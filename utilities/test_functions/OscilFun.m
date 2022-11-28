classdef OscilFun < MeshFun
    properties
        problem = struct('frequency',1);
        iscomplex = true;
    end
    methods
        function V = OscilFun(mesh,problem)
            V = V@MeshFun(mesh);
            V.problem = problem;
        end
        function N = cardinality(space)
            N = 2*space.mesh.nodes;
        end
        function S = support(fun)
            h = HatFun(fun.mesh,fun.mod);
            S = h.support;
        end
        function k = frequency(space)
            k = space.problem.frequency;
        end
        function [y,dy] = eval(fun,x)
            id_h = fun.mod;
            h = HatFun(fun.mesh,id_h);
            [y_h,dy_h] = h.eval(x);
            k = fun.frequency;
            if fun.div == 1
                y  =  y_h.*exp(+1i*k*x);
                dy = dy_h.*exp(+1i*k*x) + 1i*k.*exp(+1i*k*x).*y_h;
            else
                y  =  y_h.*exp(-1i*k*x);
                dy = dy_h.*exp(-1i*k*x) - 1i*k.*exp(-1i*k*x).*y_h;
            end
        end
    end
end