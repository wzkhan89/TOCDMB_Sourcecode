
clear; clc; close all;
addpath(genpath(pwd));


data_name   = 'Pig';   
sample_size = 500;        

%Parameters
alpha = 0.01; data_type = 'dis'; alg_name = 'TOCDmb'; num_datasets = 10; 

switch data_name
    case 'Insurance', prefix='Insurance'; folder='data/insurance_data';
    case 'Mildew',    prefix='Mildew';    folder='data/mildew_data';
    case 'Child3',    prefix='Child3';    folder='data/child3_data';
    case 'Child10',   prefix='Child10';   folder='data/child10_data';
    case 'Alarm10',   prefix='Alarm10';   folder='data/alarm10_data';
    case 'Pig',       prefix='Pigs';      folder='data/pigs_data';
    case 'Gene',      prefix='Gene';      folder='data/gene_data';
    otherwise, error('Unknown data_name: %s', data_name);
end

graph = importdata(fullfile(folder, [prefix '_graph.txt']));
fprintf('T-OCDMB | %s | n=%d\n', data_name, sample_size);

prec=[]; rec=[]; total_time=0; used=0;
for d = 1:num_datasets
    dp = fullfile(folder, sprintf('%s_s%d_v%d.txt', prefix, sample_size, d));
    if exist(dp,'file')==0, continue; end
    data = importdata(dp) + 1; nf = size(data,2); used = used + 1;
    dpr = zeros(1,nf); drc = zeros(1,nf);
    for target = 1:nf
        [MB,~,t] = Causal_Learner(alg_name, data, data_type, alpha, target);
        [~,pr,rc] = evaluation_MB(MB, target, graph);
        dpr(target)=pr; drc(target)=rc; total_time=total_time+t;
    end
    prec=[prec, mean(dpr)]; rec=[rec, mean(drc)]; %#ok<AGROW>
    fprintf('  v%-2d  precision=%.3f  recall=%.3f\n', d, mean(dpr), mean(drc));
end

fprintf('----------------------------------------\n');
fprintf(' RESULT %s n=%d:  precision=%.2f+/-%.2f  recall=%.2f+/-%.2f\n', ...
    data_name, sample_size, mean(prec), std(prec), mean(rec), std(rec));
fprintf(' Avg time per dataset = %.2f s\n', total_time/max(used,1));
