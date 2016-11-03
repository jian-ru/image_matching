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
    img = conv2(img, G, 'full');
    
    padding = 20 - floor(kernelSize * 0.5);
    img = padarray(img, [padding padding]);
    offset = (3:5:40) - 21;
    x = bsxfun(@plus, x + 20, offset);
    y = bsxfun(@plus, y + 20, offset);
    [nr, nc, ~] = size(img);
    % each slice of idx are the indices for the elements of the 8x8
    % descriptor
    idx = bsxfun(@(x, y) y * nc + x, permute(x, [3 2 1]), ...
        permute(y', [1 3 2]));
    descs = img(idx(:));
    descs = reshape(descs, 64, []);
end