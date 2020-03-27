function [JJ_f sample_f] = multi_std(JJ_1, sample)
% JJ_1: 5D array. 4th array seeds, 5th array sample
% JJ_1=reshape(JJ,[150 150 7 N_seeds N_samples]);
% sample: (N samples X N seeds) barcodes
N=100;
Area_p = zeros(N,500);
for i=1:N
    for j=1:500
    Area_p(i,j) = size(nonzeros(JJ_1(:,:,1,j,i)),1);
    end
end

stat_p=[mean(Area_p')' std(Area_p')'./2];

clear i
clear j
for i=1:N
ind_std = find(Area_p(i,:)>stat_p(i,1)-stat_p(i,2) & Area_p(i,:)<stat_p(i,1)+stat_p(i,2));
JJ_i1 = JJ_1(:,:,:,ind_std,1);
JJ_i = JJ_1(:,:,:,ind_std,i);

        if i==1
            JJ_f = JJ_i1;
        else
            JJ_f = cat(4,JJ_f, JJ_i);
        end
      
sample_i1 = sample(1,ind_std);
sample_i = sample(i,ind_std);

        if i==1
            sample_f = sample_i1;
        else
            sample_f = cat(2,sample_f, sample_i);
        end
end
