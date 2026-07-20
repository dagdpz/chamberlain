function report = cl_pulv_bodysignals_bacchus_build_db
%CL_PULV_BODYSIGNALS_BACCHUS_BUILD_DB  Build Bacchus (monkey B) penetration database.
%
% Example:
%   addpath('E:\Dropbox\Sources\Repos\chamberlain');
%   report = cl_pulv_bodysignals_bacchus_build_db;
%   cl_plot_electrode_localization('Pulv_bodysignals/cl_pulv_bodysignals_bacchus_penetration_db', ...
%       'Pulv_bodysignals_dPul_R');

excel_path = 'Y:\Data\Sorting_tables\Bacchus\Bac_sorted_neurons.xlsx';
mat_path = 'Y:\Projects\Pulv_bodysignal\LFP\ECG_Bacchus_complete\Bacchus_Sites.mat';
output_mfile = fullfile(fileparts(mfilename('fullpath')), ...
    'cl_pulv_bodysignals_bacchus_penetration_db.m');

report = cl_create_penetration_db(excel_path, mat_path, output_mfile, ...
    'MapGroup', @pulv_bodysignals_map_group, ...
    'Groups', {'VP_R', 'dPul_L', 'dPul_R', 'MD_L', 'MD_R'}, ...
    'GridId', 'GRID.22.3', ...
    'RightVmrPath', 'Y:\MRI\Bacchus\20220215_anatomy_electrode_rVPL\dicom\0101\BA_20220218_chamber_R_normal.vmr', ...
    'RightZOffsetMm', 23.5, ... % from grid top to brain entry (image center) - depth is relative to grid top
    'LeftVmrPath', 'Y:\MRI\Bacchus\20220201_anatomy_electrode_rightMD_leftDPul\dicom\0103\BA_20220201_chamber_L_normal.vmr', ...
    'LeftZOffsetMm', 21, ... % from grid top to brain entry (image center) - depth is relative to grid top
    'Monkey', 'Bac', ...
    'ExperimentPrefix', 'Pulv_bodysignals', ...
    'ExpectedSiteCounts', struct('VP_R', 18, 'dPul_L', 116, 'dPul_R', 28, 'MD_L', 6, 'MD_R', 56), ...
    'ExpectedSessionCounts', struct('VP_R', 6, 'dPul_L', 22, 'dPul_R', 8, 'MD_L', 1, 'MD_R', 9));
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
