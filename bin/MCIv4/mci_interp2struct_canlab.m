function [fname, Cfname] = mci_interp2struct_canlab(MAPfile, volumes, structFile, out_path)
% mci_interp2struct() - Interpolates the functional data to the structural (underlay) dimensions.
%  
% Usage: >> [fname, Cfname] = mci_interp2struct(MAPfile, volumes, structFile, out_path);
%   
% INPUTS:
% MAPfile    = Functional data filename, should be .nii 
% volumes    = volumes of MAPfile to interpolate (typically the components of interest)
% structFile = Structural data filename, also .nii 
% out_path   = path to save interpolated files
%
% OUTPUTS:
% fname      = filenames of the interpolated maps.  Same name as input file with an 'i' prefix.
% Cfname     = filename of the interpolated map coordinates.
%
% See also: mci_makeimage()

[dpath, dname, dext] = fileparts(MAPfile);

if nargin < 4
    out_path = dpath;
end
       
%% load in the structural info
[~, structHInfo, XYZ] = icatb_read_data(structFile);
XYZ = reshape(XYZ,[3,structHInfo.DIM]);

%% interpolate
test_dat = fmri_data(MAPfile);
struct_dat = fmri_data(structFile);
Fimages = resample_space(test_dat, struct_dat);
le_image = zeros(Fimages.volInfo.dim);
le_image( Fimages.volInfo.wh_inmask ) = Fimages.dat;

%% multiply w/ brain masks
% brain mask
mask_dat = fmri_data('../bin/MCIv4/mask_ch2better_aligned2EPI.nii');
mask_dat = resample_space(mask_dat, struct_dat);
mask_image = zeros(mask_dat.volInfo.dim);
mask_image( mask_dat.volInfo.wh_inmask ) = mask_dat.dat;
le_image = le_image.* mask_image;

% white matter mask
mask_dat = fmri_data('../bin/REST_V1.8_masks/WhiteMask_09_61x73x61.hdr');
mask_dat.dat = ~mask_dat.dat;
mask_dat = resample_space(mask_dat, struct_dat);
mask_image = zeros(mask_dat.volInfo.dim);
mask_image( mask_dat.volInfo.wh_inmask ) = mask_dat.dat;
le_image = le_image.* mask_image;

% csf mask
mask_dat = fmri_data('../bin/REST_V1.8_masks/CsfMask_07_61x73x61.hdr');
mask_dat.dat = ~mask_dat.dat;
mask_dat = resample_space(mask_dat, struct_dat);
mask_image = zeros(mask_dat.volInfo.dim);
mask_image( mask_dat.volInfo.wh_inmask ) = mask_dat.dat;
% wh_image( wh_image < 1 ) = 0;
le_image = le_image.* mask_image;

%% Save the coordinates in .mat format
C = mci_simplify_coords(XYZ);
Cfname = fullfile(out_path, ['i' dname '_coords.mat']);
fprintf('Saving interpolated coordinates to %s...\n', Cfname)
save(Cfname, 'C');

%% Save the interpolated data in nifti format
fname = fullfile(out_path, ['i' dname '.nii']);
fprintf('Saving interpolated data to %s...\n\t new dimensions [%d x %d x %d]...', fname, size(Fimages,1), size(Fimages,2), size(Fimages,3))
mci_create_4DNiftifile(fname, le_image, structHInfo.V.mat)
fprintf('done.\n')

