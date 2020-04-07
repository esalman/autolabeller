clear all
tStart = tic;

% add paths
addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/GroupICATv4.0b/' ) )
addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/spm12/' ) )
addpath( genpath( '../bin/CanlabCore/' ) )
addpath('../bin/2019_03_03_BCT')

% fbirn
params.param_file = '/data/mialab/users/salman/projects/fBIRN/current/data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
params.outpath = '../results/fbirn/';
params.n_corr = 3;
% run the autolabeller
label_auto_main( params );

% % bsnip
% params.param_file = '/data/mialab/users/salman/projects/BSNIP/2016-11-30/analysis_spm12/ica_results/bsnip8_ica_parameter_info.mat';
% params.outpath = '../results/bsnip/';
% params.n_corr = 3;
% % run the autolabeller
% label_auto_main( params );

% % cobre
% params.param_file = '/data/mialab/users/salman/projects/COBRE/current/results/ica_results_old/cobre1_ica_parameter_info.mat';
% params.outpath = '../results/cobre/';
% params.n_corr = 3;
% % run the autolabeller
% label_auto_main( params );

close all

tEnd = toc(tStart)
