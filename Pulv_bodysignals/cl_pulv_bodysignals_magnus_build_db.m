function report = cl_pulv_bodysignals_magnus_build_db
%CL_PULV_BODYSIGNALS_MAGNUS_BUILD_DB  Build Magnus (monkey M) penetration database.
%
% Example:
%   addpath('E:\Dropbox\Sources\Repos\chamberlain');
%   addpath('E:\Dropbox\Sources\Repos\chamberlain\Pulv_bodysignals');
%   report = cl_pulv_bodysignals_magnus_build_db;
%   cl_plot_electrode_localization('cl_pulv_bodysignals_magnus_penetration_db', ...
%       'Pulv_bodysignals_dPul_R');
%
% Set RightVmrPath / LeftVmrPath / z offsets before plotting (empty for now).

excel_path = 'Y:\Data\Sorting_tables\Magnus\Mag_sorted_neurons.xlsx';
mat_path = 'Y:\Projects\Pulv_bodysignal\LFP\ECG_Magnus_complete\Magnus_Sites.mat';
output_mfile = fullfile(fileparts(mfilename('fullpath')), ...
    'cl_pulv_bodysignals_magnus_penetration_db.m');

report = cl_create_penetration_db(excel_path, mat_path, output_mfile, ...
    'MapGroup', @pulv_bodysignals_map_group, ...
    'Groups', {'VP_L', 'dPul_L', 'dPul_R', 'MD_L'}, ...
    'GridId', 'GRID.22.3', ...
    'RightVmrPath', '', ...
    'RightZOffsetMm', NaN, ...
    'LeftVmrPath', '', ...
    'LeftZOffsetMm', NaN, ...
    'Monkey', 'Mag', ...
    'ExperimentPrefix', 'Pulv_bodysignals', ...
    'ExpectedSiteCounts', struct('VP_L', 180, 'dPul_L', 127, 'dPul_R', 311, 'MD_L', 154), ...
    'ExpectedSessionCounts', struct('VP_L', 11, 'dPul_L', 6, 'dPul_R', 17, 'MD_L', 5));
end

function group = pulv_bodysignals_map_group(target, hemisphere)
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
    case {"vpl", "above_vpl"}
        group = "VP" + suffix;
    case "dpul"
        group = "dPul" + suffix;
    case "md"
        group = "MD" + suffix;
    otherwise
        group = "";
end
end
