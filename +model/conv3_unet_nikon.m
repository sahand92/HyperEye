function [trainingData layers options] = conv3_unet_nikon(imageDir,labelDir)

% -------------------------------------------------------------
%imageDir='C:\Segment_germ\Images';
%labelDir='C:\Segment_germ\Labels';

imds=imageDatastore(imageDir);
classNames=["grain","obstructed","border","broken"];
labelID=[1 2 3 4];
pxds = pixelLabelDatastore(labelDir,classNames,labelID);
pxds.ReadSize=1;
imds.ReadSize=1;

tbl = countEachLabel(pxds);
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency;
trainingData = pixelLabelImageDatastore(imds,pxds);

% -------------------------------------------------------------
layers = [
    imageInputLayer([1400 1400 3])

    convolution2dLayer(20,64,'Padding',[0 0 0 0],'stride',[5 5], 'NumChannels',3)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(10,'Stride',3)

    convolution2dLayer(14,64,'Padding',[0 0 0 0],'stride',[4 4])
    batchNormalizationLayer
    reluLayer

    transposedConv2dLayer(14,64,'Stride',4,'Cropping',0);
    batchNormalizationLayer
    reluLayer
    
    transposedConv2dLayer(65,64,'Stride',15,'Cropping',0);
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(1,4);
    softmaxLayer()
    pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights)
  ];
% -------------------------------------------------------------
% options = trainingOptions('adam', ...
%     'ExecutionEnvironment','multi-gpu',...
%     'InitialLearnRate',1e-3, ...
%     'MaxEpochs',1000, ...
%     'MiniBatchSize',128,...
%     'Shuffle','every-epoch', ...
%     'Plots','training-progress', ...
%     'Verbose',true);
l2reg = 0.0001;
maxEpochs = 150;
options = trainingOptions('sgdm',...
    'ExecutionEnvironment','gpu',...
    'InitialLearnRate',0.01, ...
    'Momentum',0.9,...
    'L2Regularization',l2reg,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',1,...
    'LearnRateSchedule','piecewise',...    
    'Shuffle','every-epoch',...
    'GradientThresholdMethod','l2norm',...
    'GradientThreshold',0.05, ...
    'Plots','training-progress', ...
    'VerboseFrequency',20);
% miniBatchSize  = 10;
% options = trainingOptions('adam', ... %'sgdm'
%     'MiniBatchSize',miniBatchSize, ...
%     'ExecutionEnvironment','gpu',...
%     'MaxEpochs',1000, ...
%     'InitialLearnRate',1e-3, ...
%     'LearnRateSchedule','none', ...
%     'LearnRateDropFactor',0.1, ...
%     'LearnRateDropPeriod',100, ...
%     'Shuffle','every-epoch', ...
%     'Plots','training-progress', ...
%     'Verbose',true);
% -------------------------------------------------------------
end
