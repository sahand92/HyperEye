function [Rsquared Rsquared_v] = PLS_reg(spectra,variable,ncomp)
%clearvars -except T spectra variable ncomp

%spectra=table2array(T(:,15:end));
%variable=T.VarName6;

spectra_diff=(diff(spectra(:,370:end-80),2,2));
%spectra_diff=(diff(spectra(:,50:end-50),2,2));
%spectra_diff(:,298:305)=ones(1,8).*(spectra_diff(:,297)+spectra_diff(:,306))./2;


%spectra_diff=spectra_diff';
%spectra_diff=lowpass(spectra_diff',50,length(spectra_diff));
rd = 2;
fl = 11;
spectra_diff = sgolayfilt(spectra_diff',rd,fl);
spectra_diff=zscore(spectra_diff);


%inds=kmeans(spectra_diff',3,'Distance','cityblock');

%spectra_diff=spectra_diff(:,inds==1);

Y=variable;% Protien ISI(inds==1);
%+T.VarName14;

%randomize observations and validations
indperm=randperm(length(Y));
Y(indperm)=Y;
spectra_diff(:,indperm)=spectra_diff;
%---------------------------------------
ind_GP_0=find(Y==0);
spectra_GP=spectra_diff;
spectra_GP(:,ind_GP_0)=[];
Y(ind_GP_0)=[];

N=floor(size(spectra_GP,2)*3/4);
X=spectra_GP(:,1:N)';
y=Y(1:N);
XV=spectra_GP(:,N+1:end)';
yV=Y(N+1:end);


[XL,yl,XS,YS,beta,PCTVAR,mse] = plsregress(X,y,5);

yfit = [ones(size(X,1),1) X]*beta;
residuals=y-yfit;
yfitv = [ones(size(XV,1),1) XV]*beta;
ind_out=find(isoutlier(residuals)==1);
residuals_v=yV-yfitv;
ind_out_v=find(isoutlier(residuals_v)==1);

% second calculation after outlier removal ------------------------------
X(ind_out,:)=[];
y(ind_out)=[];
% XV(ind_out_v,:)=[];
% yV(ind_out_v)=[];
[XL,yl,XS,YS,beta,PCTVAR,mse] = plsregress(X,y,ncomp);
yfit = [ones(size(X,1),1) X]*beta;
residuals=y-yfit;
yfitv = [ones(size(XV,1),1) XV]*beta;
residuals_v=yV-yfitv;



% ------------------------------------------------------------------------
TSS = sum((y-mean(y)).^2);
RSS = sum((y-yfit).^2);
Rsquared = 1 - RSS/TSS
SE = sqrt(RSS./length(y));

TSS = sum((yV-mean(yV)).^2);
RSS_v = sum((yV-yfitv).^2);
Rsquared_v = 1 - RSS_v/TSS
SE_v = sqrt(RSS_v./length(yV));


Ycomb=[y; yV];
Y_fit=[yfit; yfitv];
y_cell=cell(repmat(cell({'Calibration'}),[length(y) 1]));
yV_cell=cell(repmat(cell({'Validation'}),[length(yV) 1]));
y_cells=[y_cell; yV_cell];

f=figure;
set(gcf,'position',[320,101,600,780]);
hp1=uipanel('position',[0 .25 1 .75]);
hp2=uipanel('position',[0 0 1 .25]);
hp1=scatterhist(Ycomb,Y_fit,'Direction','out','Kernel','off',...
    'Location','NorthEast','Group',y_cells,'Parent',hp1);
hp1(1).Children(2).MarkerFaceColor=[.07 .62 1];
hp1(1).Children(2).MarkerSize=3;
%hp1(1).Children(1).MarkerFaceColor=[1 .41 .16];
hp1(1).Children(1).Marker='o';
hp1(1).Children(1).MarkerSize=3;
hp1(1).Children(1).LineWidth=1;

hp1(2).Children(1).BinMethod='auto';
hp1(2).Children(2).BinMethod='auto';
hp1(3).Children(1).BinMethod='auto';
hp1(3).Children(2).BinMethod='auto';

 hp1(1).Parent.BackgroundColor='W';
 hp2.BackgroundColor='W';
 f.Color='W';
line([min(y) max(yfit)],[min(y) max(yfit)])
%------------- TextBox -----------------------------------
dim = [.47 .15 .14 .16];
dim2 = [.14 .54 .14 .08]; 


R_2_str = strcat('R_{cal}^2 = ',{' '},num2str(Rsquared,'%4.3f'));
R_2_str_v = strcat('R_{val}^2 = ',{' '},num2str(Rsquared_v,'%4.3f'));
SE_str = strcat('SE_{cal} = ',{' '},num2str(SE,'%4.3f'));
SE_v_str = strcat('SE_{val} = ',{' '},num2str(SE_v,'%4.3f'));
N_cal = strcat('N_{cal} = ',{' '},num2str(length(y)));
N_cal_v = strcat('N_{val} = ',{' '},num2str(length(yV)));

str1 = [R_2_str,SE_str,R_2_str_v,SE_v_str];
str2 = [N_cal,N_cal_v];
% annotation('textbox',dim1,...
%     'String',model_name,'FitBoxToText','off','Interpreter','none','EdgeColor','none');
handles=guihandles(f);

annotation(hp1(1).Parent,'textbox',dim,...
    'String',str1,'FitBoxToText','off','FontSize',8);
annotation(hp1(1).Parent,'textbox',dim2,...
    'String',str2,'FitBoxToText','off','FontSize',8);
%---------------------------------------------------------
ylabel('Y_{Predicted}')
xlabel('Y')
set(gca,'XAxisLocation','bottom')
set(gca,'YAxisLocation','left')
legend({'Calibration','Validation','Perfect Match'})
axes('Parent',hp2);
[y_sorted, y_order] = sort(y);
stem(residuals(y_order),'MarkerSize',2)
hold on
[y_v_sorted, y_v_order] = sort(yV);
stem(residuals_v(y_v_order),'MarkerSize',2)
xlabel('Observation (Y sorted, low to high)')
ylabel('Residual')