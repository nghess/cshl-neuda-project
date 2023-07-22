function [mat_out,timepoints] = cellarray_to_matrix(cell_in,bin_win,stride,trl_time_win)
%takes a cell array of neurons by trials, with each cell containing the
%spike times of each neuron at that trial
%and turns it into a trial by neuron by time array
%trl_time_win is time ticks, with 0 locked to stim
%e.g. [-1.5::5.5]
%bin_win is the window counting size in ms (e.g. 300ms)
%stride in in ms (e.g. 10ms)
%SYX 072123
nNeurons = size(cell_in,1);
nTrls = size(cell_in,2);
epoch_start = trl_time_win(1);
epoch_end = trl_time_win(length(trl_time_win));
nTimePoints_ms = (epoch_end-epoch_start)*1000;
% nTime = nTimePoints_ms/bin_win;
nStride = nTimePoints_ms/stride;
zero_time = abs(trl_time_win(1))*1000;

mat_out = nan(nNeurons,nTrls,nStride);
for n = 1:nNeurons % last region is usually 'root' (i.e. unassigned)
    for trl = 1:nTrls
        if ~isempty(cell_in{n,trl})
            for strd = 1:nStride
                temp_start = ((strd-1)*stride+1);
                temp_end = ((strd-1)*stride+bin_win);
                tempSpk = cell_in{n,trl};
                tempSpkms = tempSpk*1000;
                tempSpkms = tempSpkms+zero_time;
                sum(tempSpkms<temp_end & tempSpkms>temp_start);
                mat_out(n,trl,strd) = sum(tempSpkms<temp_end & tempSpkms>temp_start);
            end
        else
            mat_out(n,trl,:) = zeros(1,nStride);
        end
    end
end



timepoints = trl_time_win;