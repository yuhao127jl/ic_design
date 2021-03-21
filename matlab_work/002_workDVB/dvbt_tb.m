clear all;

% Initialization
dump_open;
global_settings;
visualization_settings;
dvbt_send_init;
dvbt_receive_init;

% Import globals
global DUMP;
global DVBT_SETTINGS;

n = 188; %packet length
input_file = fopen (['.' '/5-superframes/1274p.ts'], 'r');

compare_queue = []; 
%used to compare if the received data the same as the send data

fprintf ('signal sendding & receiving');

while ~ feof (input_file) | ~ isempty (compare_queue)

  % Read a packet
  if ~ feof (input_file)
    % get an MPEG transport MUX packet into a row vector
    [data_in, count] = fread (input_file, n);
    fid = fopen(['.' '/dvbt.txt'], 'w');
    fprintf (fid, 'TB: reading block of length %d\n', count);
  else
    count = 0;
  end
  % zero pad packet if necessary
  if count == 0
    data_in = [ hex2dec('47') ; zeros(n-1,1) ];
  elseif count < n
    data_in = [ data_in ; zeros(n-count,1) ];
  end
  if count > 0
    % put packet into compare_queue
    if isempty (compare_queue)
      compare_queue = data_in;
    else
      compare_queue = [ compare_queue , data_in ];
    end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send a packet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data_channel_in = dvbt_send (data_in);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transmit a symbol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if ~ isempty (data_channel_in)
       fprintf ('.'); 
       data_channel_out = channel_model (data_channel_in); 
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Receive a packet  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if ~ isempty (data_channel_out)
        data_out = dvbt_receive (data_channel_out); 

      % Check received packet
      if ~ isempty (compare_queue) & ~ isempty (data_out)
        [should_be_n, packets_in] = size(compare_queue);
        [should_be_n, packets_out] = size(data_out);
      
        for k = 1:min(packets_in,packets_out)
          fprintf (fid, 'TB: comparing received packet\n');
          send_packet=compare_queue(:,k);
          receive_packet=data_out(:,k);
	      if all(all(send_packet == receive_packet))
	         fprintf (fid, 'TB: successfully transmitted');
          else
	         dump_close;
	         error ('transmission error');
           end

        end

        % Remove packets from compare queue
        if packets_out < packets_in
          compare_queue = compare_queue(:,packets_out+1:packets_in);
        else
          compare_queue = [];
        end
      end
    end
  end  
end
fprintf ('\n');

% Cleanup
fclose (input_file);
dump_close;
fprintf ('\nDVB-T works.\n');
