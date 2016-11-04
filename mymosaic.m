% img_input is a cell array of color images (HxWx3 uint8 values in the
% range [0,255])
% img_mosaic is the output mosaic

function [img_mosaic] = mymosaic(img_input)
    grayImgs = img_input;
    numImgs = length(img_input);
    
    if numImgs <= 0
        img_mosaic = {};
        return;
    end
    if numImgs == 1
        img_mosaic = img_input;
        return;
    end
    
    for i = 1:numImgs
        if size(grayImgs{i}, 3) == 3
            grayImgs{i} = rgb2gray(grayImgs{i});
        else
            img_input{i} = repmat(img_input{i}, 1, 1, 3);
        end
        [nr, nc, ~] = size(grayImgs{i});
        corners{i} = [0 0 1; nc 0 1; nc nr 1; 0 nr 1]';
    end
    
    maxPts = 1000;
    ransacThreshold = 3;
    
    for i = 1:numImgs-1
        img1 = grayImgs{i};
        img2 = grayImgs{i+1};
        C1 = corner_detector(img1);
        C2 = corner_detector(img2);
        [x1, y1, ~] = anms(C1, maxPts);
        [x2, y2, ~] = anms(C2, maxPts);
        [descs1, x1, y1] = feat_desc(img1, x1, y1);
        [descs2, x2, y2] = feat_desc(img2, x2, y2);
        match = feat_match(descs1, descs2);
        mask = match ~= -1;
        match = match(mask);
        x1 = x1(mask); y1 = y1(mask); x2 = x2(match); y2 = y2(match);
        [H, idx] = ransac_est_homography(x1, y1, x2, y2, ransacThreshold);
        Hs{i} = H;
        x1 = x1(idx); y1 = y1(idx); x2 = x2(idx); y2 = y2(idx);
        figure; showMatchedFeatures(img1, img2, [x1, y1], [x2, y2], 'montage');
    end
    Hs{numImgs} = eye(3, 3);
    
    for i = numImgs-1:-1:1
        Hs{i} = Hs{i+1} * Hs{i};
    end
    
    minCoord = [inf; inf];
    maxCoord = -minCoord;
    for i = 1:numImgs
        cs = Hs{i} * corners{i};
        cs = bsxfun(@rdivide, cs(1:2, :), cs(3, :));
        minCoord = min(minCoord, min(cs, [], 2));
        maxCoord = max(maxCoord, max(cs, [], 2));
        corners{i} = cs;
    end
    minCoord = floor(minCoord);
    maxCoord = ceil(maxCoord);
    offsets = -minCoord + 1;
    maxCoord = maxCoord + offsets;
    
    canvas = zeros(maxCoord(2), maxCoord(1), 3);
    for i = 1:numImgs
        img = img_input{i};
        H = Hs{i};
        corners{i} = bsxfun(@plus, corners{i}, offsets);
        startXY = max(round(min(corners{i}, [], 2)), 1);
        mask = ones(size(img));
        T = projective2d(H');
        img = double(imwarp(img, T));
        mask = imwarp(mask, T);
        sx = startXY(1); sy = startXY(2);
        [nr, nc, ~] = size(img);
        canvas(sy:sy+nr-1, sx:sx+nc-1, :) = mask .* img + ...
            (1.0 - mask) .* canvas(sy:sy+nr-1, sx:sx+nc-1, :);
    end
    img_mosaic = uint8(min(canvas, 255));
    figure; imshow(img_mosaic);
end