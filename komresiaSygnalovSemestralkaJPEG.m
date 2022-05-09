%JPEG
%prevod do JPEG
clear all;
close all;


data = double(imread("lena160x160.jpg"));
[x,y,z] = size(data);

KR = 0.299;
KG = 0.587;
KB = 0.114;


ImageYCbCr = zeros(x,y,z); %obrazok v YCrCb

for a=1:1:x                 % prevod na YCrCb
    for b=1:1:y    
            R = data(a,b,1);
            G = data(a,b,2);        
            B = data(a,b,3);
     
            ImageYCbCr(a,b,1) = (KR*R) + (KG*G) + (KB*B);
            ImageYCbCr(a,b,2) = 128 + (0.5* ((B - ImageYCbCr(a,b,1))/(1 - KB))); %Cb
            ImageYCbCr(a,b,3) = 128 + (0.5* ((R - ImageYCbCr(a,b,1))/(1 - KR)));  %Cr
    end
end                         % konec prevodu na YCrCb


%komresia 4:2:0

ImageYCbCrCompresed = zeros(x,y,z); %obrazok v YCbCr kompresia 4:2:0

ImageYCbCrCompresed(:,:,1) = ImageYCbCr(:,:,1); %kopirovanie Y

for a=1:2:x
    for b=1:2:y
    ImageYCbCrCompresed(a,b,2) = ImageYCbCr(a,b,2); %polovicka horizontalne a aj vertikalne pe Cb 
    ImageYCbCrCompresed((a+1),b,2) = ImageYCbCr(a,b,2);
    ImageYCbCrCompresed(a,(b+1),2) = ImageYCbCr(a,b,2);
    ImageYCbCrCompresed((a+1),(b+1),2) = ImageYCbCr(a,b,2);     %koniec polovicka horiyontalne a aj vertikalne pe Cb 

    ImageYCbCrCompresed(a,b,3) = ImageYCbCr(a,b,3);     %polovicka horizontalne a aj vertikalne pe Cr 
    ImageYCbCrCompresed((a+1),b,3) = ImageYCbCr(a,b,3);
    ImageYCbCrCompresed(a,(b+1),3) = ImageYCbCr(a,b,3);
    ImageYCbCrCompresed((a+1),(b+1),3) = ImageYCbCr(a,b,3);      %koniec polovicka horiyontalne a aj vertikalne pe Cr
    end
end
%koniec komresia 4:2:0

%rozdelenie do blokov 8x8
Rblocks8x8 = zeros(8,8,((x/8)*(y/8)));      %matice 8x8 pre R
Gblocks8x8 = zeros(8,8,((x/8)*(y/8)));      %matice 8x8 pre G
Bblocks8x8 = zeros(8,8,((x/8)*(y/8)));      %matice 8x8 pre B

counterD=1;

    for a=1:8:x
        for b=1:8:y
            
                for e=1:1:8
                    for f=1:1:8
                    Rblocks8x8(e,f,counterD) = ImageYCbCrCompresed(e+a-1,f+b-1,1);
                    Gblocks8x8(e,f,counterD) = ImageYCbCrCompresed(e+a-1,f+b-1,2);
                    Bblocks8x8(e,f,counterD) = ImageYCbCrCompresed(e+a-1,f+b-1,3);
                    end
                end
            counterD = counterD+1;
        end
    end
%koniec rozdelenie do blokov 8x8

%DCT
vectorAfterDCTR = zeros(1,8);
vectorAfterDCTG = zeros(1,8);
vectorAfterDCTB = zeros(1,8);

N = 8;
for i=1:1:((x/8)*(y/8))
    for j=1:1:8
        for k = 1:1:8               
            for n = 1:1:8
sumR = Rblocks8x8(j,n,i)*cos((pi/N)*((n-1)+(1/2))*(k-1));
vectorAfterDCTR(k) = vectorAfterDCTR(k) + sumR;

sumG = Gblocks8x8(j,n,i)*cos((pi/N)*((n-1)+(1/2))*(k-1));
vectorAfterDCTG(k) = vectorAfterDCTG(k) + sumG;

