# Autolabeller

This tool can automatically generate anatomical and functional labels of spatial maps of brain activity.

## Prerequisites

Autolabeller is written in Matlab™ and requires several Matlab toolboxes to run. Please download the following toolboxes and add to your Matlab path.

- [GIFT](https://github.com/trendscenter/gift)
- [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
- [CanlabCore](https://github.com/canlab/CanlabCore)
- [BCT Toolbox](https://sites.google.com/site/bctnet/) (March 2019 release)

## Using the autolabeller

Example code can be found in `example_label_ic.m`. Note that it requires around 4GB of RAM to run.

    % add requirements to path
    addpath( genpath( './bin/GroupICATv4.0b/' ) )      % GIFT toolbox
    addpath( genpath( './bin/CanlabCore/CanlabCore' ) )       % Canlab toolbox
    addpath( './bin/spm12/' )      % SPM12 toolbox
    addpath('./bin/2019_03_03_BCT')       % Brain connectivity toolbox
    addpath('./src/')       % add the autolabeller src folder only

    % GICA example with fbirn dataset
    clear params;
    params.param_file = './data/ICAresults_C100_fbirn/fbirnp3_rest_ica_parameter_info.mat';
    params.outpath = './results/fbirn/';
    params.n_corr = 3;
    params.fit_method = 'mnr';
    disp( 'Running the autolabeller on FBIRN dataset' )
    label_auto_main( params );

    % Spatial map example with neuromark template
    clear params;
    params.sm_path = './data/NetworkTemplate/NetworkTemplate_High_VarNor.nii';
    params.outpath = './results/neuromark/';
    params.n_corr = 3;
    params.fit_method = 'mnr';
    disp( 'Running the autolabeller on NeuroMark dataset' )
    label_auto_main( params );

### Visualization

An optional FNC visualization script is provided (`example_plot_results.m`).

## Result

![fbirn/fnc_reordered](results/fbirn/fnc_reordered.png)
