function data_out = insert_reference_signals (data_in)

  %declarations
  global DVBT_STATE_SENDER;
  global DVBT_SETTINGS;
  n = 1512;
  data_out = zeros(1705, 1);
  alpha = 1/sqrt(10);

  % create a set of pilots
  Kmin=0;
  Kmax=1705;
 continual_pilots = ...
      [ 0 48 54 87 141 156 192 201 255 279 282 333 432 450 ...
       483 525 531 618 636 714 759 765 780 804 873 888 918 ...
       939 942 969 984 1050 1101 1107 1110 1137 1140 1146 ...
       1206 1269 1323 1377 1491 1683 1704];
  pilot_set = union (continual_pilots, Kmin + 3*rem(DVBT_STATE_SENDER.l,4) + ...
		     12*(0:(DVBT_SETTINGS.ofdm.carrier_count-12)/12));

  % Insert TPS symbols
  tps_set = [34 50 209 346 413 569 595 688 790 901 ...
                1073 1219 1262 1286 1469 1594 1687];

  % merge data and pilots
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
      data_out(u) = 4/3 * 2 * (0.5 - DVBT_STATE_SENDER.refsig.w(p));
      pilot = pilot + 1;
    elseif u == t; % it's a TPS signal
       if   DVBT_STATE_SENDER.l == 0;   % it's a TPS signal initial S0
        data_out(u) = 2 * (0.5 - DVBT_STATE_SENDER.refsig.w(p));
        else
        data_out(u) = DVBT_STATE_SENDER.tps_signal(DVBT_STATE_SENDER.l);
       end
         tps = tps + 1;
    else % it's a payload carrier
      data_out(u) = alpha * data_in(v);
      v = v + 1;
    end
  end