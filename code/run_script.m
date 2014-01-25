% Run Script for Project 1 Color Segmentation, ESE 650
% Written by Qiong Wang at University of Pennsylvania
% 01/23/2014

%% Initialize
trainFlag = true;
testFlag  = false;

%% Path
scriptDir = fileparts(mfilename('fullpath'));
testDir   = fullfile(scriptDir, '../data/test/');
trainDir  = fullfile(scriptDir, '../data/train/');
outputDir = fullfile(scriptDir, '../results');
if ~exist(outputDir, 'dir')
    mkdir(outputDir); 
    cd(outputDir); mkdir('test'); mkdir('train'); cd(scriptDir);
end
addpath(genpath('code'));
dirstruct = dir([testDir,  '*.png']);
dirtrain  = dir([trainDir, '*.png']);

%% Train
if trainFlag
    myTrain;
else
    load(fullfile(trainDir, 'train_results.mat'));
end

%% Test
if ~testFlag
    return
end

for i = 1:length(dirstruct),
    % Current test image
    im = imread(fullfile(dataDir, dirstruct(i).name));
    % My algorithm
    [x, y, d] = myTest(im);
    % Display results:
    hf = figure(1);
    image(im);
    hold on;
    plot(x, y, 'g+');
    title(sprintf('Barrel distance: %.1f m', d));
    % You may also want to plot and display other
    % diagnostic information such as the outlines
    % of connected regions, etc.
    hold off;
    pause;
end