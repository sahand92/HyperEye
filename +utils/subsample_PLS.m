function [RSQ, SEP] = subsample_PLS(spectra,variable)
for i=1:10
    n = size(spectra,1);
    fold = randperm(n);
    [~,Rsquared_v, SE_v, num_outliers, ncomp] = plot.PLS_reg(spectra,variable,fold);
    
    RSQ_val(i) = Rsquared_v;
    SEP_val(i) = SE_v;
    outlier_count(i) = num_outliers;
    component_count(i)= ncomp;
end

RSQ = [mean(RSQ_val) std(RSQ_val)];
SEP = [mean(SEP_val) std(SEP_val)];
end