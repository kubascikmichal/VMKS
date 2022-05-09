clear all;
data = imread("lena160x160.jpg");
[x,y,z] = size(data);
[Y, Cb, Cr] = make_YCbCr(data);
[Cb, Cr] = make_compr420(Cb, Cr);
[Y_bl, Cb_bl, Cr_bl] = make_blocks8x8(Y, Cb, Cr);
[Y_bl, Cb_bl, Cr_bl] = make_DCT(Y_bl, Cb_bl, Cr_bl);
[Y_bl, Cb_bl, Cr_bl] = make_kvant(Y_bl, Cb_bl, Cr_bl);
[Y_v, Cb_v, Cr_v] = make_zig_zag(Y_bl, Cb_bl, Cr_bl);
[Y_v_r, Cb_v_r, Cr_v_r] = make_RLE(Y_v, Cb_v, Cr_v);
[Y_c, Cb_c, Cr_c, tree_Y, tree_Cb, tree_Cr] = make_Huffman(Y_v_r, Cb_v_r, Cr_v_r, Y_v, Cb_v, Cr_v);
[Y_ih, Cb_ih, Cr_ih] = make_invHuffman(Y_c, Cb_c, Cr_c, tree_Y, tree_Cb, tree_Cr);
[Y_iz, Cb_iz, Cr_iz] = make_invzig_zag(Y_v, Cb_v, Cr_v);
[Y_iz, Cb_iz, Cr_iz] = make_invkvant(Y_iz, Cb_iz, Cr_iz);
[Y_idct, Cb_idct, Cr_idct] = make_invDCT(Y_iz, Cb_iz, Cr_iz);
[Yn, Cbn, Crn] = make_invblocks8x8(Y_idct, Cb_idct, Cr_idct);
figure;
imshow(uint8(make_invYCbCr(Y, Cb, Cr)));
figure;
imshow(uint8(make_invYCbCr(Yn, Cbn, Crn)));


function [r_Y, r_Cb, r_Cr] = make_YCbCr(data)
Kr = 0.299;
Kg = 0.587;
Kb = 1-Kr-Kg;
[x,y,z] = size(data);
r_Y = zeros(x,y);
r_Cb = zeros(x,y);
r_Cr = zeros(x,y);

for i=1:1:x
    for j=1:1:y
        r_Y(i,j) = (Kr*data(i,j,1) + Kg*data(i,j,2) + Kb*data(i,j,3));
        r_Cb(i,j) = 128 + 0.5 * ((data(i,j,3) - r_Y(i,j))/(1-Kb));
        r_Cr(i,j) = 128 + 0.5 * ((data(i,j,1) - r_Y(i,j))/(1-Kr));
    end 
end
end

function picture = make_invYCbCr(Y, Cb, Cr)
Kr = 0.299;
Kg = 0.587;
Kb = 1-Kr-Kg;
[x,y]= size(Y);
picture = zeros(x,y);
for i=1:1:x
    for j=1:1:y
        picture(i,j,1) = (Cr(i,j) - 128)*2*(1-Kr) + Y(i,j);
        picture(i,j,3) = (Cb(i,j) - 128)*2*(1-Kb) + Y(i,j);
        picture(i,j,2) = (Y(i,j) - Kr * picture(i,j,1) - Kb * picture(i,j,2))/Kg;
    end
end
end

function [r_Cb, r_Cr] = make_compr420(Cb, Cr)
[x,y] = size(Cb);
r_Cb = zeros(x,y);
r_Cr = zeros(x,y);
for i=1:2:x
    for j=1:2:y
        r_Cb(i,j) = Cb(i, j);
        r_Cb(i,j+1) = Cb(i, j);
        r_Cb(i+1,j) = Cb(i, j);
        r_Cb(i+1,j+1) = Cb(i, j);

        r_Cr(i,j) = Cr(i, j);
        r_Cr(i,j+1) = Cr(i, j);
        r_Cr(i+1,j) = Cr(i, j);
        r_Cr(i+1,j+1) = Cr(i, j);
    end 
end
end

function [Y_bl, Cb_bl, Cr_bl] = make_blocks8x8(Y, Cb, Cr)
[x,y] = size(Y);
Y_bl = zeros(8,8,((x/8)*(y/8)));
Cb_bl = zeros(8,8,((x/8)*(y/8)));
Cr_bl = zeros(8,8,((x/8)*(y/8)));

