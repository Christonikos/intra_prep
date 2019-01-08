function [data]=car(data)
%this function calculates and returns the common avg reference of 2-d matrix "data".
%kjm 12/07
% Modified by Christos-Nikolaos Zacharopoulos to treat channels with NaNs
% (rejected in previous stages)

data=double(data);

transflag=0;
if size(data,1)<size(data,2)
    data=data';
    transflag=1;
end

num_chans = size(data,2);

% loop thorugh the data and empty the NaNs
for chanID = 1:num_chans
    if any(isnan(data(:,chanID)))
        data(:,chanID) = 0;
   end
end




% create a CAR spatial filter
spatfiltmatrix=[];
spatfiltmatrix=-ones(num_chans);
for i = 1:num_chans
    spatfiltmatrix(i, i) = num_chans-1;
end
spatfiltmatrix = spatfiltmatrix/num_chans;

% perform spatial filtering
if (isempty(spatfiltmatrix) ~= 1)
   fprintf(1, 'Performing Spatial filtering\n');
   
   data = data*spatfiltmatrix;
   
   if (size(data, 2) ~= size(spatfiltmatrix, 1))
      fprintf(1, 'The first dimension in the spatial filter matrix has to equal the second dimension in the data');
   end
end

if transflag==1, data=data'; end



