clear all
close all
clc

sub_list = ['01';'02';'03';'04';'05';'06';'09';'10';'11';'12';'13';'14';'15';...
    '16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'31';...
    '32';'33';'34';'35';'36';'37';'38';'39'];
subnb_list = [1;2;3;4;5;6;9;10;11;12;13;14;15;16;17;18;19;20;21;22;...
    23;24;25;26;27;28;29;31;32;33;34;35;36;37;38;39];

%load data
%make sure to cd to the directory where the matlab data files are saved if necessary
load('Data_main_task.mat','Data_allsubs') %fmri task data
load('Data_ratings.mat','Data_allsubs_r') %ratings data from follow up task after fmri

probas = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]; %list of probabilities used in the lotteries
orange = [0.93 0.5 0.2]; %orange gain color for plots
magenta = [0.7 0 0.7]; %magenta color for plots
grey = [0.65 0.65 0.65];

%% Analysis #1: choice and ratings data (Fig 2)
Choice_GL = zeros(length(subnb_list),2); %for Fig 2A data
Choice_GainP = zeros(length(subnb_list),9); %for Fig 2C data
Choice_LossP = zeros(length(subnb_list),9); %for Fig 2C data
Rating_GL = zeros(length(subnb_list),2); %for Fig 2B data
Rating_GainP = zeros(length(subnb_list),9); %for Fig 2D data
Rating_LossP = zeros(length(subnb_list),9); %for Fig 2D data
Beta_EV_Choice = zeros(length(subnb_list),1); %for Fig 2E data
Uncertainty_GainP = zeros(length(subnb_list),9); %for Fig 2F data
Uncertainty_LossP = zeros(length(subnb_list),9); %for Fig 2F data

for i=1:length(subnb_list)
    isub = Data_allsubs(:,1)==subnb_list(i); %extract choice rows for subject i
    dsub = Data_allsubs(isub,:); %data for subject i
    dsub(isnan(dsub(:,11)),:)=[]; %remove missed trials
    i_g = dsub(:,3)==1; %gain trials
    i_l = dsub(:,3)==0; %loss trials
    Choice_GL(i,:) = [mean(dsub(i_g,9)) mean(dsub(i_l,9))];

    for k=1:length(probas)
        p = probas(k);
        ip = dsub(:,6)<=p+0.01 & dsub(:,6)>=p-0.01; %select trials where probability p was used
        Choice_GainP(i,k) = mean(dsub(i_g & ip,9));
        Choice_LossP(i,k) = mean(dsub(i_l & ip,9));
        Uncertainty_GainP(i,k) = mean(dsub(i_g & ip,16));
        Uncertainty_LossP(i,k) = mean(dsub(i_l & ip,16));
    end

    %calculate slope between EV and information choice
    dEV = [(0.1:0.1:0.9)' Choice_GainP(i,:)' ; (-0.1:-0.1:-0.9)' Choice_LossP(i,:)']; %matrix with EV in column 1 and info choice in column 2
    b = glmfit(dEV(:,1),dEV(:,2));
    Beta_EV_Choice(i) = b(2);

    isubr = Data_allsubs_r(:,1)==subnb_list(i); %extract rating rows for subject i
    dsubr = Data_allsubs_r(isubr,:); %data for subject i
    i_g = dsubr(:,3)==1; %gain trials
    i_l = dsubr(:,3)==0; %loss trials
    Rating_GL(i,:) = [mean(dsubr(i_g,6)) mean(dsubr(i_l,6))];
    
    for k=1:length(probas)
        p = probas(k);
        ip = dsubr(:,5)<=p+0.01 & dsubr(:,5)>=p-0.01; %select trials where probability p was used
        Rating_GainP(i,k) = mean(dsubr(i_g & ip,6));
        Rating_LossP(i,k) = mean(dsubr(i_l & ip,6));
    end
end

