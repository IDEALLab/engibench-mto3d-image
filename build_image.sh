#!/usr/bin/env bash
# Build the MTO3D runtime image locally (linux/amd64) from this recipe.
# Usage: ./build_image.sh [output-image]   (default engibench-mto3d:local)
set -euo pipefail

output_image=${1:-engibench-mto3d:local}
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=pins.env
source "$here/pins.env"

command -v docker >/dev/null && docker buildx version >/dev/null 2>&1 || {
    echo "Docker with Buildx is required." >&2; exit 1; }
if docker image inspect "$output_image" >/dev/null 2>&1; then
    echo "Output image already exists; refusing to replace it: $output_image" >&2
    exit 1
fi
[[ -d "$here/case/app" && -d "$here/case/src" ]] || { echo "case/ must contain app/ and src/" >&2; exit 1; }
unexpected=$(find "$here/case" \( -name EXEC -o -name '*.o' -o -name '*.so' -o -name '*~' \) -print)
if [[ -n "$unexpected" ]]; then
    echo "Vendored case contains build output that must not be committed:" >&2
    echo "$unexpected" >&2
    exit 1
fi
case_manifest_sha256=$(cd "$here/case" && find . -type f -print0 | LC_ALL=C sort -z \
    | xargs -0 shasum -a 256 | shasum -a 256 | awk '{print $1}')
[[ "$case_manifest_sha256" == "$MTO3D_CASE_MANIFEST_SHA256" ]] || {
    echo "case/ manifest $case_manifest_sha256 != pinned $MTO3D_CASE_MANIFEST_SHA256" >&2; exit 1; }
patches_sha256=$(cd "$here/patches" && shasum -a 256 0*.patch | shasum -a 256 | awk '{print $1}')
revision=$(git -C "$here" rev-parse HEAD 2>/dev/null || echo unknown)
tree_state=clean
[[ -z "$(git -C "$here" status --porcelain --untracked-files=normal 2>/dev/null)" ]] || tree_state=dirty

docker buildx build \
    --platform linux/amd64 \
    --load \
    --file "$here/Dockerfile" \
    --build-arg "BASE_IMAGE=$BASE_IMAGE" \
    --build-arg "MTO3D_CASE_MANIFEST_SHA256=$case_manifest_sha256" \
    --build-arg "MTO3D_PATCHES_SHA256=$patches_sha256" \
    --build-arg "MTO3D_RECIPE_REVISION=$revision" \
    --build-arg "MTO3D_RECIPE_TREE_STATE=$tree_state" \
    --build-arg "IMAGE_LICENSES=$APPROVED_IMAGE_LICENSES" \
    --tag "$output_image" \
    "$here"
echo "Built $output_image. Check it with:"
echo "  docker run --rm --platform linux/amd64 $output_image mto3d-source-smoke"
echo "  docker run --rm --platform linux/amd64 $output_image mto3d-reference-check"
