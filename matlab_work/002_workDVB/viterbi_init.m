%% rs_init Initialize Convolutional Encoder and Decoder.
%%
%%   viterbi_init () initializes a global data structure with the
%%   parameters of the convolutional encoder and decoder.
%%   This function is called by global_settings.


function viterbi_init ()

  global DVBT_SETTINGS;

  DVBT_SETTINGS.convolutional_code = {};
  DVBT_SETTINGS.convolutional_code.init_kammeyer = 0;
  DVBT_SETTINGS.convolutional_code.use_kammeyer = 0;
  %% memory length
  DVBT_SETTINGS.convolutional_code.m = 6;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Settings for Kammeyer Viterbi
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if DVBT_SETTINGS.convolutional_code.init_kammeyer
    DVBT_SETTINGS.convolutional_code.g = ...
	[1 1 1 1 0 0 1 ;
	 1 0 1 1 0 1 1];
    DVBT_SETTINGS.convolutional_code.trellis = ...
	make_trellis (DVBT_SETTINGS.convolutional_code.g, 0);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Settings for simple convolutional codec
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  DVBT_SETTINGS.convolutional_code.init_register = ...
      zeros(1,DVBT_SETTINGS.convolutional_code.m);
  %% generator polynomials
  DVBT_SETTINGS.convolutional_code.mother_x = [1 2 3 6];
  DVBT_SETTINGS.convolutional_code.mother_y = [2 3 5 6];
