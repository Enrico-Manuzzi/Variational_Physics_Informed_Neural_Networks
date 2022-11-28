function save_all_figures(suffix)
if nargin == 0
    suffix = '';
end
rootpath = fileparts(which('main.m'));
FolderName = [rootpath,'/outputs/images'];   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = get(FigHandle, 'Name');
    saveas(FigHandle, fullfile(FolderName, [FigName,suffix,'.png']));
end
