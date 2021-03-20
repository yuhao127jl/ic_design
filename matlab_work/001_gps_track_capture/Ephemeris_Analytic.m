function   [ephemeris,activeChnList,TOW] = Ephemeris_Analytic(Track,SV_PRN,firstSubFrame,msToProcess)
%             ������λͬ������֡ͬ������żУ�������������ȡ
% �� �룺
%       Track��λͬ������֡ͬ������żУ��ĵ����Ǻ�PRN�뵼�����ı���������Ip
%       firstSubFrame����֡ͷ��ʼ��λ��
%       msToProcess�����ٴ������ݵ�ʱ�䣨ms��
% �� ����
%       ephemeris����ȡ����������
%       TOW��GPS�źŵķ���ʱ��

% load('trackingResults.mat');% �����õ�����
% msToProcess = 37000;
Num_Acq = size(Track,2);
activeChnList = SV_PRN;
gpsPi = 3.1415926535898;  % pi�Ķ���
TiChu_PRN = [];
% for k=1:Num_Acq
%     Track(k).Ip = trackResults(k).I_P;
%     Track(k).PRN = trackResults(k).PRN;
% end

% ���ٺ��λͬ������֡ͬ������żУ�����
% [firstSubFrame,SV_PRN] = BitFrame_SyncParity(Track,msToProcess);

% �жϵ��������Ƿ���36s�����ݣ���֤�ܹ����������������������ٵ��������Ƿ����㶨λҪ��
if (msToProcess < 36000) || (Num_Acq < 4)
    disp('�ɼ�����Ƶ����̫�� �� �ܸ��ٵ�������̫���޷����ж�λ. �˳�������');
    ephemeris = [];
    TOW = [];
    return
end

for k=1:Num_Acq
    % ����֡ͷ��ʼ��ȡ5����֡���ݣ�һ֡��
    NavBits = Track(k).Ip(firstSubFrame(k) - 20 : firstSubFrame(k) + (1500 * 20) -1)';
    NavBits = reshape(NavBits, 20, (size(NavBits, 1) / 20));
    navBits_Best = sum(NavBits);% �ۼӺ�õ��ϺõĹ���ֵ
    
    % ӳ���0/1ֵ��navBits_Best>0--->1;navBits_Best<=0--->0;
    navBits_Best = (navBits_Best > 0);
    navBitsBin = dec2bin(navBits_Best);  %��ʮ����ת��Ϊ�����ƣ��ַ�char���ͣ�
    
    %% �����������ģ��õ���������
    bits = navBitsBin(2:1501)';
    D30Star = navBitsBin(1);   % ��һ֡���ݵ����һ������   
    for i = 1:5
        % ��֡���ݲ�ֳ�5����֡
        subframe = bits(300*(i-1)+1 : 300*i);

        % ��������10���ֵļ���
        for j = 1:10
            word = subframe(30*(j-1)+1 : 30*j);  % ��֡�е�ÿһ����
            if D30Star == '1'
                % ���ݱ��ط�ת
                data = word(1:24);
                dataLength = length(data);
                temp(1:dataLength) = '1';               
                invertMask = bin2dec(char(temp));                
                word(1:24) = dec2bin(bitxor(bin2dec(data), invertMask), dataLength);  % ��24�����ݰ�λȡ��
            end
            subframe(30*(j-1)+1 : 30*j) = word;           
            D30Star = subframe(30*j);
        end

        % ��ȡ��֡��
        subframeID = bin2dec(subframe(50:52));

        % ����������֡�е���������
        switch subframeID
            case 1  % ��1��֡
                ephemeris(k).weekNumber  = bin2dec(subframe(61:70)) + 1024;
                ephemeris(k).accuracy    = bin2dec(subframe(73:76));
                ephemeris(k).health      = bin2dec(subframe(77:82));
                ephemeris(k).T_GD        = BuMa2Dec(subframe(197:204)) * 2^(-31);
                ephemeris(k).IODC        = bin2dec([subframe(83:84) subframe(211:218)]);
                ephemeris(k).t_oc        = bin2dec(subframe(219:234)) * 2^4;
                ephemeris(k).a_f2        = BuMa2Dec(subframe(241:248)) * 2^(-55);
                ephemeris(k).a_f1        = BuMa2Dec(subframe(249:264)) * 2^(-43);
                ephemeris(k).a_f0        = BuMa2Dec(subframe(271:292)) * 2^(-31);
            case 2  % ��2��֡
                % It contains first part of ephemeris parameters
                ephemeris(k).IODE_sf2    = bin2dec(subframe(61:68));
                ephemeris(k).C_rs        = BuMa2Dec(subframe(69: 84)) * 2^(-5);
                ephemeris(k).deltan      = BuMa2Dec(subframe(91:106)) * 2^(-43) * gpsPi;
                ephemeris(k).M_0         = BuMa2Dec([subframe(107:114) subframe(121:144)]) * 2^(-31) * gpsPi;
                ephemeris(k).C_uc        = BuMa2Dec(subframe(151:166)) * 2^(-29);
                ephemeris(k).e           = bin2dec([subframe(167:174) subframe(181:204)]) * 2^(-33);
                ephemeris(k).C_us        = BuMa2Dec(subframe(211:226)) * 2^(-29);
                ephemeris(k).sqrtA       = bin2dec([subframe(227:234) subframe(241:264)]) * 2^(-19);
                ephemeris(k).t_oe        = bin2dec(subframe(271:286)) * 2^4;
            case 3  % ��3��֡
                ephemeris(k).C_ic        = BuMa2Dec(subframe(61:76)) * 2^(-29);
                ephemeris(k).omega_0     = BuMa2Dec([subframe(77:84) subframe(91:114)]) * 2^(-31) * gpsPi;
                ephemeris(k).C_is        = BuMa2Dec(subframe(121:136)) * 2^(-29);
                ephemeris(k).i_0         = BuMa2Dec([subframe(137:144) subframe(151:174)]) * 2^(-31) * gpsPi;
                ephemeris(k).C_rc        = BuMa2Dec(subframe(181:196)) * 2^(-5);
                ephemeris(k).omega       = BuMa2Dec([subframe(197:204) subframe(211:234)]) * 2^(-31) * gpsPi;
                ephemeris(k).omegaDot    = BuMa2Dec(subframe(241:264)) * 2^(-43) * gpsPi;
                ephemeris(k).IODE_sf3    = bin2dec(subframe(271:278));
                ephemeris(k).iDot        = BuMa2Dec(subframe(279:292)) * 2^(-43) * gpsPi;
            case 4  % ��4��֡
                % Almanac, ionospheric model, UTC parameters.
                % SV health (PRN: 25-32).
                % Not decoded at the moment.
            case 5  % ��5��֡
                % SV almanac and health (PRN: 1-24).
                % Almanac reference week number and time.
                % Not decoded at the moment.
        end % switch subframeID 
    end % for i = 1:5 
    
    if ( isempty(ephemeris(k).IODC) || isempty(ephemeris(k).IODE_sf2) || isempty(ephemeris(k).IODE_sf3) )
        % �޳�����IODC��IODE������
        activeChnList = setdiff(SV_PRN, Track(k).PRN);
        TiChu_PRN = [TiChu_PRN; Track(k).PRN];
    end    
    
    % ���������е�һ����֡�������룺��֡�����һ����֡��Ӧ������ʱ��ȥ30s������GPS���ݷ����ʱ��
    TOW(k) = bin2dec(subframe(31:47)) * 6 - 30;
end

