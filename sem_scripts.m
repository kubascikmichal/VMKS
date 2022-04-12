data=[8,8,8,8,8,8,8,8];
data2 = make_dct(data)
make_idct(data2)

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

function ret_Y, ret_CbCr = make_kvant(data_Y, data_CbCr)
%TODO div
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
          99 99 99 99 99 99 99 99]
    NxY=length(dataY);
    if(NxY>=8)
        for i=1:1:N
            NyY = length(data_Y(i))
        end
    end

end