# T-OCDMB — Code, Data, and Reproducibility Documentation

Article: "Triplet offline causal discovery based on optimal Markov blanket and
its application.

This document describes the software and data accompanying the article: how the
package is organised, how to run each component, the parameters used, the data
sources.



## 1\. Environment

* MATLAB R2021a.
* Statistics and Machine Learning Toolbox
* Operating system: Windows 11.



## 2\. Package layout



Causal\_Learner.m



TOCDmb/
TOCDmb\_G2.m  
TOCDmb\_Z.m  
common/  
my\_g2\_test.m  
my\_fisherz\_test.m  
subsets1.m, mysetdiff.m, myunion.m, STA.m, ...
evaluation/
evaluation\_MB.m    
run\_TOCDmb\_tables.m  
run\_TOCDmb\_single.m    
data/



## 3\. How to run

### 3.1 Benchmark Bayesian networks (Tables 4-7, discrete, G2 test)

From the package root in MATLAB:

matlab
addpath(genpath(pwd));
run\_TOCDmb\_tables          % all benchmark networks, both sample sizes (but it takes time around few days to run whole Benchmark Bayesian networks)



or one network at a time:

matlab
run\_TOCDmb\_single          % edit data\_name, sample\_size, which\_v at the top



Direct single-target call:

matlab
data = importdata('data/insurance\_data/Insurance\_s500\_v1.txt') + 1; % values start at 1
\[MB, nTests, t] = Causal\_Learner('TOCDmb', data, 'dis', 0.01, 5);   % target = 5



Example sitting Parameter values for: alpha = 0.01, maxK = 3, G2 test, 10 dataset (for details configuration referred to the paper)
Set sample sizes according to the Benchmark Bayesian networks, it produce averaged evaluation metrics.



For statistical test (Friedman and Neyamani), we used the error rate of precision and recall for detail refer to the paper.

For these tests I used "drawNemenyi" https://github.com/sepehrband/drawNemenyi

Download the source code from drawNemenyi and create/update demo.m file inside the library and provide the error rate as an input. This file has already been created inside TOCDMB\_Recall\_Corrected/statistical test. Update the demo.m with this file.





### 3.2 Real-world feature selection (Table 9, continuous, Fisher z test)

Load the dataset into the workspace, identify the class-label column, then:

matlab
addpath(genpath(pwd));
load('data/arcene.mat');                 % example
X = arcene;
target = <label column index>;  
\[feats, t] = TOCDmb\_FS(X, target, 0.01, 'z');





## 5\. Data sources

###### The following datasets are used in the article:

###### **.**   https://pages.mtu.edu/\~lebrown/supplements/mmhc\_paper/mmhc\_index.html

* UCI Machine Learning Repository: http://archive.ics.uci.edu/ml
* ASU feature-selection repository: https://jundongl.github.io/scikit-feature/
* https://www.csie.ntu.edu.tw/\~cjlin/libsvmtools/datasets/



## 

