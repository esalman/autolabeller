% sorts FNC matrix
% input: unsorted FNC matrix, corresponding IC# and functional domain label
% 
function [sorted_idx_reordered, reordered_matrix, order_] = sort_fnc( fnc, labels )
    addpath('../bin/2019_03_03_BCT')

    % sorted domain labels
    [t1, idx_dumb] = sortrows( labels, 2 );
    [mod_names, t2, aff] = unique( t1(:,2) );
    mod_ = accumarray(aff, 1);
    sorted_idx = cell2mat( labels(idx_dumb,1) );
    rsn_fnc = fnc( sorted_idx, sorted_idx );
    
    % reorder modules
    node_order = reorder_mod( rsn_fnc, aff );

    % sorted output index
    sorted_idx_reordered = sorted_idx( node_order );
    reordered_matrix = fnc( sorted_idx_reordered, sorted_idx_reordered );
    order_ = idx_dumb( node_order );

