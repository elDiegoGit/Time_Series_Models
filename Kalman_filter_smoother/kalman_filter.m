% -----------------------------------------------------------------------
% Function: Kalman Filter to be used with Example 1.
% Done with Matlab R2023b
% -----------------------------------------------------------------------

function [Kt, log_like_cum, states_filtered, P_filtered, P_predicted] = kalman_filter(Y, SSM)

    % Unpack the state space model from the struct
    A = SSM.A;
    B = SSM.B;
    C = SSM.C;
    Q = SSM.Q;
    R = SSM.R;
    S0 = SSM.S0;
    P0 = SSM.P0;
    
    % Initializing variables (n = obs, T = time steps, m = # of states)
    [n, T] = size(Y); 
    [m, ~] = size(A);  
    
    % Pre-allocating memory:
    cum_sum = 0;
    log_like_t = zeros(1,T);   % Store per-period log-likelihoods
    log_like_cum = zeros(1,T); % Store cumulative log-likelihoods
    states_filtered = zeros(m, T);
    P_filtered = zeros(m, m, T);   % Store filtered conditional variances
    P_predicted = zeros(m, m, T);  % Store predicted conditional variances
    Kt = zeros(m,n);               % Store Kalman Gain


    %% Initialize State mean and covariance
    St = S0;
    Pt = P0;
    

    %% Kalman Filter recursion:
    for t = 1:T

        % Prediction step:
        St_pred = A * St;           % conditional mean of S_t: S_{t|t-1}
        Pt_pred = A * Pt * A' + Q;  % conditional variance of S_t: P_{t|t-1}
        F_pred = C * Pt_pred * C' + R;     % F_{t|t-1}

        % Save States Covariance prediction:
        P_predicted(:,:,t) = Pt_pred;

        % Measurement received:
        Y_pred       = C * St_pred;        % Predicted Y_t: Y_{t|t-1}
        F_error      = Y(:, t) - Y_pred;   % Forecast Error: Y_t - Y_{t|t-1}
        
        % Define Kalman gain:
        K = Pt_pred * C' / F_pred;  
        
        % Update State's conditional Mean and Variance:
        St = St_pred + K * F_error;
        Pt = Pt_pred - K * C * Pt_pred;
        
        % Save filtered states
        states_filtered(:, t) = St;
        P_filtered(:,:,t) = Pt;
        Kt(:,:,t) = K;

        
        % Updating the log-likelihood
        %log_like = log_like + log(det(S_innovation)) + F_error' / S_innovation * F_error;
        log_like_t(t) = -0.5 * (n * log(2*pi) + log(det(F_pred)) + F_error' / F_pred * F_error);
        cum_sum = cum_sum + log_like_t(t);
        log_like_cum(t) = cum_sum;
    end
    
    % Computing the log-likelihood
    %log_like = -0.5 * (n * T * log(2 * pi) + log_like);


end
   %log_like_t(t) = -0.5 * (n * log(2*pi) + log_det_S + F_error' * S_inv_innovation);
   %cum_sum = cum_sum + log_like_t(t);
   %log_like_cum(t) = cum_sum;