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

fn_inp={'FigS5_Raman_droplet_ACBC_pos1_t000.csv','FigS5_Raman_droplet_ACBC_pos1_t007.csv','FigS5_Raman_droplet_ACBC_pos1_t008.csv','FigS5_Raman_droplet_ACBC_pos1_t010.csv','FigS5_Raman_droplet_ACBC_pos2_t078.csv','FigS5_Raman_droplet_ACBC_pos2_t080.csv','FigS5_Raman_droplet_ACBC_pos2_t082.csv','FigS5_Raman_droplet_ACBC_pos2_t084.csv','FigS5_Raman_droplet_ACBC_pos2_t087.csv','FigS5_Raman_droplet_ACBC_pos2_t089.csv','FigS5_Raman_droplet_ACBC_pos2_t090.csv','FigS5_Raman_droplet_ACBC_pos2_t093.csv','FigS5_Raman_droplet_ACBC_pos2_t094.csv','FigS5_Raman_droplet_ACBC_pos2_t096.csv','FigS5_Raman_droplet_ACBC_pos2_t099.csv','FigS5_Raman_droplet_ACBC_pos2_t100.csv','FigS5_Raman_droplet_ACBC_pos2_t102.csv','FigS5_Raman_droplet_ACBC_pos2_t104.csv','FigS5_Raman_droplet_ACBC_pos2_t105.csv','FigS5_Raman_droplet_ACBC_pos2_t107.csv','FigS5_Raman_droplet_ACBC_pos2_t108.csv','FigS5_Raman_droplet_ACBC_pos2_t109.csv','FigS5_Raman_droplet_ACBC_pos2_t110.csv','FigS5_Raman_droplet_ACBC_pos2_t112.csv','FigS5_Raman_droplet_ACBC_pos2_t113.csv','FigS5_Raman_droplet_ACBC_pos2_t115.csv','FigS5_Raman_droplet_ACBC_pos2_t116.csv','FigS5_Raman_droplet_ACBC_pos2_t118.csv','FigS5_Raman_droplet_ACBC_pos2_t121.csv','FigS5_Raman_droplet_ACBC_pos2_t126.csv','FigS5_Raman_droplet_ACBC_pos2_t136.csv','FigS5_Raman_droplet_ACBC_pos2_t141.csv','FigS5_Raman_droplet_ACBC_pos2_t146.csv'};
fn_out = 'FigS5';

offset = [0];
for i=1:length(fn_inp)
    offset=[offset i*.5];
end

%% Import data from text files

% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

% Setup the Import Options and import the data

opts = delimitedTextImportOptions("NumVariables", 2);  % for data import

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["raman_shift", "int"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

T_init_pos = {};
T_one_pos = {};

% read in files
for ii=1:length(fn_inp)
    
    time_pos = split(erase(erase(fn_inp{ii},'FigS5_Raman_droplet_ACBC_'),'.csv'),'_'); % get time and pos from title
    time(ii) = str2num(erase(time_pos{2},'t'));
    if time_pos{1}=='pos1'
        T_init_pos = [T_init_pos; {readtable([fullfile(pn,fn_inp{ii})],opts)}];
    else
        T_one_pos = [T_one_pos; {readtable([fullfile(pn,fn_inp{ii})],opts)}];
    end
end

figure('Units','Inches','Position',[1 1 3 5]*TrueInchConversion);
min_wavelength = 950;
max_wavelength = 1200;

% new offset
offset_one = [0];
for i=1:length(T_one_pos)+length(T_init_pos)
    offset_one=[offset_one i*.5];%*.75]; 
end
offset_one(1:length(T_init_pos)-1) = offset_one(1:length(T_init_pos)-1)-0.3;

jj=1;
% initial droplet
for ii = 1:length(T_init_pos)
    % truncate data to just range of interest
    wavelength = T_init_pos{ii}.raman_shift(T_init_pos{ii}.raman_shift > min_wavelength &...
        T_init_pos{ii}.raman_shift < max_wavelength);
    Int = T_init_pos{ii}.int(T_init_pos{ii}.raman_shift > min_wavelength &...
        T_init_pos{ii}.raman_shift < max_wavelength);
    Norm_Int = (Int - min(Int))/(max(Int) - min(Int))+offset_one(jj);
    plot(wavelength,Norm_Int,'r'); hold on; 
    
    jj=jj+1;
end

for ii = 1:length(T_one_pos)
    % truncate data to just range of interest
    wavelength = T_one_pos{ii}.raman_shift(T_one_pos{ii}.raman_shift > min_wavelength &...
        T_one_pos{ii}.raman_shift < max_wavelength);
    Int = T_one_pos{ii}.int(T_one_pos{ii}.raman_shift > min_wavelength &...
        T_one_pos{ii}.raman_shift < max_wavelength);
    Norm_Int = (Int - min(Int))/(max(Int) - min(Int))+offset_one(jj);
    plot(wavelength,Norm_Int,'b'); hold on; 
    
    jj = jj+1;
end
xline(1058.8,'k--'); xline(1085.9,'k--');

xlabel('Raman shift [cm^{-1}]')
ylabel('normalized intensity [a.u.]')
xlim([min_wavelength max_wavelength])
ylim([-0.3 max(offset_one)+offset_one(2)+0.5])
ax = gca;
ax.YTick = '';
ax.XMinorTick = 'on';

% add time on right y-axis
yyaxis right
set(gca,'ytick',[0:length(time)-1],'ylim',[0,length(time)+1.2],'Ycolor','k','YTickLabel',[time],'TickDir','out')
ylabel('Time (min)')

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end
