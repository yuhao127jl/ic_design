%**************************************************************************
%
% NoiseAndCarrier.M
%
%**************************************************************************
f1=200;       %�ź�1Ƶ��Ϊ200Hz
f2=800;       %�ź�2Ƶ��Ϊ800Hz
Fs=2000;      %����Ƶ��Ϊ2KHz
N=14;         %����λ��
%Pn=Pn0*Fs/2; %�����źŹ���
%width=0.5;   %����SAWTOOTH()�ĳ߶Ȳ���Ϊ0.5
%duty=50;     %����SQUQRE()�ĳ߶Ȳ���Ϊ50
%�����ź�
t=0:1/Fs:1;
c1=2*pi*f1*t;
c2=2*pi*f2*t;
%sq=square(c,duty);%��������
%tr=sawtooth(c,width);%�������ǲ�
s1=sin(c1);%�������Ҳ�
s2=sin(c2);%�������Ҳ�
s=s1+s2;   %�����������ز��ϳɺ���ź�
%������������ź�
noise=randn(1,length(t));%������˹����������

%��һ������
noise=noise/max(abs(noise));
s=s/max(abs(s));

%14��������
Q_noise=round(noise*(2^(N-1)-1));
Q_s=round(s*(2^(N-1)-1));

%����������Ƶ��˲����������źŽ����˲�
% hn=E4_7_Fir8Serial;
% Filter_noise=filter(hn,1,Q_noise);
% Filter_s=filter(hn,1,Q_s);

%���źŵķ�Ƶ��Ӧ
m_noise=20*log(abs(fft(Q_noise,1024)))/log(10); 
m_noise=m_noise-max(m_noise);

m_s=20*log(abs(fft(Q_s,1024)))/log(10); 
m_s=m_s-max(m_s);

%�˲���ķ�Ƶ��Ӧ
% Fm_noise=20*log(abs(fft(Filter_noise,1024)))/log(10); 
% Fm_noise=Fm_noise-max(Fm_noise);
% Fm_s=20*log(abs(fft(Filter_s,1024)))/log(10); 
% Fm_s=Fm_s-max(Fm_s);

%�˲��������ķ�Ƶ��Ӧ
% m_hn=20*log(abs(fft(hn,1024)))/log(10); m_hn=m_hn-max(m_hn);

%���÷�Ƶ��Ӧ�ĺ����굥λΪHz
x_f=[0:(Fs/length(m_s)):Fs/2];

%ֻ��ʾ��Ƶ�ʲ��ֵķ�Ƶ��Ӧ
% mf_noise=m_noise(1:length(x_f));
% mf_s=m_s(1:length(x_f));
% Fmf_noise=Fm_noise(1:length(x_f));
% Fmf_s=Fm_s(1:length(x_f));
% Fm_hn=m_hn(1:length(x_f));

%���Ʒ�Ƶ��Ӧ����
% subplot(211)
% plot(x_f,mf_noise,'-.',x_f,Fmf_noise,'-',x_f,Fm_hn,'--');
% xlabel('Ƶ��(Hz)');ylabel('����(dB)');title('Matlab����������ź��˲�ǰ���Ƶ��');
% legend('�����ź�Ƶ��','����ź�Ƶ��','�˲�����Ӧ');
% grid;

% subplot(212)
% plot(x_f,mf_s,'-.',x_f,Fmf_s,'-',x_f,Fm_hn,'--');
% xlabel('Ƶ��(Hz)');ylabel('����(dB)');title('Matlab����ϳɵ�Ƶ�ź��˲�ǰ���Ƶ��');
% legend('�����ź�Ƶ��','����ź�Ƶ��','�˲�����Ӧ');
% grid;

%�����ɵ�������ʮ�������ݸ�ʽд��txt�ļ���
fid=fopen('Int_noise.txt','w');
fprintf(fid,'%8d\r\n',Q_noise);
fprintf(fid,';'); 
fclose(fid);

fid=fopen('Int_s.txt','w');
fprintf(fid,'%8d\r\n',Q_s);
fprintf(fid,';'); 
fclose(fid);

%�����ɵ������Զ��������ݸ�ʽд��txt�ļ���
fid=fopen('.\Bin_noise.txt','w');
for i=1:length(Q_noise)
    B_noise=dec2bin(Q_noise(i)+(Q_noise(i)<0)*2^N,N);
    for j=1:N
       if B_noise(j)=='1'
           tb=1;
       else
           tb=0;
       end
       fprintf(fid,'%d',tb);  
    end
    fprintf(fid,'\r\n');
end
fprintf(fid,';'); 
fclose(fid);


fid=fopen('.\Bin_s.txt','w');
for i=1:length(Q_s)
    B_s=dec2bin(Q_s(i)+(Q_s(i)<0)*2^N,N);
    for j=1:N
       if B_s(j)=='1'
           tb=1;
       else
           tb=0;
       end
       fprintf(fid,'%d',tb);  
    end
    fprintf(fid,'\r\n');
end
fprintf(fid,';'); 
fclose(fid);


