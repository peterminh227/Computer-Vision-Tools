function training = BuildKNN(image_paths, steps, vocab)
    fprintf('Start building database training/test image... \n');
    K = size(vocab,2); % num of clusters ..
    N = size(image_paths,1);
    knn_class = fitcknn(vocab', [1:K]');
    training = [];
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
        [~, img_sift_features] = ...
            vl_dsift(single(img_gray), 'fast', 'Step', steps);
        vocab_labels = predict(knn_class, single(img_sift_features'));
        img_histogram = histcounts(vocab_labels, K);
        img_histogram = img_histogram/norm(img_histogram);
        training = [training;img_histogram];
    end
end