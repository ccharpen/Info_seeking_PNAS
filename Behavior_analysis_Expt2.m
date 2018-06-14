clear all
close all
clc

sub_list = [21;22;23;24;25;32;33;34;35;36;38;39;40;41;42;43;46;47;48;49;50;...
    51;52;53;54;55;56;57;58;59;60;61;62;63;64;65;66;67;69;70;71;72];

%load data
%make sure to cd to the directory where the matlab data files are saved if necessary
load('Data_market_task.mat') 

grey = [0.65 0.65 0.65];

%% Data for Figure 6

%Figure 6B: example subject
example_sub = 63;
isub = data_allsubs(:,1) == example_sub;
dsub = data_allsubs(isub,:);
%extract variables of interest
swtp = dsub(:,9); %signed willingness to pay
smc = dsub(:,4); %signed market change

%Figure 6C: run mixed effect model on entire dataset
data_allsubs_zc = [data_allsubs(:,[1 7 9]) zscore(data_allsubs(:,4)) zscore(data_allsubs(:,5)) ...
    zscore(data_allsubs(:,15)) zscore(data_allsubs(:,12)) zscore(data_allsubs(:,2)) zscore(data_allsubs(:,16))];
%variables of interest for regression model:
%1: subject number
%2: choice
%3: signed WTP
%4: signed market change
%5: absolute market change
%6: known portfolio value
%7: number of trials since last info
%8: time (trial number)
%9: cursor position

data_allsubs_zc(isnan(data_allsubs_zc(:,2)),:)=[]; %remove missed trials

Data_tbl_zc = array2table(data_allsubs_zc, 'VariableNames',{'sub' 'choice' 'valWTP' 'sMC' 'aMC' 'PV' 'NLI' 'T' 'CP'});

%Model - wtp: fixed & random effects of each predictor + fixed & random intercepts
warning('off')
glme = fitglme(Data_tbl_zc,'valWTP ~ 1 + sMC + aMC + PV + NLI + T + CP + (1|sub) + (-1+sMC|sub) + (-1+aMC|sub) + (-1+PV|sub) + (-1+NLI|sub) + (-1+T|sub) + (-1+CP|sub)',...
    'Distribution','Normal','Link','identity','FitMethod','Laplace','DummyVarCoding','effects');
%note: the stats for all fixed effects are in glme.Coefficients table

%Figure 6D: extract random effects from the model
[Rand_eff,Rnames,Rstats] = randomEffects(glme); %random effect coefficient estimates
ind_smc = find(strcmp(Rnames.Name,'sMC')); %extract indices for signed market change effect
beta_smc = Rand_eff(ind_smc) + double(glme.Coefficients(2,2)); %add fixed effect to get value of sMC effect for each individual

%Figure 6E
total_WTP = zeros(length(sub_list),6);
for i=1:length(sub_list)
    isub = data_allsubs(:,1)==sub_list(i); %extract choice rows for subject i
    dsub = data_allsubs(isub,:); %data for subject i
    dsub(isnan(dsub(:,6)),:)=[]; %remove missed trials
    up = dsub(:,4)>0; %trials where market went up
    down = dsub(:,4)<0; %trials where market went down
    receive = dsub(:,6)>0; %trials where subject chooses info
    avoid = dsub(:,6)<0; %trials where subject avoids info
    total_WTP(i,1:4) = [sum(dsub(up & receive,8)) sum(dsub(down & receive,8)) sum(dsub(up & avoid,8)) sum(dsub(down & avoid,8))];
    total_WTP(i,5) = total_WTP(i,1) - total_WTP(i,2);
    total_WTP(i,6) = total_WTP(i,3) - total_WTP(i,4);
end

%% Now plot the whole figure
figure('Position',[100,100,1000,750]); 
%Figure 6B
subplot(2,2,1); hold on
plot([-20 20],[0 0],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot([0 0],[-30 30],'-','Color',[0.7 0.7 0.7],'LineWidth',0.5)
plot(smc, swtp, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
lin_fit = glmfit(smc, swtp);
plot([min(smc) max(smc)], [lin_fit(1)+lin_fit(2)*min(smc) lin_fit(1)+lin_fit(2)*max(smc)], '--', 'Color','k','LineWidth',1.5)
xlim([-20 20])
ylim([-30 30])
ax = gca;
ax.FontSize = 9;
xlabel('Market change')
ylabel('Signed WTP (in pence)')
title('Fig 6B')
%Figure 6C
subplot(2,2,2); hold on
bar(double(glme.Coefficients(2:3,2)),0.5,'FaceColor',grey);
errorbar(double(glme.Coefficients(2:3,2)),double(glme.Coefficients(2:3,3)),'k.','LineWidth',1)
ax = gca;
ax.FontSize = 9;
ax.XTick = [1 2];
ax.XTickLabel = {'Signed', 'Absolute'};
xlabel('Market Change')
ylabel('Effect on Signed WTP')
title('Fig. 6C')
%Figure 6D
subplot(2,2,3); hold on
bar(sort(beta_smc),0.5,'FaceColor',grey)
xlim([0 43])
ax = gca;
ax.FontSize = 9;
ax.XTickLabel = [];
ax.XLabel.String = 'Participant';
ax.YLabel.String = {'Effect of signed market'; 'change on signed WTP'};
title('Fig 6D')
%Figure 6E
subplot(2,2,4); hold on
bar(mean(total_WTP(:,5:6),1)/100,0.5,'FaceColor',grey); hold on
errorbar(mean(total_WTP(:,5:6),1)/100,std(total_WTP(:,5:6)/100,1)/sqrt(length(sub_list)),'k.','LineWidth',1)
ax = gca;
ax.FontSize = 9;
ax.XTick = [1 2];
ax.XTickLabel = {'Receive knowledge', 'Remain ignorant'};
ax.YLabel.String = {'Difference in total WTP'; '(£ Market UP - DOWN)'};
ylim([-2 2.5])
title('Fig. 6D')