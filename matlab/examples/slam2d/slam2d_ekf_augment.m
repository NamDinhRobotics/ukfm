function [aug_state, aug_P, ekf_lmk] = slam2d_ekf_augment(state, P, ...
    y, R, ekf_lmk)
%SLAMD_EKF_AUGMENT Augment state
%
% Syntax: [up_state, up_P] = slam2d_ekf_augment(state, P, y, R, iekf_lmk)
%
% Inputs:
%    state - state
%    P - covariance matrix
%    y - measurement
%    R - noise covariance matrix
%    iekf_lmk - already observed landmark
%
% Outputs:
%    aug_state - augmented state
%    aug_P - augmented covariance matrix
J = [0 -1; 1 0];
N_y = length(find(y(3, :) > 0));

aug_state = state;
aug_P = P;

for i = 1:N_y
    idx = find(~(ekf_lmk - y(3, i)));
    if ~isempty(idx)
        continue
    end
    p_l = aug_state.Rot*y(1:2, i) + aug_state.p;
    aug_state.p_l = [aug_state.p_l p_l];
    % augment the landmark state
    ekf_lmk = [ekf_lmk; y(3, i)];
    % indices of the new landmark
    idx = find(~(ekf_lmk - y(3, i)));

    % get Jacobian and then covariance following [2]
    HR = zeros(2, length(aug_P));
    HR(1:2, 1:3) = -state.Rot'*[J*(p_l-state.p) eye(2)];
    HL = state.Rot';
    
    iHL = inv(HL);
    P_aug_aug = iHL*(HR*aug_P*HR' + R)*iHL';
    P_aug_prev = -iHL*HR*aug_P;
    aug_P = [aug_P P_aug_prev';
        P_aug_prev P_aug_aug];
end
end