% 
% 
% 
function func_pred = label_anatomical( sm_file, vols_, n )
    % for using fmri_data class
    addpath( genpath( '../bin/CanlabCore' ) )

    bucknerlab_path = '../data/Functional_networks/Bucknerlab_286_17_networks_plus_anatomy/resampled_mask_Buckner_r286.nii';
    bucknerlab_labels_path = '../data/Functional_networks/Bucknerlab_286_17_networks_plus_anatomy/idx_286_for_Buckner17.mat';

    % load SPM anatomical labels
    bucknerlab_labels = load( bucknerlab_labels_path );
    rnames = bucknerlab_labels.rnames;
    map_ = bucknerlab_labels.idx_286_for_Buck17.dat;

    disp('resampling to Bucknerlab atlas')
    sm_dat = fmri_data( sm_file, [], 'noverbose' );
    bucknerlab_dat = fmri_data( bucknerlab_path, [], 'noverbose' );
    sm_dat = resample_space( sm_dat, bucknerlab_dat );

    if isempty( vols_ )
        vols_ = 1:size(sm_dat.dat, 2);
    end
    sm_dat.dat = sm_dat.dat(:, vols_);
    
    disp('masking Bucknerlab atlas')
    s_ = [length(bucknerlab_dat.dat) max( bucknerlab_dat.dat )];
    bucknerlab_V_4D = zeros(s_);
    for jj = 1:max( bucknerlab_dat.dat )
        idx = find( bucknerlab_dat.dat == jj );
        bucknerlab_V_4D( idx, jj ) = 1;
    end

    disp('computing correlation')
    func_pred = cell( length( vols_ ), 1+2*n );
    corrs_ = corr( sm_dat.dat, bucknerlab_V_4D );

    for jj = 1:length( vols_ )
        func_pred{jj, 1} = vols_(jj);
        [vv, ii] = maxk( corrs_(jj, :), n );
        t1 = 2;
        for kk = 1:n
            func_pred{jj, t1} = bucknerlab_get_label( ii(kk), map_, rnames );
            func_pred{jj, t1+1} = vv(kk);
            t1 = t1 + 2;
        end
    end

    disp('done predicting functional labels')

function r = bucknerlab_get_label( val, map_, rnames )
    row_ = map_( map_(:,2) == val, : );
    switch row_( 4 )
        case 1
            r = 'subcortical';
        case 2
            r = rnames{ row_(3) };
        case 3
            r = 'basal ganglia';
        case 4
            r = 'cerebellum';
    end

