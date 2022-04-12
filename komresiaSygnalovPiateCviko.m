%Huffman
clear all;
close all;


data = double(imread("lena160x160.jpg"));
[x,y,z] = size(data);


ImageRGBCount = zeros(2,256,3); %tabulka pocetnosti

    ImageRGBCount(1,1,1) = 0;   % naplnanie tabulky kodom farby R
    ImageRGBCount(1,1,2) = 0;   % naplnanie tabulky kodom farby G
    ImageRGBCount(1,1,3) = 0;   % naplnanie tabulky kodom farby B

for a=2:1:256                 % naplnanie tabulky z pocetnostou
    ImageRGBCount(1,a,1) = a-1;   % naplnanie tabulky kodom farby R
    ImageRGBCount(1,a,2) = a-1;   % naplnanie tabulky kodom farby G
    ImageRGBCount(1,a,3) = a-1;   % naplnanie tabulky kodom farby B
end    

for a=1:1:x                 % priradenie pocetnosti do tabulky pre jednotlive farby
    for b=1:1:y    
            R = data(a,b,1);
            G = data(a,b,2);        
            B = data(a,b,3);
        
                ImageRGBCount(2,R+1,1) = ImageRGBCount(2,R+1,1) + 1;
                ImageRGBCount(2,G+1,2) = ImageRGBCount(2,G+1,2) + 1;
                ImageRGBCount(2,B+1,3) = ImageRGBCount(2,B+1,3) + 1;
    end
end   % koniec priradenie pocetnosti do tabulky pre jednotlive farby

for a=1:1:3
for repeat=1:1:256                % usporiadanie
    for b=1:1:255
        if ImageRGBCount(2,b,a) < ImageRGBCount(2,b+1,a)
       value =  ImageRGBCount(2,b,a);
       ImageRGBCount(2,b,a) = ImageRGBCount(2,b+1,a);
       ImageRGBCount(2,b+1,a) = value;
       value =  ImageRGBCount(1,b,a);
       ImageRGBCount(1,b,a) = ImageRGBCount(1,b+1,a);
       ImageRGBCount(1,b+1,a) = value;
        end
    end
end
end          % koniec usporiadania

indexR = 256; %dokoncit vyhladavanie prvej farby ktora nema pocetnost 0
indexG= 256;
indexB = 256;
while ImageRGBCount(2,indexR,1) <= 0
indexR = indexR - 1;
end
while ImageRGBCount(2,indexG,2) <= 0
indexG = indexG - 1;
end
while ImageRGBCount(2,indexB,3) <= 0
indexB = indexB - 1;
end

newCellArrayR = zeros(2,2);
newCellArrayR(1,1) = ImageRGBCount(1,indexR,1);
newCellArrayR(2,1) = ImageRGBCount(2,indexR,1);
newCellArrayR(1,2) = ImageRGBCount(1,indexR-1,1);
newCellArrayR(2,2) = ImageRGBCount(2,indexR-1,1);

newCellArrayG = zeros(2,2);
newCellArrayG(1,1) = ImageRGBCount(1,indexG,2);
newCellArrayG(2,1) = ImageRGBCount(2,indexG,2);
newCellArrayG(1,2) = ImageRGBCount(1,indexG-1,2);
newCellArrayG(2,2) = ImageRGBCount(2,indexG-1,2);

newCellArrayB = zeros(2,2);
newCellArrayB(1,1) = ImageRGBCount(1,indexB,3);
newCellArrayB(2,1) = ImageRGBCount(2,indexB,3);
newCellArrayB(1,2) = ImageRGBCount(1,indexB-1,3);
newCellArrayB(2,2) = ImageRGBCount(2,indexB-1,3);


cellCountedR = num2cell(newCellArrayR);
RCellCounted = {cellCountedR};

cellCountedG = num2cell(newCellArrayG);
GCellCounted = {cellCountedG};

cellCountedB = num2cell(newCellArrayB);
BCellCounted = {cellCountedB};



countR = (newCellArrayR(2,1)+newCellArrayR(2,2));
countG = (newCellArrayG(2,1)+newCellArrayG(2,2));
countB = (newCellArrayB(2,1)+newCellArrayB(2,2));


