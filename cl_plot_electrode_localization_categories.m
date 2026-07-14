function cl_plot_electrode_localization_categories(db_file,experiment_id,co,save_voi,plot_opts)
% Multi-category significance coloring; trajectories via plot_opts.DrawTrajectory.
% cl_plot_electrode_localization_categories(db_file, experiment_id);  % uses *_visualization_settings.m
% co: cell of colors per significance column; defaults to cfg.category_colors

if nargin < 4,
	save_voi = 0;
end

run(db_file);

viz_func = '';
if exist('viz_settings', 'var') && ischar(viz_settings) && ~isempty(viz_settings)
    viz_func = viz_settings;
end
cfg = cl_load_visualization_settings(db_file, experiment_id, viz_func);

if nargin < 3,
    if isfield(cfg, 'category_colors')
        co = cfg.category_colors;
    else
        co = {[1 0 0]};
    end
end
if nargin < 5,
    if isfield(cfg, 'plot_opts')
        plot_opts = cfg.plot_opts;
    else
        plot_opts = struct('DrawTrajectory', true);
    end
end

run('cl_grid_db'); % need for grid spacing

penetration_date_any=1:size(significant,1);
for k = penetration_date_any
    [x(k) y(k) z(k)] = cl_plot_coronal_slice_smaller(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm, [1 0 0], plot_opts);
end

h_fig = get(0,'Children');

penetration_date_non_sig=find(~any(significant,2))';
for k = penetration_date_non_sig
	[x(k) y(k) z(k)] = cl_plot_coronal_slice_smaller(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm, [1 0 0], plot_opts);
end

for f = 1:length(h_fig),
	set(0,'CurrentFigure',h_fig(f));
 	set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker nonsignificant');
end

for c=1:size(significant,2)
    penetration_date_sig=find(significant(:,c))';
    for k = penetration_date_sig
        [x(k) y(k) z(k)] = cl_plot_coronal_slice_smaller(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm, co{c}, plot_opts);
    end

    h_fig = get(0,'Children');
    for f = 1:length(h_fig),
        set(0,'CurrentFigure',h_fig(f));
        set(findobj(gca,'Tag','penetration marker'),'Tag',['penetration marker ' num2str(c)]);
    end
end

if save_voi && exist([vmr_path(1:end-4) '.voi'],'file'),
	voi = xff([vmr_path(1:end-4) '.voi']);

	if voi.Convention == 1,
		x = fix(voi.OriginalVMRFramingCubeDim/2) - (x - fix(voi.OriginalVMRFramingCubeDim/2));
	end

	voi.NrOfVOIs = k;
	for i = 1:k,
		voi.VOI(i).Name = [monkey_prefix penetration_date{i}];
		voi.VOI(i).Color = [255 0 0];
		voi.VOI(i).Voxels = sortrows(ne_voi_sphere_around_voxel([y(i) z(i) x(i)],2),-3);
		voi.VOI(i).NrOfVoxels = length(voi.VOI(i).Voxels);
	end

	voi.SaveAs([vmr_path(1:end-4) '_' experiment_id '.voi']);
end

white_style = struct('FaceColor','w','EdgeColor','w','FaceAlpha',1,'EdgeAlpha',1);
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

    for c=1:size(significant,2)
        hn = findobj(gca,'Tag','penetration marker nonsignificant');
        hs = findobj(gca,'Tag',['penetration marker ' num2str(c)]);

        for obj = hs
            cl_apply_marker_style(obj, co{c}, 3);
        end
        set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker set');

        for obj = hn
            cl_apply_marker_style(obj, white_style, 3);
        end
    end
end
