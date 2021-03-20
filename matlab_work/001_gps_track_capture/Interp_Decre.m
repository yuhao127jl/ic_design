function CA_39MHz = Interp_Decre(CAcode,Freq_sample)
% 插值过程：采样率从1.023MHz--->39MHz
% 输入输出定义：CAcode为C/A码，码片为1023，Freq_sample为需要转化的采样速率，即
%              从1.023MHz转化到Freq_sample采样速率。
%              CA_39MHz输出采样速率为Freq_sample的C/A码。

format long g;
Freq_CA = 1.023e6;     % CA码的码片速率
detaT = 0.001;         % 采样数据的时间为1ms
Num = detaT*Freq_sample;% 1ms的采样点数39000
N = 1:Num;

CA_buf = repmat(CAcode,1,5);
sign = ceil( (N/Freq_sample+eps)*Freq_CA + eps);
CA_39MHz = CA_buf(sign);
CA_39MHz = [CA_39MHz(1),CA_39MHz(1:end-1)];



% 插值的效果不怎么好！！！！！！
% format long g;
% % Freq_sample = 39e6;  % 39MHz的采样速率
% Freq_CA = 1.023e6;        % CA码的码片速率
% ratio_val = Freq_sample/Freq_CA;% 速率转化比值
% decimal_ratio = ratio_val - floor(ratio_val); % 比值的小数部分
% val_num = floor(ratio_val);% 比值的整数部分
% % CAcode = CAcodegen(1,1023);
% 
% dec_sum = 0;
% Bu_val = Freq_sample/1000-1023*val_num;% 126
% Bu_pos = val_num*ones(1,1023);% 对补的39进行定位
% % 记录需要插39个的位置
% for n=1:1023
%     if(dec_sum<1)
%         dec_sum = dec_sum + decimal_ratio;
%     end
%     if(dec_sum>=1)
%         dec_sum = dec_sum - 1;
%         Bu_pos(n) = 39;
%     end 
% end
% % 采样率从1.023MHz--->39MHz
% CA_39MHz = [];
% for i=1:1023
%     CA_39MHz_buf = repmat(CAcode(i),1,Bu_pos(i));
%     CA_39MHz = [CA_39MHz,CA_39MHz_buf];
% end
% 
% CA_39MHz = [CA_39MHz(1:end-1),CA_39MHz(end-1)];
