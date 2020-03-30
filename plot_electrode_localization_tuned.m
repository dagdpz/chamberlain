function plot_electrode_localization_tuned(db_file,experiment_id,penetration_marker_color,save_voi) 
% e.g. 
% plot_electrode_localization('Curius_microstim_beh_electrode_localization_mat','Curius_microstim_beh_electrode_localization_dorsal_direct','r');
% plot_electrode_localization('Linus_microstim_beh_electrode_localization_mat','Linus_microstim_beh_electrode_localization_dorsal_direct','r');

% db_file should contain one or more experiment_id
% db_file should contain grid_id
% db_file should contain vmr_path
% db_file should contain z_offset_mm: distance from chamber top to "brain entry"

if nargin < 3,
	penetration_marker_color = 'r';
end

if nargin < 4,
	save_voi = 0;
end

run(db_file); 

run('grid_db'); % need for grid spacing


penetration_date_non_sig=find(~significant)';
for k = penetration_date_non_sig
	[x(k) y(k) z(k)] = plot_coronal_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm);
end

h_fig = get(0,'Children');
for f = 1:length(h_fig),
	set(0,'CurrentFigure',h_fig(f));
	UD = get(h_fig(f),'UserData');
 	set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker nonsignificant');
end

penetration_date_sig=find(significant)';
for k = penetration_date_sig
	[x(k) y(k) z(k)] = plot_coronal_slice(vmr_path,[xyz(k,1:2)*grid_spacing xyz(k,3)],z_offset_mm);
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


switch monkey
    case 'Cur';
        co = {'g','r'}; %curius 3,5 5,3
    case 'Lin';
        co = {'c','r','g','y'}; %linus -2,4 -1,3 0,2
    case 'Cor';
        co = {'c','r','g','y'}; %linus -2,4 -1,3 0,2
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
	UD = get(h_fig(f),'UserData');
	y_mm = UD.y_mm;
	
	this_slice_sites_idx = find(xyz(:,2)*grid_spacing==y_mm);
	n_unique_sites_this_slice = size(unique(xyz(this_slice_sites_idx,:),'rows'),1);
	
	old_str = get(get(gca,'Title'),'String');
	title({char(old_str),sprintf('%s, %s (...,%d), %d sites %d unique sites',experiment_id,grid_id,xyz(this_slice_sites_idx(1),2),length(this_slice_sites_idx),n_unique_sites_this_slice)},'Interpreter','none');
    
% 	set(findobj(gca,'Tag','penetration marker'),'Color',penetration_marker_color);
     hn = findobj(gca,'Tag','penetration marker nonsignificant');
     hs = findobj(gca,'Tag','penetration marker');
     recolor_markers(co{f},hs,hn);
	set(findobj(gca,'Tag','penetration marker'),'Tag','penetration marker set');
    

end