function deltaTable = measureColorStrip(colorRef, colorActual,isPlot)

% Input
%   colorRef : color reference in LAB Space
%   colorAct : color actual in LAB Space


% Measure Delta using Eucludian Distance
deltaLab = colorRef - colorActual;
% Delta_E  = sqrt((1/3)*deltaLab(:,1).^2 + (1/3)*deltaLab(:,2).^2 + (1/3)*deltaLab(:,3).^2);
Delta_E  = (1/3)*sqrt(deltaLab(:,1).^2 + deltaLab(:,2).^2 + deltaLab(:,3).^2);

L_Ref   = colorRef(:,1);
a_Ref   = colorRef(:,2);
b_Ref   = colorRef(:,3);
L_Act   = colorActual(:,1);
a_Act   = colorActual(:,2);
b_Act   = colorActual(:,3);

% Arrange data to a table
deltaTable = table(L_Ref,a_Ref,b_Ref,L_Act,a_Act,b_Act,Delta_E);

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
