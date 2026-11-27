#!/usr/bin/env bash
# mto3d-source-smoke: structural checks of the MTO3D image (no numerical run; see
# mto3d-reference-check for the numerical release gate).
set -euo pipefail

readonly template=/opt/mto3d/case-template
for command in blockMesh decomposePar reconstructPar mpirun ssh \
    mto3d-export-case mto3d-prepare-mesh mto3d-reference-check; do
    command -v "$command" >/dev/null
done
test -f /opt/libMMA_yu.so
test -f "$FOAM_USER_LIBBIN/libgroovyBC.so"
test -x "$template/src/EXEC"
test -f "$template/xh_template.gz"
grep -q updateDesign "$template/src/createFields.H"
test "$(tr -d '[:space:]' <"$template/.engibench-mto3d-runtime-version")" = 1
test -s /opt/mto3d/mto3d-source-inputs.txt
test -s /opt/mto3d/binary-sha256.txt
test -s /opt/mto3d/prebuilt-polyMesh/blockMeshDict.sha256
test -s /opt/mto3d/prebuilt-polyMesh/files.sha256
sha256sum --check --quiet /opt/mto3d/binary-sha256.txt

# The template must hold inputs only: no histories, time or processor directories, mesh, or
# wmake output.
unexpected=$(find "$template" \( -name 'MeanT.txt' -o -name 'PowerDiss.txt' -o -name 'Voluse.txt' \
    -o -name 'Time.txt' -o -name 'BI.txt' -o -name 'viol.txt' -o -name 'normL2.txt' -o -name 'qu.txt' \
    -o -name 'aMax.txt' -o -name 'Heaviside.txt' -o -name 'processor*' -o -name '*.o' -o -name '*~' \
    -o -path "$template/app/constant/polyMesh" -o -path "$template/src/Make/linux64*" \) -print -quit)
if [[ -n "$unexpected" ]]; then
    echo "Generated or backup file retained in the case template: $unexpected" >&2
    exit 1
fi
for entry in "$template"/app/*; do
    case "$(basename "$entry")" in 0|constant|system) ;; *)
        echo "Unexpected entry in the case template: $entry" >&2; exit 1 ;;
    esac
done
if ldd /opt/libMMA_yu.so "$template/src/EXEC" | grep -q 'not found'; then
    echo "Unresolved shared-library dependency." >&2
    exit 1
fi

work=$(mktemp -d "${TMPDIR:-/tmp}/mto3d-source-smoke.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
mto3d-export-case "$work/case"
mto3d-prepare-mesh "$work/case/app" >/dev/null
(cd "$work/case/app/constant/polyMesh" && sha256sum --check --status /opt/mto3d/prebuilt-polyMesh/files.sha256)
echo "MTO3D image structural smoke test passed."