counter=1;
    for a=1:8:x
        for b=1:8:y            
            for e=1:1:8
                for f=1:1:8
                    Y_bl(e,f,counter) = Y(e+a-1,f+b-1);
                    Cb_bl(e,f,counter) = Cb(e+a-1,f+b-1);
                    Cr_bl(e,f,counter) = Cr(e+a-1,f+b-1);
                end
            end
            counter = counter+1;
        end
    end
end

function [Y, Cb, Cr] = make_invblocks8x8(Y_bl, Cb_bl, Cr_bl)
[x1, y1, z1] = size(Y_bl);
[x2, y2, z2] = size(Cb_bl);
[x3, y3, z3] = size(Cr_bl);
minimum = min([z1, z2, z3]);
Y=zeros(round(sqrt(minimum*64)),round(sqrt(minimum*64)));
Cb=zeros(round(sqrt(minimum*64)),round(sqrt(minimum*64)));
Cr=zeros(round(sqrt(minimum*64)),round(sqrt(minimum*64)));
c=1;
    for a=1:8:round(sqrt(minimum))*8
        for b=1:8:round(sqrt(minimum))*8  
            for e=1:1:8
                for f=1:1:8
                Y(e+a-1,f+b-1) = Y_bl(e,f,c);
                Cb(e+a-1,f+b-1) = Cb_bl(e,f,c);
                Cr(e+a-1,f+b-1) = Cr_bl(e,f,c) ;
                end
            end
            c = c+1;
        end
    end
end

function [Y_bl, Cb_bl, Cr_bl] = make_DCT(Y_bl, Cb_bl, Cr_bl)
[x,y,z] = size(Y_bl);
Y_dct = zeros(1,8);
Cb_dct = zeros(1,8);
Cr_dct = zeros(1,8);

N = 8;
for i=1:1:z
    for j=1:1:8
        for k = 1:1:8               
            for n = 1:1:8
            Y_dct(k) = Y_dct(k) + Y_bl(j,n,i)*cos((pi/N)*((n-1)+(1/2))*(k-1));
            Cb_dct(k) = Cb_dct(k) + Cb_bl(j,n,i)*cos((pi/N)*((n-1)+(1/2))*(k-1));
            Cr_dct(k) = Cr_dct(k) + Cr_bl(j,n,i)*cos((pi/N)*((n-1)+(1/2))*(k-1));
            end
        end
        Y_bl(j,:,i) = Y_dct(:);
        Cb_bl(j,:,i) = Cb_dct(:);
        Cr_bl(j,:,i) = Cr_dct(:);
        
        Y_dct = zeros(1,8);
        Cb_dct = zeros(1,8);
        Cr_dct = zeros(1,8);
    end
end
end

function [Y_idct, Cb_idct, Cr_idct] = make_invDCT(Y_iz, Cb_iz, Cr_iz) 
    vector_Y = zeros(1,8);
    vector_Cb = zeros(1,8);
    vector_Cr = zeros(1,8);
    [x1, y1, z1] = size(Y_iz);
    [x2, y2, z2] = size(Cb_iz);
    [x3, y3, z3] = size(Cr_iz);
    z = min([z1, z2, z3]);
    N = 8;
    for i=1:1:z
        for j=1:1:8
            for k = 1:1:8 
                vector_Y(k) = (1/2)*Y_iz(j,1,i);
                vector_Cr(k) = (1/2)*Cb_iz(j,1,i);
                vector_Cb(k) = (1/2)*Cr_iz(j,1,i);
                for n = 2:1:8
                    sumR = Y_iz(j,n,i)*cos((pi/N)*((k-1)+(1/2))*(n-1));
                    vector_Y(k) = vector_Y(k) + sumR;
    
                    sumG = Cb_iz(j,n,i)*cos((pi/N)*((k-1)+(1/2))*(n-1));
                    vector_Cr(k) = vector_Cr(k) + sumG;
    
                    sumB = Cr_iz(j,n,i)*cos((pi/N)*((k-1)+(1/2))*(n-1));
                    vector_Cb(k) = vector_Cb(k) + sumB;
                end
                vector_Y(k) = vector_Y(k)/(N/2);
                vector_Cr(k) = vector_Cr(k)/(N/2);
                vector_Cb(k) = vector_Cb(k)/(N/2);
            end
            Y_iz(j,:,i) = vector_Y(:);
            Cb_iz(j,:,i) = vector_Cr(:);
            Cr_iz(j,:,i) = vector_Cb(:);
            
            vector_Y = zeros(1,8);
            vector_Cb = zeros(1,8);
            vector_Cr = zeros(1,8);
        end
    end
    Y_idct = Y_iz;
    Cb_idct = Cb_iz;
    Cr_idct = Cr_iz;
