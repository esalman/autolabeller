clear all
tStart = tic;

addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/GroupICATv4.0b/' ) )      % GIFT toolbox
addpath( '../bin/' )

outpath = '../results/fbirn/';
param_file = '/data/mialab/users/salman/projects/fBIRN/current/data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
structFile = '../bin/MCIv4/ch2better_aligned2EPI_resampled.nii';

% load outputs
network_labels = readmatrix( fullfile( outpath, 'network_labels.csv' ) );
func_labels = readtable( fullfile( outpath, 'functional_labels.csv' ) );
func_labels = func_labels( func_labels.network==1, : );

sesInfo = load(param_file);
sesInfo = sesInfo.sesInfo;
num_IC = sesInfo.numComp;

% plot FNC
% read FNC
fnc = readmatrix( fullfile( outpath, 'sorted_fnc.csv' ) );
sorted_idx = readmatrix( fullfile( outpath, 'sorted_network_idx.csv' ) );
max_fnc = max( abs( fnc(:) ) );
% load module labels
[mod_names, t2, aff] = unique( func_labels.region_1, 'stable' );
mod_ = accumarray(aff, 1);
% plot
figure
my_icatb_plot_FNC(fnc, [-max_fnc max_fnc], cell(1, num_IC), sorted_idx, gcf, 'Correlation', [], mod_, mod_names, 1);
title('FBIRN dataset reordered FNC matrix')
set(gcf, 'color', 'w')
saveas(gcf, fullfile(outpath, 'fnc_reordered.png'))

close all

tEnd = toc(tStart)