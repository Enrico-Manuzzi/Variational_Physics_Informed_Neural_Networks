% This tutorial explains the main features of the test space class for hat
% functions.

% clean everything
clear, clc, close all

% create a mesh
domain = [0,1];
elements = 5;
mesh = Mesh(domain,elements);

% create the test space of hat functions
V_hat = HatFun(mesh);

% query how many test functions are in the space
V_hat.cardinality

% get a the first hat function from the test_space
id = 1;
v1 = get(V_hat,id);

% query the support of the test function
v1.support

% evaluate and plot the test function
x = linspace(domain(1),domain(2));
y = v1.eval(x);
figure
subplot(1,2,1)
title('hat functions of the initial mesh')
plot(x,y)

% get the second hat function with an alternative notation
id = 2;
v2 = HatFun(mesh,id);

% and plot it
hold on
plot(x,v2.eval(x))

% because of the pointer behaviour, if we refine the mesh the hat functions
% are automatically updated
mesh.refine([1 2]);
subplot(1,2,2)
title('hat functions of the refine mesh')
plot(x,v1.eval(x),x,v2.eval(x))
