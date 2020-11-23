function createValidationPatches(imageDir,labelDir)

% imageDir = 'C:\Tagarno\chickpea_tagarno\cropped\Patches';
% labelDir = 'C:\Tagarno\chickpea_tagarno\labels\PixelLabelDataBG\patches';

% labelDir = 'C:\Tagarno\Jumbo\PixelLabelData\Patches';
% imageDir = 'C:\Tagarno\Jumbo\Images\Patches';


trainList = dir(fullfile(strcat(imageDir,'\','Training'), '*.png'));
trainFiles = {trainList.name};

labelList = dir(fullfile(strcat(labelDir,'\','Training'), '*.png'));
labelFiles = {labelList.name};


rand_ind = randperm(length(trainList));
val_ind = rand_ind(1:floor(length(trainList)*0.25));

for i = 1:length(val_ind)
    movefile(fullfile(strcat(imageDir,'\','Training'),trainFiles{val_ind(i)}),...
        fullfile(strcat(imageDir,'\','Validation')));
    
    movefile(fullfile(strcat(labelDir,'\','Training'),labelFiles{val_ind(i)}),...
        fullfile(strcat(labelDir,'\','Validation')));
end