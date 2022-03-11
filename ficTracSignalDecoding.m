function [ velocityOut , accumulatedPositionOut ] = ficTracSignalDecoding( ficTracBallPosition , sampleRate , lowPassFilterCutOff, maxFlyVelocity)
%FICTRACSIGNALDECODING takes a fictrac position value and extracts ball velocity 
%  This function will take a FicTrac output signal as aquired by the DAQ
%  as an analog signal and solve for the ball's angular velocity in the given 
%  dimention. To do this the signal is then UNWRAPPED to handle the abrupt
%  transitions caused by when the ball rotates completely and the signal
%  resets (0->10 volts or 10 volts -> 0) transistions.  Then the signal will be
%  further CLEANED to remove extra position values surrounding those signal
%  reset time points. Then the position signal is LOW PASS FILTERED two/mulitiple(?) times!! to
%  remove noise/ 50Hz sampling of fictrac. Then the velocity of the ball with be solved for in
%  degree/s by using the gradient function, and taking into consideration the  
%  sample rate the data was collected at. Velocity values above what a
%  resonable fly would turn the ball at (maxFlyVelocity) are discarded
%  
%   INPUTS
%   ficTracBallPosition  - array containing data from 0-10 volts relating
%   to the balls position
%
%   sampleRate - Rate the data was aquired at ( samples/ second )
%   
%   lowPassFilterCutOff - frequency that the position signal will be low
%   pass filtered at (Hz)
%
%   maxFlyVelocity - max value of realistic fly movement (deg/s) 
%
%   OUTPUT
%   velocityOut -array containing ball's instentanous velocity (degree/sec)
%   accumulatedPositionOut - array containing the filtered and unwraped
%   position signal in degrees
%
%   Yvette Fisher 1/2018
% ------------------------------
FICTRAC_MAX_VOLTAGE = 10;  % volts

% transfrom ficTrac signal into radians  
posRadians = ficTracBallPosition .* 2 .* pi ./ FICTRAC_MAX_VOLTAGE; 

% upwrap position signal
unwrappedPos = unwrap( posRadians );

% find indexes where the unwrapping happened (tolerace = pi)
upwrappedIndexes = find ( abs( diff( posRadians )) > pi); 

NUM_SAMPLES_FROM_WRAP_TO_REPLACE = 2;
% handle edge case so we don't fill off the edge of the trace
upwrappedIndexes = upwrappedIndexes( upwrappedIndexes > NUM_SAMPLES_FROM_WRAP_TO_REPLACE & upwrappedIndexes < (length ( unwrappedPos ) - NUM_SAMPLES_FROM_WRAP_TO_REPLACE) ); 

cleanedPos = unwrappedPos;
% replace potentially problematic indexes with Nan
for i = 1: length ( upwrappedIndexes )
    index_start = upwrappedIndexes(i) -  NUM_SAMPLES_FROM_WRAP_TO_REPLACE ; 
    index_end = upwrappedIndexes(i) +  NUM_SAMPLES_FROM_WRAP_TO_REPLACE ; 
    
    cleanedPos( index_start : index_end ) = NaN;
end

% replace NaN values with the last preceding value that was a real number
nanIDX = find( isnan( cleanedPos ) ); % find NaN indexes
% replace with preceeding value
while( ~isempty( nanIDX ) )
    cleanedPos(nanIDX) = cleanedPos(nanIDX - 1);
    
    % find any remaining NaN
    nanIDX  = find( isnan(cleanedPos) );
end

 
%% LOW PASS FILTER the signal
% low pass filter the position array
 filteredPosition = lowPassFilter( cleanedPos, lowPassFilterCutOff, sampleRate );

%  NUMBER_OF_FILTER_ROUNDS = 10;
%  % filter 9 more times:
%  for i = 1 : NUMBER_OF_FILTER_ROUNDS - 1
%       % low pass filter the position array again to be more aggressize
%  filteredPosition = lowPassFilter( filteredPosition, lowPassFilterCutOff, sampleRate );
%  end
 
% plotting to check how well unwrapping, cleaning and filtering worked
% can be commented out once you are happy with the parameters

figure('Position',[50, 50, 1000, 400]);  set(gcf, 'Color', 'w');
ax(1) = subplot(4, 1, 1);
plot(posRadians,  'DisplayName', 'postion (rad)'  ); hold on; legend('show');
ylabel ('rad');
ax(2) = subplot (4, 1, 2);
plot(unwrappedPos, 'DisplayName', 'unwrappedPos' ); hold on; legend('show');
ax(3) = subplot (4, 1, 3);
plot(cleanedPos, 'DisplayName', 'cleanedPos' ); hold on; legend('show');
ax(4) = subplot (4, 1, 4);
plot(filteredPosition, 'DisplayName', 'filteredPosition' ); hold on; legend('show')
linkaxes(ax,'x');
legend('show')


% transform from radians into degrees, send to user
accumulatedPositionOut = ( filteredPosition / (2*pi) ) * 360;

% take derivative and ajust for sample rate to solve for deg/s
%velocityOut = diff( accumulatedPositionOut ) .* sampleRate ; % degees / sec
velocityOut = gradient( accumulatedPositionOut ) .* sampleRate ; % degees / sec

%low pass filter the velocity signal
velocityOut = lowPassFilter( velocityOut, lowPassFilterCutOff, sampleRate );

% remove velocity values that are too large to be possible for the fly
velocityOut = replaceValuesOutsideThresholdBound( velocityOut, maxFlyVelocity);

% plotting to check degree calulation and velocity
figure('Position',[50, 50, 1000, 400]);  set(gcf, 'Color', 'w');
bx(1) = subplot(3, 1, 1);
plot(filteredPosition, 'DisplayName', 'filteredPosition' ); hold on; legend('show');
bx(1) = subplot(3, 1, 2);
plot(accumulatedPositionOut, 'DisplayName', 'accumulatedPosition' ); hold on; legend('show');
ylabel ('deg');
bx(2) = subplot (3, 1, 3);
plot(velocityOut, 'DisplayName', 'velocity' ); hold on; legend('show');
linkaxes(bx,'x');


end

