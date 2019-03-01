%% BUILD VOCAB
function sift_vocab = ...
    build_sift_vocabulary(image_paths, vocab_size, steps)
    fprintf('Start building vocabulary... \n');
    sift_features =[];
    N = length(image_paths);
    % binSize = 4;
    for i = 1:N
        img = imread(image_paths{i});
        if (numel(size(img))>=3)
            img_gray = double(rgb2gray(img))/255.0;
        else
            img_gray = double(img);
        end
         
        % Normalization 
        img_gray=img_gray-min(img_gray(:));
        img_gray=img_gray/max(img_gray(:));
        [~, img_sift_features] = ...
            vl_dsift(single(img_gray), ...
            'fast', 'Step', steps);
        % take 100 features randomly.
        img_sift_features = ...
            img_sift_features(:,randsample(size(img_sift_features,2),100));
        sift_features = [sift_features img_sift_features];
    end
    % K-mean process: 
    K = vocab_size;
    [sift_vocab, ~] = vl_kmeans...
    (single(sift_features), K, 'distance', 'l1', 'algorithm', 'elkan');
    % sift_vocab are the centers of clusters ... 
end