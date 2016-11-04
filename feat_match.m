% descs1 is a 64x(n1) matrix of double values
% descs2 is a 64x(n2) matrix of double values
% match is n1x1 vector of integers where m(i) points to the index of the
% descriptor in p2 that matches with the descriptor p1(:,i).
% If no match is found, m(i) = -1

function [match] = feat_match(descs1, descs2)
    kdTree = KDTreeSearcher(descs2', 'Distance', 'euclidean');
    % find the two nearest neighbors for each descriptor in the first image
    idx = knnsearch(kdTree, descs1', 'K', 2);
    D1NN = sum((descs1 - descs2(:, idx(:, 1))).^2);
    D2NN = sum((descs1 - descs2(:, idx(:, 2))).^2);
    D2NN(D2NN < 1e-6) = 1;
    ratios = D1NN ./D2NN;
    match = -ones(size(descs1, 2), 1);
    mask = ratios <= 0.6;
    match(mask) = idx(mask, 1);
end