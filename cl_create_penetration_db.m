function report = cl_create_penetration_db(excel_path, mat_path, output_mfile, varargin)
%CL_CREATE_PENETRATION_DB  Build a cl_chamberlain penetration database from Excel + MAT.
%
% Example (generic template — replace paths in cl_example_create_penetration_db.m):
%   report = cl_example_create_penetration_db;
%
% Example (Pulv_bodysignals Bacchus):
%   report = cl_pulv_bodysignals_bacchus_build_db;
%   cl_plot_electrode_localization('Pulv_bodysignals/cl_pulv_bodysignals_bacchus_penetration_db', ...
%       'Pulv_bodysignals_dPul_R', 'r');
%
%   Reads a neuron-sorting Excel table and a MAT file with site IDs, keeps
%   sites present in both sources, maps each row to a group label via
%   MapGroup, and writes a penetration_db-style .m file.
%
%   Template function: cl_example_create_penetration_db.m
%
%   Required inputs
%   ---------------
%   excel_path    Path to sorting table (.xlsx)
%   mat_path      Path to MAT file listing included site IDs
%   output_mfile  Path for generated database .m file
%
%   Name-value pairs
%   ----------------
%   MapGroup             Function handle (target, hemisphere) -> group string (required)
%   Groups               Cell array of groups to export (default: all mapped groups)
%   GridId               Chamber grid ID for cl_grid_db.m (default 'GRID.22.2')
%   VmrPath              Single VMR for all cases (default ''; ignored if chamber paths set)
%   ZOffsetMm            Single z offset for all cases (default NaN)
%   RightVmrPath         Right-chamber VMR (groups ending in _R)
%   RightZOffsetMm       Right-chamber grid-top to brain-entry offset (mm)
%   LeftVmrPath          Left-chamber VMR (groups ending in _L)
%   LeftZOffsetMm        Left-chamber grid-top to brain-entry offset (mm)
%   Monkey               Monkey name/prefix in db (default 'Mon')
%   ExperimentPrefix     experiment_id prefix (default 'Experiment')
%   ExcelSheet           Excel sheet name (default 'final_sorting')
%   MatSiteVar           Variable name in MAT file (default 'site_IDs')
%   DepthColumn          Excel column for penetration depth (default 'Aimed_electrode_depth')
%   ExpectedSiteCounts   Optional struct of expected site counts per group (warnings only)
%   ExpectedSessionCounts Optional struct of expected session counts per group (warnings only)

p = inputParser;
p.addRequired('excel_path', @(s) ischar(s) || isstring(s));
p.addRequired('mat_path', @(s) ischar(s) || isstring(s));
p.addRequired('output_mfile', @(s) ischar(s) || isstring(s));
p.addParameter('MapGroup', [], @(f) isa(f, 'function_handle'));
p.addParameter('Groups', {}, @(c) iscell(c) && (isempty(c) || all(cellfun(@(s) ischar(s) || isstring(s), c))));
p.addParameter('GridId', 'GRID.22.2', @(s) ischar(s) || isstring(s));
p.addParameter('VmrPath', '', @(s) ischar(s) || isstring(s));
p.addParameter('ZOffsetMm', NaN, @(x) isnumeric(x) && isscalar(x));
p.addParameter('RightVmrPath', '', @(s) ischar(s) || isstring(s));
p.addParameter('RightZOffsetMm', NaN, @(x) isnumeric(x) && isscalar(x));
p.addParameter('LeftVmrPath', '', @(s) ischar(s) || isstring(s));
p.addParameter('LeftZOffsetMm', NaN, @(x) isnumeric(x) && isscalar(x));
p.addParameter('Monkey', 'Mon', @(s) ischar(s) || isstring(s));
p.addParameter('ExperimentPrefix', 'Experiment', @(s) ischar(s) || isstring(s));
p.addParameter('ExcelSheet', 'final_sorting', @(s) ischar(s) || isstring(s));
p.addParameter('MatSiteVar', 'site_IDs', @(s) ischar(s) || isstring(s));
p.addParameter('DepthColumn', 'Aimed_electrode_depth', @(s) ischar(s) || isstring(s));
p.addParameter('ExpectedSiteCounts', struct(), @isstruct);
p.addParameter('ExpectedSessionCounts', struct(), @isstruct);
p.parse(excel_path, mat_path, output_mfile, varargin{:});

if isempty(p.Results.MapGroup)
    error('cl_create_penetration_db:MissingMapGroup', ...
        'MapGroup function handle is required. See cl_example_create_penetration_db.m.');
end

