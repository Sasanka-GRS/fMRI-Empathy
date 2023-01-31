function y = dataNorm(x)
    l = size(x);
    y = x;
    for k = 1:l(2)
        x1 = x(:,k);
        mean = sum(x1)/l(1);
        %{
        v = var(x1); % Use inbuilt
        Y = (x1-mean)/sqrt(v);
        %}
        Y = x1-mean;
        y(:,k) = Y;
    end
end