sumB = Bblocks8x8(j,n,i)*cos((pi/N)*((n-1)+(1/2))*(k-1));
vectorAfterDCTB(k) = vectorAfterDCTB(k) + sumB;
            end
        end
        Rblocks8x8(j,:,i) = vectorAfterDCTR(:);
        Gblocks8x8(j,:,i) = vectorAfterDCTG(:);
        Bblocks8x8(j,:,i) = vectorAfterDCTB(:);
        
        vectorAfterDCTR = zeros(1,8);
        vectorAfterDCTG = zeros(1,8);
        vectorAfterDCTB = zeros(1,8);
    end
end
clear vectorAfterDCTR vectorAfterDCTG vectorAfterDCTB sumB sumG sumR
%koniec DCT

%kvantizacia
matrixChroma = [17 18 24 47 99 99 99 99;18 21 26 66 99 99 99 99;24 26 56 99 99 99 99 99;47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;99 99 99 99 99 99 99 99;99 99 99 99 99 99 99 99;99 99 99 99 99 99 99 99];
matrixLuma = [16 11 10 16 24 40 51 61;12 12 14 19 26 58 60 55;14 13 16 24 40 57 69 56;14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;24 35 55 64 81 104 113 92;49 64 78 87 103 121 120 101;72 92 95 98 112 100 103 99];

for i=1:1:((x/8)*(y/8))
    for j=1:1:8
        for k=1:1:8
        Rblocks8x8(j,k,i) = round(Rblocks8x8(j,k,i)/matrixLuma(j,k));
        Gblocks8x8(j,k,i) = round(Gblocks8x8(j,k,i)/matrixChroma(j,k));
        Bblocks8x8(j,k,i) = round(Bblocks8x8(j,k,i)/matrixChroma(j,k));
        end
    end
end

%koniec kvantizacie

%ZIGZAG
outputVectorR = zeros(1,(((x/8)*(y/8))*64));  %vytvorenie vystupneho vektora
outputVectorCounterR = 1; %pocitadlo
outputVectorG = zeros(1,(((x/8)*(y/8))*64));  %vytvorenie vystupneho vektora
outputVectorCounterG = 1; %pocitadlo
outputVectorB = zeros(1,(((x/8)*(y/8))*64));  %vytvorenie vystupneho vektora
outputVectorCounterB = 1; %pocitadlo

for j=1:1:((x/8)*(y/8))
    for i=1:1:15
        for l = 1:1:i
        k = i - l + 1;
        modulo = mod(i,2);
            if l<=8 && k <= 8
                if modulo == 1
                outputVectorR(1,outputVectorCounterR) = Rblocks8x8(k,l,j); 
                outputVectorCounterR = outputVectorCounterR +1;
                
                outputVectorG(1,outputVectorCounterG) = Gblocks8x8(k,l,j); 
                outputVectorCounterG = outputVectorCounterG +1;
                
                outputVectorB(1,outputVectorCounterB) = Bblocks8x8(k,l,j); 
                outputVectorCounterB = outputVectorCounterB +1;
                else
                outputVectorR(1,outputVectorCounterR) = Rblocks8x8(l,k,j);
                outputVectorCounterR = outputVectorCounterR +1;

                outputVectorG(1,outputVectorCounterG) = Gblocks8x8(l,k,j);
                outputVectorCounterG = outputVectorCounterG +1;

                outputVectorB(1,outputVectorCounterB) = Bblocks8x8(l,k,j);
                outputVectorCounterB = outputVectorCounterB +1;
                end
            end
        end
    end
end
%koniec ZIGZAG

%RLE
outputVectorAfterRLER = zeros(1,(((x/8)*(y/8))*64));
outputVectorAfterRLERCounter = 1;

outputVectorAfterRLEG = zeros(1,(((x/8)*(y/8))*64));
outputVectorAfterRLEGCounter = 1;

outputVectorAfterRLEB = zeros(1,(((x/8)*(y/8))*64));
outputVectorAfterRLEBCounter = 1;

sumR = 1;
sumG = 1;
sumB = 1;

