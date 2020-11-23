function pixel_table_mean = mean_pixel_table(pixel_table)

% find unique samples
str_name = char(pixel_table.name);
pixel_table.name = string(str_name(:,1:end-6));
unique_names = unique(string(str_name(:,1:end-6)));

% preallocate table
image_summaries = array2table(nan(length(unique_names),size(pixel_table,2).*2),...
    'VariableNames',[pixel_table.Properties.VariableNames,...
    strcat(pixel_table.Properties.VariableNames,'_std')]);
image_summaries = removevars(image_summaries,{'name', 'name_std'});
name_table = array2table(strings(length(unique_names),1),'VariableNames',{'name'});
image_summaries = [name_table, image_summaries,];

for i = 1:length(unique_names)
   image_table = pixel_table(pixel_table.name == unique_names(i),:);
   image_mean = mean(str2double(table2array(image_table(:,2:end))));
   image_std = std(str2double(table2array(image_table(:,2:end))));

   
   image_summaries.name(i) = unique_names(i);
   image_summaries(i,2:end) = [array2table(image_mean),array2table(image_std)];
end
pixel_table_mean = image_summaries;

end
 