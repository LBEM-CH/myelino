%% Skin data analysis - Myelin damage


%% score tot scatter

% data is the matrix in the statistics file with score,-,+,++,+++ damage

figure, hold on
%score_ID=0;

%score_ID={};
%score_ID_an={};
%score_num=0;
score_num=data;
% score_ID and score_num are the columns from the excel sheet with myelin damage
% score_ID_an is the anonymus version of score_ID

x=(1:1:length(data))';

%for i=1:1:length(score_num)
%    scatter(x(i),score_num(i), "filled", "k")
%    xticks(x)
%    xticklabels(score_ID_an)
%end

for i=1:1:11
    s1=scatter(x(i),score_num(i),65, "filled")
    xticks(x)
   %xticklabels(score_ID_an)
    s1.MarkerFaceColor = [0.47,0.67,0.19];
end

for i=12:1:27
    s2=scatter(x(i),score_num(i),65, "filled")
    xticks(x)
   % xticklabels(score_ID_an)
    s2.MarkerFaceColor = [0.96,0.55,0.37];
end

% for i=16:1:19
%     s3=scatter(x(i),score_num(i),65, "filled")
%     xticks(x)
%     xticklabels(score_ID_an)
%     s3.MarkerFaceColor = [0 0.4470 0.7410];
% end

for i=28:1:31
    s4=scatter(x(i),score_num(i),65, "filled")
    xticks(x)
    %xticklabels(score_ID_an)
    s4.MarkerFaceColor = [0.91,0.66,0.08];
end

for i=32:1:36
    s5=scatter(x(i),score_num(i),65, "filled")
    xticks(x)
   % xticklabels(score_ID_an)
    s5.MarkerFaceColor = [0.94,0.21,0.21];
end

yline(1, 'LineWidth',2)
xlim([0 40])
ylim([0 2.5])
ylabel(['Score tot'])
set(gca,'FontSize',18,'FontWeight','bold')
set(gca,'ytick',[0,1,2])
set(gca,'xtick',[])
axis square

% green [0.47,0.67,0.19]
% orange [0.96,0.55,0.37]
% blue [0 0.4470 0.7410] 
% yellow [0.91,0.66,0.08]
% red [0.94,0.21,0.21]

%% Test if data is normally distributed (One-sample Kolmogorov-Smirnov test)

% data is the matrix in the statistics file with score,-,+,++,+++ damage

% if p<0.05 data is not normally distributed
% if p>0.05 data is normally distributed

[h1, p1] = kstest(data(:,1));     

%% Test if data is normally distributed (Shapiro Wilk)

% data is the matrix in the statistics file with score,-,+,++,+++ damage

addpath('...'); %add right path

group_sizes = [11, 16, 4, 5];  % Number of examples in each group in this order: CTRL, PD, DLB, MSA:

group_labels = 1:length(group_sizes);  % Group numbers (1, 2, 3, 4)

groups = repelem(group_labels, group_sizes);  % Repeat each label according to its group size

unique_groups = unique(groups);  % Get unique group labels

for i = 1:length(unique_groups)
    group_data = data(groups == unique_groups(i)); % Extract data for each group
    [h, p] = swtest(group_data); % Perform Shapiro-Wilk test

    % Levene's Test (checking if variances are equal)
    [pLev,stats] = vartestn(data, groups);

    if h==0
    fprintf('Group %d: h = %d, p = %.4f, data normally distributed\n', unique_groups(i), h, p);
        if pLev<0.05
            fprintf('Variances are unequal, p = %.4f\n', pLev);
        elseif pLev>0.05
            fprintf('Variances are equal, p = %.4f\n', pLev);
        end
    elseif h==1
    fprintf('Group %d: h = %d, p = %.4f, data is not normally distributed\n', unique_groups(i), h, p);
        if pLev<0.05
            fprintf('Variances are unequal, p = %.4f\n', pLev);
        elseif pLev>0.05
            fprintf('Variances are equal, p = %.4f\n', pLev);
        end
    end
end
%% p value with two sample t-test (cannot be done if sample is not normally distributed)

% data is the matrix in the statistics file with score,-,+,++,+++ damage

%p-value for score tot
scoreCTRL=data(1:11,1);
scorePD=data(12:27,1);
scoreDLB=data(28:31,1);
scoreMSA=data(32:36,1);


[hCTRL_PD,pCTRL_PD] = ttest2(scoreCTRL, scorePD);
[hCTRL_DLB,pCTRL_DLB] = ttest2(scoreCTRL, scoreDLB);
[hCTRL_MSA,pCTRL_MSA] = ttest2(scoreCTRL, scoreMSA);

[hPD_DLB,pPD_DLB] = ttest2(scorePD, scoreDLB);
[hPD_MSA,pPD_MSA] = ttest2(scorePD, scoreMSA);

[hDLB_MSA,pDLB_MSA] = ttest2(scoreDLB, scoreMSA);

%% Kruskal-Wallis test with Bonferroni correction

group_sizes = [11, 16, 4, 5];  % Number of examples in each group in this order: CTRL, PD, DLB, MSA:

group_labels = 1:length(group_sizes);  % Group numbers (1, 2, 3, 4)

groups = repelem(group_labels, group_sizes);  % Repeat each label according to its group size

unique_groups = unique(groups);  % Get unique group labels
[p_kw, ~, stats] = kruskalwallis(data, groups, 'off');

% If Kruskal-Wallis is significant, perform Dunn's test
if p_kw < 0.05
    % Perform Dunn’s test (requires FDR correction toolbox)
    c = multcompare(stats, 'CType', 'dunn-sidak');
    
    % Extract p-values
    p_values = c(:,6);
    
    % Apply Bonferroni correction
    num_comparisons = length(p_values);
    p_corrected = min(p_values * num_comparisons, 1);  % Ensure p-values don't exceed 1
    
    % Display results
    fprintf('Kruskal-Wallis p-value: %.5f\n', p_kw);
    fprintf('Pairwise comparisons (Dunn’s test with Bonferroni correction):\n');
    disp(table(c(:,1), c(:,2), p_values, p_corrected, ...
        'VariableNames', {'Group1', 'Group2', 'Raw_p', 'Bonferroni_p'}));
else
    fprintf('Kruskal-Wallis test is not significant (p = %.5f). No need for post-hoc test.\n', p_kw);
end

%% box plot
figure

subplot(1,4,1)
boxchart(scoreCTRL, 'BoxFaceColor',[0.47,0.67,0.19])
xticklabels({'CTRL'})
%set(gca,'XColor','w')
set(gca,'ytick',[0,1,2])
ylabel(['Score tot'])
%ylabel(['MPZ (ng/ml)'])
ylim([0 2.5])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,2)
boxchart(scorePD, 'BoxFaceColor',[0.96,0.55,0.37])
xticklabels({'PD'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 2.5])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,3)
boxchart(scoreDLB, 'BoxFaceColor',[0.91,0.66,0.08]) 
xticklabels({'DLB'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 2.5])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,4)
boxchart(scoreMSA, 'BoxFaceColor',[0.94,0.21,0.21]) 
xticklabels({'MSA'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 2.5])
set(gca,'FontSize',18,'FontWeight','bold')


% green [0.47,0.67,0.19]
% orange [0.96,0.55,0.37]
% blue [0 0.4470 0.7410] 
% yellow [0.91,0.66,0.08]
% red [0.94,0.21,0.21]


%% chi squared

addpath('...'); %add right path

% counts = contingency table (rows = groups, columns = damage categories)
counts = [
    145 179 54 6;   % Control
    97  244 105 19; % PD
    19  51  25 9;   % DLB
    73  81  13 3    % MSA
];

% Labels
groupNames = ["CTRL", "PD", "DLB", "MSA"];
%damageLevels = ["No", "Mild", "Moderate", "High"];
damageLevels = ["No damage", "Mild damage", "Moderate damage", "High damage"];

% Reconstruct group and damage vectors
group = [];
damage = [];

for i = 1:4
    for j = 1:4
        n = counts(i,j);
        group = [group; repmat(groupNames(i), n, 1)];
        damage = [damage; repmat(damageLevels(j), n, 1)];
    end
end

% Perform chi-square test
[~, chi2stat, pval, labels] = crosstab(group, damage);

disp("Chi-squared statistic:")
disp(chi2stat)
disp("p-value:")
disp(pval)

% Convert to proportions
proportions = counts ./ sum(counts, 2);  % row-wise proportions

% Create categorical with explicit order
xCats = categorical(groupNames);
xCats = reordercats(xCats, groupNames);  % enforce correct order

figure
bar(xCats, proportions, 'stacked')
lgd=legend(damageLevels, 'Location', 'SouthOutside','NumColumns', 2);
ax = gca;
ax.Position = [0.1, 0.3, 0.8, 0.6];
fig = gcf; % Get current figure

lgd.Position = [0.42, 0.05, 0.2, 0.03];  % Centered at the bottom
title('Proportion of myelin sheaths')


% Add annotations
for i = 1:numel(groupNames)          % For each group
    yBase = 0;                         % Start stacking from 0
    for j = 1:numel(damageLevels)     % For each category
        yVal = proportions(i, j);
        if yVal > 0.03                 % Only label if >= 3% to avoid clutter
            text(i, yBase + yVal/2, sprintf('%.0f%%', yVal * 100), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 20, ...
                'Color', 'w', ...
                'FontWeight', 'bold');
        end
        yBase = yBase + yVal;         % Update stacking height
    end
