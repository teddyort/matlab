function pset_export(fname)
%Exports the current figure in a consistent manner to a folder named
%'Resources' in the current location in png and fig formats
    fs_bak = get(gca,'fontsize');
    f = gcf;
    pos_bak = f.Position;
    f.Position(end)=f.Position(end-1);
    set(gca,'fontsize',18)
    ppi=get(0,'ScreenPixelsPerInch');
    f.PaperUnits='inches';
    f.PaperSize = f.Position(3:4)/ppi;
    f.PaperPosition = [0 0 f.Position(3:4)/ppi];
    if exist([cd '\Resources'],'dir')==7
        folder = 'Resources';
    else
        folder = uigetdir;
    end
    savefig([folder '\' fname]);
    print(gcf,[folder '\' fname '.png'],'-dpng', '-r300');
    f.Position = pos_bak;
    set(gca, 'FontSize', fs_bak);
end