function opts = cl_parse_plot_options(arg1, arg2, varargin)
%CL_PARSE_PLOT_OPTIONS  Options for penetration slice plotting.
%
%   opts = cl_parse_plot_options('coronal')
%   opts = cl_parse_plot_options('coronal', 'zoom', 2)
%   opts = cl_parse_plot_options(plot_opts, 'coronal')           % legacy struct
%   opts = cl_parse_plot_options(plot_opts, 'coronal', 'zoom', 2)
%
%   JitterFraction   Uniform jitter range as fraction of marker diameter
%                    in the slice plane (0 = off). Coronal: left-right.
%                    Sagittal: anterior-posterior.
%   DrawTrajectory   If true, one dashed line per unique grid column on the slice
%                    (LR for coronal, AP for sagittal). Jitter moves markers only.
%   Zoom             Linear zoom on slice image; 1 = full image (default),
%                    2 = central 50%, 4 = central 25%.

if nargin < 1 || isempty(arg1)
    view = 'coronal';
    plot_opts = cl_merge_plot_opts(varargin{:});
elseif ischar(arg1) || isstring(arg1)
    view = char(arg1);
    plot_opts = cl_merge_plot_opts(arg2, varargin{:});
elseif ischar(arg2) || isstring(arg2)
    view = char(arg2);
    plot_opts = cl_merge_plot_opts(arg1, varargin{:});
else
    error('cl_parse_plot_options:invalidArgs', ...
        'Expected view (char) as first or second argument.');
end

opts = struct('JitterFraction', 0, 'DrawTrajectory', false, 'View', view, 'Zoom', 1);

fields = {'JitterFraction', 'DrawTrajectory', 'View', 'Zoom'};
for i = 1:numel(fields)
    f = fields{i};
    if isfield(plot_opts, f) && ~isempty(plot_opts.(f))
        opts.(f) = plot_opts.(f);
    end
end

end
