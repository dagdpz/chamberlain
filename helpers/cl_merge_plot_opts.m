function plot_opts = cl_merge_plot_opts(varargin)
%CL_MERGE_PLOT_OPTS  Merge plot_opts struct(s) and name-value pairs.
%
%   plot_opts = cl_merge_plot_opts(struct('JitterFraction', 0.5), 'Zoom', 2);
%   plot_opts = cl_merge_plot_opts('zoom', 2, 'DrawTrajectory', true);
%
% Names are case-insensitive ('zoom' -> Zoom).

plot_opts = struct();
if nargin == 0
    return;
end

i = 1;
while i <= numel(varargin)
    arg = varargin{i};
    if isstruct(arg)
        plot_opts = merge_struct(plot_opts, arg);
        i = i + 1;
        continue;
    end
    if ischar(arg) || isstring(arg)
        field = canonical_plot_opt_field(char(arg));
        if i == numel(varargin)
            error('cl_merge_plot_opts:missingValue', ...
                'Missing value for option ''%s''.', char(arg));
        end
        plot_opts.(field) = varargin{i + 1};
        i = i + 2;
        continue;
    end
    error('cl_merge_plot_opts:invalidArg', ...
        'Expected struct or name-value pair, got %s.', class(arg));
end

end

function out = merge_struct(base, add)
out = base;
if isempty(add) || ~isstruct(add)
    return;
end
names = fieldnames(add);
for k = 1:numel(names)
    key = canonical_plot_opt_field(names{k});
    val = add.(names{k});
    if ~isempty(val)
        out.(key) = val;
    end
end
end

function field = canonical_plot_opt_field(name)
aliases = struct( ...
    'jitterfraction', 'JitterFraction', ...
    'drawtrajectory', 'DrawTrajectory', ...
    'zoom', 'Zoom', ...
    'view', 'View');
key = lower(strtrim(name));
if isfield(aliases, key)
    field = aliases.(key);
    return;
end
error('cl_merge_plot_opts:unknownOption', ...
    'Unknown plot option ''%s''. Use JitterFraction, DrawTrajectory, Zoom, or View.', name);
end
