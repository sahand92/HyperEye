function [layers options augimds] = conv3_class(XTrain,YTrain,XValidation,YValidation)
% -------------------------------------------------------------
layers = [
    imageInputLayer([size(XTrain,1) size(XTrain,2) size(XTrain,3)])

    convolution2dLayer([1 16],8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer([1 2],'Stride',2)

    convolution2dLayer([1 8],16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer([1 2],'Stride',2)
  
    convolution2dLayer([1 4],32,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer([1 2],'Stride',2)

    fullyConnectedLayer(size(categories(YTrain),1))
    softmaxLayer
    classificationLayer];
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
imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-90,90], ...
    'RandXTranslation',[-10 10], ...
    'RandYTranslation',[-10 10]);
augimds = augmentedImageDatastore([size(XTrain,1) size(XTrain,2) size(XTrain,3)],XTrain,YTrain,'DataAugmentation',imageAugmenter);
%minibatch = preview(augimds);
end
