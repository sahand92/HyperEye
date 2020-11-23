function orientation = Predict_wheat_orient(I,net_orient)

     [w, l, c]=size(I);
     imdim = 150;
     J = zeros(imdim,imdim,7,'single');
     if (w>imdim | l>imdim)==1
        padded=zeros(imdim,imdim,7,'single');
     else
        padded = padarray(I,[floor((imdim-w)/2) floor((imdim-l)/2)],0);
     end
     %padded = imresize(padded,[100 100]); % resize images to 100X100 pixels
     [wp, lp, cp]=size(padded);
     J(1:wp,1:lp,1:cp) = padded;
   
    [argvalue, argmax] = max(predict(net_orient,J));
    orientation = categorical(argmax,[1 2 3],{'down','other','up'});
end
    