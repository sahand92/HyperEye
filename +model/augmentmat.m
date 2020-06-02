function patchOut = augmentmat(patchIn,flag)

isValidationData = strcmp(flag,'validation');

InputImage = cell(size(patchIn,1),1);

% 5 augmentations: nil,rot90,fliplr,flipud,rot90(fliplr)
 fliprot = @(x) rot90(fliplr(x));
 augType = {@rot90,@fliplr,@flipud,fliprot};
for id=1:size(patchIn,1) 
    rndIdx = randi(4,1);
    tmpImg =  patchIn.InputImage{id};
%     if rndIdx > 4 || isValidationData
%         out =  tmpImg;
%         respOut = tmpResp;
%     else
%         out =  augType{rndIdx}(tmpImg);
%         respOut = augType{rndIdx}(tmpResp);
%     end
    % Crop the response to to the network's output.
    %respFinal=respOut(45:end-44,45:end-44,45:end-44,:);
    out =  augType{rndIdx}(tmpImg);
    
    InputImage{id,1}= out;
end
patchOut = table(InputImage);