
function net_regression(XTrain,YTrain,model_NN)

net = model_NN; 
YPredicted = predict(net,XTrain);
scatter(YTrain,YPredicted,'black','.')

md1 = fitlm(YTrain,YPredicted,'y~x1-1');
hold on

x = linspace(min(YTrain),max(YTrain),100);
h = plot(md1.Coefficients.Estimate(1)*x+0,x,'red','LineWidth',2);
h.Parent.FontSize = 14;
xlabel('GP% Training')
ylabel('GP% Predicted')
box on

hold on


%------------- TextBox -----------------------------------
dim = [.6 .2 .22 .2]; 
dim1 = [.6 .12 .25 .15]; 


R_2_str = strcat('R^2 = ',{' '},num2str(md1.Rsquared.Ordinary));
RMSE_str = strcat('RMSE = ',{' '},num2str(md1.RMSE));
N_str = strcat('N = ',{' '},num2str(length(YPredicted)));
model_name = strcat('model : ',{' '},inputname(3));
str1 = [R_2_str,RMSE_str,N_str];

annotation('textbox',dim1,...
    'String',model_name,'FitBoxToText','off','Interpreter','none','EdgeColor','none');
  
annotation('textbox',dim,...
    'String',str1,'FitBoxToText','off');
%---------------------------------------------------------

end



