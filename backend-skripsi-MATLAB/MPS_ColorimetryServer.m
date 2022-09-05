function [out] = ColorimetryAllANN(InputData)

addpath(genpath([pwd 'C:\Users\ASUS\OneDrive - UNIVERSITAS INDONESIA\Documents\MATLAB\TestUntukServer\function']));
addpath(genpath([pwd 'C:\Users\ASUS\OneDrive - UNIVERSITAS INDONESIA\Documents\MATLAB\TestUntukServer\reference']));

load('C:\Users\ASUS\OneDrive - UNIVERSITAS INDONESIA\Documents\ColorimetryNew\ANN-Gabung-New.mat');

File = convertStringsToChars(InputData);

% Description:
% Adjust the Address on your PC
% input: image file
%        sample information
%        smart phone information

% output: segmented roi
%         target information

% Configuration
% FisheyeCorrection = false; % true | false

%% Opening file
[PathName] = 'G:\Agnes Academic\Android Development\JavaScript\ReactNative\backend-skripsi-foto-master\assets\';
[FileName] = (File);


%% Data Reading
img     = imread([PathName FileName]);
imgInfo = imfinfo([PathName FileName]);
    
%% Image Pre Processing
 try   
% segment image strip board from camera
imgBoard = segmentBoard(img);

% figure; imshow(imgBoard);
 catch e
     out = "Data Error";
     return
 end
    
%% Segmentation Step

% load masking image
mask     = imread('C:\Users\ASUS\OneDrive - UNIVERSITAS INDONESIA\Documents\MATLAB\TestUntukServer\reference\ColorMaskWater2.jpg'); % masking old
% ColorMask.jpg for Urine
% ColorMaskWater.jpg for Water

% Number of test strip
numStrip = 6;  % 10 for Urine Test Strip and 6 for Water Test Strip

 try   
% exctract image of Color Reference Matrix and Test Strip
[imgCR, imgTS]  = segmentColorStrip(imgBoard, mask, numStrip); % New

 catch e
     out = "Data Error";
     return
 end
        
%% Adding sample information for modeling, classification and regression
annotation.object   = 'Water';            %% Sample or Object Name in English (Ex: Original Urine, Artificial Urine, Water, etc)

   
annotation.testStripID{2}   = 1;                     %% Analiti position in Test Strip (Up to down)
annotation.atributName{2}   = 'PPM';                  %% Regression Naming (untuk satuan)


    

 %% Create Dataset

valCR(:,:,:)    = avRGB(imgCR);
valTS(:,:,:)    = avRGB(imgTS);
               
% Color Correction using sRGB Color Space Lab
if valCR ~= 0
    
% load Color Reference Value
colorRef    = load('C:\Users\ASUS\OneDrive - UNIVERSITAS INDONESIA\Documents\MATLAB\TestUntukServer\reference\colorRef.mat');
colorRef    = colorRef.colorRef;
corr_valTS  = zeros(size(valTS));

% convert RGB to LAB Color Space
rgbCR   = double(valCR(:,:,:)) / (2^8 - 1);
labCR   = rgb2lab(rgbCR,'ColorSpace','srgb');

rgbTS   = double(valTS(:,:,:)) / (2^8 - 1);
labTS   = rgb2lab(rgbTS,'ColorSpace','srgb');

rgbRef  = double(colorRef.RGB) / (2^8 - 1);
labRef  = rgb2lab(rgbRef,'ColorSpace','srgb');

% training
model = 'root6x3'; % color correction model
observer = '1964' % '1931' (default) | '1964'
% loss = 'ciede94' % 'mse' | 'ciede00' (default) | 'ciede94' |'ciedelab' | 'cmcde'
targetcolorspace = 'sRGB'; % 'sRGB' (default)
metrics = {'mse', 'ciede00', 'ciedelab'}; % only for evaluation: 'mse' | 'ciede00' | 'ciede94' | 'ciedelab' | 'cmcde' |  (default = {'ciede00', 'ciedelab'})

% default loss function: ciede00
% if RGB_train has been white-balanced, consider using 'preservewhite' and
% 'whitepoint' parameters.
[matrix, scale, XYZ_train_pred, errs_train] = ccmtrain(rgbCR,...
  rgbRef,...
 'model', model,...
 'allowscale', true,...
 'observer', observer,...
 'omitlightness', false,...
 'bias', true,...
 'targetcolorspace', targetcolorspace,...
 'loss', 'ciede00',...
 'metric', metrics);
      
% apply correction matrix to color matrix
rgbCR               = double(valCR) / (2^8 - 1);
corrRGB_CR(:,:,:)   = ccmapply(rgbCR,model,matrix,scale);

% apply correction matrix to original Strip Test
rgbTS               = double(valTS) / (2^8 - 1);
corr_valTS(:,:,:)   = ccmapply(rgbTS,model,matrix,scale);

else
    disp('Data Error');
    return
end
        
% Preparing Data
feature     = corr_valTS(1,:,:);       % example for analit 10th (Glucose)
        
%% Validasi Regresi

        rmseANNTt            = zeros(1,1);
        testingCorrCoeff     = zeros(1,1);
        
        ttIdx = 1;
            
        testFeature          = feature(ttIdx, :); 
       
        
        % Testing ANN on Testing Data
     
        testingTargetPrediction = sim(net,testFeature');

                                                         


% Check Dataset content
if ~exist('feature', 'var')
    disp('Error: Feature variable is not found');
    return
end


output = sprintf('%3.1f %s',testingTargetPrediction,annotation.atributName{2});

out = convertCharsToStrings(output)

end




