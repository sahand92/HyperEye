function spectra_diff = preprocess_spectra(spectra, treatment)
rd = 2;
fl = 11;

edge_pts = 5;

if treatment == 'raw'
    spectra_diff = spectra(:,edge_pts:end-edge_pts)';
elseif treatment == 'MCS'
    spectra_diff = zscore(spectra(:,edge_pts:end-edge_pts)');
elseif treatment == 'SGF'
    spectra_diff = utils.sgolayfilt(zscore(spectra(:,edge_pts:end-edge_pts)'),rd,fl);
elseif treatment == '1st'
    [~, spectra_diff]=gradient(utils.sgolayfilt(zscore(spectra(:,edge_pts:end-edge_pts)'),rd,fl),1);
elseif treatment == '2nd'
    [~, spectra_diff]=gradient(utils.sgolayfilt(zscore(spectra(:,edge_pts:end-edge_pts)'),rd,fl),1);
    [~, spectra_diff]= gradient(spectra_diff,1);
else
    spectra_diff = 0;
end
end