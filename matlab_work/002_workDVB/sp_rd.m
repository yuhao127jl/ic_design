%generate random variables as the TS stream and random it for energy
%dispersal

function [a,b,c,d,e,f,g,h] = sp_rd

%generate 188byte MUX packet

%define 1 sync-word byte
    sync  =  [ 0,1,0,0,0,1,1,1 ];
    dsync = [ 1,0,1,1,1,0,0,0 ];
    
    a1 = randsrc(1,1516,[0,1]);
    a = cat(2,dsync,a1);
    b1 = randsrc(1,1516,[0,1]);
    b = cat(2,sync,b1);
    c1 = randsrc(1,1516,[0,1]);
    c = cat(2,sync,c1);
    d1 = randsrc(1,1516,[0,1]);
    d = cat(2,sync,d1);
    e1 = randsrc(1,1516,[0,1]);
    e = cat(2,sync,e1);
     f1 = randsrc(1,1516,[0,1]);
     f = cat(2,sync,f1);
    g1 = randsrc(1,1516,[0,1]);
    g = cat(2,sync,g1);
    h1 = randsrc(1,1516,[0,1]);
    h = cat(2,sync,h1);

%Transport multiplex adaptation and randomization for energy
%dispersal
    A(1, ;)=[1,0,1,0,1,0,1,0,1];
    C=[0,0,0,1,0,0,0,0,1];
       for j=2:m;
                A(j,1)=mod(C*A(j-1,:)',2);
                A(j,2:1)=A(j-1,1:0);
       end
     g=A(:,1);




    