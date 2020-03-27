function im_HSI_pred = HSI_prediction(HSI_image,beta)
im_HSI = HSI_image(:,:,50:end-50);
[sr sc sch]=size(im_HSI);

im = reshape(im_HSI,[sr*sc,sch]);

 rd = 2;
 fl = 11;
im = utils.sgolayfilt(im,rd,fl);
im_predictions = [ones(size(im,1),1) im]*beta;

im_HSI_predictions=reshape(im_predictions,[sr sc 1]);
im_HSI_pred = im_HSI;
im_HSI_pred(:,:,sch+1) = im_HSI_predictions;
end
