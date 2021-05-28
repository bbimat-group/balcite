%% clean up
close all
clear variables
clc

%% USER INPUTS 
% Files must be in same directory as script
% --- to set the path manually, replace the value of pn with the containing folder path --- 
pn = pwd;

% Output flag for saving figure
save_figure = false; 
% END USER INPUTS

% Declare constants

fn_inp = {'FigS6_B_survival_ACBC_x144_trial1.csv','FigS6_B_survival_ACBC_x144_trial2.csv','FigS6_B_survival_ACBC_x144_trial3.csv','FigS6_C_survival_ACBC_x167_trial1.csv','FigS6_C_survival_ACBC_x167_trial2.csv','FigS6_C_survival_ACBC_x167_trial3.csv','FigS6_D_survival_ACBC_x255_trial1.csv','FigS6_D_survival_ACBC_x255_trial2.csv','FigS6_E_survival_ACBC_x345_trial1.csv','FigS6_E_survival_ACBC_x345_trial2.csv','FigS6_E_survival_ACBC_x345_trial3.csv','FigS6_F_survival_ACBC_x534_trial1.csv','FigS6_F_survival_ACBC_x534_trial2.csv','FigS6_F_survival_ACBC_x534_trial3.csv','FigS6_A_survival_ACC_trial1.csv','FigS6_A_survival_ACC_trial2.csv','FigS6_A_survival_ACC_trial3.csv','FigS6_A_survival_ACC_trial4.csv','FigS6_A_survival_ACC_trial5.csv'};
fn_out = 'FigS9';

% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

%% Import data 

opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableTypes = ["double", "double", "double"];
opts.VariableNames = ["t_event", "cens", "freq"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";


for ii=1:length(fn_inp)
    T{ii} = readtable([fullfile(pn,fn_inp{ii})],opts);
end



%% plot

% define default time axes for all experiments
tv_single = {0:0.5:45;0:0.5:45;0:0.5:45;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;0:1/60:3;...
0:0.5:90;0:0.5:90;0:0.5:90;0:0.5:90;0:0.5:90};

ll = [2,3,5,6];
ind = 1;
mm = 1;
aa = 1;
bb = 1;

figure('Units','Inches','Position',[1 1 6.75 3]*TrueInchConversion);
set(0,'DefaultAxesColorOrder','default');
hold on;
for ii = 1:length(T)
    fname = erase(erase(fn_inp{ii},'FigS6_'),'.csv');
    
    if contains(fname, 'ACC')
        subplot(2,3,1);
        hold on
        x_f = 0;
        corner_label = sprintf('x_f=%d',x_f);
        leg_entry = sprintf('Trial %d',aa);
        aa = aa + 1;
        fname = erase(fname,'A_survival_');
    elseif contains(fname, '255')
        subplot(2,3,4);
        hold on
        x_f = 0.255;
        corner_label = sprintf('x_f=%0.3f',x_f);
        leg_entry = sprintf('Trial %d',bb);
        bb = bb + 1;
        fname = erase(fname,'D_survival_');
    else
        subplot(2,3,ll(ind));
        hold on
        x_f3 = [0.144,0.167,0.345,0.534];
        letters = 'BCEF';
        letter = letters(ind);
        x_f = x_f3(ind);
        corner_label = sprintf('x_f=%0.3f',x_f);
        leg_entry = sprintf('Trial %d',mm);
        fname = erase(fname,[letter,'_survival_']);
        if mm == 3
            ind = ind+1;
            mm = 0;
        end
        mm = mm+1;
    end
    
    [emp_S, emp_t] = ecdf(T{ii}.t_event,'censoring',T{ii}.cens,'frequency',T{ii}.freq,'function',"survivor"); hold on
    emp_t(1) = 0;
    if T{ii}.cens(end) ~= 0
        emp_t(end+1) = T{ii}.t_event(end);
        emp_S(end+1) = emp_S(end);
    end
    s = stairs(emp_t,emp_S);
    s.DisplayName = leg_entry;
    ax = gca;
    ax.TickDir = 'out';
    ax.XLim = tv_single{ii}([1,end]);
    ax.XMinorTick = 'on';
    ax.YMinorTick = 'on';
    ylimit=get(gca,'ylim');
    xlimit=get(gca,'xlim');
    if mm==3 | x_f == 0.255 | x_f == 0
        text(xlimit(2)*.99,ylimit(2),corner_label,'HorizontalAlignment','right','VerticalAlignment','top');
    end
    title(fname(1:end-7),'Interpreter','none')        
    ylabel('N_0/N')
    xlabel('time [hr]')
    
    box on
    legend('Trial 1','Trial 2','Trial 3','Trial 4','Trial 5','Location','SouthWest')
end

%

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end   
