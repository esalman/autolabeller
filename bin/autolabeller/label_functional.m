% 
% 
% 
function func_pred = label_anatomical( sm_file, networks, n )
    % for using fmri_data class
    addpath( genpath( '../bin/CanlabCore' ) )

    bucknerlab_path = which( 'resampled_mask_Buckner_r286.nii' );
    bucknerlab_labels_path = which( 'idx_286_for_Buckner17.mat' );

    % load SPM anatomical labels
    bucknerlab_labels = load( bucknerlab_labels_path );
    rnames = bucknerlab_labels.rnames;
    map_ = bucknerlab_labels.idx_286_for_Buck17.dat;

    disp('resampling to Bucknerlab atlas')
    sm_dat = fmri_data( sm_file, [], 'noverbose' );
    bucknerlab_dat = fmri_data( bucknerlab_path, [], 'noverbose' );
    sm_dat = resample_space( sm_dat, bucknerlab_dat );
    n_vols = size(sm_dat.dat, 2);

    disp('masking Bucknerlab atlas')
    s_ = [length(bucknerlab_dat.dat) max( bucknerlab_dat.dat )];
    bucknerlab_V_4D = zeros(s_);
    for jj = 1:max( bucknerlab_dat.dat )
        idx = find( bucknerlab_dat.dat == jj );
        bucknerlab_V_4D( idx, jj ) = 1;
    end

    disp('computing correlation')
    func_pred = cell( n_vols, 2*(n+1) );
    corrs_ = corr( sm_dat.dat, bucknerlab_V_4D );

    % network flags
    func_pred(:, 2) = networks;
    
    headers = {'volume', 'network'};
    header_flag = 0;
    for jj = 1:n_vols
        func_pred{jj, 1} = jj;
        [vv, ii] = maxk( corrs_(jj, :), n );
        t1 = 3;
        for kk = 1:n
            func_pred{jj, t1} = bucknerlab_get_label( ii(kk), map_, rnames );
            func_pred{jj, t1+1} = vv(kk);
            t1 = t1 + 2;
            if ~header_flag
                headers = [headers, {['region_' num2str(kk)] ['corr_' num2str(kk)]}];
            end
        end
        header_flag = 1;
    end
    
    func_pred = [headers; func_pred];

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