valueR = outputVectorR(1,1);
if  valueR ~= 0 || outputVectorAfterRLER(1,1) == 0 || outputVectorAfterRLER(1,2) == 0
outputVectorAfterRLER(1,outputVectorAfterRLERCounter) = valueR;
sumR = 1;
end
valueG = outputVectorG(1,1);
if  valueG ~= 0 || outputVectorAfterRLEG(1,1) == 0 || outputVectorAfterRLEG(1,2) == 0
outputVectorAfterRLEG(1,outputVectorAfterRLEGCounter) = valueG;
sumG = 1;
end
valueB = outputVectorB(1,1);
if  valueB ~= 0 || outputVectorAfterRLEB(1,1) == 0 || outputVectorAfterRLEB(1,2) == 0
outputVectorAfterRLEB(1,outputVectorAfterRLEBCounter) = valueB;
sumB = 1;
end

for i=2:1:(((x/8)*(y/8))*64)
valueR = outputVectorR(1,i);
valueG = outputVectorG(1,i);
valueB = outputVectorB(1,i);

if valueR == outputVectorAfterRLER(1,outputVectorAfterRLERCounter)
sumR = sumR + 1;
else
 outputVectorAfterRLERCounter = outputVectorAfterRLERCounter+1;   
outputVectorAfterRLER(1,(outputVectorAfterRLERCounter)) = sumR;
outputVectorAfterRLERCounter = outputVectorAfterRLERCounter+1; 
outputVectorAfterRLER(1,outputVectorAfterRLERCounter) = valueR;
sumR = 1;
end 

if valueG == outputVectorAfterRLEG(1,outputVectorAfterRLEGCounter)
sumG = sumG + 1;
else
 outputVectorAfterRLEGCounter = outputVectorAfterRLEGCounter+1;   
outputVectorAfterRLEG(1,(outputVectorAfterRLEGCounter)) = sumG;
outputVectorAfterRLEGCounter = outputVectorAfterRLEGCounter+1; 
outputVectorAfterRLEG(1,outputVectorAfterRLEGCounter) = valueG;
sumG = 1;
end 

if valueB == outputVectorAfterRLEB(1,outputVectorAfterRLEBCounter)
sumB = sumB + 1;
else
outputVectorAfterRLEBCounter = outputVectorAfterRLEBCounter+1;   
outputVectorAfterRLEB(1,(outputVectorAfterRLEBCounter)) = sumB;
outputVectorAfterRLEBCounter = outputVectorAfterRLEBCounter+1; 
outputVectorAfterRLEB(1,outputVectorAfterRLEBCounter) = valueB;
sumB = 1;
end 
end

outputVectorAfterRLERCounter = outputVectorAfterRLERCounter+1; 
outputVectorAfterRLER(1,(outputVectorAfterRLERCounter)) = sumR;

outputVectorAfterRLEGCounter = outputVectorAfterRLEGCounter+1; 
outputVectorAfterRLEG(1,(outputVectorAfterRLEGCounter)) = sumG;

outputVectorAfterRLEBCounter = outputVectorAfterRLEBCounter+1; 
outputVectorAfterRLEB(1,(outputVectorAfterRLEBCounter)) = sumB;

outputVectorAfterRLERcopy = zeros(1,outputVectorAfterRLERCounter);
outputVectorAfterRLEGcopy = zeros(1,outputVectorAfterRLEGCounter);
outputVectorAfterRLEBcopy = zeros(1,outputVectorAfterRLEBCounter);

for i =1:1:outputVectorAfterRLERCounter
outputVectorAfterRLERcopy(1,i) = outputVectorAfterRLER(1,i);
end
outputVectorAfterRLER = zeros(1,outputVectorAfterRLERCounter);
outputVectorAfterRLER = outputVectorAfterRLERcopy;

for i =1:1:outputVectorAfterRLEGCounter
outputVectorAfterRLEGcopy(1,i) = outputVectorAfterRLEG(1,i);
end
outputVectorAfterRLEG = zeros(1,outputVectorAfterRLEGCounter);
outputVectorAfterRLEG = outputVectorAfterRLEGcopy;

