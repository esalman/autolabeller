tic
clear all

% add paths
addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/GroupICATv4.0b/' ) )
addpath( genpath( '/trdapps/linux-x86_64/matlab/toolboxes/spm12/' ) )

disp('load fbirn features')
[feat_fbirn, labels_fbirn, sm_fbirn] = load_fbirn_features();
predicted_labels = label_rsn( feat_fbirn );
f1 = score_( logical( labels_fbirn ), predicted_labels )

% disp('load bsnip features')
% [feat_bsnip, labels_bsnip] = load_bsnip_features();
% predicted_labels = label_rsn( feat_bsnip );
% f1 = score_( logical( labels_bsnip ), predicted_labels )

% disp('load cobre features')
% [feat_cobre, labels_cobre] = load_cobre_features();
% predicted_labels = label_rsn( feat_cobre );
% f1 = score_( logical( labels_cobre ), predicted_labels )

label_anatomical( sm_fbirn )

toc
