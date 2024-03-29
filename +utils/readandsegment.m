
function JJ = readandsegment(T,wavelengths,folder)
%segments multiple files and stacks the segments in a single array (JJ)
% T: Table of sample names, where filenames are stored in column called 'Filename'
% wavelengths: array index of wavelengths used, e.g., [72,72*2,72*3] for
% RGB. or [24:24:288-24] for class predictions
%Folder in which subfolders contain the .raw measurement files:
%e.g.: 'E:\Hyperspectral Data\Pulse Market Class\Group_1\'

% Output JJ: 4-D image array. First 2 dims are the image pixels, dim 3 is 
% the channel, and dim 4 corresponds to samples.

for ii = 1:length(T.Filename)
    strcat('file:',{' '},string(ii),{' '},'of',{' '},...
        string(length(T.Filename))) %progress
   
    filename = strcat(folder,...
    T.Filename(ii),'\measurement.raw');  

    D=utils.readHSIraw(filename);
    J = utils.segmentHSI(single(D));
    J_rgb=J(:,:,wavelengths,:);
        if ii==1
            JJ = J_rgb;
        else
            JJ = cat(4,JJ, J_rgb);
        end
    clear J_rgb
    clear J
    clear D
end
end
 