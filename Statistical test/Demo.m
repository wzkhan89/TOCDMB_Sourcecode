%% drawNemenyi demo

       
% %%% real world datasets and algorithms ave values
% results = [0.02, 0.10, 0.09, 0.09;    % crx
%            0.01, 0.20, 0.17, 0.18;    % sonar
%            0.05, 0.11, 0.23, 0.15;    % optdigits
%            0.02, 0.07, 0.05, 0.07;    % coil2000
%            0.21, 1.00, 1.00, 1.00;    % colon
%            0.05, 0.22, 1.00, 0.38;    % lung
%            0.06, 1.00, 1.00, 1.00;    % sido0
%            0.15, 0.27, 0.27, 0.21;    % prostate-GE
%            0.01, 0.30, 0.34, 0.31;   % arcene
%            0.09, 0.19, 0.16, 0.16;    % leukemia2
%            0.08, 0.21, 0.21, 0.21;    % 11Tumors
%            0.10, 0.17, 0.17, 0.14;    % SMK-CAN-187
%            0.05, 0.11, 0.11, 0.11;    % GLI-85
%            0.04, 0.08, 1.00, 0.08];    % Dorothea

% %%% real world datasets and algorithms fine tree
% results = [0.03, 0.12, 0.12, 0.11;  % crx
%     0.01, 0.17, 0.17, 0.17;  % sonar
%     0.11, 0.12, 0.23, 0.19;  % optdigits
%     0.04, 0.05, 0.06, 0.05;  % coil2000
%     0.22, 0.00, 0.00, 0.00;  % colon
%     0.05, 0.00, 0.00, 0.37;  % lung
%     0.12, 0.00, 0.00, 0.00;  % sido0
%     0.14, 0.28, 0.31, 0.23;  % prostate-GE
%     0.01, 0.30, 0.39, 0.27;  % arcene
%     0.13, 0.23, 0.17, 0.18;  % leukemia2
%     0.12, 0.23, 0.23, 0.23;  % 11Tumors
%     0.14, 0.18, 0.18, 0.15;  % SMK-CAN-187
%     0.08, 0.11, 0.11, 0.10;  % GLI-85
%     0.05, 0.07, 0.00, 0.07]; % Dorothea


% %%% real world datasets and algorithms SVM
% results = [0.03, 0.07, 0.07, 0.07;  % crx
%     0.01, 0.14, 0.18, 0.17;  % sonar
%     0.06, 0.09, 0.23, 0.19;  % optdigits
%     0.02, 0.04, 0.05, 0.04;  % coil2000
%     0.22, 0.00, 0.00, 0.00;  % colon
%     0.05, 0.13, 0.00, 0.37;  % lung
%     0.04, 0.00, 0.00, 0.00;  % sido0
%     0.22, 0.27, 0.28, 0.22;  % prostate-GE
%     0.01, 0.27, 0.33, 0.30;  % arcene
%     0.10, 0.17, 0.14, 0.12;  % leukemia2
%     0.09, 0.19, 0.17, 0.19;  % 11Tumors
%     0.11, 0.12, 0.13, 0.12;  % SMK-CAN-187
%     0.04, 0.10, 0.11, 0.10;  % GLI-85
%     0.03, 0.07, 0.00, 0.07]; % Dorothea


%%% real world datasets and algorithms cosineknn
results =[0.03, 0.07, 0.07, 0.08;  % crx
    0.01, 0.30, 0.17, 0.16;  % sonar
    0.10, 0.12, 0.23, 0.06;  % optdigits (BAMB value corrected to 94)
    0.02, 0.05, 0.05, 0.05;  % coil2000
    0.20, 0.00, 0.00, 0.00;  % colon
    0.05, 0.32, 0.00, 0.39;  % lung
    0.01, 0.00, 0.00, 0.00;  % sido0
    0.22, 0.27, 0.23, 0.19;  % prostate-GE
    0.02, 0.31, 0.29, 0.35;  % arcene
    0.10, 0.17, 0.16, 0.15;  % leukemia2
    0.11, 0.21, 0.22, 0.21;  % 11Tumors
    0.12, 0.15, 0.19, 0.14;  % SMK-CAN-187
    0.05, 0.12, 0.12, 0.11;  % GLI-85
    0.07, 0.09, 0.00, 0.09]; % Dorothea
       

Names = {'T-OCD_{MB}', 'HITON-MB', 'STMB','BAMB'}; % names
OutputFolder  = 'D:\WaqarPhD\PhDYsu\MB_FeatureSelection_Work_submition_Code\SeventhPaper\MBHCode\Statistical test';                       % Output folder
Outname = 'NemenyiResults';                        % Output name
drawNemenyi(results, Names, OutputFolder, Outname);

