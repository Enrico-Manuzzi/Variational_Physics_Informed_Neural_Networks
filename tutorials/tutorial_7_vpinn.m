% This tutorial explains the main features of the VPINN class.
% In short, this class is supposed to be a more simple interface to perform
% the operations described in the previous tutorial.

% clean everything
clear, clc, close all
rng('default')

% storage
data.name = 'vpinn_f1';
data.save = true;

% problem
data.problem = 'L2'; % L2 - H1
data.solution = @(x,k) sin(k*x);
data.grad_solution = @(x,k) k*cos(k*x);
data.iscomplex = false;
data.domain = [0,pi];
data.frequency = 1;
data.quad_nodes = 8;

% mesh
data.elements = 10;

% test space
data.test_space = 'oscil'; % hat - oscil

% neural network
data.hidden_layers = 1; 
data.neurons = 4;

% optimizer
data.train = 'mixed'; % linear - adam - mixed 
data.epochs = 25;
data.learn_rate = 1e-2;
data.learn_decay = 0;

% create the vpinn
vpinn = VPINN(data);
vpinn.solve

% create the dual problem and solve it
dual_vpinn = dual(vpinn);
dual_vpinn.epochs = 200;
dual_vpinn.solve

% change the frequency of the original problem and solve it (also the dual
% will change)
vpinn.problem.frequency = 2;
vpinn.problem.name = 'vpinn_f2';
vpinn.solve