end

% ----- External label for Control (group 1), High damage -----
x_ctrl = 1;  % bar index
y_ctrl = sum(proportions(1,1:3)) + proportions(1,4)/2;  % center of High bar
x_label_ctrl = x_ctrl - 0.5;  % position of external label (left side)
text(x_label_ctrl, y_ctrl, '1%', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 20, 'FontWeight', 'bold')

% Draw connecting line (Control)
line([x_label_ctrl + 0.05, x_ctrl - 0.05], [y_ctrl, y_ctrl], 'Color', 'k','HandleVisibility', 'off')

% ----- External label for MSA (group 4), High damage -----
x_msa = 4;
y_msa = sum(proportions(4,1:3)) + proportions(4,4)/2;
x_label_msa = x_msa + 0.5;  % position of external label (right side)
text(x_label_msa, y_msa, '1%', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 20, 'FontWeight', 'bold')

% Draw connecting line (MSA)
line([x_msa + 0.05, x_label_msa - 0.05], [y_msa, y_msa], 'Color', 'k','HandleVisibility', 'off')

set(gca,'FontSize',20,'FontWeight','bold')
ylim([0 1.03])
set(gca,'ytick',[])


% Compute expected values
total = sum(counts(:));
rowSums = sum(counts, 2);
colSums = sum(counts, 1);
expected = rowSums * colSums / total;

% Compute standardized residuals
stdResiduals = (counts - expected) ./ sqrt(expected);

% Compute p-values for each cell
pValues = 1 - chi2cdf((counts - expected).^2 ./ expected, 1);

% Bonferroni corrected alpha (adjusted for 16 cells in table)
alpha_adj = 0.05 / numel(counts);

% Find significant residuals (|residual| > 2.58 after Bonferroni correction)
significantCells = abs(stdResiduals) > 2.58;

% Display significant residuals and their corresponding p-values
disp('Significant Standardized Residuals:')
[row, col] = find(significantCells);  % Find locations of significant cells
for i = 1:length(row)
    fprintf('Group: %s, Damage: %s, Residual: %.2f\n', ...
        groupNames(row(i)), damageLevels(col(i)), stdResiduals(row(i), col(i)));
end

% Display p-values and check if they are significant
disp('P-values for each cell:')
[row, col] = find(pValues < 0.05);  % Find significant p-values
for i = 1:length(row)
    fprintf('Group: %s, Damage: %s, p-value: %.4f\n', ...
        groupNames(row(i)), damageLevels(col(i)), pValues(row(i), col(i)));
end

% Plot the standardized residuals as a heatmap
figure(100), hold on
axis tight;
imagesc(stdResiduals);
colormap(bluewhitered(256));
colorbar;
caxis([-max(abs(stdResiduals(:))) max(abs(stdResiduals(:)))]);  % Center around 0
xticks(1:4);
xticklabels({'No\newlinedamage', 'Mild\newlinedamage', 'Moderate\newlinedamage', 'High\newlinedamage'});
yticks(1:4);
yticklabels({'CTRL', 'PD', 'DLB', 'MSA'});
set(gca, 'YDir', 'reverse');  % Flip Y-axis so "Control" is at the top
title('Chi squared test');
colorbar
set(gca,'FontSize',20,'FontWeight','bold')

