% This tutorial explains the main features of the neural netowrk class.

% clean everything
clear, clc, close all

% specify the network dimensions:
% [input hidden_layer1 hidden_layer2 ... output]
dimensions = [1 2 3 2 1];

% create the network using the Xavier initialization
net = Net(dimensions);

% query the dimensions of the net
net.dimensions

% query the layers
net.layers

% query the activation function
net.act

% query the output weights
net.param(end).W

% query the output bias
net.param(end).b

% evalutate the network and its derivatives
x = linspace(0,1);
[y,dy,d2y] = net.eval(x);

% add one layer to the network
neurons = 12;
net.dimensions
net.add_layer(neurons);
net.dimensions

% create a dummy complex problem
complex_problem.iscomplex = true;

% use the complex problem to initialize a network:
% because the problem is complex the network must output both the real part
% and the imaginary part. Hence it must have output dimension 2
dimensions = [1 2 2 2];
complex_net = Net(dimensions,complex_problem);

% complex networks output complex numbers when evaluated, not points in R^2
y = complex_net.eval(x)

% create a dummy physical problem
physical_problem.iscomplex = false;
physical_problem.domain = [0,1];
physical_problem.frequency = 3;

% use the physical problem to initialize a shallow network with the
% Henriquez initialization, i.e. weights = frequency and equally spaced
% activation functions over the domain
neurons = 30;
physical_net = Net.Henriquez(neurons,physical_problem);
physical_net.dimensions