end

function [Y_bl, Cb_bl, Cr_bl] = make_kvant(Y_bl, Cb_bl, Cr_bl)
[x,y,z] = size(Y_bl);
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

for i=1:1:z
    for j=1:1:8
        for k=1:1:8
        Y_bl(j,k,i) = round(Y_bl(j,k,i)/div_Y(j,k));
        Cb_bl(j,k,i) = round(Cb_bl(j,k,i)/div_CbCr(j,k));
        Cr_bl(j,k,i) = round(Cr_bl(j,k,i)/div_CbCr(j,k));
        end
    end
end
end

function [Y_invk, Cb_invk, Cr_invk] = make_invkvant(Y_iz, Cb_iz, Cr_iz)
Y_invk = zeros(size(Y_iz,1),size(Y_iz,2), size(Y_iz,3));
Cb_invk = zeros(size(Cb_iz,1),size(Cb_iz,2), size(Cb_iz,3));
Cr_invk = zeros(size(Cr_iz,1),size(Cr_iz,2), size(Cr_iz,3));
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

for i=1:1:(size(Y_iz,3))
    for j=1:1:8
        for k=1:1:8
        Y_invk(j,k,i) = Y_iz(j,k,i)*div_Y(j,k);
        Cb_invk(j,k,i) = Cb_iz(j,k,i)*div_CbCr(j,k);
        Cr_invk(j,k,i) = Cr_iz(j,k,i)*div_CbCr(j,k);
        end
    end
end
end

function [Y_v, Cb_v, Cr_v] = make_zig_zag(Y_bl, Cb_bl, Cr_bl)
[x,y,z] = size(Y_bl);
Y_v = zeros(1,(z*64)); 
Y_v_c = 1; 
Cb_v = zeros(1,(z*64));   
Cb_v_c = 1; 
Cr_v = zeros(1,(z*64)); 
Cr_v_c = 1;

for j=1:1:z
    for i=1:1:15
        for l = 1:1:i
        k = i - l + 1;
        modulo = mod(i,2);
            if l<=8 && k <= 8
                if modulo == 1
                Y_v(1,Y_v_c) = Y_bl(k,l,j); 
                Y_v_c = Y_v_c +1;
                
                Cb_v(1,Cb_v_c) = Cb_bl(k,l,j); 
                Cb_v_c = Cb_v_c +1;
                
                Cr_v(1,Cr_v_c) = Cr_bl(k,l,j); 
                Cr_v_c = Cr_v_c +1;
                else
                Y_v(1,Y_v_c) = Y_bl(l,k,j);
                Y_v_c = Y_v_c +1;

                Cb_v(1,Cb_v_c) = Cb_bl(l,k,j);
                Cb_v_c = Cb_v_c +1;

                Cr_v(1,Cr_v_c) = Cr_bl(l,k,j);
                Cr_v_c = Cr_v_c +1;
                end
            end
        end
    end
end
end

function [Y_iz, Cb_iz, Cr_iz] = make_invzig_zag(Y_ih, Cb_ih, Cr_ih)
Y_iz = zeros(8,8,round(size(Y_ih,2)/64));
Y_iz_c = 1;
Cb_iz = zeros(8,8,round(size(Cb_ih,2)/64));
Cb_iz_c = 1;
Cr_iz = zeros(8,8,round(size(Cr_ih,2)/64));
Cr_iz_c = 1;
y = min([size(Y_ih,2),size(Cb_ih,2),size(Cr_ih,2)])
for j=1:1:y/64
    for i=1:1:15
        for l = 1:1:i
        k = i - l + 1;
        modulo = mod(i,2);
            if l<=8 && k <= 8
                if modulo == 1
                Y_iz(k,l,j) =  Y_ih(1,Y_iz_c);
                Y_iz_c = Y_iz_c +1;
                
                Cb_iz(k,l,j) = Cb_ih(1,Cb_iz_c); 
                Cb_iz_c = Cb_iz_c +1;
                
                Cr_iz(k,l,j) =  Cr_ih(1,Cr_iz_c); 
                Cr_iz_c = Cr_iz_c +1;
                else
                Y_iz(l,k,j) = Y_ih(1,Y_iz_c);
                Y_iz_c = Y_iz_c +1;

                Cb_iz(l,k,j) = Cb_ih(1,Cb_iz_c);
                Cb_iz_c = Cb_iz_c +1;

                Cr_iz(l,k,j) = Cr_ih(1,Cr_iz_c);
                Cr_iz_c = Cr_iz_c +1;
                end
            end
        end
    end
