function X = quant_bit(carrier,bit_width)
% ����������������
% ����������壺
%   �������������carrierΪ��Ҫ���������ݣ�bit_widthΪ����λ��                
%   ������������� XΪ�����������
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
