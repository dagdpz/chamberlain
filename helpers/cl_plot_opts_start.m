function idx = cl_plot_opts_start(varargin)
%CL_PLOT_OPTS_START  Index of first plot_opts struct or name-value token.

idx = numel(varargin) + 1;
for i = 1:numel(varargin)
    arg = varargin{i};
    if isstruct(arg) && cl_is_plot_opts_struct(arg)
        idx = i;
        return;
    end
    if (ischar(arg) || isstring(arg)) && cl_is_plot_opt_name(arg)
        idx = i;
        return;
    end
end

end