for i =1:1:outputVectorAfterRLEBCounter
outputVectorAfterRLEBcopy(1,i) = outputVectorAfterRLEB(1,i);
end
outputVectorAfterRLEB = zeros(1,outputVectorAfterRLEBCounter);
outputVectorAfterRLEB = outputVectorAfterRLEBcopy;

clear outputVectorAfterRLERcopy outputVectorAfterRLEGcopy outputVectorAfterRLEBcopy;

%koniec RLE

%Huffman
%Tabulka pocetnosti
vectorOfCountsR = zeros(2,outputVectorAfterRLERCounter);
vectorOfCountsRCounter = 2;

vectorOfCountsG = zeros(2,outputVectorAfterRLEGCounter);
vectorOfCountsGCounter = 2;

vectorOfCountsB = zeros(2,outputVectorAfterRLEBCounter);
vectorOfCountsBCounter = 2;

for i=1:2:outputVectorAfterRLERCounter
    for j=1:1:vectorOfCountsRCounter
        if outputVectorAfterRLER(i) == vectorOfCountsR(1,j)
            vectorOfCountsR(2,j) = vectorOfCountsR(2,j) + outputVectorAfterRLER(i+1);
            break;
        else
            if j == vectorOfCountsRCounter 
            vectorOfCountsR(1,j) = outputVectorAfterRLER(i);
            vectorOfCountsR(2,j) = outputVectorAfterRLER(i+1); 
            vectorOfCountsRCounter = vectorOfCountsRCounter + 1;
            end
        end
    end
end

for i=1:2:outputVectorAfterRLEGCounter
    for j=1:1:vectorOfCountsGCounter
        if outputVectorAfterRLEG(i) == vectorOfCountsG(1,j)
            vectorOfCountsG(2,j) = vectorOfCountsG(2,j) + outputVectorAfterRLEG(i+1);
            break;
        else
            if j == vectorOfCountsGCounter 
            vectorOfCountsG(1,j) = outputVectorAfterRLEG(i);
            vectorOfCountsG(2,j) = outputVectorAfterRLEG(i+1); 
            vectorOfCountsGCounter = vectorOfCountsGCounter + 1;
            end
        end
    end
end

for i=1:2:outputVectorAfterRLEBCounter
    for j=1:1:vectorOfCountsBCounter
        if outputVectorAfterRLEB(i) == vectorOfCountsB(1,j)
            vectorOfCountsB(2,j) = vectorOfCountsB(2,j) + outputVectorAfterRLEB(i+1);
            break;
        else
            if j == vectorOfCountsBCounter 
            vectorOfCountsB(1,j) = outputVectorAfterRLEB(i);
            vectorOfCountsB(2,j) = outputVectorAfterRLEB(i+1); 
            vectorOfCountsBCounter = vectorOfCountsBCounter + 1;
            end
        end
    end
end

%vectorOfCountsRCounter = vectorOfCountsRCounter - 1;
%vectorOfCountsGCounter = vectorOfCountsGCounter - 1;
%vectorOfCountsBCounter = vectorOfCountsBCounter - 1;

vectorOfCountsRcopy = zeros(2,vectorOfCountsRCounter);
vectorOfCountsGcopy = zeros(2,vectorOfCountsGCounter);
vectorOfCountsBcopy = zeros(2,vectorOfCountsBCounter);

for i =1:1:vectorOfCountsRCounter
vectorOfCountsRcopy(1,i) = vectorOfCountsR(1,i);
vectorOfCountsRcopy(2,i) = vectorOfCountsR(2,i);
end

for i =1:1:vectorOfCountsGCounter
vectorOfCountsGcopy(1,i) = vectorOfCountsG(1,i);
vectorOfCountsGcopy(2,i) = vectorOfCountsG(2,i);
end

for i =1:1:vectorOfCountsBCounter
vectorOfCountsBcopy(1,i) = vectorOfCountsB(1,i);
vectorOfCountsBcopy(2,i) = vectorOfCountsB(2,i);
end

