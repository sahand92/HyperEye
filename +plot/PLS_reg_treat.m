function [Rsquared RMSE ncomp Beta stats] = PLS_reg_treat(spectra,variable,fold,treatment)
%clearvars -except T spectra variable ncomp
rd = 2;
fl = 11;

edge_pts = 5;

if treatment == 'raw'
    spectra_diff = spectra(:,edge_pts:end-edge_pts)';
elseif treatment == 'MCS'
    spectra_diff = zscore(spectra(:,edge_pts:end-edge_pts)');
elseif treatment == 'SGF'
    spectra_diff = utils.sgolayfilt(zscore(spectra(:,edge_pts:end-edge_pts)'),rd,fl);
elseif treatment == '1st'
    [~, spectra_diff]=gradient(utils.sgolayfilt(zscore(spectra(:,edge_pts:end-edge_pts)'),rd,fl),1);
elseif treatment == '2nd'
    [~, spectra_diff]=gradient(utils.sgolayfilt(zscore(spectra(:,edge_pts:end-edge_pts)'),rd,fl),1);
    [~, spectra_diff]= gradient(spectra_diff,1);
else
    spectra_diff = 0;
end


Y=variable;

%randomize observations and validations
indperm=fold; %randperm(length(Y));
Y(indperm)=Y;
spectra_diff(:,indperm)=spectra_diff;
%---------------------------------------
ind_GP_0=find(Y==0 | isnan(Y) | isnan(spectra_diff(1,:)'));
spectra_GP=spectra_diff;
spectra_GP(:,ind_GP_0)=[];
Y(ind_GP_0)=[];


% cross validation
N=size(spectra_GP,2);
cv = cvpartition(N,'KFold',5);

numFolds = cv.NumTestSets;
RSS_v = zeros(1,5);
RSS_ncomp = zeros(1,30);

% optimize PLS components
for j = 1:30
    for i = 1:numFolds
        X = spectra_GP(:,training(cv,i))';
        y = Y(training(cv,i));
        
        XV = spectra_GP(:,test(cv,i))';
        yV = Y(test(cv,i));
        
        [XL,yl,XS,YS,beta,PCTVAR,mse] = plsregress(X,y,j);
        yfitv = [ones(size(XV,1),1) XV]*beta;
        RSS_v(i) = sum((yV-yfitv).^2);
    end
    RSS_ncomp(j) = mean(RSS_v);
end
ncomp = find(RSS_ncomp<prctile(RSS_ncomp,10),1);
%ncomp = 10
yData = nan(N,1);
yPred = nan(N,1);

% 5-fold CV with ncomp
    for i = 1:numFolds
        X = spectra_GP(:,training(cv,i))';
        y = Y(training(cv,i));
        
        XV = spectra_GP(:,test(cv,i))';
        yV = Y(test(cv,i));
        
        [XL,yl,XS,YS,beta,PCTVAR,mse,stats] = plsregress(X,y,ncomp);
        yfitv = [ones(size(XV,1),1) XV]*beta;
        yData(test(cv,i)) = yV;
        yPred(test(cv,i)) = yfitv;
        Beta(i,:) = beta;
    end
%figure
scatter(yData,yPred,10,...
    'MarkerEdgeColor','blue',...
    'MarkerFaceColor',[0.07,0.62,1.00],...
    'MarkerFaceAlpha',0.8)

TSS = sum((yData-mean(yData)).^2);
RSS = sum((yData-yPred).^2);
Rsquared = 1 - RSS/TSS;
RMSE = sqrt(RSS./length(yData));
% hold on
% line([0 max(yData)*1.05], [0 max(yData)*1.05]);
axis square
box on
% ------------------------------------------------------------------------
dim = [.47 .15 .19 .16];

R_2_str = strcat('R_{CV}^2 = ',{' '},num2str(Rsquared,'%4.3f'));
SE_str = strcat('RMSECV = ',{' '},num2str(RMSE,'%4.3f'));
N_str = strcat('N = ',{' '},num2str(length(yData)));
ncomp_str = strcat('No. comp. =',{' '},num2str(ncomp));

str1 = [R_2_str,SE_str,N_str,ncomp_str];

annotation('textbox',dim,...
    'String',str1,'FitBoxToText','off','FontSize',8,'Interpreter','tex');
