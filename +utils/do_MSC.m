function [spectra_out] = do_MSC(spectra_in)
% spectra_in: rows are samples, columns spectral data pts

X = spectra_in;
%X = zscore(X')';
y = mean(X(:,1:end));

                coeff=zeros(size(X,2),2);
                out = zeros(size(X));
                for i=1:size(X,1) % MSC (y=ax+b)
                    coeff(i,:) = polyfit(y,X(i,:),1);
                end
                
                for i = 1:size(X,1)
                    out(i,:) = X(i,:)-coeff(i,2)/coeff(i,1);
                end
                
                spectra_out = out;
end
