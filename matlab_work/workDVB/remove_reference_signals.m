function data_out = remove_reference_signals (data_in)

  % Global declarations
  global DVBT_SETTINGS;
  global DVBT_STATE_RECEIVER;
  global VISUALIZATION;

  [n, should_be_one] = size (data_in);
  alpha = 1/sqrt(10);

  % Perform actions
  data_out = zeros(1512, 1);
  
  % create a set of pilots
  l=DVBT_STATE_RECEIVER.l;
  Kmin=0;
  Kmax=DVBT_SETTINGS.ofdm.carrier_count;
 continual_pilots = ...
      [ 0 48 54 87 141 156 192 201 255 279 282 333 432 450 ...
       483 525 531 618 636 714 759 765 780 804 873 888 918 ...
       939 942 969 984 1050 1101 1107 1110 1137 1140 1146 ...
       1206 1269 1323 1377 1491 1683 1704];
  pilot_set = union (continual_pilots, Kmin + 3*rem(l,4) + ...
		     12*(0:(DVBT_SETTINGS.ofdm.carrier_count-12)/12));

  % Insert TPS symbols
  tps_set = [34 50 209 346 413 569 595 688 790 901 ...
                1073 1219 1262 1286 1469 1594 1687];

  % separate data from pilots and TPS
  v=1; % current input payload carrier index
  pilot=1; % current pilot index in pilot_set
  tps=1; % current tps index in tps_set
  for u = 1:1705 % for all output carriers
    p = 1+pilot_set(pilot); % get next pilot
    if tps <= length(tps_set) % get next tps
      t = 1+tps_set(tps);
    else
      t = 0;
    end
    
    if u == p % it's a pilot signal
      pilot = pilot + 1;
    elseif u == t; % it's a TPS signal
      tps = tps + 1;
    else % it's a payload carrier
      data_out(v) = data_in(u) / alpha;
      v = v + 1;
    end
  end
  data_out = round(data_out);



