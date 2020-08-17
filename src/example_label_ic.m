clear all
tStart = tic;

% add requirements to path
addpath( genpath( '../bin/GroupICATv4.0b/' ) )      % GIFT toolbox
addpath( genpath( '../bin/CanlabCore/CanlabCore' ) )       % Canlab toolbox
addpath( '/trdapps/linux-x86_64/matlab/toolboxes/spm12/' )      % SPM12 toolbox
addpath( '../bin/2019_03_03_BCT' )       % Brain connectivity toolbox
addpath( '../bin/autolabeller/' )       % add the autolabeller src folder only

% GICA example with fbirn dataset
clear params;
params.param_file = '/data/mialab/users/salman/projects/fBIRN/current/data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
params.outpath = '../results/fbirn_nc_train_sub/';
params.fit_method = 'mnr';
params.n_corr = 3;
params.skip_noise = 0;
params.skip_anatomical = 0;
params.skip_functional = 0;
params.noise_training_set = 'fbirn_sub';
params.anatomical_atlas = 'aal';
params.threshold = 3;
params.functional_atlas = 'yeo_buckner';
% params.functional_atlas = 'gordon2016';
% params.functional_atlas = 'caren';
disp( 'Running the autolabeller on FBIRN dataset' )
label_auto_main( params );

% Spatial map example with neuromark template
clear params;
params.sm_path = '/data/mialab/competition2019/NetworkTemplate/NetworkTemplate_High_VarNor.nii';
params.mask_path = '/data/mialab/competition2019/NetworkTemplate/Mask.img';
params.outpath = '../results/neuromark_nc_train_sub/';
params.fit_method = 'mnr';
params.n_corr = 3;
params.skip_noise = 0;
params.skip_anatomical = 0;
params.skip_functional = 0;
params.noise_training_set = 'fbirn_sub';
params.anatomical_atlas = 'aal';
params.threshold = 3;
params.functional_atlas = 'yeo_buckner';
% params.functional_atlas = 'gordon2016';
% params.functional_atlas = 'caren';
disp( 'Running the autolabeller on NeuroMark dataset' )
label_auto_main( params );

% GICA example with cobre dataset
clear params;
params.param_file = '/data/mialab/users/salman/projects/COBRE/current/results/ica_results_old/cobre1_ica_parameter_info.mat';
params.outpath = '../results/cobre_nc_train_sub/';
params.n_corr = 3;
params.fit_method = 'mnr';
params.skip_noise = 0;
params.skip_anatomical = 0;
params.skip_functional = 0;
params.noise_training_set = 'fbirn_sub';
params.anatomical_atlas = 'aal';
params.threshold = 3;
params.functional_atlas = 'yeo_buckner';
% params.functional_atlas = 'gordon2016';
% params.functional_atlas = 'caren';
disp( 'Running the autolabeller on COBRE dataset' )
label_auto_main( params );

tEnd = toc(tStart)