end
end

function [Y_v_r, Cb_v_r, Cr_v_r] = make_RLE(Y_v, Cb_v, Cr_v)
[x,y,z] = size(Y_v);
Y_v_r = [];
Cb_v_r = [];
Cr_v_r = [];

last = Y_v(1);
count = 1;
last_index = 1;
for i=2:1:length(Y_v)
    if(last == Y_v(i) && count < 255)
        count = count+1;
    else
        Y_v_r(last_index) = last;
        Y_v_r(last_index+1) = count;
        last_index = last_index +2;
        last = Y_v(i);
        count = 1;
    end
end
Y_v_r(last_index) = last;
Y_v_r(last_index+1) = count;


last = Cb_v(1);
count = 1;
last_index = 1;
for i=2:1:length(Cb_v)
    if(last == Cb_v(i) && count < 255)
        count = count+1;
    else
        Cb_v_r(last_index) = last;
        Cb_v_r(last_index+1) = count;
        last_index = last_index +2;
        last = Cb_v(i);
        count = 1;
    end
end
Cb_v_r(last_index) = last;
Cb_v_r(last_index+1) = count;


last = Cr_v(1);
count = 1;
last_index = 1;
for i=2:1:length(Cr_v)
    if(last == Cr_v(i) && count < 255)
        count = count+1;
    else
        Cr_v_r(last_index) = last;
        Cr_v_r(last_index+1) = count;
        last_index = last_index +2;
        last = Cr_v(i);
        count = 1;
    end
end
Cr_v_r(last_index) = last;
Cr_v_r(last_index+1) = count;

end

function [Y_code, Cb_code, Cr_code, c_v_c_Y, c_v_c_Cb, c_v_c_Cr] = make_Huffman(Y_v_r, Cb_v_r, Cr_v_r, Y_v, Cb_v, Cr_v)
%Tabulka pocetnosti
v_c_Y = zeros(2,size(Y_v_r,2));
v_c_c_Y = 2;

v_c_Cb = zeros(2,size(Cb_v_r,2));
v_c_c_Cb = 2;

v_c_Cr = zeros(2,size(Cr_v_r,2));
v_c_c_Cr = 2;

for i=1:2:size(Y_v_r,2)
    for j=1:1:v_c_c_Y
        if Y_v_r(i) == v_c_Y(1,j)
            v_c_Y(2,j) = v_c_Y(2,j) + Y_v_r(i+1);
            break;
        else
            if j == v_c_c_Y 
            v_c_Y(1,j) = Y_v_r(i);
            v_c_Y(2,j) = Y_v_r(i+1); 
            v_c_c_Y = v_c_c_Y + 1;
            end
        end
    end
end

for i=1:2:size(Cb_v_r,2)
    for j=1:1:v_c_c_Cb
        if Cb_v_r(i) == v_c_Cb(1,j)
            v_c_Cb(2,j) = v_c_Cb(2,j) + Cb_v_r(i+1);
            break;
        else
            if j == v_c_c_Cb 
            v_c_Cb(1,j) = Cb_v_r(i);
            v_c_Cb(2,j) = Cb_v_r(i+1); 
            v_c_c_Cb = v_c_c_Cb + 1;
            end
        end
    end
end

