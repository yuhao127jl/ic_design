function CA_39MHz = Interp_Decre(CAcode,Freq_sample)
% ��ֵ���̣������ʴ�1.023MHz--->39MHz
% ����������壺CAcodeΪC/A�룬��ƬΪ1023��Freq_sampleΪ��Ҫת���Ĳ������ʣ���
%              ��1.023MHzת����Freq_sample�������ʡ�
%              CA_39MHz�����������ΪFreq_sample��C/A�롣

format long g;
Freq_CA = 1.023e6;     % CA�����Ƭ����
detaT = 0.001;         % �������ݵ�ʱ��Ϊ1ms
Num = detaT*Freq_sample;% 1ms�Ĳ�������39000
N = 1:Num;

CA_buf = repmat(CAcode,1,5);
sign = ceil( (N/Freq_sample+eps)*Freq_CA + eps);
CA_39MHz = CA_buf(sign);
CA_39MHz = [CA_39MHz(1),CA_39MHz(1:end-1)];



% ��ֵ��Ч������ô�ã�����������
% format long g;
% % Freq_sample = 39e6;  % 39MHz�Ĳ�������
% Freq_CA = 1.023e6;        % CA�����Ƭ����
% ratio_val = Freq_sample/Freq_CA;% ����ת����ֵ
% decimal_ratio = ratio_val - floor(ratio_val); % ��ֵ��С������
% val_num = floor(ratio_val);% ��ֵ����������
% % CAcode = CAcodegen(1,1023);
% 
% dec_sum = 0;
% Bu_val = Freq_sample/1000-1023*val_num;% 126
% Bu_pos = val_num*ones(1,1023);% �Բ���39���ж�λ
% % ��¼��Ҫ��39����λ��
% for n=1:1023
%     if(dec_sum<1)
%         dec_sum = dec_sum + decimal_ratio;
%     end
%     if(dec_sum>=1)
%         dec_sum = dec_sum - 1;
%         Bu_pos(n) = 39;
%     end 
% end
% % �����ʴ�1.023MHz--->39MHz
% CA_39MHz = [];
% for i=1:1023
%     CA_39MHz_buf = repmat(CAcode(i),1,Bu_pos(i));
%     CA_39MHz = [CA_39MHz,CA_39MHz_buf];
% end
% 
% CA_39MHz = [CA_39MHz(1:end-1),CA_39MHz(end-1)];
