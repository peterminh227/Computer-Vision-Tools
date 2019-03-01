%%%% Supportive function % not using built-in-func
%% GET FEATURES
function [image_features] = ...
    get_bags_SIFT(image_paths, steps, vocab)
    fprintf('Starting get features... \n');
    K = size(vocab,2); % num of clusters ..
    N = size(image_paths,1);
    image_features = zeros(N,K); % Nx100
    for i=1:N
        img = imread(image_paths{i});
        if (numel(size(img))>=3)
            img_gray = double(rgb2gray(img))/255.0;
        else
            img_gray = double(img);
        end
            
        % Normalization 
        img_gray=img_gray-min(img_gray(:));
        img_gray=img_gray/max(img_gray(:));
        % notice that dense sift is used
        [~, img_sift_features] = ...
            vl_dsift(single(img_gray), 'fast', 'Step', steps);
        % Single the sift feats for the sake of distance measurement
        img_sift_features = single(img_sift_features);
        img_histogram = zeros(1, K); % 1 x 100
        Q = size(img_sift_features, 2); %
        distances = zeros(K, 1);
        for j=1:Q
            % for each local feature, get the distances to the centroids
            for k=1:K
                distances(k) = vl_alldist2(img_sift_features(:,j), vocab(:,k), 'l1');
            end
            % then get the index of the nearest centroid (i.e. nearest distance)
            [~, index] = ismember(min(distances), distances);
            % and increment it to the histogram
            img_histogram(index) = img_histogram(index) + 1;        
        end
        % normalize the histogram
        img_histogram = img_histogram/norm(img_histogram);    
        % add it to the features matrix
        image_features(i,:) = img_histogram;
    end
end