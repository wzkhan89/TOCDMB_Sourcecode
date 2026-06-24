function [MB, num_ci_tests, elapsed_time] = TOCDmb_G2(Data, target, alpha, ns, p, maxK)

start_time   = tic;
num_ci_tests = 0;


%% Step 1: PC recognition via HITON-PC

[pc, nt, sepset] = HITONPC_TOCD(Data, target, alpha, ns, p, maxK);
num_ci_tests = num_ci_tests + nt;
for i = 1:p
    if isempty(sepset{i}), sepset{i} = []; end
end


%% Step 2: Spouse recognition via BAMB 

NonPC  = mysetdiff(1:p, [pc, target]);
spouse = cell(1, p);                  % spouse{Y} = spouses through common child Y

for ci = 1:length(pc)
    Y    = pc(ci);
    cand = [];
    for k = 1:length(NonPC)
        X     = NonPC(k);
        sepXT = sepset{X};

        
        pval_indep = my_g2_test(X, target, sepXT, Data, ns, alpha);
        num_ci_tests = num_ci_tests + 1;
        if isnan(pval_indep) || pval_indep <= alpha
            continue;
        end

        
        S = myunion(sepXT, Y);
        pval_dep = my_g2_test(X, target, S, Data, ns, alpha);
        num_ci_tests = num_ci_tests + 1;
        if ~isnan(pval_dep) && pval_dep <= alpha
            cand = [cand, X];         %#ok<AGROW>
        end
    end
    spouse{Y} = cand;
end

% Step 2b: prune false spouses. 
for ci = 1:length(pc)
    Y      = pc(ci);
    SpY    = spouse{Y};
    pcRest = mysetdiff(pc, Y);
    kept   = SpY;
    for s = 1:length(SpY)
        X   = SpY(s);
        cut = 0;
        flags = 1;
        while length(pcRest) >= cut && cut <= maxK
            SS = subsets1(pcRest, cut);
            for si = 1:length(SS)
                ConSet = myunion(SS{si}, Y);
                pval = my_g2_test(target, X, ConSet, Data, ns, alpha);
                num_ci_tests = num_ci_tests + 1;
                if isnan(pval)
                    
                else
                    if pval > alpha
                        flags = 0;
                        kept  = mysetdiff(kept, X);
                        break;
                    end
                end
            end
            if flags == 0, break; end
            cut = cut + 1;
        end
    end
    spouse{Y} = kept;
end


spouse_all = [];
for ci = 1:length(pc)
    if ~isempty(spouse{pc(ci)})
        spouse_all = myunion(spouse_all, spouse{pc(ci)}(:)');
    end
end
spouse_all = mysetdiff(spouse_all, pc);


%% Step 3: Non-MB descendant removal via STMB 

CanPC = pc;
for ci = 1:length(pc)
    Y      = pc(ci);
    CanSpY = spouse{Y};
    pcRest = mysetdiff(pc, Y);
    cut    = 1;
    flags  = 1;
    while length(pcRest) >= cut && cut <= maxK
        SS = subsets1(pcRest, cut);
        for si = 1:length(SS)
            ConSet = myunion(SS{si}, CanSpY);
            pval = my_g2_test(target, Y, ConSet, Data, ns, alpha);
            num_ci_tests = num_ci_tests + 1;
            if isnan(pval)
                
            else
                if pval > alpha
                    flags = 0;
                    CanPC = mysetdiff(CanPC, Y);
                    break;
                end
            end
        end
        if flags == 0, break; end
        cut = cut + 1;
    end
end
pc = CanPC;

MB = myunion(pc, spouse_all);
elapsed_time = toc(start_time);
end


function [pc, ntest, sepset] = HITONPC_TOCD(Data, target, alpha, ns, p, k)
cpc    = [];
pc     = [];
dep    = zeros(1, p);
sepset = cell(1, p);
ntest  = 0;


for i = 1:p
    if i == target, continue; end
    ntest = ntest + 1;
    [pval, dep(i)] = my_g2_test(i, target, [], Data, ns, alpha);
    if isnan(pval)
        CI = 1;                
    elseif pval <= alpha
        CI = 0;                 
    else
        CI = 1;                 
    end
    if CI == 0
        cpc = [cpc, i];        
    end
end


[~, var_index] = sort(dep(cpc), 'descend');


for i = 1:length(cpc)
    Y  = cpc(var_index(i));
    pc = [pc, Y];              

    pc_tmp         = pc;
    last_break_flag = 0;

    for j = length(pc):-1:1
        X     = pc(j);
        CanPC = mysetdiff(pc_tmp, X);

        break_flag = 0;
        cutSetSize = 1;         
        while length(CanPC) >= cutSetSize && cutSetSize <= k
            SS = subsets1(CanPC, cutSetSize);
            for si = 1:length(SS)
                Z = SS{si};

                
                if X ~= Y
                    if isempty(find(Z == Y, 1))
                        continue;
                    end
                end

                ntest = ntest + 1;
                pval = my_g2_test(X, target, Z, Data, ns, alpha);
                if isnan(pval)
                    CI = 0;     
                elseif pval <= alpha
                    CI = 0;     
                else
                    CI = 1;     
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
        if break_flag == 1 || last_break_flag == 1, break; end
    end

    pc = pc_tmp;
end
end
