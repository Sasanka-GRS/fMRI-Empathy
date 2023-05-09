function Graphs_W = smoothWindowLearnWeighted(XData,Num,alpha,beta,iter,N,cutoffA,cutoffTop)

% alpha increases smoothness of learnt data
% beta increases sparsity of learnt graph
L = size(XData);
L = L(2);

Graphs_W = [];
Graphs_top = [];

start = 1;
%last = Num;

parfor last = Num:L

    %% Start with Z_est as original data

    X = XData(:,last-Num+1:last);
    L_est = zeros(N,N);
    Z_est = X;

    W = smoothWindowInside(iter,L_est,Z_est,alpha,beta,N,Num,X);
    
    Graphs_W = [Graphs_W,W];

end

Graphs_W = reshape(Graphs_W,N,N,L-Num+1);

end