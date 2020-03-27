function [XTrain YTrain XValidation YValidation]=prepare_training(spectra,Lab)

Y=Lab;
X=table2array(spectra);

Y(isnan(Lab))=[];
X(isnan(Lab),:)=[];
X(163,:)=[];
Y(163)=[];

%X=lowpass(X,20,length(X));

l_t=ceil(length(Y)*0.75);
XTrain(1,:,1,:)=X(1:l_t,:)';
%discard 50 channels from each side and diff
XTrain=diff(XTrain(1,360:end-50,1,:));

YTrain=Y(1:l_t);

XValidation(1,:,1,:)=X(l_t+1:end,:)';
%discard 50 channels from each side and diff
XValidation=diff(XValidation(1,360:end-50,1,:));

YValidation=Y(l_t+1:end);

end