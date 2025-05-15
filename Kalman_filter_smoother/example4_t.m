% -----------------------------------------------------------------------
% Example 4_t: Solution to a Neoclassical Growth Model via Uhlig's Toolkit.
%
% Obj: Recover SMOOTHED states + build likelihood with Matlab's KS code
% using calibrated parameters, PCE data and assuming no measurement error.
%
% The model:
% y_t = C x_t + D v_t       : Observation/Measurement equation
% x_t = A x_{t-1} + B w_t   : State/ Transition equation
%
% where:
% y_t = (PCE_t, GDP_t) 
% x_t = (k_t, c_t, r_t, z_t)
%
% Explicitely: 2 observables and 4 latent states as AR(1).
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

% GDP 
[trend, cycle] = hpfilter(gdp, Smoothing = lambda);
log_gdp = log(gdp);
log_trend_gdp = log(trend);
log_deviation_gdp = log_gdp - log_trend_gdp;

% Define colors and figure format
blue    = [  1,  87, 155]/255;
red     = [4/5, 1/5, 1/5];
green   = [2/5, 4/5, 2/5];
lgblue  = [108, 172, 228]/255;
violet  = [143,   0, 255]/255;
plot_colors = {blue; red; green; violet};
fig_fmt = 'png';


%% Initialize state space model:

% Matrix Parameters:
psi = 0.95; 
sigma = 0.712; 

a11 = 0.965;
a12 = 0;
a13 = 0;
a14 = 0.075*psi;
a21 = 0.618;
a22 = 0;
a23 = 0;
a24 = 0.305*psi;
a31 = -0.022;
a32 = 0;
a33 = 0;
a34 = 0.035*psi;
a41 = 0;
a42 = 0;
a43 = 0;
a44 = psi;
b11 = 0.075;
b22 = 0.305;
b33 = 0.035;
b44 = 1;
c11 = 1;
c12 = 0;
c13 = 0;
c14 = 0;
c21 = 0;
c22 = 1;
c23 = 0;
c24 = 0;
d11 = 0;
params_0 = [a11, a12, a13, a14, a21, a22, a23, a24, a31, a32, a33, a34, ...
          a41, a42, a43, a44, b11, b22, b33, b44, c11, c12, c13, c14, ...
          c21, c22, c23, 24, d11];


% Initial guess for model's state equation variance-covariance matrix:
%cov_0 = eye(4);
cov_0 =[
    8.8779, 6.7700, -0.0471, 4.2275;
    6.7700, 5.3883, -0.0107, 3.9131;
   -0.0471, -0.0107,  0.0045, 0.0759;
    4.2275, 3.9131,  0.0759, 5.1994];


% Initial estimate of the state's conditional mean (Matlab calls it as mean):
mean_0 = [0;0;0;0];  

% Define StateType: (0 for stationary)
stateType = [0, 0, 0, 0];


Y = [log_deviation_gdp log_deviation];

%% Create SSM and Filter data
% Create the state-space model by passing the function ParamMap as a function handle to ssm:
mdl = ssm(@(params) ParamMap_t(params, mean_0, cov_0, stateType));


% Run the filter at set parameter values to obtain filtered states:
[X, logL, SmoothedStates] = smooth(mdl, Y, 'params',params_0);

% Store period log_likelihoods
log_likelihoods_seq = [SmoothedStates.LogLikelihood];

% Sanity check:
total_log_likelihood = sum(log_likelihoods_seq);


%% Plot Filtered States.

long_vector = cell2mat({SmoothedStates.SmoothedStates}'); %960 in length
T = length(log_deviation);  % or 240
X = reshape(long_vector, 4, T)';  % Reshape into 4 rows, then transpose.

% 2. Align dates:
dates = dates(1:T);

% 3. Set colors:
plot_colors = {blue; red; green; violet};

% 4. State names:
state_names = {'k_t', 'c_t', 'r_t', 'z_t'};

% 5. Create single figure:
figure;
hold on;
for i = 1:4
    plot(dates, X(:,i), 'LineWidth', 1.5, 'Color', plot_colors{i});
end
hold off;
grid on;
xlabel('Year', 'FontSize', 12);
ylabel('State Value', 'FontSize', 12);
title('Filtered States using Matlab''s KF', 'FontSize', 12);
ylim([-0.1 0.1]); 
legend(state_names, 'Location', 'best', 'FontSize', 12);

% 6. Save figure as PNG
filename = 'eg_4_smoothed_states.png';
saveas(gcf, filename);


%% Save output
% Save the filtered states into a .mat file
save('example4_t.mat', 'X', 'dates');






