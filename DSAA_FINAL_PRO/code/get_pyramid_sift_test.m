function image_feats = get_pyramid_sift_test(image_paths)

    % vocab = vocab_size x 128
    load('pyramid_vocab.mat')

    % size of histogram or num_features
    d = 400;
    n = length(image_paths);
    
    image_feats = ones(n, d);
    
    % build kdtree for distance querying
    kdtree = vl_kdtreebuild(pyramid_vocab', 'NumTrees', 1);
    
    for i = 1:n
        
        image = single(imread(image_paths{i}));

        descriptors = image_descriptors(image);
        
        [min_indices, ~] = vl_kdtreequery(kdtree, pyramid_vocab', single(descriptors));
        
        % Build histogram from min_indices
        count_histogram = hist(single(min_indices), d);
        
        image_feats(i, :) = count_histogram ./ size(descriptors, 2);
        
         drawnow;
        plot(count_histogram);
        pause(0.05);
        
        current_value=i;
        total_number=n;
        name =  'Getting Pyramid Sifts';
            percent = round(current_value/total_number * 100.0);

            print_every_percent = 0.05;
            increment = total_number * print_every_percent;

            if (mod(current_value, increment) == 0)

                progress = sprintf('%s: %i%% (%i / %i)', name, percent, current_value, total_number);
                disp(progress)
            end
    end

end