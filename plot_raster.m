load('./mat-files/cues/MG-goCueTime-spiketimes.mat');
[neurons, trials] = size(regionActivity);

figure(1);

for ii = 1:neurons %Going through all the relevant trials

    clf;
    hold on;


    for jj = 1:trials
        tempSpikes = regionActivity{ii,jj}; %Retrieve the spikes from that trial
        nSpikes = length(tempSpikes); %How many?
        for kk = 1:nSpikes %Plot each individual spike
            plot([tempSpikes(kk) tempSpikes(kk)],[jj jj+1],'color','k') %As a tick mark
        end
    end
    xline(0,'r','LineWidth',2);
    xlim([-15 5]); %Proper onsets
    ylim([1 jj+1]) %And figure cutoffs 
    xlabel('t in s') %And labels
    ylabel('Trial number')
    %movshonize(36,1)
    %makeWhite
    %shg

    % pause(0.2);
end
