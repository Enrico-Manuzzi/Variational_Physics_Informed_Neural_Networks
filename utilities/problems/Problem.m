classdef (Abstract) Problem < matlab.mixin.Copyable
    properties
        islinear
        iscomplex
        name = 'test'
        domain
        trial
        test_space
        quad_rule = @lgwt;
        quad_nodes = 10;
        normalize_loss = false;
    end
    methods (Static)
        function df = d(f,x)
            x = dlarray(x);
            [Rx,Ix] = dlfeval(@Approximation.grad,f,x);
            df = Rx + 1i*Ix;
        end
        function [Rx,Ix] = grad(f,x)
            R = real(f(x));
            I = imag(f(x));
            Rx = dlgradient(sum(R,'all'),x,'AllowComplex',false);
            Ix = dlgradient(sum(I,'all'),x,'AllowComplex',false);
        end
    end
    methods (Abstract)
        [Auv,Fv,Avv] = weak_form(prob,guess,test_fun)
        u = solution(prob,x);
    end
    methods
        
        function set.trial(prob,trial)
            if isa(trial,'function_handle')
                G.eval = trial;
                G.param = [];
                G.support = [nan,nan];
                prob.trial = G;
            else
                prob.trial = trial;
            end
        end

        function [Auv,Fv,Avv] = eval(prob,param)
            if nargin > 1
                prob.trial.param = param;
            end
             N = prob.test_space.cardinality;
            for i = N:-1:1
                test_fun = get(prob.test_space,i);
                [Auv(i,:),Fv(i,:),Avv(i,:)] =  weak_form(prob,prob.trial,test_fun);
            end
        end

        function [L,grad] = loss_fun(prob,param)
            [Auv,Fv,Avv] = prob.eval(param);
            if prob.normalize_loss
                L = mean(abs(Auv-Fv).^2./Avv,'all');
            else
                L = mean(abs(Auv-Fv).^2,'all');
            end
            if nargout > 1
                grad = dlgradient(L,prob.trial.param,'AllowComplex',false);
            end
        end

        function [L,grad] = loss(prob)
            if nargout > 1
                [L,grad] = dlfeval(@prob.loss_fun,prob.trial.param);
            else
                L = prob.loss_fun(prob.trial.param);
            end
        end

        function E = error(prob)
            D = prob.domain;
            N_nodes = 10*prob.quad_nodes;
            [x,w] = prob.quad_rule(N_nodes,D(1),D(2));

            try
                [u,du,d2u] = prob.solution(x);
                [uh,duh,d2uh] = prob.trial.eval(x);
                N_out = 3;
            catch
                try
                    [u,du] = prob.solution(x);
                    [uh,duh] = prob.trial.eval(x);
                    N_out = 2;
                catch
                    u = prob.solution(x);
                    uh = prob.trial.eval(x);
                    N_out = 1;
                end
            end
            
            E.L2 = sqrt(dot(abs(uh - u).^2,w));
            if N_out >= 2
                E.H1 = sqrt(E.L2^2 + dot(abs(duh - du).^2,w));
            end
            if N_out >= 3
                E.H2 = sqrt(E.H1^2 + dot(abs(d2uh - d2u).^2,w));
            end
            if not(all(u == 0)) ~= 0
                u_L2 = sqrt(dot(abs(u).^2,w));
                E.L2 = E.L2/u_L2;
                if N_out >= 2
                    u_H1 = sqrt(u_L2^2 + dot(abs(du).^2,w));
                    E.H1 = E.H1/u_H1;
                end
                if N_out >= 3
                    u_H2 = sqrt(u_H1^2 + dot(abs(d2u).^2,w));
                    E.H2 = E.H2/u_H2;
                end
            end
            E.u = u; E.uh = uh; E.x = x;
        end

        function plot(prob)
            E = prob.error;
            figure('Name',[prob.name,'_solution'])
            if prob.iscomplex
                subplot(1,2,1)
            end
            plot(E.x,real(E.uh),"-",LineWidth=2);
            xlim(prob.domain)
            hold on
            plot(E.x,real(E.u), "--",LineWidth=2)
            legend("predicted","true")
            format = '%.2e';
            title_string = "Error L2: " + num2str(E.L2,format);
            if isfield(E,'H1')
                title_string = title_string + " H1: " + num2str(E.H1,format);
            end
            if isfield(E,'H2')
                title_string = title_string + " H2: " + num2str(E.H2,format);
            end
            if prob.iscomplex
                sgtitle(title_string)
                title('real')
            else
                title(title_string);
            end
            if prob.iscomplex
                subplot(1,2,2)
                plot(E.x,imag(E.uh),"-",LineWidth=2);
                xlim(prob.domain)
                hold on
                plot(E.x,imag(E.u), "--",LineWidth=2)
                hold off
                legend("predicted","true")
                title("imaginary")
            end
        end

    end
end