vectorOfCountsR = zeros(2,vectorOfCountsRCounter);
vectorOfCountsG = zeros(2,vectorOfCountsGCounter);
vectorOfCountsB = zeros(2,vectorOfCountsBCounter);

for i =1:1:vectorOfCountsRCounter
vectorOfCountsR(1,i) = vectorOfCountsRcopy(1,i);
vectorOfCountsR(2,i) = vectorOfCountsRcopy(2,i);
end

for i =1:1:vectorOfCountsGCounter
vectorOfCountsG(1,i) = vectorOfCountsGcopy(1,i);
vectorOfCountsG(2,i) = vectorOfCountsGcopy(2,i);
end

for i =1:1:vectorOfCountsBCounter
vectorOfCountsB(1,i) = vectorOfCountsBcopy(1,i);
vectorOfCountsB(2,i) = vectorOfCountsBcopy(2,i);
end

clear vectorOfCountsRcopy vectorOfCountsGcopy vectorOfCountsBcopy;
%koniec Tabulka pocetnosti
cellvectorOfCountsR = num2cell(vectorOfCountsR);
cellvectorOfCountsG = num2cell(vectorOfCountsG);
cellvectorOfCountsB = num2cell(vectorOfCountsB);

clear vectorOfCountsR vectorOfCountsG vectorOfCountsB;
%Usporiadanie

indexR = vectorOfCountsRCounter-1;
indexG = vectorOfCountsGCounter-1;
indexB = vectorOfCountsBCounter-1;

while cellvectorOfCountsR{2,2} > 0  || cellvectorOfCountsG{2,2} > 0 || cellvectorOfCountsB{2,2} > 0
for repeat=1:1:vectorOfCountsRCounter                % usporiadanieR
    for b=1:1:vectorOfCountsRCounter-1
        if cellvectorOfCountsR{2,b} < cellvectorOfCountsR{2,b+1}
       value =  cellvectorOfCountsR{2,b};
       cellvectorOfCountsR(2,b) = cellvectorOfCountsR(2,b+1);
       cellvectorOfCountsR{2,b+1} = value;
       value =  cellvectorOfCountsR(1,b);
       cellvectorOfCountsR(1,b) = cellvectorOfCountsR(1,b+1);
       cellvectorOfCountsR(1,b+1) = value;
        end
    end
end

for repeat=1:1:vectorOfCountsGCounter                % usporiadanieG
    for b=1:1:vectorOfCountsGCounter-1
        if cellvectorOfCountsG{2,b} < cellvectorOfCountsG{2,b+1}
       value =  cellvectorOfCountsG{2,b};
       cellvectorOfCountsG(2,b) = cellvectorOfCountsG(2,b+1);
       cellvectorOfCountsG{2,b+1} = value;
       value =  cellvectorOfCountsG(1,b);
       cellvectorOfCountsG(1,b) = cellvectorOfCountsG(1,b+1);
       cellvectorOfCountsG(1,b+1) = value;
        end
    end
end

for repeat=1:1:vectorOfCountsBCounter                % usporiadanieB
    for b=1:1:vectorOfCountsBCounter-1
        if cellvectorOfCountsB{2,b} < cellvectorOfCountsB{2,b+1}
       value =  cellvectorOfCountsB{2,b};
       cellvectorOfCountsB(2,b) = cellvectorOfCountsB(2,b+1);
       cellvectorOfCountsB{2,b+1} = value;
       value =  cellvectorOfCountsB(1,b);
       cellvectorOfCountsB(1,b) = cellvectorOfCountsB(1,b+1);
       cellvectorOfCountsB(1,b+1) = value;
        end
    end
end

clear value;


%koniec Usporiadanie

if(cellvectorOfCountsR{2,2} > 0)  %pre R
newCellR = cell(3,2);
newCellR(1,1) = cellvectorOfCountsR(1,indexR);
newCellR(2,1) = cellvectorOfCountsR(2,indexR);
newCellR(1,2) = cellvectorOfCountsR(1,indexR-1);
newCellR(2,2) = cellvectorOfCountsR(2,indexR-1);
newCellR{3,1} = 1; 
newCellR{3,2} = 0;

