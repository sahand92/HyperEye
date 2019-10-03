[XTrain1,~,YTrain1] = digitTrain4DArrayData;
[XValidation1,~,YValidation1] = digitTest4DArrayData;


layers = [
   % imageInputLayer([28 28 1])
    imageInputLayer([100 100 11])

    convolution2dLayer([1 16],8,'Padding','same', 'NumChannels',1)
    batchNormalizationLayer
    reluLayer
    %dropoutLayer(0.1)

    
    maxPooling2dLayer([1 2],'Stride',2)

    convolution2dLayer([1 8],16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    %dropoutLayer(0.1)

    
    maxPooling2dLayer([1 2],'Stride',2)
  
    convolution2dLayer([1 4],32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    %dropoutLayer(0.1)

    
    maxPooling2dLayer([1 2],'Stride',2)

    
%     convolution2dLayer([1 3],64,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
    
    %dropoutLayer(0.2)
    %fullyConnectedLayer(128)
    %dropoutLayer(0.2)
    fullyConnectedLayer(5)
   % dropoutLayer(0.1)
   softmaxLayer
    ClassificationLayer];


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
    'ValidationData',{XValidation1,YValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',true);

XTrain(1,:,1,:) = DAS_spectra(1:15000,:)';
YTrain=GP(1:15000);

XValidation(1,:,1,:) = DAS_spectra(15000:end,:)';
YValidation=GP(15000:end);


imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-90,90], ...
    'RandXTranslation',[-10 10], ...
    'RandYTranslation',[-10 10]);
augimds = augmentedImageDatastore([100 100 3],XTrain1,YTrain,'DataAugmentation',imageAugmenter);
minibatch = preview(augimds);
imshow(imtile(minibatch.input));
net = trainNetwork(augimds,layers,options);
net = trainNetwork(XTrain1,YTrain,layers,options);

[argvalue, argmax] = max(YPredicted');
C=confusionmat(YTrain,argmax,'Order',{'setosa','versicolor','virginica'});