excel_path = char(p.Results.excel_path);
mat_path = char(p.Results.mat_path);
output_mfile = char(p.Results.output_mfile);
map_group = p.Results.MapGroup;
groups = cellfun(@char, p.Results.Groups, 'UniformOutput', false);
grid_id = char(p.Results.GridId);
vmr_path = char(p.Results.VmrPath);
z_offset_mm = p.Results.ZOffsetMm;
right_vmr_path = char(p.Results.RightVmrPath);
right_z_offset_mm = p.Results.RightZOffsetMm;
left_vmr_path = char(p.Results.LeftVmrPath);
left_z_offset_mm = p.Results.LeftZOffsetMm;
use_chamber_paths = cl_chamber_paths_requested(varargin);
monkey = char(p.Results.Monkey);
experiment_prefix = char(p.Results.ExperimentPrefix);
excel_sheet = char(p.Results.ExcelSheet);
mat_site_var = char(p.Results.MatSiteVar);
depth_column = char(p.Results.DepthColumn);
expected_site_counts = p.Results.ExpectedSiteCounts;
expected_session_counts = p.Results.ExpectedSessionCounts;

mat_data = load(mat_path);
if ~isfield(mat_data, mat_site_var)
    error('cl_create_penetration_db:MissingMatVar', ...
        'MAT file %s does not contain variable ''%s''.', mat_path, mat_site_var);
end
mat_site_ids = normalize_site_ids(mat_data.(mat_site_var));

tbl = readtable(excel_path, 'Sheet', excel_sheet, 'TextType', 'string');
required_cols = {'Site_ID','Target','Hemisphere','x','y',depth_column};
missing_cols = setdiff(required_cols, tbl.Properties.VariableNames);
if ~isempty(missing_cols)
    error('cl_create_penetration_db:MissingColumns', ...
        'Excel sheet is missing columns: %s', strjoin(missing_cols, ', '));
end

tbl.Site_ID = string(tbl.Site_ID);
tbl.Target = string(tbl.Target);
tbl.Hemisphere = string(tbl.Hemisphere);
tbl = tbl(ismember(tbl.Site_ID, mat_site_ids), :);
if isempty(tbl)
    error('cl_create_penetration_db:NoOverlap', ...
        'No Excel rows match site IDs from %s.', mat_path);
end

[~, first_idx] = unique(tbl.Site_ID, 'stable');
sites = tbl(first_idx, :);
sites.Group = strings(height(sites), 1);
for i = 1:height(sites)
    sites.Group(i) = string(map_group(sites.Target(i), sites.Hemisphere(i)));
end
sites = sites(sites.Group ~= "", :);
if isempty(groups)
    groups = cellstr(unique(sites.Group, 'stable'));
end
sites = sites(ismember(sites.Group, string(groups)), :);
sites = sortrows(sites, {'Group', 'Site_ID'});

if isempty(sites)
    error('cl_create_penetration_db:NoSites', ...
        'No sites left after group filtering.');
end

report = struct();
report.monkey = monkey;
report.groups = groups;
report.site_counts = struct();
report.session_counts = struct();

for i = 1:numel(groups)
    grp = groups{i};
    grp_rows = sites(sites.Group == string(grp), :);
    fld = matlab.lang.makeValidName(grp);
    report.site_counts.(fld) = height(grp_rows);
    report.session_counts.(fld) = ...
        numel(unique(penetration_date_from_site_id(grp_rows.Site_ID)));
    if isfield(expected_site_counts, fld) && ...
            report.site_counts.(fld) ~= expected_site_counts.(fld)
        warning('cl_create_penetration_db:SiteCountMismatch', ...
            '%s: expected %d sites, found %d.', grp, ...
            expected_site_counts.(fld), report.site_counts.(fld));
    end
    if isfield(expected_session_counts, fld) && ...
            report.session_counts.(fld) ~= expected_session_counts.(fld)
        warning('cl_create_penetration_db:SessionCountMismatch', ...
            '%s: expected %d sessions, found %d.', grp, ...
            expected_session_counts.(fld), report.session_counts.(fld));
    end
end

write_penetration_db_file(output_mfile, sites, struct( ...
    'grid_id', grid_id, ...
    'vmr_path', vmr_path, ...
    'z_offset_mm', z_offset_mm, ...
    'right_vmr_path', right_vmr_path, ...
    'right_z_offset_mm', right_z_offset_mm, ...
    'left_vmr_path', left_vmr_path, ...
    'left_z_offset_mm', left_z_offset_mm, ...
    'use_chamber_paths', use_chamber_paths, ...
    'monkey', monkey, ...
    'experiment_prefix', experiment_prefix, ...
    'excel_path', excel_path, ...
    'mat_path', mat_path, ...
    'depth_column', depth_column));

fprintf('Wrote %s (%d sites).\n', output_mfile, height(sites));
for i = 1:numel(groups)
    grp = groups{i};
    fld = matlab.lang.makeValidName(grp);
    fprintf('  %s: %d sessions, %d sites\n', grp, ...
        report.session_counts.(fld), report.site_counts.(fld));
end
end

function ids = normalize_site_ids(raw_ids)
if iscell(raw_ids)
    ids = string(raw_ids(:));
elseif isstring(raw_ids)
    ids = raw_ids(:);
