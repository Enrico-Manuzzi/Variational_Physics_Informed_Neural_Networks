classdef Mesh < matlab.mixin.Copyable
    properties
        coord
    end
    methods
        function obj = Mesh(domain,elements)
            obj.coord = linspace(domain(1),domain(2),elements+1);
        end
        function N = nodes(mesh)
            N = length(mesh.coord);
        end
        function E = elements(mesh)
            E = mesh.nodes - 1;
        end
        function mesh = refine(mesh,elem)
            new_nodes = (mesh.coord(elem)+mesh.coord(elem+1))/2;
            mesh.coord = sort([mesh.coord,new_nodes]);
        end
        function m = mod(mesh,id)
            % m = the node I get in position id if the mesh were periodic
            m = mod(id-1,mesh.nodes)+1;
        end
        function d = div(mesh,id)
            % d = how many times I have to repeat the mesh to contain id
            d = ceil(id/mesh.nodes);
        end
        function plot(mesh)
            plot(mesh.coord,zeros(1,mesh.nodes),'-o')
            ylim([-1 1])
            xlim([mesh.coord(1),mesh.coord(end)])
        end
    end
end