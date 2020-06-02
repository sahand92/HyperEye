% n is a square number
n=20*20;
index=19*20*20+1:20*20*20;
I=(imtile(JJ(:,:,[5 3 2],index))./255);
position_x=repmat([1:150:(sqrt(n))*150]',[sqrt(n) 1]);
position_y=reshape(repmat([1:150:(sqrt(n))*150],[sqrt(n) 1]),[n 1]);
II=insertText(I,[position_x,position_y],string([index]),'TextColor','white','BoxColor','black','BoxOpacity',0,'FontSize',24);
