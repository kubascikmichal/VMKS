
clear all;
close all;

data = imread("Yrobot_sch1.jpg");
[x,y,z] = size(data);

for i=1:1:x
    for j=1:1:y
        if (data(i,j,1) > 200) 
            vector(((i-1)*y) + j) = 1;
        else
            vector(((i-1)*y) + j) = 0;
        end
    end 
end

code = uint8([]);
last = vector(1);
count = 1;
last_index = 1;
for i=2:1:length(vector)
    if(last == vector(i) || count == 255)
        count = count+1;
    else
        code(last_index) = last;
        code(last_index+1) = count;
        last_index = last_index +2;
        last = vector(i);
        count = 1;
    end
end
code(last_index) = last;
code(last_index+1) = count;

vector_after = [];
for i=1:2:length(code)
    if(code(i) == 1)
        vector_after = [vector_after, ones(1,code(i+1))];
    else
        vector_after = [vector_after, zeros(1,code(i+1))];
    end
end

new_image = zeros(x,y);
for i=1:1:x
    for j=1:1:y
        new_image(i,j) = vector_after((i-1)*y + j);
    end 
end
