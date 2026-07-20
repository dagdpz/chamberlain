function cl_plot_slice_scale_bar(ax, voxel_size_mm, varargin)
%CL_PLOT_SLICE_SCALE_BAR  5 mm scale bar in the visible slice corner.
%
% Call after cl_apply_slice_zoom so the bar stays on-screen and anatomically
% correct. Positions relative to current xlim/ylim.
%
%   cl_plot_slice_scale_bar(ax, voxel_size, 'View', 'coronal');
%   cl_plot_slice_scale_bar(ax, voxel_size, 'View', 'sagittal', 'LineWidth', 3);

if nargin < 1 || isempty(ax)
    ax = gca;
end

p = inputParser;
addParameter(p, 'View', 'coronal', @(x) ismember(x, {'coronal', 'sagittal'}));
addParameter(p, 'DirectionLabel', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'BarLengthMm', 5, @(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p, 'LineWidth', 2, @(x) isnumeric(x) && isscalar(x));
addParameter(p, 'LabelFontSize', 10, @(x) isnumeric(x) && isscalar(x));
addParameter(p, 'TextFontSize', 8, @(x) isnumeric(x) && isscalar(x));
parse(p, varargin{:});

dir_label = char(p.Results.DirectionLabel);
if isempty(dir_label)
    if strcmp(p.Results.View, 'sagittal')
        dir_label = 'A';
    else
        dir_label = 'L';
    end
end

xl = xlim(ax);
yl = ylim(ax);
dx = diff(xl);
dy = diff(yl);
bar_len = p.Results.BarLengthMm / voxel_size_mm;

y_bar = yl(1) + 0.06 * dy;
x_dir = xl(1) + 0.04 * dx;
x_bar0 = xl(1) + 0.10 * dx;
x_bar1 = x_bar0 + bar_len;

hold(ax, 'on');
text(ax, x_dir, y_bar, dir_label, 'Color', [1 1 1], ...
    'FontSize', p.Results.LabelFontSize, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
line(ax, [x_bar0 x_bar1], [y_bar y_bar], 'Color', [1 1 1], ...
    'LineWidth', p.Results.LineWidth);
text(ax, x_bar0, y_bar + 0.05 * dy, sprintf('%g mm', p.Results.BarLengthMm), ...
    'Color', [1 1 1], 'FontSize', p.Results.TextFontSize, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

end
