# syntax=docker/dockerfile:1.7
#
# EngiBench MTO3D runtime image.
#
# Derived from the published, digest-pinned MTO2D runtime, which is a pinned source build of
# exactly the dependency revisions found inside the legacy MTO3D image MTO_GEN.sif
# (OpenFOAM-5.x 7f7d351, swak4Foam 9d8f12a, Open MPI 4.0.4, PETSc 3.12, Scotch 6.0.8, MMA).
# This image adds only the vendored 3D case and solver source, compiles the solver with the
# base image's wmake/PETSc/MMA, and installs the MTO3D case-export, mesh and gate helpers.
ARG BASE_IMAGE=ghcr.io/ideallab/engibench-mto2d@sha256:2887a5c8eaa3fba2d2738188757aeb66fe69d8ef7060698cb8512252aacaa131
FROM --platform=linux/amd64 ${BASE_IMAGE}

ARG BASE_IMAGE
ARG BASE_IMAGE_DIGEST
ARG MTO3D_CASE_MANIFEST_SHA256
ARG MTO3D_PATCHES_SHA256
ARG MTO3D_RECIPE_REVISION
ARG MTO3D_RECIPE_TREE_STATE
ARG IMAGE_LICENSES

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY case/ /opt/mto3d/case-template/
COPY patches/ /usr/local/src/mto3d-patches/
COPY install-case.sh /usr/local/sbin/mto3d-install-case
RUN chmod 0755 /usr/local/sbin/mto3d-install-case \
    && BASE_IMAGE="${BASE_IMAGE}" \
       MTO3D_CASE_MANIFEST_SHA256="${MTO3D_CASE_MANIFEST_SHA256}" \
       MTO3D_PATCHES_SHA256="${MTO3D_PATCHES_SHA256}" \
       /usr/local/bin/mto2d-entrypoint /usr/local/sbin/mto3d-install-case

COPY build-prebuilt-mesh.sh /usr/local/sbin/mto3d-build-prebuilt-mesh
RUN chmod 0755 /usr/local/sbin/mto3d-build-prebuilt-mesh \
    && /usr/local/bin/mto2d-entrypoint /usr/local/sbin/mto3d-build-prebuilt-mesh

COPY entrypoint.sh /usr/local/bin/mto3d-entrypoint
COPY export-case.sh /usr/local/bin/mto3d-export-case
COPY prepare-mesh.sh /usr/local/bin/mto3d-prepare-mesh
COPY smoke-test.sh /usr/local/bin/mto3d-source-smoke
COPY reference-check.sh /usr/local/bin/mto3d-reference-check
RUN chmod 0755 \
        /usr/local/bin/mto3d-entrypoint \
        /usr/local/bin/mto3d-export-case \
        /usr/local/bin/mto3d-prepare-mesh \
        /usr/local/bin/mto3d-source-smoke \
        /usr/local/bin/mto3d-reference-check \
    && /usr/local/bin/mto3d-entrypoint mto3d-source-smoke

LABEL org.opencontainers.image.title="EngiBench MTO3D runtime" \
      org.opencontainers.image.description="MTO3D OpenFOAM thermal-fluid topology-optimization solver on the pinned MTO2D runtime" \
      org.opencontainers.image.licenses="${IMAGE_LICENSES}" \
      org.opencontainers.image.source="https://github.com/IDEALLab/engibench-mto3d-image" \
      org.opencontainers.image.documentation="https://engibench.ethz.ch/problems/mto3d/" \
      org.opencontainers.image.vendor="IDEALLab" \
      org.opencontainers.image.version="v0" \
      org.opencontainers.image.revision="${MTO3D_RECIPE_REVISION}" \
      org.opencontainers.image.mto3d.recipe-tree-state="${MTO3D_RECIPE_TREE_STATE}" \
      org.opencontainers.image.base.name="${BASE_IMAGE}" \
      org.opencontainers.image.base.digest="${BASE_IMAGE_DIGEST}" \
      org.opencontainers.image.mto3d.case-manifest.sha256="${MTO3D_CASE_MANIFEST_SHA256}" \
      org.opencontainers.image.mto3d.patches.sha256="${MTO3D_PATCHES_SHA256}"

ENTRYPOINT ["/usr/local/bin/mto3d-entrypoint"]
CMD ["/bin/bash"]
