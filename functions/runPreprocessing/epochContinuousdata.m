function [epochs, nE] = epochContinuousdata(raw_data,params)

fprintf('\n%s\n','---- Epoching continuous data ----')
disp([newline 'Creating  epochs of 10 minutes.'])

epochLms = 600000 ; % epoch length in ms, epochs of 10 minutes
epochLidx = round(epochLms / (1000/params.srate));
nE = floor(length(raw_data)/epochLidx); % N epochste));
nchans = size(raw_data,1);

epochs = reshape(raw_data(:,1:nE*epochLidx), ...
    [nchans epochLidx nE]);


disp([newline 'Epoching completed, ' num2str(nE) ' epochs were created.'])