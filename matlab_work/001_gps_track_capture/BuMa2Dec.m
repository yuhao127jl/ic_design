function intNumber = BuMa2Dec(binaryNumber);
%     ����ת��Ϊʮ����������
% intNumber = twosComp2dec(binaryNumber)
% �ж��Ƿ�Ϊ�ַ�
if ~isstr(binaryNumber)
    error('Input must be a string.');
end
% ������ת��Ϊʮ����
intNumber = bin2dec(binaryNumber);
% �������λΪ1����Ը������в��뻹ԭ
if binaryNumber(1) == '1'
    intNumber = intNumber - 2^size(binaryNumber, 2);
end

end