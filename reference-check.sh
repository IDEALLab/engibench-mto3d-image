#!/usr/bin/env bash
# mto3d-reference-check: numerical release gate for the MTO3D image (16 MPI ranks, simple (2 2 4)).
#
# A (bitwise, primary). Frozen evaluation of the bundled golden design -- case 3Dheatsink_0's
#   stored final xh, xh_template.gz, sha256 5219bdbe...b35b -- at its own conditions (inlet
#   (0 0 -0.121), PowerDissMax 21.6, voluse 0.49), exactly as EngiBench's MTO3D.simulate() runs it:
#   updateDesign no, final physics, flow from rest to residual 1e-6, and 100 iterations with the
#   design fixed (writeInterval 100, writePrecision 12) and the (T) solver at tolerance 1e-10.
#   OpenFOAM applies the energy equation's linearUpwind convection as an explicit correction from
#   the current temperature; the iterations converge it (one iteration would return the first-order
#   upwind temperature). frozen_status.txt must equal, as full-precision text, the record that the
#   legacy MTO_GEN.sif toolchain (gcc 4.8.5, CentOS 7), the base image's toolchain (gcc 9.4, Ubuntu
#   20.04) and EngiBench on this recipe's image produced bit for bit, and the design must come back
#   unchanged. Frozen evaluation runs no Heaviside projection and no MMA, which is why it is
#   toolchain-independent.
# B (secondary). The first 3 legacy optimization iterations reproduce the 2022 golden histories.
#   Later optimizer iterations are not bitwise across toolchains (the projection's exp() differs in
#   the last bit between glibc versions), so the gate stops at 3.
# Oversubscription does not change results: reductions depend on the rank count only.
set -euo pipefail

readonly frozen_iterations=100
readonly expected_status=$'iteration 100\nmean_temperature 0.72734474883281197\npower_dissipation 21.574459770765856\nvolume_residual -0.056715922051203072\nns_passes 1\nns_max_iter 20000\ninitial_residual_U 1.8321119970195303e-09\ninitial_residual_p 1.2402577187434099e-08\nns_converged 1\nqu 0.001\nalphaMax 2500000'
declare -A golden=(
    [MeanT]=$'1\t3.60179\n2\t3.55877\n3\t3.55257'
    [PowerDiss]=$'1\t3.4759\n2\t3.43107\n3\t3.4331'
    [Voluse]=$'1\t-0.0278788\n2\t-0.0326202\n3\t-0.0327574'
)

