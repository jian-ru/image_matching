% y1, x1, y2, x2 are the corresponding point coordinate vectors Nx1 such
% that (y1i, x1i) matches (x2i, y2i) after a preliminary matching

% thresh is the threshold on distance used to determine if transformed
% points agree

% H is the 3x3 matrix computed in the final step of RANSAC

% inlier_ind is the nx1 vector with indices of points in the arrays x1, y1,
% x2, y2 that were found to be inliers

function [H, inlier_ind] = ransac_est_homography(x1, y1, x2, y2, thresh)
    numIters = 2000;
    numMatches = size(x1, 1);
    % 1000 samples of 4 points
    samples = zeros(numIters * 4, 1);
    for i = 1:numIters
        samples(4*i-3:4*i) = randperm(numMatches, 4);
    end
    Xs = reshape(x1(samples), 4, []);
    Ys = reshape(y1(samples), 4, []);
    Xd = reshape(x2(samples), 4, []);
    Yd = reshape(y2(samples), 4, []);
    Xs = num2cell(Xs, 1);
    Ys = num2cell(Ys, 1);
    Xd = num2cell(Xd, 1);
    Yd = num2cell(Yd, 1);
    H = cellfun(@est_homography, Xd, Yd, Xs, Ys, 'UniformOutput', false);
    X1 = num2cell(repmat(x1, 1, numIters), 1);
    Y1 = num2cell(repmat(y1, 1, numIters), 1);
    [X1_, Y1_] = cellfun(@apply_homography, H, X1, Y1, 'UniformOutput', false);
    X1_ = cell2mat(X1_);
    Y1_ = cell2mat(Y1_);
    tmpX2 = bsxfun(@(a, b) (a - b).^2, X1_, x2);
    tmpY2 = bsxfun(@(a, b) (a - b).^2, Y1_, y2);
    inlierMask = sqrt(tmpX2 + tmpY2) < thresh;
    counts = sum(inlierMask);
    [~, bestIdx] = max(counts);
    
    inlier_ind = find(inlierMask(:, bestIdx));
    H = est_homography(x2(inlier_ind), y2(inlier_ind), x1(inlier_ind), y1(inlier_ind));
end