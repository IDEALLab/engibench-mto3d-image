# engibench-mto3d-image

Build recipe for the OpenFOAM solver image behind the [EngiBench](https://github.com/IDEALLab/EngiBench)
`MTO3D` problem. EngiBench pins the published image by digest in `MTO3D.container_id`, the same way
`MTO2D` pins `ghcr.io/ideallab/engibench-mto2d`. Intended package: `ghcr.io/ideallab/engibench-mto3d`.

## Using the image

Nothing here is needed to *run* MTO3D. EngiBench pins the image digest in `MTO3D.container_id` and pulls it
automatically:

```python
from engibench.problems.mto3d import MTO3D

problem = MTO3D()
design, _ = problem.random_design()
objectives = problem.simulate(design)  # [mean temperature, power dissipation]
```

The image exports a pristine writable case through `mto3d-export-case`; EngiBench's `model/runner.py` uses that
protocol automatically.

## What the image is

The image derives from the published, digest-pinned MTO2D runtime
(`ghcr.io/ideallab/engibench-mto2d@sha256:2887a5c8…`). That runtime is a pinned source build of exactly
the dependency revisions found inside the legacy MTO3D image `MTO_GEN.sif`
(sha256 `d53c0b6f…62a6`): OpenFOAM-5.x `7f7d351b741b`, swak4Foam `9d8f12af95f5`, Open MPI 4.0.4,
PETSc 3.12.5, Scotch 6.0.8 and the MMA library. MMA source equality: the base image's `MMA.c` is
the legacy 3D `MMA.c` plus one added method (`resetAsymptotes`), and its header adds only that
declaration.

On top, this recipe adds:

- `case/`: the golden case `3Dheatsink_0` (inputs and production solver source, no compiled `EXEC`),
  byte-identical to its source in the shared MTO collection, laid out as `app/{0,constant,system}` and
  `src/`, plus `xh_template.gz` (the case's final design; exact fixed solid/fluid cells; the EngiBench
  writer template). Its manifest is pinned in `pins.env`.
- `patches/`, applied in order with zero fuzz:
  - `00-toolchain-compat`: include `<vector>`/`<numeric>` and the PETSc/MMA headers before OpenFOAM's
    (gcc >= 9). No numerical change.
  - `01-warm-start-initialization`: initialize the MMA variables from a supplied `0/xh`
    (warm-ready-3d order) and make `NoContinuation` an optional key (default 0).
  - `02-frozen-evaluation`: `updateDesign no` evaluates the supplied design without adjoints,
    sensitivities, MMA or filter, and writes a full-precision `frozen_status.txt`. The default (`yes`)
    keeps the legacy optimizer. EngiBench runs a frozen evaluation for 100 iterations: OpenFOAM
    applies the energy equation's `linearUpwind` convection as an explicit correction computed from
    the current temperature, so the energy equation must be re-solved until that correction has
    converged. A single iteration from the uniform initial field returns the first-order upwind
    temperature, with mean temperatures 1-16% below the converged values for the published designs.
    If a frozen iteration uses all `NSmaxIter` passes without converging the flow, the patch writes
    the status and stops the run, because the evaluation is invalid. Without this, the capped flow
    solve would repeat in each of the 100 iterations. Converged iterations never take this branch,
    so their results are unchanged.
- helpers: `mto3d-export-case` (pristine writable case), `mto3d-prepare-mesh` (hash-verified prebuilt
  `blockMesh` output), `mto3d-source-smoke` (structure) and `mto3d-reference-check` (numerics).

## Evidence (2026-11-25)

All runs use 16 MPI ranks, `simple (2 2 4)`, the decomposition of every published case.

| Check | Result |
| --- | --- |
| `blockMesh` in the base image vs the legacy SIF | byte-identical `polyMesh` |
| Legacy optimizer, first 3 iterations (production + 00, gcc 9.4) | MeanT/PowerDiss/Voluse text-identical to the 2022 golden histories |
| Same with the full patch stack (default keys) | identical |
| Patch 00 under the legacy gcc 4.8.5 toolchain | identical |
| Frozen evaluation of the golden design as EngiBench runs it (100 iterations, `(T)` tolerance 1e-10): legacy SIF toolchain vs base-image toolchain vs EngiBench on this recipe's image | **bitwise identical** `frozen_status.txt` (MeanT 0.72734474883281197, PowerDiss 21.574459770765856); flow from rest converged in 131 passes; design unchanged |
| Same, re-run independently (case 0; 8 of 48 diverse pilot designs; the 6 byte-identical design pairs in the pilot) | bitwise identical |
| Single frozen iteration of the golden design, both toolchains | bitwise identical, but first-order: MeanT 0.71813685838686836, 1.27% below the converged value |
| Frozen evaluation of all 4,999 converged published designs (EngiBench re-evaluation campaign, EPYC 7763), and 48 of them on Xeon 8592+ | every check passed; Xeon and EPYC labels bitwise identical |
| Stall guard: case 3905, whose pressure residual stalls at about 2e-6 (above the 1e-6 tolerance), with `frozen_ns_max_iter=2000` | `simulate()` raises "did not converge the flow" after 131 s, instead of repeating the capped solve in all 100 iterations |
| Image with the stall guard vs the image that computed the dataset labels (48 diverse designs) | bitwise identical labels; release gate and EngiBench end-to-end pass |
| Full cold optimization of the golden case vs the 2022 legacy-SIF run (4 h 57 min on 16 EPYC 7763 cores) | **not bitwise**: identical for 4 iterations; Voluse differs from iteration 5, MeanT from 10, PowerDiss from 19, and the trajectories separate slowly (largest differences 0.65% in MeanT and 3.5% in PowerDiss). Both runs stop after 1,920 iterations. The final design differs in 1.1% of the design cells, and its frozen objectives are within 0.09% (MeanT) and 0.25% (PowerDiss) of the published design's. The frozen evaluation uses neither the Heaviside projection nor MMA, and is bitwise. The optimizer differences most likely come from `exp()` in glibc 2.31 vs 2.17, which the projection calls for every cell. |

The release gate (see below) is therefore the bitwise frozen evaluation exactly as EngiBench's `simulate()` runs
it, as for MTO2D, plus the first 3 legacy optimizer iterations.

Rehearsal without Docker, on an HPC cluster that has none: the same build steps as an Apptainer image
(`apptainer build --fakeroot`, bootstrapped from the base image converted to SIF) build in about 95 s;
`mto3d-source-smoke` passes, and `mto3d-reference-check` passes both parts in about 115 s (part A 45 s)
on 16 EPYC 7763 cores. EngiBench's `MTO3D`, driven through EngiBench's own Apptainer runtime on that
image, returns a `simulate()` result bitwise equal to the gate record, and a 3-iteration cold
`optimize()` whose history rows are identical to the 2022 golden histories.

## Building

```bash
./build_image.sh engibench-mto3d:local
docker run --rm --platform linux/amd64 engibench-mto3d:local mto3d-source-smoke
docker run --rm --platform linux/amd64 engibench-mto3d:local mto3d-reference-check
```

The base image already carries the compiled dependency stack, so a build only compiles the 3D solver
and takes minutes (longer under ARM emulation). The image is `linux/amd64` only.

With Apptainer, run the gates the way EngiBench runs the image (`--compat`). That mode gives `/tmp`
only a small tmpfs, so point `TMPDIR` at a bind mount:

```bash
mkdir -p gate-tmp
apptainer run --compat --mount type=bind,src="$PWD/gate-tmp",target=/work --env TMPDIR=/work \
    engibench-mto3d.sif mto3d-reference-check
```

## Publishing

The `Publish` workflow (`workflow_dispatch`) builds the image, runs both gates, and with
`publish` + `confirm_redistribution_rights` pushes `v0` and `v0-<commit>` to
`ghcr.io/<owner>/engibench-mto3d` with `GITHUB_TOKEN` (`packages: write`). New GHCR packages are
private: make the package public, verify an anonymous pull of the digest, then set
`DEFAULT_CONTAINER_IMAGE` in `engibench/problems/mto3d/v0.py`.

## Numerical release gate

`mto3d-reference-check` runs inside the image with 16 MPI ranks, oversubscribed on smaller machines (results
depend on the rank count only), and fails unless both parts pass:

- **A (bitwise).** A frozen evaluation of the bundled golden design (case `3Dheatsink_0`, `xh_template.gz`) at
  its own conditions (inlet 0.121 m/s, power bound 21.6, volume fraction 0.49), exactly as EngiBench's
  `simulate()` runs it: 100 iterations with the design fixed. `frozen_status.txt` must equal the cross-toolchain
  record as full-precision text (MeanT 0.72734474883281197, PowerDiss 21.574459770765856), and the design must
  come back unchanged.
- **B.** The first 3 legacy optimizer iterations, from the historical cold start, must reproduce the 2022 golden
  `MeanT`, `PowerDiss` and `Voluse` histories. Later optimizer iterations are not bitwise across toolchains (see
  Evidence), so the gate stops at 3.

The gate needs neither the dataset nor EngiBench. It takes about 2 minutes on 16 EPYC 7763 cores. The Publish
workflow runs it on every run, before anything is pushed.

## Licensing

The image label `org.opencontainers.image.licenses` is `GPL-3.0-or-later AND LGPL-2.1-only`
(`APPROVED_IMAGE_LICENSES` in `pins.env`). It follows the MTO2D image, whose recipe repository vendors the closely
related MTO2D solver source, is GPL-3.0-or-later and labels its image `GPL-3.0-or-later`. `LGPL-2.1-only` covers the
MMA library inherited from the base image. In the vendored solver source, ten boundary-condition files carry
OpenFOAM's GPL-3.0-or-later header; the solver itself (`MTO_TFS.C` and its include files) and two other
boundary-condition files carry no licence text, so the Publish workflow pushes only when
`confirm_redistribution_rights` is ticked. The image redistributes third-party components under their own licences,
including OpenFOAM (GPL-3.0), swak4Foam (GPL), PETSc (BSD-2-Clause), Open MPI (BSD) and MMA (LGPL-2.1, inherited
from the base image).
