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

fn_out = 'Fig4';

gumev1max_haz    = @(data, mu, J) J.*exp(-J.*(data-mu))./(exp(exp(-J.*(data-mu)))-1);
gumev1max_cumhaz = @(data, mu, J) -log(1-exp(-exp(-J*(data-mu))));
tv = {0:0.5:60;0:0.5:60;0:1/20:8;0:1/60:3;0:1/60:3;0:1/60:3};

% get & set calibration for screen resolution
ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
matlab_PixelsPerInch = get(0,'ScreenPixelsPerInch');
TrueInchConversion = ScreenPixelsPerInch/matlab_PixelsPerInch;

%% Import data & plot 

% import fit parameters
Results = readtable([fullfile(pn,'Fig4_survival_fit_params.csv')]);

cmap = winter(12);
cmap = cmap(1:2:end,:);

figure('Units','Inches','Position',[1 1 5 2]*TrueInchConversion);
legend_txt = {};
for ii = 3:6
    legend_txt = [legend_txt sprintf('%.2f',Results.x_f(ii-2))];
    
    ax1 = subplot(1,3,1);
    hold on;
    plot(tv{ii},gumev1max_haz(tv{ii},Results.mu(ii-2),Results.J(ii-2)),'-','Color',cmap(ii,:),'LineWidth',1); 
    
    ax2 = subplot(1,3,3);
    hold on;
    plot(tv{ii},gumev1max_cumhaz(tv{ii},Results.mu(ii-2),Results.J(ii-2)),'-','Color',cmap(ii,:),'LineWidth',1); 
    
    ax3 = subplot(1,3,2);
    hold on;
    t_temp = tv{ii};
    plot(t_temp,-log(gumev1max_haz(t_temp,Results.mu(ii-2),Results.J(ii-2))),'-','Color',cmap(ii,:),'LineWidth',1); 
end

ax1.TickDir = 'out';
ax1.YScale  = 'log';
ax1.XLim=[0,2.5];
ax1.YLim=[1e-2,30];
ax1.XMinorTick = 'on';
xlabel(ax1,'time [h]');
ylabel(ax1,'$h(t; \widehat{J},\widehat{\mu})$ [1/h]', 'Interpreter',"latex")
legend(legend_txt);
set(ax1,'Box','on');

ax2.TickDir = 'out';
ax2.YScale  = 'log';
ax2.XLim=[0,3];
ax2.YLim=[1e-2,30];
ax2.XMinorTick = 'on';
xlabel(ax2,'time [h]');
ylabel(ax2,'$H(t; \widehat{J},\widehat{\mu})$ [a.u.]', 'Interpreter',"latex")
set(ax2,'Box','on');

ax3.TickDir = 'out';
ax3.YScale  = 'linear';
ax3.XLim=[0,2];
ax3.YLim=[0,400];
ax3.XMinorTick = 'on';
xlabel(ax3,'time [h]');
ylabel(ax3,'$-\log{h(t;J,\mu)} = \widehat{W}_r^* - \log{A}$ [a.u.]', 'Interpreter',"latex")
set(ax3,'Box','on');

% save figure

if save_figure==true
    saveas(gcf,[fullfile(pn,fn_out)],'epsc');
    disp(['Saved to file:',fullfile(pn,fn_out)] );
else
    disp('Figure not saved!');
end
