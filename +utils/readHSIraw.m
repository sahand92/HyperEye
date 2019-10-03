function D=readHSIraw(datafile)

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

% average reference lines
whiteref=mean(D_whiteref,1);
darkref=mean(D_darkref,1);

% calculate final HSI image
D=(D_HSI-darkref)./(whiteref-darkref);


% interpolate missing channel by taking average of prev and next channel
D=reshape(D,[info.samples*info.lines,info.bands]);
[n, channel]=find(isnan(D)==1);
D(n,channel)=(D(n,channel+1)+D(n,channel-1))./2;
D=reshape(D,[info.lines, info.samples, info.bands]);
end