% Annotate each cell
[nRows, nCols] = size(stdResiduals);
for i = 1:nRows
    for j = 1:nCols
        if pValues(i,j) < 0.05
            text(j, i, sprintf('R = %.2f', stdResiduals(i,j)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
            'Color', 'white', 'FontSize', 20);
                if pValues(i,j) < 0.001
                     text(j, i, sprintf('p = %.4f', pValues(i,j)), ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                    'Color', 'white', 'FontSize', 20);
                else 
                     text(j, i, sprintf('p = %.3f', pValues(i,j)), ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                    'Color', 'white', 'FontSize', 20);
                end
         end
    end
end
%% g-ratio disease groups full cohort

% patient_info is the patient info table with columns:
% patient_info.PatientCode (list of patient codes), patient_info.Age and patient_info.Group

% data is a cell e.g. data=cell(36,3); containing patient code, age and disease group

% Create a table from data
patient_info = cell2table(data, 'VariableNames', {'PatientCode', 'Age', 'Group'});

% Specify the full path to the folder containing g-ratio_*.m files
folder_path = '...'; %add right path
cd(folder_path)

% Get a list of all .m files in that folder with 'g-ratio_' in their names
files = dir(fullfile(folder_path, 'g-ratio_*.mat'));  % Use full path with file pattern


% Initialize a container for the combined data
combined_data = [];

for i = 1:length(files)
    filename = fullfile(folder_path, files(i).name);

    % Extract patient code from filename
    patient_code = extractBetween(files(i).name, 'g-ratio_', '.mat');

    % Load the .mat file
    DATA = load(filename);  % This loads a struct with fields = variable names

    % the variable inside the .mat file is called 'g_ratio'
  
       
        % Lookup age
        idx = strcmp(patient_info.PatientCode, patient_code);
        age = patient_info.Age(idx);
        group = patient_info.Group(idx);

        % Prepare columns
        nRows = height(DATA.T);
        patient_column = repmat(patient_code, nRows, 1);  % Cell array
        age_column = repmat(age, nRows, 1);
        group_column = repmat(group, nRows, 1);

        % Extract only the G-ratio column (assumed to be 2nd column)
        g_ratio_column = DATA.T{:,2};

        % Combine into one array (use cell array to mix string and numeric types)
        combined_patient_data = [patient_column, num2cell(g_ratio_column), num2cell(age_column), group_column];

        % Append to final dataset
        combined_data = [combined_data; combined_patient_data];
    
end

% Convert to table
combined_data_table = cell2table(combined_data, 'VariableNames', {'PatientCode', 'G_Ratio', 'Age', 'Group'});

% Display final table
disp(combined_data_table);


%% myelin thickness disease groups full cohort

% patient_info is the patient info table with columns:
% patient_info.PatientCode (list of patient codes), patient_info.Age and patient_info.Group

% data is a cell e.g. data=cell(36,3); containing patient code, age and disease group

% Create a table from data
patient_info = cell2table(data, 'VariableNames', {'PatientCode', 'Age', 'Group'});

% Specify the full path to the folder containing g-ratio_*.m files
folder_path = '...'; %add right path
cd(folder_path)

% Get a list of all .m files in that folder with 'g-ratio_' in their names
files = dir(fullfile(folder_path, 'thickness_*.mat'));  % Use full path with file pattern


% Initialize a container for the combined data
combined_data = [];

for i = 1:length(files)
    filename = fullfile(folder_path, files(i).name);

    % Extract patient code from filename
    patient_code = extractBetween(files(i).name, 'thickness_', '.mat');

    % Load the .mat file
    DATA = load(filename);  % This loads a struct with fields = variable names

    % the variable inside the .mat file is called 'g_ratio'
  
       
        % Lookup age
        idx = strcmp(patient_info.PatientCode, patient_code);
        age = patient_info.Age(idx);
        group = patient_info.Group(idx);

        % Prepare columns
        nRows = height(DATA.T);
        patient_column = repmat(patient_code, nRows, 1);  % Cell array
        age_column = repmat(age, nRows, 1);
        group_column = repmat(group, nRows, 1);

        % Extract only the Thickness column (assumed to be 2nd column)
        thickness_column = DATA.T{:,2};

        % Combine into one array (use cell array to mix string and numeric types)
        combined_patient_data = [patient_column, num2cell(thickness_column), num2cell(age_column), group_column];

        % Append to final dataset
        combined_data = [combined_data; combined_patient_data];
    
end

% Convert to table
combined_data_table = cell2table(combined_data, 'VariableNames', {'PatientCode', 'Thickness', 'Age', 'Group'});

% Display final table
disp(combined_data_table);

%% g ratio score categories full cohort

% patient_info is the patient info table with columns:
% patient_info.PatientCode (list of patient codes), patient_info.Age and patient_info.Group

% data is a cell e.g. data=cell(36,3); containing patient code, age and disease group

% Create a table from data
patient_info = cell2table(data, 'VariableNames', {'PatientCode', 'Age', 'Group'});

% Specify the full path to the folder containing g-ratio_*.mat files
folder_path = '...'; %add right path
cd(folder_path)

% Get a list of all .mat files in that folder with 'g-ratio_' in their names
files = dir(fullfile(folder_path, 'g-ratio_*.mat'));  % Use full path with file pattern

% Initialize a container for the combined data
g_ratio_scores = [];

for i = 1:length(files)
    filename = fullfile(folder_path, files(i).name);

    % Load the .mat file
    DATA = load(filename);  % This loads a struct with fields = variable names

    % the variable inside the .mat file is called 'g_ratio'
    G_RATIO = DATA.T.g_ratio;

    % Extract clean patient names from the first column (assuming it's ImageID)
    DATA.T.CleanPatientName = cellfun(@(s) s(1:find(s == '-', 1, 'last') - 1), ...
                                      DATA.T.ImageID, ...
                                      'UniformOutput', false);

    % Extract the damage score from the filename (e.g., 'g-ratio_Score0.mat')
    [~, file_name, ~] = fileparts(files(i).name); % Get the filename without extension
    damage_score = extractAfter(file_name, 'Score');  % Extract the score part after 'Score'
    value = str2double(damage_score);
    damage_score_vector = repmat(value, length(G_RATIO), 1);
    % Create a new column for the damage score
    combined_data_score = table(DATA.T.CleanPatientName, G_RATIO, damage_score_vector, ...
                                'VariableNames', {'PatientCode', 'g_ratio', 'DamageScore'});

    % Append to the big table
    g_ratio_scores = [g_ratio_scores; combined_data_score];
end

% Join the tables based on the 'PatientCode' column
combined_table = join(g_ratio_scores, patient_info, 'Keys', 'PatientCode');

% The combined_table now contains:
% - PatientCode
% - g_ratio
% - DamageScore
% - Age (from patient_info table)
% - Group (from patient_info table)

% Display the resulting table
disp(combined_table);

%% myelin thickness score categories full cohort


% Assuming the patient info table is called 'patient_info' with columns:
% patient_info.PatientCode (list of patient codes), patient_info.Age and patient_info.Group

% data is a cell e.g. data=cell(36,3); containing patient code, age and disease group

% Create a table from data
patient_info = cell2table(data, 'VariableNames', {'PatientCode', 'Age', 'Group'});

% Specify the full path to the folder containing g-ratio_*.mat files
folder_path = '...'; %add right path
cd(folder_path)

% Get a list of all .mat files in that folder with 'g-ratio_' in their names
files = dir(fullfile(folder_path, 'thickness_*.mat'));  % Use full path with file pattern

% Initialize a container for the combined data
thickness_scores = [];

for i = 1:length(files)
    filename = fullfile(folder_path, files(i).name);

    % Load the .mat file
    DATA = load(filename);  % This loads a struct with fields = variable names

    % the variable inside the .mat file is called 'g_ratio'
    THICKNESS = DATA.T.Thickness;

    % Extract clean patient names from the first column (assuming it's ImageID)
    DATA.T.CleanPatientName = cellfun(@(s) s(1:find(s == '-', 1, 'last') - 1), ...
                                      DATA.T.ImageID, ...
                                      'UniformOutput', false);

    % Extract the damage score from the filename (e.g., 'g-ratio_Score0.mat')
    [~, file_name, ~] = fileparts(files(i).name); % Get the filename without extension
    damage_score = extractAfter(file_name, 'Score');  % Extract the score part after 'Score'
    value = str2double(damage_score);
    damage_score_vector = repmat(value, length(THICKNESS), 1);
    % Create a new column for the damage score
    combined_data_score = table(DATA.T.CleanPatientName, THICKNESS, damage_score_vector, ...
                                'VariableNames', {'PatientCode', 'thickness', 'DamageScore'});

    % Append to the big table
    thickness_scores = [thickness_scores; combined_data_score];
end

% Join the tables based on the 'PatientCode' column
combined_table = join(thickness_scores, patient_info, 'Keys', 'PatientCode');

% The combined_table now contains:
% - PatientCode
% - Thickness
% - DamageScore
% - Age (from patient_info table)
% - Group (from patient_info table)

% Display the resulting table
disp(combined_table);


%% Correlation plots 

%data is a matrix containing myelin damage and 1 variable to correlate (e.g. age, PMD, fixation time)

data_corr=[data(:,1) data(:,2)];

%in corrplot c is the correlation coefficient, p is the p-value, H the graphic object

figure (1)
[c_all,p_all,H]=corrplot(data_corr(:,:), Type="Spearman"); 

figure (2)
[c_CTRL,p_CTRL,H]=corrplot(data_corr(1:11,:));  

figure (3)
[c_PD,p_PD,H]=corrplot(data_corr(12:27,:));


%% makes all the corr figures with same size/style etc 

H(2,1).MarkerSize=7;
H(2,1).MarkerFaceColor='[0 0.45 0.74]';
set(gca,'ytick',[0,1,2])
set(gca,'FontSize',16,'FontWeight','bold')
set(gca,'Units','centimeters')
set(gca,'position',[2,2,11,11])
xlabel('Age (years)')
ylabel('Myelin damage')
axis square
%xlim([50 95])
ylim([0 2.5])
%saveas(gcf,'corr_plot_score_age','fig')
%saveas(gcf,'corr_plot_score_age','tiff')
%saveas(gcf,'corr_plot_score_age','eps')

%% sex differences myelin damage
% Example vectors

%data is the matrix with myelin damage in column 1 and sex in column 2

phenotype = data(:,1); % myelin data
sex = data(:,2);      % sex labels (binary vector: 0 = male, 1 = female)

% Grouping the phenotype data by sex
phenotype_male = phenotype(sex == 0);
phenotype_female = phenotype(sex == 1);

% Perform Mann–Whitney U Test (Wilcoxon rank-sum test)
[p, h, stats] = ranksum(phenotype_male, phenotype_female);

% Display results
fprintf('Mann–Whitney U test p-value: %.5f\n', p);

% Interpretation
if p < 0.05
    fprintf('There is a significant difference in phenotype between sexes (p = %.5f).\n', p);
else
    fprintf('No significant difference in phenotype between sexes (p = %.5f).\n', p);
end


figure(1), hold on
subplot(1,2,1)
boxchart(phenotype_female, 'BoxFaceColor',[1,0,1])
xticklabels({'F'})
set(gca,'ytick',[0,1,2])
set(gca,'FontSize',16,'FontWeight','bold')
ylabel(['Score tot'])
ylim([0 2.5])

subplot(1,2,2)
boxchart(phenotype_male, 'BoxFaceColor',[0,1,1])
%set(gca,'xtick',[])      %removes xticks
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
set(gca,'FontSize',16,'FontWeight','bold')
xticklabels({'M'})
ylim([0 2.5])


path='...'; %add right path
cd(path)
saveas(gcf,'box_plot_score_F_M_all','fig')
saveas(gcf,'box_plot_score_F_M_all','tiffn')
saveas(gcf,'box_plot_score_F_M_all','eps')

%% Sensitivity, specificity, ROC, AUC

i=0;
j=0;
TN_CTRL=0;
TN_CTRL_tot=0;

FP_CTRL=0;
FP_CTRL_tot=0;

threshold=0:0.01:2;  %array of different thresholds to calculate ROC curve

for i=1:1:length(threshold)
    for j=1:1:11  % CTRL
        if data(j) < threshold(i)
        TN_CTRL=TN_CTRL+1;
        end
        if data(j) >= threshold(i)
        FP_CTRL=FP_CTRL+1;
        end
    end
    TN_CTRL_tot(i)=TN_CTRL;
    TN_CTRL=0;
    FP_CTRL_tot(i)=FP_CTRL;
    FP_CTRL=0;
end

TP_PD=0;
TP_PD_tot=0;

FN_PD=0;
FN_PD_tot=0;

for i=1:1:length(threshold)
    for j=12:1:27  % PD
        if data(j) >= threshold(i)
        TP_PD=TP_PD+1;
        end
        if data(j) < threshold(i)
        FN_PD=FN_PD+1;
        end
    end
    TP_PD_tot(i)=TP_PD;
    TP_PD=0;
    FN_PD_tot(i)=FN_PD;
    FN_PD=0;
end

TP_DLB=0;
TP_DLB_tot=0;

FN_DLB=0;
FN_DLB_tot=0;

% for i=1:1:length(threshold)
%     for j=28:1:31  % DLB
%         if data(j) >= threshold(i)
%         TP_DLB=TP_DLB+1;
%         end
%         if data(j) < threshold(i)
%         FN_DLB=FN_DLB+1;
%         end
%     end
%     TP_DLB_tot(i)=TP_DLB;
%     TP_DLB=0;
%     FN_DLB_tot(i)=FN_DLB;
%     FN_DLB=0;
% end

TN_MSA=0;
TN_MSA_tot=0;

FP_MSA=0;
FP_MSA_tot=0;

for i=1:1:length(threshold)
    for j=32:1:36  % MSA
        if data(j) < threshold(i)
        TN_MSA=TN_MSA+1;
        end
        if data(j) >= threshold(i)
        FP_MSA=FP_MSA+1;
        end
    end
    TN_MSA_tot(i)=TN_MSA;
    TN_MSA=0;
    FP_MSA_tot(i)=FP_MSA;
    FP_MSA=0;
end

 %TPR = true positive rate = sensitivity
 %FPR = false positive rate = 1 - specificity

 TPR_PD_CTRL=0;
 FPR_PD_CTRL=0;

for i=1:1:length(threshold)
    TPR_PD_CTRL(i)=TP_PD_tot(i)/(TP_PD_tot(i)+FN_PD_tot(i));  
    FPR_PD_CTRL(i)=FP_CTRL_tot(i)/(FP_CTRL_tot(i)+TN_CTRL_tot(i));
end

%flip vectors to have them in increasing order otherwise AUC is negative
FPR_PD_CTRL=flip(FPR_PD_CTRL); 
TPR_PD_CTRL=flip(TPR_PD_CTRL);
threshold=flip(threshold);

x=0:0.1:1; % to plot the line at 45° (random guess)
y=x;
AUC_PD_CTRL=trapz(FPR_PD_CTRL,TPR_PD_CTRL);
txt = ['AUC_{PD-CTRL} = ',num2str(round(AUC_PD_CTRL,2))];

figure(31), hold on
plot(FPR_PD_CTRL,TPR_PD_CTRL, 'o-', 'LineWidth',2, MarkerSize=8)
plot(x,y,'--', 'LineWidth',2)
text(0.55,0.4,txt,"FontSize",16,"Color",'[0.00,0.45,0.74]');
xlabel('1 - Specificity')
ylabel('Sensitivity')
title('ROC curve PD-CTRL');
set(gca,'FontSize',16,'FontWeight','bold')
pbaspect([1 1 1]) % plot box square aspect ratio
box on % box around plot

 TPR_PD_MSA=0;
 FPR_PD_MSA=0;

for i=1:1:length(threshold)
    TPR_PD_MSA(i)=TP_PD_tot(i)/(TP_PD_tot(i)+FN_PD_tot(i));  
    FPR_PD_MSA(i)=FP_MSA_tot(i)/(FP_MSA_tot(i)+TN_MSA_tot(i));
end

%flip vectors to have them in increasing order otherwise AUC is negative
FPR_PD_MSA=flip(FPR_PD_MSA); 
TPR_PD_MSA=flip(TPR_PD_MSA);
threshold=flip(threshold);

x=0:0.1:1; % to plot the line at 45° (random guess)
y=x;
AUC_PD_MSA=trapz(FPR_PD_MSA,TPR_PD_MSA);
txt = ['AUC_{PD-MSA} = ',num2str(round(AUC_PD_MSA,2))];

figure(31), hold on
plot(FPR_PD_MSA,TPR_PD_MSA, 'o-', 'LineWidth',2, MarkerSize=8)
%plot(x,y,'--', 'LineWidth',2)
text(0.55,0.5,txt,"FontSize",16, "Color",'[0.93,0.69,0.13]');
xlabel('1 - Specificity')
ylabel('Sensitivity')
title('ROC curve PD-MSA-CTRL');
set(gca,'FontSize',16,'FontWeight','bold')
pbaspect([1 1 1]) % plot box square aspect ratio
box on % box around plot

% I don't calculate DLB_CTRL and DLB_MSA since I have 1 DLB scores < 1, 1 DLB score = 1 and 2 DLB scores > 1 therefore idk 
% what would be TP, FP, TN, FN

%score threshold=1 corresponds to threshold(101)
t=101; 

sensitivity=TP_PD_tot(t)/(TP_PD_tot(t)+FN_PD_tot(t));
% specificity_ctrl=TN_CTRL_tot(t)/(TN_CTRL_tot(t)+FP_CTRL_tot(t));
% specificity_msa=TN_MSA_tot(t)/(TN_MSA_tot(t)+FP_MSA_tot(t));
% accuracy_ctrl=(TP_PD_tot(t)+TN_CTRL_tot(t))/(TP_PD_tot(t)+TN_CTRL_tot(t)+FP_CTRL_tot(t)+FN_PD_tot(t));
% accuracy_msa=(TP_PD_tot(t)+TN_MSA_tot(t))/(TP_PD_tot(t)+TN_MSA_tot(t)+FP_MSA_tot(t)+FN_PD_tot(t));

specificity_ctrl_msa=(TN_CTRL_tot(t)+TN_MSA_tot(t))/(TN_CTRL_tot(t)+TN_MSA_tot(t)+FP_CTRL_tot(t)+FP_MSA_tot(t));
accuracy_ctrl_msa=(TP_PD_tot(t)+TN_CTRL_tot(t)+TN_MSA_tot(t))/(TP_PD_tot(t)+TN_CTRL_tot(t)+TN_MSA_tot(t)+FP_CTRL_tot(t)+FP_MSA_tot(t)+FN_PD_tot(t));

% 
 PPV=TP_PD_tot(t)/(TP_PD_tot(t)+FP_CTRL_tot(t)+FP_MSA_tot(t)); %positive predictive value
 NPV=(TN_CTRL_tot(t)+TN_MSA_tot(t))/(TN_CTRL_tot(t)+TN_MSA_tot(t)+FN_PD_tot(t)); %negative predictive value

%% local maxima of line profile (Figure 2)

xm=no_damage(:,1);
ym=no_damage(:,2);

xp=mild_damage(:,1);
yp=mild_damage(:,2);

x2p=moderate_damage(:,1);
y2p=moderate_damage(:,2);

x3p=high_damage(:,1);
y3p=high_damage(:,2);


TFm = islocalmax(ym);
figure(1), hold on
subplot(4,1,1), hold on
plot(xm,ym)
plot(xm(TFm),ym(TFm),'r*')
xlim([0 514])
%xlabel(['Distance (nm)'])
ylabel(['Gray value'])
%pbaspect([3 1 1]) % x-axis 3 times longer than y,z
set(gca,'FontSize',14,'FontWeight','bold')
set(gca,'ytick',[])     %removes yticks
box on

TFm_num = double(TFm);

i=0;
for i=1:1:length(TFm_num)
    if TFm_num(i) == 1
    TFm_num(i) = 4;
    end
end

figure(2), hold on
scatter(xm,TFm_num, 15, "filled")
ylim([0.5 4.5])

TFp = islocalmax(yp);
figure(1), hold on
subplot(4,1,2), hold on
plot(xp,yp)
plot(xp(TFp),yp(TFp),'r*')
xlim([0 471])
%xlabel(['Distance (nm)'])
ylabel(['Gray value'])
%pbaspect([3 1 1])
set(gca,'FontSize',14,'FontWeight','bold')
set(gca,'ytick',[])     %removes yticks
box on

TFp_num = double(TFp);

i=0;
for i=1:1:length(TFp_num)
    if TFp_num(i) == 1
    TFp_num(i) = 3;
    end
end

figure(2), hold on
scatter(xp,TFp_num, 15, "filled")
ylim([0.5 4.5])

TF2p = islocalmax(y2p);
figure(1), hold on
subplot(4,1,3), hold on
plot(x2p,y2p)
plot(x2p(TF2p),y2p(TF2p),'r*')
xlim([0 784])
%xlabel(['Distance (nm)'])
ylabel(['Gray value'])
%pbaspect([3 1 1])
set(gca,'FontSize',14,'FontWeight','bold')
set(gca,'ytick',[])     %removes yticks
box on

TF2p_num = double(TF2p);

i=0;
for i=1:1:length(TF2p_num)
    if TF2p_num(i) == 1
    TF2p_num(i) = 2;
    end
end

figure(2), hold on
scatter(x2p,TF2p_num, 15, "filled")
ylim([0.5 4.5])

TF3p = islocalmax(y3p);
figure(1), hold on
subplot(4,1,4), hold on
plot(x3p,y3p)
plot(x3p(TF3p),y3p(TF3p),'r*')
xlim([0 1712])
xlabel(['Distance (nm)'])
ylabel(['Gray value'])
%pbaspect([3 1 1])
set(gca,'FontSize',14,'FontWeight','bold')
set(gca,'ytick',[])     %removes yticks
box on

TF3p_num = double(TF3p);
figure(2), hold on
scatter(x3p,TF3p_num, 15, "filled")
ylim([0.5 4.5])
box on


%% Image size less than 10 MB for myelin thickness

% Specify the folder containing the images
inputFolder = '...'; %add right path
outputFolder = '...'; %add right path


% Create the output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Get a list of all the image files in the folder
imageFiles = dir(fullfile(inputFolder, '*.tif')); 


% Loop through all the image files
for i = 1:length(imageFiles)
    % Get the full path of the image
    inputImagePath = fullfile(inputFolder, imageFiles(i).name);
    
    % Get the file size in bytes
    fileInfo = dir(inputImagePath);
    fileSize = fileInfo.bytes;
    
    % Check if the file size is smaller than 10 MB
    if fileSize < 10 * 1024 * 1024 % 10 MB in bytes
        % Define the path to copy the image to the new folder
        outputImagePath = fullfile(outputFolder, imageFiles(i).name);
        
        % Copy the image to the new folder
        copyfile(inputImagePath, outputImagePath);
        fprintf('Copied: %s\n', imageFiles(i).name);
    end
end

disp('Finished copying files.');


%% myelin thickness
% Set the folder path
folderPath = '...'; %add right path

cd(folderPath); % enter folder

% Get a list of all files in the folder
fileList = dir(fullfile(folderPath, '*.tif')); 

% Initialize an empty table with column names
T = table();  % Create an empty table to store values
  
% Loop through each file
for i = 1:length(fileList)
    I=0;
    dist_vector=0;
    crop=0;
    m=0;
    j=0;

    % Get the full path of the current file
    fileName = fileList(i).name;
    filePath = fullfile(folderPath, fileName);
    
    % Display the file name (for debugging)
    disp(['Reading file: ', fileName]);
    I=imread(fileName);

    dist_vector=reshape(I,1,[]);

    for k=1:1:length(dist_vector)
      if dist_vector(k) > m
            j=j+1;
            crop(j)=dist_vector(k);
        end
    end

%h=histogram(crop);

crop=crop*3.14; % Set correct pixel size in nm: 1px = 3.14 nm
average(i)=mean(crop); % average thickness in nm 
st_dev(i)=std(crop); % standard deviation in nm

fprintf('Average thickness: %d\n Standard deviation: %d\n\n', average, st_dev);

 % Split the filename at the first occurrence of '-'
    parts = split(fileName, '_');
    % Get the part before the '_'
    shortfileName = parts{1};  % The first part before '-'
    
    % Generate the letter (char) for the current row
    letter = char(shortfileName);  % 'A', 'B', 'C', ...
    
    % Generate the corresponding number (1, 2, 3, ...)
    number = average(i);
    number2 = st_dev(i);
    
    % Create a new row as a table
    newRow = table({letter}, number, number2);  % Note the cell {} for strings
    
    % Append the new row to the table
    T = [T; newRow];  % Append row by row
end

T.Properties.VariableNames = {'ImageID', 'Thickness', 'Standard deviation'};  %change column name to match info

% Display the table
disp(T);
save('thickness_Score3.mat', 'T');


%% normalize myelin labels only for visualization

inputFolder = '...'; %add right path (labeled)
outputFolder = '...'; %add right path (normalized)
outputFolder2 = '...'; %add right path (for_g_ratio)
cd(inputFolder); % enter folder

% Create the output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Create the output folder if it doesn't exist
if ~exist(outputFolder2, 'dir')
    mkdir(outputFolder2);
end

% Get a list of all files in the folder
fileList = dir(fullfile(inputFolder, '*.tif')); 

% Loop through each file
for i = 1:length(fileList)
    % I=0;
    % dist_vector=0;
    % crop=0;
    % m=0;
    % j=0;

    % Get the full path of the current file
    fileName = fileList(i).name;
    inputImagePath = fullfile(inputFolder, fileName);
   
    
    % Display the file name (for debugging)
    disp(['Reading file: ', fileName]);
    I=imread(fileName);
    min_val = double(min(I(:)));
    max_val = double(max(I(:)));
    
    normalized_I = uint8(255 * (double(I) - min_val) / (max_val - min_val));
    %imshow(normalized_I);

    output_path = fullfile(outputFolder, fileName); % Create full path
    imwrite(normalized_I, output_path);  % Save image
 
end


%% g-ratio

% Define the caseID
%caseID='N22-017';  %change also the filename at the end of the section (in the saving option)

% Set the folder path
folderPath = '...';  %add right path
cd(folderPath); % enter folder

% Get a list of all files in the folder
fileList = dir(fullfile(folderPath, '*.tif')); %check if tif or tiff (put both options)

% Initialize an empty table with column names
T = table();  % Create an empty table


% Loop through each file
for i = 1:length(fileList)    
    I=0;

    % Get the full path of the current file
    fileName = fileList(i).name;
    filePath = fullfile(folderPath, fileName);
    
    % Display the file name (for debugging)
    disp(['Reading file: ', fileName]);
    I = imread(fileName);
    
    axonValue = 255;  % Pixels with value 255
    pixel_count_axon_myelin = sum(I(:) > 0); %all the pixels except for the background
    pixel_count_axon = sum(I(:) == axonValue);

    g_ratio=sqrt(pixel_count_axon./pixel_count_axon_myelin);
    fprintf('Number of pixels with value 128 or 255: %d\n Number of pixels with value 255: %d\n The g-ratio is: %d \n\n', pixel_count_axon_myelin, pixel_count_axon, g_ratio);
   
    % Split the filename at the first occurrence of '_'
    parts = split(fileName, '_');
    % Get the part before the '_'
    shortfileName = parts{1};  % The first part before '_'
    
    % Generate the letter (char) for the current row
    letter = char(shortfileName);  % 'A', 'B', 'C', ...
    
    % Generate the corresponding number (1, 2, 3, ...)
    number = g_ratio;
    
    % Create a new row as a table
    newRow = table({letter}, number);  % Note the cell {} for strings
    
    % Append the new row to the table
    T = [T; newRow];  % Append row by row
end 

T.Properties.VariableNames = {'ImageID', 'g_ratio'};  %change column name to match info

% Display the table
disp(T);
save(['g-ratio_Score3.mat'], 'T');

%% Group tables for myelin g-ratio

% Set the folder path
folderPath = '...'; %add right path
cd(folderPath); % enter folder

% Get a list of all files in the folders
fileList = dir(fullfile(folderPath, '*.mat')); 

% Initialize an empty table with column names
Table_g_ratio = table();  % Create an empty table

for i = 1:length(fileList)   

    % Get the full path of the current file
    fileName = fileList(i).name;
    filePath = fullfile(folderPath, fileName);
    T=load(fileName);
    mean_g_ratio=mean(T.T.g_ratio);

    % Split the filename at the first occurrence of '_'
    parts = split(fileName, '_');
    % Get the part after the '_'
    shortfileName = parts{2};  % The part after '_'

     % Split the filename at the first occurrence of '.'
    parts2 = split(shortfileName, '.');
    % Get the part before the '.'
    shortfileName2 = parts2{1};  % The part before '.'

    % Generate the letter (char) for the current row
    letter = char(shortfileName);  % 'A', 'B', 'C', ...
    
    % Generate the corresponding number (1, 2, 3, ...)
    number = mean_g_ratio;
    
    % Create a new row as a table
    newRow = table({letter}, number);  % Note the cell {} for strings
    
    % Append the new row to the table
    Table_g_ratio = [Table_g_ratio; newRow];  % Append row by row

end

Table_g_ratio.Properties.VariableNames = {'DonorID', 'Mean_g_ratio'};  %change column name to match info
% Display the table
disp(Table_g_ratio);
save('g-ratio_MSA.mat', 'Table_g_ratio');

%% box plot from table g ratio disease groups
% Set the folder path
folderPath = '...';  %add right path
cd(folderPath); % enter folder

load('All_g-ratio_CTRL.mat')
g_ratioCTRL=allg_ratio;

load('All_g-ratio_PD.mat')
g_ratioPD=allg_ratio;

load('All_g-ratio_DLB.mat')
g_ratioDLB=allg_ratio;

load('All_g-ratio_MSA.mat')
g_ratioMSA=allg_ratio;


figure(1), hold on
subplot(1,4,1), hold on

boxchart(g_ratioCTRL,'BoxFaceColor',[0.47,0.67,0.19], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioCTRL, 25);
Q3 = prctile(g_ratioCTRL, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioCTRL >= lowerBound & g_ratioCTRL <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioCTRL(nonOutliers))), g_ratioCTRL(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

ylim([0 1])
xticklabels({'CTRL'})
ylabel('Myelin g-ratio')
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,2), hold on
boxchart(g_ratioPD, 'BoxFaceColor',[0.96,0.55,0.37], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioPD, 25);
Q3 = prctile(g_ratioPD, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioPD >= lowerBound & g_ratioPD <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioPD(nonOutliers))), g_ratioPD(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'PD'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 1])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,3), hold on
boxchart(g_ratioDLB, 'BoxFaceColor',[0.91,0.66,0.08], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioDLB, 25);
Q3 = prctile(g_ratioDLB, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioDLB >= lowerBound & g_ratioDLB <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioDLB(nonOutliers))), g_ratioDLB(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'DLB'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 1])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,4), hold on
boxchart(g_ratioMSA, 'BoxFaceColor',[0.94,0.21,0.21], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioMSA, 25);
Q3 = prctile(g_ratioMSA, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioMSA >= lowerBound & g_ratioMSA <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioMSA(nonOutliers))), g_ratioMSA(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'MSA'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 1])
set(gca,'FontSize',18,'FontWeight','bold')

