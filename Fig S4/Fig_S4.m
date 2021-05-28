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

fn_inp = {'FigS4_A_x_vs_RamanShift.csv','FigS4_B_Ba_concentrations.csv'};
fn_out = 'FigS4';

% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

opts = delimitedTextImportOptions("NumVariables", 9);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableTypes = ["double", "double","double", "double","double", "double","double", "double", "double"];
opts.VariableNames = ["x_ICPData", "x_error_ICP","y_XRFData", "y_error_XRF","y_EDSData", "y_error_EDS","x_RamanDrops","x_error_RamanDrops","y_RamanDrops"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

T{2} = readtable([fullfile(pn,fn_inp{2})],opts);

 
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableTypes = ["double", "double","double", "double"];
opts.VariableNames = ["x_Ba_XRF", "v1_raman_peakfit","fit_slope", "fit_intercept"];

T{1} = readtable([fullfile(pn,fn_inp{1})],opts); 

clear opts

%% Plot data
figure('Units','Inches','Position',[1 1 4.5 2]*TrueInchConversion);

% plot raman calibration curve (v1 peak vs x)
subplot(1,2,1);
plot(T{1}.x_Ba_XRF,T{1}.v1_raman_peakfit,'.','MarkerSize',10,'DisplayName','Bulk ACBC'); hold on; 
x_vals = [0:0.01:max(T{1}.x_Ba_XRF)];
plot(x_vals,T{1}.fit_slope(1)*x_vals+T{1}.fit_intercept(1),'k--','DisplayName',sprintf('y=%.2fx+%.2f',T{1}.fit_slope(1),T{1}.fit_intercept(1)));

ax1=gca;
legend()
ax1.TickDir = 'out';
ax1.XLabel.String='x';
ax1.XLim = [0 1];
ax1.YLabel.String='\nu_1 Raman shift [cm^{-1}]';
ax1.YMinorTick = 'on';


% plot icp vs xrf or raman fit
subplot(1,2,2);
errorbar(T{2}.x_ICPData,T{2}.y_XRFData,T{2}.y_error_XRF,...
    T{2}.y_error_XRF,T{2}.x_error_ICP,T{2}.x_error_ICP,'.','MarkerSize',10,'DisplayName','Bulk ACBC'); hold on;
errorbar(T{2}.x_ICPData,T{2}.y_EDSData,T{2}.y_error_EDS,...
        T{2}.y_error_EDS,T{2}.x_error_ICP,T{2}.x_error_ICP,'^','MarkerSize',5,'DisplayName','Bulk balcite');
errorbar(T{2}.x_RamanDrops,T{2}.y_RamanDrops,T{2}.x_error_RamanDrops,'horizontal','*','DisplayName','Droplet');
plot(x_vals,x_vals,'k:','DisplayName','y=x')

% plot settings
ax2=gca;
legend()
xlim([0 1])
ylim([0 1])
ax2.TickDir = 'out';
ax2.YLabel.String='x';
ax2.XLabel.String='x_f';


if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end   
