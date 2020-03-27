function [sample, c1, c2, c3, c4, c5, c6, Area_p,...
    W, H, A, Circularity, Eccentricity,...
    EquivDiameter, Perimeter]=multi2dist(folder)
%folder='C:\MATLAB\Eyefoss\Corteva\Corteva';
N=1000;
files = dir(folder);
for i=3:length(files)
    names(i)=string(files(i).name);
end
names=rmmissing(names);
%names=names(1:10);
%W=zeros(length(names),250,'single');
%H=zeros(length(names),250,'single');
sample = names';

%preallocate
%sample = strings(length(names));
c1 = zeros(length(names),N);
c2 = zeros(length(names),N);
c3 = zeros(length(names),N);
c4 = zeros(length(names),N);
c5 = zeros(length(names),N);
c6 = zeros(length(names),N);
Area_p = zeros(length(names),N);
W = zeros(length(names),N);
H = zeros(length(names),N);
A = zeros(length(names),N);
Eccentricity = zeros(length(names),N);
EquivDiameter = zeros(length(names),N);
Circularity = zeros(length(names),N);
Perimeter = zeros(length(names),N);

parfor i=1:length(names)
   % blobs=dir(strcat(folder,'\',names(i),'\ObjectImages\ImageData\decompressed\*.hips'));
   % length(blobs)/3
      
    for j=1:N%length(blobs)/3
        
        
        blob_name=strcat('blob_0',sprintf('%04d.hips',j-1));
        if isfile(strcat(folder,'\',char(names(i)),...
                '\ObjectImages\ImageData\',char(blob_name)))
        
        [MultiSpecStruct,maskStruct,rngStruct] = ...
        readHIPSstructures(strcat(folder,'\',char(names(i)),'\ObjectImages\ImageData\'),...
        char(blob_name));
        [width height] = utils.bounding_dims(MultiSpecStruct.Image,maskStruct.Image);
        W(i,j)=width;
        H(i,j)=height;
        I=MultiSpecStruct.Image.*maskStruct.Image;
        c1(i,j) = mean(nonzeros(I(:,:,1)./255));
        c2(i,j) = mean(nonzeros(I(:,:,2)./255));
        c3(i,j) = mean(nonzeros(I(:,:,3) ./255));
        c4(i,j) = mean(nonzeros(I(:,:,4)./255));
        c5(i,j) = mean(nonzeros(I(:,:,5)./255));
        c6(i,j) = mean(nonzeros(I(:,:,6)./255));
        
        stats = regionprops(maskStruct.Image,'Circularity',...
        'Eccentricity','EquivDiameter','Perimeter');
        Eccentricity(i,j) = stats.Eccentricity;
        EquivDiameter(i,j) = stats.EquivDiameter;
        Circularity(i,j) = stats.Circularity;
        Perimeter(i,j) = stats.Perimeter;

        Area_p(i,j) = size(nonzeros(maskStruct.Image),1);

        H_data=rngStruct.Image.*maskStruct.Image;
        A(i,j)=prctile(reshape(H_data,[size(H_data,1)*size(H_data,2) 1]),95);  
        else
            continue
        end %end while loop
    end
end
   
end