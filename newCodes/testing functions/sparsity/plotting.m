function plotting(Layout,W,top,node)

N = size(Layout);
N = N(1);

scatter(Layout(:,1),Layout(:,2),80,'o','filled'); % Plot nodes
for i = 1:N
    %scatter(Layout(i,1),Layout(i,2),20,'o','filled');
    text(Layout(i,1)+0.1,Layout(i,2)+0.1,num2str(node(i)),'FontSize',25);
end
hold on

for i=1:N
    for j=1:N
        if top(i,j)~=0
            x=[Layout(i,1),Layout(j,1)];
            y=[Layout(i,2),Layout(j,2)]';
            plot(x,y,'r-',LineWidth=1.5);
        else
            if W(i,j)~=0
                x=[Layout(i,1),Layout(j,1)];
                y=[Layout(i,2),Layout(j,2)]';
                plot(x,y,'black-');
            end
        end
    end
end

hold off

set(gca,'XColor', 'none','YColor','none')

end