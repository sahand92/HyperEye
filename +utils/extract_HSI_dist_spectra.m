function [barcode, spectra_dist] = extract_HSI_dist_spectra(folder,image_type)


files = dir(folder);
for i=3:length(files)
    names(i)=string(files(i).name);
end

names=rmmissing(names);

nbins = 200;
xbins = linspace(-1,3,nbins);


if strcmp(image_type, 'single')
    fprintf('image type: single \n')
    spectra_dist = zeros(length(names),5,10,288);

    for i = 1:length(names)
        fprintf(strcat(names(i),'\n'))
        mat_file = strcat(folder,'\',names(i),'\',names(i),'.mat');
        D_struct = load(mat_file);
        field_name = fieldnames(D_struct);
        D = D_struct.(field_name{1});
        J = utils.segmentHSI(D); % [100 100 num_segs 288] array
        J = permute(J, [1 2 4 3]);

        n_seg = size(J,3);
        for j = 1:n_seg
            D = reshape(squeeze(J(:,:,j,:)),[100*100 288]);
            ind_zero = find(D(:,1)==0);
            D(ind_zero,:) = [];
            counts = hist(D,10);
            spectra_dist(i,j,:,:) = counts;
            % output size is 1x5(num of grains)x10(num bins)x288
        end
    end
            
        clear D_struct D J
    
elseif strcmp(image_type,'bulk')
    fprintf('image type: bulk \n')
    spectra_dist = zeros(length(names),nbins, 288);

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
        ind_zero = find(D(:,1)==0);
        D(ind_zero,:)=[];
        counts = hist(D,xbins);
        spectra_dist(i,:,:) = counts;

        clear D_struct D counts
    end
else
    fprintf('not a valid image type!')
end

barcode = names';
end