count =newCellR{2,1} + newCellR{2,2};

cellvectorOfCountsR(1,indexR-1) = {newCellR};
cellvectorOfCountsR(2,indexR-1) = num2cell(count);
cellvectorOfCountsR(2,indexR) = {0};
cellvectorOfCountsR(1,indexR) = {0};
indexR = indexR-1;
end
        
if(cellvectorOfCountsG{2,2} > 0)            %pre G
newCellG = cell(2);
newCellG(1,1) = cellvectorOfCountsG(1,indexG);
newCellG(2,1) = cellvectorOfCountsG(2,indexG);
newCellG(1,2) = cellvectorOfCountsG(1,indexG-1);
newCellG(2,2) = cellvectorOfCountsG(2,indexG-1);

countG =newCellG{2,1} + newCellG{2,2};

cellvectorOfCountsG(1,indexG-1) = {newCellG};
cellvectorOfCountsG(2,indexG-1) = num2cell(countG);
cellvectorOfCountsG(2,indexG) = {0};
cellvectorOfCountsG(1,indexG) = {0};
indexG = indexG-1;
end


if(cellvectorOfCountsB{2,2} > 0)            %preB
newCellB = cell(2);
newCellB(1,1) = cellvectorOfCountsB(1,indexB);
newCellB(2,1) = cellvectorOfCountsB(2,indexB);
newCellB(1,2) = cellvectorOfCountsB(1,indexB-1);
newCellB(2,2) = cellvectorOfCountsB(2,indexB-1);

countB =newCellB{2,1} + newCellB{2,2};

cellvectorOfCountsB(1,indexB-1) = {newCellB};
cellvectorOfCountsB(2,indexB-1) = num2cell(countB);
cellvectorOfCountsB(2,indexB) = {0};
cellvectorOfCountsB(1,indexB) = {0};
indexB = indexB-1;
end
end


%spustenie rekurzie pre vztvorenie tabulky
tableR = containers.Map('KeyType','double','ValueType','char'); %tabulka koncova s klucom na kodovanie
reccursion(tableR,cellvectorOfCountsR{1,1},"");
tableG = containers.Map('KeyType','double','ValueType','char'); %tabulka koncova s klucom na kodovanie
reccursion(tableG,cellvectorOfCountsG{1,1},"");
tableB = containers.Map('KeyType','double','ValueType','char'); %tabulka koncova s klucom na kodovanie
reccursion(tableB,cellvectorOfCountsB{1,1},"");
%koniec spustenie rekurzie pre vztvorenie tabulky
ahoj = keys(tableR);
ahoj2 = values(tableR);
%zakodovanie pomocou klucov do vystupneho vektoru
outputR = "";
outputG = "";
outputB = "";
for i=1:1:outputVectorCounterR-1
outputR = outputR + tableR(outputVectorR(i)) ;
end
for i=1:1:outputVectorCounterG-1
outputG = outputG + tableG(outputVectorG(i)) ;
end
for i=1:1:outputVectorCounterB-1
outputB = outputB + tableB(outputVectorB(i)) ;
end
%koniec zakodovanie pomocou klucov do vystupneho vektoru
%koniec Huffman
%koniec prevod do JPEG


%dekodovanie Huffmana 
charsOutputR = outputR{1};
inputVectorR = decodeHuffman(cellvectorOfCountsR{1,1},charsOutputR);

charsOutputG = outputG{1};
inputVectorG = decodeHuffman(cellvectorOfCountsG{1,1},charsOutputG);

charsOutputB = outputB{1};
inputVectorB = decodeHuffman(cellvectorOfCountsB{1,1},charsOutputB);
%koniec dekodovanie Huffmana 

