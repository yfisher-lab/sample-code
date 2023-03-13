% plotting Spike persistence analysis
% Yvette Fisher March 2023
%{
The matrices we are interested in are Heatmap_spike/voltage_mean/value. 
For spikes there are different versions of it depending on how you smooth 
the spike raster trial. The initial one I did is just spike_mean/value,
 which is smoothed with gaussian windows. Rests are exponentially smoothed,
 and the time constant is indicated from the name.

The matrix will be in nx9 form, where n is the time bin bounded by the 
longest persistence trial and 9 are just 9 angle bins, 30 degrees each.
%}
%% Open file of the fly you want to analyze from tianhao's data set
[fileName, pathname] = uigetfile(); % prompt users in a gui to navegate to the file we want to analyize
cd(pathname)
load(fileName);

%% Build variables for plotting 
% Parameters for plotting 
DURATION_LIMIT_Sec = 15; % the longest persistent data to include in the heatmap

% Load in which spike means to plot (smoothing options, gaussian or expentiail) 
meanSpikeMatrix = persistentHM.Heatmap_spike_mean_250ms_exp;

spikeValuesCellArray = persistentHM.Heatmap_spike_value_250ms_exp;

spikeValuesTransient = spikeValuesCellArray(1,:); % first second


%% Plot spike rate heat map
figure('Position',[50, 50, 800, 500]);
set(gcf, 'Color', 'w');

matrixToPlot = meanSpikeMatrix(1:DURATION_LIMIT_Sec,:); % clips values past duration limit

imagesc( matrixToPlot ,'AlphaData', ~isnan(matrixToPlot) ); hold on;
set(gca,'color',0*[1 1 1]); 

c = colorbar; % color scale bar
c.Label.String = 'mean spike rate (Hz)';

% approximate angles for X tick labels
xLabelsAngleDegs = 0:persistentHM.heading_bin_size:persistentHM.heading_bin_size*length(matrixToPlot(1,:))*persistentHM.heading_bin_size; 
set(gca, 'xticklabel', xLabelsAngleDegs )
xlabel('Relative pattern position (deg)')
ylabel('Duration fly spent at this angle (sec)')

title(["Mean spike rate " fileName]);
niceaxes

%% Plot distrubtion of spikes rates in first (transient) bin
figure('Position',[50, 50, 1800, 500])
set(gcf, 'Color', 'w');

for i= 1:length(spikeValuesTransient)
    subplot(1,length(spikeValuesTransient),i);

    histogram(spikeValuesTransient{i},'Normalization','pdf');
end



%% look at the Std of the spike rates.... and also occupancy...




%% Plot Vm 