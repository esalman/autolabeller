function [feat_, labels_, sm_path, fnc] = load_fbirn_features()
    % input ICA parameter file
    param_file = '/data/mialab/users/salman/projects/BSNIP/2016-11-30/analysis_spm12/ica_results/bsnip8_ica_parameter_info.mat';
    ic_meta_path = '/data/mialab/users/salman/projects/BSNIP/2016-11-30/analysis_spm12/code/bsnip8_rsn.mat';

    % load ICA session info
    sesInfo = load(param_file);
    sesInfo = sesInfo.sesInfo;

    % load labels
    ic_meta = load( ic_meta_path );
    numComp = sesInfo.numComp;

    % get falff and dynrange from ica postprocess file
    t1 = load( fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_postprocess_results.mat']) );

    % make an output file of noise features (and labels)
    out_ = [t1.fALFF, t1.dynamic_range, zeros(numComp, 1)];
    for ii = 1:size(ic_meta.ic_sel, 1)
        out_(ic_meta.ic_sel(ii), 3) = 1;
    end

    feat_ = zscore( out_(:,1:2) );
    % rsn labels, 0=noise, 1=RSN
    labels_ = logical( out_(:,3) );

    sm_path = fullfile(sesInfo.outputDir, [sesInfo.aggregate_components_an3_file '.nii']);

    fnc = squeeze( mean( t1.fnc_corrs_all ) );
    
