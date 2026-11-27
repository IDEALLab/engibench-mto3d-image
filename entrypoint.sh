#!/bin/bash
# mto3d-entrypoint: the MTO3D image reuses the base image's validated OpenFOAM 5.x / PETSc /
# OpenMPI 4.0.4 environment setup unchanged.
exec /usr/local/bin/mto2d-entrypoint "$@"
