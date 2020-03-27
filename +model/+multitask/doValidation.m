%[XValidation,YValidation_1,YValidation_2] = digitTest4DArrayData;

dlXValidation = dlarray(XValidation,'SSCB');
if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    dlXValidation = gpuArray(dlXValidation);
end

doTraining = false;
[dlYPred_1,dlYPred_2] = model.multitask.model_multitask(dlXValidation, parameters,doTraining,state);

Y_1_RMSE = sqrt(mean((extractdata(dlYPred_1) - YValidation_1').^2));
Y_2_RMSE = sqrt(mean((extractdata(dlYPred_2) - YValidation_2').^2));

%--------------------------------------------------------
dlXTrain = dlarray(XTrain,'SSCB');
if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    dlXTrain = gpuArray(dlXTrain);
end

doTraining = false;
[dlYPred_1,dlYPred_2] = model.multitask.model_multitask(dlXTrain, parameters,doTraining,state);

Y_1_RMSE = sqrt(mean((extractdata(dlYPred_1) - YTrain_1').^2));
Y_2_RMSE = sqrt(mean((extractdata(dlYPred_2) - YTrain_2').^2));

