clear all;
close all;

Kr = 0.299;
Kg = 0.587;
Kb = 1-Kr-Kg;

data = double(imread("lena160x160.jpg"));
[x,y,z] = size(data);

Y = zeros(x,y);
Cb = zeros(x,y);
Cr = zeros(x,y);

for i=1:1:x
    for j=1:1:y
        Y(i,j) = (Kr*data(i,j,1) + Kg*data(i,j,2) + Kb*data(i,j,3));
        Cb(i,j) = 128 + 0.5 * ((data(i,j,3) - Y(i,j))/(1-Kb));
        Cr(i,j) = 128 + 0.5 * ((data(i,j,1) - Y(i,j))/(1-Kr));
    end 
end
%4:2:2
Cb1 = zeros(x,y);
Cr1 = zeros(x,y);
for i=1:1:x
    for j=1:2:y
        Cb1(i,j) = Cb(i, j);
        Cb1(i,j+1) = Cb(i, j);
        Cr1(i,j) = Cr(i, j);
        Cr1(i,j+1) = Cr(i, j);
    end 
end
%4:2:0
Cb2 = zeros(x,y);
Cr2 = zeros(x,y);
for i=1:2:x
    for j=1:2:y
        Cb2(i,j) = Cb(i, j);
        Cb2(i,j+1) = Cb(i, j);
        Cb2(i+1,j) = Cb(i, j);
        Cb2(i+1,j+1) = Cb(i, j);

        Cr2(i,j) = Cr(i, j);
        Cr2(i,j+1) = Cr(i, j);
        Cr2(i+1,j) = Cr(i, j);
        Cr2(i+1,j+1) = Cr(i, j);
    end 
end

data_nc = zeros(x,y,z);
data_422 = zeros(x,y,z);
data_420 = zeros(x,y,z);

for i=1:1:x
    for j=1:1:y
        data_nc(i,j,1) = (Cr(i,j) - 128)*2*(1-Kr) + Y(i,j);
        data_nc(i,j,3) = (Cb(i,j) - 128)*2*(1-Kb) + Y(i,j);
        data_nc(i,j,2) = (Y(i,j) - Kr * data_nc(i,j,1) - Kb * data_nc(i,j,2))/Kg;

        data_422(i,j,1) = (Cr(i,j) - 128)*2*(1-Kr) + Y(i,j);
        data_422(i,j,3) = (Cb(i,j) - 128)*2*(1-Kb) + Y(i,j);
        data_422(i,j,2) = (Y(i,j) - Kr * data_422(i,j,1) - Kb * data_422(i,j,2))/Kg;

        data_420(i,j,1) = (Cr(i,j) - 128)*2*(1-Kr) + Y(i,j);
        data_420(i,j,3) = (Cb(i,j) - 128)*2*(1-Kb) + Y(i,j);
        data_420(i,j,2) = (Y(i,j) - Kr * data_420(i,j,1) - Kb * data_420(i,j,2))/Kg;
    end 
end

figure('Name','Original');
imshow(uint8(data));

figure('Name','No compression');
imshow(uint8(data_nc));

figure('Name','Compression 4:2:2');
imshow(uint8(data_422));

figure('Name','Compression 4:2:0');
imshow(uint8(data_420));