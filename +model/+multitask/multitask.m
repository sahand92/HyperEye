clear XTrain XValidation
N=998;
fold1 = randperm(N);

spectra=Data.spectra;%rescale(Data.spectra,-1,1);

N=floor(3*N/4);
Y_1=Data.Protein(fold1);
Y_2=Data.Moisture(fold1);
Y_3=Data.Type(fold1);
spectra_fold=spectra(:,fold1);

ind_0=find(Y_1==0 | Y_2==0);
spectra_fold(:,ind_0)=[];
Y_1(ind_0)=[];
Y_2(ind_0)=[];
Y_3(ind_0)=[];

spectra_Train = spectra_fold(:,1:N);
YTrain_1 = Y_1(1:N);
YTrain_2 = Y_2(1:N);
YTrain_3 = Y_3(1:N);

spectra_val = spectra_fold(:,N+1:end);
YValidation_1 = Y_1(N+1:end);
YValidation_2 = Y_2(N+1:end);
YValidation_3 = Y_3(N+1:end);

XTrain(1,:,1,:) = spectra_Train;
XValidation(1,:,1,:) = spectra_val;


classNames = categories(YTrain_3);
numClasses = numel(classNames);
numObservations = numel(YTrain_1);

% Network -----------------------------------------------------------------
parameters.conv1.Weights = dlarray(model.multitask.initializeGaussian([1,10,1,8],599));
parameters.conv1.Bias = dlarray(zeros(1,1,8,'double'));

parameters.batchnorm1.Offset = dlarray(zeros([8,1,1],'double'));
parameters.batchnorm1.Scale = dlarray(ones(8,1,1,'double'));
state.batchnorm1.TrainedMean = zeros(8,1,1,'double');
state.batchnorm1.TrainedVariance  = ones(8,1,1,'double');


parameters.conv2.Weights = dlarray(model.multitask.initializeGaussian([1,4,8,32],464));%32
parameters.conv2.Bias = dlarray(zeros(1,1,32,'double'));

parameters.batchnorm2.Offset = dlarray(zeros(32,1,1,'double')); 
parameters.batchnorm2.Scale = dlarray(ones(32,1,1,'double'));
state.batchnorm2.TrainedMean = zeros(32,1,1,'double');
state.batchnorm2.TrainedVariance  = ones(32,1,1,'double');

parameters.conv3.Weights = dlarray(model.multitask.initializeGaussian([1,5,32,64],416));
parameters.conv3.Bias = dlarray(zeros(1,1,64,'double'));

parameters.batchnorm3.Offset = dlarray(zeros(64,1,1,'double'));
parameters.batchnorm3.Scale = dlarray(ones(64,1,1,'double'));
state.batchnorm3.TrainedMean = zeros(64,1,1,'double');
state.batchnorm3.TrainedVariance  = ones(64,1,1,'double');

parameters.conv4.Weights = dlarray(model.multitask.initializeGaussian([1,5,32,64],416));
parameters.conv4.Bias = dlarray(zeros(1,1,64,'double'));

parameters.batchnorm4.Offset = dlarray(zeros(64,1,1,'double'));
parameters.batchnorm4.Scale = dlarray(ones(64,1,1,'double'));
state.batchnorm4.TrainedMean = zeros(64,1,1,'double');
state.batchnorm4.TrainedVariance  = ones(64,1,1,'double');

parameters.conv5.Weights = dlarray(model.multitask.initializeGaussian([1,5,32,64],416));
parameters.conv5.Bias = dlarray(zeros(1,1,64,'double'));

parameters.batchnorm5.Offset = dlarray(zeros(64,1,1,'double'));
parameters.batchnorm5.Scale = dlarray(ones(64,1,1,'double'));
state.batchnorm5.TrainedMean = zeros(64,1,1,'double');
state.batchnorm5.TrainedVariance  = ones(64,1,1,'double');

