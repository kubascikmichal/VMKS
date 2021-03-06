clear all;
close all;
data = imread("lena160x160.jpg");
[x,y,z] = size(data);
dataR = data(:,:,1);
dataG = data(:,:,2);
dataB = data(:,:,3);

counts_R = (zeros(1,256));
counts_G = (zeros(1,256));
counts_B = (zeros(1,256));

for i=1:1:x
    for j=1:1:y
        counts_R(dataR(i,j)+1) = counts_R(dataR(i,j)+1) + 1;
        counts_G(dataG(i,j)+1) = counts_G(dataG(i,j)+1) + 1;
        counts_B(dataB(i,j)+1) = counts_B(dataB(i,j)+1) + 1;
    end
end

counts_sorted_R = (cell(256,1,2));
counts_sorted_G = (cell(256,1,2));
counts_sorted_B = (cell(256,1,2));

for i=1:1:256
        counts_sorted_R(i,1,1) = i;
        counts_sorted_R(i,1,2) = counts_R(i);
        counts_sorted_G(i,1,1) = i;
        counts_sorted_G(i,1,2) = counts_G(i);
        counts_sorted_B(i,1,1) = i;
        counts_sorted_B(i,1,2) = counts_B(i);
end

function outCell = twoCellsToOne(cellFirst, cellSecond)
    outCell = [cellFirst; cellSecond];
end

function sortedCellVector = sortCellVector(cellVector) 
    for i=1:1:size(cellVector)
       for j=1:1:size(cellVector)-i
             if (cellVector{j+1,1,1} < cellVector{j,1,1})
                tmp = cellVector{j+1,1,1};
                cellVector{j+1,:,:} = cellVector{j,:,:};
                cellVector{j,:,:} = tmp;
             end
       end
    end
      sortedCellVector = cellVector;
end
