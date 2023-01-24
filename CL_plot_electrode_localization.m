function CL_plot_electrode_localization(keys,experiment_id,co,save_voi,saggital_or_coronal)
% e.g.
% plot_electrode_localization('Curius_microstim_beh_electrode_localization_mat','Curius_microstim_beh_electrode_localization_dorsal_direct','r');
% plot_electrode_localization('Linus_microstim_beh_electrode_localization_mat','Linus_microstim_beh_electrode_localization_dorsal_direct','r');

% db_file should contain one or more experiment_id
% db_file should contain grid_id
% db_file should contain vmr_path
% db_file should contain z_offset_mm: distance from chamber top to "brain entry"

vmr_path = keys.vmr_path;
z_offset_mm = keys.z_offset_mm;
monkey_prefix = [upper(keys.monkey(1:2)) '_'];
%target_area = keys.target_area;
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

%CL_readout_from_tuning_table;

run('grid_db'); % need for grid spacing

%% to create all vmrs
penetration_date_any=1:size(significant,1);
for k = penetration_date_any
    [x(k) y(k) z(k)] = plot_on_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm,saggital_or_coronal);
end

%% annoying part to plot electrode tracks
xyz_nojitter(:,3) = xyz_nojitter(:,3) + z_offset_mm;
xyz_identifier=xyz;
xyz_identifier(:,3) = xyz(:,3) + z_offset_mm;

h_fig = get(0,'Children');
for f = 1:length(h_fig),
    set(0,'CurrentFigure',h_fig(f));
    UD = get(h_fig(f),'UserData');
    current_handles=findobj(gca,'Tag','penetration marker');
    xz_current_slice=cell2mat([get(current_handles, 'XData') get(current_handles, 'YData')]);
    grid_z= (xz_current_slice(:,2) - fix(UD.voxel_dim/2))*UD.voxel_size*-1;
    switch saggital_or_coronal
        case 'coronal'
            grid_x= (xz_current_slice(:,1) - fix(UD.voxel_dim/2))*UD.voxel_size/grid_spacing;
            grid_y=repmat(UD.y_mm/grid_spacing,size(grid_x));
        case 'sagittal'
            grid_y= (xz_current_slice(:,1) - fix(UD.voxel_dim/2))*UD.voxel_size/grid_spacing;
            grid_x=repmat(UD.x_mm/grid_spacing,size(grid_y));
    end
    current_locations=ismember(round(xyz_identifier*1000),round([grid_x grid_y grid_z]*1000),'rows');
    unique_electrode_positions=unique(xyz_nojitter(current_locations,1))*grid_spacing/UD.voxel_size + fix(UD.voxel_dim/2);
    for p=unique_electrode_positions'
        line([p p],[0 UD.voxel_dim],'color','w','linestyle',':');
    end
    %delete(current_handles);
end

penetration_date_non_sig=find(~any(significant,2))';
for k = penetration_date_non_sig
    %[x(k) y(k) z(k)] = plot_coronal_slice_smaller(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm);
    [x(k) y(k) z(k)] = plot_on_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm,saggital_or_coronal);
end

for f = 1:length(h_fig),
    set(0,'CurrentFigure',h_fig(f));
    UD = get(h_fig(f),'UserData');
    set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker nonsignificant');
end


%% here it gets a bit more complicated, because we need to set different tags for each category
for c=1:size(significant,2)
    penetration_date_sig=find(significant(:,c))';
    for k = penetration_date_sig
        [x(k) y(k) z(k)] = plot_on_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm,saggital_or_coronal);
    end
    h_fig = get(0,'Children');
    for f = 1:length(h_fig),
        set(0,'CurrentFigure',h_fig(f));
        UD = get(h_fig(f),'UserData');
        set(findobj(gca,'Tag','penetration marker'),'Tag',['penetration marker ' num2str(c)]);
    end
end

if save_voi && exist([vmr_path(1:end-4) '.voi'],'file'), % save voi
    voi = xff([vmr_path(1:end-4) '.voi']); % should be empty voi
    if voi.Convention == 1, % radiological
        % x coordinates from plot_coronal_slice come as neurological, flip, e.g. 129->127: 128 - (129-128)
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
    set(findobj(gca,'Tag','penetration marker nonsignificant'),'Color','w');
    %      ha = findobj(gca,'Tag','penetration marker');
    %      recolor_markers(co{f},ha);
    %	set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker set');
end
for f = 1:length(h_fig),
    set(0,'CurrentFigure',h_fig(f));
    switch saggital_or_coronal
        case 'coronal'
            y_mm = UD.y_mm;
            this_slice_sites_idx = find(xyz(:,2)*grid_spacing==y_mm);
        case 'sagittal'
            x_mm = UD.x_mm;
            this_slice_sites_idx = find(xyz(:,1)*grid_spacing==x_mm);
    end
    
    n_unique_sites_this_slice = size(unique(xyz(this_slice_sites_idx,:),'rows'),1);
    
    old_str = get(get(gca,'Title'),'String');
    title({char(old_str),sprintf('%s, %s (...,%d), %d sites %d unique sites',experiment_id,grid_id,xyz(this_slice_sites_idx(1),2),length(this_slice_sites_idx),n_unique_sites_this_slice)},'Interpreter','none');
    
    % 	set(findobj(gca,'Tag','penetration marker'),'Color',penetration_marker_color);
    for c=1:size(significant,2)
        hn = findobj(gca,'Tag','penetration marker nonsignificant');
        hs = findobj(gca,'Tag',['penetration marker ' num2str(c)]);
        for obj = hs
            set(obj,'Color',co{c});
        end
        set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker set');
        
        for obj = hn
            set(obj,'Color','w');
        end
    end
end
end

function [x y z] = plot_on_slice(vmr_path,xyz,z_offset_mm,saggital_or_coronal)
switch saggital_or_coronal
    case 'coronal'
        [x y z] = plot_coronal_slice_smaller(vmr_path,xyz,z_offset_mm);
    case 'sagittal'
        [x y z] = plot_sagittal_slice(vmr_path,xyz,z_offset_mm);
end
end