%% box plot from table g ratio damage score
% Set the folder path
folderPath = '...';  %add right path
cd(folderPath); % enter folder

load('g-ratio_Score0.mat')
g_ratioScore0=T.g_ratio;

load('g-ratio_Score1.mat')
g_ratioScore1=T.g_ratio;

load('g-ratio_Score2.mat')
g_ratioScore2=T.g_ratio;

load('g-ratio_Score3.mat')
g_ratioScore3=T.g_ratio;

figure(1), hold on
subplot(1,4,1), hold on
boxchart(g_ratioScore0,'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioScore0, 25);
Q3 = prctile(g_ratioScore0, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioScore0 >= lowerBound & g_ratioScore0 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioScore0(nonOutliers))), g_ratioScore0(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

ylim([0 1])
xticklabels({'No\newlinedamage'})
ylabel('Myelin g-ratio')
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,2), hold on
boxchart(g_ratioScore1, 'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)


% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioScore1, 25);
Q3 = prctile(g_ratioScore1, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioScore1 >= lowerBound & g_ratioScore1 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioScore1(nonOutliers))), g_ratioScore1(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')


xticklabels({'Mild\newlinedamage'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 1])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,3), hold on
boxchart(g_ratioScore2, 'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioScore2, 25);
Q3 = prctile(g_ratioScore2, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioScore2 >= lowerBound & g_ratioScore2 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioScore2(nonOutliers))), g_ratioScore2(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'Moderate\newlinedamage'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 1])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,4), hold on
boxchart(g_ratioScore3, 'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)


% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(g_ratioScore3, 25);
Q3 = prctile(g_ratioScore3, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = g_ratioScore3 >= lowerBound & g_ratioScore3 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(g_ratioScore3(nonOutliers))), g_ratioScore3(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'High\newlinedamage'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 1])
set(gca,'FontSize',18,'FontWeight','bold')

