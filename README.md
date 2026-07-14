# chamberlain

MATLAB toolbox for visualizing recording and microstimulation electrode locations on chamber MRI scans. Overlays chamber geometry, grid hole positions, and penetration sites on BrainVoyager VMR volumes via [NeuroElf](https://neuroelf.net/).

All toolbox functions use the `cl_` prefix. Project-specific code lives in subfolders with an additional prefix (e.g. `cl_pulv_bodysignals_*` in `Pulv_bodysignals/`).

## Requirements

- MATLAB
- [NeuroElf](https://neuroelf.net/) (BVQXtools / `xff`, `BVQXfile`, `ne_voi_sphere_around_voxel`, etc.)

```matlab
addpath('Y:\Sources\NeuroElf_v11_7521\');  % DAG example path
addpath('path/to/chamberlain');
addpath('path/to/chamberlain/helpers');
addpath('path/to/chamberlain/Pulv_bodysignals');  % project-specific dbs
```

Experiment-specific penetration databases may also live in a separate repo: [dagdpz/Settings/chamberlain](https://github.com/dagdpz/Settings/tree/master/chamberlain).

## Coordinate system

Penetration locations use grid coordinates:

| Field | Meaning |
|-------|---------|
| `xyz(:,1:2)` | Grid hole indices (x, y) |
| `xyz(:,3)` | Depth in mm from chamber top (or brain surface, depending on db) |
| `z_offset_mm` | Distance from chamber top or GRID top to brain entry; added to z before plotting, should be different from 0 if z is from top of the chamber |

Grid hole positions in mm are obtained by multiplying hole indices by `grid_spacing` from `cl_grid_db.m`.

## Supported grids (`cl_grid_db.m`)

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
| `cl_chamberlain.m` | Interactive axial-slice viewer: load VMR, overlay chamber ring and crosshairs, optionally plot grid holes and a location marker |
| `cl_grid_db.m` | Grid/chamber geometry lookup (run via `grid_id` in workspace) |
| `cl_penetration_db_example.m` | Minimal example penetration database |
| `cl_create_penetration_db.m` | Build penetration db from Excel sorting table + MAT site list |
| `cl_example_create_penetration_db.m` | Template function for `cl_create_penetration_db` (copy for new projects; includes Pulv_bodysignals example) |
| `cl_example_visualization_settings.m` | Template function for per-project plot cfg (pair with penetration db) |
| `cl_plot_grid.m` | Standalone grid visualization with alignment mark |

### Helpers (`helpers/`)

Marker styling and slice-plot utilities used by the slice plotters and batch localization functions.

| File | Purpose |
|------|---------|
| `helpers/cl_load_visualization_settings.m` | Resolve `*_visualization_settings.m` from db filename (or `viz_settings` override) |
| `helpers/cl_parse_marker_style.m` | Normalize color char / RGB / struct into marker face/edge/alpha fields |
| `helpers/cl_apply_marker_style.m` | Apply parsed style to existing plot handles |
| `helpers/cl_parse_plot_options.m` | Jitter and trajectory options (`JitterFraction`, `DrawTrajectory`) |
| `helpers/cl_marker_jitter_offset.m` | Per-marker jitter offset on slice plane |
| `helpers/cl_plot_slice_marker.m` | Plot one penetration marker with style + jitter + optional trajectory line |
| `helpers/cl_recolor_markers.m` | Depth-gradient recoloring of penetration markers |

### Slice plotting

| File | Purpose |
|------|---------|
| `cl_plot_coronal_slice.m` | Plot a penetration on a coronal slice; reuses existing figure per y-coordinate |
| `cl_plot_coronal_slice_smaller.m` | Same as above, smaller markers (for dense multi-site plots) |
| `cl_plot_sagittal_slice.m` | Plot a penetration on a sagittal slice |
| `cl_plot_sagittal_slice_smaller.m` | Same as above, smaller markers (for dense multi-site plots) |

### Batch localization

| File | Purpose |
|------|---------|
| `cl_plot_electrode_localization.m` | Plot all penetrations from a db file on coronal slices; optional VOI export |
| `cl_plot_electrode_localization_tuned.m` | Significant vs non-significant sites (white markers for non-sig); monkey-specific color schemes |
| `cl_plot_electrode_localization_categories.m` | Multi-category significance coloring with electrode track lines |
| `cl_plot_electrode_localization_from_keys.m` | Variant accepting a `keys` struct; coronal or sagittal; integrates with tuning-table pipeline |
| `cl_readout_from_tuning_table.m` | Populate penetration data from DAG extended tuning tables (script, run in caller workspace) |
| `cl_map_grid_penetrations.m` | Interactive grid map with listbox to highlight penetrations |

### Pulv_bodysignals (`Pulv_bodysignals/`)

| File | Purpose |
|------|---------|
| `cl_pulv_bodysignals_bacchus_build_db.m` | Bacchus (B) build — split L/R chamber VMRs |
| `cl_pulv_bodysignals_bacchus_penetration_db.m` | Generated Bacchus db: `VP_R`, `dPul_L`, `dPul_R`, `MD_L`, `MD_R` |
| `cl_pulv_bodysignals_magnus_build_db.m` | Magnus (M) build — VMR paths TBD in build script |
| `cl_pulv_bodysignals_magnus_penetration_db.m` | Generated Magnus db: `VP_L`, `dPul_L`, `dPul_R`, `MD_L` |
| `cl_pulv_bodysignals_bacchus_visualization_settings.m` | Bacchus plot cfg (not overwritten by db rebuild) |
| `cl_pulv_bodysignals_magnus_visualization_settings.m` | Magnus plot cfg (not overwritten by db rebuild) |

## Usage

### Interactive chamber viewer (axial slices)

```matlab
cl_chamberlain('load_file', 'path/to/chamber.vmr', 'R.G.3');
cl_chamberlain(-8, [-2 -2]);              % z (mm) and xy location (mm)
cl_chamberlain('plot_grid', [3 3]);       % grid holes; optional location in hole units
```

### Single coronal/sagittal slice

```matlab
% cl_plot_coronal_slice(filename, xyz_mm, z_offset_mm [, marker_style [, plot_opts]])
% cl_plot_sagittal_slice(filename, xyz_mm, z_offset_mm [, marker_style [, plot_opts]])

[x, y, z] = cl_plot_coronal_slice('path/to/chamber.vmr', [x_mm y_mm z_mm], z_offset_mm);
[x, y, z] = cl_plot_sagittal_slice('path/to/chamber.vmr', [x_mm y_mm z_mm], z_offset_mm);

% Marker style + jitter/trajectory options (MarkerSize in style scales jitter)
cl_plot_coronal_slice(vmr, xyz_mm, z_offset, struct('FaceColor',[1 0 0],'EdgeColor','k','MarkerSize',3), ...
    struct('JitterFraction',0.5,'DrawTrajectory',true));
```

Dense multi-site plots use `cl_plot_coronal_slice_smaller` / `cl_plot_sagittal_slice_smaller` (default `MarkerSize` 3). `cl_plot_electrode_localization_from_keys` and `_categories` call the `_smaller` variants.

### Batch electrode localization

DB `.m` files must define: `experiment_id`, `grid_id`, `vmr_path`, `z_offset_mm`, `penetration_date`, `xyz`, `target`, `notes` (and optionally `monkey_prefix`, `significant`, `xyz_nojitter`, `viz_settings`).

```matlab
% Signature:
% cl_plot_electrode_localization(db_file, experiment_id [, marker_style [, save_voi [, plot_opts]]])

cl_plot_electrode_localization(db_file, experiment_id);  % loads *_visualization_settings.m

cl_plot_electrode_localization('Linus_microstim_beh_electrode_MRI_localization', ...
    'Linus_microstim_beh_electrode_MRI_localization_dorsal_direct', 'r');

cl_plot_electrode_localization(db_file, experiment_id, 'r', 1);  % with VOI export

% Explicit style + plot options (override cfg)
cl_plot_electrode_localization(db_file, experiment_id, ...
    struct('FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5), 0, ...
    struct('JitterFraction',0.5,'DrawTrajectory',true));
```

#### Visualization settings (`*_visualization_settings.m`)

Plot defaults live in a **separate** function file so `cl_create_penetration_db` can regenerate the penetration db without wiping them.

**Filename convention** (auto-discovered from db path via `cl_load_visualization_settings`):

| Penetration db | Visualization settings |
|----------------|------------------------|
| `cl_pulv_bodysignals_bacchus_penetration_db.m` | `cl_pulv_bodysignals_bacchus_visualization_settings.m` |
| `cl_pulv_bodysignals_magnus_penetration_db.m` | `cl_pulv_bodysignals_magnus_visualization_settings.m` |
| `my_penetration_db.m` | `my_visualization_settings.m` |

Override: set `viz_settings = 'my_custom_func'` in the penetration db.

```matlab
function cfg = cl_pulv_bodysignals_bacchus_visualization_settings(experiment_id)
cfg = struct( ...
    'marker_style', struct( ...
        'FaceColor', [1 0 0], 'EdgeColor', 'k', ...
        'FaceAlpha', 0.3, 'EdgeAlpha', 1, 'MarkerSize', 3), ...
    'plot_opts', struct( ...
        'JitterFraction', 0.5, 'DrawTrajectory', true), ...
    'category_colors', {{[1 0 0], [0 1 0]}});  % for _categories only

switch experiment_id
    case 'Pulv_bodysignals_dPul_L'
        cfg.plot_opts.JitterFraction = 0.75;
    otherwise
        error('Unknown experiment_id: %s', experiment_id);
end
end
```

Copy `cl_example_visualization_settings.m` as a starting point for new projects.

| `cfg` field | Used by | Meaning |
|-------------|---------|---------|
| `marker_style` | `cl_plot_electrode_localization`, slice plotters | char, RGB, or struct (see below) |
| `plot_opts` | slice plotters, batch functions | `JitterFraction`, `DrawTrajectory` |
| `category_colors` | `cl_plot_electrode_localization_categories` | cell of colors, one per `significant` column |

**`marker_style` fields** (via `cl_parse_marker_style`):

| Field | Default | Notes |
|-------|---------|-------|
| `FaceColor` | `[1 0 0]` | char or RGB |
| `EdgeColor` | `FaceColor/2` if omitted | char or RGB |
| `FaceAlpha` | `1` | `0` = hollow/outline marker only |
| `EdgeAlpha` | `1` | |
| `MarkerSize` | `5` (`cl_plot_coronal_slice`), `3` (`*_smaller`) | also sets jitter amplitude |

**`plot_opts` fields** (via `cl_parse_plot_options`):

| Field | Default | Notes |
|-------|---------|-------|
| `JitterFraction` | `0` | Random offset in the **slice plane only**: left–right on coronal, anterior–posterior on sagittal. Range = fraction × marker diameter. Typical: `0.3`–`0.75`. Depth is never jittered. |
| `DrawTrajectory` | `false` | One dashed white line per unique grid column on the slice; jitter moves markers only, not the line |

On older MATLAB versions without `MarkerFaceAlpha`/`MarkerEdgeAlpha`, partial transparency is approximated by blending RGB toward gray.

### Build penetration database (Excel + MAT)

```matlab
% Pulv_bodysignals Bacchus (requires network paths):
addpath('path/to/chamberlain');
addpath('path/to/chamberlain/Pulv_bodysignals');
report = cl_pulv_bodysignals_bacchus_build_db;
cl_plot_electrode_localization('cl_pulv_bodysignals_bacchus_penetration_db', ...
    'Pulv_bodysignals_dPul_R');

% Magnus (set VMR paths in cl_pulv_bodysignals_magnus_build_db before plotting):
report = cl_pulv_bodysignals_magnus_build_db;
cl_plot_electrode_localization('cl_pulv_bodysignals_magnus_penetration_db', ...
    'Pulv_bodysignals_dPul_R');

% Generic template for a new project:
report = cl_example_create_penetration_db;  % edit paths first
% copy cl_example_visualization_settings.m -> my_visualization_settings.m
```

### Interactive grid map

```matlab
cl_map_grid_penetrations('cl_penetration_db_example', 'test');
cl_map_grid_penetrations('path/to/experiment_db.m');
```

### Tuning-table pipeline (DAG)

```matlab
run('cl_readout_from_tuning_table');  % sets keys fields in workspace
cl_plot_electrode_localization_from_keys(keys, experiment_id, co, save_voi, 'coronal');
% keys must contain: vmr_path, z_offset_mm, monkey, grid_id, xyz, xyz_nojitter,
%                    penetration_date, significant
```

## Notes

- Radiological VMRs (`Convention == 1`) are flipped L-R so R displays as R.
- VOI export creates small spherical VOIs per penetration and can run `ne_voicoord2tal` for Talairach coordinates.
- `cl_plot_electrode_localization_tuned` and `_categories` expect a logical `significant` flag per penetration (or per category) in the db file. `_categories` also loads `category_colors` and `plot_opts` from `*_visualization_settings.m` when arguments are omitted.
- `cl_readout_from_tuning_table` may add small pre-jitter to `xyz` in **grid coordinates** before plotting — separate from slice-plane `JitterFraction`.
- `DrawTrajectory`: one fixed dashed line per unique grid column (LR on coronal, AP on sagittal); jitter offsets markers only, not the line.
- `cl_chamberlain` action strings (`'plot_grid'`, `'plot_location'`, etc.) are API names, not function filenames.
