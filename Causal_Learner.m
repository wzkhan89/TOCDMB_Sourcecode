function [Result1, Result2, Result3] = Causal_Learner(input_alg_name, data, data_type, alpha, target)


if nargin < 5
    error('Insufficient input arguments. Usage: Causal_Learner(''TOCDmb'', data, ''dis'', alpha, target)');
end

addpath(genpath(pwd));


if ~strcmp(input_alg_name, 'TOCDmb')
    error('Invalid algorithm name: %s. This package only contains TOCDmb.', input_alg_name);
end

if ~strcmp(data_type, 'dis')
    error('TOCDmb_G2 requires discrete data; set data_type = ''dis''.');
end

% Parameters.
maxK = 3;
[~, p] = size(data);
ns = max(data);          

% Markov blanket learning by T-OCDMB.
fprintf('\nMarkov blanket learning by TOCDmb\n');
[MB, test, time] = TOCDmb_G2(data, target, alpha, ns, p, maxK);

Result1 = MB;
Result2 = test;
Result3 = time;

fprintf('------------------------------------\n');
end
