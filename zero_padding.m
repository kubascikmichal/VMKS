clear all;
close all;
data = imread("lena160x160.jpg");
[x,y,z] = size(data);
dataR = zeros(x,y);
dataG = zeros(x,y);
dataB = zeros(x,y);
for i=1:1:x
    for j=1:1:y
        dataR(:,:) = data(:,:,1);
        dataG(:,:) = data(:,:,2);
        dataB(:,:) = data(:,:,3);
    end
end
dataRfft = zeros(x,y);
dataGfft = zeros(x,y);
dataBfft = zeros(x,y);
for i=1:1:x
    dataRfft(i,:) = fft(dataR(i,:));
    dataGfft(i,:) = fft(dataG(i,:));
    dataBfft(i,:) = fft(dataB(i,:));
end

for i=1:1:y
    dataRfft(:,i) = fft(dataRfft(:,i));
    dataGfft(:,i) = fft(dataGfft(:,i));
    dataBfft(:,i) = fft(dataBfft(:,i));
end

dataRfft2 = zeros(320,320);
dataGfft2 = zeros(320,320);
dataBfft2 = zeros(320,320);
for i=1:1:x
        if(i <= x/2+1)
            dataRfft2(i,1:1+x/2) = dataRfft(i,1:1+x/2);
            dataRfft2(i,end-x/2:end) = dataRfft(i,end-x/2:end);

            dataGfft2(i,1:1+x/2) = dataGfft(i,1:1+x/2);
            dataGfft2(i,end-x/2:end) = dataGfft(i,end-x/2:end);

            dataBfft2(i,1:1+x/2) = dataBfft(i,1:1+x/2);
            dataBfft2(i,end-x/2:end) = dataBfft(i,end-x/2:end);
        else
            dataRfft2(end-x+i,1:1+x/2) = dataRfft(i,1:1+x/2);
            dataRfft2(end-x+i,end-x/2:end) = dataRfft(i,end-x/2:end);

            dataGfft2(end-x+i,1:1+x/2) = dataGfft(i,1:1+x/2);
            dataGfft2(end-x+i,end-x/2:end) = dataGfft(i,end-x/2:end);

            dataBfft2(end-x+i,1:1+x/2) = dataBfft(i,1:1+x/2);
            dataBfft2(end-x+i,end-x/2:end) = dataBfft(i,end-x/2:end);    
        end
end

dataRnew = zeros(2*x,2*y);
dataGnew = zeros(2*x,2*y);
dataBnew = zeros(2*x,2*y);
for i=1:1:320
    dataRnew(:,i) = ifft(dataRfft2(:,i));
    dataGnew(:,i) = ifft(dataGfft2(:,i));
    dataBnew(:,i) = ifft(dataBfft2(:,i));
end

for i=1:1:320
    dataRnew(i,:) = ifft(dataRnew(i,:));
    dataGnew(i,:) = ifft(dataGnew(i,:));
    dataBnew(i,:) = ifft(dataBnew(i,:));
end

data2 = zeros(2*x,2*y,z);
data2(:,:,1) = real(dataRnew);
data2(:,:,2) = real(dataGnew);
data2(:,:,3) = real(dataBnew);