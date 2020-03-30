function [x y z] = plot_coronal_slice_smaller(filename,xyz_mm, z_offset_mm)
% plot_coronal_slice('D:\MRI\Linus\20140725\ani_0783\0100\LI_20140725_T1_chamR_normal.vmr',[0 0 0]);
% plot_coronal_slice('D:\MRI\Linus\20140221elec\ani_0712\0005\LI_20130614_STEREO-TO-LI_20140221_Rcham_normal.vmr',[0 0 0]);

if nargin > 2,
	% correct for "from chamber top to the chamber center - brain entry"
	xyz_mm(3) = xyz_mm(3) + z_offset_mm;
end

figs = get(0,'Children');	
if ~isempty(figs), % figure(s) already exist
		
% 	if strcmp(get(gcf,'Name'),[filename ' y' num2str(xyz_mm(2),2)]),
% 		UD = get(gcf,'UserData');
% 	end
	for f=1:length(figs)
		if strcmp(get(figs(f),'Name'),[filename ' y' num2str(xyz_mm(2),2)]),
			figure(figs(f));
			UD = get(figs(f),'UserData');
			break;
		end
	end
	
end
	
if ~exist('UD','var'),
      
        vmr = xff(filename);
        
        voxel_size = vmr.VoxResX;
        voxel_dim = vmr.DimX;		% voxels in framing cube
        
        X = vmr.VMRData;		% y,z,x
	if vmr.Convention == 1,		% radiological
		X = flipdim(X,3);       % flip L-R: now R is R
	end
        
        UD.filename = filename;
	% UD.grid_id = grid_id;
        UD.X = X;
        UD.voxel_size = voxel_size;
        UD.voxel_dim = voxel_dim;
        UD.grid_y = xyz_mm(2);
	
	hf = figure('Name',[filename ' y' num2str(xyz_mm(2),2)],'Position',[100 100 800 800]);
        set(hf,'Userdata',UD);
	UD.y_mm = NaN;
 
end


% convert to voxels
y = fix(UD.voxel_dim/2) - fix(xyz_mm(2)/UD.voxel_size);

% center xz and convert to voxels (from upper left corner of the image)
x = xyz_mm(1)/UD.voxel_size + fix(UD.voxel_dim/2);
z = fix(UD.voxel_dim/2) - xyz_mm(3)/UD.voxel_size;

if UD.y_mm ~= xyz_mm(2), % new coronal slice
	imagesc(squeeze(UD.X(y,:,:)));
	UD.y_mm = xyz_mm(2);
	colormap(gray); axis square; 
	
	hold on; line([15 15+5/UD.voxel_size],[10 10],'Color',[1 1 1],'LineWidth',3); 
	text(8,10,'L','Color',[1 1 1],'FontSize',14);
	text(15,10+2/UD.voxel_size,'5 mm','Color',[1 1 1]);
	
end

hold on; plot(x,z,'ro','MarkerSize',0.5,'linewidth',0.1,'Tag','penetration marker');

xlabel([UD.filename ' y ' num2str(xyz_mm(2), 2) ' (' num2str(y) ')'] ,'Interpreter','none');
set(gcf,'UserData',UD);
