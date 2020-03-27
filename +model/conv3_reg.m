function [layers options] = conv3_reg(XTrain,YTrain,XValidation,YValidation)
% -------------------------------------------------------------
layers = [
    imageInputLayer([size(XTrain,1) size(XTrain,2) size(XTrain,3)],'Name','Input')

    convolution2dLayer([1 10],8,'Padding',[0 0 0 0],'stride',[1 5],'NumChannels',1,'Name','conv_1')
    batchNormalizationLayer('Name','BN_1')
    reluLayer('Name','relu_1')
    
    maxPooling2dLayer([1 3],'Stride',[1 2],'Name','MP_1')
    %dropoutLayer(0.1)

    convolution2dLayer([1 4],32,'Padding',[0 0 0 0],'stride',[1 2],'Name','conv_2')
    batchNormalizationLayer('Name','BN_2')
    reluLayer('Name','relu_2')
    
    maxPooling2dLayer([1 3],'Stride',[1 2],'Name','MP_2')
    %dropoutLayer(0.1)
  
    convolution2dLayer([1 5],64,'Padding',[0 0 0 0],'stride',[1 2],'Name','conv_3')
    batchNormalizationLayer('Name','BN_3')
    reluLayer('Name','relu_3')

    %maxPooling2dLayer([1 2],'Stride',2)

    fullyConnectedLayer(1,'Name','FC_1')
    regressionLayer('Name','regout_1')];
% -------------------------------------------------------------
miniBatchSize  = 128;%128;
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('adam', ... %'sgdm'
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',10000, ...
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
