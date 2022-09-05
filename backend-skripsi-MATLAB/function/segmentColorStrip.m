function [imgCR, imgTS] = segmentColorStrip(imgRGB, mask, numStrip)


if nargin < 3
    numStrip  = 10;
end

if nargin == 0
    close all
    filename    = 'IMG\ColorChart_04.jpg';
    numStrip    = 10;
    imgRGB      = imread(filename);
    mask        = imread('IMG\ColorMask.jpg');
end

mask     = im2double(mask);

% Detect image Orientation
sz = size(imgRGB);
if sz(1)<sz(2)
    imgRGB = imrotate(imgRGB,-90);
end
ratio = 760/min(sz(1), sz(2));
imgRGB  = imresize(imgRGB,ratio);

% Blurring Image
imgRGB  = imgaussfilt(imgRGB,2);

% Check Bright or Dark
imgGray  = rgb2gray(imgRGB);
grayMean = mean2(imgGray);

% Detect Circle
Rmin = 20;
Rmax = 30;
if grayMean>90
    [centersDark, radiiDark] = imfindcircles(imgGray, [Rmin Rmax], 'ObjectPolarity','dark');
else
    [centersDark, radiiDark] = imfindcircles(imgGray, [Rmin Rmax], 'ObjectPolarity','bright');
end

% ADJUST IF STARTED WITH SHORT AXIS
% Check click distances
xc = centersDark(:,1);
yc = centersDark(:,2);
if length(xc) < 4
    disp('Wrong Image Input');
    rgbCR = 0;
    rgbTS = 0;
    return
end

% Point Arrangement counterclokwise
cx = mean(xc);
cy = mean(yc);
tetha = atan2(yc - cy, xc - cx);
[~, order] = sort(tetha);
xc = xc(order);
yc = yc(order);

% dists  = pdist([xc(1:4),yc(1:4)],'euclidean');
% widhth = (dists(1)+dists(6))/2;                  % widhth
% height = (dists(3)+dists(4))/2;                  % height

%Corected image
oriPoints   = [xc yc];
szMask      = size(mask);
transPoint  = [min(xc),min(yc);
               min(xc)+szMask(2),min(yc);
               min(xc)+szMask(2),min(yc)+szMask(1);
               min(xc),min(yc)+szMask(1)];

tform           = fitgeotrans(oriPoints,transPoint,'Projective'); % make transformation matrix
resultReference = imref2d(size(imgRGB));
imgRGB          = imwarp(imgRGB, tform, 'OutputView', resultReference); % transform

 


xc = transPoint(:,1);
yc = transPoint(:,2);

% MAKE COLORCARD GRID IMAGE
mask    = rgb2gray(mask);
mask    = imbinarize(mask, 'global'); % , 'adaptive','ForegroundPolarity','bright', 'Sensitivity',0.5
cardImg = bwlabel(mask',8)';
[B,~]   = bwboundaries(cardImg);

% Crop & Plot Boundary
imgStrip = imcrop(imgRGB,[xc(1) yc(1) szMask(2) szMask(1)]);
imgStrip = imresize(imgStrip, size(cardImg));


% Get Color
imgArea = cell(1,length(B));
for k = 1:length(B)
    stats = regionprops(cardImg==k,'BoundingBox');
    imgBox = imcrop(imgStrip,stats.BoundingBox);
    imgArea{k} = imgBox;    
end

% Color Reference
if numStrip == 6
    idCR = [2 3 4 5 7 8 9 10 12 13 14 15 17 18 19 20 22 23 24 25 27 28 29 30];
    idTS = [6 11 16 21 26 31];
else
    idCR = [4 5 6 7 9 10 11 12 15 16 17 18 21 22 23 24 26 27 28 29 32 33 34 35];
    idTS = [3 8 13 14 19 20 25 30 31 36];
end

% Data Save
imgCR = imgArea(idCR);
imgTS = imgArea(idTS);