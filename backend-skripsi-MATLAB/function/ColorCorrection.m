function [rgbCR, rgbTS] = ColorCorrection(image)


if nargin == 0
    close all
    filename = 'IMG\ColorChart_05.jpg';
    display = true;
    imgRGB  = imread(filename);
    img     = im2double(imgRGB);
    
end

chart = esfrChart(img);