function tf = cl_is_marker_style_arg(arg)
%CL_IS_MARKER_STYLE_ARG  True for marker_style char/RGB/struct arguments.

if isstruct(arg)
    names = lower(fieldnames(arg));
    marker_fields = {'facecolor', 'edgecolor', 'facealpha', 'edgealpha', 'markersize', 'linewidth'};
    tf = any(ismember(names, marker_fields));
    return;
end
if isnumeric(arg) && numel(arg) == 3
    tf = true;
    return;
end
if ischar(arg) || isstring(arg)
    tf = ~cl_is_plot_opt_name(arg);
    return;
end
tf = false;

end
