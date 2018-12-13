function channel = returnchannel(~,event)
% This is a callback function used to return the deviant
% channels from the powerspectrum plot. 
dts = get(event.Target,'Tag');
channel = {dts};
% Christos
