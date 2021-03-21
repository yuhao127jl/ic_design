function dvbt_send_init ()

  %% Global declarations
  global DVBT_SETTINGS;
  global DVBT_STATE_SENDER;
  DVBT_STATE_SENDER = {};
  
  %% Frame structure
  DVBT_STATE_SENDER.u = 0;
  % Packet number within super-frame
  DVBT_STATE_SENDER.n = 0;  
  % Symbol number within frame, l = 1:68
  DVBT_STATE_SENDER.l = 0;
  % Frame number within super-frame, m = 1:4
  DVBT_STATE_SENDER.m = 0;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Part 1: MUX adaptation and randomization for energy dispersal
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  DVBT_STATE_SENDER.scrambler = {};
  % Contents of PRBS shift register  
  DVBT_STATE_SENDER.scrambler.prbs_register = ...
      DVBT_SETTINGS.scrambler.init_prbs_register; % initialiaze the PRBS register

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Part 3: Outer Interleaver
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  DVBT_STATE_SENDER.outer_interleaver = {};
      DVBT_STATE_SENDER.outer_interleaver.queue = zeros(12*204,1);

  % Bitstream losely coupling Reed/Solomon w. Viterbi
  DVBT_STATE_SENDER.bit_stream = [];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Part 4: Convolutional encoder
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  DVBT_STATE_SENDER.convolutional_code = ...
      DVBT_SETTINGS.convolutional_code.init_register;
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
 %% Part 5: Inner interleave
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 DVBT_STATE_SENDER.Inner_interleave = {};
  % compute permutation table H(q)
  Nmax = 1512;
  Mmax = 2048;
  Nr = log2(Mmax);  % 11
  DVBT_STATE_SENDER.inner_interleaver.Hq = zeros(Nmax,1);
  qq = 0;

  perm_table=[4 3 9 6 2 8 1 5 7 0]; % Bit permutations for the 2K mode
  for ii = 0:Mmax-1
    % compute Ri
    switch ii
      case 0
        r1 = zeros (1, Nr-1);
      case 1
        r1 = zeros (1, Nr-1);
      case 2
        r1 = zeros (1, Nr-1);
        r1(1) = 1;
      otherwise
        r1 = [r1(2:Nr-1) , xor(r1(1+0), r1(1+3))];
    end
    r = zeros(1, Nr-1);
    % Bit permutations: caculate Ri
    for k = 0:Nr-2
      r(1+perm_table(1+k)) = r1(1+k);
    end
    % compute H(q)
    DVBT_STATE_SENDER.inner_interleaver.Hq(1+qq) = mod (ii,2) * 2^(Nr-1);
    for jj = 0:Nr-2
    DVBT_STATE_SENDER.inner_interleaver.Hq(1+qq) = ...
    DVBT_STATE_SENDER.inner_interleaver.Hq(1+qq)+r(jj+1)*2^jj;
    end
    if DVBT_STATE_SENDER.inner_interleaver.Hq(1+qq) < Nmax
      qq = qq + 1;
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Part 6: Insert reference signal
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DVBT_STATE_SENDER.refsig.w = zeros(1,1705); %1*1705
    reg = ones(1,11); % initialize
      for k = 1:1705
        DVBT_STATE_SENDER.refsig.w(k) = reg(11);
        new_bit = xor (reg(9), reg(11));
        reg = [ new_bit reg(1:10) ];
      end % Generation of PRBS sequence
     
     % insert TPS reference signal
     set = [34 50 209 346 413 569 595 688 790 901 ...
                1073 1219 1262 1286 1469 1594 1687];
            %generate TPS signal
        s = zeros(1,53);
        if  DVBT_STATE_SENDER.m == 1|3
        s(1:16)= [0 0 1 1 0 1 0 1 1 1 1 0 1 1 1 0];
        else
         s(1:16)= [1 1 0 0 1 0 1 0 0 0 0 1 0 0 0 1]; 
        end
        s(17:22) = [0 0 0 0 0 0];
        s(23:24) = [1 1]; % Frame number 4 in the super-frame 
        s(25:26) = [0 1]; %16-QAM
        s(27:29) = [0 0 1];%¦Á = 1
        s(30:35) = [0 0 0 0 0 0]; %1/2 code rate for both HP&LP
        s(36:37) = [1 1]; %1/4 guard interval values
        s(38:39) = [0 0]; %2K mode
        s(40:47) = [0 0 0 0 0 0 0 0];
        s(48:53) = [0 0 0 0 0 0]; %Annex F

        genpoly = bchpoly(127, 113);
        add = zeros(1,60);
        msg = [s.';add.'];
        code = encode(msg,127,113,'bch/fmt',genpoly);
        DVBT_STATE_SENDER.tps_signal = code(1:67);
      
      
  

  
