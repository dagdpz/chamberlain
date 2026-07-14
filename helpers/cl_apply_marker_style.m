function cl_apply_marker_style(h, marker_input, default_marker_size)
%APPLY_MARKER_STYLE  Set separate face/edge color and alpha on plot markers.
%
%   cl_apply_marker_style(h, 'r')
%   cl_apply_marker_style(h, struct('FaceColor',[1 0 0],'EdgeColor','k',...
%       'FaceAlpha',0.5,'EdgeAlpha',1))

if nargin < 3
    default_marker_size = [];
end
if isempty(h)
    return;
end

style = cl_parse_marker_style(marker_input, default_marker_size);

for i = 1:numel(h)
    hi = h(i);
    face = style.FaceColor;
    edge = style.EdgeColor;

    if style.FaceAlpha <= 0
        face = 'none';
    end

    set(hi, 'Marker', 'o', 'LineStyle', 'none', ...
        'MarkerFaceColor', face, 'MarkerEdgeColor', edge);
    if ~isempty(style.MarkerSize)
        set(hi, 'MarkerSize', style.MarkerSize);
    end

    alpha_set = false;
    try
        if style.FaceAlpha > 0
            set(hi, 'MarkerFaceAlpha', style.FaceAlpha);
        end
        if style.EdgeAlpha < 1
            set(hi, 'MarkerEdgeAlpha', style.EdgeAlpha);
        end
        alpha_set = true;
    catch
    end

    if ~alpha_set && isnumeric(face) && style.FaceAlpha > 0 && style.FaceAlpha < 1
        set(hi, 'MarkerFaceColor', face * style.FaceAlpha + 0.5 * (1 - style.FaceAlpha));
    end
    if ~alpha_set && isnumeric(edge) && style.EdgeAlpha < 1
        set(hi, 'MarkerEdgeColor', edge * style.EdgeAlpha + 0.5 * (1 - style.EdgeAlpha));
    end
end
end
