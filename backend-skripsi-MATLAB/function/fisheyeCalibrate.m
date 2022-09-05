function [FisheyeParams] = fisheyeCalibrate(folderImg, folderSave)

warning 'off';

if nargin == 0
    clc
    close all
    % folderName  = 'C:\Users\Adhi Harmoko S\UNIVERSITAS INDONESIA\BioImPhy - Documents\Code\SmartphoneMachineLearning\checkerBoard\HN5T\';
    folderImg  = uigetdir(pwd, 'Select image folder');
    if folderImg == 0
        disp('Canceled')
        return
    end
end

imds        = imageDatastore(folderImg);
disp(['Number of collected image: ' num2str(length(imds.Files))]);

disp('Detecting Checkerboard Points')
[imagePoints,boardSize,imagesUsed] = detectCheckerboardPoints(imds.Files);

disp(['Number of image used: ' num2str(sum(imagesUsed))]);
fileUsed = imds.Files(imagesUsed);
  
if nargin == 0
    for i = 1:length(fileUsed)
        imgFileName = fileUsed(i);
        imgFileName = split(imgFileName, filesep);
        disp(['Filename (' num2str(i) '): ' imgFileName{end}]);
        
        I = imread(fileUsed{i});
        subplot(3, length(fileUsed), i);
        imshow(I); 
        title(['Imaged ' imgFileName{end}]);
        hold on;
        plot(imagePoints(:,1,i),imagePoints(:,2,i),'ro');
    end
end

if sum(imagesUsed) < 3
    FisheyeParams = 0;
    disp('The images used were not proper with the calibration process');
    return
end

squareSize  = 5; % millimeters 160
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

IMG         = readimage(imds,1);
info        = imfinfo(imds.Files{1});
imageSize   = [size(IMG,1) size(IMG,2)];

% Calibrate the camera using fisheye parameters
[FisheyeParams, imagesUsed, estimationErrors]   = estimateFisheyeParameters(imagePoints,worldPoints,imageSize, 'EstimateAlignment', false,'WorldUnits', 'millimeters');

if nargin == 0
    disp(['Number of image used: ' num2str(sum(imagesUsed))]);
    correctedIMG = undistortFisheyeImage(IMG,FisheyeParams.Intrinsics, 'interp', 'cubic', 'ScaleFactor', 0.35);
    % correctedIMG = undistortFisheyeImage(IMG,FisheyeParams.Intrinsics,'OutputView','valid', 'interp', 'cubic', 'ScaleFactor', 1);
    figure; 
    imshow(IMG); 
    title('Original Image');
    
    figure; 
    imshow(correctedIMG); 
    title('Corrected Image');
    
    % View reprojection errors
    figure; 
    showReprojectionErrors(FisheyeParams);
    
    % Visualize pattern locations
    figure; 
    showExtrinsics(FisheyeParams, 'CameraCentric');
    
    % Display parameter estimation errors
    displayErrors(estimationErrors, FisheyeParams);
    
    folderSave  = uigetdir(pwd, 'Select folder to save');
    if folderSave == 0
        disp('Canceled');
        return
    end
end
save([folderSave filesep 'FishEye-' info.Model '.mat'], 'FisheyeParams');
disp ('Done');
disp (['Parameters were saved in ' folderSave filesep 'FishEye-' info.Model '.mat']);

