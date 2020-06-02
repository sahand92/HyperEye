
ind_A=find(imds.Labels=='A');
ind_B=find(imds.Labels=='B');
ind_C=find(imds.Labels=='C');
ind_D=find(imds.Labels=='D');
ind_E=find(imds.Labels=='E');

ind_class=ind_E;
%JJ=zeros(200,200,7,length(ind_class),'uint8');
Circularity=zeros(1,length(ind_class));
for i=1:100%length(ind_class)
    JJ(:,:,:,i)=utils.matReader(imds.Files{ind_class(i)});
    JJ_mask=(imbinarize(rgb2gray((JJ(:,:,[5 3 2],i)))));

     stats = regionprops(JJ_mask,'Circularity');
     Circularity(i) = stats.Circularity;
end
figure
imshow(imtile(JJ(:,:,[5 3 2],:)))


% reject based on circularity threshold. Also compare adjacent images and reject the
% one with the lower circularity
ind=1:size(JJ,4);
ind_rej=find(Circularity<0.75);
%Compare first and last image, separately
if ismember(1,ind_rej)
ind_rej_prev=ind_rej+2;
elseif ismember(ind(end),ind_rej)
    ind_rej_next=ind_rej-2;
else
    ind_rej_prev=ind_rej-1;
    ind_rej_next=ind_rej+1;
end
Circ_comp=Circularity(ind_rej_prev)-Circularity(ind_rej_next);
ind_rej_add=unique([ind_rej, ind_rej+sign(Circ_comp)]);
ind_clean=ind(~ismember(ind,ind_rej_add));



JJ_clean=JJ(:,:,:,ind_clean);
figure
imshow(imtile(JJ_clean(:,:,[5 3 2],:)))
figure
imshow(imtile(JJ(:,:,[5 3 2],:)))

for j=1:size(JJ_clean,4)
    J=JJ_clean(:,:,:,j);
imdir='F:\EyeFoss Data\Pulses\Chickpeas\DEFECTS\DEFECTS\CFAHO19 Fractions EF1 PNR17 16Mar2020\Images Clean\';
save((strcat(imdir,'C\',sprintf('%05d.mat',j-1))),'J');
end




n=10*10;
%Lt=renamecats(Lt,{'Frost','Good'},{'Bad','Good'});
%LpC=renamecats(LpC,{'Frost','Good'},{'Bad','Good'});

index=Circularity;
I=(imtile(JJ(:,:,[5 3 2],1:n)));
position_x=repmat([1:200:(sqrt(n))*200]',[sqrt(n) 1]);
position_y=reshape(repmat([1:200:(sqrt(n))*200],[sqrt(n) 1]),[n 1]);
II=insertText(I,[position_x,position_y],string(round(index,2)),'TextColor','Green','BoxColor','black','BoxOpacity',0,'FontSize',24);
figure
imshow(II)
imshow(imtile(JJ(:,:,[5 3 2],:)))