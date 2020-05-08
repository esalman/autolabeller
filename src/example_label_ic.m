clear all
tStart = tic;

% add requirements to path
addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/GroupICATv4.0b/' ) )      % GIFT toolbox
addpath( genpath( '../bin/CanlabCore/CanlabCore' ) )       % Canlab toolbox
addpath( '/trdapps/linux-x86_64/matlab/toolboxes/spm12/' )      % SPM12 toolbox
addpath( '../bin/2019_03_03_BCT' )       % Brain connectivity toolbox
addpath( '../bin/autolabeller/' )       % add the autolabeller src folder only

% GICA example with fbirn dataset
clear params;
params.param_file = '/data/mialab/users/salman/projects/fBIRN/current/data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
params.outpath = '../results/fbirn/';
params.n_corr = 3;
params.fit_method = 'mnr';
disp( 'Running the autolabeller on FBIRN dataset' )
label_auto_main( params );

% % Spatial map example with neuromark template
% clear params;
% params.sm_path = '/data/mialab/competition2019/NetworkTemplate/NetworkTemplate_High_VarNor.nii';
% params.outpath = './results/neuromark/';
% params.n_corr = 3;
% params.fit_method = 'mnr';
% disp( 'Running the autolabeller on NeuroMark dataset' )
% label_auto_main( params );

% % GICA example with cobre dataset
% clear params;
% params.param_file = '/data/mialab/users/salman/projects/COBRE/current/results/ica_results_old/cobre1_ica_parameter_info.mat';
% params.outpath = './results/cobre/';
% params.n_corr = 3;
% params.fit_method = 'mnr';
% disp( 'Running the autolabeller on COBRE dataset' )
% label_auto_main( params );

tEnd = toc(tStart)
