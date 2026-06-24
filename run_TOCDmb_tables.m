% run_TOCDmb_tables.m
% ----------------------------------------------------------------------
% Reproduces the T-OCDMB column of:
%   Table 4  Precision, sample size 500
%   Table 5  Recall,    sample size 500
%   Table 6  Precision, sample size 5000
%   Table 7  Recall,    sample size 5000
% and the average per-dataset runtime used in Table 8.
%
% For each benchmark BN and sample size it averages adjacency precision and
% recall over all targets and all 10 datasets, matching Eqs. (1)-(2):
%     Recall    = TP / (TP + FN)
%     Precision = TP / (TP + FP)
%
% Just open MATLAB in this folder and run:  run_TOCDmb_tables
% ----------------------------------------------------------------------

clear; clc; close all;
addpath(genpath(pwd));

alg_name     = 'TOCDmb';
data_type    = 'dis';        % BN data is discrete -> G2 test
alpha        = 0.01;         % significance level used in the paper
num_datasets = 10;           % 10 datasets per BN per sample size
sample_sizes = [500, 5000];

% {paper_name, file_prefix, data_subfolder}
bn_list = {
    'Insurance', 'Insurance', 'data/insurance_data'
    'Mildew',    'Mildew',    'data/mildew_data'
    'Child3',    'Child3',    'data/child3_data'
    'Child10',   'Child10',   'data/child10_data'
    'Alarm10',   'Alarm10',   'data/alarm10_data'
    'Pig',       'Pigs',      'data/pigs_data'
    'Gene',      'Gene',      'data/gene_data'
};

nBN = size(bn_list, 1);
nSS = numel(sample_sizes);

precision_tbl = nan(nBN, nSS);
recall_tbl    = nan(nBN, nSS);
time_tbl      = nan(nBN, nSS);

for b = 1:nBN
    paper_name = bn_list{b, 1};
    prefix     = bn_list{b, 2};
    folder     = bn_list{b, 3};

    graph_path = fullfile(folder, [prefix '_graph.txt']);
    if exist(graph_path, 'file') == 0
        fprintf('[skip] %s: graph not found (%s)\n', paper_name, graph_path);
        continue;
    end
    graph = importdata(graph_path);

    for s = 1:nSS
        ss = sample_sizes(s);

        prec_per_dataset = [];
        rec_per_dataset  = [];
        total_time = 0;
        used = 0;

        for d = 1:num_datasets
            data_path = fullfile(folder, sprintf('%s_s%d_v%d.txt', prefix, ss, d));
            if exist(data_path, 'file') == 0
                continue;
            end
            data = importdata(data_path) + 1;     % values must start at 1
            nf   = size(data, 2);
            used = used + 1;

            ds_prec = zeros(1, nf);
            ds_rec  = zeros(1, nf);
            for target = 1:nf
                [MB, ~, t] = Causal_Learner(alg_name, data, data_type, alpha, target);
                [~, adj_precision, adj_recall] = evaluation_MB(MB, target, graph);
                ds_prec(target) = adj_precision;
                ds_rec(target)  = adj_recall;
                total_time = total_time + t;
            end
            prec_per_dataset = [prec_per_dataset, mean(ds_prec)]; %#ok<AGROW>
            rec_per_dataset  = [rec_per_dataset,  mean(ds_rec)];  %#ok<AGROW>
        end

        if used > 0
            precision_tbl(b, s) = mean(prec_per_dataset);
            recall_tbl(b, s)    = mean(rec_per_dataset);
            time_tbl(b, s)      = total_time / used;
            fprintf('%-10s n=%-5d  precision=%.2f  recall=%.2f  time/ds=%.2fs\n', ...
                paper_name, ss, precision_tbl(b, s), recall_tbl(b, s), time_tbl(b, s));
        end
    end
end

%% ---- Print the four table columns -----------------------------------
print_col('Table 4  Precision (n=500)',  bn_list(:,1), precision_tbl(:,1));
print_col('Table 5  Recall    (n=500)',  bn_list(:,1), recall_tbl(:,1));
print_col('Table 6  Precision (n=5000)', bn_list(:,1), precision_tbl(:,2));
print_col('Table 7  Recall    (n=5000)', bn_list(:,1), recall_tbl(:,2));

fprintf('\nTable 8  Average runtime per dataset (s)\n');
fprintf('  %-10s  n=500: %.2f   n=5000: %.2f\n', 'overall mean', ...
    mean(time_tbl(:,1), 'omitnan'), mean(time_tbl(:,2), 'omitnan'));

function print_col(title, names, col)
    fprintf('\n%s\n', title);
    for i = 1:numel(names)
        if isnan(col(i))
            fprintf('  %-10s   --\n', names{i});
        else
            fprintf('  %-10s   %.2f\n', names{i}, col(i));
        end
    end
end
