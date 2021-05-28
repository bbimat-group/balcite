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

fn_out = 'Fig3';

tv = {0:0.5:60;0:0.5:60;0:1/20:8;0:1/60:3;0:1/60:3;0:1/60:3};
gumev1max_sur    = @(data, mu, J) 1-exp(-exp(-J.*(data-mu)));

% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

%% Import Data
% filenames
fn_inp = {'Fig3_survival_x0.csv','Fig3_survival_x144.csv','Fig3_survival_x167.csv','Fig3_survival_x255.csv','Fig3_survival_x345.csv','Fig3_survival_x534.csv'};

Fit_Results = readtable([fullfile(pn,'Fig3_survival_fit_params.csv')]);
Fit_Results.Par_Names = string({Fit_Results.Par_Names{:}})';

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
    temp = erase(fn_inp{ii},'Fig3_survival_x');
    ba_conc{ii} = ['x_f=',erase(temp,'.csv')];
end


%% Plot
figure('Units','Inches','Position',[1 1 4.5 3.25]*TrueInchConversion);
hold on;
cmap = parula(12);
cmap = cmap(1:2:end,:);
N_exp = 6;

% panel m
subplot(2,2,1);
legend_txt={};

for ii = 1:N_exp
    [emp_S, emp_t, emp_S_lo, emp_S_up] = ecdf(T{ii}.t_event,"censoring",T{ii}.cens,'frequency',T{ii}.freq,'function',"survivor",...
        "bounds","on",'alpha',0.05);  hold on
    emp_t(1) = 0;
    if T{ii}.cens(end) ~= 0
        emp_t(end+1) = T{ii}.t_event(end);
        emp_S(end+1) = emp_S(end);
        emp_S_lo(end+1) = emp_S_lo(end);
        emp_S_up(end+1) = emp_S_up(end);
    end
    p(ii) = stairs(emp_t,emp_S,'-','Color',cmap(ii,:),'LineWidth',1);
    stairs(emp_t,emp_S_lo,':','Color',cmap(ii,:),'LineWidth',1);    
    stairs(emp_t,emp_S_up,':','Color',cmap(ii,:),'LineWidth',1);   
    legend_txt = [legend_txt, ba_conc{ii}];
end

ax1 = gca;
ax1.TickDir = 'out';
ax1.XScale  = 'log';
ax1.XLim = [0.2,60];
ax1.XMinorTick = 'on';
xlabel('time [h]');
ylabel('$S(t)\approx\frac{N_0}{N}$ [a.u.]','interpreter',"latex")
legend(p,legend_txt,'location','best')
box on

% panel n

subplot(2,2,2);
hold on;
ii = 1;
[emp_S, emp_t, emp_S_lo, emp_S_up] = ecdf(T{ii}.t_event,"censoring",T{ii}.cens,'frequency',T{ii}.freq,'function',"survivor", "bounds","on");   
emp_t(1) = 0;
if T{ii}.cens(end) ~= 0
    emp_t(end+1) = T{ii}.t_event(end);
    emp_S(end+1) = emp_S(end);
    emp_S_lo(end+1) = emp_S_lo(end);
    emp_S_up(end+1) = emp_S_up(end);
end
stairs(emp_t,emp_S,'-','Color',cmap(ii,:),'LineWidth',1);
stairs(emp_t,emp_S_lo,':','Color',cmap(ii,:),'LineWidth',1);    
stairs(emp_t,emp_S_up,':','Color',cmap(ii,:),'LineWidth',1);  

t = 0:0.1:max(emp_t);
ACC_idx = 1;
% plot S of mle estimate
plot(t,1-expcdf(t,1/Fit_Results.Par_value(ACC_idx)),'r-')
% plot confidence bounds
S = linspace(1,0.9*emp_S(end),100);
Tv = expinv(1-S,1./[Fit_Results.Par_CI_low(ACC_idx);Fit_Results.Par_CI_high(ACC_idx)]);
plot(Tv(1,:),S,'r--',Tv(2,:),S,'r--')

ax2 = gca;
ax2.TickDir = 'out';
ax2.YScale  = 'log';
ax2.XLim  = [0,emp_t(end)];
ax2.XMinorTick = 'on';
xlabel('time [h]');
ylabel('$S(t)\approx\frac{N_0}{N}$ [a.u.]','interpreter',"latex")
box on


% panel o

subplot(2,2,3);
hold on;
ii = 2;
[emp_S, emp_t, emp_S_lo, emp_S_up] = ecdf(T{ii}.t_event,"censoring",T{ii}.cens,'frequency',T{ii}.freq,'function',"survivor", "bounds","on");   
emp_t(1) = 0;
if T{ii}.cens(end) ~= 0
    emp_t(end+1) = T{ii}.t_event(end);
    emp_S(end+1) = emp_S(end);
    emp_S_lo(end+1) = emp_S_lo(end);
    emp_S_up(end+1) = emp_S_up(end);
end
stairs(emp_t,emp_S,'-','Color',cmap(ii,:),'LineWidth',1);
stairs(emp_t,emp_S_lo,':','Color',cmap(ii,:),'LineWidth',1);    
stairs(emp_t,emp_S_up,':','Color',cmap(ii,:),'LineWidth',1);  
ax3 = gca;
ax3.TickDir = 'out';
ax3.YScale  = 'log';
ax3.XLim = [0,emp_t(end)];
ax3.XMinorTick = 'on';
xlabel('time [h]');
ylabel('$S(t)\approx\frac{N_0}{N}$ [a.u.]','interpreter',"latex")
box on


% panel p

% get index of J & mu
J_idx = find(Fit_Results.x_f>0 & Fit_Results.Par_Names=='J'); 
mu_idx = find(Fit_Results.x_f>0 & Fit_Results.Par_Names=='mu'); 

subplot(2,2,4);
hold on;
for ii = 3:6
    [emp_S, emp_t, emp_S_lo, emp_S_up] = ecdf(T{ii}.t_event,'frequency',T{ii}.freq,'function',"survivor", "bounds","on");   
    emp_t(1) = 0;
    if T{ii}.cens(end) ~= 0
        emp_t(end+1) = T{ii}.t_event(end);
        emp_S(end+1) = emp_S(end);
        emp_S_lo(end+1) = emp_S_lo(end);
        emp_S_up(end+1) = emp_S_up(end);
    end
    stairs(emp_t,emp_S,'-','Color',cmap(ii,:),'LineWidth',1);
    stairs(emp_t,emp_S_lo,':','Color',cmap(ii,:),'LineWidth',1);    
    stairs(emp_t,emp_S_up,':','Color',cmap(ii,:),'LineWidth',1);  
    plot(tv{ii},gumev1max_sur(tv{ii},Fit_Results.Par_value(mu_idx(ii-2)),Fit_Results.Par_value(J_idx(ii-2))),'k--')
end
ax4 = gca;
ax4.TickDir = 'out';
ax4.YScale  = 'log';
ax4.XLim=[0,4];
ax4.YLim=[1e-3,1];
ax4.XMinorTick = 'on';
xlabel('time [h]');
ylabel('$S(t)\approx\frac{N_0}{N}$ [a.u.]','interpreter',"latex")
box on

% save figure 

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end

