function cl_plot_coronal_slice_ax(ax, vmr_ud, y_mm, sites_xyz_mm, marker_style, varargin)
%CL_PLOT_CORONAL_SLICE_AX  Render one coronal VMR slice and penetration markers on ax.
%
% sites_xyz_mm: Nx3 [x y z] in mm (y should match y_mm; z includes z_offset_mm).
% Optional trailing args: default_marker_size, title_lines, plot_opts struct/pairs.
%
% Example:
%   cl_plot_coronal_slice_ax(ax, vmr_ud, y_mm, sites_xyz_mm, 'r', 'zoom', 2);
%   cl_plot_coronal_slice_ax(ax, vmr_ud, y_mm, sites_xyz_mm, 'r', 3, title_lines, 'zoom', 2);

if nargin < 5 || isempty(marker_style)
    marker_style = 'r';
end

[default_marker_size, title_lines, plot_opts] = cl_parse_slice_ax_opts(y_mm, varargin{:});
slice_opts = cl_parse_plot_options('coronal', plot_opts);

y_vox = fix(vmr_ud.voxel_dim / 2) - fix(y_mm / vmr_ud.voxel_size);
imagesc(ax, squeeze(vmr_ud.X(y_vox, :, :)));
colormap(ax, gray);
axis(ax, 'square');
hold(ax, 'on');

for k = 1:size(sites_xyz_mm, 1)
    xyz_mm = sites_xyz_mm(k, :);
    x = xyz_mm(1) / vmr_ud.voxel_size + fix(vmr_ud.voxel_dim / 2);
    z = fix(vmr_ud.voxel_dim / 2) - xyz_mm(3) / vmr_ud.voxel_size;
    cl_plot_slice_marker(ax, [x z], marker_style, plot_opts, default_marker_size, 'coronal');
end

title(ax, title_lines, 'Interpreter', 'none', 'FontSize', 8);
set(ax, 'XTick', [], 'YTick', []);
cl_apply_slice_zoom(ax, slice_opts.Zoom);
cl_plot_slice_scale_bar(ax, vmr_ud.voxel_size, 'View', 'coronal', ...
    'LineWidth', 2, 'LabelFontSize', 10, 'TextFontSize', 8);

end
