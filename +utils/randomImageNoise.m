function I_out = randomImageNoise(I)

idx = randi(6);

if idx == 1
    I_out = imnoise(I,'speckle',0.1);
elseif idx == 2
    I_out = imnoise(I,'gaussian',0.1);
elseif idx == 3
    I_out = imgaussfilt(I,2);
else
    I_out = I;
end
end