parameters.fc3.Weights = dlarray(model.multitask.initializeGaussian([numClasses,320],320));
parameters.fc3.Bias = dlarray(zeros(numClasses,1,'double'));

parameters.fc1.Weights = dlarray(model.multitask.initializeGaussian([1,320],320));
parameters.fc1.Bias = dlarray(zeros(1,1,'double'));
% parameters.fc_1.Weights = dlarray(model.multitask.initializeGaussian([320,320],320));
% parameters.fc_1.Bias = dlarray(zeros(320,1,'double'));

parameters.fc2.Weights = dlarray(model.multitask.initializeGaussian([1,320],320));
parameters.fc2.Bias = dlarray(zeros(1,1,'double'));
% parameters.fc_2.Weights = dlarray(model.multitask.initializeGaussian([320,320],320));
% parameters.fc_2.Bias = dlarray(zeros(320,1,'double'));
% -------------------------------------------------------------------------
%Training options ---------------------------------------------------------
learnRate = 0.0001;
momentum = 0.9;
numEpochs = 1000;
miniBatchSize = 128;
plots = "training-progress";
trailingAvg = [];
trailingAvgSq = [];

numIterationsPerEpoch = floor(numObservations./miniBatchSize);
executionEnvironment = "auto";
%--------------------------------------------------------------------------
% Train model -------------------------------------------------------------
if plots == "training-progress"
    figure;
    hAxes(1)=gca;
    lineLossTrain = animatedline(hAxes(1));
    lineLossValidation = animatedline(hAxes(1),'LineStyle','--');
    xlabel("Iteration")
    ylabel("Loss")
end

    figure;
    hAxes(2)=gca;
    lineRMSETrain_1 = animatedline(hAxes(2));
    lineRMSETrain_2 = animatedline(hAxes(2),'Color','red');
    lineRMSEVal_1 = animatedline(hAxes(2),'LineStyle','--');
    lineRMSEVal_2 = animatedline(hAxes(2),'Color','red','LineStyle','--');
    xlabel("Iteration")
    ylabel("Training RMSE")
    
    figure;
    hAxes(3)=gca;
    lineAccuracy_3 = animatedline(hAxes(3),'Color','blue');
    lineAccuracyVal_3 = animatedline(hAxes(3),'Color','blue','LineStyle','--');
    xlabel("Iteration")
    ylabel("Training Accuracy")
    
    

iteration = 0;
start = tic;

Protein_RMSE = zeros(1,numEpochs*numIterationsPerEpoch);
Moisture_RMSE = zeros(1,numEpochs*numIterationsPerEpoch);
Protein_val_RMSE = zeros(1,numEpochs*numIterationsPerEpoch);
Moisture_val_RMSE = zeros(1,numEpochs*numIterationsPerEpoch);
Class_val_acc = zeros(1,numEpochs*numIterationsPerEpoch);
Class_acc = zeros(1,numEpochs*numIterationsPerEpoch);
Train_loss = zeros(1,numEpochs*numIterationsPerEpoch);
Val_loss = zeros(1,numEpochs*numIterationsPerEpoch);


