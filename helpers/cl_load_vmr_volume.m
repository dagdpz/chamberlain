function ud = cl_load_vmr_volume(vmr_path, vmr_cache)
%CL_LOAD_VMR_VOLUME  Load VMR volume once; optional cache map keyed by path.
%
% Example:
%   ud = cl_load_vmr_volume('Y:\MRI\...\chamber_normal.vmr');

if nargin < 2
    vmr_cache = [];
end

if ~isempty(vmr_cache) && isKey(vmr_cache, vmr_path)
    ud = vmr_cache(vmr_path);
    return;
end

vmr = xff(vmr_path);

voxel_size = vmr.VoxResX;
voxel_dim = vmr.DimX;
X = vmr.VMRData;
if vmr.Convention == 1
    X = flipdim(X, 3);
end

ud = struct( ...
    'filename', vmr_path, ...
    'X', X, ...
    'voxel_size', voxel_size, ...
    'voxel_dim', voxel_dim);

if ~isempty(vmr_cache)
    vmr_cache(vmr_path) = ud;
end

end
