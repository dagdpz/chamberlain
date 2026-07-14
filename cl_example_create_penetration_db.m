function report = cl_example_create_penetration_db
%CL_EXAMPLE_CREATE_PENETRATION_DB  Generic template — copy this file for a new project.
%
% Example (replace paths, then run):
%   addpath('E:\Dropbox\Sources\Repos\chamberlain');
%   report = cl_example_create_penetration_db;
%
% Full real-world example (Pulv_bodysignals, monkey Bacchus):
%   addpath('E:\Dropbox\Sources\Repos\chamberlain');
%   report = cl_pulv_bodysignals_bacchus_build_db;
%   cl_plot_electrode_localization('Pulv_bodysignals/cl_pulv_bodysignals_bacchus_penetration_db', ...
%       'Pulv_bodysignals_dPul_R');
%
% Plot settings: Pulv_bodysignals/cl_pulv_bodysignals_bacchus_visualization_settings.m
% Template: cl_example_visualization_settings.m

excel_path = 'path/to/sorting_table.xlsx';
mat_path = 'path/to/site_list.mat';
output_mfile = fullfile(pwd, 'my_penetration_db.m');

report = cl_create_penetration_db(excel_path, mat_path, output_mfile, ...
    'MapGroup', @example_map_group, ...
    'Groups', {'area_L', 'area_R'}, ...
    'GridId', 'GRID.22.2', ...
    'Monkey', 'Mon', ...
    'ExperimentPrefix', 'MyProject', ...
    'ExcelSheet', 'final_sorting', ...
    'MatSiteVar', 'site_IDs', ...
    'DepthColumn', 'Aimed_electrode_depth', ...
    'VmrPath', 'path/to/chamber.vmr', ...
    'ZOffsetMm', 0);
end

function group = example_map_group(target, hemisphere)
target = lower(strip(string(target)));
hemisphere = lower(strip(string(hemisphere)));
if startsWith(hemisphere, 'r')
    suffix = "_R";
elseif startsWith(hemisphere, 'l')
    suffix = "_L";
else
    group = "";
    return;
end
switch target
    case 'my_area'
        group = "area" + suffix;
    otherwise
        group = "";
end
end
