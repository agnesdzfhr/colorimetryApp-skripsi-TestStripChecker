function deltaTable = measureColorStrip94(colorRef, colorActual,isPlot)

% Input
%   colorRef : color reference in LAB Space
%   colorAct : color actual in LAB Space

 
% Measure Delta using Eucludian Distance
[Delta_E] = ciede94(colorActual, colorRef, true);

% convert the cartesian a*b* to polar chroma and hue
[h_Ref,c_Ref] = cart2pol(colorRef(:,2), colorRef(:,3));
[h_Act,c_Act] = cart2pol(colorActual(:,2), colorActual(:,3));
h_Ref = h_Ref*180/pi;
h_Act = h_Act*180/pi;
meanC = (c_Act+c_Ref)/2;

% compute G factor using the arithmetic mean chroma
G = 0.5 - 0.5*(((meanC.^7)./(meanC.^7 + 25^7)).^0.5);

% transform the a* values
colorRef(:,2) = (1 + G).*colorRef(:,2);
colorActual(:,2) = (1 + G).*colorActual(:,2);

% recompute the polar coordinates using the new a*
[h_Ref,c_Ref] = cart2pol(colorRef(:,2), colorRef(:,3));
[h_Act,c_Act] = cart2pol(colorActual(:,2), colorActual(:,3));
h_Ref = h_Ref*180/pi;
h_Act = h_Act*180/pi;
L_Ref = colorRef(:,1);
L_Act = colorActual(:,1);

% Arrange data to a table
deltaTable = table(L_Ref,c_Ref,h_Ref,L_Act,c_Act,h_Act,Delta_E);

if isPlot
    figure;
    rgbRef = lab2rgb(colorRef);
    rgbAct = lab2rgb(colorActual);
    
    rgbRef = rgbRef*2^8 - 1;
    rgbAct = rgbAct*2^8 - 1;
    
    displayTextLocation = zeros(24,2);
    
    col_sq_sz   = 180;
    col_sq_width=round(col_sq_sz/6);
    full_col_ch = zeros(6*col_sq_sz,4*col_sq_sz,3);
    displayText = cell(24,1);
    
    for m =1:6
        for n=1:4
            ind = (n-1)+4*(m-1)+1;
            col_sq = zeros(col_sq_sz,col_sq_sz,3);
            col_sq(:,:,1) = rgbRef(ind,1);
            col_sq(:,:,2) = rgbRef(ind,2);
            col_sq(:,:,3) = rgbRef(ind,3);
            
            col_sq(col_sq_width:end-col_sq_width,col_sq_width:end-col_sq_width,1) = rgbAct(ind,1);
            col_sq(col_sq_width:end-col_sq_width,col_sq_width:end-col_sq_width,2) = rgbAct(ind,2);
            col_sq(col_sq_width:end-col_sq_width,col_sq_width:end-col_sq_width,3) = rgbAct(ind,3);
            
            full_col_ch(col_sq_sz*(m-1)+1:col_sq_sz*(m-1)+col_sq_sz,col_sq_sz*(n-1)+1:col_sq_sz*(n-1)+col_sq_sz,:) = col_sq;
            displayTextLocation(ind,1) = round(col_sq_sz*(n-1)+1+col_sq_sz/4); % X location
            displayTextLocation(ind,2) = round(col_sq_sz*(m-1)+1+col_sq_sz/2); % Y location
            
            displayText{ind} = sprintf('Patch %d \n\n$$\\Delta$$E = %3.1f ', ind, Delta_E(ind));
            % displayText{ind} = sprintf('$$\\Delta$$E = %3.1f ', Delta_E(ind));
        end
    end
    
    hIm = imshow(uint8(full_col_ch));
    h = ancestor(hIm,'figure');
    set(h,'Name','Visual Color Comparison')
    
    text(displayTextLocation(:,1),displayTextLocation(:,2),displayText,'FontSize',9.5,'FontWeight','bold','Color',[1 1 1],'Interpreter','latex');
end
