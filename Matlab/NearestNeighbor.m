function accuracy = NearestNeighbor(distmat,labels)

test_labels = [];
predicted_labels = [];
counter = 0;

for i = 1:length(labels)
    d_temp = distmat(i,:);
    l_temp = labels;
    d_temp(i) = [];
    l_temp(i) = [];
    
    test_labels = [test_labels;labels(i)];
    [mn,idx] = min(d_temp);
    predicted_labels = [predicted_labels;l_temp(idx)];
    if labels(i)==l_temp(idx)
        counter = counter+1;
    end
end
accuracy = counter*100/length(labels);