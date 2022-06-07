function PLS_CV_P(spectra, trait, treatment)


ind_trait_0 = find(trait==0 | isnan(trait) | isnan(spectra(:,1)));
trait(ind_trait_0) = [];
spectra(ind_trait_0,:)=[];

ind_rnd = randperm(length(trait));
ind_cal = ind_rnd(1:floor(length(trait)*2/3));
ind_pred = ind_rnd(floor(length(trait)*2/3)+1:end);

h = figure;
[Rsquared RMSE ncomp Beta] = ...
    plot.PLS_reg_treat(spectra(ind_cal,:), trait(ind_cal), ind_cal, treatment);
fprintf('Cal mean = %4.2f \n',mean(trait(ind_cal)));
fprintf('Cal range = %4.2f to ',min(trait(ind_cal)));
fprintf('%4.2f \n',max(trait(ind_cal)));
fprintf('Cal std = %4.2f \n',std(trait(ind_cal)));
fprintf('Cal N = %4.2f \n',length(trait(ind_cal)));


beta = mean(Beta);

X = spectra(ind_pred,:);
% preprocessing
X = utils.preprocess_spectra(X, treatment);
X = X';
%-------------
y = trait(ind_pred);
trait_pred = [ones(size(X,1),1) X]*beta';
fprintf('Pred mean = %4.2f \n',mean(trait_pred));
fprintf('Pred range = %4.2f to ',min(trait_pred));
fprintf('%4.2f \n',max(trait_pred));
fprintf('Pred std = %4.2f \n',std(trait_pred));
fprintf('Pred N = %4.2f \n',length(trait_pred));


hold on
scatter(y,trait_pred,10,'v',...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1,0.27,0.27],...
    'MarkerFaceAlpha',0.8);

TSS = sum((y-mean(y)).^2);
RSS = sum((y-trait_pred).^2);
Rsquared = 1 - RSS/TSS;
RMSE = sqrt(RSS./length(y));

%-------------------------
dim = [.47 .15 .19 .16];
R_2_str = strcat('R_{P}^2 = ',{' '},num2str(Rsquared,'%4.3f'));
SE_str = strcat('RMSEP = ',{' '},num2str(RMSE,'%4.3f'));
N_str = strcat('N = ',{' '},num2str(length(y)));

str1 = [R_2_str,SE_str,N_str];

annotation('textbox',dim,...
    'String',str1,'FitBoxToText','off','FontSize',8,'Interpreter','tex');

%axis limits
Y = [y;trait_pred];
xlim([min(Y) max(Y)])
ylim([min(Y) max(Y)])
hold on
line([min(Y) max(Y)*1.05], [min(Y) max(Y)*1.05],'Color','black');
legend('Calibration set', 'Prediction set')
h.CurrentAxes.FontName='Times New Roman';
h.CurrentAxes.XMinorTick = 'on';
h.CurrentAxes.YMinorTick = 'on';
h.CurrentAxes.TickLength = [0.02 0.01];
h.CurrentAxes.LineWidth = 1;
h.CurrentAxes.Legend.EdgeColor = 'none';
h.Position = [2018.8,378.8,361,308];
%------------------------
