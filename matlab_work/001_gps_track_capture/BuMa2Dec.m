function intNumber = BuMa2Dec(binaryNumber);
%     补码转化为十进制数函数
% intNumber = twosComp2dec(binaryNumber)
% 判断是否为字符
if ~isstr(binaryNumber)
    error('Input must be a string.');
end
% 二进制转化为十进制
intNumber = bin2dec(binaryNumber);
% 如果符号位为1，则对该数进行补码还原
if binaryNumber(1) == '1'
    intNumber = intNumber - 2^size(binaryNumber, 2);
end

end