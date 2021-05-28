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

fn_inp = {'FigS7_x_vs_half_life.csv'};
fn_out = 'FigS7';

opts = delimitedTextImportOptions("NumVariables", 8);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

opts2=opts; %for unit import
opts2.DataLines = [2, 2];
opts2.Delimiter = opts.Delimiter;

% Specify column names and types
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double"];
opts.VariableNames = ["x_f",  "tau_low", "tau_up", "tau_half", "fit_slope", "fit_slope_CI", "fit_intercept", "fit_intercept_CI"];
opts2.VariableNames = opts.VariableNames;
opts2.VariableTypes = ["string", "string","string", "string","string", "string","string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

T{1} = readtable([fullfile(pn,fn_inp{1})],opts);
U = readtable([fullfile(pn,fn_inp{1})],opts2);
T{1}.Properties.VariableUnits = U{:,:};
    
% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

clear opts

%% Plot data
figure('Units','Inches','Position',[1 1 2.3 2.25]*TrueInchConversion)

% plot data
errorbar(T{1}.x_f,T{1}.tau_half,T{1}.tau_half-T{1}.tau_low,T{1}.tau_up-T{1}.tau_half,'LineStyle','none');
hold on;

% plot fit curve & CIs
xvals = [0.15:0.005:0.55]';
ft = fittype('a*log(x)+c');
[curve,gof] = fit(T{1}.x_f,T{1}.tau_half,ft);
p11 = predint(curve,xvals,0.95,'functional','on');
plot(xvals,curve(xvals),'m-')
plot(xvals,p11,'m--')

ax1=gca;
xlim([0.1 0.6])
ylim([1 2.2])
ax1.TickDir='out';
legend({'95% CI',sprintf('%.3f*log(%s)+%.3f',curve.a,'x_f',curve.c)})

xlabel('x_f')
ylabel(['half-life, \tau_{1/2} [',T{1}.Properties.VariableUnits{4},']'])

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end   
