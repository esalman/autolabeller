% Autolabeller function
% Inputs: 
%   params.param_file: GICA session parameter file. Make sure to post process GICA results by running HTML report
%   params.outpath: output folder
%   params.n_corr: top X correlations with knowmn anatomical/functional regions
% Outputs: the following files are written into params.outpath folder:
%   rsn_labels.csv: RSN labels vector (0=artifact, 1=RSN)
%   anatomical_labels.csv: AAL anatomical region with highest correlations
%   functional_labels.csv: Buckner functional parcellations with highest correlations
%   sorted_IC_idx.csv: sorted IC index
%   sorted_fnc.csv: sorted FNC matrix

function func_pred = label_auto_main( params )
    % create output directory
    mkdir( fullfile( params.outpath, 'sm_fig', 'nii' ) )

    % load ICA session info
    sesInfo = load( params.param_file );
    sesInfo = sesInfo.sesInfo;
    % load GICA post_process result 
    post_process = load( fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_postprocess_results.mat']) );
    % IC aggregate map path
    sm_path = fullfile(sesInfo.outputDir, [sesInfo.aggregate_components_an3_file '.nii']);

    % predict RSN labels (0=artifact, 1=RSN)
    rsn_labels = label_rsn( sesInfo );

    % select rsn volumes to label as anatomical/functional
    rsn_idx = find( rsn_labels == 1 );

    % predict anatomical labels
    anat_labels = label_anatomical( sm_path, rsn_idx, params.n_corr);

    % predict functional labels
    func_labels = label_functional( sm_path, rsn_idx, params.n_corr);

    % sort FNC
    % load unsorted FNC
    fnc = squeeze( mean( post_process.fnc_corrs_all ) );
    [sorted_idx, rsn_fnc, order_] = sort_fnc( fnc, func_labels(:,1:2) );

    % sort the other labels
    anat_labels = anat_labels( order_, : );
    func_labels = func_labels( order_, : );

    % write output
    writematrix( rsn_labels, fullfile(params.outpath, 'rsn_labels.csv') )
    writecell( anat_labels, fullfile(params.outpath, 'anatomical_labels.csv') )
    writecell( func_labels, fullfile(params.outpath, 'functional_labels.csv') )
    writematrix( sorted_idx, fullfile(params.outpath, 'sorted_IC_idx.csv') )
    writematrix( rsn_fnc, fullfile(params.outpath, 'sorted_fnc.csv') )

    

