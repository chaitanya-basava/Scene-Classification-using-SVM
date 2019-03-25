Feature = 'spatial pyramid sift';

Classifier = 'support vector machine';
 
run('C:\Users\madhu\Downloads\vlfeat-0.9.20\toolbox\vl_setup')

data_path = 'C:\Users\madhu\Desktop\DSAA PROJECT\data_100';

categories = {'manmade','natural'};
    
num_train_per_cat = 100;

num_test_per_cat = 1;

%%%%%%%%%%%%%%%%%%%%  GETTING PATHS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('Getting paths and labels for all train and test data\n')
[train_image_paths,train_labels] = ...
    imgpaths(data_path, categories, num_train_per_cat);  

test_image_paths  = cell(num_test_per_cat*2, 1);
test_labels  = cell(num_test_per_cat*2, 1);
images = dir( fullfile(data_path, 'test', '*.jpg'));
test_image_paths{1} = fullfile(data_path, 'test', images(5).name);
test_image_paths{2} = fullfile(data_path, 'test', images(5).name);

test_labels{1} = categories{1};
test_labels{2} = categories{2};

%%%%%%%%%%%%%%%%%%  FEATURE : SPATIAL  PYRAMID  SIFT  %%%%%%%%%%%%%%

fprintf('Using spatial pyramid sift representation for images\n')

if ~exist('pyramid_vocab.mat', 'file')
       fprintf('No existing pyramid vocabulary found. Computing one from training images\n')
       pyramid_vocab = vocab(train_image_paths);
       save('pyramid_vocab.mat', 'pyramid_vocab');
end  


if ~exist('features.mat', 'file')
     fprintf('No existing descriptors found. Computing one from training images\n')
     train_image_feats = get_pyramid_sift(train_image_paths);
     save('features.mat','train_image_feats');
end
     test_image_feats  = get_pyramid_sift_test(test_image_paths);

%%%%%%%%%%%%%%%%%%  CLASSIFIER : SVM(support vector machine)  %%%%%%%%%%%%%%      
        
fprintf('Using support vector machine classifier to predict test set categories\n')
        load('features.mat');
        unique_labels = unique(train_labels);
        num_labels = size(unique_labels, 1);

        n = size(train_labels, 1);
        m = size(test_image_feats, 1);
        predicted_categories_mat = zeros(m, num_labels);

        % Create model
        for i = 1:num_labels
            label = unique_labels(i);
            one_vs_many = strcmp(label, train_labels) * 2 - 1;

            fprintf('Predicting Label %i/%i: %s\n', i, num_labels, char(label));

            [W, B] = vl_svmtrain(train_image_feats', one_vs_many, 0.00001);
            predicted = W' * test_image_feats' + B';
            predicted_categories_mat(:, i) = predicted';

        end

        [~, indices] = max(predicted_categories_mat, [], 2);
        predicted_categories = unique_labels(indices);
        
%%%%%%%%%%%%%%%%%%%% CREATING CONFUSION MATRIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Creating confusion matrix\n')

num_samples = 2; 

num_categories = length(categories);

confusion_matrix = zeros(num_categories, num_categories);
for i=1:length(predicted_categories)
    row = find(strcmp(test_labels{i}, categories));
    column = find(strcmp(predicted_categories{i}, categories));
    confusion_matrix(row, column) = confusion_matrix(row, column) + 1;
end
num_test_per_cat = length(test_labels) / num_categories;
confusion_matrix = confusion_matrix ./ num_test_per_cat;
result = imread(test_image_paths{1});
if(confusion_matrix(1)+confusion_matrix(2) > confusion_matrix(3) + confusion_matrix(4))
    fprintf('manmade\n')
    figure;
    imshow(result)
    title('MANMADE SCENE')
else
   fprintf('natural\n')
    figure;
    imshow(result)
    title('NATURAL SCENE')
end