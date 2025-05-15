% -----------------------------------------------------------------------
% Function: Kalman Smoother to be used with Example 3.
% Done with Matlab R2023b
% -----------------------------------------------------------------------

function [Jt, P_smoothed, states_smoothed] = kalman_smoother(SSM, states_filtered, P_filtered, P_predicted)
   
% Unpack model dimensions and parameters
  A = SSM.A;
  [m, T] = size(states_filtered); % m = # of states, T = # of time periods.
    
% Preallocate memory:
  states_smoothed = zeros(m, T);                  % To store smoothed states
  states_smoothed(:, T) = states_filtered(:, T);  % Final period: filtered == smoothed
  P_smoothed = zeros(m, m, T);                    % Initialize smoothed covariance matrix.
  Jt = zeros(m,m,T);                              % Initialize smoothed gain.
    
% Backward pass (RTS smoother)
    for t = T-1:-1:1 % Start at period T-1 (#239)
        
        % Smoother gain:
        J = P_filtered(:,:,t) * A' / P_predicted(:,:,t+1);
        Jt(:,:,t) = J;

        % Smoothed states:
        states_smoothed(:,t) = states_filtered(:,t) + J * (states_smoothed(:,t+1) - A * states_filtered(:,t));

        % Smoothed covariance:
         P_smoothed(:,:,t) = P_filtered(:,:,t) + ...
             J * (P_smoothed(:,:,t+1) - P_predicted(:,:,t+1)) * J';
    end
end
