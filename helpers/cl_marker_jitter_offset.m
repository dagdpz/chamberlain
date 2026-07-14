function offset = cl_marker_jitter_offset(ax, marker_size_pts, jitter_fraction)
%MARKER_JITTER_OFFSET  Uniform LR/AP jitter in data units on the slice plane.
%
%   Coronal: horizontal (LR) only — depth is not jittered.
%   Sagittal: horizontal (AP) only — depth is not jittered.
%
%   offset is uniform in [-range, +range] with
%   range = jitter_fraction * marker_diameter_in_data_units.

offset = 0;
if nargin < 3 || isempty(jitter_fraction) || jitter_fraction == 0
    return;
end
if nargin < 2 || isempty(marker_size_pts)
    marker_size_pts = 5;
end

old_units = get(ax, 'Units');
set(ax, 'Units', 'points');
pos = get(ax, 'Position');
set(ax, 'Units', old_units);

xlim_val = diff(xlim(ax));
if xlim_val <= 0 || pos(3) <= 0
    return;
end

marker_diameter_data = marker_size_pts * (xlim_val / pos(3));
range = jitter_fraction * marker_diameter_data;
offset = (2 * rand - 1) * range;

end
