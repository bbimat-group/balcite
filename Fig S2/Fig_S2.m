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

fn_inp = {'FigS2_XRD_calcite_ref.csv','FigS2_A_XRD_mixture_x0625.csv','FigS2_A_XRD_mixture_x125.csv','FigS2_A_XRD_mixture_x25.csv','FigS2_A_XRD_mixture_x375.csv','FigS2_A_XRD_mixture_x5.csv','FigS2_A_XRD_mixture_x625.csv','FigS2_A_XRD_mixture_x75.csv','FigS2_A_XRD_mixture_x875.csv','FigS2_A_XRD_mixture_x935.csv','FigS2_XRD_witherite_ref.csv','FigS2_XRD_calcite_ref.csv','FigS2_B_XRD_calcite_100mM_BaCl2.csv','FigS2_B_XRD_witherite_100mM_CaCl2.csv','FigS2_XRD_witherite_ref.csv'};
fn_inp_C = {'FigS2_XRD_calcite_ref.csv','FigS2_XRD_vaterite_ref.csv','FigS2_C_XRD_ACBC_x06.csv','FigS2_C_XRD_ACBC_x13.csv','FigS2_C_XRD_ACBC_x25.csv','FigS2_C_XRD_ACBC_x37.csv','FigS2_C_XRD_ACBC_x42.csv','FigS2_XRD_witherite_ref.csv'};
lgnd_entry = {'0','0.0625','0.125','0.25','0.375','0.5','0.625','0.75','0.875','0.935','1.0',...
    'calcite','calcite + 100mM BaCl_2','witherite + 100mM CaCl_2','witherite'};
lgnd_entry_C = {'calcite','vaterite','0.06','0.13','0.26','0.37','0.42','witherite'};
fn_out = 'FigS2';

offset = [0.05];
for i=1:length(fn_inp)-1
    offset=[offset (i+offset(1))*.75];
end
offset(end-3:end) = [0:3]+offset(1);

offset_C = [0.05];
for i=1:length(lgnd_entry_C)
    offset_C=[offset_C i+offset_C(1)];
end

%% Import data from text files

% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

% Setup the Import Options and import the data
opts1 = delimitedTextImportOptions("NumVariables", 2);  % for data import
opts2=opts1; %for unit import

% Specify range and delimiter
opts1.DataLines = [3, Inf];
opts1.Delimiter = ",";
opts2.DataLines = [2, 2];
opts2.Delimiter = opts1.Delimiter;

% Specify column names and types
opts1.VariableNames = ["bragg", "int"];
opts1.VariableTypes = ["double", "double"];
opts2.VariableNames = opts1.VariableNames;
opts2.VariableTypes = ["string", "string"];

% Specify file level properties
opts1.ExtraColumnsRule = "ignore";
opts1.EmptyLineRule = "read";

for ii=1:length(fn_inp)
    T{ii} = readtable([fullfile(pn,fn_inp{ii})],opts1);
    U     = readtable([fullfile(pn,fn_inp{ii})],opts2);
    T{ii}.Properties.VariableUnits = U{:,:};
end

for ii=1:length(fn_inp_C)
    T_C{ii} = readtable([fullfile(pn,fn_inp_C{ii})],opts1);
    U     = readtable([fullfile(pn,fn_inp_C{ii})],opts2);
    T_C{ii}.Properties.VariableUnits = U{:,:};
end

clear opts1 opts2 U

%% Plot data
figure('Units','Inches','Position',[1 1 9.5 2]*TrueInchConversion);
ax1 = subplot(1,3,1);

% set colormap
cmap = winter(23);
cmap = cmap(end-2:-2:1,:);
cmap2 = cmap(end-1:-3:1,:);

hold on;
for ii = 11:-1:1
    % normalize
    N_int = (T{ii}.int - min(T{ii}.int))/(max(T{ii}.int) - min(T{ii}.int))+offset(ii);
    %plot
    p(ii) = plot(T{ii}.bragg,N_int, 'DisplayName',['x=',lgnd_entry{ii}],'color',cmap(ii,:)); 
end
xlabel(['Bragg angle, 2\theta [',T{ii}.Properties.VariableUnits{1},']'],'color','black');
ylabel(['Normalized intensity [',T{ii}.Properties.VariableUnits{2},']'],'color','black');
ax1.XLim = [15 60];
ax1.TickDir = 'out';
ax1.YTick = [];
ax1.XMinorTick = 'on';
ax1.YLim = [0 max(offset(1:11)+1)+offset(1)];
set(ax1,'Box','on');
legend();

ax2=subplot(1,3,2);

hold on; 
for ii = 15:-1:12
    % normalize
    N_int = (T{ii}.int-min(T{ii}.int))/(max(T{ii}.int)-min(T{ii}.int))+offset(ii); 
    %plot
    p(ii) = plot(T{ii}.bragg,N_int, 'DisplayName',lgnd_entry{ii},'Color',cmap2((16-ii),:)); 
end
xlabel(['Bragg angle, 2\theta [',T{ii}.Properties.VariableUnits{1},']'],'color','black');
ylabel(['normalized intensity [',T{ii}.Properties.VariableUnits{2},']'],'color','black');
ax2.XLim = [15 60];
ax2.TickDir = 'out';
ax2.YTick = [];
ax2.XMinorTick = 'on';
ax2.YLim = [0 max(offset(12:end)+1)+offset(1)];
legend();
set(ax2,'Box','on');

% panel C
ax3=subplot(1,3,3);

min_xlim = 15;
max_xlim = 60;

hold on;
for ii = length(lgnd_entry_C):-1:1
    twotheta = T_C{ii}.bragg(T_C{ii}.bragg >= min_xlim &...
        T_C{ii}.bragg <= max_xlim);
    Int = T_C{ii}.int(T_C{ii}.bragg >= min_xlim &...
        T_C{ii}.bragg <= max_xlim);
    N_int = (Int - min(Int))/(max(Int) - min(Int))+offset_C(ii);
    p(ii) = plot(twotheta,N_int, 'k','DisplayName',lgnd_entry_C{ii}); 
end
xlabel(['Bragg angle, 2\theta [',T_C{ii}.Properties.VariableUnits{1},']'],'color','black');
ylabel(['normalized intensity [',T_C{ii}.Properties.VariableUnits{2},']'],'color','black');
ax3.XLim = [min_xlim max_xlim];
ax3.TickDir = 'out';
ax3.YTick = [];
ax3.YLim = [0 max(offset_C)+offset_C(1)];
ax3.XMinorTick = 'on';
legend();
set(ax3,'Box','on');


if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end
