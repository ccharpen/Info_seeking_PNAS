clear
clc
close all

sub_list = ['01';'02';'03';'04';'05';'06';'09';'10';'11';'12';'13';'15';...
    '16';'17';'18';'20';'21';'22';'23';'24';'25';'26';'28';'29';'31';...
    '32';'33';'34';'35';'36';'37';'38';'39'];

%load data
%make sure to cd to the directory where the matlab data files are saved if necessary
load('BOLD_per_trial.mat','IPE_EV_recap')
%cell: each row = a subject; 
%each column = a block: columns 1 & 2 = gain blocks; columns 3 & 4 = loss blocks
%then columns within each matrix:
%1: P(win/lose)
%2: Knowledge cue delivered (1), Ignorance cue delivered (0)
%3: IPE (= Knowledge (1) or Ignorance (0) minus Expected Knowledge)
%4: IPE*P(win/lose)
%5: BOLD in VTA/SN ROI
%6: BOLD in NAc ROI
%7: BOLD in VTA/SN 'losses' ROI
%8: BOLD in NAc 'losses' ROI
%9: BOLD in mOFC functional cluster

[num,text,raw] = xlsread('fMRI_results_ROIs_May2018.xlsx');
num(isnan(num(:,1)),:) = [];

orange = [0.93 0.5 0.2]; %orange gain color for plots
magenta = [0.7 0 0.7]; %magenta color for plots
grey = [0.65 0.65 0.65];

%% Data for Fig 4A, B and D
%VD-IPE signal in VTA/SN ROI for each participant (Fig 4A)
VDIPE_signal_VTA = num(:,4);

%VD-IPE components in VTA/SN ROI (Fig 4B)
VDIPE_components_VTA = num(:,22:23);

%data for correlation with behavior (Fig 4D)
VDIPE_signal_NA = num(:,5);
behavior = num(:,46);

%data for small panel in Fig 4D
numb = xlsread('Behavioral_results_Expt1_May2018.xlsx');
is = numb(:,1)==24; %participant 24
data_sub24 = [[(-0.1:-0.1:-0.9)' ; (0.1:0.1:0.9)'] [numb(is,18:26)' ; numb(is,9:17)']];

%% Data for mixed model shown in Fig 4C
%BOLD in VTA/SN as a function of IPE, GainLoss and their interaction
Betas_recap_allsubs = [];
for i=1:length(sub_list)
    brec = [ones(length(IPE_EV_recap{i,1}),1) IPE_EV_recap{i,1}(:,[3 5]); ones(length(IPE_EV_recap{i,2}),1) IPE_EV_recap{i,2}(:,[3 5]); ...
        -ones(length(IPE_EV_recap{i,3}),1) IPE_EV_recap{i,3}(:,[3 5]); -ones(length(IPE_EV_recap{i,4}),1) IPE_EV_recap{i,4}(:,[3 5])];
    %column 1: Gain (1), Loss (-1)
    %column 2: IPE
    %column 3: BOLD in midbrain VTA/SN
    
    brec(:,4) = zscore(brec(:,3)); %zscore BOLD in VTA for each subject

    Betas_recap_allsubs = [Betas_recap_allsubs; ones(length(brec(:,1)),1)*str2num(sub_list(i,:)) brec];    
end
Rec_cell = num2cell(Betas_recap_allsubs(:,[1:3 5]));
for k=1:length(Rec_cell)
    if Rec_cell{k,2}==1
        Rec_cell{k,2}='G';
    else Rec_cell{k,2}='L';
    end
end
Data_allsubs1 = cell2table(Rec_cell, 'VariableNames',{'sub' 'GainLoss' 'IPE' 'BOLD_VTA'});

glme1 = fitglme(Data_allsubs1,'BOLD_VTA ~ 1 + GainLoss + IPE + GainLoss:IPE + (1|sub) + (-1+GainLoss|sub) + (-1+IPE|sub) + (-1+GainLoss:IPE|sub)',...
    'Distribution','Normal','Link','identity','FitMethod','Laplace','DummyVarCoding','effects');
%fixed effects reported in the text are detailed in glme1.Coefficients table

%calculate separate slope for gains and losses for figure
Betas_G_allsubs = Betas_recap_allsubs(Betas_recap_allsubs(:,2)==1,:);
Betas_L_allsubs = Betas_recap_allsubs(Betas_recap_allsubs(:,2)==-1,:);
bg = glmfit(Betas_G_allsubs(:,3),Betas_G_allsubs(:,5));
bl = glmfit(Betas_L_allsubs(:,3),Betas_L_allsubs(:,5));

%plot correlation with shaded SE
rec = Betas_G_allsubs(:,[3 5]);
rec = sortrows(rec,1);
rec2 = (-0.9:0.1:0.9)';
for k=1:length(rec2)
    ind = rec(:,1)>=rec2(k)-0.001 & rec(:,1)<=rec2(k)+0.001;
    rec2(k,2) = mean(rec(ind,2));
    rec2(k,3) = std(rec(ind,2))/sqrt(sum(ind));
