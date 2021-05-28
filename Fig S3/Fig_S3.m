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

fn_inp = {'FigS3_A_Raman_bulk_ACBC_x06.csv','FigS3_A_Raman_bulk_ACBC_x13.csv','FigS3_A_Raman_bulk_ACBC_x25.csv','FigS3_A_Raman_bulk_ACBC_x37.csv','FigS3_A_Raman_bulk_ACBC_x42.csv','FigS3_A_Raman_bulk_ACBC_x64.csv','FigS3_A_Raman_bulk_ACBC_x79.csv'};
lgnd_entry = {'0.06','0.13','0.25','0.37','0.42','0.64','0.79'};
fn_inp_xtl = {'FigS3_A_Raman_bulk_balcite_x06.csv','FigS3_A_Raman_bulk_balcite_x13.csv','FigS3_A_Raman_bulk_balcite_x25.csv','FigS3_A_Raman_bulk_balcite_x37.csv','FigS3_A_Raman_bulk_balcite_x42.csv','FigS3_A_Raman_bulk_balcite_x64.csv','FigS3_A_Raman_bulk_balcite_x79.csv','FigS3_Raman_calcite_ref.csv','FigS3_Raman_witherite_ref.csv'};
fn_refs = {'FigS3_Raman_calcite_ref.csv','FigS3_Raman_witherite_ref.csv'};
fn_out = 'FigS3';

fn_inp_B = {'FigS3_Raman_calcite_ref.csv','FigS3_B_Raman_droplet_ACBC_x144.csv','FigS3_B_Raman_droplet_ACBC_x255.csv','FigS3_B_Raman_droplet_ACBC_x534.csv','FigS3_B_Raman_droplet_balcite_x144.csv','FigS3_B_Raman_droplet_balcite_x255.csv','FigS3_B_Raman_droplet_balcite_x534.csv','FigS3_Raman_witherite_ref.csv'};
lgnd_entry_B = {'calcite','x_f=0.144','x_f=0.255','x_f=0.534','x_f=0.144','x_f=0.255','x_f=0.534','witherite'};

offset = [0.1];
for i=1:length(fn_inp)-1
    offset=[offset i+offset(1)];
end

offset_B = [0.1]; 
for i=1:(length(fn_inp_B)-2)/2
    offset_B=[offset_B i*1.1+offset_B(1)];
end
offset_B(end+1:end+3) = offset_B(2:4);
offset_B(end+1) = i*1.1+offset_B(1)+1.1;

%% Import data from text files

% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

% Setup the Import Options and import the data
opts1 = delimitedTextImportOptions("NumVariables", 2);  % for data import
opts2=opts1; %for unit import

% Specify column names and types
opts1.VariableNames = ["Raman_Shift","Intensity"];
opts1.VariableTypes = ["double", "double"];
opts2.DataLines = [2, 2];
opts2.Delimiter = opts1.Delimiter;

% Specify file level properties
opts1.ExtraColumnsRule = "ignore";
opts1.EmptyLineRule = "read";
opts2.VariableNames = opts1.VariableNames;
opts2.VariableTypes = ["string", "string"];

% Specify range and delimiter
opts1.DataLines = [3, Inf];
opts1.Delimiter = ",";

for i=1:length(fn_inp)
    T{i} = readtable([fullfile(pn,fn_inp{i})],opts1);
end
for i=1:length(fn_inp_xtl)
    Xtl{i} = readtable([fullfile(pn,fn_inp_xtl{i})],opts1);
end
for i=1:length(fn_refs)
    refs{i} = readtable([fullfile(pn,fn_refs{i})],opts1);
end

for ii=1:length(fn_inp_B)
    T_B{ii} = readtable([fullfile(pn,fn_inp_B{ii})],opts1);
    U     = readtable([fullfile(pn,fn_inp_B{ii})],opts2);
    T_B{ii}.Properties.VariableUnits = U{:,:};
end

clear opts

%% Plot data
figure('Units','Inches','Position',[1 1 9 2.5]*TrueInchConversion);

ax1=subplot(1,2,1);

