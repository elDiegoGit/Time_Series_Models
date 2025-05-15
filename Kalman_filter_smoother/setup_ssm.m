% -----------------------------------------------------------------------
% Function: Setup SSM model to be used with Example 1.
%
% The model:
% y_t = C x_t + D v_t       : Observation/Measurement equation
% x_t = A x_{t-1} + B w_t   : State/ Transition equation
%
% such that:
% v_t ~ N(0, R) and R = I
% w_t ~ N(0, Q) and Q = I
%
% where:
% y_t = (PCE_t) 
% x_t = (k_t, c_t, r_t, z_t)
%
% Specifically:
% y_t = (0 1 0 0) (k_t
%                  c_t
%                  r_t
%                  z_t)
%
% (k_t     (vkk 0  0  vkz*psi   (k_{t-1}    (sigma*vkz
%  c_t   =  vck 0  0  vcz*psi    c_{t-1}  +  sigma*vcz * w_t
%  r_t      vrk 0  0  vrz*psi    r_{t-1}     sigma*vrz
%  z_t)      0  0  0  psi )      z_{t-1}     sigma   )
%
% -----------------------------------------------------------------------

function SSM = setup_ssm(vkk, vkz, vck, vcz, vrk, vrz, psi, sigma)

    % State equation Transition Matrix (ns x ns):
    A = [vkk 0 0 vkz*psi;
         vck 0 0 vcz*psi;
         vrk 0 0 vrz*psi;
         0   0 0 psi];
    
    % State equation disturbance loading matrix (ns x nw):
    B = [vkz*sigma, 0,0,0; 0,vcz*sigma,0,0; 0,0,vrz*sigma,0; 0,0,0,1*sigma];

    % Observation equation matrix (ny x ns):
    C = [0 1 0 0];

    % Observation equation innovation matrix (no measurement error) (ny x nv):
    D = 0;

    % State equation shock covariance
    Q = B * B';

    % Measurement equation shock covariance
    R = D * D'; 

    %% Initialization:
    
    % Initial mean S0 (Unconditional mean of the process)
    S0 = [0; 0; 0; 0]; 

    % Initial Covariance P0 (Unconditional variance of the process)
    n = size(A, 1); 
    vec_P0 = (eye(n^2) - kron(A,A))\ Q(:);  
    P0 = reshape(vec_P0, n, n);

    % Alternative to kron above (requires Matlab Control System Toolbox) 
    % P0 = dlyap(A, Q);

%% Build State Space into a Structure
    SSM.A = A;
    SSM.B = B;
    SSM.C = C;
    SSM.Q = Q;
    SSM.R = R;
    SSM.S0 = S0;
    SSM.P0 = P0;

end
