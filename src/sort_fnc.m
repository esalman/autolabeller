% sorts FNC matrix
% input: unsorted FNC matrix, corresponding IC# and functional domain label
% 
function [rsn_idx_reordered, reordered_matrix, order_] = sort_fnc( fnc, labels )
    addpath('../bin/2019_03_03_BCT')

    % % sorted domain labels
    % [t1, idx_dumb] = sortrows( labels, 2 );
    % [mod_names, t2, aff] = unique( t1(:,2) );
    % mod_ = accumarray(aff, 1);
    % sorted_idx = cell2mat( labels(idx_dumb,1) );
    % rsn_fnc = fnc( sorted_idx, sorted_idx );
    
    % sorted domain labels
    rsn_idx = cell2mat( labels(:,1) );
    rsn_fnc = fnc( rsn_idx, rsn_idx );

    % reorder modules
    [order_, reordered_matrix] = reorder_mod( rsn_fnc, labels(:,2) );

    % sorted output index
    rsn_idx_reordered = rsn_idx( order_ );

