classdef ApproxL2 < Problem
    properties
        frequency = 1;
        parametric_solution = @(x,k) sin(x*k);
    end
    
    methods
        function obj = ApproxL2
            obj.islinear = true;
        end

        function [y,dy] = solution(prob,x)
            k = prob.frequency;
            [y,dy] = prob.parametric_solution(x,k);
        end

        function [Auv,Fv,Avv] = weak_form(prob,trial,test_fun)
            D = prob.domain;
            S = test_fun.support;
            a = max(S(1),D(1));
            b = min(S(2),D(2));
            [x,w] = prob.quad_rule(prob.quad_nodes,a,b);
            int = @(fun) fun*w(:);

            u = trial.eval(x);
            v = test_fun.eval(x);
            f = prob.solution(x);

            Auv = int(u.*conj(v));
            Avv = int(v.*conj(v));
            Fv =  int(f.*conj(v));
        end
        
    end
end