function J = segmentHSI(D)
%removes background and segments images
tic;
% D: is an HSI image (3D array), outputted by readHSIraw 

% J: returns images of individual instances with the backgrounds removed.
%    J is a 4D array, with the 4th dimension containing the instances

% Removes the background using intensity thresholding
% backgroud pixels are given value of 1
% Use alternative methods in future (PCA, CNN, etc)
D=permute(D,[2 1 3]);
D_rgb=(1-D(:,:,50)); % pseudo-RGB from HSI image
D_adj = imadjust(D_rgb);
BW_mask=imbinarize(D_adj,0.06);
%BW_mask = ~BW_mask;
% use grayscale image to create binary mask 
D=D.*single(BW_mask); % apply mask to image
% D(D==0)=1; % make background white

%-------------------------------------------------------------------------
% use mask to recognize individual instances of the image
cc = bwconncomp(BW_mask);
stats = regionprops(cc, 'Area','Centroid','BoundingBox');
idx=find([stats.Area]>500); % minimum region size 4000
centroids=cat(1,stats.Centroid);
centroids=centroids(idx,:);
boundingbox=cat(1,stats.BoundingBox);
boundingbox=boundingbox(idx,:);
% 
%     figure
%     imshow(D_rgb)
%     hold on
%     plot(centroids(:,1),centroids(:,2),'b*','color','green')
%     hold on

%Bounding Box
J = ones(100,100,288,length(centroids),'single');

for k = 1 : length(centroids)
    thisBB = boundingbox(k,:);
%     rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
%     hold on
progress = strcat('segmenting:',{' '},string(k),{' '},'of',{' '},...
    string(length(centroids)),'\n'); %progress
fprintf(progress)
     for i=1:288/3 %crop each channel in a loop. Can make this more efficient later
        cropped = imcrop(D(:,:,(1+3*(i-1)):3*i),thisBB);
        [wc, lc, cc]=size(cropped);
        padded = padarray(cropped,[floor((520-wc)/2) floor((520-lc)/2)],0);
        %padded = imresize(padded,[100 100]); % resize images to 100X100 pixels
        [wp, lp, cp]=size(padded);
        J(1:lp,1:wp,(1+3*(i-1)):3*i,k) = permute(padded,[2 1 3]);
     end
end
toc;
end