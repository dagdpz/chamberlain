% grid db

switch grid_id
	%% DPZ
	
	case {'GRID.22.1','GRID.22.2'}
		
		% large CIT chamber, made by Caltech
		chamber.IR = 11;         % 22
		chamber.OR = 13.5;        % 27
		
		grid_spacing = 0.8; % mm
		align_protrusion_angle = 90; % deg, relative to vertical axis of the grid
		
		xy_mm(:,1) = [
			[-3:3] ...
			[-5:5] ...
			[-7:7] ...
			[-8:8] ...
			[-9:9] ...
			[-10:10]...
			[-10:10]...
			[-11:11]...
			[-11:11]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-11:11]...
			[-11:11]...
			[-10:10]...
			[-10:10]...
			[-9:9] ...
			[-8:8] ...
			[-7:7] ...
			[-5:5] ...
			[-3:3]];
		
		xy_mm(:,2) = [
			12+0*([-3:3]) ...
			11+0*([-5:5]) ...
			10+0*([-7:7]) ...
			9+0*([-8:8]) ...
			8+0*([-9:9]) ...
			7+0*([-10:10]) ...
			6+0*([-10:10]) ...
			5+0*([-11:11]) ...
			4+0*([-11:11]) ...
			3+0*([-12:12]) ...
			2+0*([-12:12]) ...
			1+0*([-12:12]) ...
			0+0*([-12:12]) ...
			-1+0*([-12:12]) ...
			-2+0*([-12:12]) ...
			-3+0*([-12:12]) ...
			-4+0*([-11:11]) ...
			-5+0*([-11:11]) ...
			-6+0*([-10:10]) ...
			-7+0*([-10:10]) ...
			-8+0*([-9:9]) ...
			-9+0*([-8:8]) ...
			-10+0*([-7:7]) ...
			-11+0*([-5:5]) ...
			-12+0*([-3:3])];
		
	case {'GRID.22.3','GRID.22.4'}
		
		% large CIT chamber, made by Crist
		chamber.IR = 11;         % 22
		chamber.OR = 13.5;        % 27
		
		grid_spacing = 0.8; % mm
		align_protrusion_angle = 90; % deg, relative to vertical axis of the grid
		
		xy_mm(:,1) = [
			[-4:4] ...
			[-6:6] ...
			[-8:8] ...
			[-9:9] ...
			[-10:10]...
			[-10:10]...
			[-11:11]...
			[-11:11]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-12:12]...
			[-11:11]...
			[-11:11]...
			[-10:10]...
			[-10:10]...
			[-9:9] ...
			[-8:8] ...
			[-6:6] ...
			[-4:4]];
		
		xy_mm(:,2) = [
			12+0*([-4:4]) ...
			11+0*([-6:6]) ...
			10+0*([-8:8]) ...
			9+0*([-9:9]) ...
			8+0*([-10:10]) ...
			7+0*([-10:10]) ...
			6+0*([-11:11]) ...
			5+0*([-11:11]) ...
			4+0*([-12:12]) ...
			3+0*([-12:12]) ...
			2+0*([-12:12]) ...
			1+0*([-12:12]) ...
			0+0*([-12:12]) ...
			-1+0*([-12:12]) ...
			-2+0*([-12:12]) ...
			-3+0*([-12:12]) ...
			-4+0*([-12:12]) ...
			-5+0*([-11:11]) ...
			-6+0*([-11:11]) ...
			-7+0*([-10:10]) ...
			-8+0*([-10:10]) ...
			-9+0*([-9:9]) ...
			-10+0*([-8:8]) ...
			-11+0*([-6:6]) ...
			-12+0*([-4:4])];
		
		
		
		%% CALTECH
	case 'L.G.1'
		
		% small CIT chamber
		chamber.IR = 8;         % 16
		chamber.OR = 11;        % 22
		
		grid_spacing = 1; % mm
		align_protrusion_angle = 115; % deg, relative to vertical axis of the grid
		
		xy_mm(:,1) = [
			-3 -2 -1 0 1 2 3 ...
			-4 -3 -2 -1 0 1 2 3 4 ...
			-5 -4 -3 -2 -1 0 1 2 3 4 5 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-5 -4 -3 -2 -1 0 1 2 3 4 5 ...
			-4 -3 -2 -1 0 1 2 3 4 ...
			-3 -2 -1 0 1 2 3 ];
		
		xy_mm(:,2) = [
			6 6 6 6 6 6 6 ...
			5 5 5 5 5 5 5 5 5 ...
			4 4 4 4 4 4 4 4 4 4 4 ...
			3 3 3 3 3 3 3 3 3 3 3 3 3 ...
			2 2 2 2 2 2 2 2 2 2 2 2 2 ...
			1 1 1 1 1 1 1 1 1 1 1 1 1 ...
			0 0 0 0 0 0 0 0 0 0 0 0 0 ...
			-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
			-2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 ...
			-3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 ...
			-4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 ...
			-5 -5 -5 -5 -5 -5 -5 -5 -5 ...
			-6 -6 -6 -6 -6 -6 -6 ];
		
	case {'R.G.3','N.G'}
		
		% small CIT chamber
		chamber.IR = 8;         % 16
		chamber.OR = 11;        % 22
		
		grid_spacing = 0.8; % mm
		align_protrusion_angle = 90; % deg, relative to vertical axis of the grid
		
		xy_mm(:,1) = [
			-3 -2 -1 0 1 2 3 ...
			-5 -4 -3 -2 -1 0 1 2 3 4 5 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 ...
			-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 ...
			-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8  ...
			-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8  ...
			-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8  ...
			-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8  ...
			-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8  ...
			-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8  ...
			-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8  ...
			-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 ...
			-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 ...
			-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 ...
			-5 -4 -3 -2 -1 0 1 2 3 4 5 ...
			-3 -2 -1 0 1 2 3];
		
		
		xy_mm(:,2) = [
			8 8 8 8 8 8 8 ...
			7 7 7 7 7 7 7 7 7 7 7 ...
			6 6 6 6 6 6 6 6 6 6 6 6 6 ...
			5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 ...
			4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 ...
			3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 ...
			2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2  ...
			1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1  ...
			0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ...
			-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
			-2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2 -2  ...
			-3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3 -3  ...
			-4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4  ...
			-5 -5 -5 -5 -5 -5 -5 -5 -5 -5 -5 -5 -5 -5 -5  ...
			-6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6  ...
			-7 -7 -7 -7 -7 -7 -7 -7 -7 -7 -7 ...
			-8 -8 -8 -8 -8 -8 -8];
		
	otherwise
		error('non existing grid ID');
		
		
		
end
