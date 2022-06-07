function dist2table(sample, c1, c2, c3, c4, c5, c6, Area_p,...
    W, H, A, Circularity, Eccentricity,...
    EquivDiameter, Perimeter)


c1(c1==0)=nan;
c2(c2==0)=nan;
c3(c3==0)=nan;
c4(c4==0)=nan;
c5(c5==0)=nan;
c6(c6==0)=nan;

Area_p(Area_p==0)=nan;
for i=1:length(sample)
  ind_out = isoutlier(Area_p(i,:));  
  Area_p(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_nan = find(~isnan(c1(i,:)));
  N(i,1) = length(ind_nan);
end

W(W==0)=nan;
for i=1:length(sample)
  ind_out = isoutlier(W(i,:));  
  W(i,ind_out) = nan;
end

H(H==0)=nan;
for i=1:length(sample)
  ind_out = isoutlier(H(i,:));  
  H(i,ind_out) = nan;
end

A(A==0)=nan;
for i=1:length(sample)
  ind_out = isoutlier(A(i,:));  
  A(i,ind_out) = nan;
end

Circularity(Circularity==0)=nan;
Eccentricity(Eccentricity==0)=nan;
EquivDiameter(EquivDiameter==0)=nan;
Perimeter(Perimeter==0)=nan;

data_mean = [sample, N, nanmean(c1,2), nanmean(c2,2), nanmean(c3,2), ...
    nanmean(c4,2), nanmean(c5,2), nanmean(c6,2),...
    nanmean(Area_p,2), nanmean(W,2), nanmean(H,2), nanmean(A,2), ...
    nanmean(Circularity,2), nanmean(Eccentricity,2), ...
    nanmean(EquivDiameter,2),nanmean(Perimeter,2)];
data_std = [nanstd(c1,0,2), nanstd(c2,0,2), nanstd(c3,0,2), ...
    nanstd(c4,0,2), nanstd(c5,0,2), nanstd(c6,0,2),...
    nanstd(Area_p,0,2), nanstd(W,0,2), nanstd(H,0,2), nanstd(A,0,2), ...
    nanstd(Circularity,0,2), nanstd(Eccentricity,0,2), ...
    nanstd(EquivDiameter,0,2),nanstd(Perimeter,0,2)];

table_all = array2table([data_mean,data_std],'VariableNames',{'barcode','N','c1','c2',...
    'c3','c4','c5','c6','Area2D','W','H','A','Circ','Eccen','EquivDiam',...
    'Perim',...
    'c1_std','c2_std','c3_std','c4_std','c5_std','c6_std',...
    'Area2D_std','W_std','H_std','A_std','Circ_std',...
    'Eccen_std','EquivDiam_std','Perim_std'});

writetable(table_all,'MY_test_standard.xlsx','Sheet',1,'Range','D1');    