function recolor_markers(color,hs,hn)

% ha = findobj(gca,'Tag','penetration marker');
s = 128/255;
e = 255/255;

Ysorig_cell = get(hs,'YData');
% Ynorig_cell = get(hn,'YData');
if iscell(Ysorig_cell)
    Ysorig=cell2mat(Ysorig_cell);
else
    Ysorig=Ysorig_cell;    
end
% if iscell(Ynorig_cell)
%     Ynorig=cell2mat(Ynorig_cell);
% else
%     Ynorig=Ynorig_cell;    
% end
[Ysort Yind]= sort(Ysorig);
hs_new = hs(Yind);

% Ymin = min([Ysorig;Ynorig]);
% Ymax = max([Ysorig;Ynorig]);
Ymin = min([Ysorig]);
Ymax = max([Ysorig]);

Yval = (Ysort-Ymin)/(Ymax-Ymin+1);
Ycol = (Yval*(e-s)+s);

cm = Ycol;
switch color
    case 'r'
        cmo = horzcat(cm, zeros(size(cm)), zeros(size(cm)));
    case 'g'
        cmo = horzcat(zeros(size(cm)), cm, zeros(size(cm)));
    case 'b'
        cmo = horzcat(zeros(size(cm)), zeros(size(cm)), cm);
    case 'c'
        cmo = horzcat(zeros(size(cm)), cm, cm);
end

for ind = 1:numel(hs)
    set(hs_new(ind),'Color',cmo(ind,:));
    uistack(hs_new(ind),'top');
end

