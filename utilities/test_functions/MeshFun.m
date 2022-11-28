classdef (Abstract) MeshFun < TestFun
    properties
        mesh
    end
    methods
        function obj = MeshFun(mesh,id)
            obj.mesh = mesh;
            if nargin > 1
                obj.id = id;
            end
        end
        function m = mod(fun)
            m = fun.mesh.mod(fun.id);
        end
        function d = div(fun)
            d = fun.mesh.div(fun.id);
        end
        N = cardinality(space);
        S = support(fun);
        [y,dy,d2y] = eval(fun,x);
    end
end

