function seed_dims=extract_dims(T)

table_height=size(T);
for i=1:table_height(1)
    filename=T.Filename(i);
    fullname=strcat('F:\Crease\EyeFoss_Images\C_up\',char(filename),'\ObjectImages\ImageData\decompressed\');
    if exist(strcat(fullname,'blob_00000.hips'))==2    
        [MultiSpecStruct,maskStruct,rngStruct] = readHIPSstructures(fullname,'blob_00000.hips');
        [width height] = utils.bounding_dims(MultiSpecStruct.Image,maskStruct.Image);
    else
        width=nan;
        height=nan;
    end
    W(i)=width;
    H(i)=height;
    barcode(i)=fprintf('%s\n',table2array(T(i,1)));

end
size(W)
size(H)
size(T)

    seed_dims=table(T.Filename,W',H');

end