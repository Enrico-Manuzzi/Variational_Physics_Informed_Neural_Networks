% This tutorial gives a breif overview
% on how to solve a simple L2 approximation problem
% using Variational Physics-Informed Neural Networks (VPINNs)

%% clean everything
clear, clc, close all
rng('default')

%% define saving options
data.name = 'vpinn_example';
data.save = true;

%% define the parameters of the L2 approximation problem
data.problem = 'L2'; 
data.solution = @(x,freq) sin(freq*x);
data.grad_solution = @(x,k) k*cos(k*x);
data.iscomplex = false;
data.domain = [0,pi];
data.frequency = 2;
data.quad_nodes = 8;

%% define the number of mesh elements 
data.elements = 10;

%% define the test space using hat functions
data.test_space = 'hat';

%% define the architecture of a shallow neural network
data.hidden_layers = 1; 
data.neurons = 4;

%% define the parameters of the optimizer using the mixed training strategy
data.train = 'mixed';
data.epochs = 100;
data.learn_rate = 1e-2;
data.learn_decay = 0;

%% create the vpinn and solve
vpinn = VPINN(data);
vpinn.solve
