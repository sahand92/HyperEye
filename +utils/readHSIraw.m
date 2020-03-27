function D=readHSIraw(datafile)
%reads .raw spectral image files 

%input full filename: datafile='C:\Users\vickngc\MATLAB\measurement.raw'

%read header file
hdrfile = strrep(datafile,'.raw','.hdr');
whitereffile=strrep(datafile,'measurement.raw','Whiteref_measurement.raw');
darkreffile=strrep(datafile,'measurement.raw','darkref_measurement.raw');

info = utils.envihdrread(hdrfile);

%read raw datafile, white and dark reference
D_HSI=multibandread(datafile,[info.lines,info.samples,info.bands],'uint16',0,'bil','ieee-le');
D_whiteref=multibandread(whitereffile,[128,384,288],'uint16',0,'bil','ieee-le');
D_darkref=multibandread(darkreffile,[25,384,288],'uint16',0,'bil','ieee-le');

whiteref=((mean(D_whiteref,1)));
darkref=((mean(D_darkref,1)));

% Apply dark and white reference
R=(1-(whiteref-D_HSI)./(whiteref-darkref));

%interpolate missing channel by taking average of prev and next channel
R=reshape(R,[info.samples*info.lines,info.bands]);
[n, channel]=find(isnan(R)==1 | isinf(R)==1);
R(n,channel)=(R(n,channel+1)+R(n,channel-1))./2;
R=reshape(R,[info.lines, info.samples, info.bands]);

D=R;%real(-log10(1-R));
end










