% This tutorial shows how to greedly train a neural network while
% increasing the frequency of the solution. This is an advanced tutorial
% that exploits customed training procedures.

% clean everything
clear, clc, close all
rng('default')

% dock all figures
set(0,'DefaultFigureWindowStyle','docked');

%% primal problem data

% storage
data.name = 'greedy';
data.save = false;

% problem
data.problem = 'H1'; % L2 - H1
data.solution = @(x,k) sin(k*x);
data.grad_solution = @(x,k) k*cos(k*x);
data.iscomplex = false;
data.domain = [0,pi];
data.frequency = 1;
data.quad_nodes = 10;

% mesh
data.elements = 10;

% test space
data.test_space = 'hat'; % hat - oscil

% neural network
data.hidden_layers = 1; 
data.neurons = 1;

% optimizer
data.train = 'mixed'; % linear - adam - mixed 
data.epochs = 100;
data.learn_rate = 1e-2;
data.learn_decay = 0;

%% build vpinn and its dual

vpinn = VPINN(data);
vpinn.train_output_bias = false;
vpinn.net.param(end).b(:) = 0;
vpinn.net.param(end).W(:) = 0;
V0 = vpinn.problem.test_space;

dual_vpinn = dual(vpinn);
dual_vpinn.epochs = 200;
dual_vpinn.init_learn_rate = 1e-1;
dual_vpinn.problem.quad_nodes = 25;
dual_vpinn.train_output_bias = false;
dual_vpinn.problem.normalize_loss = not(isequal(data.problem,'L2'));

%% Greedy algorithm

format = '%.2e';
trial_neurons = 5;
freq_list = [1 2 4];
for f = 1:length(freq_list)
    disp("Frequencey " + freq_list(f))
    vpinn.problem.frequency = freq_list(f);
    err_L2 = zeros(1,trial_neurons);
    err_H1 = zeros(1,trial_neurons);
    v_new = copy(vpinn.net);
    if f > 1
        v_new.add_layer(1);
    end

    vpinn.problem.test_space = ListFun({});
    
    for i = 1:trial_neurons
        %% solve the dual problem
    
        % sample random paramters and pick the ones maximizing the loss
        for k = 1000:-1:1
            dual_vpinn.problem.trial = copy(v_new);
            dual_vpinn.net.param(end-1).W(:) = ones(size(dual_vpinn.net.param(end-1).W));
            dual_vpinn.net.param(end-1).b(:) = -pi*rand(size(dual_vpinn.net.param(end-1).b));
            dual_vpinn.net.param(end).W(1) = 1;
            if data.iscomplex
                dual_vpinn.net.param(end).W(2) = 1;
            end
            dual_vpinn.net.param(end).b(:) = 0;
            loss_list(k) = dual_vpinn.problem.loss;
            net_list(k) = copy(dual_vpinn.net);
        end
        [~,I] = max(loss_list);
        dual_vpinn.problem.trial = copy(net_list(I));

        % train the last hidden layer only using adam
        L = dual_vpinn.net.layers;
        dual_vpinn.train_adam(L-1);
        dual_vpinn.problem.plot
        
        %% find the linear parameters for the primal problem
        w = copy(dual_vpinn.net);
        V = vpinn.problem.test_space;
        V.add(w);
        vpinn.problem.trial = Net.lin_comb(V.list);
        vpinn.train_linear;
        vpinn.problem.plot

        E = vpinn.problem.error;
        err_L2(i) = extractdata(E.L2);
        err_H1(i) = extractdata(E.H1);
        
        disp("Error L2: "+ num2str(err_L2(i),format) + " H1: " + num2str(err_H1(i),format))

    end
    %% show convergence plots

    figure('Name',[vpinn.problem.name,'_convergence_L2'])
    N = 1:trial_neurons;
    loglog(N,err_L2,N,N.^-2)
    title('Convergence L2')
    legend('error L^2','N^{-2}')
    xlabel('neurons')

    figure('Name',[vpinn.problem.name,'_convergence_H1'])
    N = 1:trial_neurons;
    loglog(N,err_H1,N,N.^-2)
    title('Convergence H1')
    legend('error H^1','N^{-2}')
    xlabel('neurons')

    
%     figure('Name',[vpinn.problem.name,'_test_space'])
%     hold on
%     V = vpinn.problem.test_space;
%     for i = 1:V.cardinality
%         v = get(V,i);
%         x = linspace(data.domain(1),data.domain(2));
%         y = v.eval(x);
%         plot(x,y)
%     end
%     xlim(data.domain)
%     title('Greedy test space')

    %% solve primal using the greedy algorithm as initialization
    vpinn.problem.test_space = V0;
    disp('Solving primal using greedy initial guess')
    vpinn.solve
    E = vpinn.problem.error;
    disp("Error L2: "+ num2str(extractdata(E.L2),format) + " H1: " + num2str(extractdata(E.H1),format))
    disp(' ')
end



% back to normal figure settings
set(0,'DefaultFigureWindowStyle','normal');