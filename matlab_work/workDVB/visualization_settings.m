%% visualization_settings Settings for Visualization
%%
%%   visualization_settings() initializes constant values and parameters
%%   relevant to visualization into a global data structure
%%   named VISUALIZATION.


function visualization_settings ()

  global VISUALIZATION;
  
  %% Visualization
  VISUALIZATION = {};
  VISUALIZATION.figure = {};
  
  VISUALIZATION.signal = 1;
  VISUALIZATION.figure.signal = 1;

  VISUALIZATION.spectrum = 1;
  VISUALIZATION.figure.spectrum = 2;

  VISUALIZATION.spectrum2 = 1;
  VISUALIZATION.figure.spectrum2 = 3;
