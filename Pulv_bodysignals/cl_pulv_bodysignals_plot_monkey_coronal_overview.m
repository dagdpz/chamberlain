function fig = cl_pulv_bodysignals_plot_monkey_coronal_overview(db_file, varargin)
%CL_PULV_BODYSIGNALS_PLOT_MONKEY_CORONAL_OVERVIEW  Pulv coronal slices per target.
%
% Layout: subplot grid — one row per nucleus (VP, dPul, MD); columns = max
% slice count (L then R) across all rows.
%
% Example:
%   cl_pulv_bodysignals_plot_monkey_coronal_overview( ...
%       'cl_pulv_bodysignals_bacchus_penetration_db');

p = inputParser;
addRequired(p, 'db_file', @(x) ischar(x) || isstring(x));
addParameter(p, 'TargetOrder', {'VP', 'dPul', 'MD'}, @iscell);
addParameter(p, 'YDirection', 'descend', @(x) ismember(x, {'ascend', 'descend'}));
addParameter(p, 'DefaultMarkerSize', 3, @(x) isnumeric(x) && isscalar(x));
parse(p, db_file, varargin{:});
db_file = char(p.Results.db_file);

experiment_ids = cl_list_penetration_experiment_ids(db_file);
if isempty(experiment_ids)
    error('No experiment_id cases found in %s', db_file);
end

groups = build_target_groups(experiment_ids, p.Results.TargetOrder);
if isempty(groups)
    error('No VP/dPul/MD experiments found in %s', db_file);
end

first_id = groups(1).L;
if isempty(first_id)
    first_id = groups(1).R;
end
first = cl_load_penetration_experiment(db_file, first_id);
grid_id = first.grid_id;
run('cl_grid_db'); %#ok<RUN>

vmr_cache = containers.Map('KeyType', 'char', 'ValueType', 'any');
monkey_label = first_id;
if isfield(first, 'monkey')
    monkey_label = first.monkey;
end

n_rows = numel(groups);
max_cols = 0;
for gi = 1:n_rows
    n_cols = count_y_slices(db_file, groups(gi).L) + count_y_slices(db_file, groups(gi).R);
    max_cols = max(max_cols, n_cols);
end

fig = figure('Name', sprintf('Coronal overview — %s', monkey_label), ...
    'Position', [40 40 1800 900]);

for gi = 1:n_rows
    nL = count_y_slices(db_file, groups(gi).L);
    nR = count_y_slices(db_file, groups(gi).R);

    plot_hemisphere_slices(fig, n_rows, max_cols, gi, 1:nL, db_file, groups(gi).L, 'L', ...
        groups(gi).target, vmr_cache, grid_spacing, p.Results);
    plot_hemisphere_slices(fig, n_rows, max_cols, gi, nL + (1:nR), db_file, groups(gi).R, 'R', ...
        groups(gi).target, vmr_cache, grid_spacing, p.Results);

    for c = (nL + nR + 1):max_cols
        subplot(n_rows, max_cols, (gi - 1) * max_cols + c);
        axis off;
    end
end

end

function groups = build_target_groups(experiment_ids, target_order)
groups = struct('target', {}, 'L', {}, 'R', {});
for ti = 1:numel(target_order)
    target = target_order{ti};
    exp_L = '';
    exp_R = '';
    for i = 1:numel(experiment_ids)
        eid = experiment_ids{i};
        tok = regexp(eid, ['_' target '_(L|R)$'], 'tokens', 'once');
        if isempty(tok)
            continue;
        end
        if strcmp(tok{1}, 'L')
            exp_L = eid;
        else
            exp_R = eid;
        end
    end
    if ~isempty(exp_L) || ~isempty(exp_R)
        groups(end + 1).target = target; %#ok<AGROW>
        groups(end).L = exp_L;
        groups(end).R = exp_R;
    end
end
end

function n = count_y_slices(db_file, experiment_id)
if isempty(experiment_id)
    n = 0;
    return;
end
data = cl_load_penetration_experiment(db_file, experiment_id);
n = numel(unique(data.xyz(:, 2)));
end

function plot_hemisphere_slices(~, n_rows, max_cols, row_idx, col_idx, ...
        db_file, experiment_id, hemi, target, vmr_cache, grid_spacing, opts)
if isempty(experiment_id) || isempty(col_idx)
    return;
end

data = cl_load_penetration_experiment(db_file, experiment_id);
cfg = cl_load_visualization_settings(db_file, experiment_id);
grid_id = data.grid_id;
marker_style = 'r';
plot_opts = struct();
if isfield(cfg, 'marker_style') && ~isempty(cfg.marker_style)
    marker_style = cfg.marker_style;
end
if isfield(cfg, 'plot_opts') && ~isempty(cfg.plot_opts)
    plot_opts = cfg.plot_opts;
end

y_grid = unique(data.xyz(:, 2));
y_mm = y_grid * grid_spacing;
if strcmp(opts.YDirection, 'ascend')
    [y_mm, sort_idx] = sort(y_mm, 'ascend');
    y_grid = y_grid(sort_idx);
else
    [y_mm, sort_idx] = sort(y_mm, 'descend');
    y_grid = y_grid(sort_idx);
end

n_slices = numel(y_mm);
if numel(col_idx) ~= n_slices
    error('Subplot count mismatch for %s (%d cols, %d slices).', ...
        experiment_id, numel(col_idx), n_slices);
end

vmr_ud = cl_load_vmr_volume(data.vmr_path, vmr_cache);

for si = 1:n_slices
    ax = subplot(n_rows, max_cols, (row_idx - 1) * max_cols + col_idx(si));
    slice_mask = data.xyz(:, 2) == y_grid(si);
    slice_xyz = data.xyz(slice_mask, :);
    n_sites = size(slice_xyz, 1);
    n_unique_sites = size(unique(slice_xyz, 'rows'), 1);
    n_trajectories = numel(unique(slice_xyz(:, 1)));
    xyz_mm = zeros(n_sites, 3);
    xyz_mm(:, 1:2) = slice_xyz(:, 1:2) * grid_spacing;
    xyz_mm(:, 3) = slice_xyz(:, 3) + data.z_offset_mm;
    panel_title = { ...
        sprintf('%s %s | y=%.1f (...,%g)', hemi, target, y_mm(si), y_grid(si)), ...
        sprintf('%s, %d sites %d unique %d traj', ...
        grid_id, n_sites, n_unique_sites, n_trajectories)};
    cl_plot_coronal_slice_ax(ax, vmr_ud, y_mm(si), xyz_mm, marker_style, ...
        plot_opts, opts.DefaultMarkerSize, panel_title);
end

end
