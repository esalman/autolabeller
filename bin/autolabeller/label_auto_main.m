% Autolabeller function
% Inputs: 
%   params.param_file: GICA session parameter file. Make sure to post process GICA results by running HTML report
%   params.sm_path: if you want to label a simple nifti volume instead of GICA result, specify this instead
%   params.outpath: output folder
%   params.n_corr: top X correlations with knowmn anatomical/functional regions. Recommended value is 3
%   params.fit_method: method used to fit training data for artifact detection. Recommended value is 'mnr' (multinomial logistic regression)
% Outputs: the following files are written into params.outpath folder:
%   network_labels.csv: network labels vector (0=artifact, 1=network) and probability that the component/spatial map is a network
%   anatomical_labels.csv: AAL anatomical region with highest correlations
%   functional_labels.csv: Buckner functional parcellations with highest correlations
%   sorted_IC_idx.csv: sorted IC index
%   sorted_fnc.csv: sorted FNC matrix

function label_auto_main( params )
    % add paths
    src_dir = fileparts( which('label_auto_main') );
    data_dir = fullfile( src_dir, 'data' );
    bin_dir = fullfile( src_dir, 'bin' );
    addpath( genpath( data_dir ) )
    addpath( genpath( bin_dir ) )

    % create output directory
    if ~exist( params.outpath, 'dir' )
        mkdir( fullfile( params.outpath, 'nc' ) )
    end

    % todo sanitize input

    if isfield( params, 'param_file' ) && ~isempty( params.param_file )
        % load ICA session info
        sesInfo = load( params.param_file );
        sesInfo = sesInfo.sesInfo;
        % load GICA post_process result 
        post_process = load( fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_postprocess_results.mat']) );
        % IC aggregate map path
        sm_path = fullfile(sesInfo.outputDir, [sesInfo.aggregate_components_an3_file '.nii']);
        flag_sort_fnc = 1;
    else
        sesInfo = [];
        sm_path = params.sm_path;
        flag_sort_fnc = 0;
    end

    % predict network labels (0=artifact, 1=network)
    network_labels = label_network( sesInfo, sm_path, params.fit_method );
    % network_labels = label_network_nc( fullfile( params.outpath, 'nc' ), sesInfo, sm_path );

    % select network volumes to label as anatomical/functional
    network_idx = network_labels(2:end,1);

    % predict anatomical labels
    anat_labels = label_anatomical( sm_path, network_idx, params.n_corr);

    % predict functional labels
    func_labels = label_functional( sm_path, network_idx, params.n_corr);

    % sort FNC
    if flag_sort_fnc
        % load unsorted FNC
        fnc = squeeze( mean( post_process.fnc_corrs_all ) );
        [sorted_idx, network_fnc, order_] = sort_fnc( fnc, func_labels(2:end,1:3) );

        % sort the other labels
        anat_labels(2:end, :) = anat_labels( order_+1, : );
        func_labels(2:end, :) = func_labels( order_+1, : );
    end

    % write output
    writecell( network_labels, fullfile(params.outpath, 'network_labels.csv') )
    writecell( anat_labels, fullfile(params.outpath, 'anatomical_labels.csv') )
    writecell( func_labels, fullfile(params.outpath, 'functional_labels.csv') )
    if flag_sort_fnc
        writematrix( sorted_idx, fullfile(params.outpath, 'sorted_network_idx.csv') )
        writematrix( network_fnc, fullfile(params.outpath, 'sorted_fnc.csv') )
    end

    

