classdef Optimizer < matlab.mixin.Copyable
    properties
        problem
        epochs = 1000;
        init_learn_rate = 1e-3;
        learn_decay = 0;
        plot = true;
        minimize = true;
        train_output_bias = true;
    end
    properties (Access=private)
        best_param
        best_loss
        loss
        adam_step
        start
        mean_grad
        mean_grad_sq
        learn_rate
        fig
        line_loss
    end
    methods
        function N = net(opt)
            N = opt.problem.trial;
        end
        
        function opt = Optimizer(net,problem)
            problem.trial = net;
            opt.problem = problem;
        end

        function train_adam(opt,layers_to_train)
            if nargin < 2
                L = opt.net.layers;
                layers_to_train = 1:L;
            end
            opt.initialize
            % if opt.minimize
            %     opt.train_linear;
            % end
            for i = 1:opt.epochs
                opt.update_param(layers_to_train);
                opt.update_plot(i)
            end
            opt.pick_best
        end

        function train_mixed(opt)
            opt.initialize
            L = opt.net.layers;
            for i = 1:opt.epochs
                % i
                opt.train_linear;
                % opt.problem.error.H1
                opt.update_param(1:L-1);
                % opt.problem.error.H1
                opt.update_plot(i)
            end
            opt.pick_best
        end

        function [A,F] = train_linear(opt)
            if not(opt.minimize)
                error('Finding output paramters as solution of a linear system is only for minimization problems.')
            end
            if opt.problem.islinear
                % last layer = output = linear case
                tmp_net = opt.net;
                if opt.train_output_bias
                    add_bias = true;
                    opt.problem.trial = @(x) tmp_net.features(x,add_bias);
                else
                    opt.problem.trial = @(x) tmp_net.features(x);
                end
                [A,F] = opt.problem.eval;
                opt.problem.trial = tmp_net;
                if isa(A,'dlarray')
                    A = extractdata(A);
                end
                if isa(F,'dlarray')
                    F = extractdata(F);
                end
    
                par_lin = A\F;

                if opt.train_output_bias
                    opt.net.param(end).W = dlarray(real(par_lin(1:end-1))');
                    opt.net.param(end).b = dlarray(real(par_lin(end)));
                else
                    opt.net.param(end).W = dlarray(real(par_lin)');
                    opt.net.param(end).b = dlarray(0);
                end
                if  opt.problem.iscomplex
                    if opt.train_output_bias
                        opt.net.param(end).W = [opt.net.param(end).W; imag(par_lin(1:end-1))'];
                        opt.net.param(end).b = [opt.net.param(end).b; imag(par_lin(end))];
                    else
                        opt.net.param(end).W = [opt.net.param(end).W; imag(par_lin)'];
                        opt.net.param(end).b = [opt.net.param(end).b; 0];
                    end
                end

                % HERE GOES THE SAVE BEST PARAM CALL!!!
                opt.save_best_param;
            else
                opt.update_param(opt.net.layers)
            end
        end

        function initialize(opt)
            opt.best_param = opt.net.param;
            opt.best_loss = opt.problem.loss;
            opt.adam_step = 0;
            opt.start = tic;
            opt.mean_grad = [];
            opt.mean_grad_sq = [];
            opt.learn_rate = opt.init_learn_rate;
            if opt.plot
                figure('Name',[opt.problem.name,'_training']);
                opt.fig = gca;
                C = colororder;
                opt.line_loss = animatedline(Color=C(2,:));
                ylim([0 inf])
                xlabel("Epoch")
                ylabel("Loss")
                set(opt.fig, 'YScale', 'log')
                grid on
                opt.loss = opt.problem.loss;
                opt.update_plot(0)
            end
        end


        function update_plot(opt,epoch)
            if opt.plot
                addpoints(opt.line_loss,epoch,opt.loss);    
                D = duration(0,0,toc(opt.start),Format="hh:mm:ss");
                title(opt.fig,"Epochs: " + epoch + ", Elapsed: " + string(D) + ", Loss: " + num2str(opt.loss))
                drawnow
            end
        end

        function update_param(opt,layers_to_train)
            L = opt.net.layers;
            if nargin < 2
                layers_to_train = 1:L;
            end

            if isequal(layers_to_train,L) && opt.minimize
                warning('Using Adam to find output paramters ONLY. Solving a linear system using function train_linear is prefered.')
            end

            [~,grad] = opt.problem.loss;
            if not(opt.minimize) % = maximize
                for j = 1:L
                    grad(j).W = -grad(j).W;
                    grad(j).b = -grad(j).b;
                end
            end
            opt.learn_rate = opt.init_learn_rate/(1+opt.learn_decay*opt.adam_step);
            I = layers_to_train;
            opt.adam_step = opt.adam_step+1;
            if not(opt.train_output_bias)
                old_bias = opt.net.param(end).b;
            end
            [opt.net.param(I),opt.mean_grad,opt.mean_grad_sq] = adamupdate ...
                (opt.net.param(I),grad(I),opt.mean_grad,opt.mean_grad_sq,opt.adam_step,opt.learn_rate);
            if not(opt.train_output_bias)
                opt.net.param(end).b = old_bias;
            end

            opt.save_best_param;
        end

        function save_best_param(opt)
            opt.loss = opt.problem.loss;
            if opt.minimize
                if opt.loss < opt.best_loss
                    opt.best_loss = opt.loss;
                    opt.best_param = opt.net.param;
                end
            else
                if opt.loss > opt.best_loss
                    opt.best_loss = opt.loss;
                    opt.best_param = opt.net.param;
                end
            end
        end

        function pick_best(opt)
            opt.net.param = opt.best_param;
            opt.loss = opt.best_loss;
        end

    end
end