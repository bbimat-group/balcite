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

fn_inp = {'Fig1_A_DFT_FormEnergy_ACBC.csv','Fig1_B_DFT_FormEnergy_R3c_calcite.csv','Fig1_C_DFT_FormEnergy_Pnma_aragonite.csv','Fig1_D_DFT_FormEnergy_R3m.csv','Fig1_E_DFT_FormEnergy_R3m_balcite.csv','Fig1_A_inferred_FEcurve_ACBC.csv','Fig1_B_inferred_FEcurve_R3c_calcite.csv','Fig1_C_inferred_FEcurve_Pnma_aragonite.csv','Fig1_D_inferred_FEcurve_R3m.csv','Fig1_E_inferred_FEcurve_R3m_balcite.csv'};
fn_out = 'Fig1';

colors={'black','red',[105, 65, 190]./255,[100, 200, 100]./255,[55, 175, 240]./255};

% % get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableTypes = ["double", "double"];
opts.VariableNames = ["x", "Energy"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

for ii=1:4
    T{ii} = readtable([fullfile(pn,fn_inp{ii})],opts);
end

clear opts
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableTypes = ["double", "double","string"];
opts.VariableNames = ["x", "Energy","flip"];

T{5} = readtable([fullfile(pn,fn_inp{5})],opts);
%'Format','%s%s'

opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [3, Inf];

% Specify column names and types
opts.VariableTypes = ["double", "double"];
opts.VariableNames = ["x", "y"];

for ii=6:length(fn_inp)
    T{ii} = readtable([fullfile(pn,fn_inp{ii})],opts);
end

clear opts

%% Plot data
figure('Units','Inches','Position',[1 1 5.5 4.25]*TrueInchConversion);
t = tiledlayout(2,3);

%plot 1 a-d
ax1=[];
for ii = 1:4
    ax(ii) = nexttile;
    hold on;
    plot(T{ii}.x,T{ii}.Energy,'k.','MarkerSize',10);
    ylim([0 30])
    if ii==4
        ylim([0 60])
    end
    plot(T{ii+5}.x,T{ii+5}.y,'color',colors{ii},'LineWidth',1);
end

%plot 1 e
ax(5) = nexttile;
s_rows = T{5}.flip=='s';
r_rows = T{5}.flip=='r';
plot(T{5}.x(s_rows),T{5}.Energy(s_rows),'k.','MarkerSize',10, 'DisplayName','sequentially flipped'); hold on
plot(T{5}.x(r_rows),T{5}.Energy(r_rows),'kd','MarkerSize',3,'LineWidth',1, 'DisplayName','randomly flipped');
h=plot(T{10}.x,T{10}.y,'color',colors{5},'LineWidth',1);
set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
ylim([0 30]);
legend('location','southeast');

%plot 1 f
ax(6) = nexttile;
for ii=1:5
    hold on;
    plot(T{ii+5}.x,T{ii+5}.y,'color',colors{ii},'LineWidth',1);
    ylim([0 30])
end
legend([{'ACBC','R$\bar{3}$c','pnma','R3m','R$\bar{3}$m'}],'Interpreter','Latex','location','northwest')

set(ax, 'Box', 'on');
for ii=1:6
    ax(ii).TickDir = 'out';
    ax(ii).YLabel.String='\DeltaH_{DFT} = T\DeltaS_{config} [kJ/mol]';
    ax(ii).XLabel.String='x';
    ax(ii).XTick = [0:0.2:1];
end

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end   
