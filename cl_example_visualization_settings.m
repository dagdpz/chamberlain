function cfg = cl_example_visualization_settings(experiment_id)
%CL_EXAMPLE_VISUALIZATION_SETTINGS  Template — copy for a new project.
%
% Naming convention (auto-discovered from penetration db filename):
%   my_penetration_db.m              -> my_visualization_settings.m
%   cl_myproject_penetration_db.m    -> cl_myproject_visualization_settings.m
%   cl_myproject_bacchus_penetration_db.m -> cl_myproject_bacchus_visualization_settings.m
%
% Or set viz_settings = 'my_custom_viz_func' in the penetration db to override.
%
% Pulv_bodysignals example: cl_pulv_bodysignals_bacchus_visualization_settings.m

cfg = struct( ...
    'marker_style', struct( ...
        'FaceColor', [1 0 0], 'EdgeColor', 'k', ...
        'FaceAlpha', 0.5, 'EdgeAlpha', 1, 'MarkerSize', 3), ...
        'plot_opts', struct( ...
        'JitterFraction', 0.5, 'DrawTrajectory', true), ...
        'category_colors', {{[1 0 0], [0 1 0]}});

switch experiment_id
    case 'MyProject_area_L'
        cfg.plot_opts.JitterFraction = 0.75;

    case 'MyProject_area_R'
        % per-experiment overrides

    otherwise
        error('Unknown experiment_id: %s', experiment_id);
end

end
