function [dsTrain layers lgraph options] = conv3_unet(imageDir,labelDir)

% -------------------------------------------------------------
%imageDir='C:\Segment_germ\Images';
%labelDir='C:\Segment_germ\Labels';

imds=imageDatastore(imageDir,'ReadFcn',@utils.padImgReader);
classNames=["endosperm","germ","background"];
labelID=[1 2 0];
pxds = pixelLabelDatastore(labelDir,classNames,labelID,'ReadFcn',@utils.padImgReader);
pxds.ReadSize=25;
imds.ReadSize=25;

tbl = countEachLabel(pxds);
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency;

augmenter = imageDataAugmenter( ...
    'RandRotation',[-90,90], ...
   'RandXTranslation',[-10 10], ...
    'RandYTranslation',[-10 10]);

dsTrain = pixelLabelImageDatastore(imds,pxds,...
    'DataAugmentation',augmenter);


% -------------------------------------------------------------
inputTileSize=[152,152,3];
encoderDepth=3;
numclasses=3;

%--------------------------------------------------------------
[lgraph, ~] = unetLayers(inputTileSize,numclasses,...
    'EncoderDepth',encoderDepth);%,...
  % 'ConvolutionPadding','valid');
outputLayer = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',...
    classWeights,'Name','Output');
lgraph = replaceLayer(lgraph,'Segmentation-Layer',outputLayer);


layers = [
    imageInputLayer([150 150 3])

    convolution2dLayer(8,64,'Padding',[1 1 1 1],'stride',[4 4], 'NumChannels',3)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2)

    convolution2dLayer(3,64,'Padding',[1 1 1 1],'stride',[1 1])
    batchNormalizationLayer
    reluLayer

    transposedConv2dLayer(5,64,'Stride',2,'Cropping',1);
    batchNormalizationLayer
    reluLayer
    
    transposedConv2dLayer(8,64,'Stride',4,'Cropping',1);
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(1,3);
    softmaxLayer()
    pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights)
  ];
% -------------------------------------------------------------
options = trainingOptions('adam', ...
    'ExecutionEnvironment','multi-gpu',...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',100, ...
    'MiniBatchSize',64,...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',true);
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
