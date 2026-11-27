#!/usr/bin/env bash
# Build-time only (run through the base image's entrypoint, which provides the OpenFOAM 5.x,
# PETSc and Open MPI environment): compile the vendored MTO3D solver and finalize the template.
set -euo pipefail
: "${BASE_IMAGE:?}" "${MTO3D_CASE_MANIFEST_SHA256:?}" "${MTO3D_PATCHES_SHA256:?}"

readonly template=/opt/mto3d/case-template
test -d "$template/app/0" && test -d "$template/app/constant" && test -d "$template/app/system"
test -d "$template/src" && test ! -e "$template/src/EXEC"
command -v wmake >/dev/null
test -f /opt/libMMA_yu.so            # MMA library of the base image (Make/options: -L/opt -lMMA_yu)
test -e /opt/MPI_INC                 # Make/options: -I/opt/MPI_INC
test -f "$FOAM_USER_LIBBIN/libgroovyBC.so"   # controlDict: libs ("libgroovyBC.so")

test -f "$template/xh_template.gz"           # writer template: golden final design, exact fixed cells

# EngiBench solver patches, applied in order with zero fuzz: 00 gcc>=9 compatibility (no numerical
# change), 01 warm-start initialization (optional NoContinuation), 02 frozen evaluation
# (updateDesign switch). With default keys the solver follows the legacy optimizer path.
for patch_file in /usr/local/src/mto3d-patches/0*.patch; do
    (cd "$template" && patch -p1 --batch --forward --no-backup-if-mismatch -F0 <"$patch_file")
done
grep -q updateDesign "$template/src/createFields.H"
# Compile against the header /opt/libMMA_yu.so was built from: it differs from the case copy only by
# the resetAsymptotes() declaration, and MMA.c differs from the legacy 3D library only by that method.
install -m 0644 /usr/local/src/mto2d-mma/MMA.h "$template/src/MMA.h"
(cd "$template/src" && wmake)
test -x "$template/src/EXEC"
(cd "$template/src" && wclean)
test -x "$template/src/EXEC"
if ldd "$template/src/EXEC" | grep -q 'not found'; then
    echo "The MTO3D solver has unresolved shared-library dependencies." >&2
    exit 1
fi

printf '1\n' >"$template/.engibench-mto3d-runtime-version"
mkdir -p /opt/mto3d
{
    printf 'base_image=%s\n' "$BASE_IMAGE"
    printf 'case_manifest_sha256=%s\n' "$MTO3D_CASE_MANIFEST_SHA256"
    printf 'patches_sha256=%s\n' "$MTO3D_PATCHES_SHA256"
    printf 'mma_header_sha256=%s\n' "$(sha256sum "$template/src/MMA.h" | awk '{print $1}')"
} >/opt/mto3d/mto3d-source-inputs.txt
sha256sum /opt/libMMA_yu.so "$template/src/EXEC" >/opt/mto3d/binary-sha256.txt
