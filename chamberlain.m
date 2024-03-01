function chamberlain(varargin)
% Needs NeuroElf/BVQXtools!
% e.g. addpath('Y:\Sources\NeuroElf_v11_7521\');
% Examples:
% chamberlain('load_file','Z:\MRI\Hanuman\20101128cham\7\7_L_cham.vmr','R.G.3');
% chamberlain('load_file','D:\MRI\Linus\20140725\ani_0783\0100\LI_20140725_T1_chamR_normal.vmr','GRID.22.1');
% chamberlain(-8,[-2 -2]); % in mm
% chamberlain('plot_grid',[3 3]); % in grid holes

if nargin < 1,
    disp('please specify inputs - action, anatomy file, grid, or location');
    return;
    
    
elseif strcmp(varargin{1},'load_file'),
    action = 'load_anatomical';
    filename = varargin{2};
    grid_id = varargin{3};
    
    % elseif strcmp(varargin{1},'load_file_coronal'),
    %         action = 'load_anatomical_coronal';
    %         filename = varargin{2};
    %         grid_id = varargin{3};
    
else
    UD = get(0,'UserData');
    
    if ~ischar(varargin{1}),
        z_mm = varargin{1};
        if nargin > 1,
            xy_mm = varargin{2};
        end
        action = 'plot_anatomical';
    else
        action = varargin{1};
        if nargin > 1,
            z_mm = varargin{2};
        end
        if nargin > 2,
            xy_mm = varargin{3};
        end
    end
end

if strcmp(action,'load_anatomical'),
    
    
    vmr = BVQXfile(filename);
    
    voxel_size = vmr.VoxResX;
    voxel_dim = vmr.DimX;		% voxels in framing cube
    
    X = vmr.VMRData;		% y,z,x
    if vmr.Convention == 1,		% radiological
        X = flipdim(X,3);       % flip L-R: now R is R
    end
    
    UD.filename = filename;
    UD.grid_id = grid_id;
    UD.X = X;
    UD.voxel_size = voxel_size;
    UD.voxel_dim = voxel_dim;
    UD.plot_grid = 0;
    
    set(0,'Userdata',UD);
    
    chamberlain('plot_anatomical',0);
    
    
elseif strcmp(action,'plot_anatomical')
    
    % convert to voxels
    z = fix(-z_mm/UD.voxel_size) + fix(UD.voxel_dim/2);
    
    h = get(0,'Children');
    if any(strcmp(get(h,'Tag'),'Chamberlain')),
        h_idx = find(strcmp(get(h,'Tag'),'Chamberlain'));
        figure(h(h_idx));
    else
        figure('Name',UD.filename,'Tag','Chamberlain');
        
    end
    imagesc(squeeze(UD.X(:,z,:)));
    colormap(gray); axis square;
    title(['z ' num2str(z_mm, '%2.f') ' (' num2str(z) ')']);
    xlabel(UD.filename,'Interpreter','none');
    
    chamberlain('plot_chamber');
    % chamberlain('plot_stereotaxic');
    
    if exist('xy_mm','var')
        chamberlain('plot_location',xy_mm);
    end
    
elseif strcmp(action,'plot_stereotaxic'),
    
    xlim = get(gca,'Xlim');
    ylim = get(gca,'Ylim');
    
    hold on;
    line([xlim(1) xlim(2)],[0 0]+UD.voxel_dim/2,'Color',[1 0 0]);
    line([0 0]+UD.voxel_dim/2,[ylim(1) ylim(2)],'Color',[1 0 0]);
    
elseif strcmp(action,'plot_chamber')
    
    grid_id = UD.grid_id;
    run('grid_db');
    
    n_cham_el = 128;
    
    x = chamber.IR*1/UD.voxel_size*cos(2*pi*(1:(n_cham_el+1))/n_cham_el)+UD.voxel_dim/2;
    y = chamber.IR*1/UD.voxel_size*sin(2*pi*(1:(n_cham_el+1))/n_cham_el)+UD.voxel_dim/2;
    hold on;
    plot(x,y,'Color',[1 0.5 0]);
    line([min(x) max(x)],[0 0]+UD.voxel_dim/2,'Color',[1 0 0]);
    line([0 0]+UD.voxel_dim/2,[min(y) max(y)],'Color',[1 0 0]);
    ig_add_title([' ' grid_id]);
    
    if UD.plot_grid,
        chamberlain('plot_grid');
    end
    
    % plot(0+UD.voxel_dim/2,0+UD.voxel_dim/2,'ro','MarkerSize',1/UD.voxel_size);
    
elseif strcmp(action,'plot_grid')
    
    UD.plot_grid = 1;
    
    grid_id = UD.grid_id;
    run('grid_db');
    
    xy = grid_spacing*xy_mm/UD.voxel_size;
    
    plot(xy(:,1)+UD.voxel_dim/2,-xy(:,2)+UD.voxel_dim/2,'y.','MarkerSize',0.1/UD.voxel_size);
    
    if nargin == 2,
        chamberlain('plot_location',varargin{2}*grid_spacing);
    end
    
    set(0,'UserData',UD);
    
elseif strcmp(action,'plot_location')
    xy_mm = varargin{2};
    xy = xy_mm/UD.voxel_size;
    
    
    hold on;
    plot(xy(1)+UD.voxel_dim/2,-xy(2)+UD.voxel_dim/2,'rx','MarkerSize',2/UD.voxel_size);
    ht = get(gca,'title');
    title_str = [get(ht,'String') , sprintf(' xy %.2f %.2f',xy_mm(1),xy_mm(2))];
    title(title_str);
    
end