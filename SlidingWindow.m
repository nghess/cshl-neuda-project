function [binnedActivity, time] = SlidingWindow(regionActivity, timeDuration, windowSize, strideSize)
%
%
%

timeDuration = timeDuration .* 1000;
if rem(windowSize, 2) ~= 1
    error('Window size has to be odd!')
end

timeSteps = (timeDuration(1) + ceil(windowSize/2)): strideSize: (timeDuration(2) - ceil(windowSize/2)) ;
time = timeSteps/1000;

[neurons, trials] = size(regionActivity);

binnedActivity = zeros(neurons, trials, length(timeSteps));

for ii = 1:trials

    for jj = 1:neurons

        neuronSpiketimes = regionActivity{jj,ii};

        if isempty(neuronSpiketimes)
            continue;
        end

        for kk = 1:length(timeSteps)
            
            curr_time = [timeSteps(kk) - (windowSize-1)/2,...
                timeSteps(kk) + (windowSize-1)/2]/1000;

            binnedActivity(jj, ii, kk) = length(find(...
                neuronSpiketimes >= curr_time(1) & ...
                neuronSpiketimes <= curr_time(2)));

        end

    end

end