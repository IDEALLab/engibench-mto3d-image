#!/usr/bin/env bash
# mto3d-export-case: copy the image's pristine, built MTO3D case into an empty directory.
set -euo pipefail

readonly source_case=/opt/mto3d/case-template
readonly runtime_version=1

if [[ $# -ne 1 ]]; then
    echo "Usage: mto3d-export-case /empty/output/directory" >&2
    exit 2
fi
destination=$1
if [[ "$destination" != /* || "$destination" == "/" ]]; then
    echo "Destination must be an absolute path other than /: $destination" >&2
    exit 2
fi
if [[ ! -d "$source_case/app" || ! -x "$source_case/src/EXEC" ]]; then
    echo "Image does not contain a built MTO3D case template." >&2
    exit 1
fi
if [[ "$(tr -d '[:space:]' <"$source_case/.engibench-mto3d-runtime-version")" != "$runtime_version" ]]; then
    echo "Image case template has an unsupported runtime marker." >&2
    exit 1
fi
mkdir -p "$destination"
if find "$destination" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    echo "Destination is not empty; refusing to overwrite it: $destination" >&2
    exit 1
fi
cp -a --no-preserve=ownership "$source_case/." "$destination/"
test -x "$destination/src/EXEC"
test -f "$destination/.engibench-mto3d-runtime-version"
