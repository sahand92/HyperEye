figure
numImages = 300;
%perm = randperm(numImages,700);
J=zeros(150,150,7,200,'uint8');
for i = 1:200
    %subplot(10,10,i);
    J(:,:,:,i)=utils.matReader(imdsTest.Files{(i)});
end
Lp=predict(net_chickpea,J);
[argvalue, argmax] = max(Lp');
LpC=categorical(argmax,[1 2 3],{'A','C','D'});

C = confusionchart(LpC,Lt)

Lt=imdsTest.Labels;
imshow(imtile(J(:,:,[5 3 2],:)))

% n is a square number
n=10*10;

%Lt=renamecats(Lt,{'Frost','Good'},{'Bad','Good'});
%LpC=renamecats(LpC,{'Frost','Good'},{'Bad','Good'});
ind_rand=randperm(300);
index=Lt(ind_rand(1:100));
index_p=LpC(ind_rand(1:100));


I=(imtile(J(:,:,[5 3 2],ind_rand(1:n))));
position_x=repmat([1:200:(sqrt(n))*200]',[sqrt(n) 1]);
position_y=reshape(repmat([1:200:(sqrt(n))*200],[sqrt(n) 1]),[n 1]);
position_yp=position_y+30;

II=insertText(I,[position_x,position_y],string([index]),'TextColor','Green','BoxColor','black','BoxOpacity',0,'FontSize',26);
II2=insertText(II,[position_x,position_yp],string([index_p]),'TextColor','cyan','BoxColor','black','BoxOpacity',0,'FontSize',26);


