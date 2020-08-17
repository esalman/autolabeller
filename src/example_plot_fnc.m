clear all
tStart = tic;

addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/GroupICATv4.0b/' ) )      % GIFT toolbox
addpath( '../bin/' )

outpath = '../results/fbirn_nc_train_sub/';
param_file = '/data/mialab/users/salman/projects/fBIRN/current/data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
functional_atlas = 'yeo_buckner';
% functional_atlas = 'gordon2016';
% functional_atlas = 'caren';

% outpath = '../results/cobre_nc_train_sub/';
% param_file = '/data/mialab/users/salman/projects/COBRE/current/results/ica_results_old/cobre1_ica_parameter_info.mat';
% functional_atlas = 'yeo_buckner';
% % functional_atlas = 'gordon2016';
% % functional_atlas = 'caren';

% load outputs
func_labels = readtable( fullfile( outpath, ['functional_labels_' functional_atlas '.csv'] ) );
func_labels = func_labels( func_labels.network==1, : );

sesInfo = load(param_file);
sesInfo = sesInfo.sesInfo;
num_IC = sesInfo.numComp;

% plot FNC
% read FNC
fnc = readmatrix( fullfile( outpath, ['sorted_fnc_' functional_atlas '.csv'] ) );
sorted_idx = readmatrix( fullfile( outpath, ['sorted_network_idx_' functional_atlas '.csv'] ) );
max_fnc = max( abs( fnc(:) ) );
% load module labels
[mod_names, t2, aff] = unique( func_labels.region_1, 'stable' );
mod_ = accumarray(aff, 1);
% plot
figure
my_icatb_plot_FNC(fnc, [-max_fnc max_fnc], cell(1, num_IC), sorted_idx, gcf, 'Correlation', [], mod_, mod_names, 1);
title({'(B) FBIRN dataset reordered FNC matrix', ['Functional parcellation: ' strrep(functional_atlas, '_', '-')]}, 'fontname', 'Jost')
set(gcf, 'color', 'w')
export_fig(fullfile(outpath, ['fnc_reordered_' functional_atlas '.png']), '-r150', '-p0.01')

% plot unsorted FNC for comparison
post_process = load( fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix '_postprocess_results.mat']) );
fnc_unsorted = squeeze( mean( post_process.fnc_corrs_all ) );

func_labels_us = sortrows( func_labels(:,[1, 3]), 1 );
[t1, idx_dumb] = sortrows( func_labels_us, 2 );
[mod_names, t2, aff] = unique( t1(:,2), 'stable' );
mod_ = accumarray(aff, 1);
sorted_idx = func_labels_us(idx_dumb,1).volume;
fnc_unsorted = fnc_unsorted( sorted_idx, sorted_idx );

figure
my_icatb_plot_FNC(fnc_unsorted, [-max_fnc max_fnc], cell(1, num_IC), sorted_idx, gcf, 'Correlation', [], mod_, mod_names.region_1, 1);
title({'(A) FBIRN dataset unsorted FNC matrix', ['Functional parcellation: ' strrep(functional_atlas, '_', '-')]}, 'fontname', 'Jost')
set(gcf, 'color', 'w')
export_fig(fullfile(outpath, ['fnc_unsorted_' functional_atlas '.png']), '-r150', '-p0.01')

close all

tEnd = toc(tStart)