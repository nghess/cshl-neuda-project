% Matlab Exercises on analysis of Steinmetz Data for CSHL course
% Primary Authors: Michael Moore and Mark Reimers, modified by PW
% Start from code directory

blankslate;
%rootfolder = 'Z:\Projects\Project 1';
%cd(rootfolder);
%addpath(genpath(fullfile(rootfolder, '/npy-matlab-master')));

%% Specify the path to the folder containing the datasets
% add path to npy-matlab-master as well as to the current directory for
% helper functions

mice_name = 'Cori_2016-12-18';
S = loadSession(fullfile('\\eden\neuda2023\Data\Steinmetz\allData', mice_name)); % this calls a custom-coded read function for this dataset; it reads all .npy and .tsv files in the directory

%% Region Properties
% make a structure containing properties of the regions included in the session

regions = struct;
regions.name = unique(S.channels.brainLocation.allen_ontology,'rows'); % a character array 
regions.N = size(regions.name,1);
regions = orderfields(regions,{'N','name'});
regions.color = hsv(size(regions.name,1)-1); % unique rgb triplet for each region
regions.color(regions.N,:) = [ .5 .5 .5]; % grey for 'root' (i.e. not known)
% go further: add probe and depth fields to regions struct

%% Neuron Properties 
% neuron ('cluster') properties are distributed in a few different places,
% we bring them together into a new struct called 'neurons'

neurons = struct;
% extract the neuron properties
neurons.id = unique(S.spikes.clusters);
% note that id's in S.spikes.clusters run from 0 to (N-1), and do not match row index of S.clusters 
neurons.N = length(neurons.id); % number of neurons
neurons = orderfields(neurons,{'N','id'});

% identify region by row in region struct
[~,Loc] = ismember(S.channels.brainLocation.allen_ontology(S.clusters.peakChannel,:),regions.name,'rows');
neurons.region = Loc; % numeric code for region
regions.name = strtrim(string(regions.name)); % after match, make names into a more manageable string variable
clear Loc
neurons.depth = S.clusters.depths;
neurons.probe = S.clusters.probes;

[~,depthOrder ] = sort(neurons.depth);

%% Create a structure containing information about the trial
trials = struct;
trials.N = size(S.trials.intervals,1);
trials.isStimulus = S.trials.visualStim_contrastLeft > 0 | S.trials.visualStim_contrastRight > 0; % did a brighter image appear on one side?
trials.isMovement = S.trials.response_choice ~= 0; % did the mouse move the wheel in response?
trials.visStimTime = S.trials.visualStim_times; % time of stimulus
trials.responseTime = S.trials.response_times; % time response recorded
trials.turn = S.trials.response_choice; % 
trials.contrast =  S.trials.visualStim_contrastLeft - S.trials.visualStim_contrastRight ; % contr
LvsR=sign( trials.contrast ); % indicates contrast difference relevant for choice
xtab1=crosstab( LvsR ,  S.trials.response_choice);
% stimuli  L<R, L=R, L>R in rows; choices -1,0,1 in column
% Make a contingency table of stimuli x choices and display it on console
table(xtab1(:,1),xtab1(:,2),xtab1(:,3),'VariableNames',{ 'turn R', 'No turn', 'turn L'},'RowNames',{'L', 'equal', 'R'})
trials.Correct = ( LvsR == 0 | S.trials.response_choice == LvsR) & trials.isMovement ; % flag correct choices
% omitting passive if both 0
trials.responseLatency = trials.responseTime - S.trials.goCue_times; 
trials.timeOut = trials.responseLatency > 1.49; % time outs at 1.5 sec

regionTable = table( histcounts(neurons.region(neurons.probe==0),...
    .5:1:(regions.N-.5))', histcounts(neurons.region(neurons.probe==1),.5:1:(regions.N-.5))', ...
    'VariableNames',["Probe 0" "Probe 1"],'RowNames', regions.name(1:regions.N-1));
disp(regionTable) % print out region names

% add more fields to trial structure
trials.intervals = S.trials.intervals;
trials.goCueTime = S.trials.goCue_times; % time of stimulus

%% Identify neurons, get the spike times and align trial to the experiment time
alignCues = {'visStimTime', 'goCueTime'};

for ll = 1:length(regions.name)
    
    % Identify neurons in relevant regions
    relReg = ll; %Suggestion for exploration - change this to 9 later, to compare with extrastriate COMMENT: *VISp is the primary visual cortex COMMENT: do we need to pool many brain regions?
    neuronsInRegionRowNumbers = find(neurons.region == relReg); %Which rows are relevant?
    neuronIdsInRegion = neurons.id(neuronsInRegionRowNumbers); %Which IDs do these rows correspond to?
    nRelNeuron = length(neuronIdsInRegion); %How many relevant neurons are there?
    spikeTimesPerNeuron = cell(nRelNeuron,3); %Initialize a cell where we will put spike times

    % Get the spike times out and assign it to neurons
    for ii = 1:nRelNeuron %Go through all the neurons - relevant ones only
        tempIndices = find(S.spikes.clusters == neuronIdsInRegion(ii)); %All spikes of a given neuron
        spikeTimesPerNeuron{ii,1} = ii; %Row number
        spikeTimesPerNeuron{ii,2} = neuronIdsInRegion(ii); %Which neuron did spikes come from?
        spikeTimesPerNeuron{ii,3} = S.spikes.times(tempIndices); %Corresponding spiketime
    end %This takes a moment

    regionActivity = cell(nRelNeuron, trials.N);

    % Sort neuron activity based on trials
    for kk = 1:length(alignCues)
    
        %neuronal activity aligned to visual stimulus
        for ii = 1:trials.N %Go through all trials and align by stimulus onset time
        
            for jj = 1:nRelNeuron % Go through all neurons
        
                neuronSpikeTimes = spikeTimesPerNeuron{jj,3};
                validSpikeTimes = neuronSpikeTimes(neuronSpikeTimes >= trials.intervals(ii,1) & neuronSpikeTimes <= trials.intervals(ii,2));
                alignedSpikeTimes = validSpikeTimes-trials.(alignCues{kk})(ii); %On same clock
                regionActivity{jj, ii} = alignedSpikeTimes;
        
            end
        
        end %This should be fast
        
        % Important parameters
        regionName = regions.name(relReg);
        regionID = relReg;
        alignCue = alignCues{kk};

        % save
        save(fullfile(pwd, 'mat-files',...
            sprintf('%s-%s-spiketimes.mat',regions.name(relReg), alignCues{kk})),...
            "regionName", "regionID", "regionActivity", "alignCue",...
            "regions", "spikeTimesPerNeuron");
    end
end
