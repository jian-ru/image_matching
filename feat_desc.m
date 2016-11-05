% img = double (height)x(width) array (grayscale image) with values in the
% range 0-255
% x = nx1 vector representing the column coordinates of corners
% y = nx1 vector representing the row coordinates of corners
% descs = 64xn matrix of double values with column i being the 64 dimensional
% descriptor computed at location (xi, yi) in im

function [descs] = feat_desc(img, x, y)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = double(img);
    
    kernelSize = 5;
    sigma = 1.0;
    G = fspecial('gaussian', [kernelSize kernelSize], sigma);
    img = conv2(img, G, 'same');
    img = conv2(img, G, 'same');
    
    patchSize1D = 40;
    hlen = floor(patchSize1D * 0.5);
    [nr, nc, ~] = size(img);
    
    start = ceil(kernelSize * 0.5);
    stepSize = 5;
    offset = (start:stepSize:patchSize1D) - hlen;
    x = bsxfun(@plus, x, offset);
    y = bsxfun(@plus, y, offset);

    % each slice of idx are the indices for the elements of the 8x8 descriptor
    idx = bsxfun(@(x, y) (x - 1) * nr + y, permute(x, [3 2 1]), ...
        permute(y', [1 3 2]));
    descs = img(idx(:));
    descs = reshape(descs, 64, []);
    M = mean(descs);
    descs = bsxfun(@minus, descs, M);
    sigma = std(descs);
    descs = bsxfun(@rdivide, descs, sigma);
end
