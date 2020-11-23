function [Area_int, Area, Area_rect] = Calc_area(Ir)
% method 1: interpolate surf
     [l, w]=size(Ir);
     x = 1:w;
     y = 1:l;
     [X, Y] = meshgrid(x,y);
     z = Ir(:);
  [xq,yq] = meshgrid(1:0.5:w, 1:0.5:l);
  vq = griddata(X(:),Y(:),z,xq,yq,'natural');
  h_interp = surf(vq);   
  N_int = h_interp.VertexNormals;
  N_int_z = squeeze(N_int(:,:,3));
  N_int_z = N_int_z./sqrt(sum(N_int.^2,3));
  Area_int = sum(1./N_int_z(:)) - nnz(h_interp.ZData);
  
% method 2: direct surf  
  h = surf(Ir);
  N = h.VertexNormals;
  N_z = squeeze(N(:,:,3));
  N_z = N_z./sqrt(sum(N.^2,3));
  Area = sum(1./N_z(:)) - nnz(h.ZData);
    
 % method 3: rectangular faces
 Area_2D = nnz(~Ir);
 Area_rect = Area_2D + sum(sum(abs(diff(Ir))));
 
end