% Loop over epochs.
for epoch = 1:numEpochs
    
    % Shuffle data.
    idx = randperm(numObservations);
    XTrain = XTrain(:,:,:,idx);
    YTrain_1 = YTrain_1(idx);
    YTrain_2 = YTrain_2(idx);
    YTrain_3 = YTrain_3(idx);
    
    % Loop over mini-batches
    for i = 1:numIterationsPerEpoch
        iteration = iteration + 1;
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        ind_it = (epoch-1)*numIterationsPerEpoch + i;
        % Read mini-batch of data and convert the labels to dummy
        % variables.
        X = XTrain(:,:,:,idx);
        
        Y1 = YTrain_1(idx)';
        Y1 = double(Y1);
        
        Y2 = YTrain_2(idx)';
        Y2 = double(Y2);
        
        Y3 = zeros(numClasses, miniBatchSize, 'double');
        for c = 1:numClasses
            Y3(c,YTrain_3(idx)==classNames(c)) = 1;
        end
        
        Y3_val = zeros(numClasses, miniBatchSize, 'double');
        for c = 1:numClasses
            Y3_val(c,YValidation_3==classNames(c)) = 1;
        end

        
        % Convert mini-batch of data to dlarray.
        dlX = dlarray(X,'SSCB');
        dlXV = dlarray(XValidation,'SSCB');

        
        % If training on a GPU, then convert data to gpuArray.
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "multi-gpu"
            dlX = gpuArray(dlX);
        end
        
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function.
        [gradients,state,loss] = dlfeval(@model.multitask.modelGradients, dlX, Y1, Y2, Y3, parameters, state);
        [gradientsV,stateV,lossV] = dlfeval(@model.multitask.modelGradients, dlXV,...
            YValidation_1', YValidation_2', Y3_val, parameters, state);

        % Update the network parameters using the Adam optimizer.
        [parameters,trailingAvg,trailingAvgSq] = adamupdate(parameters,gradients, ...
            trailingAvg,trailingAvgSq,iteration,learnRate);
        
        % Display the training progress.
        if plots == "training-progress"
            D = duration(0,0,toc(start),'Format','hh:mm:ss');
            addpoints(lineLossTrain,iteration,double(gather(extractdata(loss))))
            addpoints(lineLossValidation,iteration,double(gather(extractdata(lossV))))
        Train_loss(ind_it) =  gather(extractdata(loss));
        Val_loss(ind_it) = gather(extractdata(lossV));
            title("Epoch: " + epoch + ", Elapsed: " + string(D))
            drawnow
        end
        
        % Training Progress
       [dlYPred_1,dlYPred_2, dlYPred_3] = model.multitask.model_multitask(dlX, parameters,false,state);
       Y_1_RMSE = sqrt(mean((extractdata(dlYPred_1) - YTrain_1(idx)').^2));
       Y_2_RMSE = sqrt(mean((extractdata(dlYPred_2) - YTrain_2(idx)').^2));
       Protein_RMSE(ind_it)=gather(Y_1_RMSE);
       Moisture_RMSE(ind_it)=gather(Y_2_RMSE);

           addpoints(lineRMSETrain_1,iteration,double((Y_1_RMSE)))
           addpoints(lineRMSETrain_2,iteration,double((Y_2_RMSE)))
           drawnow
       [~,idx_class] = max(extractdata(dlYPred_3),[],1);
       labelsPred = classNames(idx_class);
       accuracy = mean(labelsPred==YTrain_3(idx));
       Class_acc(ind_it) = accuracy;
           addpoints(lineAccuracy_3,iteration,accuracy*100);
           drawnow
       
         % Validation Progress
       [dlYVal_1,dlYVal_2, dlYVal_3] = model.multitask.model_multitask(dlXV, parameters,false,state);
       YV_1_RMSE = sqrt(mean((extractdata(dlYVal_1) - YValidation_1').^2));
       YV_2_RMSE = sqrt(mean((extractdata(dlYVal_2) - YValidation_2').^2));
       Protein_val_RMSE(ind_it)=gather(YV_1_RMSE);
       Moisture_val_RMSE(ind_it)=gather(YV_2_RMSE);

           addpoints(lineRMSEVal_1,iteration,double((YV_1_RMSE)))
           addpoints(lineRMSEVal_2,iteration,double((YV_2_RMSE)))
           drawnow
       [~,idx_class_v] = max(extractdata(dlYVal_3),[],1);
       labelsPred = classNames(idx_class_v);
       accuracy = mean(labelsPred==YValidation_3);
       Class_val_acc(ind_it) = accuracy;
           addpoints(lineAccuracyVal_3,iteration,accuracy*100);
           drawnow
    end
end
