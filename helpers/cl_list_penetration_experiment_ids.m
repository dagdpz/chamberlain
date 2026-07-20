function ids = cl_list_penetration_experiment_ids(db_file)
%CL_LIST_PENETRATION_EXPERIMENT_IDS  Parse experiment_id cases from a penetration db.
%
% Example:
%   ids = cl_list_penetration_experiment_ids( ...
%       'Pulv_bodysignals/cl_pulv_bodysignals_bacchus_penetration_db');

if ~endsWith(db_file, '.m')
    db_path = which([db_file '.m']);
    if isempty(db_path)
        db_path = [db_file '.m'];
    end
else
    db_path = db_file;
end

txt = fileread(db_path);
tokens = regexp(txt, "case\s+'([^']+)'", 'tokens');
ids = cellfun(@(c) c{1}, tokens, 'UniformOutput', false);

end
