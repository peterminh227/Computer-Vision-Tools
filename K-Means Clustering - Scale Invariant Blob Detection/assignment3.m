%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   VU Computer Vision (2018W)
%   Exercise Part - Assignments I
%
%   Group 13-15 03
%   Pintaric Thomas, Vu Minh Nhat, Lassnig Jakob
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
close all;
clear all;

imageName = 'test01.jpg';
%imageName = 'butterfly.jpg';
radii = [1:1:20]; % <-- enter radius range here (units: pixels)


display(['Processing "',imageName,'"']);
I = double(imread(['images/',imageName]));
assert(size(I,3) == 1);

circles = [];
Info = [];
threshold = 50;

LoG = [];
LoG_local_max = [];
LoG_is_local_max = [];

for i=1:length(radii)
    r = radii(i); % radius
    sigma = r / sqrt(2); % sigma
    filterSize = 2*ceil(3*sigma)+1; % filter size
    filter = sigma^2 * fspecial('log', filterSize, sigma); % LoG
    LoG(:,:,i) = imfilter(I, filter, 'same', 'replicate');
    LoG_local_max(:,:,i) = ordfilt2(LoG(:,:,i),9,ones(3,3));

    % Find locally maximal filter response in the pixel's 3x3 neighborhood
    LoG_is_local_max(:,:,i) = (LoG(:,:,i) == LoG_local_max(:,:,i));
    
    Info{i}.r = r;
    Info{i}.sigma = sigma;
    Info{i}.filterSize = filterSize;
    Info{i}.filter = filter;
end

% 3D non-max suppression
for i=1:length(radii)
    j = [max(i-1, 1):min(i+1, length(radii))]; % slice indices
    
    % Find locally maximal filter response in the pixel's 3x3x3 neighborhood
    % (NOTE: LoG_is_local_max already contains the single-slice 3x3 local maximum.)
    LoG_is_local_max(:,:,i) = LoG_is_local_max(:,:,i) & ...
        (LoG_local_max(:,:,i) == max(LoG_local_max(:,:,j),[],3));

    [Y,X] = ind2sub(size(LoG_is_local_max),find(LoG_is_local_max(:,:,i) & (LoG(:,:,i) > threshold)));
    circles = vertcat(circles, [X Y repmat(radii(i),length(X),1)]);
    
end

show_all_circles(uint8(I), circles(:,1), circles(:,2), circles(:,3));