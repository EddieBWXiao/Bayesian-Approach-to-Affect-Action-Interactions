function report = VATmdlcomp
    %takes in 8x300+ matrices
    %returns table for how good each one is
    
    AICs = readmatrix('VAT_AICtable.csv');
    BICs = readmatrix('VAT_BICtable.csv');    
    
    close all
    %name of models
    mns = {'FixedPrecision','UpdatePrecision','NoBias','UpdatePrecision-NoBias','FixedChange','UpdatePrecision-FixedChange','PrecisionShift','PriorGuided'};
    num_models = length(mns);
    %% histogram check
    figure;
    for i = 1:size(AICs,1)
        subplot(4,2,i)
        histogram(AICs(i,:),200:10:450)
        title(mns{i})
    end
    sgtitle('AIC distribution')
    
    figure;
    for i = 1:size(BICs,1)
        subplot(4,2,i)
        histogram(BICs(i,:),200:10:450)
       title(mns{i})
    end
    sgtitle('BIC distribution')
    
    
    %report the averages
    AIC = [mean(AICs,2),std(AICs,[],2)];
    BIC = [mean(BICs,2),std(AICs,[],2)];
    
    %% plot bar chart
    figure;
    subplot(2,1,1)
    bar_x = 1:num_models;%how many bars to plot
    bar(bar_x,AIC(:,1))
    hold on
    er = errorbar(bar_x,AIC(:,1),AIC(:,2),AIC(:,2));    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none'; 
    ylabel('AIC')
    set(gca,'XTickLabel',mns);
    title('Comparison of models with AIC')
    legend('mean AIC','standard deviation')
    hold off    
    
    subplot(2,1,2)
    bar_x = 1:num_models;%how many bars to plot
    bar(bar_x,BIC(:,1))
    hold on
    er = errorbar(bar_x,BIC(:,1),BIC(:,2),BIC(:,2));    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    ylabel('BIC')
    set(gca,'XTickLabel',mns);
    legend('mean AIC','standard deviation')
    title('Comparison of models with BIC')
    hold off    
      
    %% find lowest mean
    [~,ii] = sort(AIC(:,1));%sort and get weird index
    [~,AICranking]=sort(ii);%sort that index again to get real ranking
    [~,ii2] = sort(BIC(:,1));
    [~,BICranking]=sort(ii2);    
    
    %% find delta A/BIC, from first model
    dAIC = AICs-AICs(1,:);
    dBIC = BICs-BICs(1,:);
    mean_dAIC = mean(dAIC,2);
    mean_dBIC = mean(dBIC,2);
    SE_dAIC = std(dAIC,[],2)./sqrt(size(dAIC,2));
    SE_dBIC = std(dBIC,[],2)./sqrt(size(dBIC,2));

    
    %% find number of participants for whom this is the best
    [~,ii3] = sort(AICs,1);%sort for ranking within each participant
    [~,AsubjRank]=sort(ii3,1);%get ranking (i.e., for this participant, is it the best?)
    [~,ii4] = sort(BICs,1);
    [~,BsubjRank]=sort(ii4,1);  
    
    BestForNSujbects_AIC = sum(AsubjRank==1,2);
    BestForNSujbects_BIC = sum(BsubjRank==1,2);    
    
    Top3ForNSujbects_AIC = sum(AsubjRank<4,2);
    Top3ForNSujbects_BIC = sum(BsubjRank<4,2);  
    
    %% output
    modelname = mns';
    
    report = table(modelname,AICranking,BICranking,mean_dAIC,SE_dAIC,mean_dBIC,SE_dBIC,BestForNSujbects_AIC,BestForNSujbects_BIC,...
        Top3ForNSujbects_AIC,Top3ForNSujbects_BIC);
    
      %% plot another bar chart
    figure;
    subplot(2,1,1)
    bar_x = 1:num_models;%how many bars to plot
    bar(bar_x,mean_dAIC)
    hold on
    er = errorbar(bar_x,mean_dAIC,SE_dAIC,SE_dAIC);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none'; 
    ylabel('△AIC')
    set(gca,'XTickLabel',mns);
    title('Comparison of models with AIC')
    legend('AIC change per participant','standard error')
    hold off    
    set(gca, 'box', 'off')
    
    subplot(2,1,2)
    bar_x = 1:num_models;%how many bars to plot
    bar(bar_x,mean_dBIC)
    hold on
    er = errorbar(bar_x,mean_dBIC,SE_dBIC,SE_dBIC);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    ylabel('△BIC')
    set(gca,'XTickLabel',mns);
    legend('BIC change per participant','standard error')
    title('Comparison of models with BIC')
    hold off    
    set(gca, 'box', 'off')


end