%vytvorenie matic 8x8 pomocou inverse ZIGZAG
inputRblocks8x8 = zeros(8,8,size(inputVectorR,2)/64);
inputVectorCounterR = 1;
inputGblocks8x8 = zeros(8,8,size(inputVectorG,2)/64);
inputVectorCounterG = 1;
inputBblocks8x8 = zeros(8,8,size(inputVectorB,2)/64);
inputVectorCounterB = 1;
for j=1:1:(size(inputVectorR,2)/64)
    for i=1:1:15
        for l = 1:1:i
        k = i - l + 1;
        modulo = mod(i,2);
            if l<=8 && k <= 8
                if modulo == 1
                inputRblocks8x8(k,l,j) =  outputVectorR(1,inputVectorCounterR) ;
                inputVectorCounterR = inputVectorCounterR +1;
                
                inputGblocks8x8(k,l,j) = outputVectorG(1,inputVectorCounterG); 
                inputVectorCounterG = inputVectorCounterG +1;
                
                inputBblocks8x8(k,l,j) =  outputVectorB(1,inputVectorCounterB); 
                inputVectorCounterB = inputVectorCounterB +1;
                else
                inputRblocks8x8(l,k,j) = outputVectorR(1,inputVectorCounterR);
                inputVectorCounterR = inputVectorCounterR +1;

                inputGblocks8x8(l,k,j) = outputVectorG(1,inputVectorCounterG);
                inputVectorCounterG = inputVectorCounterG +1;

                inputBblocks8x8(l,k,j) = outputVectorB(1,inputVectorCounterB);
                inputVectorCounterB = inputVectorCounterB +1;
                end
            end
        end
    end
end
%koniec vytvorenie matic 8x8 pomocou inverse ZIGZAG

%dekvantizacia

for i=1:1:(size(inputVectorR,2)/64)
    for j=1:1:8
        for k=1:1:8
        inputRblocks8x8(j,k,i) = inputRblocks8x8(j,k,i)*matrixLuma(j,k);
        inputGblocks8x8(j,k,i) = inputGblocks8x8(j,k,i)*matrixChroma(j,k);
        inputBblocks8x8(j,k,i) = inputBblocks8x8(j,k,i)*matrixChroma(j,k);
        end
    end
end
%koniec dekvantizacia

%inverse DCT
vectorAfterDCTInverseR = zeros(1,8);
vectorAfterDCTInverseG = zeros(1,8);
vectorAfterDCTInverseB = zeros(1,8);


N = 8;
for i=1:1:((x/8)*(y/8))
    for j=1:1:8
       for k = 1:1:8 
    vectorAfterDCTInverseR(k) = (1/2)*inputRblocks8x8(j,1,i);
     vectorAfterDCTInverseG(k) = (1/2)*inputGblocks8x8(j,1,i);
     vectorAfterDCTInverseB(k) = (1/2)*inputBblocks8x8(j,1,i);
for n = 2:1:8
sumR = inputRblocks8x8(j,n,i)*cos((pi/N)*((k-1)+(1/2))*(n-1));
vectorAfterDCTInverseR(k) = vectorAfterDCTInverseR(k) + sumR;

sumG = inputGblocks8x8(j,n,i)*cos((pi/N)*((k-1)+(1/2))*(n-1));
vectorAfterDCTInverseG(k) = vectorAfterDCTInverseG(k) + sumG;

sumB = inputBblocks8x8(j,n,i)*cos((pi/N)*((k-1)+(1/2))*(n-1));
vectorAfterDCTInverseB(k) = vectorAfterDCTInverseB(k) + sumB;
end
vectorAfterDCTInverseR(k) = vectorAfterDCTInverseR(k)/(N/2);
vectorAfterDCTInverseG(k) = vectorAfterDCTInverseG(k)/(N/2);
vectorAfterDCTInverseB(k) = vectorAfterDCTInverseB(k)/(N/2);
        end
        inputRblocks8x8(j,:,i) = vectorAfterDCTInverseR(:);
        inputGblocks8x8(j,:,i) = vectorAfterDCTInverseG(:);
        inputBblocks8x8(j,:,i) = vectorAfterDCTInverseB(:);
        
        vectorAfterDCTInverseR = zeros(1,8);
        vectorAfterDCTInverseG = zeros(1,8);
        vectorAfterDCTInverseB = zeros(1,8);
    end
