function [XL,yl,XS,YS,beta Rsquared_v SE_v num_outliers ncomp stats] = PLS_reg(spectra,variable,fold,treatment)
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

%------------------

f=figure;
set(gcf,'position',[320,101,750,780]);
hp1=uipanel('position',[0 .25 0.75 .75]);
hp2=uipanel('position',[0 0 0.75 .25]);
hp3=uipanel('position',[0.75 0 0.25 1]);
CB1 = uicontrol('Parent',hp3,'Position',[25 700 1100 15],...
    'Style','checkbox','String','Z-Score','FontSize',10,...
    'Callback',@(spectra,variable,ncomp) plot.PLS_reg);


Y=variable;% Protien ISI(inds==1);
%+T.VarName14;

%randomize observations and validations
indperm=fold; %randperm(length(Y));
Y(indperm)=Y;
spectra_diff(:,indperm)=spectra_diff;
%---------------------------------------
ind_GP_0=find(Y==0 | isnan(Y));
spectra_GP=spectra_diff;
spectra_GP(:,ind_GP_0)=[];
Y(ind_GP_0)=[];

N=floor(size(spectra_GP,2)*0.75);
%N=501;
%N
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
num_outliers = length(ind_out);
%second calculation after outlier removal ------------------------------
% X(ind_out,:)=[];
% y(ind_out)=[];
% XV(ind_out_v,:)=[];
% yV(ind_out_v)=[];

    % Do PLS using 1:30 components------------------------------------------
    for i=1:30

    [XL,yl,XS,YS,beta,PCTVAR,mse] = plsregress(X,y,i);
    yfit = [ones(size(X,1),1) X]*beta;
    yfitv = [ones(size(XV,1),1) XV]*beta;

    TSS = sum((y-mean(y)).^2);
    RSS(i) = sum((y-yfit).^2);
    Rsquared(i) = 1 - RSS(i)/TSS;

    TSS = sum((yV-mean(yV)).^2);
    RSS_v(i) = sum((yV-yfitv).^2);
    Rsquared_v(i) = 1 - RSS_v(i)/TSS;
    end
    ncomp=find(RSS_v==min(RSS_v));
    %ncomp = 7;
    %-----------------------------------------------------------------------
[XL,yl,XS,YS,beta,PCTVAR,mse,stats] = plsregress(X,y,ncomp);
yfit = [ones(size(X,1),1) X]*beta;
residuals=y-yfit;
yfitv = [ones(size(XV,1),1) XV]*beta;
residuals_v=yV-yfitv;

% ------------------------------------------------------------------------
TSS = sum((y-mean(y)).^2);
RSS = sum((y-yfit).^2);
Rsquared = 1 - RSS/TSS;
SE = sqrt(RSS./length(y));

TSS = sum((yV-mean(yV)).^2);
RSS_v = sum((yV-yfitv).^2);
Rsquared_v = 1 - RSS_v/TSS;
SE_v = sqrt(RSS_v./length(yV));

md_train = fitlm(y,yfit,'y~x1+1')
anova(md_train)
md_val = fitlm(yV,yfitv,'y~x1+1')
anova(md_val)


Ycomb=[y; yV];
Y_fit=[yfit; yfitv];
y_cell=cell(repmat(cell({'Calibration'}),[length(y) 1]));
yV_cell=cell(repmat(cell({'Validation'}),[length(yV) 1]));
y_cells=[y_cell; yV_cell];



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
x = linspace(min(y),max(y),100);
hold on
plot(x,md_train.Coefficients.Estimate(2)*x+md_train.Coefficients.Estimate(1),'red','LineWidth',0.5);
hold on
plot(x,md_val.Coefficients.Estimate(2)*x+md_val.Coefficients.Estimate(1),'red','LineStyle','--','LineWidth',0.5);
%------------- TextBox -----------------------------------
dim = [.47 .15 .14 .16];
dim2 = [0.13,0.52,0.16,0.11]; 


R_2_str = strcat('R_{cal}^2 = ',{' '},num2str(Rsquared,'%4.3f'));
R_2_str_v = strcat('R_{val}^2 = ',{' '},num2str(Rsquared_v,'%4.3f'));
SE_str = strcat('SE_{cal} = ',{' '},num2str(SE,'%4.3f'));
SE_v_str = strcat('SE_{val} = ',{' '},num2str(SE_v,'%4.3f'));
N_cal = strcat('N_{cal} = ',{' '},num2str(length(y)));
N_cal_v = strcat('N_{val} = ',{' '},num2str(length(yV)));
ncomp_str=strcat('N_{components} =',{' '},num2str(ncomp));

str1 = [R_2_str,SE_str,R_2_str_v,SE_v_str];
str2 = [N_cal,N_cal_v,ncomp_str];
% annotation('textbox',dim1,...
%     'String',model_name,'FitBoxToText','off','Interpreter','none','EdgeColor','none');
handles=guihandles(f);

annotation(hp1(1).Parent,'textbox',dim,...
    'String',str1,'FitBoxToText','off','FontSize',8);
annotation(hp1(1).Parent,'textbox',dim2,...
    'String',str2,'FitBoxToText','off','FontSize',8);

%---------------------------------------------------------
bl3=uicontrol('Parent',hp3,'Style','popupmenu','Position',[25 600 100 15],...
                'String',{'1';'2';'3'},'BackgroundColor','white',...
                'min',0,'max',30);

CB2 = uicontrol('Parent',hp3,'Position',[25 680 1100 15],...
    'Style','checkbox','String','SG filter','FontSize',10);
%---------------------------------------------------------
ylabel('Y_{Predicted}')
xlabel('Y')
set(gca,'XAxisLocation','bottom')
set(gca,'YAxisLocation','left')
legend({'Calibration','Validation','Perfect Match','Train Regression','Val. Regression'})
axes('Parent',hp2);
[y_sorted, y_order] = sort(y);
stem(residuals(y_order),'MarkerSize',2)
hold on
[y_v_sorted, y_v_order] = sort(yV);
stem(residuals_v(y_v_order),'MarkerSize',2)
xlabel('Observation (Y sorted, low to high)')
ylabel('Residual')