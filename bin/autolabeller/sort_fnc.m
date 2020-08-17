% sorts FNC matrix
% input: unsorted FNC matrix, corresponding IC# and functional domain label
% 
function [network_idx_reordered, reordered_matrix, order_] = sort_fnc( fnc, labels )
    % sorted domain labels
    network_idx = find( cell2mat( labels(:,2) ) );
    noise_idx = find( ~cell2mat( labels(:,2) ) );
    network_fnc = fnc( network_idx, network_idx );

    % reorder modules
    [order_, reordered_matrix] = reorder_mod( network_fnc, labels( network_idx, 3 ) );

    % sorted output index of the networks
    network_idx_reordered = network_idx( order_ );

    % sorted output index of all components
    order_ = [network_idx_reordered; noise_idx];

    disp('done reordering FNC')

