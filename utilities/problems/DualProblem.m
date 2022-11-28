classdef DualProblem < Problem
    properties
        primal
    end
    methods
        function obj = DualProblem(prob)
            obj.primal = prob;
            obj.name = [obj.primal.name,'_dual'];
            obj.test_space = ListFun({prob}); % test space = problem trial
            obj.islinear = obj.primal.islinear;
            obj.iscomplex = obj.primal.iscomplex;
            obj.domain = obj.primal.domain;
            obj.quad_rule = obj.primal.quad_rule;
            obj.quad_nodes = obj.primal.quad_nodes;
            obj.normalize_loss = true;
        end
        function [Auv,Fv,Avv] = weak_form(obj,trial,test_fun)
            % trial = function to train = original v
            % test_fun = function fixed = original u
            [Auv,Fv,Avv] = obj.primal.weak_form(test_fun,trial);
        end
        function [u,du,d2u] = solution(obj,x)
            switch nargout
                case 1
                    u = obj.primal.solution(x);
                case 2
                    [u,du] = obj.primal.solution(x);
                case 3
                    [u,du,d2u] = obj.primal.solution(x);
            end
        end
        function E = error(obj)
            E = error@Problem(obj);
            E.L2 = nan;
            E.H1 = nan;
            E.H2 = nan;
            E.u = nan;
        end
        function plot(obj)
            plot@Problem(obj)
            title('solution of the dual problem')
            legend off
        end
    end
end