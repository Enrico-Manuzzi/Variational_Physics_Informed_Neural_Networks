% This tutorial explains the main features of the mesh class.

% clean everything
clear, clc, close all

% number of mesh elements
elements = 5;

% the interval you want to mesh
domain = [0 1];

% create the mesh object, with equally spaced nodes
mesh = Mesh(domain,elements);

% get the coordinates of the vertices
mesh.coord

% get the number of elements
mesh.elements

% get the number of nodes ( nodes = elements + 1)
mesh.nodes

% plot the mesh
subplot(1,2,1)
mesh.plot
title('intial mesh')

% refine the mesh
elem_to_refine = [1 2 5];
mesh.refine(elem_to_refine)

% plot the refined mesh
subplot(1,2,2)
mesh.plot
title('refined mesh')

% create a new pointer to the same mesh
new_ptr = mesh;

% create a copy of the mesh
new_mesh = copy(mesh);

% see the following links for more informations on the pointer behaviour:
% https://ch.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html
% https://ch.mathworks.com/help/matlab/ref/matlab.mixin.copyable-class.html