% input: noisecloud training spatial map and timecourses
% output: 1 (network) or 0 (artifact)
function network_pred = label_network( outpath, sesInfo, sm_path )
    disp('predicting networks')

    ic_meta_path = which( 'fBIRN_rsn.csv' );
    ic_meta = readtable( ic_meta_path );
    ic_meta = ic_meta.IC;

    training_opts.sm = which('fbirnp3_rest_mean_component_ica_s_all_.nii'); % Spatial maps
    training_opts.tc = which('fbirnp3_rest_mean_timecourses_ica_s_all_.nii'); % Timecourses
    training_opts.regress_cov = [];
    training_opts.TR = 2;
    training_opts.class_labels = ic_meta; % Labels 
    
    if ~isempty( sesInfo )
        testing_opts.sm = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_mean_component_ica_s_all_.nii']);
        testing_opts.tc = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_mean_timecourses_ica_s_all_.nii']);
    else
        testing_opts.sm = sm_path;
    end

    testing_opts.regress_cov = [];
    testing_opts.TR = 2;

    % set NOISE_ATLAS_DIRS
    t1 = which( 'raal2mni152.nii' );
    NOISE_ATLAS_DIRS = fileparts( t1 );
    
    [class_labels, fit_mdl, result_nc_classifier] = noisecloud_run(training_opts, testing_opts, 'convert_to_z', 'yes', 'outDir', outpath, 'coregister', 0, ...
        'iterations', 1, 'cross_validation', 10);
    
    disp('done predicting network')
end

function [feat_, headers] = get_training_features( feat_fbirn, sesInfo )
    if ~isempty( sesInfo )
        % fit fbirn model with all features
        feat_ = feat_fbirn;
        headers = {'network', 'probability', 'fALFF', 'dynamic_range', 'brain_corr', 'wm_corr', 'csf_corr'};
    else
        % fit fbirn model with only brain mask corr features
        feat_ =  feat_fbirn( :, 3:5 );
        headers = {'network', 'probability', 'brain_corr', 'wm_corr', 'csf_corr'};
    end
end

function feat_ = get_testing_features( mask_corrs, sesInfo )
    if ~isempty( sesInfo )
        % get all features
        % load GICA post_process result 
        post_process = load( fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_postprocess_results.mat']) );
        % load fALFF and dynamic range from post_process output
        fALFF = post_process.fALFF;
        dyn_range = post_process.dynamic_range;

        % create noise features
        feat_ = [fALFF dyn_range mask_corrs];
        feat_ = zscore( feat_ );
    else
        % get only brain mask corr features
        feat_ = zscore( mask_corrs );
    end
end

function mdl_ = get_trained_model( feat_, labels_, fit_method )
    labels_ = categorical( labels_ );
    switch fit_method
        case 'mnr'
            disp('train using mnr')
            [mdl_, dev, stats] = mnrfit( feat_, categorical( labels_ ) );
        case 'svm'  % does not work very well, needs tuning
            disp('train using svm')
            mdl_ = fitcsvm( feat_, categorical( labels_ ) );
    end
end

function network_pred = fit_test_data( feat_, model_, fit_method )
    feat_ = zscore( feat_ );
    switch fit_method
        case 'mnr'
            disp('predict using mnr')
            p_hat = mnrval(model_, feat_);
            network_pred = p_hat(:,1) < p_hat(:,2);
            network_pred = [network_pred, p_hat(:,2)];
        case 'svm'
            disp('predict using svm')
            network_pred = predict(model_, feat_);
            network_pred = double( flip( network_pred ) ) - 1;
    end
end

function corrs_ = get_mask_corrs( sm_path )
    structFile = which( 'ch2better_aligned2EPI_resampled.nii' );
    
    %% correlation w/ brain masks
    % resample everything to the same space
    struct_dat = fmri_data(structFile, [], 'noverbose');

    % load IC aggregate map
    sm_dat = fmri_data( sm_path, [], 'noverbose' );
    sm_dat = resample_space( sm_dat, struct_dat );

    % brain mask
    mask_dat = fmri_data( which('mask_ch2better_aligned2EPI.nii'), [], 'noverbose');
    mask_dat = resample_space(mask_dat, struct_dat);
    corr_brainmask = corr(sm_dat.dat, mask_dat.dat);

    % white matter mask
    mask_dat = fmri_data( which('WhiteMask_09_61x73x61.hdr'), [], 'noverbose');
    mask_dat = resample_space(mask_dat, struct_dat);
    corr_whitemask = corr(sm_dat.dat, mask_dat.dat);

    % csf mask
    mask_dat = fmri_data( which('CsfMask_07_61x73x61.hdr'), [], 'noverbose');
    mask_dat = resample_space(mask_dat, struct_dat);
    corr_csfmask = corr(sm_dat.dat, mask_dat.dat);

    corrs_ = [corr_brainmask corr_whitemask corr_csfmask];
end
