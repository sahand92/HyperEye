function J_4D=HSI_predicted(J, net)
%applies neural net predictions to 4D array of hyperspectral data
%input: J is a 4D array of [width height channels samples], and the output
        % of utils.readHSIraw
        % net is a matlab deep learning neural network object. 
%output: The predictions of "net" are added as an extra channel to J.        
%--------------------------------------------------------------------
% discard the first 30, and last 12 channels.
J=J(:,:,30:end-12,:);  % consistent with size of NIR2HSI

%restructure J to appropriate size for doing predictions
[h, w, c, n] = size(J);
J = permute(J,[1 2 4 3]);
J = reshape(J,[w*h*n,c]).'; 
J_4D(1,:,1,:)=ones(size(J),'single')-J; %reflectance spectra from absorption spectra

%---------------------------------------------------------------------
%find the image pixels (exclude background) and edge pixels 
%where the average intensity is below 0.01, and exclude them before doing 
%predictions. 
ind_img=(ismember(squeeze(J_4D(1,:,:))',zeros([c,w*h*n],'single')','rows'))==0;
ind_edge=(mean(squeeze(J_4D))<0.01);

HS_predict_img=zeros([w*h*n,1],'single'); %initalize predictions as an array of zeros
HS_predict_img(ind_img) = predict(net,J_4D(1,:,1,ind_img)); %predict using net
HS_predict_img(ind_edge)=0; %set predictions of edge pixels to zero. 

% add prediction as (c+1)th channel
J_4D(1,c+1,1,:)=HS_predict_img;

% reshape to original image
J_4D = reshape(J_4D,[1,c+1,w*h,n]);
J_4D = permute(J_4D,[3 1 2 4]);
J_4D= reshape(J_4D,[w,h,c+1,n]);

end