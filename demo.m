% img1 = imread('test/goldenbridge/goldengate-01.png');
% img2 = imread('test/goldenbridge/goldengate-02.png');
% C1 = corner_detector(img1);
% C2 = corner_detector(img2);
% [x1, y1, ~] = anms(C1, 1000);
% [x2, y2, ~] = anms(C2, 1000);
% [descs1, x1, y1] = feat_desc(img1, x1, y1);
% [descs2, x2, y2] = feat_desc(img2, x2, y2);
% match = feat_match(descs1, descs2);
% mask = match ~= -1;
% match = match(mask);
% x1 = x1(mask); y1 = y1(mask); x2 = x2(match); y2 = y2(match);
% [H, idx] = ransac_est_homography(x1, y1, x2, y2, 3);
% showMatchedFeatures(img1, img2, [x1(idx), y1(idx)], [x2(idx), y2(idx)], 'montage');

clear all;

baseName = 'test/goldenbridge/goldengate-';
numImgs = 6;
ext = '.png';
baseNum = 0;

% baseName = 'test/test1/';
% numImgs = 2;
% ext = '.jpg';
% baseNum = 0;

% baseName = 'test/lab/cyl_image';
% numImgs = 18;
% ext = '.png';
% baseNum = 1;

% baseName = 'test/halfdome/halfdome-';
% numImgs = 6;
% ext = '.png';
% baseNum = 0;

% baseName = 'test/yosemite/yosemite';
% numImgs = 4;
% ext = '.jpg';
% baseNum = 1;

% baseName = 'test/hotel/hotel-';
% numImgs = 8;
% ext = '.png';
% baseNum = 0;

% baseName = 'test/yard/yard-';
% numImgs = 9;
% ext = '.png';
% baseNum = 0;

for i=1:numImgs
    num = i - 1 + baseNum;
    if num < 10
        imgName = [baseName, '0', num2str(num), ext];
    else
        imgName = [baseName, num2str(num), ext];
    end
    
    inputImgs{i} = imread(imgName);
end

compositeImg = mymosaic(inputImgs);
