
%****************************************************************************
% Module        : DDS sine and cosine generator
% Description   : phase resolution 2pi/(2^10), bitwidth = 16
% Date          : 2021-05-12
%****************************************************************************
N = 10;                       % phase bit width
phase = 2^N;                  % phase num    2*pi

x = linspace(0, 6.28, 1024);  % phase resolution 
y_sin = sin(x);
y_cos = cos(x);

% quantification by 16bits
wth = 16;
y_sin = y_sin * 32678;
y_cos = y_cos * 32678;

% write into file
fid = fopen('dds_sin.txt', 'wt');
fprintf(fid, '%10.0f\n', y_sin);
fclose(fid);

fid = fopen('dds_cos.txt', 'wt');
fprintf(fid, '%10.0f\n', y_cos);
fclose(fid);

fid = fopen('dds_sin_bin.txt', 'wt');
for i=1:length(y_sin)
    tmp = dec2bin(y_sin(i)+(y_sin(i)<0)*2^wth, wth);
    for j=1:wth
        if tmp(j) == '1'
            tb = 1;
        else
            tb = 0;
        end
        fprintf(fid, '%d', tb);
    end
    fprintf(fid, '\r\n');
end
fclose(fid);

fid = fopen('dds_cos_bin.txt', 'wt');
for i=1:length(y_cos)
    tmp = dec2bin(y_cos(i)+(y_cos(i)<0)*2^wth, wth);
    for j=1:wth
        if tmp(j) == '1'
            tb = 1;
        else
            tb = 0;
        end
        fprintf(fid, '%d', tb);
    end
    fprintf(fid, '\r\n');
end
fclose(fid);


