function   firstSubFrame = BitFrame_SyncParity(Track,msToProcess)
%             ���������ٺ��λͬ������֡ͬ������żУ�����
% �� �룺
%       Track�����ٺ�����Ǻ�PRN�뵼�����ı���������Ip
%       msToProcess�����ٴ������ݵ�ʱ�䣨ms��
% �� ����
%       firstSubFrame��֡ͬ����λͬ�������֡ͷ��λ��
%       SV_PRN���޳���������ͨ��������Ǻ�

% load('trackingResults.mat');% �����õ�����

Num_Acq = size(Track,2);
pos = ones(Num_Acq,1);
% �жϵ��������Ƿ���36s�����ݣ���֤�ܹ����������������������ٵ��������Ƿ����㶨λҪ��
if (msToProcess < 36000) || (Num_Acq < 4)
    disp('�ɼ�����Ƶ����̫�� �� �ܸ��ٵ�������̫���޷����ж�λ. �˳�������');
%     navSolutions = [];
%     eph          = [];
    return
end

for k=1:Num_Acq
    Ip(k,:) = Track(k).Ip;
    SV_PRN(k,1) = Track(k).PRN;
end

% ��֡��ͬ���ֽ�
preamble_bits = [1 -1 -1 -1 1 -1 1 1];% ͬ���ֽ�
preamble_ms = kron(preamble_bits, ones(1, 20));% ��msΪ��λ���Ӷ��ܹ�ͬ��������λ
firstSubFrame = zeros(1,Num_Acq);

for k=1:Num_Acq
    bits = Ip(k,:);
    % ��ֵ���������ת��Ϊ-1��+1
    bits(bits > 0)  =  1;
    bits(bits <= 0) = -1;

    % ��ͬ���ֽ������
    XcorrResult = xcorr(bits, preamble_ms);
    xcorrLength = (length(XcorrResult) +  1) /2;

    % �ҵ���֡ͬ���Ŀ�ʼ�ط�����ȷ������λ
    clear index
    clear index_frame
    index = find(abs(XcorrResult(xcorrLength : xcorrLength * 2 - 1)) > 153)';

    for i = 1:size(index)
        index_frame = index - index(i);
        if (~isempty(find( index_frame == 6000 )))
            %--------------- ���¶�ȡǰ��λ��ֵ������֤ ----------------%
            % ͨ��У���һ����֡��ǰ����������֤�������ĵ���ȷ�ԡ����ڼٶ���֪
            % ��ı߽磬������Ҫ��ȡ62ms�ı��أ�
            % 1. ��֡ǰ��2������������żУ�飻
            % 2. ��֡�е�ǰ2���֣�ң����-TLW�ͽ�����-HOW���ܹ�60ms����
            bits = Ip(k,index(i)-40:index(i)+20*60-1)';
            % ����ÿ��λ��20��ֵ
            bits = reshape(bits, 20, (size(bits, 1) / 20));
            bits = sum(bits);
            % ��ֵ���������ת��Ϊ- 1��+ 1
            bits(bits > 0)  =  1;
            bits(bits <= 0) = -1;
            % ��żУ��
            if(navPartyCheck(bits(1:32)) ~=0 && navPartyCheck(bits(31:62)) ~=0)
                firstSubFrame(1,k) = index(i);
                break;
            end
        end
    end

    if(firstSubFrame==0)
        % ���û���ҵ���֡ͷ��������������Ǽ��޳��������
        SV_PRN = setdiff(SV_PRN, SV_PRN(k,1));
        pos(k,1) = 0;
        disp(['�޷��ҵ�ͨ�������ǣ�',num2str(SV_PRN(k,1)),'����֡ͷ!']);        
    end
end

% �޳��Ҳ�����֡ͷ�����ǵĵ�����������
sig = 1;
for k=1:Num_Acq
    if(pos(k,1)==1)
        TrackResults(sig).Ip = Track(k).Ip;
        TrackResults(sig).PRN = Track(k).PRN;
        sig = sig + 1;
    end  
end