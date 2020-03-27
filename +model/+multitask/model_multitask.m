 function [dlY1,dlY2,dlY3,state] = model_multitask(dlX,parameters,doTraining,state)

% Convolution
W = parameters.conv1.Weights;
B = parameters.conv1.Bias;
dlY = dlconv(dlX,W,B,'Padding',[0 0 0 0],'Stride',[1 5]);

% Batch normalization, ReLU
Offset = parameters.batchnorm1.Offset;
Scale = parameters.batchnorm1.Scale;
trainedMean = state.batchnorm1.TrainedMean;
trainedVariance = state.batchnorm1.TrainedVariance;

if doTraining
    [dlY,trainedMean,trainedVariance] = batchnorm(dlY,Offset,Scale,trainedMean,trainedVariance);
    
    % Update state
    state.batchnorm1.TrainedMean = trainedMean;
    state.batchnorm1.TrainedVariance = trainedVariance;
else
    dlY = batchnorm(dlY,Offset,Scale,trainedMean,trainedVariance);
end
dlY = relu(dlY);
dlY = maxpool(dlY,[1 3],'Stride',[1 2]);


% Convolution
W = parameters.conv2.Weights;
B = parameters.conv2.Bias;
dlY = dlconv(dlY,W,B,'Padding',[0 0 0 0],'Stride',[1 2]);

% Batch normalization, ReLU
Offset = parameters.batchnorm2.Offset;
Scale = parameters.batchnorm2.Scale;
trainedMean = state.batchnorm2.TrainedMean;
trainedVariance = state.batchnorm2.TrainedVariance;

if doTraining
    [dlY,trainedMean,trainedVariance] = batchnorm(dlY,Offset,Scale,trainedMean,trainedVariance);
    
    % Update state
    state.batchnorm2.TrainedMean = trainedMean;
    state.batchnorm2.TrainedVariance = trainedVariance;
else
    dlY = batchnorm(dlY,Offset,Scale,trainedMean,trainedVariance);
end
dlY = relu(dlY);
dlYmp = maxpool(dlY,[1 3],'Stride',[1 2]);

% Convolution
W = parameters.conv3.Weights;
B = parameters.conv3.Bias;
dlYb1 = dlconv(dlYmp,W,B,'Padding',[0 0 0 0],'Stride',[1 2]);

% Batch normalization
Offset = parameters.batchnorm3.Offset;
Scale = parameters.batchnorm3.Scale;
trainedMean = state.batchnorm3.TrainedMean;
trainedVariance = state.batchnorm3.TrainedVariance;

if doTraining
    [dlYb1,trainedMean,trainedVariance] = batchnorm(dlYb1,Offset,Scale,trainedMean,trainedVariance);
    
    % Update state
    state.batchnorm3.TrainedMean = trainedMean;
    state.batchnorm3.TrainedVariance = trainedVariance;
else
    dlYb1 = batchnorm(dlYb1,Offset,Scale,trainedMean,trainedVariance);
end

% ReLU
dlYb1 = relu(dlYb1);

% % Fully connect
% W = parameters.fc_1.Weights;
% B = parameters.fc_1.Bias;
% dlYb1 = fullyconnect(dlYb1,W,B);

W = parameters.fc1.Weights;
B = parameters.fc1.Bias;
dlY1 = fullyconnect(dlYb1,W,B);

% Branch 2 --------------------------------------------------------------
% Convolution
W = parameters.conv4.Weights;
B = parameters.conv4.Bias;
dlYb2 = dlconv(dlYmp,W,B,'Padding',[0 0 0 0],'Stride',[1 2]);

% Batch normalization
Offset = parameters.batchnorm4.Offset;
Scale = parameters.batchnorm4.Scale;
trainedMean = state.batchnorm4.TrainedMean;
trainedVariance = state.batchnorm4.TrainedVariance;

if doTraining
    [dlYb2,trainedMean,trainedVariance] = batchnorm(dlYb2,Offset,Scale,trainedMean,trainedVariance);
    
    % Update state
    state.batchnorm4.TrainedMean = trainedMean;
    state.batchnorm4.TrainedVariance = trainedVariance;
else
    dlYb2 = batchnorm(dlYb2,Offset,Scale,trainedMean,trainedVariance);
end

% ReLU
dlYb2 = relu(dlYb2);

% Fully connect
% W = parameters.fc_2.Weights;
% B = parameters.fc_2.Bias;
% dlYb2 = fullyconnect(dlYb2,W,B);

W = parameters.fc2.Weights;
B = parameters.fc2.Bias;
dlY2 = fullyconnect(dlYb2,W,B);

% Branch 3 --------------------------------------------------------------
% Convolution
W = parameters.conv5.Weights;
B = parameters.conv5.Bias;
dlYb3 = dlconv(dlYmp,W,B,'Padding',[0 0 0 0],'Stride',[1 2]);

% Batch normalization
Offset = parameters.batchnorm5.Offset;
Scale = parameters.batchnorm5.Scale;
trainedMean = state.batchnorm5.TrainedMean;
trainedVariance = state.batchnorm5.TrainedVariance;

if doTraining
    [dlYb3,trainedMean,trainedVariance] = batchnorm(dlYb3,Offset,Scale,trainedMean,trainedVariance);
    
    % Update state
    state.batchnorm5.TrainedMean = trainedMean;
    state.batchnorm5.TrainedVariance = trainedVariance;
else
    dlYb3 = batchnorm(dlYb3,Offset,Scale,trainedMean,trainedVariance);
end

% ReLU
dlYb3 = relu(dlYb3);

% Fully connect
W = parameters.fc3.Weights;
B = parameters.fc3.Bias;
dlY3 = fullyconnect(dlYb3,W,B);
dlY3 = softmax(dlY3);
end