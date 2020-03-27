function [JJ sample W H A]=multi2mat(folder)
%folder='C:\MATLAB\Eyefoss\Corteva\Corteva';
tic
N=500;
files = dir(folder);
for i=3:length(files)
    names(i)=string(files(i).name);
end
names=rmmissing(names);
%names=names(1:2);
%W=zeros(length(names),250,'single');
%H=zeros(length(names),250,'single');
JJ=zeros(150,150,7,length(names)*N,'single'); %length(names)*N
for i=1:length(names)
    %blobs=dir(strcat(folder,'\',names(i),'\ObjectImages\ImageData\decompressed\*.hips'));
   % length(blobs)/3
    sample_i=repmat(names(i),[N 1]);

    if i==1
        sample=repmat(names(1),[N 1]);
    else
        sample=[sample;sample_i];        
    end
    
    
    J=zeros(150,150,7,'single'); % 7
    
    for j=1:N%length(blobs)/3
        
        
        blob_name=strcat('blob_0',sprintf('%04d.hips',j-1))
        
        [MultiSpecStruct,maskStruct,rngStruct] = ...
        readHIPSstructures(strcat(folder,'\',char(names(i)),'\ObjectImages\ImageData\decompressed\'),...
        char(blob_name));
        [width height] = utils.bounding_dims(MultiSpecStruct.Image,maskStruct.Image);
        W(i,j)=width;
        H(i,j)=height;
%        if isnan(MultiSpecStruct.Image(1))
%            I=zeros(150,150,6);
%        else    
           I=MultiSpecStruct.Image.*maskStruct.Image;
           %I=rngStruct.Image.*maskStruct.Image; % restore back to top
           I(:,:,7)=rngStruct.Image.*maskStruct.Image;
           H_data=rngStruct.Image.*maskStruct.Image;
           A(i,j)=prctile(reshape(H_data,[size(H_data,1)*size(H_data,2) 1]),95);  
           I=single(I);
%        end
        %imshow(I(:,:,[5 3 1])./256) %[5 3 1]) is RGB
        %crop each channel in a loop. Can make this more efficient later
        [w, l, c]=size(I);
        if (w>150 | l>150)==1
           padded=[];%ones(150,150,6,'single');
        else
           padded = padarray(I,[floor((150-w)/2) floor((150-l)/2)],0);
        end
        %padded = imresize(padded,[100 100]); % resize images to 100X100 pixels
           [wp, lp, cp]=size(padded);
           J(1:wp,1:lp,1:cp) = padded;
           %imshow(J(:,:,[5 3 1])./255)
           if j==1
             J_1=J;
           else
             J_1=cat(4,J_1,J);
           end
    end
    
    %if i==1
    %   JJ=J_1;
    %else
       %JJ=cat(4,JJ,J_1);
       JJ(:,:,:,(N*(i-1)+1):N*i)=J_1;
       clear J_1
end
toc   
end