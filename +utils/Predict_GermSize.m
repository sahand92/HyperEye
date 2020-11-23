function [GermSize EndospermSize] = Predict_GermSize(I,net_germ)

    I_rgb = I(:,:,[5 3 2]);
  
     [w, l, c]=size(I_rgb);
     imdim = 160;
     J = zeros(imdim,imdim,3,'uint8');
     if (w>imdim | l>imdim)==1
        padded=zeros(imdim,imdim,3,'uint8');
     else
        padded = padarray(I_rgb,[floor((imdim-w)/2) floor((imdim-l)/2)],0);
     end
     %padded = imresize(padded,[100 100]); % resize images to 100X100 pixels
     [wp, lp, cp]=size(padded);
     J(1:wp,1:lp,1:cp) = padded;
   
    L = semanticseg(J,net_germ);
    L_vector=reshape(L,[imdim*imdim 1]);
    label_counts = countcats(L_vector);
    GermSize = label_counts(1);
    EndospermSize = label_counts(2);
end
    