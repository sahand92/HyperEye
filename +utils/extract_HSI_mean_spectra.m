function [barcode spectra_i] = extract_HSI_mean_spectra(folder,image_type)


files = dir(folder);
for i=3:length(files)
    names(i)=string(files(i).name);
end

names=rmmissing(names);

spectra_i = zeros(length(names), 288);


if strcmp(image_type, 'single')
    fprintf('image type: single \n')
    for i = 1:length(names)
        fprintf(strcat(names(i),'\n'))
        mat_file = strcat(folder,'\',names(i),'\',names(i),'.mat');
        D_struct = load(mat_file);
        field_name = fieldnames(D_struct);
        D = D_struct.(field_name{1});
        J = utils.segmentHSI(D); % [100 100 288 5] array
        J = permute(J, [1 2 4 3]);

        n_seg = size(J,3);

        J = reshape(J,[100*100*n_seg 288]);
        ind_nonzero = find(J(:,1)~=0);
        spectra = mean(J(ind_nonzero,:),1); %average 5 grain spectrum
        spectra_i(i,:) = spectra;

        clear D_struct D J spectra
    end
elseif strcmp(image_type,'bulk')
    fprintf('image type: bulk \n')
    for i = 1:length(names)
        fprintf(strcat(names(i),'\n'))
        mat_file = strcat(folder,'\',names(i),'\',names(i),'.mat');
        try D_struct = load(mat_file);
        catch continue;
        end
        field_name = fieldnames(D_struct);
        D = D_struct.(field_name{1});
        D=permute(D,[2 1 3]);
        D_rgb=(1-D(:,:,50)); % pseudo-RGB from HSI image
        D_adj = imadjust(D_rgb);
        BW_mask=imbinarize(D_adj,0.06);
        %BW_mask = ~BW_mask;
        % use grayscale image to create binary mask 
        D=D.*single(BW_mask); 
        D = reshape(D,[size(D,1)*size(D,2) 288]);
        ind_nonzero = find(D(:,1)~=0);
        spectra = mean(D(ind_nonzero,:),1); %average 5 grain spectrum
        spectra_i(i,:) = spectra;

        clear D_struct D spectra
    end
else
    fprintf('not a valid image type!')
end

barcode = names';
end