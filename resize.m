clear all;
close all;
data = imread("lena160x160.jpg");
[x,y,z] = size(data);
data2 = uint8(zeros(2*x,2*y,z));
for i=1:1:x
    for j=1:1:y
        for k=1:1:z
            data2(2*i-1,2*j-1,k) = data(i,j,k);
            data2(2*i-1,2*j,k) = data(i,j,k);
            data2(2*i,2*j-1,k) = data(i,j,k);
            data2(2*i,2*j,k) = data(i,j,k);
        end
    end
end

imshow(data2);
