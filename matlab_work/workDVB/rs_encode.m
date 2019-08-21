%% rs_decode Reed/Somomon Encoder.
%%
%%   y = rs_decode(x) encodes a MPEG transport multiplex packet
%%   using the Reed/Solomon algorithm. x and y are column vectors
%%   of Galois field elements.


function data_out = rs_encode (data_in)

  % Global declarations
  global DUMP;
  global DVBT_SETTINGS;
  global DVBT_STATE_SENDER;
  global GF;

  % Abbreviations
  k = DVBT_SETTINGS.rs.k;
  n = DVBT_SETTINGS.rs.n;
  t = DVBT_SETTINGS.rs.t;
  

  % Perform actions
  parity=zeros(2*t,1);
  parity(:)=GF.zero;
  for index = 1:k
    feedback = gf_add (data_in(index), parity(1));

    parity = gf_add ([parity(2:2*t) ; 0], ...
		     gf_mul (feedback, DVBT_SETTINGS.rs.g(2*t:-1:1)));
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data_out = [ data_in ; parity ];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Debugging dump
  fprintf (DUMP.sender, '    rs_encode: parity = [');
  for p = 1:2*t
    fprintf (DUMP.sender, '%d', parity(p));
    if p < 2*t
      fprintf (DUMP.sender, '; ');
    end
  end
  fprintf (DUMP.sender, '];\n');

  % Data dump
  fwrite (DUMP.rs_encode, data_out, 'uchar');