work=$(mktemp -d "${TMPDIR:-/tmp}/mto3d-reference.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
mpirun_flags=(--oversubscribe)
if [[ "$(id -u)" -eq 0 ]]; then
    mpirun_flags+=(--allow-run-as-root)  # e.g. `docker run` without --user, as in the publish workflow
fi
run_case() {  # run_case <case-dir>
    (
        cd "$1/app"
        mto3d-prepare-mesh . >"$1/mesh.log" 2>&1
        decomposePar >"$1/decompose.log" 2>&1
        if ! mpirun "${mpirun_flags[@]}" -n 16 ../src/EXEC -parallel >"$1/solver.log" 2>&1; then
            tail -n 40 "$1/solver.log" >&2
            echo "MTO3D reference run failed in $1" >&2
            exit 1
        fi
        reconstructPar -latestTime >"$1/reconstruct.log" 2>&1
    )
}
set_once() {  # set_once <file> <anchor-ERE> <sed-expression>: the anchor must match exactly one line
    local count before
    count=$(grep -c -E "$2" "$1" || true)
    if [[ "$count" -ne 1 ]]; then
        echo "expected exactly one line matching '$2' in $1; found $count" >&2
        exit 1
    fi
    before=$(cat "$1")
    sed -i -E "$3" "$1"
    if [[ "$(cat "$1")" == "$before" ]]; then
        echo "edit did not change $1: $3" >&2
        exit 1
    fi
}

# --- A: frozen evaluation of the golden design
mto3d-export-case "$work/frozen"
app=$work/frozen/app
zcat "$work/frozen/xh_template.gz" | sed -E 's/^([[:space:]]*location[[:space:]]+)"[^"]*";/\1"0";/' \
    | gzip -n >"$app/0/xh.gz"
set_once "$app/constant/optProperties" '^continuation[[:space:]]*$' 's/^(continuation[[:space:]]*)$/updateDesign        no;\n\1/'
set_once "$app/constant/optProperties" '^continuation[[:space:]]*$' '/^continuation[[:space:]]*$/{n;s/^\{$/{\n    NoContinuation      1;/}'
set_once "$app/constant/transportProperties" '^NSmaxIter[[:space:]]+[0-9]+;' 's/^(NSmaxIter[[:space:]]+)[0-9]+;/\120000;/'
set_once "$app/system/controlDict" '^endTime[[:space:]]+[0-9]+;' "s/^(endTime[[:space:]]+)[0-9]+;/\\1$frozen_iterations;/"
set_once "$app/system/controlDict" '^writeInterval[[:space:]]+[0-9]+;' "s/^(writeInterval[[:space:]]+)[0-9]+;/\\1$frozen_iterations;/"
set_once "$app/system/controlDict" '^writePrecision[[:space:]]+[0-9]+;' 's/^(writePrecision[[:space:]]+)[0-9]+;/\112;/'
set_once "$app/system/fvSolution" '^[[:space:]]*"\(T\)"[[:space:]]*$' \
    '/^[[:space:]]*"\(T\)"[[:space:]]*$/,/\}/{s/^([[:space:]]*tolerance[[:space:]]+)[^;]*;/\11e-10;/;s/^([[:space:]]*relTol[[:space:]]+0;)[[:space:]]*$/\1\n        maxIter         20000;/}'
t_solver=$(sed -n -E '/^[[:space:]]*"\(T\)"[[:space:]]*$/,/\}/p' "$app/system/fvSolution")
[[ $(grep -c -E '^[[:space:]]*tolerance[[:space:]]+1e-10;' <<<"$t_solver") -eq 1 &&
   $(grep -c -E '^[[:space:]]*maxIter[[:space:]]+20000;' <<<"$t_solver") -eq 1 ]] || { echo "(T) solver not set" >&2; exit 1; }
[[ $(grep -c 'NoContinuation      1;' "$app/constant/optProperties") -eq 1 ]] || { echo "NoContinuation not set" >&2; exit 1; }
start=$(date +%s)
run_case "$work/frozen"
actual_status=$(grep -v '^elapsed_clock_time' "$app/frozen_status.txt")
status=0
if [[ "$actual_status" == "$expected_status" ]]; then
    echo "A: frozen evaluation ($frozen_iterations iterations) identical to the cross-toolchain record (bitwise)"
else
    echo "A: frozen evaluation MISMATCH" >&2
    diff <(printf '%s\n' "$expected_status") <(printf '%s\n' "$actual_status") >&2 || true
    status=1
fi
if cmp -s <(zcat "$app/0/xh.gz" | sed -n '/^internalField/,/^)/p') \
          <(zcat "$app/$frozen_iterations/xh.gz" | sed -n '/^internalField/,/^)/p'); then
    echo "A: design unchanged by the frozen evaluation"
else
    echo "A: frozen evaluation CHANGED the design" >&2
    status=1
fi
echo "A: wall time $(( $(date +%s) - start ))s"

# --- B: first 3 legacy optimization iterations (no 0/xh: historical cold start)
mto3d-export-case "$work/legacy"
set_once "$work/legacy/app/system/controlDict" '^endTime[[:space:]]+[0-9]+;' 's/^(endTime[[:space:]]+)[0-9]+;/\13;/'
run_case "$work/legacy"
for name in MeanT PowerDiss Voluse; do
    if [[ "$(cat "$work/legacy/app/$name.txt")" == "${golden[$name]}" ]]; then
        echo "B: $name rows 1-3 identical to the 2022 golden history"
    else
        echo "B: $name MISMATCH" >&2
        paste "$work/legacy/app/$name.txt" <(printf '%s\n' "${golden[$name]}") >&2
        status=1
    fi
done
if [[ $status -ne 0 ]]; then
    echo "MTO3D numerical release gate FAILED." >&2
    exit 1
fi
echo "MTO3D numerical release gate passed."
