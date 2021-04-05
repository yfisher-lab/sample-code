function [ spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes( voltage , timeArray , peakHeightThreshold )
%DETECTSPIKETIMES spike detection for whole cell current clamp recordings
%   This function analyzes the voltage trace from a current clamp
%   recordings.  The function will also plot the trace with spikes detected
%   marked
%
%  OUTPUT  spikeRasterOut - logical array with 1 when spike onset occurs
%          spikeIndexOut - index values when the spike start time occured
%          spikeTimesOut - times (sec) when the spike start times occured
%
%    Yvette Fisher, MBL, 7/2018

%%  Spike detection testing scripts:


% FIND PEAKS in diff of Voltage 
WIDTHS_REQUIRED = 10;

diffVoltage = diff( voltage );

lowPassCutOff = 10000;
sampleRate = 33333;
%low pass filter the diff trace
diffVoltage = lowPassFilter( diffVoltage,  lowPassCutOff , sampleRate );

[~ , spikeIndex] = findpeaks( diffVoltage, 'MinPeakHeight', peakHeightThreshold, 'MinPeakWidth',WIDTHS_REQUIRED);

% Plot the voltage data, and detected spikes
figure('Position',[50, 50, 800, 400]);
set(gcf, 'Color', 'w');


subplot(2, 1 ,1);
plot( timeArray,  voltage ); hold on; box off
scatter( timeArray(spikeIndex),  voltage(spikeIndex) ); 
xlabel('seconds');
ylabel('membrane voltage (mV)');

subplot(2, 1, 2)
plot( timeArray(1:end-1), diffVoltage ); hold on; box off
scatter( timeArray(spikeIndex) , diffVoltage(spikeIndex) );
xlabel('seconds');
ylabel('derivative of membrane voltage (mV)');

title( ['dVdt threshold: ' num2str( peakHeightThreshold ) ]);
%output variables
spikeIndexOut = spikeIndex;
spikeTimesOut = timeArray(spikeIndex);

spikeRasterOut = zeros(1, length(timeArray));
spikeRasterOut( spikeIndex ) = 1; % put ones when the spikes occured

end