%% Kruskal-Wallis test + Dunn's post hoc test for myelin g-ratio or thickness (grouped by scores)
%g-ratio scores

% folderPath = '...';  %add right path
% cd(folderPath); % enter folder
% 
% load('g-ratio_Score0.mat')
% g_ratioScore0=T.g_ratio;
% 
% load('g-ratio_Score1.mat')
% g_ratioScore1=T.g_ratio;
% 
% load('g-ratio_Score2.mat')
% g_ratioScore2=T.g_ratio;
% 
% load('g-ratio_Score3.mat')
% g_ratioScore3=T.g_ratio;

%myelin thickness scores

% folderPath = '...';  %add right path
% cd(folderPath); % enter folder
% 
% load('thickness_Score0.mat')
% thickness_Score0=T.Thickness;
% 
% load('thickness_Score1.mat')
% thickness_Score1=T.Thickness;
% 
% load('thickness_Score2.mat')
% thickness_Score2=T.Thickness;
% 
% load('thickness_Score3.mat')
% thickness_Score3=T.Thickness;

% Create a grouped data array
% data = [g_ratioScore0; g_ratioScore1; g_ratioScore2; g_ratioScore3];
data = [thickness_Score0; thickness_Score1; thickness_Score2; thickness_Score3];

% Create group labels for g-ratio
% group = [ones(length(g_ratioScore0),1); 
%          2*ones(length(g_ratioScore1),1); 
%          3*ones(length(g_ratioScore2),1); 
%          4*ones(length(g_ratioScore3),1)];

