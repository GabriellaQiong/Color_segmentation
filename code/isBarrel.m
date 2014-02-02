function [flag, bw, params] = isBarrel(imBin)
% ISBARREL decide whether the current binary area is a barrel
% The stroke method referred from stackflow
bw  = bwareaopen(imBin, 10);
se  = strel('disk',5);
se2 = strel('disk',2);
bw  = imclose(bw,se);
bw  = imopen(bw,se2);
bw  = bwareaopen(bw,100);
bw  = imfill(bw,'holes');

% Shape statistics
[B, L]    = bwboundaries(bw,'noholes');
stats     = regionprops(L,'Centroid','Area','BoundingBox','Perimeter','Orientation');
params    = struct;
blobNum   = length(B);
area      = zeros(blobNum, 1);
center    = zeros(blobNum, 2);
bound     = zeros(blobNum, 4);
theta     = zeros(blobNum, 1);
ratioWH   = zeros(blobNum, 1);
box       = zeros(blobNum, 1);
ratioBox  = zeros(blobNum, 1);

for i = 1 : blobNum
    area(i)      = stats(i).Area;
    center(i, :) = stats(i).Centroid;
    bound(i, :)  = stats(i).BoundingBox;
    theta(i)     = stats(i).Orientation;
    ratioWH(i)   = max(bound(i, 3),bound(i, 4))/min(bound(i, 3),bound(i, 4));
    box(i)       = bound(i, 3)*bound(i, 4);
    ratioBox(i)  = area(i)/box(i);
end

[~, idx] = sort(ratioBox, 'descend');
for i = 1 : blobNum
    if (ratioBox(idx(i)) > 0.5 && ratioWH(idx(i)) > 1 && ratioWH(idx(i)) < 2.0)
        flag          = true;
        params.center = center((idx(i)), :);
        params.bound  = bound((idx(i)), :);
        params.theta  = theta((idx(i)));
        break;
    else
        flag   = false;
    end
end

end