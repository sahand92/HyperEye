clear XTrain XValidation
fold1 = randperm(700);

spectra=rescale(Data.spectra,-1,1);

spectra_Train = spectra(:,fold1(1:500));
YTrain_1 = Data.Protein(fold1(1:500));
YTrain_2 = Data.Moisture(fold1(1:500));
YTrain_3 = Data.Type(fold1(1:500));

spectra_val = spectra(:,fold1(501:end));
YValidation_1 = Data.Protein(fold1(501:end));
YValidation_2 = Data.Moisture(fold1(501:end));
YValidation_3 = Data.Type(fold1(501:end));

XTrain(1,:,1,:) = spectra_Train;
XValidation(1,:,1,:) = spectra_val;


classNames = categories(YTrain_3);
numClasses = numel(classNames);
numObservations = numel(YTrain_1);

% Network -----------------------------------------------------------------
parameters.fc1.Weights = dlarray(model.multitask.initializeGaussian([80,599],599));
parameters.fc1.Bias = dlarray(zeros(80,1,'double'));

parameters.fc2.Weights = dlarray(model.multitask.initializeGaussian([80,80],80));
parameters.fc2.Bias = dlarray(zeros(80,1,'double'));

parameters.fc3.Weights = dlarray(model.multitask.initializeGaussian([80,80],80));
parameters.fc3.Bias = dlarray(zeros(80,1,'double'));

parameters.fc4.Weights = dlarray(model.multitask.initializeGaussian([80,80],80));
parameters.fc4.Bias = dlarray(zeros(80,1,'double'));

parameters.fc5.Weights = dlarray(model.multitask.initializeGaussian([80,80],80));
parameters.fc5.Bias = dlarray(zeros(80,1,'double'));

parameters.fc6.Weights = dlarray(model.multitask.initializeGaussian([1,80],80));
parameters.fc6.Bias = dlarray(zeros(1,1,'double'));

parameters.fc7.Weights = dlarray(model.multitask.initializeGaussian([1,80],80));
parameters.fc7.Bias = dlarray(zeros(1,1,'double'));

parameters.fc8.Weights = dlarray(model.multitask.initializeGaussian([4,80],80));
parameters.fc8.Bias = dlarray(zeros(4,1,'double'));

% -------------------------------------------------------------------------
%Training options ---------------------------------------------------------
learnRate = 0.0002;
momentum = 0.9;
numEpochs = 2000;
miniBatchSize = 128;
plots = "training-progress";
trailingAvg = [];
trailingAvgSq = [];

numIterationsPerEpoch = floor(numObservations./miniBatchSize);
executionEnvironment = "auto";
%--------------------------------------------------------------------------
% Train model -------------------------------------------------------------
if plots == "training-progress"
    %figure;
   % hAxes(1)=gca;
    lineLossTrain = animatedline(hAxes(1));
    lineLossValidation = animatedline(hAxes(1),'LineStyle','--');
    xlabel("Iteration")
    ylabel("Loss")
end

%     figure;
%     hAxes(2)=gca;
%     lineRMSETrain_1 = animatedline(hAxes(2));
%     lineRMSETrain_2 = animatedline(hAxes(2),'Color','red');
%     lineRMSEVal_1 = animatedline(hAxes(2),'LineStyle','--');
%     lineRMSEVal_2 = animatedline(hAxes(2),'Color','red','LineStyle','--');
%     xlabel("Iteration")
%     ylabel("Training RMSE")
%     
%     figure;
%     hAxes(3)=gca;
%     lineAccuracy_3 = animatedline(hAxes(3),'Color','blue');
%     lineAccuracyVal_3 = animatedline(hAxes(3),'Color','blue','LineStyle','--');
%     xlabel("Iteration")
%     ylabel("Training Accuracy")
%     
    

iteration = 0;
start = tic;

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
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            dlX = gpuArray(dlX);
        end
        
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function.
        [gradients,loss] = dlfeval(@model.multitask.modelGradients_MLP, dlX, Y1, Y2, Y3, parameters);
        [gradientsV,lossV] = dlfeval(@model.multitask.modelGradients_MLP, dlXV,...
            YValidation_1', YValidation_2', Y3_val, parameters);

        % Update the network parameters using the Adam optimizer.
        [parameters,trailingAvg,trailingAvgSq] = adamupdate(parameters,gradients, ...
            trailingAvg,trailingAvgSq,iteration,learnRate);
        
        % Display the training progress.
        if plots == "training-progress"
            D = duration(0,0,toc(start),'Format','hh:mm:ss');
            addpoints(lineLossTrain,iteration,double(gather(extractdata(loss))))
            addpoints(lineLossValidation,iteration,double(gather(extractdata(lossV))))

            title("Epoch: " + epoch + ", Elapsed: " + string(D))
            drawnow
        end
        
        % Training Progress
       [dlYPred_1,dlYPred_2, dlYPred_3] = model.multitask.model_multitask_MLP(dlX, parameters,false);
       Y_1_RMSE = sqrt(mean((extractdata(dlYPred_1) - YTrain_1(idx)').^2));
       Y_2_RMSE = sqrt(mean((extractdata(dlYPred_2) - YTrain_2(idx)').^2));

           addpoints(lineRMSETrain_1,iteration,double((Y_1_RMSE)))
           addpoints(lineRMSETrain_2,iteration,double((Y_2_RMSE)))
           drawnow
       [~,idx_class] = max(extractdata(dlYPred_3),[],1);
       labelsPred = classNames(idx_class);
       accuracy = mean(labelsPred==YTrain_3(idx));
           addpoints(lineAccuracy_3,iteration,accuracy*100);
           drawnow
         % Validation Progress
       [dlYVal_1,dlYVal_2, dlYVal_3] = model.multitask.model_multitask_MLP(dlXV, parameters,false);
       YV_1_RMSE = sqrt(mean((extractdata(dlYVal_1) - YValidation_1').^2));
       YV_2_RMSE = sqrt(mean((extractdata(dlYVal_2) - YValidation_2').^2));

           addpoints(lineRMSEVal_1,iteration,double((YV_1_RMSE)))
           addpoints(lineRMSEVal_2,iteration,double((YV_2_RMSE)))
           drawnow
       [~,idx_class_v] = max(extractdata(dlYVal_3),[],1);
       labelsPred = classNames(idx_class_v);
       accuracy = mean(labelsPred==YValidation_3);
           addpoints(lineAccuracyVal_3,iteration,accuracy*100);
           drawnow
    end
end
