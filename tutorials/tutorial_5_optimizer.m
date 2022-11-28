% This tutorial explains the main features of the optmizer class.

% clean everything
clear, clc, close all
rng('default')


% create a problem
problem = ApproxL2;
problem.frequency = 1;
problem.domain = [0,2*pi];
problem.parametric_solution = @my_solution;
problem.iscomplex = false;
problem.quad_nodes = 10;
mesh = Mesh(problem.domain,10);
problem.test_space = HatFun(mesh);


% create a shallow neural network using the Henriquez initialiation
neurons = 4;
net = Net.Henriquez(neurons,problem);

% create an optimizer for the chosen network and the chosen problem
optimizer = Optimizer(net,problem);

% set the optimizer paramters
optimizer.epochs = 100;
optimizer.init_learn_rate = 1e-2;
optimizer.learn_decay = 0;
optimizer.plot = true;
optimizer.minimize = true;
optimizer.train_output_bias = true;

% train the output parameters only
% and return the linear system which was used to find them
[A,F] = optimizer.train_linear;

% solve the minimization problem, using train_linear for the output
% paramters and adam for the non-linear paramters
optimizer.train_mixed;

% plot the solution
problem.plot


%% true solution
function [y,dy] = my_solution(x,frequency)
    k = frequency;
    y = sin(k*x);
    dy = k*cos(k*x);
end