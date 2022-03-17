function [ trialFilesList , fullTrialFilesList , fullStimulusList , fullTrialNumList ] = extractTrialsWithCertainStimulusName( stimulusNameToExtract , includeIfNameContainsString, varargin)
%EXTRACTTRIALSWITHCERTAINSTIMULUSNAME searches thru a folder with Ephy data
%from a single recording and extract all the trials that used a certain
%stimulus
%  INPUT
%       stimulusNameToExtract => string to look for in stimulus.name

%       includeIfNameContainsString => Logical if 'true' any name that
%       contains the string will be returned.  If 'false' only exact string
%       matches will be return
%
%       trial option list -3rd optional input
%
%  OUTPUT
%       trialNumberList => array containing all trial numbers where that
%       stimulus was used
%       fullTrialNumberList => array containing all trial numbers where any
%       stimulus was used
%
%  Yvette Fisher 10/2017, updated 11/2018
if nargin > 2
    possibleTrialNums = varargin{1};
end


% prompt users in a gui to navegate to the folder we want to analyize
DIRECTORYNAME = uigetdir();
cd( DIRECTORYNAME );

fileListDescription = fullfile(DIRECTORYNAME, '*.mat');
fileList = dir( fileListDescription );
% find which files contain the string 'trial'
isATrialLogical = contains( {fileList.name}, 'trial');
fileList = fileList( isATrialLogical ); % only keep files that are actually trial files

counter = 1;
allTrialsCounter = 1; % update the counter        

% loop over all data trials within that folder
for i = 1: length( fileList )
    
    % load current file
    load( fileList(i).name)

    
    % check if stimulus is a variable
    if( exist( 'stimulus', 'var') )
        
        % save current file name
        fullTrialFilesList(allTrialsCounter) = fileList(i);
        fullStimulusList{allTrialsCounter} = stimulus.name; % same simtulus name
        fullTrialNumList(allTrialsCounter) = trialMeta.trialNum;
        allTrialsCounter = allTrialsCounter + 1;
        
        if(  (includeIfNameContainsString && contains(stimulus.name,  stimulusNameToExtract)) || strcmp (stimulus.name,  stimulusNameToExtract))
            
            % check if fileList is within trials wanted, if we are even bothering
            % to check:
            if( exist( 'possibleTrialNums', 'var') )
                % if it is not correct trial number
                if( exist( 'trialMeta', 'var') && sum(trialMeta.trialNum == possibleTrialNums) )
                           
                    % save file name into
                    trialFilesList( counter ) = fileList (i);
                    counter = counter + 1; % update the counter
                end
            else
                 % save file name into
                    trialFilesList( counter ) = fileList (i);
                    counter = counter + 1; % update the counter          
            end
            
        end
    end
end

    % check if trialFilesList exists
% if not create an empty variable and print warning
if( ~exist('trialFilesList') )
    trialFilesList = struct([]);
    print('WARNING: trialFilesList variable is empty, no files used the specified stimulus')
end

end

