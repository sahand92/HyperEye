function [width height] = bounding_dims(M)
%I=MultiSpecStruct.Image;
%M=maskStruct.Image;
M=M(:,:,[5 3 2]);
M=imbinarize(rgb2gray(M),0);
cc = bwconncomp(M);
stats = regionprops(cc, 'Area','Centroid','BoundingBox');
idx=find([stats.Area]>1000 & [stats.Area]<100000); % minimum region size 4000
if isempty(idx)
    width=0;
    height=0;
else
centroids=cat(1,stats.Centroid);
centroids=centroids(idx,:);
boundingbox=cat(1,stats.BoundingBox);
boundingbox=boundingbox(idx,:);

% imshow(M);
% hold on
 thisBB = boundingbox;
% rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','w','LineWidth',1 );

width=thisBB(3);
height=thisBB(4);
end
%clf
end