end
xg = rec2(:,1);
yg = bg(1) + bg(2)*rec2(:,1);
seg = rec2(:,3); %standard error for plot below

rec = Betas_L_allsubs(:,[3 5]);
rec = sortrows(rec,1);
rec2 = (-0.9:0.1:0.9)'
for k=1:length(rec2)
    ind = rec(:,1)>=rec2(k)-0.001 & rec(:,1)<=rec2(k)+0.001;
    rec2(k,2) = mean(rec(ind,2));
    rec2(k,3) = std(rec(ind,2))/sqrt(sum(ind));
end
xl = rec2(:,1);
yl = bl(1) + bl(2)*rec2(:,1);
sel = rec2(:,3); %standard error for plot below

Lg = yg' - seg';
Ug = yg' + seg';
Xcg = [xg' xg(end:-1:1)'];
Ycg = [Ug Lg(end:-1:1)];
Ll = yl' - sel';
Ul = yl' + sel';
Xcl = [xl' xl(end:-1:1)'];
Ycl = [Ul Ll(end:-1:1)];

%% Plot Figure 4
figure('Position',[100,100,1000,600]); 
%Fig 4A
subplot(2,6,[1,2]); hold on;
bar(sort(VDIPE_signal_VTA),0.5,'FaceColor',grey)
xlim([0 34])
ylim([-0.8 0.6])
ax = gca;
ax.FontSize = 9;
ax.XTickLabel = [];
ax.XLabel.String = 'Participant';
ax.YLabel.String = {'Valence-dependent'; 'Information Prediction';'Error in VTA/SN'};
title('Fig. 4A')
%Fig 4B
subplot(2,6,[4,5]); hold on
bar(mean(VDIPE_components_VTA,1),0.5,'FaceColor',grey);
errorbar(mean(VDIPE_components_VTA,1),std(VDIPE_components_VTA,1)/sqrt(length(sub_list)),'k.','LineWidth',1)
ax = gca;
ax.FontSize = 9;
ax.XTick = [1 2];
ax.XTickLabel = {'Actual info*EV', 'Expected info*EV'};
ax.YLabel.String = {'Valence-dependent'; 'components in VTA/SN'};
ylim([-0.4 0.4])
xlim([0.5 2.5])
title('Fig. 4B')
%Fig 4C
subplot(2,6,[7,8]); hold on
col2 = magenta;
col2(find(magenta<1)) = col2(find(magenta<1))+ 0.8*[1-magenta(find(magenta<1))]; %adds noise for shaded SE
Pa = patch(Xcl,Ycl,col2);
set(Pa,'linestyle','none','linewidth',2);
Li = plot(xl,yl,'color',magenta,'linewidth',2,'LineStyle','-');
alpha(0.5)
col2 = orange;
col2(find(orange<1)) = col2(find(orange<1))+ 0.8*[1-orange(find(orange<1))]; %adds noise for shaded SE
Pa = patch(Xcg,Ycg,col2);
set(Pa,'linestyle','none','linewidth',2);
Li = plot(xg,yg,'color',orange,'linewidth',2,'LineStyle','-');
alpha(0.5)
ylim([-0.4 0.4])
ax = gca;
ax.FontSize = 9;
xlabel('Information Prediction Error')
ylabel('BOLD in VTA/SN')
title('Fig. 4C')
%Fig 4D
subplot(2,6,[10,11]); hold on
plot([-0.3 0.7],[0 0],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot([0 0],[-0.3 0.6],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot(behavior, VDIPE_signal_NA, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
xlim([-0.3 0.7])
ylim([-0.3 0.6])
lin_fit = glmfit(behavior, VDIPE_signal_NA);
plot([min(behavior) max(behavior)], [lin_fit(1)+lin_fit(2)*min(behavior) lin_fit(1)+lin_fit(2)*max(behavior)], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Valence-dependent information choice')
ax.YLabel.String = {'Valence-dependent Information'; 'Prediction Error in NAc'};
title('Fig. 4D')
%Fig 4D Panel
subplot('Position',[0.82,0.2,0.15,0.2]); hold on
plot(data_sub24(1:9,1),data_sub24(1:9,2), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',magenta, 'MarkerEdgeColor',magenta, 'MarkerSize',3)
plot(data_sub24(10:18,1),data_sub24(10:18,2), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',orange, 'MarkerEdgeColor',orange, 'MarkerSize',3)
plot([0 0],[0,1],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
lin_fit = glmfit(data_sub24(:,1), data_sub24(:,2));
plot([-0.9 0.9], [lin_fit(1)+lin_fit(2)*-0.9 lin_fit(1)+lin_fit(2)*0.9], '--', 'Color','k')
ax = gca;
ax.FontSize = 7;
xlabel('EV')
ylabel('Information choice')
title('Participant 24')


%% Plot Figure S5
VDIPE_Comp1 = num(:,24); %first component of VD-IPE in NAc
VDIPE_Comp2 = num(:,25); %second component of VD-IPE in NAc
RPE = num(:,11); %RPE signal in NAc

figure('Position',[100,100,800,600]); 
%Figure S5A
subplot(2,2,1); hold on
plot([-0.3 0.7],[0 0],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot([0 0],[-0.6 1.2],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot(behavior, VDIPE_Comp1, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
xlim([-0.3 0.7])
ylim([-0.6 1.2])
lin_fit = glmfit(behavior, VDIPE_Comp1);
plot([min(behavior) max(behavior)], [lin_fit(1)+lin_fit(2)*min(behavior) lin_fit(1)+lin_fit(2)*max(behavior)], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Valence-dependent information choice')
ylabel('Actual knowledge*EV in NAc');
title('Fig. S5A')
%Figure S5B
subplot(2,2,2); hold on
plot([-0.3 0.7],[0 0],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot([0 0],[-2 1],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot(behavior, VDIPE_Comp2, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
xlim([-0.3 0.7])
ylim([-2 1])
lin_fit = glmfit(behavior, VDIPE_Comp2);
plot([min(behavior) max(behavior)], [lin_fit(1)+lin_fit(2)*min(behavior) lin_fit(1)+lin_fit(2)*max(behavior)], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Valence-dependent information choice')
ylabel('Expected knowledge*EV in NAc');
title('Fig. S5B')
%Figure S5C
subplot(2,2,3); hold on
bar(sort(RPE),0.5,'FaceColor',grey)
xlim([0 34])
ylim([-0.6 1])
ax = gca;
ax.FontSize = 9;
ax.XTickLabel = [];
ax.XLabel.String = 'Participant';
ax.YLabel.String = 'Reward Prediction Error in NAc';
title('Fig. S5C')
%Figure S5D
subplot(2,2,4); hold on
plot([-0.3 0.7],[0 0],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot([0 0],[-0.6 1],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot(behavior, RPE, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
xlim([-0.3 0.7])
ylim([-0.6 1])
lin_fit = glmfit(behavior, RPE);
plot([min(behavior) max(behavior)], [lin_fit(1)+lin_fit(2)*min(behavior) lin_fit(1)+lin_fit(2)*max(behavior)], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Valence-dependent information choice')
ylabel('Reward Prediction Error in NAc');
title('Fig. S5D')

%% Plot Figure S6B
VDIPE_SN_atlas = num(:,43); %VD-IPE signal in SN anatomical ROI from atlas (Murty et al, 2014)
VDIPE_VTA_atlas = num(:,44); %VD-IPE signal in VTA anatomical ROI from atlas (Murty et al, 2014)

figure();
bar(1,mean(VDIPE_signal_VTA),0.7,'FaceColor','r'); hold on
bar(2,mean(VDIPE_SN_atlas),0.7,'FaceColor','b');
bar(3,mean(VDIPE_VTA_atlas),0.7,'FaceColor','g');
errorbar([1,2,3],[mean(VDIPE_signal_VTA),mean(VDIPE_SN_atlas),mean(VDIPE_VTA_atlas)],[std(VDIPE_signal_VTA),std(VDIPE_SN_atlas),std(VDIPE_VTA_atlas)]/sqrt(length(sub_list)),'k.')
ax = gca;
ax.FontSize = 10;
ax.XTick = [1 2 3];
ax.XTickLabel = {'Neurosynth VTA/SN' 'SN (atlas)' 'VTA (atlas)'};
ax.YLabel.String = {'Valence-Dependent Information'; 'Prediction Error signal'};
xlim([0.2 3.8])
ylim([0 0.18])
title('Fig S6B')

%% Extract correlations between regressors (EV, IPE, VD-IPE) for each subject
correlations = zeros(length(sub_list),3);
for i=1:length(sub_list)
    %for each subject, build a matrix with the following columns (each row
    %is a trial): EV, IPE, VD-IPE
    recap = [IPE_EV_recap{i,1}(:,[1 3]);IPE_EV_recap{i,2}(:,[1 3]); ...
        [-IPE_EV_recap{i,3}(:,1) IPE_EV_recap{i,3}(:,3)]; ...
        [-IPE_EV_recap{i,4}(:,1) IPE_EV_recap{i,4}(:,3)]]; %first column is EV, second column is IPE
    recap(:,3) = recap(:,1).*recap(:,2); %VD-IPE
    corr_mat = corr(recap); %correlation matrix
    correlations(i,:) = [corr_mat(1,3) corr_mat(1,2) corr_mat(2,3)];
    %column 1: correlation between EV and VD-IPE
    %column 2: correlation between EV and IPE
    %column 3: correlation between IPE and VD-IPE
end  