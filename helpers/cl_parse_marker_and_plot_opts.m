function [marker_style, plot_opts] = cl_parse_marker_and_plot_opts(varargin)
%CL_PARSE_MARKER_AND_PLOT_OPTS  Optional marker_style + plot_opts pairs.
%
%   [marker_style, plot_opts] = cl_parse_marker_and_plot_opts('r', 'zoom', 2);
%   [marker_style, plot_opts] = cl_parse_marker_and_plot_opts('zoom', 2);

marker_style = 'r';
plot_opts = struct();

if isempty(varargin)
    return;
end

plot_start = cl_plot_opts_start(varargin{:});
if plot_start == 1
    plot_opts = cl_merge_plot_opts(varargin{:});
    return;
end

if plot_start <= numel(varargin)
    if plot_start > 1
        if numel(varargin(1:plot_start - 1)) > 1
            error('cl_parse_marker_and_plot_opts:tooManyMarkerStyles', ...
                'Expected at most one marker_style before plot options.');
        end
        marker_style = varargin{1};
    end
    plot_opts = cl_merge_plot_opts(varargin{plot_start:end});
    return;
end

if numel(varargin) == 1
    arg = varargin{1};
    if isstruct(arg) && cl_is_plot_opts_struct(arg)
        plot_opts = cl_merge_plot_opts(arg);
    elseif cl_is_marker_style_arg(arg)
        marker_style = arg;
    else
        plot_opts = cl_merge_plot_opts(arg);
    end
    return;
end

if cl_is_marker_style_arg(varargin{1})
    marker_style = varargin{1};
    plot_opts = cl_merge_plot_opts(varargin{2:end});
else
    plot_opts = cl_merge_plot_opts(varargin{:});
end

end
