% -----------------------------------------------------------------------
% Script to compare filtered states from example1 and example2
% -----------------------------------------------------------------------

%% Houskeeping:
clear
close all
clc

%% Load data:
load('example3.mat');          % loads smoothed states from example1
load('example4.mat');          % loads smoothed states from example2

% Compare smoothed states:
difference = states_smoothed' - X  % be careful with orientation!


%% Plot results
figure;
for i = 1:4
    subplot(2,2,i)
    plot(dates, difference(:,i), 'LineWidth', 1.5);
    grid on;
    title(['Difference in State ', num2str(i)]);
end
sgtitle('Difference Between Bespoke KF and Matlab KF');
