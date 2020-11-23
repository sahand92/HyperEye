function data = padImgReader(filename)

    I = imread(filename);
    I_padded = padarray(I,[1 1],0,'both');
    data = I_padded;