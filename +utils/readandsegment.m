
function JJ = readandsegment(T,wavelengths)

% T: Table of sample names, where filenames are stored in column called 'Filename'
% wavelengths: array index of wavelengths used, e.g., [72,72*2,72*3] for
% RGB.

% Output JJ: 4-D image array. First 2 dims are the image pixels, dim 3 is 
% the channel, and dim 4 corresponds to samples.

for ii = 1:length(T.Filename)
    strcat('file:',{' '},string(ii),{' '},'of',{' '},...
        string(length(T.Filename))) %progress
   
    filename = strcat('E:\Hyperspectral Data\Pulse Market Class\Group_1\',...
    T.Filename(ii),'\measurement.raw');  

    D=utils.readHSIraw(filename);
    J = utils.segmentHSI(single(D));
    J_rgb=J(:,:,wavelengths,:);%J(:,:,[72,72*2,72*3],:);
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
 