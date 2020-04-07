function spm_anat = load_spm_anatomy()
    addpath( '../data/Anatomical/Eickhoff_SPManatomy_22c' )
    addpath( genpath( '../bin/CanlabCore' ) )

    [spm_anatomy_regions, region_names_cell] = canlab_load_spmanatomy_regions()