else
    ids = string(raw_ids(:));
end
ids = strip(ids);
end

function dates = penetration_date_from_site_id(site_ids)
site_ids = string(site_ids);
dates = strings(size(site_ids));
for i = 1:numel(site_ids)
    tok = regexp(site_ids(i), '_(\d{8})_Site_', 'tokens', 'once');
    if ~isempty(tok)
        dates(i) = tok{1};
    else
        dates(i) = "";
    end
end
end

function write_penetration_db_file(output_mfile, sites, meta)
[fid, msg] = fopen(output_mfile, 'w');
if fid < 0
    error('cl_create_penetration_db:WriteFailed', 'Could not open %s: %s', output_mfile, msg);
end
cleanup = onCleanup(@() fclose(fid));

fprintf(fid, '%% %s penetration database for %s\n', meta.experiment_prefix, meta.monkey);
fprintf(fid, '%% Generated by cl_create_penetration_db on %s\n', datestr(now, 31));
fprintf(fid, '%% Source Excel: %s\n', meta.excel_path);
fprintf(fid, '%% Source MAT:   %s\n', meta.mat_path);
fprintf(fid, '%% xyz(:,1:2): grid hole x/y; xyz(:,3): depth (mm, negative from chamber top)\n\n');

fprintf(fid, 'monkey = ''%s'';\n', meta.monkey);
fprintf(fid, 'monkey_prefix = ''%s_'';\n', upper(meta.monkey(1:min(2, numel(meta.monkey)))));
fprintf(fid, 'grid_id = ''%s'';\n', meta.grid_id);
if meta.use_chamber_paths
    fprintf(fid, 'right_vmr_path = ''%s'';\n', meta.right_vmr_path);
    write_z_offset_line(fid, 'right_z_offset_mm', meta.right_z_offset_mm);
    fprintf(fid, 'left_vmr_path = ''%s'';\n', meta.left_vmr_path);
    write_z_offset_line(fid, 'left_z_offset_mm', meta.left_z_offset_mm);
else
    fprintf(fid, 'vmr_path = ''%s'';\n', meta.vmr_path);
    if isnan(meta.z_offset_mm)
        fprintf(fid, 'z_offset_mm = NaN; %% set before plotting\n');
    else
        fprintf(fid, 'z_offset_mm = %g;\n', meta.z_offset_mm);
    end
end
fprintf(fid, '\nn = 1;\n');
fprintf(fid, 'switch experiment_id\n');

groups = unique(sites.Group, 'stable');
for n = 1:numel(groups)
    grp = groups(n);
    case_id = sprintf('%s_%s', meta.experiment_prefix, grp);
    grp_rows = sites(sites.Group == grp, :);
    fprintf(fid, '\n\tcase ''%s''\n', case_id);
    if meta.use_chamber_paths
        if endsWith(char(grp), '_R')
            fprintf(fid, '\t\tvmr_path = right_vmr_path;\n');
            fprintf(fid, '\t\tz_offset_mm = right_z_offset_mm;\n');
        else
            fprintf(fid, '\t\tvmr_path = left_vmr_path;\n');
            fprintf(fid, '\t\tz_offset_mm = left_z_offset_mm;\n');
        end
    end
    for i = 1:height(grp_rows)
        row = grp_rows(i, :);
        pdate = penetration_date_from_site_id(row.Site_ID);
        if pdate == ""
            pdate = char(row.Site_ID);
        end
        depth = -row.(meta.depth_column);
        if isnan(depth)
            error('cl_create_penetration_db:MissingDepth', ...
                'Site %s has no %s.', row.Site_ID, meta.depth_column);
        end
        note = sprintf('%s | %s %s', row.Site_ID, row.Target, row.Hemisphere);
        fprintf(fid, ...
            ['\t\tpenetration_date{n} = ''%s''; ' ...
             'xyz(n,:) = [%g %g %g]; ' ...
             'target{n} = ''%s''; ' ...
             'notes{n} = ''%s''; n = n+1;\n'], ...
            pdate, row.x, row.y, depth, grp, note);
    end
end

fprintf(fid, '\n\totherwise\n');
fprintf(fid, '\t\terror(''Unknown experiment_id: %%s'', experiment_id);\n');
fprintf(fid, 'end\n');
end

function write_z_offset_line(fid, var_name, z_offset_mm)
if isnan(z_offset_mm)
    fprintf(fid, '%s = NaN; %% set before plotting\n', var_name);
else
    fprintf(fid, '%s = %g;\n', var_name, z_offset_mm);
end
end

function tf = cl_chamber_paths_requested(args)
tf = false;
for i = 1:2:numel(args) - 1
    name = args{i};
    if ~(ischar(name) || isstring(name))
        continue;
    end
    switch lower(char(name))
        case {'rightvmrpath', 'leftvmrpath', 'rightzoffsetmm', 'leftzoffsetmm'}
            tf = true;
            return;
    end
end
end
