% 
% 
% 
function func_pred = label_functional( sm_file, mask_file, threshold, networks, atlas_name, n )

    atlas = load_atlas( atlas_name );

    sm_dat = fmri_data( sm_file, mask_file, 'noverbose' );
    atlas_dat = fmri_data( atlas.path, mask_file, 'noverbose' );

    % threshold if needed
    if threshold
        sm_dat.dat( abs( sm_dat.dat ) < threshold ) = 0;
    end

    sm_dat = resample_space( sm_dat, atlas_dat );
    n_vols = size(sm_dat.dat, 2);

    disp('masking atlas')
    atlas_V_2D = convert_atlas2d( atlas.name, atlas_dat );

    disp('computing correlation')
    func_pred = cell( n_vols, 2*(n+1) );
    corrs_ = corr( sm_dat.dat, atlas_V_2D );

    % network flags
    func_pred(:, 2) = num2cell( networks );
    
    for jj = 1:n_vols
        func_pred{jj, 1} = jj;
        [vv, ii] = maxk( corrs_(jj, :), n );
        t1 = 3;
        for kk = 1:n
            func_pred{jj, t1} = get_atlas_label( ii(kk), atlas );
            func_pred{jj, t1+1} = vv(kk);
            t1 = t1 + 2;
        end
    end
    
    % create header
    headers = {'volume', 'network'};
    for kk = 1:n
        headers = [headers, {['region_' num2str(kk)] ['corr_' num2str(kk)]}];
    end

    func_pred = [headers; func_pred];

    disp('done predicting functional labels')

function ret = load_atlas( atlas_name )
    switch atlas_name
    case 'caren'
        disp('resampling to CAREN, Doucet 2019 atlas')
        ret.name = atlas_name;
        t1 = fileparts( which( 'CAREN1_SAL.nii' ) );
        t2 = dir([t1 '/*.nii']);
        ret.path = fullfile( t2(1).folder, {t2.name} );
        ret.labels = cellfun( @(x) x(8:10), {t2.name}, 'UniformOutput', false );

    case 'gordon2016'
        disp('resampling to Gordon 2016 atlas')
        ret.name = atlas_name;
        ret.path = which( 'Parcels_MNI_111.nii' );
        labels_path = which( 'Parcels.xlsx' );
    
        t1 = readtable( labels_path );
        ret.ParcelID = t1.ParcelID;
        ret.Community = t1.Community;

    otherwise
        % yeo_buckner
        disp('resampling to Bucknerlab atlas')
        ret.name = atlas_name;
        ret.path = which( 'resampled_mask_Buckner_r286.nii' );
        labels_path = which( 'idx_286_for_Buckner17.mat' );
    
        t1 = load( labels_path );
        ret.rnames = t1.rnames;
        ret.map_ = t1.idx_286_for_Buck17.dat;        
    end

function ret = convert_atlas2d( atlas_name, atlas_dat )
    switch atlas_name
    case 'caren'
        ret = atlas_dat.dat;
    otherwise
        s_ = [length(atlas_dat.dat) max( atlas_dat.dat )];
        ret = zeros(s_);
        for jj = 1:max( atlas_dat.dat )
            idx = find( atlas_dat.dat == jj );
            ret( idx, jj ) = 1;
        end
    end

function ret = get_atlas_label( val, atlas )
    switch atlas.name
    case 'caren'
        ret = atlas.labels{ val };
        
    case 'gordon2016'
        ret = atlas.Community{ find( atlas.ParcelID == val ) };
        
    otherwise
        % yeo_buckner
        row_ = atlas.map_( atlas.map_(:,2) == val, : );
        switch row_( 4 )
            case 1
                ret = 'subcortical';
            case 2
                ret = atlas.rnames{ row_(3) };
            case 3
                ret = 'basal ganglia';
            case 4
                ret = 'cerebellum';
        end       
    end
    
    

