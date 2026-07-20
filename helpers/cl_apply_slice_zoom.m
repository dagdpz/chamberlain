function cl_apply_slice_zoom(ax, zoom)
%CL_APPLY_SLICE_ZOOM  Crop slice axes to the central portion of the image.
%
%   zoom = 1 (default): full image
%   zoom = 2: central 50% (linear zoom factor 2)
%   zoom = 4: central 25%
%
% Example:
%   cl_apply_slice_zoom(gca, 2);

if nargin < 1 || isempty(ax)
    ax = gca;
end
if nargin < 2 || isempty(zoom) || zoom <= 1
    return;
end

xl = xlim(ax);
yl = ylim(ax);
xc = mean(xl);
yc = mean(yl);
half_w = diff(xl) / (2 * zoom);
half_h = diff(yl) / (2 * zoom);
xlim(ax, [xc - half_w, xc + half_w]);
ylim(ax, [yc - half_h, yc + half_h]);
axis(ax, 'square');

end
