% input: fALFF and dynamic range of ICA timecourses
% output: 1 (RSN) or 0 (artifact)
function rsn_pred = label_rsn( sesInfo )
    disp('predicting RSN')
    structFile = '../bin/MCIv4/ch2better_aligned2EPI_resampled.nii';

    % load fbirn features
    [feat_fbirn, labels_fbirn] = load_fbirn_true_labels();

    % fit fbirn model
    [B, dev, stats] = mnrfit(feat_fbirn, categorical( labels_fbirn ));

    % load GICA post_process result 
    post_process = load( fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_postprocess_results.mat']) );
    % load fALFF and dynamic range from post_process output
    fALFF = post_process.fALFF;
    dyn_range = post_process.dynamic_range;

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
    
    % create noise features
    feat_ = [fALFF dyn_range corr_brainmask corr_whitemask corr_csfmask];
    feat_ = zscore( feat_ );

    % predict fbirn labels
    p_hat = mnrval(B, feat_);
    rsn_pred = p_hat(:,1) < p_hat(:,2);

    disp('done predicting RSN')
