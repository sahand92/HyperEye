function patchOut = augmentmat(patchIn,flag)

isValidationData = strcmp(flag,'validation');

InputImage = cell(size(patchIn,1),1);
inpResponse = cell(size(patchIn,1),1);

% 5 augmentations: nil,rot90,fliplr,flipud,rot90(fliplr)
fliprot = @(x) rot90(fliplr(x));
noise = @(x) imnoise(x,'gaussian');
warm = @(x) chromadapt(x,[245 243 255]);
cold = @(x) chromadapt(x,[255 243 239]);
blurred = @(x) imfilter(x,fspecial('average',5),'replicate');
fliplr_blurred = @(x) blurred(fliplr(x));
augType = {@rot90,@fliplr,@flipud,fliprot,noise,blurred,...
    fliplr_blurred,warm,cold,...
warm,cold,warm,cold};
 
for id=1:size(patchIn,1) 
    rndIdx = randi(7,1);
    tmpImg =  patchIn.InputImage{id};
    tmpResp = patchIn.ResponsePixelLabelImage{id};

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
        if rndIdx >= 5
            respOut = tmpResp;
        else
            respOut = augType{rndIdx}(tmpResp);
        end
            
    
    respFinal=respOut;%respOut(45:end-44,45:end-44,:);
    
    InputImage{id,1}= out;
    inpResponse{id,1}=respFinal;

end
patchOut = table(InputImage,inpResponse);