function [valRGB] = avRGB(imgROI)

if iscell(imgROI)
    valRGB = zeros(length(imgROI),3);
    
    for i=1:length(imgROI)
        img = imgROI{i};
        valRGB(i,1)  = mean2(img(:,:,1));
        valRGB(i,2)  = mean2(img(:,:,2));
        valRGB(i,3)  = mean2(img(:,:,3));
    end
else
    
end


end

