function pset_export(fname)
%Exports the current figure in a consistent manner to a folder named
%'Resources' in the current location in png and fig formats
    p=get(gcf,'Position');
    set(gcf,'Position',[p(1) p(2) 800 800]);
    savefig(['Resources/' fname]);
    saveas(gcf,['Resources/' fname '.png']);
    set(gcf,'Position', p);
end