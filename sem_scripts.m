%test
data=[8,8,8,8,8,8,8,8];
data2 = make_dct(data)
make_idct(data2)



%data2 = make_zigzag(data);
%data2 = make_izigzag(data,8,8);

function ret_dct = make_dct(data)
%TODO make DCT Xk=sum(n=0, N-1) xn(cos(pi/N(n+1/2)k)
    N=length(data);
    ret_dct = zeros(N,1);
    for i=1:1:N
        for j=1:1:N
            ret_dct(i) = ret_dct(i)+data(j)*cos(pi/N * (j-1/2)*(i-1));
        end 
    end
end

function ret_idct = make_idct(data)
%TODO make IDCT
    N=length(data);
    ret_idct = zeros(N,1);
    for i=1:1:N
        ret_idct(i) = 1/2*data(1);
    end
    for i=1:1:N
        for j=2:1:N
            ret_idct(i) = ret_idct(i)+data(j)*cos(pi/N * (i-1/2)*(j-1));
        end 
    end
    ret_idct = ret_idct*2/N;
end

function ret_Y, ret_Cb, ret_Cr = make_kvant(data_Y, data_Cb, data_Cr)
    ret_Y = data_Y;
    ret_Cb = data_Cb;
    ret_Cr = data_Cr;
    div_Y = [ 16 11 10 16 24 40 51 61;
        12 12 14 19 26 58 60 55;
        14,13,16 24 40 57 69 56;
        14 17 22 29 51 87 80 62;
        18 22 37 56 68 109 103 77;
        24 35 55 64 81 104 113 92;
        49 64 78 87 103 121 120 101;
        72 92 95 98 112 100 103 99];
    div_CbCr = [17 18 24 47 99 99 99 99;
          18 21 26 66 99 99 99 99;
          24 26 56 99 99 99 99 99;
          47 66 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99];
    NxY=length(data_Y);
    if(NxY>=8)
        for i=1:1:8
            NyY = length(data_Y(i));
            if(NyY>=8)
                for j=1:1:8
                    ret_Y(i,j) = data_Y(i,j) / div_Y(i,j);
                end
            end
        end
    end

    NxCb = length(data_Cb);
    if(NxCb>=8)
        for i=1:1:8
            NyCb = length(data_Cb(i));
            if(NyCb>=8)
                for j=1:1:8
                    ret_Cb(i,j) = data_Cb(i,j) / div_CbCr(i,j);
                end
            end
        end
    end
        
    NxCr = length(data_Cr);
    if(NxCr>=8)
        for i=1:1:8
            NyCr = length(data_Cb(i));
            if(NyCr>=8)
                for j=1:1:8
                    ret_Cr(i,j) = data_Cr(i,j) / div_CbCr(i,j);
                end
            end
        end
    end
end

function ret_data = make_YCbCr_420(data)
Kr = 0.299;
Kg = 0.587;
Kb = 1-Kr-Kg;
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
ret_data = zeros(x,y,z);
for i=1:1:x
    for j=1:1:y
        ret_data(i,j,1) = (Cr(i,j) - 128)*2*(1-Kr) + Y(i,j);
        ret_data(i,j,3) = (Cb(i,j) - 128)*2*(1-Kb) + Y(i,j);
        ret_data(i,j,2) = (Y(i,j) - Kr * ret_data(i,j,1) - Kb * ret_data(i,j,2))/Kg;
    end
end
end

function ret_zigzag = make_zigzag(data)
    [x,y] = size(data);
    index = 1;
    for i=1:1:y
        for j=1:1:i
            if(mod(i,2) == 1)
                ret_zigzag(index) = data(i-j+1, j);
            else
                ret_zigzag(index) = data(j, i-j+1);
            end
            index = index+1;
        end 
    end
    for i=2:1:y
        for j=1:1:y-i
            if(mod(i,2) == 1)
                ret_zigzag(index) = data(y-j, j);
            else
                ret_zigzag(index) = data(j, y-j);
            end
            index = index+1;
        end 
    end
end

function ret_data = make_izigzag(zigzag,x,y)
    if(x*y == length(zigzag))
        ret_data = zeros(x,y);
        index = length(zigzag);
        for i=1:1:y
            for j=1:1:i
                if(mod(y,2) == 1)
                    ret_data(i, i-j+1) = zigzag(index);
                else
                    ret_data(i-j+1, i) = zigzag(index);
                end
                index = index-1;
            end 
        end
    end
end

function ret_RLE = make_RLE(data)
[x,y] = size(data);
for i=1:1:x
    for j=1:1:y 
        vector(((i-1)*y) + j) = data(x,y,1);
    end 
end

ret_RLE = uint8([]);
last = vector(1);
count = 1;
last_index = 1;
for i=2:1:length(vector)
    if(last == vector(i) || count == 255)
        count = count+1;
    else
        ret_RLE(last_index) = last;
        ret_RLE(last_index+1) = count;
        last_index = last_index + 2;
        last = vector(i);
        count = 1;
    end
end
ret_RLE(last_index) = last;
ret_RLE(last_index+1) = count;

end

function ret_data = make_iRLE(RLE, x, y)
    if((x*y) == length(RLE))
        vector_after = [];
        for i=1:2:length(RLE)
            vector_after = [vector_after, RLE(i)*ones(1,code(i+1))];
        end

        ret_data = zeros(x,y);
        for i=1:1:x
            for j=1:1:y
                ret_data(i,j) = vector_after((i-1)*y + j);
            end 
        end
    end
end