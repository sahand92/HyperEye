function J_4D=HSI_predicted(J, net)

% ind_nan=find((isnan(J_4D(:,:,))));
%J(isnan(J))=1;
J=J(:,:,10:end-12,:);  % consistent with size of NIR2HSI
[h, w, c, n] = size(J);
J = permute(J,[1 2 4 3]);
J = reshape(J,[w*h*n,c]).';
J_4D(1,:,1,:)=ones(size(J),'single')-J;


%---------------------------------------------------------------------

%Use model to predict GP

%ind_bg=(ismember(squeeze(J_4D(1,:,:))',zeros([c,w*h*n],'single')','rows'))==1;
ind_img=(ismember(squeeze(J_4D(1,:,:))',zeros([c,w*h*n],'single')','rows'))==0;
ind_edge=(mean(squeeze(J_4D))<0.01);

HS_predict_img=zeros(w*h*n,1);
HS_predict_img(ind_img) = predict(net,J_4D(1,:,1,ind_img));
HS_predict_img(ind_edge)=0;

% add prediction as (c+1)th channel
J_4D(1,c+1,1,:)=HS_predict_img;

% reshape to original image
J_4D = reshape(J_4D,[1,c+1,w*h,n]);
J_4D = permute(J_4D,[3 1 2 4]);
J_4D= reshape(J_4D,[w,h,c+1,n]);

end