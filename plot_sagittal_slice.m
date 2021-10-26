function [x y z] = plot_sagittal_slice(filename,xyz_mm, z_offset_mm)
% plot_sagittal_slice('Y:\MRI\Flaffus\20160509\dicom\0100\FL_20160509_STEREO_neurological.vmr',[-10 -20 30]);
% plot_sagittal_slice('Y:\MRI\Flaffus\20160509\dicom\0101\FL_20160509_left_chamber_normal_128.vmr',[-11*0.8 0.8 0]);

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
        if strcmp(get(figs(f),'Name'),[filename ' x' num2str(xyz_mm(1),2)]),
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
        X = flip(X,3);       % flip L-R: now R is R
    end
    
    UD.filename = filename;
    % UD.grid_id = grid_id;
    UD.X = X;
    UD.voxel_size = voxel_size;
    UD.voxel_dim = voxel_dim;
    
    hf = figure('Name',[filename ' x' num2str(xyz_mm(1),2)],'Position',[100 100 800 800]);
    set(hf,'Userdata',UD);
    UD.x_mm = NaN;
    
end


% convert to voxels
x = fix(UD.voxel_dim/2) + fix(xyz_mm(1)/UD.voxel_size);

% center yz and convert to voxels (from upper left corner of the image)
y = fix(UD.voxel_dim/2) - xyz_mm(2)/UD.voxel_size;
z = fix(UD.voxel_dim/2) - xyz_mm(3)/UD.voxel_size;

if UD.x_mm ~= xyz_mm(1), % new sagittal slice
    imagesc((squeeze(UD.X(:,:,x)))');
    UD.x_mm = xyz_mm(1);
    colormap(gray); axis square;
    
    hold on; line([15 15+5/UD.voxel_size],[10 10],'Color',[1 1 1],'LineWidth',3);
    text(8,10,'A','Color',[1 1 1],'FontSize',14);
    text(15,10+2/UD.voxel_size,'5 mm','Color',[1 1 1]);
    
end

hold on; plot(y,z,'ro','MarkerSize',5,'Tag','penetration marker');

xlabel([UD.filename ' x ' num2str(xyz_mm(1), 2) ' (' num2str(x) ')'] ,'Interpreter','none');
set(gcf,'UserData',UD);
