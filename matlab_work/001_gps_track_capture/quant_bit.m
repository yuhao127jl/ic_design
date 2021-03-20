function X = quant_bit(carrier,bit_width)
% 比特量化函数定义
% 输入输出定义：
%   函数输入变量：carrier为需要量化的数据，bit_width为量化位宽                
%   函数输出变量： X为量化后的数据
if(bit_width>2)
    X = fix((carrier*2^(bit_width-1)-1)/max(carrier));
else
    for k = 1:length(carrier)
        if(carrier(k)>0)
            X(k) = 1;
        else
            X(k) = -1;
        end
    end
end
