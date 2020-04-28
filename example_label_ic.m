clear all
tStart = tic;

% add requirements to path
addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/GroupICATv4.0b/' ) )      % GIFT toolbox
addpath( genpath( '/data/mialab/users/salman/projects/autolabeler/20200427_current/bin/CanlabCore/CanlabCore' ) )       % Canlab toolbox
addpath( '/trdapps/linux-x86_64/matlab/toolboxes/spm12/' )      % SPM12 toolbox
addpath('/data/mialab/users/salman/projects/autolabeler/20200427_current/bin/2019_03_03_BCT')       % Brain connectivity toolbox
addpath('./src/')       % add the autolabeller src folder only

% GICA example with fbirn dataset
clear params;
params.param_file = '/data/mialab/users/salman/projects/fBIRN/current/data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
params.outpath = './results/fbirn/';
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

close all

tEnd = toc(tStart)