min_wavelength = 1000;
max_wavelength = 1150;
hold on; 
for ii = length(fn_inp):-1:1
    % normalize & plot data
    wv_acbc = T{ii}.Raman_Shift(T{ii}.Raman_Shift >= min_wavelength &...
        T{ii}.Raman_Shift <= max_wavelength);
    Int = T{ii}.Intensity(T{ii}.Raman_Shift >= min_wavelength &...
        T{ii}.Raman_Shift <= max_wavelength);
    N_int = (Int - min(Int))/(max(Int) - min(Int))+offset(ii);
    p(ii+1) = plot(wv_acbc,N_int,'DisplayName',['x_f=',lgnd_entry{ii}],'color','k'); 

    % normalize & plot crystallized data
    wv_xtl = Xtl{ii}.Raman_Shift(Xtl{ii}.Raman_Shift >= min_wavelength &...
        Xtl{ii}.Raman_Shift <= max_wavelength);
    int_xtl = Xtl{ii}.Intensity(Xtl{ii}.Raman_Shift >= min_wavelength &...
        Xtl{ii}.Raman_Shift <= max_wavelength);
    N_int_xtl = (int_xtl - min(int_xtl))/(max(int_xtl) - min(int_xtl))+offset(ii);
    plot(wv_xtl,N_int_xtl,'g'); 
end
% normalize & plot references & peak lines
lgnd_idx = [length(fn_inp)+2,1];
lgnd_ref = {'witherite','calcite'};
off_ref = [offset(1)-1, max(offset)+1.1];
for ii=1:length(refs)
    wv_ref = refs{ii}.Raman_Shift(refs{ii}.Raman_Shift >= min_wavelength &...
        refs{ii}.Raman_Shift <= max_wavelength);
    int_refs = refs{ii}.Intensity(refs{ii}.Raman_Shift >= min_wavelength &...
        refs{ii}.Raman_Shift <= max_wavelength);
    N_int_refs = (int_refs - min(int_refs))/(max(int_refs) - min(int_refs))+off_ref(ii);
    p(lgnd_idx(ii)) = plot(wv_ref,N_int_refs,'k-','DisplayName',lgnd_ref{ii}); hold on;
    [pk, loc] = findpeaks(N_int_refs,wv_ref,'MinPeakProminence',0.5);
    xline(loc,'k--');
end

xlabel('Raman shift [cm^-^1]')
ylabel('normalized Intensity [a.u.]')
ax1.TickDir = 'out';
xticks(ax1,[1000:25:1150]);
ax1.YTick = [];
ax1.Box = 'on';
ax1.XMinorTick = 'on';
xlim([min_wavelength max_wavelength]);
ylim([-1 max(offset)+2+offset(1)*2])
legend(ax1,fliplr(p));


ax2=subplot(1,2,2);

for ii = 1:length(fn_inp_B)
    wavelength = T_B{ii}.Raman_Shift(T_B{ii}.Raman_Shift >= min_wavelength &...
        T_B{ii}.Raman_Shift <= max_wavelength);
    Int = T_B{ii}.Intensity(T_B{ii}.Raman_Shift >= min_wavelength &...
        T_B{ii}.Raman_Shift <= max_wavelength);
    N_int = (Int - min(Int))/(max(Int) - min(Int))+offset_B(ii);
    if ii==2 | ii==3 | ii==4
        p(ii) = plot(wavelength,N_int,'DisplayName',lgnd_entry_B{ii},'color','k');
    elseif ii==5 | ii==6 | ii==7
        p(ii) = plot(wavelength,N_int,'g','DisplayName',lgnd_entry_B{ii});
    else
        p(ii) = plot(wavelength,N_int,'DisplayName',lgnd_entry_B{ii},'color','k'); hold on;
        [pk, loc] = findpeaks(N_int,wavelength,'MinPeakProminence',0.5);
        xline(loc,'k--');
    end
end
xlabel(['Raman shift [',T_B{ii}.Properties.VariableUnits{1},']'])
ylabel(['normalized intensity [',T_B{ii}.Properties.VariableUnits{2},']'])
ax2.XLim = [min_wavelength max_wavelength];
xticks(ax2,[1000:25:1150]);
ax2.TickDir = 'out';
ax2.YTick = [];
ax2.XMinorTick = 'on';
ax2.YLim = [0 max(offset_B)+1+offset_B(1)];
legend(ax2,fliplr([p(1:4),p(end)]));

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end
