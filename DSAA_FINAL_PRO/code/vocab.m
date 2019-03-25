

function vocab = vocab( image_paths )
% The inputs are images, a N x 1 cell array of image paths and the size of 
% the vocabulary.
    
    % Sample random permutation of images
    sample_size = length(image_paths);
    perm = randperm(length(image_paths), sample_size);
    
    for i = 1:sample_size
        image_index = perm(i);
        image = single(imread(image_paths{image_index}));
    
        descriptors =image_descriptors(image);
        %size(descriptors)
        
        num_descriptors = size(descriptors, 2);
        if ~exist('descriptors', 'var')
            total_descriptors = zeros(size(descriptors, 1), num_descriptors * sample_size);
        end
        
        start_index = (i - 1)*num_descriptors + 1;
        end_index = i*num_descriptors;
        total_descriptors(:, start_index:end_index) = descriptors;
        
        current_value=i;
        total_number= sample_size;
         name = 'Creating Pyramid Vocab';
        percent = round(current_value/total_number * 100.0);

        print_every_percent = 0.05;
        increment = total_number * print_every_percent;

        if (mod(current_value, increment) == 0)

            progress = sprintf('%s: %i%% (%i / %i)', name, percent, current_value, total_number);
            disp(progress)
        end
        
       
    end

    num_clusters = 200;
    
    fprintf('Creating KMeans clusters (%i clusters)', num_clusters);
    % Cluster results
    % 
    % centers = 128 x num_clusters
    % assignments = 1 x num_features_found
    [centers, ~] = vl_kmeans(single(total_descriptors), num_clusters);
   % plot(centers)
    
    % vocab = vocab_size x 128
    vocab = centers';
end