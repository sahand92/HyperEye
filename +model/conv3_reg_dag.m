function [lgraph options augimds] = conv3_reg_dag(XTrain,YTrain,XValidation,YValidation)
% -------------------------------------------------------------
layers = [
    imageInputLayer([size(XTrain,1) size(XTrain,2) size(XTrain,3)],'Name','input')

    convolution2dLayer(8,16,'Padding',[1 1 1 1],'stride',[4 4], 'NumChannels',size(XTrain,3),...
    'Name','conv_1')
    batchNormalizationLayer('Name','BN_1')
    reluLayer('Name','relu_1')
    
    maxPooling2dLayer(3,'Stride',2,'Name','MP_1')

    convolution2dLayer(4,32,'Padding',[0 0 0 0],'stride',[2 2],'Name','conv_2')
    batchNormalizationLayer('Name','BN_2')
    reluLayer('Name','relu_2')

    ];

lgraph = layerGraph(layers);

skipConv = convolution2dLayer(9,32,'Padding',[0 0 0 0],'stride',[4 4],'Name','skipConv');
lgraph = addLayers(lgraph,skipConv);
lgraph = connectLayers(lgraph,'relu_1','skipConv');

add = additionLayer(2,'Name','add_1');
lgraph = addLayers(lgraph,add);

lgraph = connectLayers(lgraph,'skipConv','add_1/in1');
lgraph = connectLayers(lgraph,'relu_2','add_1/in2');

lgraph = addLayers(lgraph, fullyConnectedLayer(size(categories(YTrain),1),'Name','fc_1'));
lgraph = connectLayers(lgraph,'add_1','fc_1');

lgraph = addLayers(lgraph, softmaxLayer('Name','softmax'));
lgraph = connectLayers(lgraph,'fc_1','softmax');

lgraph = addLayers(lgraph, classificationLayer('Name','classout'));
lgraph = connectLayers(lgraph,'softmax','classout');
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
