function style = cl_parse_marker_style(marker_input, default_marker_size)
%PARSE_MARKER_STYLE  Normalize marker color input for penetration plots.
%
%   style = cl_parse_marker_style('r')
%   style = cl_parse_marker_style([1 0 0])
%   style = cl_parse_marker_style(struct('FaceColor',[1 0 0],'EdgeColor','k',...
%       'FaceAlpha',0.4,'EdgeAlpha',1))
%
%   Fields: FaceColor, EdgeColor, FaceAlpha, EdgeAlpha, MarkerSize

if nargin < 2
    default_marker_size = [];
end

style = struct( ...
    'FaceColor', [1 0 0], ...
    'EdgeColor', [0.5 0 0], ...
    'FaceAlpha', 1, ...
    'EdgeAlpha', 1, ...
    'MarkerSize', default_marker_size);

if nargin < 1 || isempty(marker_input)
    return;
end

if isstruct(marker_input)
    fields = {'FaceColor','EdgeColor','FaceAlpha','EdgeAlpha','MarkerSize'};
    for i = 1:numel(fields)
        f = fields{i};
        if isfield(marker_input, f) && ~isempty(marker_input.(f))
            style.(f) = marker_input.(f);
        end
    end
    if isempty(style.MarkerSize)
        style.MarkerSize = default_marker_size;
    end
    if isnumeric(style.FaceColor) && ~isfield(marker_input, 'EdgeColor')
        style.EdgeColor = style.FaceColor / 2;
    end
    return;
end

style.FaceColor = marker_input;
if isnumeric(marker_input)
    style.EdgeColor = marker_input / 2;
else
    style.EdgeColor = marker_input;
end
if isempty(style.MarkerSize)
    style.MarkerSize = default_marker_size;
end
end