% Create group labels for myelin thickness
group = [ones(length(thickness_Score0),1); 
         2*ones(length(thickness_Score1),1); 
         3*ones(length(thickness_Score2),1); 
         4*ones(length(thickness_Score3),1)];

% Perform Kruskal-Wallis test
[p_kw, ~, stats] = kruskalwallis(data, group, 'off');

% If Kruskal-Wallis is significant, perform Dunn's test
if p_kw < 0.05
    % Perform Dunn’s test (requires FDR correction toolbox)
    c = multcompare(stats, 'CType', 'dunn-sidak');
    
    % Extract p-values
    p_values = c(:,6);
    
    % Apply Bonferroni correction
    num_comparisons = length(p_values);
    p_corrected = min(p_values * num_comparisons, 1);  % Ensure p-values don't exceed 1
    
    % Display results
    fprintf('Kruskal-Wallis p-value: %.5f\n', p_kw);
    fprintf('Pairwise comparisons (Dunn’s test with Bonferroni correction):\n');
    disp(table(c(:,1), c(:,2), p_values, p_corrected, ...
        'VariableNames', {'Group1', 'Group2', 'Raw_p', 'Bonferroni_p'}));
else
    fprintf('Kruskal-Wallis test is not significant (p = %.5f). No need for post-hoc test.\n', p_kw);
end
%% Kruskal-Wallis test + Dunn's post hoc test for myelin g-ratio and thickness (grouped by disease) (sample size N is big >10)
%g-ratio 

folderPath = '...'; %add right path 
cd(folderPath); % enter folder

load('All_g-ratio_CTRL.mat')
g_ratioCTRL=allg_ratio;

load('All_g-ratio_PD.mat')
g_ratioPD=allg_ratio;

load('All_g-ratio_DLB.mat')
g_ratioDLB=allg_ratio;

load('All_g-ratio_MSA.mat')
g_ratioMSA=allg_ratio;


%myelin thickness 

% folderPath = '...';  %add right path
% cd(folderPath); % enter folder
% 
% load('All_thick_CTRL.mat')
% thickness_CTRL=allThickness;
% 
% load('All_thick_PD.mat')
% thickness_PD=allThickness;
% 
% load('All_thick_DLB.mat')
% thickness_DLB=allThickness;
% 
% load('All_thick_MSA.mat')
% thickness_MSA=allThickness;

% Create a grouped data array
data = [g_ratioCTRL; g_ratioPD; g_ratioDLB; g_ratioMSA];
%data = [thickness_CTRL; thickness_PD; thickness_DLB; thickness_MSA];

% Create group labels for g-ratio
group = [ones(length(g_ratioCTRL),1); 
         2*ones(length(g_ratioPD),1); 
         3*ones(length(g_ratioDLB),1); 
         4*ones(length(g_ratioMSA),1)];

% Create group labels for myelin thickness
% group = [ones(length(thickness_CTRL),1); 
%          2*ones(length(thickness_PD),1); 
%          3*ones(length(thickness_DLB),1); 
%          4*ones(length(thickness_MSA),1)];

% Perform Kruskal-Wallis test
[p_kw, ~, stats] = kruskalwallis(data, group, 'off');

% If Kruskal-Wallis is significant, perform Dunn's test
if p_kw < 0.05
    % Perform Dunn’s test (requires FDR correction toolbox)
    c = multcompare(stats, 'CType', 'dunn-sidak');
    
    % Extract p-values
    p_values = c(:,6);
    
    % Apply Bonferroni correction
    num_comparisons = length(p_values);
    p_corrected = min(p_values * num_comparisons, 1);  % Ensure p-values don't exceed 1
    
    % Display results
    fprintf('Kruskal-Wallis p-value: %.5f\n', p_kw);
    fprintf('Pairwise comparisons (Dunn’s test with Bonferroni correction):\n');
    disp(table(c(:,1), c(:,2), p_values, p_corrected, ...
        'VariableNames', {'Group1', 'Group2', 'Raw_p', 'Bonferroni_p'}));
else
    fprintf('Kruskal-Wallis test is not significant (p = %.5f). No need for post-hoc test.\n', p_kw);
end

%% Group tables for myelin thickness

% Set the folder path
folderPath = '...'; %add right path
cd(folderPath); % enter folder


% Get a list of all files in the folders
fileList = dir(fullfile(folderPath, '*.mat')); 

% Initialize an empty table with column names
Table_thickness = table();  % Create an empty table

for i = 1:length(fileList)   

    % Get the full path of the current file
    fileName = fileList(i).name;
    filePath = fullfile(folderPath, fileName);
    T=load(fileName);
    mean_thickness=mean(T.T.Thickness);
    %total_thickness=T.T.Thickness;

    % Split the filename at the first occurrence of '_'
    parts = split(fileName, '_');
    % Get the part after the '_'
    shortfileName = parts{2};  % The part after '_'

     % Split the filename at the first occurrence of '.'
    parts2 = split(shortfileName, '.');
    % Get the part before the '.'
    shortfileName2 = parts2{1};  % The part before '.'

    % Generate the letter (char) for the current row
    letter = char(shortfileName);  % 'A', 'B', 'C', ...
    
    % Generate the corresponding number (1, 2, 3, ...)
    number = mean_thickness;
    
    % Create a new row as a table
    newRow = table({letter}, number);  % Note the cell {} for strings
    
    % Append the new row to the table
    Table_thickness = [Table_thickness; newRow];  % Append row by row

end

Table_thickness.Properties.VariableNames = {'DonorID', 'Mean_thickness'};  %change column name to match info
% Display the table
disp(Table_thickness);
save('thickness_score0.mat', 'Table_thickness');

%% Total thickness (not averaged by patient)
% Set the folder path
folderPath = '...'; %add right path
cd(folderPath); % enter folder

filePattern = fullfile(folderPath, '*.mat'); 
fileList = dir(filePattern);

allThickness = []; % Initialize empty vector
thicknessCell = cell(length(fileList), 1);

for k = 1:length(fileList)
    fileName = fullfile(folderPath, fileList(k).name);
    loadedData = load(fileName);
    
    tableName = fieldnames(loadedData);
    tempTable = loadedData.(tableName{1});
    
    allThickness = [allThickness; tempTable.Thickness]; % Concatenate thickness values
end

save('All_thick_CTRL.mat', 'allThickness');

%% Total g-ratio (not averaged by patient)
% Set the folder path
folderPath = '...'; %add right path
cd(folderPath); % enter folder

filePattern = fullfile(folderPath, '*.mat'); 
fileList = dir(filePattern);

allg_ratio = []; % Initialize empty vector
g_ratioCell = cell(length(fileList), 1);

for k = 1:length(fileList)
    fileName = fullfile(folderPath, fileList(k).name);
    loadedData = load(fileName);
    
    tableName = fieldnames(loadedData);
    tempTable = loadedData.(tableName{1});
    
    allg_ratio = [allg_ratio; tempTable.g_ratio]; % Concatenate thickness values
end

save('All_g-ratio_PD.mat', 'allg_ratio');

%% box plot from table myelin thickness (disease groups)
% Set the folder path
folderPath = '...';  %add right path
cd(folderPath); % enter folder

% load('thickness_CTRL.mat')
% thickness_CTRL=Table_thickness.Mean_thickness;
% 
% load('thickness_PD.mat')
% thickness_PD=Table_thickness.Mean_thickness;
% 
% load('thickness_DLB.mat')
% thickness_DLB=Table_thickness.Mean_thickness;
% 
% load('thickness_MSA.mat')
% thickness_MSA=Table_thickness.Mean_thickness;

