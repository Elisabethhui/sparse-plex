% Studies the recovery probability of different algorithms
% at a fixed sparsity level and varying number of signals.

close all;
clear all;
clc;
rng('default');
% Create the directory for storing images
[status_code,message,message_id] = mkdir('bin');
% Signal space 
N = 256;
% Number of measurements
M = 32;
% Number of signals
Ss = 1:32;
% Sparsity level
K = 16;
num_trials = 200;
num_ss = length(Ss);
success_with_s.somp = zeros(num_ss, 1);
success_with_s.ra_omp = zeros(num_ss, 1);
success_with_s.ra_ormp = zeros(num_ss, 1);
success_with_s.ra_thresholding = zeros(num_ss, 1);


snr_threshold = 100;

for ns=1:num_ss
    % Current sparsity level
    S = Ss(ns);
    num_successes.somp = 0;
    num_successes.ra_omp = 0;
    num_successes.ra_ormp = 0;
    num_successes.ra_thresholding = 0;
    for nt=1:num_trials
        % Sensing matrix
        Phi = spx.dict.simple.gaussian_dict(M, N);
        % Sparse signal generator
        gen  = spx.data.synthetic.SparseSignalGenerator(N, K, S);
        % Gaussian distributed non-zero samples
        X = gen.gaussian;
        % Measurement vectors
        Y = Phi * X;
        

        % Create the solver for simultaneous orthogonal matching pursuit
        solver = spx.pursuit.joint.OrthogonalMatchingPursuit(Phi, K, 2);
        result = solver.solve(Y);
        % Solution vectors
        X_Rec = result.Z;
        % Comparison
        cs = spx.commons.SparseSignalsComparison(X, X_Rec, K);
        % Reconstruction SNR
        snr = cs.cum_signal_to_noise_ratio;
        success = snr > snr_threshold;
        num_successes.somp = num_successes.somp + success;

        % Create the solver for rank aware orthogonal matching pursuit
        solver = spx.pursuit.joint.RankAwareOMP(Phi, K);
        result = solver.solve(Y);
        % Solution vectors
        X_Rec = result.Z;
        % Comparison
        cs = spx.commons.SparseSignalsComparison(X, X_Rec, K);
        % Reconstruction SNR
        snr = cs.cum_signal_to_noise_ratio;
        success = snr > snr_threshold;
        num_successes.ra_omp = num_successes.ra_omp + success;

        % Create the solver for rank aware order recursive matching pursuit
        solver = spx.pursuit.joint.RankAwareORMP(Phi, K);
        result = solver.solve(Y);
        % Solution vectors
        X_Rec = result.Z;
        % Comparison
        cs = spx.commons.SparseSignalsComparison(X, X_Rec, K);
        % Reconstruction SNR
        snr = cs.cum_signal_to_noise_ratio;
        success = snr > snr_threshold;
        num_successes.ra_ormp = num_successes.ra_ormp + success;

        % Create the solver for rank aware thresholding
        solver = spx.pursuit.joint.RankAwareThresholding(Phi, K);
        result = solver.solve(Y);
        % Solution vectors
        X_Rec = result.Z;
        % Comparison
        cs = spx.commons.SparseSignalsComparison(X, X_Rec, K);
        % Reconstruction SNR
        snr = cs.cum_signal_to_noise_ratio;
        success = snr > snr_threshold;
        num_successes.ra_thresholding = num_successes.ra_thresholding + success;

        fprintf('S: %d, K=%d, trial=%d\n', S, K, nt);
    end
    success_with_s.somp(ns) = num_successes.somp / num_trials;
    success_with_s.ra_omp(ns) = num_successes.ra_omp / num_trials;
    success_with_s.ra_ormp(ns) = num_successes.ra_ormp / num_trials;
    success_with_s.ra_thresholding(ns) = num_successes.ra_thresholding / num_trials;
end


save ('bin/figure_2_success_with_s_comparison.mat');

