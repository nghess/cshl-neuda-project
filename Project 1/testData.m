test = permute(csd,[3,1,2]);
[ts] = PCA_sliding_window(test,[1:200],100,.8);
%%
figure
plot(ts)