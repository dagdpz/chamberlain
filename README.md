# chamberlain

MATLAB toolbox for visualizing recording and microstimulation electrode locations on chamber MRI scans. Overlays chamber geometry, grid hole positions, and penetration sites on BrainVoyager VMR volumes via [NeuroElf](https://neuroelf.net/).

## Requirements

- MATLAB
- [NeuroElf](https://neuroelf.net/) (BVQXtools / `xff`, `BVQXfile`, `ne_voi_sphere_around_voxel`, etc.)

```matlab
addpath('Y:\Sources\NeuroElf_v11_7521\');  % DAG example path
addpath('path/to/chamberlain');
```

Experiment-specific penetration databases live in a separate repo: [dagdpz/Settings/chamberlain](https://github.com/dagdpz/Settings/tree/master/chamberlain).

## Coordinate system

Penetration locations use grid coordinates:

| Field | Meaning |
|-------|---------|
| `xyz(:,1:2)` | Grid hole indices (x, y) |
| `xyz(:,3)` | Depth in mm from chamber top (or brain surface, depending on db) |
| `z_offset_mm` | Distance from chamber top to brain entry; added to z before plotting |

Grid hole positions in mm are obtained by multiplying hole indices by `grid_spacing` from `grid_db.m`.

## Supported grids (`grid_db.m`)

| Grid ID | Chamber | Spacing |
|---------|---------|---------|
| `GRID.22.1`, `GRID.22.2` | Large CIT (Caltech) | 0.8 mm |
| `GRID.22.3`, `GRID.22.4` | Large CIT (Crist) | 0.8 mm |
| `L.G.1` | Small CIT | 1.0 mm |
| `R.G.3`, `N.G` | Small CIT | 0.8 mm |

Each entry defines inner/outer chamber radius (`chamber.IR`/`chamber.OR`), hole coordinates (`xy_mm`), spacing, and alignment protrusion angle.

## Files

### Core

| File | Purpose |
|------|---------|
| `chamberlain.m` | Interactive axial-slice viewer: load VMR, overlay chamber ring and crosshairs, optionally plot grid holes and a location marker |
| `grid_db.m` | Grid/chamber geometry lookup (run via `grid_id` in workspace) |
| `penetration_db.m` | Minimal example penetration database |
| `plot_grid.m` | Standalone grid visualization with alignment mark |

### Slice plotting

| File | Purpose |
|------|---------|
| `plot_coronal_slice.m` | Plot a penetration on a coronal slice; reuses existing figure per y-coordinate |
| `plot_coronal_slice_smaller.m` | Same as above, smaller markers (for dense multi-site plots) |
| `plot_sagittal_slice.m` | Plot a penetration on a sagittal slice |

### Batch localization

| File | Purpose |
|------|---------|
| `plot_electrode_localization.m` | Plot all penetrations from a db file on coronal slices; optional VOI export to BrainVoyager |
| `plot_electrode_localization_tuned.m` | Significant vs non-significant sites (white markers for non-sig); monkey-specific color schemes |
| `plot_electrode_localization_categories.m` | Multi-category significance coloring with electrode track lines |
| `CL_plot_electrode_localization.m` | Variant accepting a `keys` struct; coronal or sagittal; integrates with tuning-table pipeline |
| `CL_readout_from_tuning_table.m` | Populate penetration data from DAG extended tuning tables |
| `map_grid_penetrations.m` | Interactive grid map with listbox to highlight penetrations |
| `recolor_markers.m` | Depth-gradient recoloring of penetration markers |

## Usage

### Interactive chamber viewer (axial slices)

```matlab
% Load VMR and grid, show chamber at z=0
chamberlain('load_file', 'path/to/chamber.vmr', 'R.G.3');

% Navigate to z (mm) and mark xy location (mm)
chamberlain(-8, [-2 -2]);

% Show grid holes; optional location in grid-hole units
chamberlain('plot_grid', [3 3]);
```

### Single coronal/sagittal slice

```matlab
[x, y, z] = plot_coronal_slice('path/to/chamber.vmr', [x_mm y_mm z_mm], z_offset_mm);
[x, y, z] = plot_sagittal_slice('path/to/chamber.vmr', [x_mm y_mm z_mm], z_offset_mm);
```

### Batch electrode localization

DB `.m` files must define: `experiment_id`, `grid_id`, `vmr_path`, `z_offset_mm`, `penetration_date`, `xyz`, `target`, `notes` (and optionally `monkey_prefix`, `significant`, `xyz_nojitter`).

```matlab
plot_electrode_localization('Linus_microstim_beh_electrode_MRI_localization', ...
    'Linus_microstim_beh_electrode_MRI_localization_dorsal_direct', 'r');

% With VOI export
plot_electrode_localization(db_file, experiment_id, 'r', 1);
```

### Interactive grid map

```matlab
map_grid_penetrations('penetration_db', 'test');
map_grid_penetrations('path/to/experiment_db.m');
```

### Tuning-table pipeline (DAG)

```matlab
CL_plot_electrode_localization(keys, experiment_id, co, save_voi, 'coronal');
% keys must contain: vmr_path, z_offset_mm, monkey, grid_id, xyz, xyz_nojitter,
%                    penetration_date, significant
```

## Notes

- Radiological VMRs (`Convention == 1`) are flipped L-R so R displays as R.
- VOI export creates small spherical VOIs per penetration and can run `ne_voicoord2tal` for Talairach coordinates.
- `plot_electrode_localization_tuned` and `_categories` expect a logical `significant` flag per penetration (or per category) in the db file.
- Jitter on x or y (in `CL_readout_from_tuning_table`) separates overlapping markers on the same slice.
