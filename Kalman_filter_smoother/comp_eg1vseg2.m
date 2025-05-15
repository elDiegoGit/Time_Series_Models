% -----------------------------------------------------------------------
% Script to compare filtered states from example1 and example2
% -----------------------------------------------------------------------

%% Houskeeping:
clear
close all
clc

%% Load data:
load('example1.mat');          % loads filtered states from example1
load('example2.mat');          % loads filtered states from example2

% Compare filtered states:
difference = states_filtered' - X  % be careful with orientation!


%% Plot results
figure;
for i = 1:4
    subplot(2,2,i)
    plot(dates, difference(:,i), 'LineWidth', 1.5);
    grid on;
    title(['Difference in State ', num2str(i)]);
end
sgtitle('Difference Between Bespoke KF and Matlab KF');
