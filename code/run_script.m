% Run Script for Project 1 Color Segmentation, ESE 650
% Written by Qiong Wang at University of Pennsylvania
% 01/29/2014

%% Clear up
clear all;
clc;

%% Initialize
trainFlag = false;
testFlag  = true;

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

for i = 1 : length(dirstruct)
    % Current test image
    im = imresize(imread(fullfile(testDir, dirstruct(i).name)), 1/4);
    % My algorithm
    [x, y, d, bound, theta] = myTest(im, cluster, fMeanEst);
    % Display results:
    hf = figure(1);
    image(im);
    hold on;
    plot(x, y, 'g+');
    title(sprintf('Barrel distance: %.1f m', d));
    plotBound(bound, 'b');
    plotBound(bound, 'r', theta);
    axis off;
    hold off;
    pause(0.1);
    print(gcf, '-djpeg', '-r300', fullfile(outputDir, '/test', sprintf('test_%02d', i)));
end