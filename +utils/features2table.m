function features2table(folder,sample, A_down, A_up, crease_depth,...
    down_area, down_area_int, down_area_rect,...
    up_area, up_area_int, up_area_rect,...
    H_down, H_up, W_down, W_up, ...
    orientation, germ_size, endosperm_size)


for i=1:length(sample)
  ind_out = isoutlier(A_down(i,:));  
  A_down(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(A_up(i,:));  
  A_up(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(crease_depth(i,:));  
  crease_depth(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(down_area(i,:));  
  down_area(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(down_area_int(i,:));  
  down_area_int(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(down_area_rect(i,:));  
  down_area_rect(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(up_area(i,:));  
  up_area(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(up_area_int(i,:));  
  up_area_int(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(up_area_rect(i,:));  
  up_area_rect(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(H_up(i,:));  
  H_up(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(H_down(i,:));  
  H_down(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(W_up(i,:));  
  W_up(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(W_down(i,:));  
  W_down(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(germ_size(i,:));  
  germ_size(i,ind_out) = nan;
end

for i=1:length(sample)
  ind_out = isoutlier(endosperm_size(i,:));  
  endosperm_size(i,ind_out) = nan;
end

for i=1:length(sample)
  N_up(i) = sum(orientation(i,:)==3); 
  N_down(i) = sum(orientation(i,:)==1); 
  N_other(i) = sum(orientation(i,:)==2); 
end

data_mean = [sample, N_up', N_down', N_other',...
    nanmean(A_up,2), nanmean(A_down,2), nanmean(W_up,2), ...
    nanmean(W_down,2), nanmean(H_up,2), nanmean(H_down,2),...
    nanmean(up_area,2), nanmean(up_area_int,2), nanmean(up_area_rect,2),...
    nanmean(down_area,2), nanmean(down_area_int,2), nanmean(down_area_rect,2), ...
    nanmean(germ_size,2),nanmean(endosperm_size,2), nanmean(crease_depth,2)];

data_std = [nanstd(A_up,0,2), nanstd(A_down,0,2), nanstd(W_up,0,2), ...
    nanstd(W_down,0,2), nanstd(H_up,0,2), nanstd(H_down,0,2),...
    nanstd(up_area,0,2), nanstd(up_area_int,0,2), nanstd(up_area_rect,0,2),...
    nanstd(down_area,0,2), nanstd(down_area_int,0,2), nanstd(down_area_rect,0,2), ...
    nanstd(germ_size,0,2),nanstd(endosperm_size,0,2),nanstd(crease_depth,0,2)];

table_all = array2table([data_mean,data_std],'VariableNames',{'barcode','N_up','N_down','N_other',...
    'A_up','A_down','W_up','W_down','H_up','H_down','up_area','up_area_int',...
    'up_area_rect','down_area','down_area_int','down_area_rect',...
    'germ_size','endosperm_size','crease_depth',...
    'A_up_std','A_down_std','W_up_std','W_down_std','H_up_std','H_down_std','up_area_std','up_area_int_std',...
    'up_area_rect_std','down_area_std','down_area_int_std','down_area_rect_std',...
    'germ_size_std','endosperm_size_std','crease_depth_std'});

%  mydir  = folder;
%  idcs   = strfind(mydir,'\');
%  ind_1 = idcs(length(idcs)-1)+1;
%  ind_2 = idcs(length(idcs))-1;

 newdir = 'MY_testset';%mydir(ind_1:ind_2);
writetable(table_all,strcat(newdir,'.xlsx'),'Sheet',1,'Range','D1');    