function data_rereference(rejected_channels_index, filtered_data, P, hopID, recID, settings)
% Remove the linear trend from the data 


% Apply re-referencing (bipolar or CAR)
switch P.rereferecing_method
  
  case 'bipolar'
    
    
  case 'common_average'
    
end

% Save to the output path