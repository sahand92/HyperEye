function multi2datastore(folder)
%folder='F:\EyeFoss Data\Pulses\Lentils\DEFECTS\2019CQOF Frost Characterisation EF2 PNR17 07Jan2020\unzipped';
tic
files = dir(folder);
imdir='F:\EyeFoss Data\Pulses\Chickpeas\DEFECTS\DEFECTS\CFAHO19 Fractions EF1 PNR17 16Mar2020\Images\';
for i=3:length(files)
    names(i)=string(files(i).name);
end
names=rmmissing(names);
imdim=200;
%names=names_AG;
for i=1:length(names)
    blobs=dir(strcat(folder,'\',names(i),'\ObjectImages\ImageData\decompressed\*.hips'));
    
    for j=1:length(blobs)/3
        
        J=zeros(200,200,7,'uint8'); 
        
        blob_name=strcat('blob_0',sprintf('%04d.hips',j-1));
        
        [MultiSpecStruct,maskStruct,rngStruct] = ...
        readHIPSstructures(strcat(folder,'\',char(names(i)),'\ObjectImages\ImageData\decompressed\'),...
        char(blob_name));
%        if isnan(MultiSpecStruct.Image(1))
%            I=zeros(150,150,6);
%        else    
           I=MultiSpecStruct.Image.*maskStruct.Image;
           %I=rngStruct.Image.*maskStruct.Image; % restore back to top
           I(:,:,7)=rngStruct.Image.*maskStruct.Image;
%        end
       
        %crop each channel in a loop. Can make this more efficient later
        [w, l, c]=size(I);
        if (w>imdim | l>imdim)==1
           J=[];%ones(imdim,imdim,7,'uint8');
        else
           padded = padarray(I,[floor((imdim-w)/2) floor((imdim-l)/2)],0);
           [wp, lp, cp]=size(padded);
           J(1:wp,1:lp,1:cp) = padded;
           
             if contains(names(i),'-A')==1
                save((strcat(imdir,'A\',num2str(i),sprintf('%04d.mat',j-1))),'J');
             elseif contains(names(i),'-B')==1
                save((strcat(imdir,'B\',num2str(i),sprintf('%04d.mat',j-1))),'J');
             elseif contains(names(i),'-C')==1
                save((strcat(imdir,'C\',num2str(i),sprintf('%04d.mat',j-1))),'J');
             elseif contains(names(i),'-D')==1
                save((strcat(imdir,'D\',num2str(i),sprintf('%04d.mat',j-1))),'J');
             else
                save((strcat(imdir,'E\',num2str(i),sprintf('%04d.mat',j-1))),'J');
             end
        end
        %padded = imresize(padded,[100 100]); % resize images to 100X100 pixels
           
           %imshow(J(:,:,[5 3 1])./255)

        clear J
             
    end
end
toc   
end