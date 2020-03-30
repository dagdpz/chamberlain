function map_grid_penetrations(db_file,experiment_id)
% Examples:
% map_grid_penetrations('Linus microstim beh electrode MRI localization')
% map_grid_penetrations('D:\Sources\MATLAB\chamberlain\db\Linus_microstim_beh_electrode_MRI_localization.m')

% db_file can be: 
% 1) penetration_db.m
% 2) name of separate db .m file


run(db_file);


figure('Name',['map_grid_penetrations: ' db_file],'Position',[100 100 1100 600],'Number','off');
hAxex = axes('Units','normalized','Position',[0.05 0.05 0.4 0.8]); axis square;
grid_info = plot_grid(grid_id);
title([experiment_id ' ' grid_id],'Interpreter','none');

set(gcf,'Userdata',xyz*grid_info.spacing);

for p = 1:length(penetration_date),	
	penetration_list{p} = [penetration_date{p}, ' ---> ', num2str(xyz(p,:)) , ' : ', target{p}, ' | ' notes{p}];
end

penetration_list = ['clear all' penetration_list];

hListbox = uicontrol(	'Style','List',...
			'String',penetration_list,...
			'Units','normalized',...
			'Position',[0.5 0.05 0.45 0.8],...
			'Callback',@listbox_Callback,...
			'Max',2,'Min',0);
 
 
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns contents
% contents{get(hObject,'Value')} returns selected item from listbox1
items = get(hObject,'String');
index_selected = get(hObject,'Value');
xyz = get(gcf,'Userdata');
if index_selected(1)>1,
	hp = plot(xyz(index_selected-1,1),xyz(index_selected-1,2),'x','Tag','penetration');
else
	delete(findobj('Tag','penetration'));	
end




