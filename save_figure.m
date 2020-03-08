function save_figure ( name )

set(gcf, 'Position', [100, 100, 600, 300])
print(name, '-depsc')
% saveas(name, 'fig')
% saveas(name, 'png')

end