classdef (Abstract) TestFun < matlab.mixin.Copyable
    properties
        id
    end
    methods
        function obj = TestFun(id)
            if nargin
                obj.id = id;
            end
        end
        function fun = get(space,id)
            fun = copy(space);
            fun.id = id;
        end
        N = cardinality(space);
        S = support(fun);
        [y,dy,d2y] = eval(fun,x);
    end
end

% Simple usage
% v = HatFun(mesh,id);
% v.support
% v.eval(x)
% v.cardinality

% Fancy usage
% V = HatFun(mesh);
% V.cardinality
% V.support --> error because id = []
% V.eval    --> error because id = []
% v = get(V,id);
% v.support
% v.eval(x)

