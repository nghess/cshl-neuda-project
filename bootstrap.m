function [ts_mat_boot] = boot(mat_in)
% mat_in is the binnedActivity which is neuron by trial by time
[nNeuron nTrl nTime] = size(mat_in);
ts_mat_boot = nan(nNeuron,nTrl,nTime);
for neu = 1:nNeuron
    for t = 1:nTime
        candidates = squeeze(mat_in(neu,:,t));
        randindx = randsample(nTrl,nTrl,'true');
        ts_mat_boot(neu,:,t) = candidates(randindx);
    end
end