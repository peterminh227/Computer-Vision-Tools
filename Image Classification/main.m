
%%% Cleaning..
clc;
clear
close all;
%%%%% SIFT  %%%%
addpath('../vlfeat-0.9.21/toolbox')
vl_setup
%%%%% Define path and categories %%%
path = './';
num_train_per_categories = 100;
categories = {'bedroom', 'forest', 'kitchen', 'livingroom', 'mountain', ...
    'office', 'store', 'street'};
[train_image_paths, test_image_paths, train_labels, test_labels] = ...
    get_path(path, categories, num_train_per_categories);

% BAG of SIFT method ...
%%%%% KNN parameter  %%%%
neighbors_count = 5;
%%%%% vocab parameter  %%%%
sift_vocab_size = 50;
sift_steps = 5;
sift_vocab = ...
    build_sift_vocabulary(train_image_paths, sift_vocab_size, sift_steps);
use_builtin_func = 1;
if use_builtin_func 
    train_image_features = BuildKNN(train_image_paths, sift_steps, sift_vocab);
    [conf_matrix, predicted_labels] = ...
    ClassifyImages(test_image_paths, test_labels, train_image_features, ...
        train_labels, sift_vocab, categories, neighbors_count, sift_steps);
    [~,my_predicted_labels] =  ...
        ClassifyImages(my_image_paths, my_image_labels, train_image_features, ...
        train_labels, sift_vocab, categories, neighbors_count, sift_steps);
else
    train_image_features = ...
    get_bags_SIFT(train_image_paths,sift_steps, sift_vocab); 
    fprintf('Finish getting features from train image... \n');
    %%% CLASIFICATION 
    fprintf('Start classifying process ...\n');
    fprintf('1. Get features from test image ...\n');
    test_image_features = ...
        get_bags_SIFT(test_image_paths,sift_steps, sift_vocab); 
    fprintf('2. Perform kNN search ...\n');
    [prediction,conf_matrix] = k_Nearest_Neighbor(train_image_features, ...
        train_labels, test_image_features, categories, neighbors_count);
end

