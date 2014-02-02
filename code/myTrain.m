% MYTRAIN for Project 1 Color Segmentation, ESE 650
% Written by Qiong Wang at University of Pennsylvania
% 01/29/2014

%% Initialize and load data
imgNum  = length(dirtrain);
lthresh = 80;
verbose = true;
C       = makecform('srgb2lab');
wTrained = zeros(imgNum, 1);

if ~exist(fullfile(trainDir, 'image.mat'), 'file')
    dCalib  = zeros(imgNum, 1);
    wCalib  = zeros(imgNum, 1);
    imgs    = cell(imgNum, 1);
    imMask  = cell(imgNum, 1);
    imVec   = cell(imgNum, 1);
    M       = [];
    
    for i = 1 : imgNum
        % Load Images
        imgs{i}   = imresize(imread(fullfile(trainDir, dirtrain(i).name)), 1/4);
        dCalib(i) = str(dirtrain(i).name(1));
        imMask{i} = roipoly(imgs{i});
        
        % Compute focal length
        [r, c]    = find(imMask{i});
        wCalib(i) = max(c) - min(c);
        
        % Transfer to Lab space
        lab      = applycform(imgs{i}, C);
        imVec{i} = reshape(lab, [], 3);
        M        = [M; imVec{i}(reshape(imMask{i}, [], 1), :)];
    end
    save(fullfile(trainDir, 'image.mat'), 'imgs', 'imMask', 'imVec', 'dCalib', 'wCalib', 'M');
else
    load(fullfile(trainDir, 'image.mat')); 
end

%% Build the train GMM model
% Find new clusters by GMM
gmmObj  = gmdistribution.fit(double(M), 2, 'replicate', 3, 'SharedCov', false);
[~, IX] = sort(gmmObj.mu(:, 1), 'descend');
cluster = gmmObj.mu(IX, :);

% Find the barrel red color cluster for each image
h = figure(100);
for i = 1 : imgNum
    fprintf('Processing image %d \n', i);
    labels = 4;
    while(true) 
        try
            [idx, centroids] = kmeans(double(imVec{i}), labels);
            labels = labels + 1;
            if labels >= 10
                if mean(imVec{i}(:, 1)) > lthresh
                    [~, centroid] = min(abs(bsxfun(@minus, centroids(:, 2), cluster(1, 2))));
                else
                    [~, centroid] = min(abs(bsxfun(@minus, centroids(:, 2), cluster(2, 2))));
                end
                imBin = reshape(idx == centroid, 300, 400);
                [flag, bw, params] = isBarrel(imBin);
                if flag
                    break;
                end
            end
        catch
            labels = labels - 1;
            [idx, centroids] = kmeans(double(imVec{i}), labels);
            if mean(imVec{i}(:, 1)) > lthresh
                [~, centroid] = min(abs(bsxfun(@minus, centroids(:, 2), cluster(1, 2))));
            else
                [~, centroid] = min(abs(bsxfun(@minus, centroids(:, 2), cluster(2, 2))));
            end
            imBin = reshape(idx == centroid, 300, 400);
            [flag, bw, params] = isBarrel(imBin);
            if flag
                break;
            end
        end
    end
    wTrained(i) = params.bound(3);
    if ~verbose
        continue;
    end
    clf;
    subplot(1, 2, 1);
    imshow(imresize(imgs{i}, 4));
    title('Original Image');
    subplot(1, 2, 2);
    imshow(bw, []);
    hold on; plot(params.center(1), params.center(2), 'g+');
    plotBound(params.bound);
    title('Detected Image');
    pause(0.1);
    print(gcf, '-djpeg','-r300',fullfile(outputDir, '/train', sprintf('train_%02d.jpg', i)));
end

%% Compute the focal length for depth computation
% Directly compute focal length
fMean    = mean(dCalib.* wCalib);

% Recompute the focal length
fMeanEst = regress(dCalib, 1./wTrained);


%% Save the train model
save(fullfile(trainDir, 'train_results.mat'), 'cluster', 'fMeanEst', 'wTrained');