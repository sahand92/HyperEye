function [layers options] = conv3_reg(XTrain,YTrain,XValidation,YValidation)
% -------------------------------------------------------------
layers = [
    imageInputLayer([size(XTrain,1) size(XTrain,2) size(XTrain,3)])

    convolution2dLayer([1 10],8,'Padding',[0 0 0 0],'stride',[1 5],'NumChannels',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer([1 3],'Stride',[1 2])
    dropoutLayer(0.1)

    convolution2dLayer([1 4],32,'Padding',[0 0 0 0],'stride',[1 2])
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer([1 3],'Stride',[1 2])
    dropoutLayer(0.1)
  
    convolution2dLayer([1 5],64,'Padding',[0 0 0 0],'stride',[1 2])
    batchNormalizationLayer
    reluLayer

    %maxPooling2dLayer([1 2],'Stride',2)

    fullyConnectedLayer(1)
    regressionLayer];
% -------------------------------------------------------------
miniBatchSize  = 128;
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('adam', ... %'sgdm'
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',1000, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','none', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',100, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',true);
% -------------------------------------------------------------
end
