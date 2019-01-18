function signal = data_detrending(filtered_data)
clear textprogressbar
textprogressbar([newline 'Removing the linear trend from the data: '])
timecount = linspace(1,100,size(filtered_data,1));
% remove the linear trend from the re-referenced data
for channel = 1:size(filtered_data,1)
    textprogressbar(timecount(channel))
    signal(channel,:) = detrend(filtered_data(channel,:));
end
