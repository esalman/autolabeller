% input: fBIRN GICA session parameter, IC meta file (hardcoded)
% output: 47x2 fBIRN ICA fALFF and dynamic ranges; 100x1 fBIRN RSN label vector
function [feat_, labels_] = load_fbirn_true_labels()
    % input ICA parameter file
    param_file = '/data/mialab/users/salman/projects/fBIRN/current/data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
    ic_meta_path = '../data/fBIRN/fBIRN_rsn.csv';
    structFile = '../bin/MCIv4/ch2better_aligned2EPI_resampled.nii';

    % load ICA session info
    sesInfo = load(param_file);
    sesInfo = sesInfo.sesInfo;

    % load labels
    ic_meta = readtable( ic_meta_path );
    numComp = sesInfo.numComp;

    % load ICA postptocess file
    post_process = load( fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_postprocess_results.mat']) );

    %% correlation w/ brain masks
    % resample everything to the same space
    struct_dat = fmri_data(structFile, [], 'noverbose');

    % load IC aggregate map
    sm_path = fullfile(sesInfo.outputDir, [sesInfo.aggregate_components_an3_file '.nii']);
    sm_dat = fmri_data( sm_path, [], 'noverbose' );
    sm_dat = resample_space( sm_dat, struct_dat );
    
    % brain mask
    mask_dat = fmri_data('../bin/MCIv4/mask_ch2better_aligned2EPI.nii', [], 'noverbose');
    mask_dat = resample_space(mask_dat, struct_dat);
    corr_brainmask = corr(sm_dat.dat, mask_dat.dat);

    % white matter mask
    mask_dat = fmri_data('../bin/REST_V1.8_masks/WhiteMask_09_61x73x61.hdr', [], 'noverbose');
    mask_dat = resample_space(mask_dat, struct_dat);
    corr_whitemask = corr(sm_dat.dat, mask_dat.dat);

    % csf mask
    mask_dat = fmri_data('../bin/REST_V1.8_masks/CsfMask_07_61x73x61.hdr', [], 'noverbose');
    mask_dat = resample_space(mask_dat, struct_dat);
    corr_csfmask = corr(sm_dat.dat, mask_dat.dat);

    feat_ = zscore( [post_process.fALFF post_process.dynamic_range corr_brainmask corr_whitemask corr_csfmask] );

    % make an output file of noise features (and labels)
    out_ = zeros(numComp, 1);
    for ii = 1:size(ic_meta, 1)
        out_( ic_meta{ii, 'IC'} ) = 1;
    end
        
    % rsn labels, 0=noise, 1=RSN
    labels_ = logical( out_ );

    