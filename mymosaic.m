% img_input is a cell array of color images (HxWx3 uint8 values in the
% range [0,255])
% img_mosaic is the output mosaic

function [img_mosaic] = mymosaic(img_input)
    numImgs = length(img_input);
    if numImgs <= 0
        img_mosaic = {};
        return;
    end
    if numImgs == 1
        img_mosaic = img_input;
        return;
    end
    
    focalLen = 1320; % goldengate
%     focalLen = 3500; % test1
%     focalLen = 5000; % lab
%     focalLen = 1650; % halfdome
%     focalLen = 1700; % yosemite
%     focalLen = 1700; % carmel
%     focalLen = 1650; % hotel
%     focalLen = 800; % yard
    
    for i = 1:numImgs
        [nr, nc, ~] = size(img_input{i});
        D = padarray(zeros(nr, nc), [1 1], 1);
        D = bwdist(D);
        D = D(2:end-1,2:end-1);
        Ds{i} = projImgCylinder(D, focalLen);
        img = double(img_input{i});
        img = img ./ max(img(:));
        img_input{i} = projImgCylinder(img, focalLen);
    end
    grayImgs = img_input;
    
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
        C1 = corner_detector(img1) .* (Ds{i} > 20.0);
        C2 = corner_detector(img2) .* (Ds{i+1} > 20.0);
        [x1, y1, ~] = anms(C1, maxPts);
        [x2, y2, ~] = anms(C2, maxPts);
        descs1 = feat_desc(img1, x1, y1);
        descs2 = feat_desc(img2, x2, y2);
        match = feat_match(descs1, descs2);
        mask = match ~= -1;
        match = match(mask);
        x1 = x1(mask); y1 = y1(mask); x2 = x2(match); y2 = y2(match);
        [H, idx] = ransac_est_homography(x1, y1, x2, y2, ransacThreshold);
        Hs{i} = H;
        x1 = x1(idx); y1 = y1(idx); x2 = x2(idx); y2 = y2(idx);
%         tform = estimateGeometricTransform([x1 y1], [x2 y2], 'similarity');
%         Hs{i} = tform.T';
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
    
    % Distance transform blending
    % The basic idea is that we should use color from img1 in area only
    % covered by img1, use color from img2 in area only covered by img2,
    % and in overlapping area, blend them according to the ratio of
    % distance of the pixel to the center of the two images (i.e. alpha1 =
    % d1 / (d1 + d2)). That is, if you are closer to the center of img1
    % than to the center of img2, you should be affected more by img1.
    canvas = zeros(maxCoord(2), maxCoord(1), 3);
    D = zeros(maxCoord(2), maxCoord(1));
    for i = 1:numImgs
        img = img_input{i};
        H = Hs{i};
        mask = Ds{i};
        mask = mask ./ max(mask(:));
        corners{i} = bsxfun(@plus, corners{i}, offsets);
        startXY = max(floor(min(corners{i}, [], 2)), 1);
        T = projective2d(H');
        img = double(imwarp(img, T));
        mask = imwarp(mask, T);
        sx = startXY(1); sy = startXY(2);
        [nr, nc, ~] = size(img);
        ex = sx + nc - 1; ey = sy + nr - 1;
        if ex > size(canvas, 2) || ey > size(canvas, 1)
            padding = [max(ey - size(canvas, 1), 0), ...
                max(ex - size(canvas, 2), 0)];
            canvas = padarray(canvas, padding, 'post');
            D = padarray(D, padding, 'post');
        end
        alpha = mask ./ (mask + D(sy:sy+nr-1, sx:sx+nc-1) + 1e-6);
        canvas(sy:sy+nr-1, sx:sx+nc-1, :) = bsxfun(@times, img, alpha) + ...
            bsxfun(@times, canvas(sy:sy+nr-1, sx:sx+nc-1, :), 1.0 - alpha);
        D(sy:sy+nr-1, sx:sx+nc-1) = bsxfun(@times, mask, alpha) + ...
            bsxfun(@times, D(sy:sy+nr-1, sx:sx+nc-1), 1.0 - alpha);
    end
    img_mosaic = uint8(min(canvas .* 255, 255));
    figure; imshow(img_mosaic);
end