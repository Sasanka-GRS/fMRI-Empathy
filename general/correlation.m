clear

N = 15; % Number of Nodes
M = 100; % Number of realizations
gamma = 1; % Sparsity Parameter
lambda = 1; % Optimization Parameter

% ------------------------------ part (a) --------------------------------

Layout = [14,40;28,-36;46,-56;60,-28;34,14;0,2;32,58;48,-44;42,14;54,20;18,68;-2,64;-48,4;60,4;-50,38];

data = load("new_data\303_data.mat");
X = data.Y;
XData = X';
XData = XData(:,2:257);


% --------------------------- part (b) -----------------------------------

% We have to solve -> min ||y_j - \sum_{n-{j}}\beta_{n}Y_{n}||_{2}^{2} +
% lambda*||beta||_{1}

beta_final = [];



for j=1:N
    
    beta_hat = sdpvar(N-1,1);
    
    X = XData;
    
    yj = X(j,:);
    X(j,:) = [];
    Yn = X;
    
    constraints = [beta_hat>=0];
    objective = norm((yj'-Yn'*beta_hat),2) + lambda*norm(beta_hat,1);
    options = sdpsettings('solver','mosek');
    
    optimize(constraints,objective,options);
    beta_est = value(beta_hat);
    beta_est = beta_est';
    
    beta_final = [beta_final;[beta_est(1:N-1 < j),0,beta_est(1:N-1 >= j)]];
    
end

W = zeros(N,N);

for i=1:N
    for j=1:N
        W(i,j) = sqrt(beta_final(i,j)*beta_final(j,i));
    end
end

A = W;
A(W >= gamma) = 1;
A(W < gamma) = 0;

% ------------------------- part (c and d) ------------------------------------

% We have to solve -> min ||y_j - \sum_{n-{j}}\beta_{n}Y_{n}||_{2}^{2} +
% lambda*||beta||_{1}

% THE OPTIMAL VALUES OF Gamma and Lambda ARE AS GIVEN BELOW

gamma = 0.13; % Sparsity Parameter
lambda = 2.5; % Optimization Parameter

Graphs = [];

L = size(XData);
L = L(2);
Num = 16;

for k = 1:(L/Num)

    beta_final = [];

    for j=1:N
    
        beta_hat = sdpvar(N-1,1);
    
        X = XData(:,(k-1)*Num+1:k*Num);
    
        yj = X(j,:);
        X(j,:) = [];
        Yn = X;
    
        constraints = [beta_hat>=0];
        objective = norm((yj'-Yn'*beta_hat),2) + lambda*norm(beta_hat,1);
        options = sdpsettings('solver','mosek');
    
        optimize(constraints,objective,options);
        beta_est = value(beta_hat);
        beta_est = beta_est';
    
        beta_final = [beta_final;[beta_est(1:N-1 < j),0,beta_est(1:N-1 >= j)]];
    
    end

    W = zeros(N,N);

    for i=1:N
        for j=1:N
            W(i,j) = sqrt(beta_final(i,j)*beta_final(j,i));
        end
    end

    A = W;
    A(W >= gamma) = 1;
    A(W < gamma) = 0;

    G1 = grasp_struct; % Defining the struct variable
    G1.A = A; % Assigning Adjacency
    G1.layout = Layout; % Assigning coordinates for each node

    Graphs = [Graphs,G1];

end

figure()

for k = 1:(L/Num)

    grasp_show_graph(gca,Graphs(k),'node_text','ID','node_text_fontsize',10,'node_text_shift',4);
    xlim([-52,62]);
    ylim([-58,70]);
    message = ['Graph at Time ',int2str((k-1)*2*Num+1),'s - ',int2str(k*2*Num), 's'];
    sgtitle(message);
    %colorbar
    pause(1);

end
%{
subplot(1,2,2);
grasp_show_graph(gca,G);
xlim([-1,11]);
ylim([-1,11]);
title('Original Graph');
sgtitle('Optimal Solution');
%}
%{
beta_final = [];

    for j=1:N
    
        beta_hat = sdpvar(N-1,1);
    
        X = XData;
    
        yj = X(j,:);
        X(j,:) = [];
        Yn = X;
    
        constraints = [beta_hat>=0];
        objective = norm((yj'-Yn'*beta_hat),2) + lambda*norm(beta_hat,1);
        options = sdpsettings('solver','mosek');
    
        optimize(constraints,objective,options);
        beta_est = value(beta_hat);
        beta_est = beta_est';
    
        beta_final = [beta_final;[beta_est(1:N-1 < j),0,beta_est(1:N-1 >= j)]];
    
    end

    W = zeros(N,N);

    for i=1:N
        for j=1:N
            W(i,j) = sqrt(beta_final(i,j)*beta_final(j,i));
        end
    end

    A = W;
    A(W >= gamma) = 1;
    A(W < gamma) = 0;

    G1 = grasp_struct; % Defining the struct variable
    G1.A = A; % Assigning Adjacency
    G1.layout = Layout; % Assigning coordinates for each node
    figure();
    grasp_show_graph(gca,G1);
    xlim([-52,62]);
    ylim([-58,70]);
    sgtitle('Estimated Graph');
    colorbar
%}