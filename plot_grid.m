function grid_info = plot_grid(grid_id)

n_cham_el = 128;

UD.voxel_size = 1;
UD.voxel_dim = 0; %128; % no need to set 128 for plotting the grid
 
run('grid_db');

grid_info.chamber = chamber;
grid_info.spacing = grid_spacing;
grid_info.align_protrusion_angle = align_protrusion_angle;
      
% figure('Name',type);

x = chamber.IR*1/UD.voxel_size*cos(2*pi*(1:(n_cham_el+1))/n_cham_el)+UD.voxel_dim/2;
y = chamber.IR*1/UD.voxel_size*sin(2*pi*(1:(n_cham_el+1))/n_cham_el)+UD.voxel_dim/2;
hold on;
plot(x,y,'Color',[0 0 0]);
line([min(x) max(x)],[0 0]+UD.voxel_dim/2,'Color',[0.5 0.5 0.5]);
line([0 0]+UD.voxel_dim/2,[min(y) max(y)],'Color',[0.5 0.5 0.5]);
plot(cos(align_protrusion_angle/180*pi)*chamber.IR*1/UD.voxel_size+UD.voxel_dim/2,sin(align_protrusion_angle/180*pi)*chamber.IR*1/UD.voxel_size+UD.voxel_dim/2,'kd');

axis square;

xy = grid_spacing*xy_mm/UD.voxel_size;

% theta = align_protrusion_angle*pi/180;
% theta = -25*pi/180;
theta = 0;

rot = [cos(theta)  -sin(theta) ; sin(theta)  cos(theta)];
xy = xy * rot;

plot(xy(:,1)+UD.voxel_dim/2,-xy(:,2)+UD.voxel_dim/2,'ko','MarkerSize',2/UD.voxel_size);