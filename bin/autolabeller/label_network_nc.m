% input: noisecloud training spatial map and timecourses
% output: 1 (network) or 0 (artifact)
function network_pred = label_network( outpath, sesInfo, sm_path )
    disp('predicting networks')

    ic_meta_path = which( 'fBIRN_rsn.csv' );
    t1 = readtable( ic_meta_path );
    t1 = t1.IC;
    % noise is lablled as 1 in noisecloud
    ic_meta = ones( 1, 100 );
    ic_meta( t1 ) = 0;

    % ic_meta = [0 0 1 1 0 0 0 1 0 0];

    training_opts.sm = which('fbirnp3_rest_mean_component_ica_s_all_.nii'); % Spatial maps
    training_opts.tc = which('fbirnp3_rest_mean_timecourses_ica_s_all_.nii'); % Timecourses
    % training_opts.sm = '/data/mialab/users/salman/projects/autolabeler/current/results/fbirn/sm5.nii';
    % training_opts.tc = [];
    training_opts.regress_cov = [];
    training_opts.TR = 2;
    training_opts.class_labels = ic_meta; % Labels 
    
    if ~isempty( sesInfo )
        testing_opts.sm = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_mean_component_ica_s_all_.nii']);
        testing_opts.tc = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_mean_timecourses_ica_s_all_.nii']);
    else
        testing_opts.sm = sm_path;
        testing_opts.tc = [];
    end

    testing_opts.regress_cov = [];
    testing_opts.TR = 2;

    [network_pred, fit_mdl, result_nc_classifier] = noisecloud_run(training_opts, testing_opts, 'convert_to_z', 'yes', 'outDir', outpath, 'coregister', 1, ...
        'iterations', 1, 'cross_validation', 10);
    
    network_pred = ~network_pred;

    disp('done predicting network')
end

