function [f1, precision_, recall_] = score_( true_labels, pred_labels )
    C = confusionmat( true_labels, pred_labels );
    
    % assume 0=noise (negative), 1=RSN (positive)
    % we're flipping it here
    tp = C(2,2);
    tn = C(1,1);
    fp = C(1,2);
    fn = C(2,1);

    precision_ = tp / ( tp + fp );
    recall_ = tp / (tp + fn);
    f1 = 2 * precision_ * recall_ / ( precision_ + recall_ );
