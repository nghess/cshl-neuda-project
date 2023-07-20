% Matlab Exercises on analysis of Steinmetz Data for CSHL course
% Primary Authors: Michael Moore and Mark Reimers, modified by PW
% Start from code directory

blankslate;
addpath(genpath('./npy-matlab-master'));

%% Specify the path to the folder containing the datasets
% add path to npy-matlab-master as well as to the current directory for
% helper functions

mice_name = 'Cori_2016-12-18';
S = loadSession(fullfile('C:\Users\Admin\Desktop\Data\Steinmetz\allData', mice_name)); % this calls a custom-coded read function for this dataset; it reads all .npy and .tsv files in the directory

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
trials.goCue_times = S.trials.goCue_times; % time of stimulus

%% 1) Identify neurons in relevant regions (3 = LGd, 9 = VISa, 10 = VISp)
relReg = 9; %Suggestion for exploration - change this to 9 later, to compare with extrastriate
neuronsInRegionRowNumbers = find(neurons.region == relReg); %Which rows are relevant?
neuronIdsInRegion = neurons.id(neuronsInRegionRowNumbers); %Which IDs do these rows correspond to?
nRelNeuron = length(neuronIdsInRegion); %How many relevant neurons are there?
spikeTimesPerNeuron = cell(nRelNeuron,3); %Initialize a cell where we will put spike times

%% 2) Get the spike times out and assign it to neurons
for ii = 1:nRelNeuron %Go through all the neurons - relevant ones only
    tempIndices = find(S.spikes.clusters == neuronIdsInRegion(ii)); %All spikes of a given neuron
    spikeTimesPerNeuron{ii,1} = ii; %Row number
    spikeTimesPerNeuron{ii,2} = neuronIdsInRegion(ii); %Which neuron did spikes come from?
    spikeTimesPerNeuron{ii,3} = S.spikes.times(tempIndices); %Corresponding spiketime
end %This takes a moment

%% 3) Align trial to the an experiment time
alignCue = 'visualStim_times';
% alignCue = 'goCue_times';

n = trials.N; %How many trials are there?
spikingPerTrial = cell(n,1); %Now, n is trial number

for ii = 1:n %Go through all trials and align by stimulus onset time
    for jj = 1:nRelNeuron % Go through all neurons
        alignedSpikeTimes = spikeTimesPerNeuron{targetNeuronRow,3}-trials.visStimTime(ii); %On same clock
        spikingPerTrial{ii} = alignedSpikeTimes(alignedSpikeTimes > onsetCutoff & alignedSpikeTimes < offsetCutoff);
    end
end %This should be fast