load('All_thick_CTRL.mat')
thickness_CTRL=allThickness;

load('All_thick_PD.mat')
thickness_PD=allThickness;

load('All_thick_DLB.mat')
thickness_DLB=allThickness;

load('All_thick_MSA.mat')
thickness_MSA=allThickness;
% 


figure(3), hold on
subplot(1,4,1), hold on
boxchart(thickness_CTRL,'BoxFaceColor',[0.47,0.67,0.19], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_CTRL, 25);
Q3 = prctile(thickness_CTRL, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_CTRL >= lowerBound & thickness_CTRL <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_CTRL(nonOutliers))), thickness_CTRL(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

ylim([0 3000])
xticklabels({'CTRL'})
ylabel('Myelin thickness (nm)')
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,2), hold on
boxchart(thickness_PD, 'BoxFaceColor',[0.96,0.55,0.37], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_PD, 25);
Q3 = prctile(thickness_PD, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_PD >= lowerBound & thickness_PD <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_PD(nonOutliers))), thickness_PD(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'PD'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 3000])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,3), hold on
boxchart(thickness_DLB, 'BoxFaceColor',[0.91,0.66,0.08], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_DLB, 25);
Q3 = prctile(thickness_DLB, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_DLB >= lowerBound & thickness_DLB <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_DLB(nonOutliers))), thickness_DLB(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'DLB'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 3000])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,4), hold on
boxchart(thickness_MSA, 'BoxFaceColor',[0.94,0.21,0.21], 'BoxWidth', 0.9)


% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_MSA, 25);
Q3 = prctile(thickness_MSA, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_MSA >= lowerBound & thickness_MSA <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_MSA(nonOutliers))), thickness_MSA(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'MSA'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 3000])
set(gca,'FontSize',18,'FontWeight','bold')

%% box plot from table myelin thickness (damage scores)
% Set the folder path
folderPath = '...';  %add right path
cd(folderPath); % enter folder

load('thickness_Score0.mat')
thickness_Score0=T.Thickness;

load('thickness_Score1.mat')
thickness_Score1=T.Thickness;

load('thickness_Score2.mat')
thickness_Score2=T.Thickness;

load('thickness_Score3.mat')
thickness_Score3=T.Thickness;

 
figure(3), hold on
subplot(1,4,1), hold on
boxchart(thickness_Score0,'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_Score0, 25);
Q3 = prctile(thickness_Score0, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_Score0 >= lowerBound & thickness_Score0 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_Score0(nonOutliers))), thickness_Score0(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

ylim([0 3000])
xticklabels({'No\newlinedamage'})
ylabel('Myelin thickness (nm)')
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,2), hold on
boxchart(thickness_Score1, 'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_Score1, 25);
Q3 = prctile(thickness_Score1, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_Score1 >= lowerBound & thickness_Score1 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_Score1(nonOutliers))), thickness_Score1(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'Mild\newlinedamage'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 3000])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,3), hold on
boxchart(thickness_Score2, 'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_Score2, 25);
Q3 = prctile(thickness_Score2, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_Score2 >= lowerBound & thickness_Score2 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_Score2(nonOutliers))), thickness_Score2(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'Moderate\newlinedamage'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 3000])
set(gca,'FontSize',18,'FontWeight','bold')

subplot(1,4,4), hold on
boxchart(thickness_Score3, 'BoxFaceColor',[0 0.4470 0.7410], 'BoxWidth', 0.9)

% Identify non-outliers
% Using 1.5*IQR rule (same as boxplot)
Q1 = prctile(thickness_Score3, 25);
Q3 = prctile(thickness_Score3, 75);
IQR = Q3 - Q1;
lowerBound = Q1 - 1.5 * IQR;
upperBound = Q3 + 1.5 * IQR;

nonOutliers = thickness_Score3 >= lowerBound & thickness_Score3 <= upperBound;

%Plot only non-outlier dots (jittered for visibility) as outliers already
%plotted with boxchart
scatter(ones(size(thickness_Score3(nonOutliers))), thickness_Score3(nonOutliers), 'filled','jitter','on', 'jitterAmount',0.15, 'MarkerEdgeAlpha',0.6, 'MarkerFaceAlpha', 0.3,'MarkerFaceColor', 'k')

xticklabels({'High\newlinedamage'})
set(gca,'ytick',[])     %removes yticks
set(gca,'YColor','none')     %removes y axis
ylim([0 3000])
set(gca,'FontSize',18,'FontWeight','bold')


%% labeled images transfer to folders divided by score

% Define folder paths
source_folder = '...'; % Source folder containing labeled files

folder1 = '...'; % Change this to actual folder path (Score 3)
folder2 = '...'; % Destination folder (Score 3)

folder3 = '...'; % Change this to actual folder path (Score 2)
folder4 = '...'; % Destination folder (Score 2)

folder5 = '...'; % Change this to actual folder path (Score 1)
folder6 = '...'; % Destination folder (Score 1)

folder7 = '...'; % Change this to actual folder path
folder8 = '...'; % Destination folder

% Ensure folder2 exists
if ~exist(folder2, 'dir')
    mkdir(folder2);
end

% Ensure folder4 exists
if ~exist(folder4, 'dir')
    mkdir(folder4);
end

% Ensure folder6 exists
if ~exist(folder6, 'dir')
    mkdir(folder6);
end

% Ensure folder8 exists
if ~exist(folder8, 'dir')
    mkdir(folder8);
end

% Get list of image files in folder1
imageFiles1 = dir(fullfile(folder1, '*.tif')); 
% Get list of image files in folder3
imageFiles3 = dir(fullfile(folder3, '*.tif')); 
% Get list of image files in folder5
imageFiles5 = dir(fullfile(folder5, '*.tif')); 
% Get list of image files in folder7
imageFiles7 = dir(fullfile(folder7, '*.tif')); 

% Loop through each file in folder1
for i = 1:length(imageFiles1)
   
    [~, baseName, ~] = fileparts(imageFiles1(i).name); % Extract base filename
    
    % Create the expected labeled filename
    labeledFile = [baseName, '_labeled_thickness.tif']; % Change extension if needed
    
    % Full path of labeled file in source_folder
    labeledFilePath = fullfile(source_folder, labeledFile);
    
    % Destination path in folder2
    destPath = fullfile(folder2, labeledFile);
    
    % Check if the labeled file exists in source_folder
    if exist(labeledFilePath, 'file')
        % Copy file to folder2
        copyfile(labeledFilePath, destPath);
        fprintf('Copied: %s\n', labeledFile);
    else
        fprintf('File not found: %s\n', labeledFile);
    end

end

baseName=0;
labeledFile=0;
labeledFilePath=0;
destPath=0;

% Loop through each file in folder3
for i = 1:length(imageFiles3)
    [~, baseName, ~] = fileparts(imageFiles3(i).name); % Extract base filename
    
    % Create the expected labeled filename
    labeledFile = [baseName, '_labeled_thickness.tif']; % Change extension if needed
    
    % Full path of labeled file in source_folder
    labeledFilePath = fullfile(source_folder, labeledFile);
    
    % Destination path in folder4
    destPath = fullfile(folder4, labeledFile);
    
    % Check if the labeled file exists in source_folder
    if exist(labeledFilePath, 'file')
        % Copy file to folder4
        copyfile(labeledFilePath, destPath);
        fprintf('Copied: %s\n', labeledFile);
    else
        fprintf('File not found: %s\n', labeledFile);
    end
end

baseName=0;
labeledFile=0;
labeledFilePath=0;
destPath=0;

% Loop through each file in folder5
for i = 1:length(imageFiles5)
    [~, baseName, ~] = fileparts(imageFiles5(i).name); % Extract base filename
    
    % Create the expected labeled filename
    labeledFile = [baseName, '_labeled_thickness.tif']; % Change extension if needed
    
    % Full path of labeled file in source_folder
    labeledFilePath = fullfile(source_folder, labeledFile);
    
    % Destination path in folder6
    destPath = fullfile(folder6, labeledFile);
    
    % Check if the labeled file exists in source_folder
    if exist(labeledFilePath, 'file')
        % Copy file to folder6
        copyfile(labeledFilePath, destPath);
        fprintf('Copied: %s\n', labeledFile);
    else
        fprintf('File not found: %s\n', labeledFile);
    end
end

baseName=0;
labeledFile=0;
labeledFilePath=0;
destPath=0;

% Loop through each file in folder7
for i = 1:length(imageFiles7)
    [~, baseName, ~] = fileparts(imageFiles7(i).name); % Extract base filename
    
    % Create the expected labeled filename
    labeledFile = [baseName, '_labeled_thickness.tif']; % Change extension if needed
    
    % Full path of labeled file in source_folder
    labeledFilePath = fullfile(source_folder, labeledFile);
    
    % Destination path in folder8
    destPath = fullfile(folder8, labeledFile);
    
    % Check if the labeled file exists in source_folder
    if exist(labeledFilePath, 'file')
        % Copy file to folder8
        copyfile(labeledFilePath, destPath);
        fprintf('Copied: %s\n', labeledFile);
    else
        fprintf('File not found: %s\n', labeledFile);
    end
end

baseName=0;
labeledFile=0;
labeledFilePath=0;
destPath=0;


%% correlation matrix

%data=table(0);  % data for correlation matrix

