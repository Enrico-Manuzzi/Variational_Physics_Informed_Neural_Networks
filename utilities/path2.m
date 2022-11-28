function P = path2(folder)
rootpath = fileparts(which('main.m'));
P = [rootpath,'/outputs/',folder,'/'];
end