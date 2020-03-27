function [FinalData]=do_PCA(Data)
DataAdjust = Data-mean(Data).*ones(size(Data));

coeffs = pca(DataAdjust);
FeatureVector=coeffs;
FinalData = FeatureVector'*DataAdjust';

figure
scatter(FinalData(1,:),FinalData(2,:));
xlabel('PC1')
ylabel('PC2')
end