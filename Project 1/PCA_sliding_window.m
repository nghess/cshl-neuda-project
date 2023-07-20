function [ts_num_PC_effective]= PCA_sliding_window(data,window,stride,eff_lim)
%assuming data is trl by cell by time
%win_size is a vector of time points (e.g. [1:20])
num_trl = size(data,1);
num_cell = size(data,2);
num_time = size(data,3);

num_wins = ceil(num_time/length(window));
ts_num_PC_effective = nan(num_trl,num_wins);
for trl = 1:num_trl


    curr_data = squeeze(data(trl,:,:));

    for win = 1:num_wins
        curr_win = window+(win*stride);
        curr_data_windowed= curr_data(:,curr_win);
        [ eivector, proj, eivals , ~, var_explained] = pca(curr_data_windowed);
        cumsum_var_explained = cumsum(var_explained);
        for pc = 1:length(var_explained)
            if cumsum_var_explained(pc)>eff_lim*100
                ts_num_PC_effective(trl,win) = pc;
                break
            end
        end

    end
end