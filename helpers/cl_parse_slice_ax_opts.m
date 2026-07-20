function [default_marker_size, title_lines, plot_opts] = cl_parse_slice_ax_opts(y_mm, varargin)
%CL_PARSE_SLICE_AX_OPTS  default_marker_size, title, and plot_opts from varargin.

default_marker_size = 3;
title_lines = sprintf('y=%.1f', y_mm);
plot_opts = struct();

if isempty(varargin)
    return;
end

plot_start = cl_plot_opts_start(varargin{:});

% Legacy: plot_opts struct, default_marker_size, title_lines [, extra pairs]
if plot_start == 1 && numel(varargin) >= 3 && isstruct(varargin{1}) && ...
        isnumeric(varargin{2}) && isscalar(varargin{2}) && ...
        (ischar(varargin{3}) || isstring(varargin{3}) || iscell(varargin{3}))
    plot_opts = cl_merge_plot_opts(varargin{1});
    default_marker_size = varargin{2};
    title_lines = varargin{3};
    if numel(varargin) > 3
        plot_opts = cl_merge_plot_opts(plot_opts, varargin{4:end});
    end
    return;
end

% Legacy/default: default_marker_size [, title_lines]
if plot_start > numel(varargin)
    if isnumeric(varargin{1}) && isscalar(varargin{1})
        default_marker_size = varargin{1};
        if numel(varargin) >= 2
            title_lines = varargin{2};
        end
    end
    return;
end

positional = varargin(1:plot_start - 1);
if plot_start <= numel(varargin)
    plot_opts = cl_merge_plot_opts(varargin{plot_start:end});
end

for k = 1:numel(positional)
    arg = positional{k};
    if isnumeric(arg) && isscalar(arg)
        default_marker_size = arg;
    elseif ischar(arg) || isstring(arg) || iscell(arg)
        title_lines = arg;
    elseif isstruct(arg) && cl_is_plot_opts_struct(arg)
        plot_opts = cl_merge_plot_opts(plot_opts, arg);
    else
        error('cl_parse_slice_ax_opts:invalidArg', ...
            'Unexpected argument: %s.', class(arg));
    end
end

end
