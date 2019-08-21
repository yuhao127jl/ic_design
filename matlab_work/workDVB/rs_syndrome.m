%% rs_syndrome Reed/Somomon, Berlekamp/Massey Algorithm.
%%
%%   syndrome = rs_syndrome (data_in) computes the error syndrome
%%   of data_in. A zero syndrome means that the transmission was
%%   error free.


function syndrome = rs_syndrome (data_in);

  % Global declarations
  global DUMP;
  global DVBT_SETTINGS;
  global GF;

  % Abbreviations
  k = DVBT_SETTINGS.rs.k;
  n = DVBT_SETTINGS.rs.n;
  t = DVBT_SETTINGS.rs.t;
  
  % Parameter checking
  [should_be_n, should_be_one] = size (data_in);
  
    % Perform actions
  syndrome = gf_eval (data_in(n:-1:1), DVBT_SETTINGS.rs.r);
  
  % Debugging dump
  fprintf (DUMP.receiver, '      rs_syndrome: syndrome = [');
  for p = 1:2*t
    fprintf (DUMP.receiver, '%d', syndrome(p));
    if p < 2*t
      fprintf (DUMP.receiver, '; ');
    end
  end
  fprintf (DUMP.receiver, '];\n');
