classdef Net < matlab.mixin.Copyable
    properties
        param
        problem = struct('iscomplex',false,'frequency',1,'domain',[0,1]);
        act = @(x) tanh(x);
        dact = @(x) 1 - tanh(x).^2;
        d2act = @(x) 2*tanh(x).*(tanh(x).^2 - 1);
%         act = @(x) max(x,0);
%         dact = @(x) (x>0);
%         d2act = @(x) 0*x;
        support = [-inf,inf];
    end

    methods (Static)

        function weights = Xavier(row,col)
            weights = randn(row,col)/sqrt(row*col);
            weights = dlarray(weights);
        end

        function net = lin_comb_gen(nets)
            net = Net;
            net.problem = nets{1}.problem; % all must have the same problem
            N = length(nets);
            L = nets{1}.layers; % all must have the same number of layers
            for i = 1:L
                net.param(i).W = [];
                net.param(i).b = [];
                for j = 1:N
                    net.param(i).W = blkdiag(net.param(i).W,nets{j}.param(i).W);
                    net.param(i).b = [net.param(i).b;nets{j}.param(i).b];
                end
            end
            net.param(1).W = sum(net.param(1).W,2);
            F = net.features;
            O = nets{1}.output;
            W = Net.Xavier(O,F);
            net.param(L).W = W*net.param(L).W;
            net.param(L).b = W*net.param(L).b;
        end

        function net = lin_comb(nets)
            % all nets are equal but for the last non-linear parameters
            v1 = nets{1};
            N = length(nets);
            net = Net(dimensions(v1));
            net.problem = v1.problem;
            L = v1.layers;
            net.param = v1.param(1:L-2);
            O = v1.output;
            net.param(L-1).W = [];
            net.param(L-1).b = [];
            for i = 1:N
                net.param(L-1).W = [net.param(L-1).W;nets{i}.param(L-1).W];
                net.param(L-1).b = [net.param(L-1).b;nets{i}.param(L-1).b];
            end
            % net.param(L).W = Net.Xavier(O,length(net.param(L-1).b));
            net.param(L).W = ones(O,length(net.param(L-1).b));
            net.param(L).b = zeros(O,1);
        end
        
        
        function net = Henriquez(neurons,problem)
            N = neurons;
            a = problem.domain(1);
            b = problem.domain(2);
            k = problem.frequency;
            out = problem.iscomplex + 1;
            net = Net([1,N,out],problem);
            mesh = linspace(a,b,N);
            net.param(1).W = k*ones(N,1);
            net.param(1).b = - net.param(1).W.*mesh';
            net.param(2).W = zeros(out,N);
            net.param(2).b = zeros(out,1);
            net.make_trainable
        end

    end

    methods
        
        function make_trainable(net)
            for i = 1:net.layers
                net.param(i).W = dlarray(net.param(i).W);
                net.param(i).b = dlarray(net.param(i).b);
            end
        end

        function TF = iscomplex(net)
            TF = net.problem.iscomplex;
        end

        function obj = Net(dims,problem)
            % e.g. shallow complex net: dims = [1 10 2] 
            if nargin > 0
                if nargin == 2
                    obj.problem = problem;
                    if obj.problem.iscomplex && dims(end) ~= 2
                        error('net is complex but ouput size is not 2')
                    end
                end
                for i = 1:length(dims)-1
                    obj.param(i).W = Net.Xavier(dims(i+1),dims(i));
                    obj.param(i).b = Net.Xavier(dims(i+1),1);
                end
            end
        end

        function [y,dy,d2y,a,da,d2a,b] = eval(net,x)
            % x --> ... --> b --> a --> y
            a = x;
            da = x.^0;
            d2a = 0*x;
            y = net.param(1).W*a + net.param(1).b;
            dy = net.param(1).W*da;
            d2y = net.param(1).W*d2a;
            for i = 2:net.layers
                b = a; 
                a = net.act(y);
                da = net.dact(y).*dy;
                d2a = net.d2act(y).*dy+d2y.*net.dact(y);
                y = net.param(i).W*a + net.param(i).b;
                dy = net.param(i).W*da;
                d2y = net.param(i).W*d2a;
            end
            if net.iscomplex
                y = y(1,:)+1i*y(2,:);
                dy = dy(1,:)+1i*dy(2,:);
                d2y = d2y(1,:)+1i*d2y(2,:);
            end
        end

        function L = layers(net)
            L = length(net.param);
        end

        function D = dimensions(net)
            D = zeros(1,1+net.layers);
            D(1) = size(net.param(1).W,2);
            for i = 1:net.layers
                D(i+1) = length(net.param(i).b);
            end
        end

        function [F,dF,d2F] = features(net,x,add_bias)
            if nargin > 1
                [~,~,~,F,dF,d2F] = net.eval(x);
                if nargin > 2 && add_bias
                    F = [F;ones(size(x))];
                    dF = [dF;zeros(size(x))];
                    d2F = [d2F;zeros(size(x))];
                end
            else
                F = length(net.param(end-1).b);
            end
        end

        function out = output(net)
            out = length(net.param(end).b);
        end

        function net1 = arrow(net1,net2)
            % x -> net1 -> net2 -> y
            par_new.W = net2.param(1).W*net1.param(end).W;
            par_new.b = net2.param(1).W*net1.param(end).b + net2.param(1).b;
            net1.param = [net1.param(1:end-1),par_new,net2.param(2:end)];
            net1.problem.iscomplex = net2.iscomplex;
        end

        function net1 = add_layer(net1,neurons)
            net2 = Net([net1.output,neurons,net1.output],net1.problem);
            net1.arrow(net2);
        end

    end
end