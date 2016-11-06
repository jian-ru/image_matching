% Adaptive Non-Maximal Suppression
% cimg = corner strength map
% max_pts = number of corners desired
% [x, y] = coordinates of corners
% rmax = suppression radius used to get max_pts corners

function [x, y, rmax] = anms(cimg, max_pts)
    [nr, nc, ~] = size(cimg);
    [X, Y] = meshgrid(1:nc, 1:nr);
    threshold = 0.03 * max(cimg(:));
    mask = cimg > threshold;
    C = cimg(mask);
    X = X(mask);
    Y = Y(mask);
    [~, I] = sort(C);
    maxNumCandidates = 10000;
    if length(I) > maxNumCandidates
        I = I(1:maxNumCandidates);
    end
    X = X(I);
    Y = Y(I);
    X2 = bsxfun(@(a, b) (a - b).^2, X', X);
    Y2 = bsxfun(@(a, b) (a - b).^2, Y', Y);
    R = min(sqrt(X2 + Y2) + tril(inf(size(X2))), [], 2);
    [R, I] = sort(R, 'descend');
    X = X(I);
    Y = Y(I);
    
    max_pts = min(size(X, 1), max_pts);
    x = X(1:max_pts);
    y = Y(1:max_pts);
    rmax = R(max_pts);
    
    patchSize1D = 40;
    hlen = floor(patchSize1D * 0.5);
    [nr, nc, ~] = size(cimg);
    validMask = x > hlen & x <= nc - hlen & ...
        y > hlen & y <= nr - hlen;
    x = x(validMask);
    y = y(validMask);
end