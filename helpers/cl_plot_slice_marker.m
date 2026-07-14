function h = cl_plot_slice_marker(ax, plot_xy, marker_style, plot_opts, default_marker_size, view)
%PLOT_SLICE_MARKER  Plot penetration marker with optional jitter and trajectory.

if nargin < 6
    view = 'coronal';
end

style = cl_parse_marker_style(marker_style, default_marker_size);
opts = cl_parse_plot_options(plot_opts, view);

track_pos = plot_xy(1);  % true LR (coronal) or AP (sagittal) grid position
plot_y = plot_xy(2);

marker_pos = track_pos;
if opts.JitterFraction ~= 0
    marker_pos = track_pos + cl_marker_jitter_offset(ax, style.MarkerSize, opts.JitterFraction);
end

hold(ax, 'on');
h = plot(ax, marker_pos, plot_y, 'o', 'Tag', 'penetration marker');
cl_apply_marker_style(h, marker_style, default_marker_size);

if opts.DrawTrajectory
    existing = findobj(ax, 'Tag', 'electrode trajectory');
    already_drawn = false;
    for ei = 1:numel(existing)
        xd = get(existing(ei), 'XData');
        if ~isempty(xd) && abs(xd(1) - track_pos) < 0.01
            already_drawn = true;
            break;
        end
    end
    if ~already_drawn
        yl = ylim(ax);
        line(ax, [track_pos track_pos], yl, 'Color', 'w', 'LineStyle', '--', ...
            'Tag', 'electrode trajectory');
    end
end

end
