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

fn_inp = {'Fig2_XRD_SigmaCalcite.csv','Fig2_XRD_balcite_as_synth.csv','Fig2_XRD_balcite_3mo.csv','Fig2_XRD_balcite_7mo.csv','Fig2_XRD_balcite_9mo.csv','Fig2_XRD_GeologicalWitherite.csv'};
fn_out = 'Fig2';

offset = [0.05];
for i=1:length(fn_inp)-1
    offset=[offset i+offset(1)];
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
    U = table("2\theta","a.u.");
    T{ii}.Properties.VariableUnits = U{:,:};
end

clear opts

%% Plot data
lgnd_entry = ({'calcite','as synthesized','3 months','7 months','9 months','witherite'});
min_xlim = 20;
max_xlim = 40;
figure('Units','Inches','Position',[1 1 3.75 2.5]*TrueInchConversion);

% set colormap
cmap = winter(length(fn_inp)*2);
cmap = cmap(1:2:end,:);

hold on;
for ii = length(fn_inp):-1:1
    % truncate data to just range of interest
    twotheta = T{ii}.bragg(T{ii}.bragg >= min_xlim &...
        T{ii}.bragg <= max_xlim);
    Int = T{ii}.int(T{ii}.bragg >= min_xlim &...
        T{ii}.bragg <= max_xlim);
    % normalize
    N_int = (Int - min(Int))/(max(Int) - min(Int))+offset(ii);
    %plot
    p(ii) = plot(twotheta,N_int, 'DisplayName',lgnd_entry{ii}); 
    % find peak locations of witherite, calicite & as-synthesized and plot
    if ii == 1 | ii == 2
        [pks, locs] = findpeaks(N_int,twotheta,'MinPeakProminence',0.5);
        for jj = 1:length(pks)
            xline(locs(jj),'b--');
        end
    elseif ii == 6
        [pks, locs] = findpeaks(N_int,twotheta,'MinPeakProminence',0.14);
        for jj = 1:length(pks)
            xline(locs(jj),'r--');
        end
    end
end
ax1=gca;
xlabel(['Bragg angle, 2\theta [\circ]'],'color','black');
ylabel(['normalized intensity [a.u.]'],'color','black');
ax1.XLim = [min_xlim max_xlim];
ax1.TickDir = 'out';
ax1.YTick = [];
ax1.YLim = [0 max(offset)+1];
ax1.XMinorTick = 'on';
set(ax1, 'Box', 'on');   
legend(fliplr(p),'location','best')

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end
