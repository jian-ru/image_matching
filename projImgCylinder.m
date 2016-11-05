function outImg = projImgCylinder(img, f)
%PROJIMGCYLINDER
%   Project @img onto a cylinder and then unwrap the cylinder
%   f - focal length
    outImg = zeros(size(img), 'like', img);
    [nr, nc, numLayers] = size(img);
    [X, Y] = meshgrid(1:nc, 1:nr);
    pX = X(:);
    pY = Y(:);
    X = pX - 0.5; % pixel center
    Y = pY - 0.5;
    xc = nc * 0.5;
    yc = nr * 0.5;
    
    oneOverF = 1.0 / f;
    theta = (X - xc) .* oneOverF;
    h = (Y - yc) .* oneOverF;
    xhat = sin(theta);
    yhat = h;
    oneOverZhat = 1.0 ./ cos(theta);
    X_ = f .* xhat .* oneOverZhat + xc;
    Y_ = f .* yhat .* oneOverZhat + yc;
    validPtMask = X_ > 0.0 & X_ < nc & Y_ > 0.0 & Y_ < nr;
    X_ = X_(validPtMask);
    pX = pX(validPtMask);
    Y_ = Y_(validPtMask);
    pY = pY(validPtMask);
    Xl = max(1, floor(X_ - 0.5) + 1);
    Yl = max(1, floor(Y_ - 0.5) + 1);
    Xh = min(nc, Xl + 1);
    Yh = min(nr, Yl + 1);
    wxh = abs(X_ - (Xl - 0.5));
    wxl = 1.0 - wxh;
    wyh = abs(Y_ - (Yl - 0.5));
    wyl = 1.0 - wyh;
    ill = (Xl - 1) .* nr + Yl;
    ilr = (Xh - 1) .* nr + Yl;
    iul = (Xl - 1) .* nr + Yh;
    iur = (Xh - 1) .* nr + Yh;
    idx = (pX - 1) .* nr + pY;
    for i = 1:numLayers
        offset = (i-1)*nr*nc;
        outImg(offset + idx) = wxl .* wyl .* img(offset + ill) + ...
            wxh .* wyl .* img(offset + ilr) + ...
            wxl .* wyh .* img(offset + iul) + ...
            wxh .* wyh .* img(offset + iur);
    end
end

