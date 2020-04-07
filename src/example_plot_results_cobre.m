clear all
tStart = tic;

addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/GroupICATv4.0b/' ) )
addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/spm12/' ) )
addpath( genpath( '../bin/MCIv4/' ) )
addpath( genpath( '../bin/CanlabCore/' ) )
addpath( genpath( '../bin/export_fig' ) )
addpath( '../bin/' )
addpath( '/data/mialab/users/salman/projects/funfc/src/' )

outpath = '../results/cobre/';
param_file = '/data/mialab/users/salman/projects/COBRE/current/results/ica_results_old/cobre1_ica_parameter_info.mat';
mask_file = '/data/mialab/users/salman/projects/COBRE/current/results/ica_results_old/cobre1Mask.img';

% load outputs
rsn_labels = readmatrix( fullfile( outpath, 'rsn_labels.csv' ) );
func_labels = table2cell( readtable( fullfile( outpath, 'functional_labels.csv' ) ) );
anat_labels = table2cell( readtable( fullfile( outpath, 'anatomical_labels.csv' ) ) );

sesInfo = load(param_file);
sesInfo = sesInfo.sesInfo;
num_IC = sesInfo.numComp;

% write output spatial maps with labels
agg_map_path = fullfile(sesInfo.outputDir, [sesInfo.aggregate_components_an3_file '.nii']);
sm_dat = fmri_data( agg_map_path, mask_file, 'noverbose' );
n_vols = size( sm_dat.dat, 2 );

for jj = 1:n_vols
    disp( ['plotting IC ' num2str(jj)] )
    % create title
    title_rsn = 'NO';
    title_anat = '';
    title_func = '';
    idx = find( [anat_labels{:,1}] == jj );
    if ( rsn_labels(jj) == 1 )
        title_rsn = 'YES'; 
        % assume top 3 correlations 
        title_anat = [strrep(anat_labels{idx,2},'_',' ') ' (' num2str(anat_labels{idx,3}) ')']; 
        title_func = [strrep(func_labels{idx,2},'_',' ') ' (' num2str(func_labels{idx,3}) ')']; 
    end
    
    title_ = ['RSN: ' title_rsn '; ANAT: ' title_anat '; FUNC: ' title_func];
    
    params = struct( ...
        'disable', 0, ...
        'data', sm_dat.dat(:, jj), ...
        'sesInfo', sesInfo, ...
        'structFile', '../bin/MCIv4/ch2better_aligned2EPI_resampled.nii', ...
        'title', title_, ...
        'savefig', 1, ...
        'outpath', fullfile( outpath, 'sm_fig' ), ...
        'outname', ['fig' num2str(jj)] );
    funfc_mciv4_save(params);
end

% plot FNC
% read FNC
fnc = readmatrix( fullfile( outpath, 'sorted_fnc.csv' ) );
sorted_idx = readmatrix( fullfile( outpath, 'sorted_IC_idx.csv' ) );
max_fnc = max( abs( fnc(:) ) );
% load module labels
[mod_names, t2, aff] = unique( func_labels(:,2) );
mod_ = accumarray(aff, 1);
% plot
figure
[~,~,C] = my_icatb_plot_FNC(fnc, [-max_fnc max_fnc], cell(1, num_IC), sorted_idx, gcf, 'Correlation', [], mod_, mod_names, 1);
saveas(gcf, fullfile(outpath, 'fnc_reordered.png'))

close all

tEnd = toc(tStart)
