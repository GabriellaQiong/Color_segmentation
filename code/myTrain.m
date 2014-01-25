% MYTRAIN for Project 1 Color Segmentation, ESE 650
% Written by Qiong Wang at University of Pennsylvania
% 01/24/2014

%% Initialize and load data
imgNum = length(distrain);
dCalib = zeros(imgNum, 1);
imgs   = cell(imgNum, 1);

for i = 1 : imgNum
    imgs{i}   = imread(fullfile(trainDir, dirtrain(i).name));
    dCalib(i) = dirtrain(i).name(1);
    
end

%% Set up color space
