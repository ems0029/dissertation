function [x,y] = plotnsided(n,colorStr,plotsize)
cmap = colororder;

switch upper(colorStr)
    case "T14"
        c = cmap(4,:);
    case "T13"
        c = cmap(3,:);
    case "A1"
        c = cmap(1,:);
    case "A2"
        c = cmap(2,:);
    otherwise
        c = cmap(5,:);
end

p = nsidedpoly(n);
cmb = nchoosek(1:n, 2);

x =[p.Vertices(cmb(:,1),1),p.Vertices(cmb(:,2),1)]';
y =[p.Vertices(cmb(:,1),2),p.Vertices(cmb(:,2),2)]';
xlim([-1 1])
ylim([-1 1])
xticks([])
yticks([])
axis square
hold on
plot(x,y,'Color',c*0.5)
scatter(p.Vertices(:,1),p.Vertices(:,2),'filled','MarkerEdgeColor','none','SizeData',50,'CData',c)

end