function [ts] = count_PCs(binnedActivity,eff_lim)
ts = zeros(1, size(binnedActivity,3));
for t = 1:size(binnedActivity,3)
    curr_vector = squeeze(binnedActivity(:,:,t));
    [ eivector, proj, eivals , ~, var_explained] = pca(curr_vector);
    cumsum_var_explained = cumsum(var_explained);
    for pc = 1:length(var_explained)
        if cumsum_var_explained(pc)>eff_lim*100
            ts(:,t) = pc;
            break
        end
    end
end