end
clear vectorAfterDCTR vectorAfterDCTG vectorAfterDCTB sumR sumG sumB
%koniec inverse DCT

%vytvorenie matice obrazka v 3 rovinach z blokov 
inputImageYCbCrCompressed = zeros(sqrt(size(inputVectorR,2)),sqrt(size(inputVectorR,2)),3);

counterD=1;

    for a=1:8:x
        for b=1:8:y
            
                for e=1:1:8
                    for f=1:1:8
                    inputImageYCbCrCompressed(e+a-1,f+b-1,1) = inputRblocks8x8(e,f,counterD);
                    inputImageYCbCrCompressed(e+a-1,f+b-1,2) = inputGblocks8x8(e,f,counterD);
                    inputImageYCbCrCompressed(e+a-1,f+b-1,3) = inputBblocks8x8(e,f,counterD) ;
                    end
                end
            counterD = counterD+1;
        end
    end
%koniec vytvorenie matice obrazka v 3 rovinach z blokov 

ImageNewRGB = zeros(x,y,z); % obrazok v RGB po YCrCb

for a=1:1:x                 % prevod na RGB
    for b=1:1:y    
            ImageNewRGB(a,b,1) = (((inputImageYCbCrCompressed(a,b,3)-128)/(0.5))*(1-KR)+inputImageYCbCrCompressed(a,b,1));    % R    
            ImageNewRGB(a,b,3) = (((inputImageYCbCrCompressed(a,b,2)-128)/(0.5))*(1-KB)+inputImageYCbCrCompressed(a,b,1));    % B
           ImageNewRGB(a,b,2) = (((inputImageYCbCrCompressed(a,b,1))-(KB*ImageNewRGB(a,b,3))-(KR*ImageNewRGB(a,b,1)))/(KG)); % G
    end
end                         % konec prevodu na RGB


ImageNewRGBorigo = zeros(x,y,z); % obrazok v RGB po YCrCb

for a=1:1:x                 % prevod na RGB
    for b=1:1:y    
            ImageNewRGBorigo(a,b,1) = (((ImageYCbCrCompresed(a,b,3)-128)/(0.5))*(1-KR)+ImageYCbCrCompresed(a,b,1));    % R    
            ImageNewRGBorigo(a,b,3) = (((ImageYCbCrCompresed(a,b,2)-128)/(0.5))*(1-KB)+ImageYCbCrCompresed(a,b,1));    % B
           ImageNewRGBorigo(a,b,2) = (((ImageYCbCrCompresed(a,b,1))-(KB*ImageNewRGBorigo(a,b,3))-(KR*ImageNewRGBorigo(a,b,1)))/(KG)); % G
    end
end                         % konec prevodu na RGB



figure;
imshow(uint8(ImageNewRGBorigo))
figure;
imshow(uint8(ImageNewRGB));

imwrite(ImageNewRGB,'lenaCompresed.jpg');

%reccursion
function reccursion(table,uzol,sekvence) 



sekvence1 = sekvence + "1";
if size(uzol{1,1}) == 1
table(uzol{1,1}) = sekvence1;    %sekvencia + '1'
else
reccursion(table,uzol{1,1},sekvence1); %sekvencia + '1')
end
sekvence2 = sekvence + "0";
if size(uzol{1,2}) == 1
table(uzol{1,2}) = sekvence2;   %sekvencia + '0'
else
reccursion(table,uzol{1,2},sekvence2); %sekvencia + '0')
end

end
%koniec reccursion

%decode huffman
function inputVector = decodeHuffman(huffmanTree,inputString)
i = 1;
inputVector = [];
uzol = huffmanTree;
while i <= strlength(inputString) 
value = str2double(inputString(i));
if value == 1
if size(uzol{1,1}) == 1
inputVector = [inputVector,uzol{1,1}];
uzol = huffmanTree;
else
uzol = uzol{1,1};  
end
else
 if size(uzol{1,2}) == 1
inputVector = [inputVector,uzol{1,2}];
uzol = huffmanTree;
else
uzol = uzol{1,2};  
end 
end
i = i + 1;
end
end
%decode huffman






