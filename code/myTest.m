function [x, y, d, bound, theta] = myTest(im, cluster, fMeanEst)
% MYTEST(IM) color segements an image, outputs the centroid and the distance.
%
% Written by Qiong Wang at University of Pennsylvania
% 01/29/2014

labels  = 7;
lthresh = 80;
verbose = false;
C       = makecform('srgb2lab');
lab     = applycform(im, C);
imVec   = reshape(lab, [], 3);

while(true)
    try
        [idx, centroids] = kmeans(double(imVec), labels);
        labels = labels + 1;
        if labels >= 10
            if mean(imVec(:, 1)) > lthresh
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
        [idx, centroids] = kmeans(double(imVec), labels);
        if mean(imVec(:, 1)) > lthresh
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

x     = params.center(1);
y     = params.center(2);
d     = fMeanEst / params.bound(3);
bound = params.bound;
theta = params.theta;

if ~verbose
    return
end
clf;
subplot(1, 2, 1);
imshow(imresize(im, 4));
subplot(1, 2, 2);
imshow(bw, []);
hold on; plot(params.center(1), params.center(2), 'g+');
plotBound(bound);
pause(0.1);

end