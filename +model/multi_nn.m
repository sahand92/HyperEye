function [lgraph,options,XTrain,YTrain,XValidation,YValidation] = multi_nn(spectra,var1)
%clearvars -except T spectra var1 var2

%spectra=table2array(T(:,17:end));
%var=T.VarName6;

spectra_diff=(diff(spectra(:,370:end-80),2,2));
rd = 2;
fl = 11;
spectra_diff = utils.sgolayfilt(spectra_diff',rd,fl);
spectra_diff=zscore(spectra_diff);

Y=var1;%[var1 var2];
%-----------------------------------------
%randomize observations and validations
indperm=randperm(length(Y));
Y(indperm,:)=Y;
spectra_diff(:,indperm)=spectra_diff;
%-----------------------------------------
%remove rows of Y with 0 value
[ind_spec_row ind_spec_col]=find(Y==0);
ind_spec_0=unique(ind_spec_row);
spectra_var=spectra_diff;
spectra_var(:,ind_spec_0)=[];
Y(ind_spec_0,:)=[];
%-----------------------------------------
%prepare Training and Validation data for NN
N=floor(size(spectra_var,2)*3/4);
XTrain(1,:,1,:)=spectra_var(:,1:N);
YTrain=Y(1:N,:);
XValidation(1,:,1,:)=spectra_var(:,N+1:end);
YValidation=Y(N+1:end,:);
%-----------------------------------------
layers = [
    imageInputLayer([size(XTrain,1) size(XTrain,2) size(XTrain,3)],'Name','input')

    convolution2dLayer([1 10],8,'Padding',[0 0 0 0],'stride',[1 5],'NumChannels',1,'Name','conv_1')
    batchNormalizationLayer('Name','BN_1')
    reluLayer('Name','relu_1')
    
    maxPooling2dLayer([1 3],'Stride',[1 2],'Name','MP_1')
    dropoutLayer(0.1,'Name','Drop_1')

    convolution2dLayer([1 4],32,'Padding',[0 0 0 0],'stride',[1 2],'Name','conv_2')
    batchNormalizationLayer('Name','BN_2')
    reluLayer('Name','relu_2')
    
    maxPooling2dLayer([1 3],'Stride',[1 2],'Name','MP_2')
    dropoutLayer(0.1,'Name','Drop_2')
  
    convolution2dLayer([1 5],64,'Padding',[0 0 0 0],'stride',[1 2],'Name','conv_3')
    batchNormalizationLayer('Name','BN_3')
    reluLayer('Name','relu_3')

    %maxPooling2dLayer([1 2],'Stride',2)
];

lgraph=layerGraph(layers);

skipConv = convolution2dLayer([1 38],64,'Padding',[0 0 0 0],'stride',[1 20],'Name','skipConv');
lgraph = addLayers(lgraph,skipConv);
lgraph = connectLayers(lgraph,'relu_1','skipConv');

add = additionLayer(2,'Name','add_1');
lgraph = addLayers(lgraph,add);

lgraph = connectLayers(lgraph,'skipConv','add_1/in1');
lgraph = connectLayers(lgraph,'relu_3','add_1/in2');

lgraph = addLayers(lgraph, fullyConnectedLayer(1,'Name','fc_1'));
lgraph = connectLayers(lgraph,'add_1','fc_1');

lgraph = addLayers(lgraph, regressionLayer('Name','reg_1'));
lgraph = connectLayers(lgraph,'fc_1','reg_1');



% lgraph = addLayers(lgraph, fullyConnectedLayer(1,'Name','fc_2'));
% lgraph = connectLayers(lgraph,'relu_3','fc_2');
% lgraph = addLayers(lgraph, regressionLayer('Name','reg_2'));
% lgraph = connectLayers(lgraph,'fc_2','reg_2');
% -------------------------------------------------------------
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
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',true);
% -------------------------------------------------------------
end

