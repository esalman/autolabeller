function mci_plotcolorbar(F, IMinfo, ind, cm)

%% plotting colorbar
ax = axes('Parent', F, 'position', IMinfo.cbarpos{ind}, 'units', 'normalized', 'color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);
axis(ax, 'off');
CBAR = colorbar('peer', ax);
set(CBAR, 'units', 'normalized');
set(CBAR, 'position', IMinfo.cbarpos{ind})
% set(CBAR, 'YLim', [1, length(cm)/2]);
set(CBAR, 'YLim', [0 .5]);
set(CBAR, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);

if IMinfo.minval == -(IMinfo.maxval)
    set(CBAR, 'YTick', [0 .25 .5]);
    ticklabel{1} = sprintf('%0.1f', IMinfo.minval);
    ticklabel{2} = '0';
    ticklabel{3} = sprintf('%0.1f', IMinfo.maxval);
else
    set(CBAR, 'YTick', [0 .5]);
    ticklabel{1} = sprintf('%0.1f', IMinfo.minval);
    ticklabel{2} = sprintf('%0.1f', IMinfo.maxval);
end

set(CBAR, 'YTickLabel', ticklabel, 'FontSize', 5, 'Color', [0 0 0]);
set(get(CBAR, 'YLabel'), 'units', 'normalized')
set(get(CBAR, 'YLabel'), 'String', IMinfo.cbarlabel, 'FontSize', 6, 'Color', [0 0 0]);
set(get(CBAR, 'YLabel'), 'position', [1.8000  0.5 0])
drawnow;