function tf = cl_is_plot_opts_struct(s)
%CL_IS_PLOT_OPTS_STRUCT  True if struct looks like plot_opts (not marker_style).

if ~isstruct(s) || isempty(fieldnames(s))
    tf = false;
    return;
end
names = lower(fieldnames(s));
plot_fields = {'jitterfraction', 'drawtrajectory', 'zoom', 'view'};
marker_fields = {'facecolor', 'edgecolor', 'facealpha', 'edgealpha', 'markersize', 'linewidth'};
tf = any(ismember(names, plot_fields)) && ~any(ismember(names, marker_fields));

end
