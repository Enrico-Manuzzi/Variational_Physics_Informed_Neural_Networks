classdef ListFun < TestFun
    properties
        list
    end
    methods
        function obj = ListFun(list)
            if nargin
                obj.list = list;
            end
        end
        function add(space,fun)
            space.list{end+1} = fun;
        end
        function N = cardinality(space)
            N = length(space.list);
        end
        function [y,dy,d2y] = eval(fun,x)
            switch nargout
                case 1
                     y = fun.list{fun.id}.eval(x);
                case 2
                    [y,dy] = fun.list{fun.id}.eval(x);
                case 3
                    [y,dy,d2y] = fun.list{fun.id}.eval(x);
            end
        end
        function fun = get(space,id)
            fun = space.list{id};
            % if the test space is problem
            % the test function is the problem trial
            if isa(fun,'Problem')
                fun = fun.trial;
            end
        end
    end
end