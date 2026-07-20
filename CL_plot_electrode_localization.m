function cl_plot_electrode_localization(db_file,experiment_id,varargin)
% e.g.
% cl_plot_electrode_localization('Curius_microstim_beh_electrode_localization_mat','Curius_microstim_beh_electrode_localization_dorsal_direct','r');
% cl_plot_electrode_localization(db_file, experiment_id);  % uses *_visualization_settings.m
% cl_plot_electrode_localization(db_file, experiment_id, struct('FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5));
% cl_plot_electrode_localization(db_file, experiment_id, 'r', 0, struct('JitterFraction',0.5,'DrawTrajectory',true));
% cl_plot_electrode_localization(db_file, experiment_id, 'r', 0, 'JitterFraction',0.5,'DrawTrajectory',true,'zoom',2);
% db_file should contain one or more experiment_id
% db_file should contain grid_id
% db_file should contain vmr_path
% db_file should contain z_offset_mm: distance from chamber top (or grid top) to "brain entry"
% db_file should contain monkey_prefix

save_voi = 0;
plot_start = cl_plot_opts_start(varargin{:});
positional = varargin(1:plot_start - 1);
plot_args = varargin(plot_start:end);

run(db_file);

viz_func = '';
if exist('viz_settings', 'var') && ischar(viz_settings) && ~isempty(viz_settings)
    viz_func = viz_settings;
end
cfg = cl_load_visualization_settings(db_file, experiment_id, viz_func);

if isfield(cfg, 'marker_style')
    penetration_marker_style = cfg.marker_style;
else
    penetration_marker_style = 'r';
end
if isfield(cfg, 'plot_opts')
    plot_opts = cfg.plot_opts;
else
    plot_opts = struct();
end

if numel(positional) >= 1
    penetration_marker_style = positional{1};
end
if numel(positional) >= 2
    save_voi = positional{2};
end
if ~isempty(plot_args)
    plot_opts = cl_merge_plot_opts(plot_opts, plot_args{:});
end

parsed_marker = cl_parse_marker_style(penetration_marker_style, 5);

run('cl_grid_db'); % need for grid spacing

for k = 1:length(penetration_date),
    [x(k) y(k) z(k)] = cl_plot_coronal_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm,penetration_marker_style,plot_opts);
end

if save_voi,
    voi = xff('new:voi');
    voi.FileVersion = 4;
    voi.ReferenceSpace = 'ACPC';
    voi.Convention = 2;

    % voi coordinates order: y z x
    voi.NrOfVOIs = k;
    for i = 1:k,
        voi.VOI(i).Name = [monkey_prefix penetration_date{i}];
        voi.VOI(i).Color = [255 0 0];
        voi.VOI(i).Voxels = sortrows(ne_voi_sphere_around_voxel([y(i) z(i) x(i)],2),-3);
        voi.VOI(i).NrOfVoxels = length(voi.VOI(i).Voxels);
    end

    voi.SaveAs([vmr_path(1:end-4) '_' experiment_id '.voi']);
    disp([vmr_path(1:end-4) '_' experiment_id '.voi saved.']);
    ne_voicoord2tal([vmr_path(1:end-4) '_' experiment_id '.voi']);
end

h_fig = get(0,'Children');

for f = 1:length(h_fig),
    set(0,'CurrentFigure',h_fig(f));
    UD = get(h_fig(f),'UserData');
    y_mm = UD.y_mm;

    this_slice_sites_idx = find(xyz(:,2)*grid_spacing==y_mm);
    if isempty(this_slice_sites_idx),
        continue;
    end
    n_unique_sites_this_slice = size(unique(xyz(this_slice_sites_idx,:),'rows'),1);

    old_str = get(get(gca,'Title'),'String');
    title({char(old_str),sprintf('%s, %s (...,%d), %d sites %d unique sites',experiment_id,grid_id,xyz(this_slice_sites_idx(1),2),length(this_slice_sites_idx),n_unique_sites_this_slice)},'Interpreter','none');

    cl_apply_marker_style(findobj(gca,'Tag','penetration marker'), penetration_marker_style, parsed_marker.MarkerSize);
    set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker set');
end
