 function [dlY1,dlY2,dlY3] = model_multitask_MLP(dlX,parameters,doTraining)

% Fully-connected
W = parameters.fc1.Weights;
B = parameters.fc1.Bias;
dlY = fullyconnect(dlX,W,B);
dlY = relu(dlY);


% Fully-connected
W = parameters.fc2.Weights;
B = parameters.fc2.Bias;
dlY = fullyconnect(dlY,W,B);
dlY = relu(dlY);

% Fully-connect
W = parameters.fc3.Weights;
B = parameters.fc3.Bias;
dlYb1 = fullyconnect(dlY,W,B);
dlYb1 = relu(dlYb1);

% Fully-connect
W = parameters.fc4.Weights;
B = parameters.fc4.Bias;
dlYb2 = fullyconnect(dlY,W,B);
dlYb2 = relu(dlYb2);

% Fully-connect
W = parameters.fc5.Weights;
B = parameters.fc5.Bias;
dlYb3 = fullyconnect(dlY,W,B);
dlYb3 = relu(dlYb3);


% Fully connect
W = parameters.fc6.Weights;
B = parameters.fc6.Bias;
dlY1 = fullyconnect(dlYb1,W,B);

% Fully connect
W = parameters.fc7.Weights;
B = parameters.fc7.Bias;
dlY2 = fullyconnect(dlYb2,W,B);

% Fully connect
W = parameters.fc8.Weights;
B = parameters.fc8.Bias;
dlY3 = fullyconnect(dlYb3,W,B);
dlY3 = softmax(dlY3);
end