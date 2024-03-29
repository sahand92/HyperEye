
function net_regression(XTrain,YTrain,XValidation,YValidation,model_NN)

net = model_NN; 
YPredicted = predict(net,XTrain);
YPredicted_v = predict(net,XValidation);
residuals = YTrain-YPredicted;
residuals_v = YValidation-YPredicted_v;

md_train = fitlm(YTrain,YPredicted,'y~x1+1');
anova(md_train);
md_val = fitlm(YValidation,YPredicted_v,'y~x1+1');
anova(md_val);

%% figure ---------------------------------------------
TSS = sum((YTrain-mean(YTrain)).^2);
RSS = sum((YTrain-YPredicted).^2);
Rsquared = 1 - RSS/TSS;
SE = sqrt(RSS./length(YTrain));

TSS = sum((YValidation-mean(YPredicted_v)).^2);
RSS_v = sum((YValidation-YPredicted_v).^2);
Rsquared_v = 1 - RSS_v/TSS;
SE_v = sqrt(RSS_v./length(YValidation));

Ycomb=[YTrain; YValidation];
Y_fit=[YPredicted; YPredicted_v];
y_cell=cell(repmat(cell({'Training'}),[length(YTrain) 1]));
yV_cell=cell(repmat(cell({'Validation'}),[length(YValidation) 1]));
y_cells=[y_cell; yV_cell];

    f=figure;
    f.Color='W';
    set(gcf,'position',[320,101,600,780]);
    hp1=uipanel('position',[0 .25 1 .75]);
    hp2=uipanel('position',[0 0 1 .25]);
    hp1=scatterhist(Ycomb,Y_fit,'Direction','out','Kernel','off',...
        'Location','NorthEast','Group',y_cells,'Parent',hp1);
    hp1(1).Children(2).MarkerFaceColor=[.07 .62 1];
    hp1(1).Children(2).MarkerSize=3;
    hp1(1).Children(1).Marker='o';
    hp1(1).Children(1).MarkerSize=3;
    hp1(1).Children(1).LineWidth=1;
    hp1(2).Children(1).BinMethod='auto';
    hp1(2).Children(2).BinMethod='auto';
    hp1(3).Children(1).BinMethod='auto';
    hp1(3).Children(2).BinMethod='auto';
    hp1(1).Parent.BackgroundColor='W';
    hp2.BackgroundColor='W';
    
line([min(YTrain) max(YPredicted)],[min(YTrain) max(YPredicted)])
x = linspace(min(YTrain),max(YTrain),100);
hold on
plot(x,md_train.Coefficients.Estimate(2)*x+md_train.Coefficients.Estimate(1),...
    'red','LineWidth',0.5);
hold on
plot(x,md_val.Coefficients.Estimate(2)*x+md_val.Coefficients.Estimate(1),...
    'red','LineStyle','--','LineWidth',0.5);

%------------- TextBox -----------------------------------
dim = [.48 .12 .15 .2]; 
dim2 = [.14 .54 .14 .08]; 

R_2_str = strcat('R_{train}^2 = ',{' '},num2str(Rsquared,'%4.3f'));
R_2_str_v = strcat('R_{val}^2 = ',{' '},num2str(Rsquared_v,'%4.3f'));
SE_str = strcat('SE_{Train} = ',{' '},num2str(SE,'%4.3f'));
SE_v_str = strcat('SE_{val} = ',{' '},num2str(SE_v,'%4.3f'));
N_cal = strcat('N_{train} = ',{' '},num2str(length(YTrain)));
N_cal_v = strcat('N_{val} = ',{' '},num2str(length(YValidation)));
model_name = strcat('model : ',{' '},inputname(5));

str1 = [R_2_str,SE_str,R_2_str_v,SE_v_str,model_name];
str2 = [N_cal, N_cal_v];


annotation(hp1(1).Parent,'textbox',dim,...
    'String',str1,'FitBoxToText','off','FontSize',8);
annotation(hp1(1).Parent,'textbox',dim2,...
    'String',str2,'FitBoxToText','off','FontSize',8);
%---------------------------------------------------------
ylabel('Y_{Predicted}')
xlabel('Y')
set(gca,'XAxisLocation','bottom')
set(gca,'YAxisLocation','left')
legend({'Training','Validation','Perfect Match','Train Regression','Val. Regression'})
axes('Parent',hp2);
[~, y_order] = sort(YTrain);
stem(residuals(y_order),'MarkerSize',2)
hold on
[~, y_v_order] = sort(YValidation);
stem(residuals_v(y_v_order),'MarkerSize',2)
xlabel('Observation (Y sorted, low to high)')
ylabel('Residual')


end



