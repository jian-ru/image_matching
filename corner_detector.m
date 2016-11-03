% img is an image
% cimg is a corner matrix

function [cimg] = corner_detector(img)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    cimg = cornermetric(img);
end