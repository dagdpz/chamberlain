% Curius_ephys_microstim_pulv_mat
% penetration database
% xyz: grid_hole_x, grid_hole_y, z depth mm from "top of the brain" or "from chamber top"

n = 1;

[tuning_per_unit_table]=ph_load_extended_tuning_table(keys);
[tuning_per_unit_table]=ph_reduce_tuning_table(tuning_per_unit_table,keys);
        co = {'b','m','r'}; % visual,visuomotor, motor
switch experiment_id
	case 'memory'
		 task_column=DAG_find_column_index(tuning_per_unit_table,'in_epoch_main_Msac_fix');
		 sign_column=DAG_find_column_index(tuning_per_unit_table,'in_NH_Cue_position_Msac_opt');
        co = {'b','m','r'}; % visual,visuomotor, motor
	case 'direct'
		 task_column=DAG_find_column_index(tuning_per_unit_table,'in_epoch_main_Msac_fix');
		 sign_column=DAG_find_column_index(tuning_per_unit_table,'in_NH_Cue_position_Vsac_opt');   
        co = {'b','m','r'}; % visual,visuomotor, motor      
	case 'Ddre'
		 task_column=DAG_find_column_index(tuning_per_unit_table,'in_epoch_main_Msac_fix');
		 sign_column=DAG_find_column_index(tuning_per_unit_table,'in_NH_Cue_position_Ddre_han');  
        co = {'b','m','r'}; % visual,visuomotor, motor   
        
	case 'Ddre_han'
		 task_column=DAG_find_column_index(tuning_per_unit_table,'in_epoch_main_Ddre_han');
		 sign_column=DAG_find_column_index(tuning_per_unit_table,'in_AH_Cue_position_Ddre_han');  
        co = {'b','m','r'}; % visual,visuomotor, motor   
	case 'visuomotor'
		 task_column=DAG_find_column_index(tuning_per_unit_table,'in_epoch_main_Msac_opt');
		 sign_column=[DAG_find_column_index(tuning_per_unit_table,'visual_Msac_opt'),...
                      DAG_find_column_index(tuning_per_unit_table,'visuomotor_Msac_opt'),...
                      DAG_find_column_index(tuning_per_unit_table,'motor_Msac_opt')];
        co = {'b','m','r'}; % visual,visuomotor, motor
	case 'gaze'
		 task_column=DAG_find_column_index(tuning_per_unit_table,'in_epoch_main_Msac_fix');
         coloumn_temp=DAG_find_column_index(tuning_per_unit_table,'in_AH_Fhol_gaze_modulation_x_Msac_fix');
         coloumn_temp2=DAG_find_column_index(tuning_per_unit_table,'in_AH_Fhol_gaze_pref_x_Msac_fix');
         coloumn_temp3=DAG_find_column_index(tuning_per_unit_table,'in_AH_Fhol_position_Msac_fix');
         temp_table=[tuning_per_unit_table(:,coloumn_temp) tuning_per_unit_table(:,coloumn_temp2) tuning_per_unit_table(:,coloumn_temp3)];
         for k=1:size(temp_table,1)
             gaze_column{k}=[temp_table{k,:}];
         end
         gaze_column=gaze_column';
         n_columns=size(tuning_per_unit_table,2);
         tuning_per_unit_table(:,n_columns+1)=num2cell(strcmp(gaze_column,'monotonousCStrue'));
         tuning_per_unit_table(:,n_columns+2)=num2cell(strcmp(gaze_column,'monotonousIStrue'));
         tuning_per_unit_table(:,n_columns+3)=num2cell(strcmp(gaze_column,'nonmonotonousCEtrue'));
         tuning_per_unit_table(:,n_columns+4)=num2cell(strcmp(gaze_column,'nonmonotonousPEtrue'));
		 sign_column=[n_columns+1,n_columns+2,n_columns+3,n_columns+4];
        co = {'m','r','b','g'}; % mono contra, mono ipsi, nonmonocentral nonmonoperipheral
end


clear penetration_date xyz target notes

target              = tuning_per_unit_table(:,DAG_find_column_index(tuning_per_unit_table,'target'));
penetration_date    = tuning_per_unit_table(:,DAG_find_column_index(tuning_per_unit_table,'unit_ID'));
task_type           = tuning_per_unit_table(:,task_column);
for c=1:numel(sign_column)
significant_c{c}       = tuning_per_unit_table(:,sign_column(c));
end

row_index           = cellfun(@(x) ~isempty(strfind(x,target_area)),target) & cellfun(@(x) ~isempty(strfind(x,keys.monkey)),penetration_date) & ~cellfun(@isempty,task_type); %% index by target location and monkey initials

idx_x=DAG_find_column_index(tuning_per_unit_table,'grid_x');
idx_y=DAG_find_column_index(tuning_per_unit_table,'grid_y');
idx_z=DAG_find_column_index(tuning_per_unit_table,'electrode_depth');
xyz                 = cell2mat(tuning_per_unit_table(row_index,[idx_x idx_y idx_z]));
xyz(:,3)            = -xyz(:,3);   
xyz_nojitter=xyz;

xyz(:,1)            = xyz(:,1) + (rand(size(xyz(:,1)))-0.5)*1.5; % jitter
% xyz(:,3)            = xyz(:,3)-repmat(z_offset_mm,sum(row_index),1);                                            %% Z relative to brain start
notes               = tuning_per_unit_table(row_index,DAG_find_column_index(tuning_per_unit_table,'unit_ID'));
target              = target(row_index);
penetration_date    = penetration_date(row_index);
%significant = cellfun(@(x) isempty(strfind(x,'-')),significant_c(row_index));
for c=1:numel(sign_column)
significant(:,c) = cellfun(@(x) (~isa(x,'char')&&x==1)||(~isempty(x)&&isa(x,'char')&&~strcmp(x,'-')&&~strcmp(x,'false')),significant_c{c}(row_index));
end
% 
% aa= find(row_index)';
% for a=aa
%     
% significant(:,c) = cellfun(@(x) (~isa(x,'char')&&x==1)||(~isempty(x)&&isa(x,'char')&&~strcmp(x,'-')&&~strcmp(x,'false')),significant_c{c}(a));
% end
