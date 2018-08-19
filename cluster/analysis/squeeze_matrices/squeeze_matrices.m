
% result_dir = '';

subdirs = dir(result_dir);
for d = 3 : length(subdirs)
%     load([result_dir '/' subdirs(d).name '/matlab.mat'])
    load([subdirs(d).name '/matlab.mat'])
    Yc = cell(1,size(Y,3));
    for i = 1 : size(Y,3)
        Yc{i} = sparse(Y(:,:,i));
    end
    clear Y
    save([subdirs(d).name '/matlab_cmpr.mat'],'-v7.3')
end