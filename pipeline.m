%% load data mats
file_dir = 'C:\CSHL Neural Data Science\cshl-neuda-project\results-mat\';
fs = dir([file_dir '*.mat']);
figure(1);
legends = [];

for file = 1%:length(fs)
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

%%
% [-0.3, 1.5]
[binnedActivity, time] = SlidingWindow(regionActivity, [-0.3 1.5], 101, 5);
nBoot = 200;
booted_mat = nan(nBoot,size(binnedActivity,1),size(binnedActivity,2),size(binnedActivity,3));
for b = 1:nBoot
    [booted_mat(b,:,:,:)] = boot(binnedActivity);
end

eff_lim = 0.8;
[ts] = count_PCs(binnedActivity,eff_lim);

%legends = [legends,{filename}];

figure
plot(time, ts)
hold on;
xline(0)


%cd('Z:\Projects\Project 1\results_mat\')
%save([filename,'_results.mat'],'ts')
end
%legend(legends)