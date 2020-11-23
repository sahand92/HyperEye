MY=strings([7500,1]);%(103000,1,'single');
FN=strings([5000,1]);%(103000,1,'single');

for i=1:length(T1)
    MY(find(sample==T1(i,1)))=T1(i,2);
    %FN(find(sample==T1(i,1)))=T1(i,3);

end

