%% dump_open Open all dump files.
%   dump_open() opens all dump files.

function dump_open ()

  % Global declarations
  global DUMP;
  DUMP = {};

  config;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % File dump
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % main files
  DUMP.main = fopen(['.' '/dvbt.txt'], 'w');
  DUMP.sender = fopen(['.' '/send.txt'], 'w');
  DUMP.receiver = fopen(['.' '/receive.txt'], 'w');
  DUMP.channel = fopen(['.' '/channel.dump'], 'w');
  % 1. Scrambler
  DUMP.scramble = fopen([DUMP.SETTINGS.test_dir '/scramble.dump'], 'w');
  DUMP.descramble = fopen([DUMP.SETTINGS.test_dir '/descramble.dump'], 'w');
  % 2. Reed-Solomon (rs)
  DUMP.rs_encode = fopen([DUMP.SETTINGS.test_dir '/rs_encode.dump'], 'w');
  DUMP.rs_decode = fopen([DUMP.SETTINGS.test_dir '/rs_decode.dump'], 'w');
  % 3. Outer interleaver
  DUMP.outer_interleave = fopen([DUMP.SETTINGS.test_dir '/outer_interleave.dump'], 'w');
  DUMP.outer_deinterleave = fopen([DUMP.SETTINGS.test_dir '/outer_deinterleave.dump'], 'w');
  % 4. Convolutional codec
  DUMP.convolutional_encode = fopen([DUMP.SETTINGS.test_dir '/convolutional_encode.dump'], 'w');
  DUMP.convolutional_decode = fopen([DUMP.SETTINGS.test_dir '/convolutional_decode.dump'], 'w');
  % 5. Puncturing
  DUMP.puncturing = fopen([DUMP.SETTINGS.test_dir '/puncturing.dump'], 'w');
  DUMP.depuncturing = fopen([DUMP.SETTINGS.test_dir '/depuncturing.dump'], 'w');
  % 6. Innner Interleaver
  DUMP.inner_interleave = fopen([DUMP.SETTINGS.test_dir '/inner_interleave.dump'], 'w');
  DUMP.inner_deinterleave = fopen([DUMP.SETTINGS.test_dir '/inner_deinterleave.dump'], 'w');
  % 7. Mapper
  DUMP.map = fopen([DUMP.SETTINGS.test_dir '/map.bin'], 'w');
  DUMP.demap = fopen([DUMP.SETTINGS.test_dir '/demap.dump'], 'w');
  % 8. Reference Signals
  DUMP.insert_reference_signals = fopen([DUMP.SETTINGS.test_dir '/insert_reference_signals.dump'], 'w');
  DUMP.remove_reference_signals = fopen([DUMP.SETTINGS.test_dir '/remove_reference_signals.dump'], 'w');
  % 9. OFDM codec
  DUMP.ofdm_encode = fopen([DUMP.SETTINGS.test_dir '/ofdm_encode.bin'], 'w');
  DUMP.ofdm_decode = fopen([DUMP.SETTINGS.test_dir '/ofdm_decode.dump'], 'w');
