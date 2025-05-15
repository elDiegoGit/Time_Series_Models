function [A, B, C, D, mean_0, cov_0, stateType] = ParamMap_t(params, mean_0, cov_0, stateType)
% ParamMap
    
 %% Model parameters:
    a11 = params(1);
    a12 = params(2);
    a13 = params(3);
    a14 = params(4);
    a21 = params(5);
    a22 = params(6);
    a23 = params(7);
    a24 = params(8);
    a31 = params(9);
    a32 = params(10);
    a33 = params(11);
    a34 = params(12);
    a41 = params(13);
    a42 = params(14);
    a43 = params(15);
    a44 = params(16);
    b11 = params(17);
    b22 = params(18);
    b33 = params(19);
    b44 = params(20);
    c11 = params(21);
    c12 = params(22);
    c13 = params(23);
    c14 = params(24);
    c21 = params(25);
    c22 = params(26);
    c23 = params(27);
    c24 = params(28);
    d11 = params(29);
%    d22 = params(14);
%    d33 = params(15);
    

 %% State-space coefficient matrices:
    A = [a11, a12, a13, a14;
         a21, a22, a23, a24;
         a31, a32, a33, a34;
         a41, a42, a43, a44];
 
    B = diag([b11, b22, b33, b44]);
    
    C = [c11, c12, c13, c14;
         c21  c22  c23  c24];

    D = [d11];
%    D = diag([d11, d22, d33]);

% Mean0 = mean_0;
% Cov0 = cov_0;
% StateType = stateType;
% DeflateY = false; 

end
