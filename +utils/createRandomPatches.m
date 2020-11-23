function createRandomPatches(imageDir,labelDir,patchSize,Npatch)
% create patches of images and pixel labels
fileList = dir(fullfile(imageDir, '*.png'));
ImageFiles = {fileList.name};

% ImageFiles = T.Image_files';
% patchSize = [160 160];
% Npatch = 100;

LabelfileList = dir(fullfile(labelDir, '*.png'));
LabelFiles = {LabelfileList.name};
LabelFiles = utils.natsortfiles(LabelFiles);

mkdir(imageDir,'Patches');
mkdir(labelDir,'Patches');

for i = 1:length(ImageFiles)
    
    I = imread(fullfile(imageDir,ImageFiles{i}));
    L = imread(fullfile(labelDir,LabelFiles{i}));
    
    for j = 1:Npatch
        rect = [randi(size(I,1)-patchSize(1)+1), ...
        randi(size(I,2)-patchSize(2)+1),...
        patchSize(1)-1,...
        patchSize(2)-1];
    
        I_patch = imcrop(I,rect);
        L_patch = imcrop(L,rect);
        
        imwrite(I_patch,char(strcat(imageDir,'\Patches\',ImageFiles{i},...
        sprintf('%05d',j),'.png')));
    
        imwrite(L_patch,char(strcat(labelDir,'\Patches\',ImageFiles{i},...
        sprintf('%05d',j),'.png')));
    end
end