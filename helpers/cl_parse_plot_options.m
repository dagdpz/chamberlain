function opts = cl_parse_plot_options(plot_opts, view)
%PARSE_PLOT_OPTIONS  Options for penetration slice plotting.
%
%   JitterFraction   Uniform jitter range as fraction of marker diameter
%                    in the slice plane (0 = off). Coronal: left-right.
%                    Sagittal: anterior-posterior.
%   DrawTrajectory   If true, one dashed line per unique grid column on the slice
%                    (LR for coronal, AP for sagittal). Jitter moves markers only.

opts = struct('JitterFraction', 0, 'DrawTrajectory', false, 'View', view);

if nargin < 1 || isempty(plot_opts)
    return;
end

fields = {'JitterFraction', 'DrawTrajectory', 'View'};
for i = 1:numel(fields)
    f = fields{i};
    if isfield(plot_opts, f) && ~isempty(plot_opts.(f))
        opts.(f) = plot_opts.(f);
    end
end

end
