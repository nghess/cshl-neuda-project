%% load data mats
file_dir = 'Z:\Projects\Project 1\mat-files\'
fs = dir(file_dir)
for file = 3:length(fs)
filename = fs(file).name;
load([file_dir,filename])

% times = [];
% for ii = 1:size(regionActivity(1))
%     for jj = 1:size(regionActivity(2))
%         curr_mat = regionActivity{ii,jj};
%         times = [times;curr_mat];
%     end
% end
% min_time = min(times);
% max_time = max(times);


window = [-15:5];
tic
[mat_out,timepoints] = cellarray_to_matrix(regionActivity,200,50,window);
toc
% plotting one neuron
% figure
eff_lim = .8;
zero_time = abs(window(1))/((window(length(window))-window(1))/size(mat_out,3));
ts = zeros(1,size(mat_out,3));
for t = 1:size(mat_out,3)
    curr_vector = squeeze(mat_out(:,:,t));
    [ eivector, proj, eivals , ~, var_explained] = pca(curr_vector');
    cumsum_var_explained = cumsum(var_explained);
    for pc = 1:length(var_explained)
        if cumsum_var_explained(pc)>eff_lim*100
            ts(:,t) = pc;
            break
        end
    end
end




%
figure
plot(ts)
xline(zero_time)
title(filename)

cd('Z:\Projects\Project 1\results_mat\')
save([filename,'_results.mat'],'ts')
end