%calculate best quadratic fits for plots
dcG = [(0.1:0.1:0.9)' (0.1:0.1:0.9)'.^2 mean(Choice_GainP,1)'];
b = glmfit(dcG(:,1:2),dcG(:,3));
gdcG = [(0.1:0.01:0.9)' (0.1:0.01:0.9)'.^2]; %generate data for plotting trendline
gdcG(:,3) = b(1) + b(2)*gdcG(:,1) + b(3)*gdcG(:,2);

dcL = [(0.1:0.1:0.9)' (0.1:0.1:0.9)'.^2 mean(Choice_LossP,1)'];
b = glmfit(dcL(:,1:2),dcL(:,3));
gdcL = [(0.1:0.01:0.9)' (0.1:0.01:0.9)'.^2]; %generate data for plotting trendline
gdcL(:,3) = b(1) + b(2)*gdcL(:,1) + b(3)*gdcL(:,2);

drG = [(0.1:0.1:0.9)' (0.1:0.1:0.9)'.^2 mean(Rating_GainP,1)'];
b = glmfit(drG(:,1:2),drG(:,3));
gdrG = [(0.1:0.01:0.9)' (0.1:0.01:0.9)'.^2]; %generate data for plotting trendline
gdrG(:,3) = b(1) + b(2)*gdrG(:,1) + b(3)*gdrG(:,2);

drL = [(0.1:0.1:0.9)' (0.1:0.1:0.9)'.^2 mean(Rating_LossP,1)'];
b = glmfit(drL(:,1:2),drL(:,3));
gdrL = [(0.1:0.01:0.9)' (0.1:0.01:0.9)'.^2]; %generate data for plotting trendline
gdrL(:,3) = b(1) + b(2)*gdrL(:,1) + b(3)*gdrL(:,2);


%Plot Figure 2
figure('Position',[500,100,1100,1150]); 
%Fig 2A
subplot(3,2,1); hold on
bar(1,mean(Choice_GL(:,1)),0.7,'FaceColor',orange);
bar(2,mean(Choice_GL(:,2)),0.7,'FaceColor',magenta);
errorbar([1,2],[mean(Choice_GL,1)],[std(Choice_GL,1)/sqrt(length(subnb_list))],'k.')
plot([0 3],[0.5 0.5],'--k')
ax = gca;
ax.FontSize = 9;
ax.XTick = [1 2];
ax.XTickLabel = {'Gain' 'Loss'};
ax.YLabel.String = {'Choice of most'; 'informative offer'};
title('Fig 2A')
%Fig 2B
subplot(3,2,2); hold on
plot(probas, mean(Choice_GainP,1), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',orange, 'MarkerEdgeColor',orange, 'MarkerSize',3)
plot(probas, mean(Choice_LossP,1), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',magenta, 'MarkerEdgeColor',magenta, 'MarkerSize',3)
errorbar(probas, mean(Choice_GainP,1), std(Choice_GainP,1)/sqrt(length(subnb_list)),'.', 'MarkerFaceColor',orange, 'Color',orange)
errorbar(probas, mean(Choice_LossP,1), std(Choice_LossP,1)/sqrt(length(subnb_list)),'.', 'MarkerFaceColor',magenta, 'Color',magenta)
plot(gdcG(:,1), gdcG(:,3), '--', 'Color',orange)
plot(gdcL(:,1), gdcL(:,3), '--', 'Color',magenta)
ylim([0.5 1])
ax = gca;
ax.FontSize = 9;
ax.YLabel.String = {'Choice of most'; 'informative offer'};
ax.XLabel.String = 'Probability of Gain/Loss';
title('Fig 2B')
%Fig 2C
subplot(3,2,3); hold on
bar(1,mean(Rating_GL(:,1)),0.7,'FaceColor',orange);
bar(2,mean(Rating_GL(:,2)),0.7,'FaceColor',magenta);
errorbar([1,2],[mean(Rating_GL,1)],[std(Rating_GL,1)/sqrt(length(subnb_list))],'k.')
xlim([0 3])
ax = gca;
ax.FontSize = 9;
ax.XTick = [1 2];
ax.XTickLabel = {'Gain' 'Loss'};
ax.YLabel.String = {'Rating'; '(desire to know)'};
title('Fig 2C')
%Fig 2D
subplot(3,2,4); hold on
plot(probas, mean(Rating_GainP,1), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',orange, 'MarkerEdgeColor',orange, 'MarkerSize',3)
plot(probas, mean(Rating_LossP,1), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',magenta, 'MarkerEdgeColor',magenta, 'MarkerSize',3)
errorbar(probas, mean(Rating_GainP,1), std(Rating_GainP,1)/sqrt(length(subnb_list)),'.', 'MarkerFaceColor',orange, 'Color',orange)
errorbar(probas, mean(Rating_LossP,1), std(Rating_LossP,1)/sqrt(length(subnb_list)),'.', 'MarkerFaceColor',magenta, 'Color',magenta)
plot(gdrG(:,1), gdrG(:,3), '--', 'Color',orange)
plot(gdrL(:,1), gdrL(:,3), '--', 'Color',magenta)
ax = gca;
ax.FontSize = 9;
ax.YLabel.String = {'Rating'; '(desire to know)'};
ax.XLabel.String = 'Probability of Gain/Loss';
title('Fig 2D')
%Fig 2E
subplot(3,2,5); hold on
bar(sort(Beta_EV_Choice),0.5,'FaceColor',grey)
xlim([0 37])
ax = gca;
ax.FontSize = 9;
ax.XTickLabel = [];
ax.XLabel.String = 'Participant';
ax.YLabel.String = {'Valence-dependent bias'; 'in information choice'};
title('Fig 2E')
%Fig 2F
subplot(3,2,6); hold on
plot(probas, mean(Uncertainty_GainP,1), 'LineStyle','-', 'Color',orange, 'Marker','o', 'MarkerFaceColor',orange, 'MarkerEdgeColor',orange, 'MarkerSize',3)
plot(probas, mean(Uncertainty_LossP,1), 'LineStyle','-', 'Color',magenta, 'Marker','o', 'MarkerFaceColor',magenta, 'MarkerEdgeColor',magenta, 'MarkerSize',3)
errorbar(probas, mean(Uncertainty_GainP,1), std(Uncertainty_GainP,1)/sqrt(length(subnb_list)),'.', 'MarkerFaceColor',orange, 'Color',orange)
errorbar(probas, mean(Uncertainty_LossP,1), std(Uncertainty_LossP,1)/sqrt(length(subnb_list)),'.', 'MarkerFaceColor',magenta, 'Color',magenta)
ylim([0.05 0.25])
ax = gca;
ax.FontSize = 9;
ax.XLabel.String = 'Probability of Gain/Loss';
ax.YLabel.String = {'Uncertainty over'; 'outcome'};
title('Fig 2F')

%% Analysis #2: choice and ratings data from replication study (Fig S2)

sub_list_p = [101;102;103;104;105;106;107;108;109;110;...
    201;202;203;204;205;206;207;208;209;210;...
    301;302;303;304;305;306];

%load data
%make sure to cd to the directory where the matlab data files are saved if necessary
load('Data_replication.mat','Data_allsubs_p') %fmri task data

Choice_GL_p = zeros(length(sub_list_p),2); %for Fig 2A data
Choice_GainP_p = zeros(length(sub_list_p),9); %for Fig 2C data
Choice_LossP_p = zeros(length(sub_list_p),9); %for Fig 2C data
Beta_EV_Choice_p = zeros(length(sub_list_p),1); %for Fig 2E data
Uncertainty_GainP_p = zeros(length(sub_list_p),9); %for Fig 2F data
Uncertainty_LossP_p = zeros(length(sub_list_p),9); %for Fig 2F data

for i=1:length(sub_list_p)
    isub = Data_allsubs_p(:,1)==sub_list_p(i); %extract choice rows for subject i
    dsub = Data_allsubs_p(isub,:); %data for subject i
    dsub(isnan(dsub(:,11)),:)=[]; %remove missed trials
    i_g = dsub(:,3)==1; %gain trials
    i_l = dsub(:,3)==0; %loss trials
    Choice_GL_p(i,:) = [mean(dsub(i_g,9)) mean(dsub(i_l,9))];

    for k=1:length(probas)
        p = probas(k);
        ip = dsub(:,6)<=p+0.01 & dsub(:,6)>=p-0.01; %select trials where probability p was used
        Choice_GainP_p(i,k) = mean(dsub(i_g & ip,9));
        Choice_LossP_p(i,k) = mean(dsub(i_l & ip,9));
        Uncertainty_GainP_p(i,k) = mean(dsub(i_g & ip,16));
        Uncertainty_LossP_p(i,k) = mean(dsub(i_l & ip,16));
    end

    %calculate slope between EV and information choice
    dEV = [(0.1:0.1:0.9)' Choice_GainP_p(i,:)' ; (-0.1:-0.1:-0.9)' Choice_LossP_p(i,:)']; %matrix with EV in column 1 and info choice in column 2
    b = glmfit(dEV(:,1),dEV(:,2));
    Beta_EV_Choice_p(i) = b(2);

end

%calculate best quadratic fits for plots
dcG_p = [(0.1:0.1:0.9)' (0.1:0.1:0.9)'.^2 mean(Choice_GainP_p,1)'];
b = glmfit(dcG_p(:,1:2),dcG_p(:,3));
gdcG_p = [(0.1:0.01:0.9)' (0.1:0.01:0.9)'.^2]; %generate data for plotting trendline
gdcG_p(:,3) = b(1) + b(2)*gdcG_p(:,1) + b(3)*gdcG_p(:,2);

dcL_p = [(0.1:0.1:0.9)' (0.1:0.1:0.9)'.^2 mean(Choice_LossP_p,1)'];
b = glmfit(dcL_p(:,1:2),dcL_p(:,3));
gdcL_p = [(0.1:0.01:0.9)' (0.1:0.01:0.9)'.^2]; %generate data for plotting trendline
gdcL_p(:,3) = b(1) + b(2)*gdcL_p(:,1) + b(3)*gdcL_p(:,2);


%Plot Figure S2
figure('Position',[500,400,1100,800]); 
%Fig S2A
subplot(2,2,1); hold on
bar(1,mean(Choice_GL_p(:,1)),0.7,'FaceColor',orange);
bar(2,mean(Choice_GL_p(:,2)),0.7,'FaceColor',magenta);
errorbar([1,2],[mean(Choice_GL_p,1)],[std(Choice_GL_p,1)/sqrt(length(sub_list_p))],'k.')
plot([0 3],[0.5 0.5],'--k')
ax = gca;
ax.FontSize = 9;
ax.XTick = [1 2];
ax.XTickLabel = {'Gain' 'Loss'};
ax.YLabel.String = {'Choice of most'; 'informative offer'};
title('Fig S2A')
%Fig S2B
subplot(2,2,2); hold on
plot(probas, mean(Choice_GainP_p,1), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',orange, 'MarkerEdgeColor',orange, 'MarkerSize',3)
plot(probas, mean(Choice_LossP_p,1), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',magenta, 'MarkerEdgeColor',magenta, 'MarkerSize',3)
errorbar(probas, mean(Choice_GainP_p,1), std(Choice_GainP_p,1)/sqrt(length(sub_list_p)),'.', 'MarkerFaceColor',orange, 'Color',orange)
errorbar(probas, mean(Choice_LossP_p,1), std(Choice_LossP_p,1)/sqrt(length(sub_list_p)),'.', 'MarkerFaceColor',magenta, 'Color',magenta)
plot(gdcG_p(:,1), gdcG_p(:,3), '--', 'Color',orange)
plot(gdcL_p(:,1), gdcL_p(:,3), '--', 'Color',magenta)
ylim([0.4 1])
ax = gca;
ax.FontSize = 9;
ax.YLabel.String = {'Choice of most'; 'informative offer'};
ax.XLabel.String = 'Probability of Gain/Loss';
title('Fig S2B')
%Fig S2C
subplot(2,2,3); hold on
bar(sort(Beta_EV_Choice_p),0.5,'FaceColor',grey)
xlim([0 27])
ax = gca;
ax.FontSize = 9;
ax.XTickLabel = [];
ax.XLabel.String = 'Participant';
ax.YLabel.String = {'Valence-dependent bias'; 'in information choice'};
title('Fig S2C')
%Fig S2D
subplot(2,2,4); hold on
plot(probas, mean(Uncertainty_GainP_p,1), 'LineStyle','-', 'Color',orange, 'Marker','o', 'MarkerFaceColor',orange, 'MarkerEdgeColor',orange, 'MarkerSize',3)
plot(probas, mean(Uncertainty_LossP_p,1), 'LineStyle','-', 'Color',magenta, 'Marker','o', 'MarkerFaceColor',magenta, 'MarkerEdgeColor',magenta, 'MarkerSize',3)
errorbar(probas, mean(Uncertainty_GainP_p,1), std(Uncertainty_GainP_p,1)/sqrt(length(sub_list_p)),'.', 'MarkerFaceColor',orange, 'Color',orange)
errorbar(probas, mean(Uncertainty_LossP_p,1), std(Uncertainty_LossP_p,1)/sqrt(length(sub_list_p)),'.', 'MarkerFaceColor',magenta, 'Color',magenta)
ylim([0.05 0.25])
ax = gca;
ax.FontSize = 9;
ax.XLabel.String = 'Probability of Gain/Loss';
ax.YLabel.String = {'Uncertainty over'; 'outcome'};
title('Fig S2D')


%% Analysis #3: GLMEM predicting choice from EV and uncertainty (Table S1 and Fig. S3)

Data_for_GLMEM = [Data_allsubs(:,[1 9]) zscore(Data_allsubs(:,17)) zscore(Data_allsubs(:,13)) zscore(Data_allsubs(:,15))];
Data_for_GLMEM(isnan(Data_for_GLMEM(:,2)),:) = []; %remove missed trials
Data_tbl = array2table(Data_for_GLMEM, 'VariableNames',{'subject' 'choice' 'p_inf_diff' 'EV' 'uncertainty'});

%Model 1: full model
glme1 = fitglme(Data_tbl,'choice ~ 1 + p_inf_diff + EV + uncertainty + (1|subject) + (-1+p_inf_diff|subject) + (-1+EV|subject) + (-1+uncertainty|subject)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace','DummyVarCoding','effects');

%Model 2: only EV
glme2 = fitglme(Data_tbl,'choice ~ 1 + EV + (1|subject) + (-1+EV|subject)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace','DummyVarCoding','effects');

%Model 3: only Uncertainty
glme3 = fitglme(Data_tbl,'choice ~ 1 + uncertainty + (1|subject) + (-1+uncertainty|subject)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace','DummyVarCoding','effects');

%Model 4: only p_info_diff
glme4 = fitglme(Data_tbl,'choice ~ 1 + p_inf_diff + (1|subject) + (-1+p_inf_diff|subject)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace','DummyVarCoding','effects');

%Model 5: only intercept (fixed + random)
glme5 = fitglme(Data_tbl,'choice ~ 1 + (1|subject)',...
    'Distribution','Binomial','Link','logit','FitMethod','Laplace','DummyVarCoding','effects');

%plot Figure S3
figure('Position', [600,500,800,600])
bar(double(glme1.Coefficients(2:4,2)),0.5,'FaceColor',grey); hold on
errorbar(double(glme1.Coefficients(2:4,2)),double(glme1.Coefficients(2:4,3)),'k.','LineWidth',1)
ax = gca;
ax.XTickLabel = {'P(info) difference' 'EV' 'Uncertainty'};
ylabel('Estimated coefficients')
title('Fig. S3 - Fixed effects Model 1 (full)')

%extract data Table S1
TableS1_data = [(1:5)' [double(glme1.ModelCriterion(1,1:2)) ; double(glme2.ModelCriterion(1,1:2)) ; double(glme3.ModelCriterion(1,1:2)) ; ...
    double(glme4.ModelCriterion(1,1:2)) ; double(glme5.ModelCriterion(1,1:2))] [glme1.Rsquared.Adjusted ; glme2.Rsquared.Adjusted ; ...
    glme3.Rsquared.Adjusted ; glme4.Rsquared.Adjusted ; glme5.Rsquared.Adjusted] ]; 
TableS1 = array2table(TableS1_data, 'VariableNames',{'Model_number' 'AIC' 'BIC' 'Adjusted_R2'});

%% Analysis #4: Control analysis testing for Pavlovian conditioning (Fig. S4)

sub_list_nd = [1;2;4;5;9;10;11;14;15;16;17;18;19;20;21;23;24;...
    25;27;28;32;33;34;35;36;37;38]; %list of non-deterministic subjects (who chose ignorance at least once)

InfoCh.Gain1 = (1:30);
InfoCh.Gain2 = (1:30);
InfoCh.Loss1 = (1:30);
InfoCh.Loss2 = (1:30);
GLM_EV_outc = zeros(length(sub_list_nd),3);

for i=1:length(sub_list_nd)
    isub = Data_allsubs(:,1)==sub_list_nd(i); %extract choice rows for subject i
    dsub = Data_allsubs(isub,:); %data for subject i
    InfoCh.Gain1(i+1,:) = dsub(dsub(:,3)==1 & dsub(:,4)==1,9)';
    InfoCh.Gain2(i+1,:) = dsub(dsub(:,3)==1 & dsub(:,4)==2,9)';
    InfoCh.Loss1(i+1,:) = dsub(dsub(:,3)==0 & dsub(:,4)==1,9)';
    InfoCh.Loss2(i+1,:) = dsub(dsub(:,3)==0 & dsub(:,4)==2,9)';

    % run glm predicting info choice as a function of EV and previous trial outcome
    data_reg = dsub(:,[5 9 13 11 12]);
    %build an additional column with previous trial outcome
    for k=1:length(data_reg(:,1))
        if data_reg(k,1)==1
            data_reg(k,6)=NaN; %no previous outcome on first trial of each block
        elseif data_reg(k,1)~=1 && data_reg(k-1,4)==0
            data_reg(k,6)=NaN; %no info delivered on previous trial
        else
            if data_reg(k-1,5)==0 %previous outcome is ZERO
                data_reg(k,6)=0;
            elseif data_reg(k-1,3)>0
                data_reg(k,6)=1; %previous outcome is WIN
            elseif data_reg(k-1,3)<0
                data_reg(k,6)=-1; %previous outcome is LOSS
            end
        end
    end
    
    %remove NaN trials
    data_reg(isnan(data_reg(:,2)),:)=[]; %missed trials
    data_reg(isnan(data_reg(:,6)),:)=[]; %trials with no previous outcome
    b = glmfit([zscore(data_reg(:,3)) zscore(data_reg(:,6))],data_reg(:,2),'binomial','link','logit');

    %calculate difference in information choice for gains vs losses for correlation (Fig. S4F)
    i_g = dsub(:,3)==1;
    i_l = dsub(:,3)==0;
    GLM_EV_outc(i,:) = [b(2) b(3) nanmean(dsub(i_g,9))-nanmean(dsub(i_l,9))];
end
        
%Plot Figure S4
figure('Position',[500,100,1100,1150]); 
%Fig S4A
subplot(3,2,1); hold on
plot(nanmean(InfoCh.Gain1(2:end,:),1)*100, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
ylim([0 100])
lin_fit = glmfit((1:30)', nanmean(InfoCh.Gain1(2:end,:),1)'*100);
plot([1 30], [lin_fit(1)+lin_fit(2) lin_fit(1)+lin_fit(2)*30], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Trial number')
ax.YLabel.String = {'% participants who chose'; 'most informative offer'};
title('Fig S4A - Gain block 1')
%Fig S4B
subplot(3,2,2); hold on
plot(nanmean(InfoCh.Gain2(2:end,:),1)*100, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
ylim([0 100])
lin_fit = glmfit((1:30)', nanmean(InfoCh.Gain2(2:end,:),1)'*100);
plot([1 30], [lin_fit(1)+lin_fit(2) lin_fit(1)+lin_fit(2)*30], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Trial number')
ax.YLabel.String = {'% participants who chose'; 'most informative offer'};
title('Fig S4B - Gain block 2')
%Fig S4C
subplot(3,2,3); hold on
plot(nanmean(InfoCh.Loss1(2:end,:),1)*100, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
ylim([0 100])
lin_fit = glmfit((1:30)', nanmean(InfoCh.Loss1(2:end,:),1)'*100);
plot([1 30], [lin_fit(1)+lin_fit(2) lin_fit(1)+lin_fit(2)*30], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Trial number')
ax.YLabel.String = {'% participants who chose'; 'most informative offer'};
title('Fig S4C - Loss block 1')
%Fig S4D
subplot(3,2,4); hold on
plot(nanmean(InfoCh.Loss2(2:end,:),1)*100, 'LineStyle','none', 'Marker','o', 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',3)
ylim([0 100])
lin_fit = glmfit((1:30)', nanmean(InfoCh.Loss2(2:end,:),1)'*100);
plot([1 30], [lin_fit(1)+lin_fit(2) lin_fit(1)+lin_fit(2)*30], '--', 'Color','k')
ax = gca;
ax.FontSize = 9;
xlabel('Trial number')
ax.YLabel.String = {'% participants who chose'; 'most informative offer'};
title('Fig S4D - Loss block 2')
%Fig S4E
subplot(3,2,5); hold on
bar(1,mean(GLM_EV_outc(:,1)),0.5,'FaceColor',[0.3 0.3 0.3]);
bar(2,mean(GLM_EV_outc(:,2)),0.5,'FaceColor',[0.8 0.8 0.8]);
errorbar([1,2],mean(GLM_EV_outc(:,1:2),1),std(GLM_EV_outc(:,1:2),1)/sqrt(length(sub_list_nd)),'k.')
ax = gca;
ax.FontSize = 9;
ax.XTick = [1 2];
ax.XTickLabel = {'Current EV' 'Previous outcome'};
ylabel('Beta predicting choice')
title('Fig S4E')
%Fig 2F
subplot(3,2,6); hold on
plot(GLM_EV_outc(:,3), GLM_EV_outc(:,1), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',[0.3 0.3 0.3], 'MarkerEdgeColor','k', 'MarkerSize',3)
plot(GLM_EV_outc(:,3), GLM_EV_outc(:,2), 'LineStyle','none', 'Marker','o', 'MarkerFaceColor',[0.8 0.8 0.8], 'MarkerEdgeColor','k', 'MarkerSize',3)
legend({'Current EV','Previous outcome'},'FontSize',8)
lin_fit1 = glmfit(GLM_EV_outc(:,3), GLM_EV_outc(:,1));
lin_fit2 = glmfit(GLM_EV_outc(:,3), GLM_EV_outc(:,2));
plot([-0.24 0.39], [lin_fit1(1)+lin_fit1(2)*(-0.24) lin_fit1(1)+lin_fit1(2)*0.39], '--', 'Color',[0.3 0.3 0.3],'LineWidth',1)
plot([-0.24 0.39], [lin_fit2(1)+lin_fit2(2)*(-0.24) lin_fit2(1)+lin_fit2(2)*0.39], '--', 'Color',[0.8 0.8 0.8],'LineWidth',1)
xlim([-0.2 0.4])
ylim([-2 6])
ax = gca;
ax.FontSize = 9;
xlabel('Behavioral difference in choice (gain - loss)')
ylabel('Beta predicting choice')
title('Fig S4F')