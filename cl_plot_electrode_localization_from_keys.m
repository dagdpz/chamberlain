function cl_plot_electrode_localization_from_keys(keys,experiment_id,co,save_voi,saggital_or_coronal, area_color, plot_opts)
% e.g.
% cl_plot_electrode_localization_from_keys(keys,'Curius_microstim_beh_electrode_localization_dorsal_direct',{'r','g','b'});
% keys must contain: vmr_path, z_offset_mm, monkey, grid_id, xyz, xyz_nojitter,
%                    penetration_date, significant

vmr_path = keys.vmr_path;
z_offset_mm = keys.z_offset_mm;
monkey_prefix = [upper(keys.monkey(1:2)) '_'];
significant = keys.significant;
xyz = keys.xyz;
xyz_nojitter = keys.xyz_nojitter;
penetration_date = keys.penetration_date;
grid_id = keys.grid_id;


if nargin < 4,
    save_voi = 0;
end
if nargin < 5,
    saggital_or_coronal='coronal';
end
if nargin < 6,
    area_color = [1 0 0];
end
if nargin < 7,
    if isfield(keys, 'plot_opts')
        plot_opts = keys.plot_opts;
    else
        plot_opts = struct();
    end
end

%cl_readout_from_tuning_table;

run('cl_grid_db'); % need for grid spacing

%% to create all vmrs
penetration_date_any=1:size(significant,1);
for k = penetration_date_any
    [x(k) y(k) z(k)] = plot_on_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm,saggital_or_coronal, area_color, plot_opts);
end

h_fig = get(0,'Children');

penetration_date_non_sig=find(~any(significant,2))';
for k = penetration_date_non_sig
    [x(k) y(k) z(k)] = plot_on_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm,saggital_or_coronal,area_color,plot_opts);
end

for f = 1:length(h_fig),
    set(0,'CurrentFigure',h_fig(f));
    UD(f) = get(h_fig(f),'UserData');
    set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker nonsignificant');
end


%% here it gets a bit more complicated, because we need to set different tags for each category
for c=1:size(significant,2)
    penetration_date_sig=find(significant(:,c))';
    for k = penetration_date_sig
        [x(k) y(k) z(k)] = plot_on_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm,saggital_or_coronal,area_color,plot_opts);
    end
    h_fig = get(0,'Children');
    for f = 1:length(h_fig),
        set(0,'CurrentFigure',h_fig(f));
        UD(f) = get(h_fig(f),'UserData');
        set(findobj(gca,'Tag','penetration marker'),'Tag',['penetration marker ' num2str(c)]);
    end
end

if save_voi && exist([vmr_path(1:end-4) '.voi'],'file'), % save voi
    voi = xff([vmr_path(1:end-4) '.voi']); % should be empty voi
    if voi.Convention == 1, % radiological
        % x coordinates from cl_plot_coronal_slice come as neurological, flip, e.g. 129->127: 128 - (129-128)
        x = fix(voi.OriginalVMRFramingCubeDim/2) - (x - fix(voi.OriginalVMRFramingCubeDim/2));
    end
    % voi coordinates order: y z x
    voi.NrOfVOIs = k;
    for i = 1:k,
        voi.VOI(i).Name = [monkey_prefix penetration_date{i}];
        voi.VOI(i).Color = [255 0 0];
        voi.VOI(i).Voxels = sortrows(ne_voi_sphere_around_voxel([y(i) z(i) x(i)],2),-3);
        % voi.VOI(i).Voxels = [y(i) z(i) x(i)];
        voi.VOI(i).NrOfVoxels = length(voi.VOI(i).Voxels);
    end
    voi.SaveAs([vmr_path(1:end-4) '_' experiment_id '.voi']);
end



for f = 1:length(h_fig),
    set(0,'CurrentFigure',h_fig(f));
    set(findobj(gca,'Tag','penetration marker nonsignificant'),'Tag','penetration marker nonsignificant');
    cl_apply_marker_style(findobj(gca,'Tag','penetration marker nonsignificant'), ...
        struct('FaceColor','w','EdgeColor','w','FaceAlpha',1,'EdgeAlpha',1), 3);
end
for f = 1:length(h_fig),
    set(0,'CurrentFigure',h_fig(f));
    switch saggital_or_coronal
        case 'coronal'
            y_mm = UD(f).y_mm;
            this_slice_sites_idx = find(xyz(:,2)*grid_spacing==y_mm);
            slice_coord_idx = 2;
        case 'sagittal'
            x_mm = UD(f).x_mm;
            this_slice_sites_idx = find(xyz(:,1)*grid_spacing==x_mm);
            slice_coord_idx = 1;
    end

    if isempty(this_slice_sites_idx),
        continue;
    end
    
    n_unique_sites_this_slice = size(unique(xyz(this_slice_sites_idx,:),'rows'),1);
    
    old_str = get(get(gca,'Title'),'String');
    gridhole_coord = xyz(this_slice_sites_idx(1), slice_coord_idx);
    title({char(old_str),sprintf('%s, %s (...,%s), %d sites %d unique sites',experiment_id,grid_id,num2str(gridhole_coord),length(this_slice_sites_idx),n_unique_sites_this_slice)},'Interpreter','none');
    
    for c=1:size(significant,2)
        hn = findobj(gca,'Tag','penetration marker nonsignificant');
        hs = findobj(gca,'Tag',['penetration marker ' num2str(c)]);
        for obj = hs
            cl_apply_marker_style(obj, co{c}, 3);
        end
        set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker set');
        
        for obj = hn
            cl_apply_marker_style(obj, struct('FaceColor','w','EdgeColor','w','FaceAlpha',1,'EdgeAlpha',1), 3);
        end
    end
end
end

function [x y z] = plot_on_slice(vmr_path,xyz,z_offset_mm,saggital_or_coronal, marker_color, plot_opts)
if nargin < 6
    plot_opts = struct();
end
switch saggital_or_coronal
    case 'coronal'
        [x y z] = cl_plot_coronal_slice_smaller(vmr_path,xyz,z_offset_mm, marker_color, plot_opts);
    case 'sagittal'
        [x y z] = cl_plot_sagittal_slice_smaller(vmr_path,xyz,z_offset_mm, marker_color, plot_opts);
end
end
