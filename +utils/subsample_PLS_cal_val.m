function [RSQ, SEP] = subsample_PLS(spectra,variable,cals_trial,vals_trial)

for i=1:10
cals=cals_trial(i,:);
cals(cals==0)=[];
vals=vals_trial(i,:);
vals(vals==0)=[];

    [~,Rsquared_v, SE_v, num_outliers, ncomp] = ...
plot.PLS_reg_cal_val(spectra,variable,cals,vals);
    
    RSQ_val(i) = Rsquared_v;
    SEP_val(i) = SE_v;
    outlier_count(i) = num_outliers;
    component_count(i)= ncomp;
end

RSQ = [mean(RSQ_val) std(RSQ_val)];
SEP = [mean(SEP_val) std(SEP_val)];
end
