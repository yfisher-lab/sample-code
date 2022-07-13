% mean holding current

ephysSettings;
% plot voltage and holding current
if(isfield(data,'scaledCurrent'))
    current = data.scaledCurrent; % for voltage clamp traces
else
    current = data.current; % for current clamp traces
end
% build timeArray
timeArray = (1:length(current) ) / settings.sampRate; % seconds

ax(1) = subplot(2,1,1);
% plot current trace
plot(timeArray, current); hold on;

LOWPASSFILTERCUTOFF = 50;
filteredCurrent = lowPassFilter( current,  LOWPASSFILTERCUTOFF , settings.sampRate );
% plot filtered current trace
plot(timeArray, filteredCurrent)

ylim([-5, 5])

% calculate mean holding current for this trial but ignore first 3 seconds
% incase there was a pulse test
startSample = 3*settings.sampRate
meanCurrent = mean(current(startSample:end))
meanFilteredCurrent = mean(filteredCurrent(startSample:end))

% print this value into the title and command window
title(['mean holding current:' num2str(meanCurrent) 'pA, filteredMean: ' num2str(meanFilteredCurrent) 'pA']);


if(isfield(data,'scaledVoltage'))
    voltage = data.scaledVoltage; % for current clamp traces
else
    voltage = data.voltage; % for voltage clamp traces
end
% plot voltage trace
ax(2) = subplot(2,1,2);
plot( timeArray, voltage); hold on;
title('voltage'); xlabel('time(s)'); ylabel('mV');



