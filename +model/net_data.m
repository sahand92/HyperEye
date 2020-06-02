function [layers options imds imdsTest imdsTrain augimds] = net_data(folder)
%folder = 'F:\EyeFoss Data\Pulses\Lentils\DEFECTS\Frost Lentil Grades EF1 PNR 17 PSS17 03Oct2019\Images'
imds = imageDatastore(fullfile(folder),...
'IncludeSubfolders',true,'FileExtensions','.mat','LabelSource','foldernames',...
'ReadFcn',@utils.matReader,'ReadSize',256)
% valimds= imageDatastore(fullfile('F:\EyeFoss Data\Pulses\Lentils\DEFECTS\2019CQOF Frost Characterisation EF2 PNR17 07Jan2020\Validations'),...
% 'IncludeSubfolders',true,'FileExtensions','.mat','LabelSource','foldernames',...
% 'ReadFcn',@utils.matReader)
numTrainingFiles = 500;
numTestFiles = 100;

[imdsTrain,imdsTest] = splitEachLabel(imds,numTrainingFiles,'randomize');
imdsTest = splitEachLabel(imdsTest,numTestFiles,'randomize');

imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-90,90], ...
    'RandXTranslation',[-10 10], ...
    'RandYTranslation',[-10 10]);

[dim_1, dim_2, dim_3] = size(utils.matReader(imds.Files{1}));
num_cats = length(categories(imds.Labels));

augimds = augmentedImageDatastore([dim_1 dim_2 dim_3],imdsTrain,'DataAugmentation',imageAugmenter);

layers = [
    imageInputLayer([dim_1 dim_2 dim_3])

    convolution2dLayer(8,16,'Padding',[1 1 1 1],'stride',[4 4], 'NumChannels',dim_3)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2)

    convolution2dLayer(4,32,'Padding','same','stride',[2 2])
    batchNormalizationLayer
    reluLayer

    %maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(100)
    fullyConnectedLayer(num_cats)
    softmaxLayer
    classificationLayer];
% -------------------------------------------------------------
miniBatchSize  = 256;
options = trainingOptions('adam', ... %'sgdm'
    'MiniBatchSize',miniBatchSize, ...
    'ExecutionEnvironment','multi-gpu',...
    'MaxEpochs',1000, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','none', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',100, ...
    'ValidationData',imdsTest, ...
    'ValidationFrequency',10, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',true);
% -------------------------------------------------------------
%minibatch = preview(augimds);
end