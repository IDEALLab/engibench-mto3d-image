#!/usr/bin/env bash
# mto3d-prepare-mesh [app-dir]: reuse the image's hash-verified blockMesh output when the case's
# blockMeshDict is the one it was built from; otherwise run blockMesh. blockMesh is deterministic
# for this dictionary (two independent runs and the legacy SIF produce byte-identical files).
set -euo pipefail

readonly cache=/opt/mto3d/prebuilt-polyMesh
if [[ $# -gt 1 ]]; then
    echo "Usage: mto3d-prepare-mesh [app-directory]" >&2
    exit 2
fi
app=${1:-.}
dictionary=$app/system/blockMeshDict
if [[ ! -f "$dictionary" ]]; then
    echo "MTO3D case has no blockMeshDict: $dictionary" >&2
    exit 1
fi
if [[ ! -s "$cache/blockMeshDict.sha256" || ! -s "$cache/files.sha256" ]] \
    || [[ "$(sha256sum "$dictionary" | awk '{print $1}')" != "$(tr -d '[:space:]' <"$cache/blockMeshDict.sha256")" ]]; then
    echo "No matching prebuilt mesh; running blockMesh."
    (cd "$app" && blockMesh)
    exit
fi
(cd "$cache/files" && sha256sum --check --status ../files.sha256)
destination=$app/constant/polyMesh
rm -rf -- "$destination"
mkdir -p "$destination"
while read -r _hash name; do
    install -m 0644 "$cache/files/$name" "$destination/$name"
done <"$cache/files.sha256"
(cd "$destination" && sha256sum --check --status "$cache/files.sha256")
echo "Reused hash-verified MTO3D mesh from the image."
