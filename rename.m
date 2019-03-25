% Get all files in the current folder clear all;
clear all
close all

files = dir(fullfile('C:','Users','madhu','Desktop','data','train','TallBuilding','*.jpg'));

% Loop through each
fileNames = {files.name};

for id = 1:length(fileNames)
    fname{id} = fullfile('C:','Users','madhu','Desktop','data','train','TallBuilding',fileNames{id});
    I{id} = imread(fname{id});
    k = id+1414;
    imwrite(I{id},sprintf('%d.jpg',k));
end
