%%  conv_encoder.m : Faltunscodierer                                     

function [y,last_state,x_tail] = conv_encoder (x,g,r_flag,term)

[n,K]     = size(g);

x = x(:);
N_info = length(x);

if (K == 1)
  K = ceil(log2(max(g)));     
  g = de2bi(g,K);
end
m = K - 1;

if r_flag>0                                          % RSC-Code
  grek = g(r_flag,:);
  g(r_flag,:) = [];
end


% Initialize state-Vector
state = zeros(1,m);

% Initialize Tailbit-Vector
if (nargout==3)
  x_tail = zeros(m,1);
end

% Initialize Ausgangsvektoren
if term>0
  y = zeros((N_info+m)*n,1);
else
  y = zeros(N_info*n,1);
end


% Coding
for i = 1:N_info

  if (r_flag>0)
    a_k              = grek & [x(i) state];
    a_k              = rem( sum(a_k), 2);
    reg              = [a_k state];
    y((i-1)*n+1)     = x(i);                    % systematisches Infobit
    y((i-1)*n+2:i*n) = rem(g*reg',2);
  else
    reg              = [x(i) state];
    y((i-1)*n+1:i*n) = rem(g*reg',2);
  end
  state = reg(1:m);
end

if term>0                                         % Terminierter Faltungscode
  for i=N_info+1:N_info+m

    reg = [0 state];
    if (r_flag>0)
      feedback     = rem(sum(grek & reg), 2);
      y((i-1)*n+1) = feedback;
      if (nargout==3)
        x_tail(i-N_info) = feedback;
      end
      y((i-1)*n+2:i*n) = rem(g*reg',2);
    else
      y((i-1)*n+1:i*n) = rem(g*reg',2);
    end
    state = reg(1:m);

  end
end

if (nargout>=2)
  last_state = bi2de(state);
end