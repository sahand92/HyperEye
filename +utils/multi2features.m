function [sample, orientation, germ_size, endosperm_size,...
    up_area_int,up_area,up_area_rect, down_area_int,...
    down_area,down_area_rect, crease_depth,...
    W_up, H_up, A_up, W_down, H_down, A_down]=...
    multi2features(folder,net_orient,net_germ)

%folder='C:\MATLAB\Eyefoss\Corteva\Corteva';
N=2000;
files = dir(folder);
for i=3:length(files)
    names(i)=string(files(i).name);
end
names=rmmissing(names);
%names=names(1:10);
%W=zeros(length(names),250,'single');
%H=zeros(length(names),250,'single');
sample = names';
orientation = nan(length(names),N);
germ_size = nan(length(names),N);
up_area_int = nan(length(names),N);
up_area = nan(length(names),N);
up_area_rect = nan(length(names),N);
down_area_int = nan(length(names),N);
down_area = nan(length(names),N);
down_area_rect = nan(length(names),N);
W_up = nan(length(names),N);
H_up = nan(length(names),N);
A_up = nan(length(names),N);
W_down = nan(length(names),N);
H_down = nan(length(names),N);
A_down = nan(length(names),N);
crease_depth = nan(length(names),N);
endosperm_size = nan(length(names),N);

for i=1:length(names)
   % blobs=dir(strcat(folder,'\',names(i),'\ObjectImages\ImageData\decompressed\*.hips'));
   % length(blobs)/3
      
    for j=1:N%length(blobs)/3
        
        
        blob_name=strcat('blob_0',sprintf('%04d.hips',j-1));
        if isfile(strcat(folder,'\',char(names(i)),...
                '\ObjectImages\ImageData\',char(blob_name)))
        
        [MultiSpecStruct,maskStruct,rngStruct] = ...
        readHIPSstructures(strcat(folder,'\',char(names(i)),...
        '\ObjectImages\ImageData\'),... % \decompressed
        char(blob_name));
    
        I=MultiSpecStruct.Image.*maskStruct.Image;
        Ir = rngStruct.Image.*maskStruct.Image;
        orient = utils.Predict_wheat_orient(cat(3,I,Ir),net_orient);
        orientation(i,j) = orient;  
           if orient == 'other'
                continue
           elseif orient == 'up'
               germ_size(i,j) = nan;
               endosperm_size(i,j) = nan;
               [Area_int, Area, Area_rect] = utils.Calc_area(Ir);
               up_area_int(i,j) = Area_int;
               up_area(i,j) = Area;
               up_area_rect(i,j) = Area_rect;
               H_data=rngStruct.Image.*maskStruct.Image;
               A_up(i,j)=prctile(reshape(H_data,[size(H_data,1)*size(H_data,2) 1]),95);
               [width, height] = utils.bounding_dims(MultiSpecStruct.Image.*maskStruct.Image);
               W_up(i,j)=width;
               H_up(i,j)=height;
               crease_depth(i,j) = utils.Calc_crease(Ir);
           else
               [germsize, endsize] = utils.Predict_GermSize(I, net_germ);
               germ_size(i,j) = germsize;
               endosperm_size(i,j) = endsize;
               [Area_int, Area, Area_rect] = utils.Calc_area(Ir);
               down_area_int(i,j) = Area_int;
               down_area(i,j) = Area;
               down_area_rect(i,j) = Area_rect;
               H_data=rngStruct.Image.*maskStruct.Image;
               A_down(i,j)=prctile(reshape(H_data,[size(H_data,1)*size(H_data,2) 1]),95);
               [width, height] = utils.bounding_dims(MultiSpecStruct.Image.*maskStruct.Image);
               W_down(i,j)=width;
               H_down(i,j)=height;
               crease_depth(i,j) = nan;
           end
        else
            continue
        end %end while loop
    end
end
   
end