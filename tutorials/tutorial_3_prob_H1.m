% This tutorial explains the main features of the variational problem class
% for the approximation of a function in H1.

% clean everything
clear, clc, close all

% create the variational problem object
problem = ApproxH1;

% query if the problem is linear with rispect to the solution
problem.islinear

% set the frequency of the problem
problem.frequency = 2;

% set the problem domain
problem.domain = [0,2*pi];

% set the true solution, defined at the end of this example
problem.parametric_solution = @my_solution;

% set the trial solution, defined at the end of this example
problem.trial = @my_trial;

% since the solution is complex we set the corresponding flag to true
problem.iscomplex = true;

% set the name for saving purposes
problem.name = 'test_H1';

% set the test space
mesh = Mesh(problem.domain,100);
problem.test_space = HatFun(mesh);

% use the Gauss-Legendre quadrature rule (default)
problem.quad_rule = @lgwt;

% set the number of quadrature nodes
problem.quad_nodes = 8;

% by default the loss is not normalized, i.e. each term is of the form:
% (a(u,v)-F(v))^2
% if you normalize the loss then each tearm is of the form:
% (a(u,v)-F(v))^2/a(v,v)
problem.normalize_loss = true;

% calculate the loss
problem.loss

% calculate the L2 error
problem.error.L2

% calculate the H1 error
problem.error.H1

% plot the solution and the trial
problem.plot


%% true solution
function [y,dy] = my_solution(x,frequency)
    k = frequency;
    y = sin(k*x) + 1i*cos(k*x);
    dy = k*cos(k*x) - 1i*k*sin(k*x);
end

%% trial solution
function [y,dy] = my_trial(x)
    y = x.^2/36;
    dy = 2*x/36;
end