for i=1:2:size(Cr_v_r,2)
    for j=1:1:v_c_c_Cr
        if Cr_v_r(i) == v_c_Cr(1,j)
            v_c_Cr(2,j) = v_c_Cr(2,j) + Cr_v_r(i+1);
            break;
        else
            if j == v_c_c_Cr 
            v_c_Cr(1,j) = Cr_v_r(i);
            v_c_Cr(2,j) = Cr_v_r(i+1); 
            v_c_c_Cr = v_c_c_Cr + 1;
            end
        end
    end
end
%koniec Tabulka pocetnosti

c_v_c_Y = num2cell(v_c_Y);
c_v_c_Cb = num2cell(v_c_Cb);
c_v_c_Cr = num2cell(v_c_Cr);

%Usporiadanie

i_Y = v_c_c_Y-1;
i_Cb = v_c_c_Cb-1;
i_Cr = v_c_c_Cr-1;

while c_v_c_Y{2,2} > 0  || c_v_c_Cb{2,2} > 0 || c_v_c_Cr{2,2} > 0
for repeat=1:1:v_c_c_Y                % usporiadanieR
    for b=1:1:v_c_c_Y-1
        if c_v_c_Y{2,b} < c_v_c_Y{2,b+1}
       value =  c_v_c_Y{2,b};
       c_v_c_Y(2,b) = c_v_c_Y(2,b+1);
       c_v_c_Y{2,b+1} = value;
       value =  c_v_c_Y(1,b);
       c_v_c_Y(1,b) = c_v_c_Y(1,b+1);
       c_v_c_Y(1,b+1) = value;
        end
    end
end

for repeat=1:1:v_c_c_Cb                % usporiadanieG
    for b=1:1:v_c_c_Cb-1
        if c_v_c_Cb{2,b} < c_v_c_Cb{2,b+1}
       value =  c_v_c_Cb{2,b};
       c_v_c_Cb(2,b) = c_v_c_Cb(2,b+1);
       c_v_c_Cb{2,b+1} = value;
       value =  c_v_c_Cb(1,b);
       c_v_c_Cb(1,b) = c_v_c_Cb(1,b+1);
       c_v_c_Cb(1,b+1) = value;
        end
    end
end

for repeat=1:1:v_c_c_Cr                % usporiadanieB
    for b=1:1:v_c_c_Cr-1
        if c_v_c_Cr{2,b} < c_v_c_Cr{2,b+1}
       value =  c_v_c_Cr{2,b};
       c_v_c_Cr(2,b) = c_v_c_Cr(2,b+1);
       c_v_c_Cr{2,b+1} = value;
       value =  c_v_c_Cr(1,b);
       c_v_c_Cr(1,b) = c_v_c_Cr(1,b+1);
       c_v_c_Cr(1,b+1) = value;
        end
    end
end

clear value;


%koniec Usporiadanie

if(c_v_c_Y{2,2} > 0)  %pre R
newCellR = cell(3,2);
newCellR(1,1) = c_v_c_Y(1,i_Y);
newCellR(2,1) = c_v_c_Y(2,i_Y);
newCellR(1,2) = c_v_c_Y(1,i_Y-1);
newCellR(2,2) = c_v_c_Y(2,i_Y-1);
newCellR{3,1} = 1; 
newCellR{3,2} = 0;

count =newCellR{2,1} + newCellR{2,2};

c_v_c_Y(1,i_Y-1) = {newCellR};
c_v_c_Y(2,i_Y-1) = num2cell(count);
c_v_c_Y(2,i_Y) = {0};
c_v_c_Y(1,i_Y) = {0};
i_Y = i_Y-1;
end
        
if(c_v_c_Cb{2,2} > 0)            %pre G
newCellG = cell(2);
newCellG(1,1) = c_v_c_Cb(1,i_Cb);
newCellG(2,1) = c_v_c_Cb(2,i_Cb);
newCellG(1,2) = c_v_c_Cb(1,i_Cb-1);
newCellG(2,2) = c_v_c_Cb(2,i_Cb-1);

countG =newCellG{2,1} + newCellG{2,2};

c_v_c_Cb(1,i_Cb-1) = {newCellG};
c_v_c_Cb(2,i_Cb-1) = num2cell(countG);
c_v_c_Cb(2,i_Cb) = {0};
c_v_c_Cb(1,i_Cb) = {0};
i_Cb = i_Cb-1;
end


