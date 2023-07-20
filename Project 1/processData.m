% load data
blankslate;
mice_name = 'Cori_2016-12-18';
S = loadSession(fullfile('C:\Users\Admin\Desktop\Data\Steinmetz\allData', mice_name)); % this calls a custom-coded read function for this dataset; it reads all .npy and .tsv files in the directory

% Get neurons
neurons = struct;

% define window, region and preview data

win = [1:200];
% process data as needed

% conduct PCA on windowed data

[myLoads, myScores, myVars, ~ , VarExplained] = pca(simData);

%visualize PCA





