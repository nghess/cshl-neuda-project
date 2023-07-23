function plot_PC_confint(ts,boot_ts,time,color,ylm)
%boot_ts dims: nBoot, time
%ts is timeseries of numPC 
%time is timestamps

nBoot = size(boot_ts,1);
SEM = std(boot_ts)/sqrt(nBoot);%neu, trl, time

up_lim = ts+1.96SEM;
low_lim = ts-1.96SEM;

figure
plot(time,ts,color,'lineWidth',2)
hold on
plot(up_lim,color,'lineStyle','--','lineWidth',1.5)
plot(low_lim,color,'lineStyle','--','lineWidth',1.5)

ylim(ylm)

end