function tf = cl_is_plot_opt_name(name)
%CL_IS_PLOT_OPT_NAME  True for plot_opts field names (case-insensitive).

if ~(ischar(name) || isstring(name))
    tf = false;
    return;
end
tf = ismember(lower(strtrim(char(name))), ...
    {'jitterfraction', 'drawtrajectory', 'zoom', 'view'});

end