if(c_v_c_Cr{2,2} > 0)            %preB
newCellB = cell(2);
newCellB(1,1) = c_v_c_Cr(1,i_Cr);
newCellB(2,1) = c_v_c_Cr(2,i_Cr);
newCellB(1,2) = c_v_c_Cr(1,i_Cr-1);
newCellB(2,2) = c_v_c_Cr(2,i_Cr-1);

countB =newCellB{2,1} + newCellB{2,2};

c_v_c_Cr(1,i_Cr-1) = {newCellB};
c_v_c_Cr(2,i_Cr-1) = num2cell(countB);
c_v_c_Cr(2,i_Cr) = {0};
c_v_c_Cr(1,i_Cr) = {0};
i_Cr = i_Cr-1;
end
end


%spustenie rekurzie pre vztvorenie tabulky
t_Y = containers.Map('KeyType','double','ValueType','char'); %tabulka koncova s klucom na kodovanie
recursion(t_Y,c_v_c_Y{1,1},"");
ahoj = keys(t_Y);
ahoj2 = values(t_Y);
t_Cb = containers.Map('KeyType','double','ValueType','char'); %tabulka koncova s klucom na kodovanie
recursion(t_Cb,c_v_c_Cb{1,1},"");
t_Cr = containers.Map('KeyType','double','ValueType','char'); %tabulka koncova s klucom na kodovanie
recursion(t_Cr,c_v_c_Cr{1,1},"");
%koniec spustenie rekurzie pre vztvorenie tabulky
%zakodovanie pomocou klucov do vystupneho vektoru
Y_code = "";
Cb_code = "";
Cr_code = "";
for i=1:1:size(Y_v,2)-1
Y_code = Y_code + t_Y(Y_v(i));
end
for i=1:1:size(Cb_v,2)-1
Cb_code = Cb_code + t_Cb(Cb_v(i)) ;
end
for i=1:1:size(Cr_v,2)-1
Cr_code = Cr_code + t_Cr(Cr_v(i)) ;
end

Y_code = convertStringsToChars(Y_code);
Cb_code = convertStringsToChars(Cb_code);
Cr_code = convertStringsToChars(Cr_code);
%koniec zakodovanie pomocou klucov do vystupneho vektoru
end

function [Y, Cb, Cr] = make_invHuffman(Y_code, Cb_code, Cr_code, tree_Y,tree_Cb, tree_Cr)
Y = [];
Cb = [];
Cr = [];
uzol = tree_Y;
for i=1:1:strlength(Y_code) 
    value = str2double(Y_code(i));
    if value == 1
            if size(uzol{1,1}) == 1
                Y = [Y,uzol{1,1}];
                uzol = tree_Y;
            else
                uzol = uzol{1,1};  
            end
        else
            if size(uzol{1,2}) == 1
                Y = [Y,uzol{1,2}];
                uzol = tree_Y;
            else
                uzol = uzol{1,2};  
            end 
    end
end

uzol = tree_Cb;
for i=1:1:strlength(Cb_code) 
    value = str2double(Cb_code(i));
    if value == 1
            if size(uzol{1,1}) == 1
                Cb = [Cb,uzol{1,1}];
                uzol = tree_Cb;
            else
                uzol = uzol{1,1};  
            end
        else
            if size(uzol{1,2}) == 1
                Cb = [Cb,uzol{1,2}];
                uzol = tree_Cb;
            else
                uzol = uzol{1,2};  
            end 
    end
end

uzol = tree_Cr;
for i=1:1:strlength(Cr_code) 
    value = str2double(Cr_code(i));
    if value == 1
            if size(uzol{1,1}) == 1
                Cr = [Cr,uzol{1,1}];
                uzol = tree_Cr;
            else
                uzol = uzol{1,1};  
            end
        else
            if size(uzol{1,2}) == 1
                Cr = [Cr,uzol{1,2}];
                uzol = tree_Cr;
            else
                uzol = uzol{1,2};  
            end 
    end
end

end

%reccursion
function recursion(table,uzol,sekvence) 
sekvence1 = sekvence + "1";
    if size(uzol{1,1}) == 1
        table(uzol{1,1}) = sekvence1;
    else
        recursion(table,uzol{1,1},sekvence1);
    end
        sekvence0 = sekvence + "0";
    if size(uzol{1,2}) == 1
        table(uzol{1,2}) = sekvence0;
    else
        recursion(table,uzol{1,2},sekvence0);
    end
end