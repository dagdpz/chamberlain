function cfg = cl_load_visualization_settings(db_file, experiment_id, viz_settings_func)
%CL_LOAD_VISUALIZATION_SETTINGS  Load per-project plot cfg for an experiment_id.
%
%   cfg = cl_load_visualization_settings(db_file, experiment_id)
%   cfg = cl_load_visualization_settings(db_file, experiment_id, viz_func)
%
% Lookup order:
%   1. viz_settings_func when provided (non-empty function name)
%   2. Convention from db filename:
%      cl_myproject_bacchus_penetration_db -> cl_myproject_bacchus_visualization_settings
%      my_penetration_db                     -> my_visualization_settings
%
% Returns struct with optional fields: marker_style, plot_opts (JitterFraction,
% DrawTrajectory, Zoom), category_colors.
% Missing file or unknown experiment_id in settings function -> empty fields.

if nargin < 3
    viz_settings_func = '';
end

if isempty(viz_settings_func)
    [~, base, ~] = fileparts(db_file);
    viz_settings_func = regexprep(base, '_penetration_db$', '_visualization_settings');
end

if isempty(viz_settings_func) || ~settings_file_exists(viz_settings_func, db_file)
    cfg = struct();
    return;
end

cfg = feval(viz_settings_func, experiment_id);

end

function found = settings_file_exists(func_name, db_file)
found = exist(func_name, 'file') == 2;
if found
    return;
end
db_dir = fileparts(db_file);
if isempty(db_dir)
    return;
end
found = exist(fullfile(db_dir, [func_name '.m']), 'file') == 2;
if found
    addpath(db_dir);
end
end
