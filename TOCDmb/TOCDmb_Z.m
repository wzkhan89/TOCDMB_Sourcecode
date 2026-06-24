function [MB, PC, spouse, test, time, sepset] = TOCDmb_Z(Data, target, alpha, samples, p, maxK)


start = tic;

if nargin < 3
    error('Data, target, and alpha are required inputs.');
end
if nargin < 4 || isempty(samples), samples = size(Data, 1); end
if nargin < 5 || isempty(p),       p       = size(Data, 2); end
if nargin < 6 || isempty(maxK),    maxK    = 3;             end

PC     = [];
cpc    = [];
spouse = cell(1, p);
sepset = cell(1, p);
dep    = zeros(1, p);
test   = 0;

%% Step 1: candidate PC 
for i = 1:p
    if i == target, continue; end
    [CI, dep(i)] = my_fisherz_test(i, target, [], Data, samples, alpha);
    test = test + 1;
    if isnan(CI)
        CI = 1;                 
    end
    if CI == 0
        cpc = [cpc, i];         
    end
end

[~, var_index] = sort(dep(cpc), 'descend');

%% Step 2: HITON-PC  
for i = 1:length(cpc)
    Y  = cpc(var_index(i));
    PC = [PC, Y];               

    pc_tmp          = PC;
    last_break_flag = 0;

    for j = length(PC):-1:1
        X     = PC(j);
        CanPC = mysetdiff(pc_tmp, X);

        break_flag = 0;
        cutSetSize = 1;         
        while length(CanPC) >= cutSetSize && cutSetSize <= maxK
            SS = subsets1(CanPC, cutSetSize);
            for si = 1:length(SS)
                Z = SS{si};
                
                if X ~= Y && isempty(find(Z == Y, 1))
                    continue;
                end

                CI = my_fisherz_test(X, target, Z, Data, samples, alpha);
                test = test + 1;
                if isnan(CI)
                    CI = 0;     
                end

                if CI == 1
                    pc_tmp     = CanPC;
                    sepset{X}  = Z;
                    break_flag = 1;
                    if X == Y, last_break_flag = 1; end
                    break;
                end
            end
            if break_flag == 1 || last_break_flag == 1, break; end
            cutSetSize = cutSetSize + 1;
        end
        if last_break_flag == 1, break; end
    end

    PC = pc_tmp;
end

%% Step 3: spouse discovery 
NonTPC = mysetdiff(1:p, myunion(PC, target));

for ci = 1:length(PC)
    Y    = PC(ci);
    cand = [];

   
    for k = 1:length(NonTPC)
        X     = NonTPC(k);
        sepXT = sepset{X};
        if isempty(sepXT), sepXT = []; end

        
        CI1 = my_fisherz_test(X, target, sepXT, Data, samples, alpha);
        test = test + 1;
        if isnan(CI1) || CI1 == 0
            continue;           
        end

        
        S = myunion(sepXT, Y);
        CI2 = my_fisherz_test(X, target, S, Data, samples, alpha);
        test = test + 1;
        if isnan(CI2)
            continue;           
        end
        if CI2 == 0
            cand = myunion(cand, X);   
        end
    end

    [spouse{Y}, nt] = refineSpouses(cand, Y, PC, target, Data, samples, alpha, maxK);
    test = test + nt;
end

%% Step 4: final MB pruning
spouse_all = cell2mat(spouse);
spouse_all = mysetdiff(unique(spouse_all), PC);
MB = myunion(PC, spouse_all);

PC_in = PC;
for i = 1:length(PC_in)
    X = PC_in(i);
    if isempty(find(PC == X, 1)), continue; end
    restMB = mysetdiff(MB, X);

    CI = my_fisherz_test(X, target, restMB, Data, samples, alpha);
    test = test + 1;
    if isnan(CI)
        CI = 0;                 
    end
    if CI == 1
        PC = mysetdiff(PC, X);
        spouse{X} = [];
        MB = mysetdiff(MB, X);
    end
end

%% Final Markov blanket 
spouse_all = mysetdiff(unique(cell2mat(spouse)), PC);
MB   = myunion(PC, spouse_all);
time = toc(start);
end


function [refined, test] = refineSpouses(cand, Y, PC, target, Data, samples, alpha, maxK)
test = 0;
if isempty(cand)
    refined = [];
    return;
end

pcRest = mysetdiff(PC, Y);


dep = zeros(1, max(cand));
for k = 1:length(cand)
    X = cand(k);
    [~, dep(X)] = my_fisherz_test(target, X, [], Data, samples, alpha);
    test = test + 1;
end
[~, ord] = sort(dep(cand), 'descend');
SP = cand(ord);

kept = SP;
for s = 1:length(SP)
    X   = SP(s);
    cut = 0;
    dropped = false;
    while length(pcRest) >= cut && cut <= maxK
        SS = subsets1(pcRest, cut);
        for si = 1:length(SS)
            condset = myunion(SS{si}, Y);
            CI = my_fisherz_test(X, target, condset, Data, samples, alpha);
            test = test + 1;
            if isnan(CI), CI = 0; end      
            if CI == 1
                dropped = true;
                break;
            end
        end
        if dropped, break; end
        cut = cut + 1;
    end
    if dropped
        kept = mysetdiff(kept, X);
    end
end
SP = kept;


kept = SP;
for s = 1:length(SP)
    X   = SP(s);
    cut = 0;
    dropped = false;
    while length(pcRest) >= cut && cut <= maxK
        SS = subsets1(pcRest, cut);
        for si = 1:length(SS)
            condset = myunion(SS{si}, Y);
            CI = my_fisherz_test(target, X, condset, Data, samples, alpha);
            test = test + 1;
            if isnan(CI), CI = 0; end
            if CI == 1
                dropped = true;
                break;
            end
        end
        if dropped, break; end
        cut = cut + 1;
    end
    if dropped
        kept = mysetdiff(kept, X);
    end
end

refined = kept;
end
