
function [XTrain YTrain XValidation YValidation]=NIR_fold(spectra,variable,fold)

spectra_diff=spectra;
Y=variable;
%---------------------------------------
indperm=fold; %randperm(length(Y));
Y(indperm)=Y;
spectra_diff(:,indperm)=spectra_diff;

%---------------------------------------
ind_GP_0=find(Y==0 | isnan(Y));
spectra_diff(:,ind_GP_0)=[];
Y(ind_GP_0)=[];
%---------------------------------------
N=floor(size(spectra_diff,2)*3/4);

plot(spectra)

XTrain(1,:,1,:)=spectra_diff(:,1:N);
YTrain=Y(1:N);
XValidation(1,:,1,:)=spectra_diff(:,N+1:end);
YValidation=Y(N+1:end);
end