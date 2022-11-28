classdef VPINN < Optimizer
    properties
        save_all
        train = 'adam';
    end
    methods
        function vpinn = VPINN(data)
            % create the mesh
            mesh = Mesh(data.domain,data.elements);

            % create the problem
            switch data.problem
                case 'L2'
                    problem = ApproxL2;
                case 'H1'
                    problem = ApproxH1;
            end
            problem.name = data.name;
            problem.frequency = data.frequency;
            problem.iscomplex = data.iscomplex;
            problem.domain = data.domain;
            problem.quad_nodes = data.quad_nodes;
            function [y,dy] = my_solution(x,frequency)
                k = frequency;
                y = data.solution(x,k);
                dy = data.grad_solution(x,k);
            end
            problem.parametric_solution = @my_solution;
            
            % create the test space
            switch data.test_space
                case 'hat'
                    problem.test_space = HatFun(mesh);
                case 'oscil'
                    problem.test_space = OscilFun(mesh,problem);
            end

            % create the network
            if data.hidden_layers == 1
               net = Net.Henriquez(data.neurons,problem);
            else
                dimensions = [1,data.neurons*ones(1,data.hidden_layers),1+data.iscomplex];
                net = Net(dimensions,problem);
            end


            % create the optimizer
            vpinn = vpinn@Optimizer(net,problem);
            vpinn.init_learn_rate = data.learn_rate;
            vpinn.learn_decay = data.learn_decay;
            vpinn.epochs = data.epochs;
            vpinn.train = data.train;
            vpinn.save_all = data.save;
        end

        function dual_obj = dual(obj)
            
            dual_prob = DualProblem(obj.problem);
            dual_prob.normalize_loss = true;
            dual_prob.islinear = false;

            dual_net =  Net(obj.net.dimensions,dual_prob);
            dual_prob.trial = dual_net;

            dual_obj = copy(obj);
            dual_obj.problem = dual_prob;

            dual_obj.minimize = false;
            dual_obj.train = 'adam';
            
        end

        function solve(obj)
            switch obj.train
                case 'linear'
                    obj.train_linear
                case 'adam'
                    obj.train_adam
                case 'mixed'
                    obj.train_mixed
            end
            obj.problem.plot
            if obj.save_all
                save_all_figures
                vpinn = copy(obj);
                save([path2('data'),obj.problem.name],"vpinn");
            end
        end        
    end
end