cellValueOfCountR = num2cell(countR);
cellValueOfCountG = num2cell(countG);
cellValueOfCountB = num2cell(countB);



cellImageRGBCount = num2cell(ImageRGBCount);



cellImageRGBCount(2,indexR-1,1) = cellValueOfCountR;
cellImageRGBCount(1,indexR-1,1) = RCellCounted;
cellImageRGBCount(2,indexR,1) = {0};
cellImageRGBCount(1,indexR,1) = {0};

cellImageRGBCount(2,indexG-1,2) = cellValueOfCountG;
cellImageRGBCount(1,indexG-1,2) = GCellCounted;
cellImageRGBCount(2,indexG,2) = {0};
cellImageRGBCount(1,indexG,2) = {0};

cellImageRGBCount(2,indexB-1,3) = cellValueOfCountB;
cellImageRGBCount(1,indexB-1,3) = BCellCounted;
cellImageRGBCount(2,indexB,3) = {0};
cellImageRGBCount(1,indexB,3) = {0};

indexR = indexR -1;

while cellImageRGBCount{2,2,1} > 0  || cellImageRGBCount{2,2,2} > 0 || cellImageRGBCount{2,2,3} > 0
for a=1:1:3
for repeat=1:1:255                % usporiadanie
    for b=1:1:254
        %if (cell2mat(cellImageRGBCount(2,b,a))) < (cell2mat(cellImageRGBCount(2,b+1,a)))
        if (cellImageRGBCount{2,b,a} < cellImageRGBCount{2,b+1,a})
       value =  cellImageRGBCount(2,b,a);
       cellImageRGBCount(2,b,a) = cellImageRGBCount(2,b+1,a);
       cellImageRGBCount(2,b+1,a) = value;
       value =  cellImageRGBCount(1,b,a);
       cellImageRGBCount(1,b,a) = cellImageRGBCount(1,b+1,a);
       cellImageRGBCount(1,b+1,a) = value;
        end
    end
end
end 
if(cellImageRGBCount{2,2,1} > 0)  %pre R
newCellR = cell(2);
newCellR(1,1) = cellImageRGBCount(1,indexR,1);
newCellR(2,1) = cellImageRGBCount(2,indexR,1);
newCellR(1,2) = cellImageRGBCount(1,indexR-1,1);
newCellR(2,2) = cellImageRGBCount(2,indexR-1,1);

count =newCellR{2,1} + newCellR{2,2};

cellImageRGBCount(1,indexR-1,1) = {newCellR};
cellImageRGBCount(2,indexR-1,1) = num2cell(count);
cellImageRGBCount(2,indexR,1) = {0};
cellImageRGBCount(1,indexR,1) = {0};
indexR = indexR-1
end

        
if(cellImageRGBCount{2,2,2} > 0)            %pre G
newCellG = cell(2);
newCellG(1,1) = cellImageRGBCount(1,indexG,2);
newCellG(2,1) = cellImageRGBCount(2,indexG,2);
newCellG(1,2) = cellImageRGBCount(1,indexG-1,2);
newCellG(2,2) = cellImageRGBCount(2,indexG-1,2);

countG =newCellG{2,1} + newCellG{2,2};

cellImageRGBCount(1,indexG-1,2) = {newCellG};
cellImageRGBCount(2,indexG-1,2) = num2cell(countG);
cellImageRGBCount(2,indexG,2) = {0};
cellImageRGBCount(1,indexG,2) = {0};
indexG = indexG-1
end


if(cellImageRGBCount{2,2,3} > 0)            %preB
newCellB = cell(2);
newCellB(1,1) = cellImageRGBCount(1,indexB,3);
newCellB(2,1) = cellImageRGBCount(2,indexB,3);
newCellB(1,2) = cellImageRGBCount(1,indexB-1,3);
newCellB(2,2) = cellImageRGBCount(2,indexB-1,3);

countB =newCellB{2,1} + newCellB{2,2};

cellImageRGBCount(1,indexB-1,3) = {newCellB};
cellImageRGBCount(2,indexB-1,3) = num2cell(countB);
cellImageRGBCount(2,indexB,3) = {0};
cellImageRGBCount(1,indexB,3) = {0};
indexB = indexB-1
end
end 







    
    






