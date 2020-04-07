% input: path to nifti file, selected volumes and correlations with how many 
% anatomical regions to return
% output: length(vols_) x (1+2N) cell of vols_ values, anatomical region names and correlation values
function anat_pred = label_anatomical( sm_file, vols_, n )
    % for using fmri_data class
    addpath( genpath( '../bin/CanlabCore' ) )

    aal_path = '../data/Anatomical/AAL/aal.nii.gz';
    aal_label_path = '../data/Anatomical/AAL/aal.nii.txt';

    % load SPM anatomical labels
    aal_labels = readtable( aal_label_path );

    % resample
    disp('resampling to AAL atlas')
    sm_dat = fmri_data( sm_file, [], 'noverbose' );
    aal_dat = fmri_data( aal_path, [], 'noverbose' );
    sm_dat = resample_space( sm_dat, aal_dat );

    if isempty( vols_ )
        vols_ = 1:size(sm_dat.dat, 2);
    end
    sm_dat.dat = sm_dat.dat(:, vols_);
    
    disp('masking AAL atlas')
    s_ = [length(aal_dat.dat) max( aal_dat.dat )];
    aal_V_4D = zeros(s_);
    for jj = 1:max( aal_dat.dat )
        idx = find( aal_dat.dat == jj );
        aal_V_4D( idx, jj ) = 1;
    end

    disp('computing correlation')
    anat_pred = cell( length( vols_ ),  1+2*n );
    corrs_ = corr( sm_dat.dat, aal_V_4D );

    for jj = 1:length( vols_ )
        anat_pred{jj, 1} = vols_(jj);
        [vv, ii] = maxk( corrs_(jj, :), n );
        t1 = 2;
        for kk = 1:n
            anat_pred{jj, t1} = aal_labels{ aal_labels.Var1 == ii(kk), 'Var2' }{1};
            anat_pred{jj, t1+1} = vv(kk);
            t1 = t1 + 2;
        end
    end

    disp('done predicting anatomical labels')


