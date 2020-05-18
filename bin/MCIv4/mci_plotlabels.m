function mci_plotlabels(F, IMinfo)
%% plotting title
for ii = 1:size(IMinfo.titlepos,1)
    Tax = axes('Parent', F, 'position', [IMinfo.titlepos(ii,1) IMinfo.titlepos(ii,2), .1 .1], 'units', 'normalized', 'color', [1 1 1]);
    axis(Tax, 'off');
    str = strrep(IMinfo.datalabel, '_', ' ');
    str = strsplit(str, ';');
    PT = text(0,0, str, 'Parent', Tax, 'Color', [0 0 0], 'FontSize', 8);
end

