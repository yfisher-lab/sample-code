function [persistenceArray] = persistenceOfHeadingBySample(var_heading_threshold, bar_position_array, sampleRate)
%Preprocessing the bar position/heading data by binning the position with
%slight change as a better estimation of prolonged heading position of fly
%     Input 1: var_heading_threshold
%          Threshold of variability in heading that can be manually determined depending on how much
%          variation in heading direction could be tolorated and be considered
%          as persistent heading direction 
%      
%     Input 2: bar_position_array
%          The bar_position array that have been corrected from frame shift
%
%      Input 3: sampleRate
%           the sample rate of the data set (typically ~20,000Hz for ephy
%           experiemnts)
%     
%     Output:persistenceArray
%          An array with the same length as bar_position_array where every
%          value tells you for that time point of the data set how many seconds the fly has been facing the same direction (within range of var_heading_threshold)
%
% Yvette Fisher 4/2022

persistenceArray = zeros(length(bar_position_array),1); % initiate values

for i = 2:length(bar_position_array)
    head_current = bar_position_array(i);

    previous_bar_postions = bar_position_array(1:i-1);
    absDiffFromCurrent = abs(previous_bar_postions - head_current); % absolute value of different from current heading

    aboveThresholdIndex = find(absDiffFromCurrent > var_heading_threshold);

    if(isempty(aboveThresholdIndex))
        persistenceArray(i) = (i-1) / sampleRate;

    else
        mostRecentAboveThreshold = max(aboveThresholdIndex);
        persistenceArray(i) = (i - mostRecentAboveThreshold) / sampleRate;
    end
end


end