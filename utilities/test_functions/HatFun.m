classdef HatFun < MeshFun
    properties
        iscomplex = false;
    end
    methods
        function N = cardinality(space)
            N = space.mesh.nodes;
        end
        function S = support(fun)
            im = max(fun.id-1,1);
            ip = min(fun.id+1,fun.mesh.nodes);
            a = fun.mesh.coord(im);
            b = fun.mesh.coord(ip);
            S = [a,b];
        end
        function [y,dy] = eval(fun,x)
            S = fun.support;
            a = S(1); b = S(2);
            value = zeros(1,fun.mesh.nodes);
            value(fun.id) = 1;
            y = interp1(fun.mesh.coord,value,x);
            c = fun.mesh.coord(fun.id);
            dy = zeros(size(x));
            dy(a<=x & x<=c) = 1/(c-a);
            dy(c<=x & x<=b) = -1/(b-c);
        end
    end
end