clc
close all
clear
addpath('../vlfeat-0.9.21/toolbox')
vl_setup
%%%% PARAMETERS %%%%
% index of test image to use (1-4)
image1_nr = 1; 
image2_nr = 2;
scene = 'campus';
type = 'jpg';
%%%%%%%%%%%%%%%%%%%%
path = sprintf('data/%s%01d.%s',scene, image1_nr, type);
test_im1 = imread(path);
test_im1_gray = double(rgb2gray(test_im1))/255.0 ;
path = sprintf('data/%s%01d.%s',scene, image2_nr, type);
test_im2 = imread(path);
% rotate
test_im2 = imrotate(test_im2,20); % rotate 20 degree
test_im2 = imresize(test_im2, 0.6);

%
test_im2_gray = double(rgb2gray(test_im2))/255.0 ;
% normalize intensities to range [0, 1]
test_im1_gray=test_im1_gray-min(test_im1_gray(:));
test_im1_gray=test_im1_gray/max(test_im1_gray(:));
test_im2_gray=test_im2_gray-min(test_im2_gray(:));
test_im2_gray=test_im2_gray/max(test_im2_gray(:));

fprintf('Computing frames and descriptors.\n') ;
[frames1,descr1] = vl_sift(single(test_im1_gray));
[frames2,descr2] = vl_sift(single(test_im2_gray));
% plot calculated SIFT descriptors
figure(1) ; clf ;
subplot(1,2,1) ; imagesc(test_im1) ; colormap gray ;
hold on ;
h=vl_plotframe(frames1) ; set(h,'LineWidth',2,'Color','g') ;
subplot(1,2,2) ; imagesc(test_im2) ; colormap gray ;
hold on ;
h=vl_plotframe(frames2) ; set(h,'LineWidth',2,'Color','g') ;
hold off

fprintf('Computing matches.\n') ;
% By passing to integers we greatly enhance the matching speed (we use
% the scale factor 512 as Lowe, but it could be even larger without
% overflow)
descr1=uint8(512*descr1);
descr2=uint8(512*descr2);
matches=vl_ubcmatch(descr1, descr2, 1.5);
% plot successful matches between images
figure(2); clf;
plot_matches(test_im1_gray,test_im2_gray,frames1, frames2, matches, 'points', 'random');
% RANSAC algorithm
N = 1000;
best_inliers_count = 0;
threshold = 5;
for i = 1:N
    count = 0;
    inliers = [];
    % take 4 matches
    points = matches(:, randperm(size(matches,2),4));
    img1_location = frames1(1:2,points(1,:));
    img2_location = frames2(1:2,points(2,:));
    %try
    if (~is_nonrobust(img1_location)) && (~is_nonrobust(img2_location))
        tform = fitgeotrans(img2_location',img1_location','projective');
        [X,Y] =  transformPointsForward(tform,frames2(1,:),frames2(2,:));
        % count inliers
        for j = 1:size(matches,2)
            d = sqrt((frames1(1,matches(1,j)) - X(1,matches(2,j)))^2 + ...
                (frames1(2,matches(1,j)) - Y(1,matches(2,j)))^2);
            if d < threshold
                count = count + 1;
                inliers = [inliers matches(:,j)];
            end
        end

        if (count > best_inliers_count)
            best_inliers_count = count;
            best_inliers = inliers;
        end
    end 
end
% Plot after remove the outliers:
figure(10); clf;

plot_matches(test_im1_gray,test_im2_gray,frames1, ...
    frames2, best_inliers, 'points', 'random');
% re-calculate best_tform
img1_location = frames1(1:2,best_inliers(1,:));
img2_location = frames2(1:2,best_inliers(2,:));
best_tform = fitgeotrans(img2_location',img1_location','projective');
inv_best_tform = fitgeotrans(img1_location',img2_location','projective');
% 
im_rotated = imwarp(test_im2,best_tform,'OutputView',imref2d(size(test_im1)));
inv_im_rotated = imwarp(test_im1,inv_best_tform,'OutputView',imref2d(size(test_im2)));
% test
figure(20)
im_test = imwarp(test_im2,best_tform,'OutputView',imref2d(size(test_im1)));
imshowpair(test_im1,im_test)

function r = is_nonrobust(X) 
     % r = 1 if points are co-linear, 0 otherwise
     p1 = X(:,1); p2 = X(:,2); p3 = X(:,3); p4 = X(:,4);
     r1 = norm(cross2D(p2-p1,p3-p1)) < eps;
     r2 = norm(cross2D(p2-p1,p4-p1)) < eps;
     r3 = norm(cross2D(p3-p2,p4-p2)) < eps;
     r = (r1 | r2 | r3 );
end
function z = cross2D(a,b)
    z = a(1)*b(2) - b(1)*a(2);
end

