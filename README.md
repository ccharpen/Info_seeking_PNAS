# Info_seeking_PNAS
Data and Code from manuscript: 'Valuation of Knowledge and Ignorance in Mesolimbic Reward Circuitry', Caroline J. Charpentier, Ethan S. Bromberg-Martin & Tali Sharot (in press) PNAS

## Description of data files
All .mat files described below contain 2 variables: a column_description variable describing the contents of each column in the main data variable, and the main data variable which contains the data of all subjects collapsed together and where each row is a trial.

### Matlab data files (.mat)

- Data_main_task.mat

Contains the behavioral data from the lottery & information choice task (Experiment 1) used concommitantly with fMRI (N=36 subjects, 120 trials per subject).

- Data_ratings.mat

Contains the behavioral data from the follow-up rating task collected outside the scanner (N=36 subjects, 36 trials per subject).

- Data_replication.mat

Contains the behavioral data from the lottery & information choice task replication sample (N=26 subjects)

- Data_market_task.mat

Contains the behavioral data from the stock market task (Experiment 2) (N=42 subjects, 200 trials per subject)

- BOLD_per_trial.mat

Contains the data used in the trial by trial BOLD models reported in the paper. This is a cell structure where each row is a subject, each column is a block (columns 1 & 2 = gain blocks, columns 3 & 4 = loss blocks). Then within each cell, the columns are as follows: P(win/lose), Knowledge (1) or Ignorance (0) cue delivered, IPE, IPE x P(win/lose), BOLD in VTA/SN ROI, BOLD in NAc ROI, BOLD in VTA/SN 'losses' ROI, BOLD in NAc 'losses' ROI, BOLD in mOFC functional cluster. The BOLD signal is extracted from the different ROI during presentation of the knowledge/ignorance cue.

### Excel files
Excel files contains the mean data for each subjects (i.e., each row represents a subjects) and can be used for statistics (calculation of means, standard errors, t-tests, ANOVAs, etc)

- Behavioral_results_Expt1_May2018.xlsx

Contains mean data from Experiment 1 and its replication in an independent sample. There are 3 spreadsheets: the main behavioral data, the temporal data reported in the SI Appendix (Fig. S4) and the replication data.

- Behavioral_results_Expt2_May2018.xlsx

Contains mean data from Experiment 2.

- fMRI_results_ROIs_May2018.xlsx

Contains individual betas extracted from regions of interests. Row 1 shows which SPM GLM was used, row 2 at what time of the task the BOLD response was extracted, and row 3 shows which contrast and which ROI.

## Analysis of Behavioral Data from Experiment 1 (lottery & information choice task)
Run Behavior_analysis_Expt1.m

Inputs = Data_main_task.mat, Data_ratings.mat, Data_replication.mat (make sure these files are saved in the same directory as the script)

Outputs = analysis of choice and ratings data (Figure 2), analysis of replication data (Figure S2), general linear mixed-effect models predicting information choice (Table S1 and Figure S3), control analysis testing for Pavlovian conditioning (Figure S4)

## Analysis of Behavioral Data from Experiment 2 (stock market task)
Run Behavior_analysis_Expt2.m

Input = Data_market_task.mat (make sure these files are saved in the same directory as the script)

Ouputs = extract necessary data, run general linear mixed-effect model and plot Figure 6

## Analysis of ROI fMRI data from Experiment 1
Run fMRI_results_Expt1.m

Inputs = fMRI_results_ROIs_May2018.xlsx, BOLD_per_trial.mat (make sure these files are saved in the same directory as the script)

Outputs = run general linear mixed-effect model using BOLD trial-by-trial data, plot Figure 4, Figure S5, Figure S6B, and extract correlation between fMRI regressors (EV, IPE, and VD-IPE) 
