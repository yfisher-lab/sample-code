function [ spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes_negative_dVdt(voltage, timeArray, dVdT_SPIKE_THRESHOLD, varargin)
%DETECTSPIKETIMES spike detection for whole cell current clamp recordings
%   This function analyzes the dV/dt of the inverted voltage trace from a current clamp
%   recordings.  The function will also plot the trace with spikes detected
%   marked
%
%         INPUTS
%           voltage - trace from recording
%           timeArray - timing of each sample in seconds
%           dVdT_SPIKE_THRESHOLD - thresold for detecting spikes in the
%           dVdt trace, aka dVdt values larger than this number will be
%           counted as spikes
%
% Optional INPUTS
%         varargin{1} - lowPassCutOff - cut off for low pass
%                     filering the dVdt trace before looking for peaks
%         varargin{2} - sampleRate, needed for lowpass filerering
%                     operation
%
%  OUTPUT  spikeRasterOut - logical array with 1 when spike onset occurs
%          spikeIndexOut - index values when the spike start time occured
%          spikeTimesOut - times (sec) when the spike start times occured
%
%    Yvette Fisher, 1/2021

if( nargin > 3)
  lowPassCutOff = varargin{1};
  sampleRate = varargin{2};
  % low pass filter the inverted voltage trace
  filteredVoltage = lowPassFilter( -1*voltage,  lowPassCutOff , sampleRate );
end
diffVoltage = diff( filteredVoltage );


% FIND PEAKS in diff of Voltage 
PEAK_WIDTH_REQUIRED = 0.0025*sampleRate; % 0.0025 s = 2.5 ms ~spike secondary event width required
DIST_BETWEEN_PEAKS = 0.002*sampleRate; %0.002 s = 2 ms refreactory period


%[~ , spikeIndex] = findpeaks( diffVoltage, 'MinPeakHeight', dVdT_SPIKE_THRESHOLD, 'MinPeakWidth', WIDTHS_REQUIRED);
[~ , spikeIndex] = findpeaks( diffVoltage, ...
    'MinPeakHeight', dVdT_SPIKE_THRESHOLD, 'MinPeakWidth', PEAK_WIDTH_REQUIRED, 'MinPeakDistance', DIST_BETWEEN_PEAKS);

% Plot the voltage data, and detected spikes
figure('Position',[50, 50, 800, 400]);
set(gcf, 'Color', 'w');


ax(1) = subplot(2, 1 ,1);
plot( timeArray,  voltage ); hold on; box off
scatter( timeArray(spikeIndex),  voltage(spikeIndex) ); 
xlabel('seconds');
ylabel('membrane voltage (mV)');

ax(2) = subplot(2, 1, 2);
plot( timeArray(1:end-1), diffVoltage ); hold on; box off
scatter( timeArray(spikeIndex) , diffVoltage(spikeIndex) );
xlabel('seconds');
ylabel('-1* dV/dt (mV)');

linkaxes(ax,'x');

title( ['dVdt threshold: ' num2str( dVdT_SPIKE_THRESHOLD ) ]);
%output variables
spikeIndexOut = spikeIndex;
spikeTimesOut = timeArray(spikeIndex);

spikeRasterOut = zeros(1, length(timeArray));
spikeRasterOut( spikeIndex ) = 1; % put ones when the spikes occured

end