%variableNames = cell(1, 11);  % cell array with name of the variables in
%for correlation matrix


% Compute the correlation matrix. Since the matrix is composed of binary,
% ordinal and continuous variables, then the correlation method has to be properly
% chosen according to the pair of variables to correlate. 

%  Binary vs Ordinal  -> Spearman rank correlation
%  Binary vs Continuous -> Point-Biserial (equivalent to Pearson)
%  Ordinal vs Continuous -> Spearman rank correlation
%  Binary vs Binary -> Phi coefficient (mathematically equivalent to Pearson correlation) 
%  Ordinal vs Ordinal -> Spearman rank correlation
%  Continuous vs Continuous -> Pearson correlation (but Spearman if data not normally distributed)


% Define column types
binaryCols = [2,9];          % Column(s) with binary variables
ordinalCols = [5,6,7,10];         % Column(s) with ordinal variables
continuousCols = [1,3,4,8,11];   % Column(s) with continuous variables

% Initialize the correlation matrix
numVars = size(data, 2);
correlationMatrix = ones(numVars, numVars);

% Loop through each pair of columns
for i = 1:numVars
    for j = i+1:numVars
        % Check variable types and compute the correct correlation
        if ismember(i, binaryCols) && ismember(j, binaryCols)
            % Binary vs Binary -> Phi coefficient (mathematically equivalent to Pearson)
            [rho, pVal] = corr(data{:,i}, data{:,j}, 'Rows', 'pairwise','Type', 'Pearson');
        elseif ismember(i, binaryCols) && ismember(j, continuousCols)
            % Binary vs Continuous -> Point-Biserial (equivalent to Pearson)
            [rho, pVal] = corr(data{:,i}, data{:,j}, 'Rows', 'pairwise','Type', 'Pearson');  
        else 
            % Binary vs Ordinal
            % Ordinal vs Ordinal
            % Ordinal vs Continuous 
            % Continuous vs Continuous

            [rho, pVal] = corr(data{:,i}, data{:,j}, 'Rows', 'pairwise','Type', 'Spearman');  
        end
        % Store correlation value in matrix
        correlationMatrix(i,j) = rho;
        correlationMatrix(j,i) = rho;  % The matrix is symmetric

        pValues(i,j) = pVal; 
        pValues(j,i) = pVal;  % The matrix is symmetric
    end
end


%Define significance level
alpha = 0.05;

%Visualize the correlation matrix using heatmap
figure(2);
imagesc(correlationMatrix);
colorbar;
title('Correlation Matrix');
xticks(1:size(correlationMatrix, 2));
yticks(1:size(correlationMatrix, 1));
set(gca,'FontSize',20,'FontWeight','bold')

% Add variable names as axis labels
xticklabels(variableNames);
yticklabels(variableNames);
axis square

% Adjust axis labels' angle for readability
xtickangle(45);

% Adjust color map
colormap('jet');  % You can change 'cool' to other color maps like 'jet', 'hot', etc.
caxis([-1 1]);

% Highlight significant correlations (p-value <= 0.05)
hold on;

% Get the size of the matrix (for defining the upper triangle)
[nRows, nCols] = size(correlationMatrix);

% Loop over the upper triangle (excluding diagonal)
for row = 1:nRows
    for col = row+1:nCols  % Only consider elements above the diagonal
         if pValues(row, col) < 0.05
           
            % Display the correlation value in the upper triangle if p-value < 0.05
        text(col, row, num2str(correlationMatrix(row, col), '%.2f'), 'Color', 'black', 'FontSize', 30, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
         end
        
    end
end

% Loop over the lower triangle (excluding diagonal)
for row = 2:nRows
    for col = 1:row-1  % Only consider elements below the diagonal
        % Check if the p-value is less than 0.05
        if pValues(row, col) < 0.05
            if pValues(row, col) < 0.001
                % Display the p-value in the lower triangle if p-value < 0.05
            text(col, row, '<0.001', 'Color', 'black', 'FontSize', 30, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            else
            % Display the p-value in the lower triangle if p-value < 0.05
            text(col, row, num2str(pValues(row, col), '%.3f'), 'Color', 'black', 'FontSize', 30, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            end
        end
    end
end


%% adjust p-values Correlation matrix considering multiple comparisons (Benjamini-Hochberg adjustment)

% Assume pValues is the matrix with p-values
numVars = size(pValues, 1);

% Flatten the upper triangle of pValues (excluding diagonal)
upperIdx = find(triu(ones(numVars), 1)); % Get indices of upper triangle
pValuesVec = pValues(upperIdx);          % Extract upper triangle values

% Step 1: Sort p-values in ascending order
[sortedP, sortIdx] = sort(pValuesVec);   
m = length(sortedP); % Total number of tests (non-redundant comparisons)

% Step 2: Compute BH critical values
bhThresholds = (1:m)' / m * 0.05;  % 0.05 is the FDR level

% Step 3: Find the largest p-value that is below its threshold
bhSignificant = (sortedP <= bhThresholds); 
if any(bhSignificant)
    maxIdx = find(bhSignificant, 1, 'last'); % Last significant index
    bhCutoff = sortedP(maxIdx); % The threshold p-value for significance
else
    bhCutoff = NaN; % No significant p-values
end

% Step 4: Compute adjusted p-values (Benjamini-Hochberg formula)
adjustedPVec = sortedP .* (m ./ (1:m)'); % Apply BH adjustment
adjustedPVec = min(1, adjustedPVec); % Ensure p-values do not exceed 1

% Reorder adjusted p-values back to original order
adjustedPValuesVec = NaN(size(pValuesVec));
adjustedPValuesVec(sortIdx) = adjustedPVec; % Restore correct order

% Step 5: Convert adjusted p-values back to matrix
adjustedPValues = NaN(size(pValues));
adjustedPValues(upperIdx) = adjustedPValuesVec; 
adjustedPValues = triu(adjustedPValues) + triu(adjustedPValues,1)'; % Make symmetric

% Step 6: Create significance matrix (binary) using adjusted p-values
adjustedSignificance = false(size(pValues)); % Initialize all as false
adjustedSignificance(upperIdx) = adjustedPValuesVec <= 0.05; % Apply cutoff
adjustedSignificance = adjustedSignificance | adjustedSignificance'; % Make symmetric

% Display results
disp('BH cutoff for significance:');
disp(bhCutoff);

disp('Adjusted significance matrix:');
disp(adjustedSignificance);

% Extract indices of significant correlations (upper triangle only)
[rowIdx, colIdx] = find(triu(adjustedSignificance, 1));

% Display significant correlations with variable names, correlation values, and adjusted p-values
disp('Significant correlation pairs:');
disp('Variable 1   |   Variable 2   | Correlation | Adjusted P-value');
disp('------------------------------------------------------------');

for k = 1:length(rowIdx)
    var1 = variableNames{rowIdx(k)}; % Get variable name for first variable
    var2 = variableNames{colIdx(k)}; % Get variable name for second variable
    corrValue = correlationMatrix(rowIdx(k), colIdx(k)); % Get correlation value
    pAdj = adjustedPValues(rowIdx(k), colIdx(k)); % Get adjusted p-value

    % Display formatted output
    fprintf('%-12s | %-12s | %.3f       | %.5f\n', var1, var2, corrValue, pAdj);
end

%% visualize correlation matrix with adjusted p-values (after Benjamini-Hochberg)

%Visualize the correlation matrix using heatmap
figure(3);
imagesc(correlationMatrix);
colorbar;
title('Correlation Matrix');
xticks(1:size(correlationMatrix, 2));
yticks(1:size(correlationMatrix, 1));
set(gca,'FontSize',20,'FontWeight','bold')

% Add variable names as axis labels
%variableNames = data.Properties.VariableNames(1:end-1);  % Adjust as needed
xticklabels(variableNames);
yticklabels(variableNames);
axis square


% Adjust axis labels' angle for readability
xtickangle(45);

% Adjust color map
colormap('jet');  % You can change 'cool' to other color maps like 'jet', 'hot', etc.
caxis([-1 1]);


% Highlight significant correlations (p-value <= 0.05)
hold on;

% Get the size of the matrix (for defining the upper triangle)
[nRows, nCols] = size(correlationMatrix);

% Loop over the upper triangle (excluding diagonal)
for row = 1:nRows
    for col = row+1:nCols  % Only consider elements above the diagonal
         if adjustedPValues(row, col) < 0.05
           
            % Display the correlation value in the upper triangle if p-value < 0.05
        text(col, row, num2str(correlationMatrix(row, col), '%.2f'), 'Color', 'black', 'FontSize', 20, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
         end
        
    end
end

% Loop over the lower triangle (excluding diagonal)
for row = 2:nRows
    for col = 1:row-1  % Only consider elements below the diagonal
        % Check if the p-value is less than 0.05
        if adjustedPValues(row, col) < 0.05
            if adjustedPValues(row, col) < 0.001
                % Display the p-value in the lower triangle if p-value < 0.05
            text(col, row, '<0.001', 'Color', 'black', 'FontSize', 20, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            else
            % Display the p-value in the lower triangle if p-value < 0.05
            text(col, row, num2str(adjustedPValues(row, col), '%.3f'), 'Color', 'black', 'FontSize', 20, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            end
        end
    end
end
