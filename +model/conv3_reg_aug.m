function [layers options augimds] = conv3_reg(XTrain,YTrain,XValidation,YValidation)
% -------------------------------------------------------------
layers = [
    imageInputLayer([size(XTrain,1) size(XTrain,2) size(XTrain,3)])

    convolution2dLayer(8,16,'Padding',[1 1 1 1],'stride',[4 4], 'NumChannels',size(XTrain,3))
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2)

    convolution2dLayer(4,32,'Padding',[0 0 0 0],'stride',[2 2])
    batchNormalizationLayer
    reluLayer
    
%     maxPooling2dLayer(2,'Stride',2)
%   
%     convolution2dLayer(4,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer

    %maxPooling2dLayer(2,'Stride',2)

    fullyConnectedLayer(1)
    regressionLayer];
% -------------------------------------------------------------
miniBatchSize  = 128;
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('adam', ... %'sgdm'
    'ExecutionEnvironment','multi-gpu',...
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
imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-90,90], ...
    'RandXTranslation',[-10 10], ...
    'RandYTranslation',[-10 10]);
augimds = augmentedImageDatastore([size(XTrain,1) size(XTrain,2) size(XTrain,3)],XTrain,YTrain,'DataAugmentation',imageAugmenter);
end
