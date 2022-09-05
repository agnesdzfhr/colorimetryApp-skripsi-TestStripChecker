function [imgBoard] = segmentBoard(imgRGB)


if nargin == 0
    close all
    % filename = 'NOVA3i\IMG_20201123_165624_DRO.jpg';
    [FileName,PathName,~] = uigetfile('*.jpg', 'Pilih image file', 'MultiSelect', 'off');
    if isequal(FileName, 0)
        msgbox('Action Canceled', 'Canceled');
        return
    end
    filename = [PathName FileName];
    imgRGB  = imread(filename);
end

sz      = size(imgRGB);
ratio   = 1000/min(sz(1), sz(2));
imgRGB  = imresize(imgRGB,ratio);

% bwredFrame   = imbinarize(imgRGB(:,:,1), 'adaptive'); % obtain the white component from red layer
% bwgreenFrame = imbinarize(imgRGB(:,:,2), 'adaptive'); % obtain the white component from green layer
% bwblueFrame  = imbinarize(imgRGB(:,:,3), 'adaptive'); % obtain the white component from blue layer
% binFrame     = bwredFrame & bwgreenFrame & bwblueFrame; % get the common region
% binFrame     = medfilt2(binFrame, [9 9]); % Filter out the noise by using median filter
% se           = strel('ball',5,5);
% binFrame     = imdilate(binFrame,se);

% Blurring Image
imgRGB  = imgaussfilt(imgRGB,2);

% Check Bright or Dark
imgGray  = rgb2gray(imgRGB);

% Binarize the image.
binaryImage = imgGray < 100;


stats       = regionprops(binaryImage, 'BoundingBox','Area');
area        = cat(1,stats.Area);
rectBox     = cat(1,stats.BoundingBox);
idArea      = area==max(area);
rectBox     = rectBox(idArea,:);



imgBoard = imcrop(imgRGB,rectBox);

