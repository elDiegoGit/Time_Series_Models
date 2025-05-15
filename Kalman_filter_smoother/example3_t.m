% -----------------------------------------------------------------------
% Example 3_t: Solution to a Neoclassical Growth Model via Uhlig's Toolkit.
%
% Obj: Recover FILTERED and SMOOTHED states + build likelihood with bespoke 
% KF and KS codes using calibrated parameters, PCE data and assuming NO 
% measurement error.
%
% The model:
% y_t = C x_t + D v_t       : Observation/Measurement equation
% x_t = A x_{t-1} + B w_t   : State/ Transition equation
%
% where:
% y_t = (PCE_t, GDP_t) 
% x_t = (k_t, c_t, r_t, z_t)
%
% Model features 2 observables and 4 states.
% -----------------------------------------------------------------------


%% Houskeeping:
clear
close all
clc


%% Obtain and prepare data:
% Import real PCE data from FRED.
c = fred;
seriesID = 'PCECC96'; 
startdate = '1960-01-01';
enddate = '2019-12-31';
data = fetch(c, seriesID, startdate, enddate);
dates = data.Data(:, 1);
pce = data.Data(:, 2);
dates = datetime(dates, 'ConvertFrom', 'datenum');


seriesID = 'GDPC1'; 
startdate = '1960-01-01';
enddate = '2019-12-31';
data = fetch(c, seriesID, startdate, enddate);
dates = data.Data(:, 1);
gdp = data.Data(:, 2);
dates = datetime(dates, 'ConvertFrom', 'datenum');



%% Apply the HP filter (lambda = 1600 since data is quarterly)
lambda =  1600;

% PCE ---------------------------------------
[trend, cycle] = hpfilter(pce, Smoothing = lambda);

% Log transformation and deviation:
log_pce = log(pce);
log_trend = log(trend);
log_deviation = log_pce - log_trend;

% GDP ---------------------------------------
[trend, cycle] = hpfilter(gdp, Smoothing = lambda);
log_gdp = log(gdp);
log_trend_gdp = log(trend);
log_deviation_gdp = log_gdp - log_trend_gdp;


%% Plot log of Real PCE and HP Trend:

% Define colors and figure format
blue    = [  1,  87, 155]/255;
red     = [4/5, 1/5, 1/5];
green   = [2/5, 4/5, 2/5];
lgblue  = [108, 172, 228]/255;
violet  = [143,   0, 255]/255;
plot_colors = {blue; red; green; violet};
fig_fmt = 'png';

% fig0 = figure();
% ax0 = axes();
% plot(dates, log_pce, 'b', 'LineWidth', 1.5)
% hold on
% plot(dates, log_trend, 'r--', 'LineWidth', 1.5)
% set(fig0, 'units', 'inches', 'position', [0 0 13 8])
% set(ax0, 'box', 'on')
% grid(ax0, "on")
% title('Log of Real PCE and HP Trend')
% legend('Log Real PCE', 'HP Trend', Location='best')
% datetick('x', 'yyyy')
% xlabel('Date')
% ylabel('Log Value')
% print(fig0, 'HPtrend', ['-d' fig_fmt])
% 
% % Plot deviations from trend:
% fig0 = figure();
% ax0 = axes();
% plot(dates, log_deviation, 'k', 'LineWidth', 1.5);
% set(fig0, 'units', 'inches', 'position', [0 0 13 8])
% set(ax0, 'box', 'on')
% grid(ax0, "on")
% title('Log-Deviation from HP Trend');
% datetick('x', 'yyyy');
% xlabel('Date');
% ylabel('Log-Deviation')
% print(fig0, 'logdeviation', ['-d' fig_fmt])



%% Define data for State Space
%Y = log_deviation';
Y = [log_deviation_gdp log_deviation];
T = length(Y);

% Parameters from policy functions (see Uhlig Toolkit Implementation p.19)
vkk = 0.965; vkz = 0.075;
vck = 0.618; vcz = 0.305;
vrk = -0.022; vrz = 0.035;
psi = 0.95; 
sigma = 0.712; 


%% State Space representation for the Kalman Filter
SSM = setup_ssm_t(vkk, vkz, vck, vcz, vrk, vrz, psi, sigma);


%% Run filter
% Kalman filter with fixed parameter values
[Kt,log_like_cum, states_filtered, P_filtered, P_predicted] = kalman_filter_t(Y, SSM);


%% Run smoother:
[Jt, P_smoothed,states_smoothed] = kalman_smoother(SSM, states_filtered, P_filtered, P_predicted);



%% Plot the filtered states with calibrated parameters
    % fig0 = figure();
    % ax0 = axes();
    % hold on
    % for i = 1:size(states_filtered, 1)
    %     plot(dates, states_filtered(i, :), 'LineWidth', 2.0, 'Color', plot_colors{i,:});
    % end
    % hold off
    % set(fig0, 'units', 'inches', 'position', [0 0 13 8]);
    % set(ax0, 'box', 'on');
    % grid(ax0, 'on');
    % title('Filtered States with CALIBRATED parameters');
    % xlabel('Time');
    % ylabel('State Values');
    % legend({'k_t', 'c_t', 'r_t', 'z_t'});
    % print(fig0, 'filtered_states_estimated', ['-d' fig_fmt]);

    % Plot technology process (z_t)
    % tech = states_filtered(4, :);
    % fig0 = figure();
    % ax0 = axes();
    % plot(dates, tech, 'LineWidth', 2, 'Color', plot_colors{4,:});
    % set(fig0, 'units', 'inches', 'position', [0 0 13 8]);
    % set(ax0, 'box', 'on');
    % grid(ax0, "on");
    % title('Filtered Technology Process (z_t) with CALIBRATED parameters');
    % xlabel('Time');
    % ylabel('Technology Process (z_t)');
    % print(fig0, 'tech_estimated', ['-d' fig_fmt]);

    % Plot variance for specific state:
    %figure, plot(squeeze(P_filtered(1,1,:)))

    % Plot filtered vs smoothed states:
    fig = figure();
    set(fig, 'units', 'inches', 'position', [0 0 13 10]);
    state_names = {'k_t', 'c_t', 'r_t', 'z_t'};

    for i = 1:4
        subplot(2, 2, i);
        plot(dates, states_filtered(i, :), 'LineWidth', 1.8, 'LineStyle', '-', 'Color', plot_colors{i,:});
        hold on
        plot(dates, states_smoothed(i, :), 'LineWidth', 1.8, 'LineStyle', '--', 'Color', 'k');
        grid on
        title(['State: ', state_names{i}]);
        xlabel('Date');
        ylabel('Value');
        datetick('x', 'yyyy');
        legend('Filtered', 'Smoothed', 'Location', 'best');
    end
    sgtitle('Filtered vs Smoothed States');
    print(fig, 'eg_3t_filtered_vs_smoothed', ['-d' fig_fmt]);


%% Save filtered output:
save('example3_t.mat', 'states_smoothed', 'dates');

