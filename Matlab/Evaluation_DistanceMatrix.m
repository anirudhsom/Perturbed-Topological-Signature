
function [avgFirst_NN,avgFirst_Tier,avgSecond_Tier,avgE_Measure,avgDCG] = Evaluation_DistanceMatrix(D,GroundTruth)

% GroundTruth: numModels*numCategories, starting from index 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrixInput = D;

%Initialization
avgFirst_NN = 0;
first_NN = 0;
avgFirst_Tier = 0;
first_Tier = 0;
avgSecond_Tier = 0;
second_Tier = 0;
avgE_Measure = 0;
e_Measure = 0;
idealDCG = 0;
DCG = 0;
avgDCG = 0;
K1 = 0;
K2 = 0;

testCategoryList.categories(1).name(1) = 0;
testCategoryList.categories(1).numModels = 0;

testCategoryList.numCategories = 0;
testCategoryList.numTotalModels = 0;
testCategoryList.modelsNo(1) = 0;
testCategoryList.classNo(1) = 0;

%%%%%%Read the classification file

% load('GroundTruth_SHREC2014_BODY_SYTHETIC.mat');
GroundTruth = GroundTruth + 1;

numCategories = size(GroundTruth,2);
numTotalModels = size(GroundTruth,1)*size(GroundTruth,2);

testCategoryList.numCategories = numCategories;
testCategoryList.numTotalModels = numTotalModels;

currNumCategories = 0;
currNumTotalModels = 0;

for i=1:numCategories
    currNumCategories = i;
    numModels = size(GroundTruth,1);
    testCategoryList.categories(currNumCategories).numModels = numModels;
    for j=1:numModels
        currNumTotalModels = currNumTotalModels+1;
        testCategoryList.modelsNo(currNumTotalModels) = GroundTruth(j,i); 
        testCategoryList.classNo(currNumTotalModels) = currNumCategories;
    end
end


% %%%%%%Read the distance matrix

matrixDis(numTotalModels,numTotalModels) = 0;
for i=1:numTotalModels
    for j=1:numTotalModels
        iNew = testCategoryList.modelsNo(i);
        jNew = testCategoryList.modelsNo(j);
        matrixDis(i,j) = matrixInput((iNew-1)*numTotalModels+jNew);          
    end
end
% 
% fclose(fp);

%%%%%%%Evaluation
matrixNo(1:numTotalModels) = 0;
modelNo(1:numTotalModels) = 0;
tempDis(1:numTotalModels) = 0;
for i = 1:numTotalModels
    matrixDis(i,i) = -Inf;
    [tempDis, modelNo] = sort(matrixDis(i,:));
    for k = 1:numTotalModels
        matrixNo(k) = testCategoryList.classNo(modelNo(k));
    end
	
	count = 0;
	K1 = testCategoryList.categories(matrixNo(1)).numModels-1;
	K2 = 2*K1;
	DCG = 0;
	idealDCG = 1;
	for j = 2:K1
		idealDCG = idealDCG + log(2.0)/log(j);
	end

	for j = 1:numTotalModels			
		if (matrixNo(j) == testCategoryList.classNo(i))
			count = count+1;
			if (j ~= 1)
				if (j == 2)
					first_NN = first_NN+1;
					DCG = 1;
				else
					DCG = DCG + log(2.0)/log(j-1);
				end
			end
		end
		if (j == K1+1)
			first_Tier = (count-1)*1.0/K1;
			avgFirst_Tier = avgFirst_Tier + first_Tier;
		end
		if (j == K2+1)
			second_Tier = (count-1)*1.0/K1;
			avgSecond_Tier = avgSecond_Tier + second_Tier;
		end
		
		if (j == 33)
			e_Measure = (count-1)*2.0/(K1+32);
			avgE_Measure = avgE_Measure + e_Measure;
		end
	end
	DCG = DCG/idealDCG;
	avgDCG = avgDCG + DCG;
	
end

avgFirst_Tier = avgFirst_Tier/numTotalModels;
avgSecond_Tier = avgSecond_Tier/numTotalModels;
avgE_Measure = avgE_Measure/numTotalModels;
avgDCG = avgDCG/numTotalModels;
avgFirst_NN = first_NN/numTotalModels;


%evalFileName = sprintf('result.txt');
%fp = fopen(evalFileName,'w');

%fprintf(fp,'NN:\n ');
%fprintf(fp,'%.4f\n ',avgFirst_NN);	
%fprintf(fp,'1_Tier:\n ');
%fprintf(fp,'%.4f\n ',avgFirst_Tier);
%fprintf(fp,'2_Tier:\n ');
%fprintf(fp,'%.4f\n ',avgSecond_Tier);
%fprintf(fp,'e_Measure:\n ');
%fprintf(fp,'%.4f\n ',avgE_Measure);
%fprintf(fp,'DCG:\n ');
%fprintf(fp,'%.4f\n ',avgDCG);
% 
%disp(' ')
%disp('------------------------ RESULTS -------------------------');
%strTemp = sprintf('NN      1-Tier      2-Tier     e-Measure     DCG\n');
%disp(strTemp);
%strTemp = sprintf('%.4f  %.4f      %.4f     %.4f        %.4f',avgFirst_NN,avgFirst_Tier,avgSecond_Tier,avgE_Measure,avgDCG);
%disp(strTemp);
%disp('----------------------------------------------------------');
%disp(' ')

%fclose(fp);
end
