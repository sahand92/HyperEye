function [table_data] = seg_props(folder, net)
%folder = 'C:\Tagarno\Jumbo\WeightProportionsLentils\Auto Exposure\';
tic
files = dir(folder);

for i=3:length(files)
    names(i)=string(files(i).name);
end
names=rmmissing(names);
rect=[645 206 799 799];

for i = 1:length(names)
    I = imread(fullfile(folder,names(i)));
    I_cropped = imcrop(I,rect);
    Lp=semanticseg(I_cropped,net);
    L1=reshape(Lp,[800*800 1]);
    cats = categories(L1);
    props = countcats(L1)./sum(countcats(L1)).*100;
    prop(i,:) = props';
end

data = [names', prop];
table_data=array2table(data,...
    'VariableNames',cats');
end
%writetable(table_data,'propotions_jumbo_auto_dev_20.xlsx','Sheet',1,'Range','D1');