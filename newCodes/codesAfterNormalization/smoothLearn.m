function [Graphs_W,Graphs_top,Graphs_Layout] = smoothLearn(XData,N,Num,alpha,beta,Layout,iter)

% alpha increases smoothness of learnt data
% beta increases sparsity of learnt graph
L = size(XData);
L = L(2);

Graphs_W = zeros(N,N,L/Num);
Graphs_top = zeros(N,N,L/Num);
Graphs_Layout = zeros(N,2,L/Num);

for k = 1:(L/Num)

    X = XData(:,(k-1)*Num+1:k*Num);
    L_est = zeros(N,N);
    Z_est = X;

    for kk = 1:iter

        % Problem is - argmin ||X-Z||_F^2 + alpha*Tr(Z'Lz) + beta*|L|_F^2
        yalmip('clear')
        Z_hat = sdpvar(N,Num);
        L_hat = sdpvar(N,N);
        
        % ----------------- optimizing over L -----------------------

        constraints = [(L_hat*ones(N,1))==zeros(N,1),sum(diag(L_hat))==N];
        for i=1:N
            for j=1:N
                if(i==j)
                    %constraints = [constraints,L_hat(i,j)>=0];
                    continue;
                else
                    constraints = [constraints,L_hat(i,j)<=0];
                end
            end
        end

        for i=1:N
            for j=i:N
                if(i~=j)
                    constraints = [constraints,L_hat(i,j)==L_hat(j,i)];
                end
            end
        end
        
        % Problem is - argmin alpha*Tr(Z'Lz) + beta*||L||_F^2
        objective = alpha*sum(diag(Z_est'*L_hat*Z_est)) + beta*norm(L_hat,'fro')^2;
        options = sdpsettings('solver','mosek');

        optimize(constraints,objective,options);
        L_est = value(L_hat);

        % ------------------ optimizing over Z ------------------------
        
        % Problem is - argmin ||X-Z||_F^2 + alpha*Tr(Z'Lz)
        objective = norm(X-Z_hat,'fro')^2 + alpha*sum(diag(Z_hat'*L_est*Z_hat));
        options = sdpsettings('solver','mosek');

        optimize(constraints,objective,options);
        Z_est = value(Z_hat);

    end

    D_hat = diag(L_est);
    W = diag(D_hat)-L_est;

    A = W;
    [W,top] = thres1(A,N,3);
    W = normAdj(W);

    Graphs_W(:,:,k) = W;
    Graphs_Layout(:,:,k) = Layout;
    Graphs_top(:,:,k) = top;

end

end