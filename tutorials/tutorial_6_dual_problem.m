% This tutorial explains the main features of the dual problem class.
% While in the primal problem we want to find the solution u that minimizes
% the loss for all test functions v, in the dual problem we want to find
% the test function v that maximizes the same loss for a given trial
% solution u.


% solve the primal problem
tutorial_5_optimizer

% create the dual problem
dual_prob = DualProblem(problem);

% create a net for the dual problem
dual_net =  Net([1 3 1],dual_prob);

% We need to normalize the loss (default) otherwise the max is at infinity.
% This does not mean that the trial of the dual problem is normalized.
dual_prob.normalize_loss = true;

% the normalized dual problem is not linear anymore
dual_prob.islinear = false;

% create an optimizer for the chosen network and the chosen problem
dual_opt = Optimizer(dual_net,dual_prob);

% we want to maximize the loss
dual_opt.minimize = false;

% set the optimizer paramters
dual_opt.epochs = 200;
dual_opt.init_learn_rate = 1e-1;
dual_opt.learn_decay = 0;
dual_opt.plot = true;

% Solving a linear system to find the ouput paramters of the
% network can be done only when minimizing the loss.
% Hence we use the adam optimizer even for the output paramters.
% Moreover, the normalized dual problem is not linear anymore.
dual_opt.train_adam;

% plot the solution
dual_prob.plot

% since for the dual problem we do not know in general the exact solution,
% we cannot compute the error
dual_prob.error.L2



