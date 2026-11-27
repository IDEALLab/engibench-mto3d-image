#!/usr/bin/env bash
# Build-time only: run blockMesh once on the template and cache the hashed polyMesh files.
set -euo pipefail

readonly source_app=/opt/mto3d/case-template/app
readonly cache=/opt/mto3d/prebuilt-polyMesh
test -f "$source_app/system/blockMeshDict"
test ! -e "$source_app/constant/polyMesh"

temporary=$(mktemp -d /tmp/mto3d-prebuilt-mesh.XXXXXX)
trap 'rm -rf -- "$temporary"' EXIT
cp -a "$source_app" "$temporary/app"
(cd "$temporary/app" && blockMesh >/dev/null)

mkdir -p "$cache/files"
(
    cd "$temporary/app/constant/polyMesh"
    for name in *; do
        install -m 0644 "$name" "$cache/files/$name"
    done
)
sha256sum "$source_app/system/blockMeshDict" | awk '{print $1}' >"$cache/blockMeshDict.sha256"
(cd "$cache/files" && sha256sum -- * >../files.sha256)
test ! -e "$source_app/constant/polyMesh"
