% code to load in data that is cleaner...

ephysSettings;

TOTAL_DEGREES_IN_PATTERN = 360;
DEGREE_PER_LED_SLOT = 360 / 96;  % 
MIDLINE_POSITION = 34;%
EDGE_OF_SCREEN_POSITION = 72; % last LED slot in postion units
EDGE_OF_SCREEN_DEG = (EDGE_OF_SCREEN_POSITION -  MIDLINE_POSITION ) * DEGREE_PER_LED_SLOT;

POSSIBLE_BAR_LOCATIONS = 2:2:71;
barPositionDegreesFromMidline = ( POSSIBLE_BAR_LOCATIONS - MIDLINE_POSITION ) * DEGREE_PER_LED_SLOT;

 MINBARPOS = 1;
 MAXBARPOS = 72;


patternOffsetPosition = decodePatternOffset( stimulus.panelParams.patternNum );
    
xBarPostion =  data.xPanelPos + patternOffsetPosition;
xBarPostion = mod( xBarPostion , MAXBARPOS );
    
barPositionDegreesVsMidline = (  xBarPostion - MIDLINE_POSITION) * DEGREE_PER_LED_SLOT;

plot(barPositionDegreesVsMidline);

%Binning the head/bar direction to somewhat a step function as an
%estimation of prolonged persisitent head direction

%binned_size = 4;
%[binned_head_barDirection, diff_index, diff_heading_pairwise] = binning_heading(barPositionDegreesVsMidline, binned_size);


% important ones barPositionDegreesVsMidline, scaledVoltage and timeArray

%%
lowPassCutOff = 90; % hz
timeArray_sec = (1:length(data.scaledVoltage))/settings.sampRate;

[ spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes(data.scaledVoltage, timeArray_sec, 0.04, lowPassCutOff, settings.sampRate);

%%
% calculate spike rate (spikes/s)
% Convert spike times into a smoothed spike rate
binWidthSec = 1; % sec
binsEdges = 0 : binWidthSec : timeArray_sec(end) ;
binsCenters = binsEdges(1 : end - 1) + ( binWidthSec / 2);
% find counts of spikes in each bin
n = histcounts ( spikeTimesOut , binsEdges  );

% normalized by bin width (seconds)
spikesPerSecond = n / (  binWidthSec );

interpolSpikeRate = interp1( binsCenters, spikesPerSecond, timeArray_sec );

%


% down sample spikeRate and heading information:
DOWN_SAMPLE_RATE = 100; % Hz  % WARNING don't run on higher than 500Hz unless you have lots of time to wait ;)
downSampleFactor = settings.sampRate / DOWN_SAMPLE_RATE;

spikeRate_lowSample = downsample(interpolSpikeRate, downSampleFactor);
barPosition_lowSample = downsample(barPositionDegreesVsMidline, downSampleFactor);
timeArray_lowSample = (1:length(barPosition_lowSample)) / DOWN_SAMPLE_RATE;

% plot to check that signals still look the same
figure;
subplot(2,1,1);
plot(timeArray_sec, interpolSpikeRate)

subplot(2,1,2)
plot(timeArray_lowSample, spikeRate_lowSample);
xlabel('sec')

figure;
subplot(2,1,1);
plot(timeArray_sec, barPositionDegreesVsMidline)

subplot(2,1,2)
plot(timeArray_lowSample, barPosition_lowSample);
xlabel('sec')



%%
%Binning the head/bar direction to somewhat a step function as an
%estimation of prolonged persisitent head direction

%Range of variability that could be tolorated as persistent
var_heading_threshold = 5;

[persistenceArray] = persistenceOfHeadingBySample(var_heading_threshold,barPosition_lowSample, DOWN_SAMPLE_RATE);


% plot to check that persistentArray looks correct
figure;
subplot(2,1,1);
plot(timeArray_lowSample, barPosition_lowSample);
ylabel('heading (deg)')


subplot(2,1,2);
plot(timeArray_lowSample, persistenceArray);
ylabel('heading persistence (s)')
xlabel('sec')


