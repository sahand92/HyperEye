function decompress_hips_folder(folder)
%folder='C:\MATLAB\Eyefoss\Corteva\Corteva';
files = dir(folder);
for i=3:length(files)
    names(i)=string(files(i).name);
end
names=rmmissing(names);
    
for i = 1:length(names)
inputImageDataFolder = strcat(folder,'\',char(names(i)),'\ObjectImages\ImageData');
outputImageDataFolder = strcat(folder,'\',char(names(i)),'\ObjectImages\ImageData\decompressed');
decompressHIPSfiles(inputImageDataFolder,outputImageDataFolder);
end

end