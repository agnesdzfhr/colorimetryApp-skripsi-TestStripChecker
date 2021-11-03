close all
clear
clc

load('C:\Users\ASUS\OneDrive - UNIVERSITAS INDONESIA\Documents\MATLAB\TestUntukServer\ModelRegresi\ANN-LM-Gabungan.mat');
 %Bayesian Regularization%
 % Huawei5t20ANN-BR-BARU
 % SamsungA5120ANN-BR-BARU
 % SH20ANN-BR-BARU

 %Levenberg-Marquardt%
 % Huawei5t20ANN-LM-BARU
 % SamsungA5120ANN-LM-BARU
 % SH20ANN-LM-BARU
             
[FileName,PathName,~] = uigetfile('*.mat', 'Select dataset file', 'MultiSelect', 'off');
if isequal(FileName, 0)
    msgbox('Action Canceled', 'Canceled');
    return
end

load([PathName FileName]);

szData   = length(target);
if szData == 0
    disp('Data Error');                         
    return
end

disp(['Number of collected mat file: ' num2str(szData)]);
        rmseANNTt            = zeros(1,1);
        testingCorrCoeff     = zeros(1,1);
        
        ttIdx = 1: szData ;
            
        testFeature          = feature(ttIdx, :);
        testTarget           = target(ttIdx, :);  
        
            % Testing ANN on Testing Data
            testingTargetPrediction = sim(net,testFeature');
            rmseANNTt               = errPerf(testingTargetPrediction',testTarget,'rmse');
            R                       = corrcoef(testTarget,testingTargetPrediction);
            testingCorrCoeff        = R(1,2);
                                                         
        errorTable = table(rmseANNTt,testingCorrCoeff);
        disp(errorTable);
        disp(['Rata-rata RMSE ANN on Testing Data' num2str(mean(rmseANNTt), '%.2f')]);
        disp(['Rata-rata Correlation Coefisient on Testing Data ' num2str(mean(testingCorrCoeff), '%.2f'), ' %']);

        % plot graph using latest cross val data
        figure;
        minData = 0;
        maxData = 10;
        markerSize = 30;
       
        % plot testing data
        scatter(testTarget, testingTargetPrediction, markerSize, 'd', 'filled', 'MarkerFaceColor','#A2142F');
        axis equal;
        
        % plot line
        hold on;
        plot((minData:maxData),(minData:maxData), '-k');
        xlim([minData maxData]);
        ylim([minData maxData]);        
        legend('PredictedTest', 'Interpreter', 'Latex', 'FontSize', 10, 'Location','southeast');
        ax(1) = xlabel(['Measured ' atributName ' (' atributUnits ')']);
        ax(2) = ylabel(['Predicted ' atributName ' (' atributUnits ')']);
        set(ax, 'Interpreter', 'Latex', 'FontSize', 12);
        set(gca,'TickLabelInterpreter','Latex', 'FontSize', 10);
        title('Real Swimming Pool Water Sample');  %Atur sesuai kebutuhan

% Check Dataset content
if ~exist('feature', 'var')
    disp('Error: Feature variable is not found');
    return
end

if ~exist('target', 'var')
    disp('Error: Target variable is not found');
    return
end