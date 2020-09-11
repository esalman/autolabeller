% input: noisecloud training spatial map and timecourses
% output: 1 (network) or 0 (artifact)
function network_pred = label_network_nc( outpath, sesInfo, sm_path, noise_training_set, threshold )
    disp('predicting networks')

    if isa( noise_training_set, 'struct' )
        training_opts.sm = noise_training_set.sm; % Spatial maps
        training_opts.tc = noise_training_set.tc; % Timecourses
        % noise is lablled as 1 in noisecloud
        ic_meta = double( ~noise_training_set.class_labels );
    else
        switch noise_training_set
        case 'neuromark'
            training_opts.sm = which( 'NetworkTemplate_High_VarNor.nii' ); % Spatial maps
            training_opts.tc = []; % Timecourses
            % noise is lablled as 1 in noisecloud
            ic_meta = ones( 1, 100 );
            t1 = [2,3,4,5,7,9,11,12,13,15,16,17,18,20,21,23,26,27,28,32,33,37,38,40,43,44,45,46,51,53,54,55,56,61,63,66,67,68,69,70,71,72,73,77,81,84,88,91,93,94,95,96,98,99];
            ic_meta( t1 ) = 0;
        case 'debug'
            training_opts.sm = '/data/mialab/users/salman/projects/autolabeler/current/results/fbirn_trained_by_neuromark/sm11.nii'; % Spatial maps
            training_opts.tc = []; % Timecourses
            % noise is lablled as 1 in noisecloud
            ic_meta = ones( 1, 11 );
            t1 = [1 2 5 6 7 9 10];
            ic_meta( t1 ) = 0;
        case 'fbirn_sub'
            training_opts.sm = '/data/mialab/users/salman/projects/autolabeler/current/results/fbirn_sub_nc_data/nc_training_sample_sm.nii'; % Spatial maps
            training_opts.tc = '/data/mialab/users/salman/projects/autolabeler/current/results/fbirn_sub_nc_data/nc_training_sample_tc.nii'; % Timecourses
            % noise is lablled as 1 in noisecloud
            t1 = csvread( '/data/mialab/users/salman/projects/autolabeler/current/results/fbirn_sub_nc_data/nc_training_labels.csv' );
            ic_meta = double( ~t1 );
        otherwise
            % use fBIRN for training
            training_opts.sm = which('fbirnp3_rest_mean_component_ica_s_all_.nii'); % Spatial maps
            training_opts.tc = which('fbirnp3_rest_mean_timecourses_ica_s_all_.nii'); % Timecourses
            ic_meta_path = which( 'fBIRN_rsn.csv' );
            t1 = readtable( ic_meta_path );
            t1 = t1.IC;
            % noise is lablled as 1 in noisecloud
            ic_meta = ones( 1, 100 );
            ic_meta( t1 ) = 0;
        end
    end

    % other training params
    training_opts.regress_cov = [];
    training_opts.TR = 2;
    training_opts.class_labels = ic_meta; % Labels 
    
    if ~isempty( sesInfo )
        testing_opts.sm = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_mean_component_ica_s_all_.nii']);
        if ~isempty( training_opts.tc )
            testing_opts.tc = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_mean_timecourses_ica_s_all_.nii']);
        else
            testing_opts.tc = [];
        end
    else
        testing_opts.sm = sm_path;
        training_opts.tc = [];
        testing_opts.tc = [];
    end

    testing_opts.regress_cov = [];
    testing_opts.TR = 2;

    [network_pred, fit_mdl, result_nc_classifier] = noisecloud_run(training_opts, testing_opts, 'convert_to_z', 'yes', 'outDir', outpath, 'coregister', 1, ...
        'iterations', 1, 'cross_validation', 10, 'threshold', threshold);
    
    % flip back because noise is lablled as 1 in noisecloud
    network_pred = ~network_pred;

    disp('done predicting network')
end

