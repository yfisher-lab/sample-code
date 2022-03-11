function [plotHandle] = raster(spikeTimes, tickHeight, spacerHeight, varargin)
%RASTER plots spike raster from a collection of spike times
%
%   INPUT
%       spikeTimes - cell array with each element containing spike times (in
%       seconds) from each different trials or cells
%
%       tickHeight - Height of raster tick mark
%
%       spacerHeight - vertical distance between tick marks
%
% Optional labelString - string label for each cell of the raster e.g. 'trial' or 'cell'
%
%
%   OUTPUT plotHandle
%
% Yvette Fisher 1/2021

if(nargin > 3)
    labelString = varargin{1};
else
    labelString = 'cell'; % default
end

% loop over spikeTime cell and plot tick marks at spike times
for i = 1:numel(spikeTimes)
    topOfTick = (tickHeight + spacerHeight)*(numel(spikeTimes) -i); % cell 1 will be at top of plot and then progress downward from there
    bottomOfTick = topOfTick - tickHeight;
    
    numSpikes = numel(spikeTimes{i});
    
    plotHandle = plot([spikeTimes{i};spikeTimes{i}], [topOfTick*ones(1,numSpikes); bottomOfTick*ones(1,numSpikes)],'k'); hold on
    
    % build y tick postion and labels
    middleOfTick(i) = topOfTick - tickHeight/2; 
    yRasterLabels{i} = [ labelString ' ' num2str(i)];
end

[accendingTicks, index] = sort(middleOfTick);
yticks(accendingTicks);
yticklabels(yRasterLabels(index)); % sort to match same accending order and so cell/trial 1 is at the top

xlabel('time(s)');
end

