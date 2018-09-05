clc
clear
close all

%% Path to code and PDs
code_path = ''; addpath(code_path);
pd_path = [code_path, '/Datasets'];
pd_files = {'Persistence_Diagrams_SHREC10_SIHKS.mat';'Persistence_Diagrams_SHREC10_HKS.mat';'Persistence_Diagrams_SHREC10_WKS.mat'}; 

%% Parameter initialization for PTS feature extraction
fprintf('\n************* Initializing Parameters *************\n')
% Number of random perturbations
param.m = 40; 
% Maximum allowable displacement of points in PD
param.max_displacement = 0.05; 
% Grid size of 2D PDF
param.x1 = 0:.02:1;
param.x2 = 0:.02:1;
% Standard deviation of Gaussian kernel function for KDE
param.sigma = 0.0004;
% Subspace dimension of PTS Grassmannian representations
param.subspace_dimension = 10;
% Weighting function to weight points in PD based on lifetime of points
param.smooth_weight = 'no';

%% Extracting PTS features from PDs
for z = 1:length(pd_files)
    % Loading PDs
    pd_file_name = pd_files{z,1};
    load([pd_path,'/', pd_file_name]);
    PDs = PD; clear PD;

    pds_per_shape = size(PDs{1,3},1);
    temp = strsplit(pd_file_name,'_');
    descriptor = temp{4}(1:(length(temp{4})-4));

    fprintf(['\n\n********** Extracting ',descriptor,' PTS Features **********\n\n'])

    save_folder_name = ['PTS_',descriptor];
    save_path = [code_path,'/',save_folder_name];
    if ~exist(save_path)
        mkdir(save_path);
    end
    % Loop over shapes
    for i  = 1:length(PDs)
        PD = PDs{i,3};
        PTS = {};
        % Loop over PDs in each shape
        for j = 1:pds_per_shape
            % Normalzing PD w.r.t. maximum death-time observed in PD
            PD_normalized = Normalize_PD(PD{j,1});

            % Creating set of randomly perturbed PDs
            Perturbed_PDs = Random_perturbation(PD_normalized, param);

            % Creating 2D PDFs using kernel density estimation
            PDFs = PDFs_from_PDs(Perturbed_PDs,param);

            % Mapping PDFs to a point on the Grassmannian
            PTS{j,1} = map_to_Grassmannian(PDFs,param);
        end
        save([save_path,'/',PDs{i,1}],'PTS');
        if ~ mod(i,4)
            fprintf('#');
        end
    end
    save([save_path,'/Parameters.mat'],'param');

    %% Computing Distance Matrix
    fprintf('\n\n************ Computing Distance Matrix ************\n\n');
    total_shapes = length(PDs);
    distmat_Chordal = zeros(total_shapes,total_shapes);
    distmat_SubspaceAngle = zeros(total_shapes,total_shapes);
    time_taken_Chordal = [];
    time_taken_SubspaceAngle = [];
    
    for i = 1:total_shapes
        pts1 = load([save_path,'/',PDs{i,1}]); pts1 = pts1.PTS;
        for j = i:total_shapes
            pts2 = load([save_path,'/',PDs{j,1}]); pts2 = pts2.PTS;
            for k = 1:length(pts1)
                tic;
                distmat_Chordal(i,j) = distmat_Chordal(i,j) + distChordalGrass(pts1{k},pts2{k});
                time_taken_Chordal = [time_taken_Chordal,toc];
                tic;
                distmat_SubspaceAngle(i,j) = distmat_SubspaceAngle(i,j) + subspace_angles(pts1{k},pts2{k});
                time_taken_SubspaceAngle = [time_taken_SubspaceAngle,toc];
            end
        end
        if ~ mod(i,4)
            fprintf('#');
        end
    end
    time_taken_Chordal = time_taken_Chordal(1:3000);
    time_taken_SubspaceAngle = time_taken_SubspaceAngle(1:3000);
    
    distmat_Chordal = distmat_Chordal+distmat_Chordal';
    distmat_Chordal(logical(eye(size(distmat_Chordal)))) = 0;
    
    distmat_SubspaceAngle = distmat_SubspaceAngle+distmat_SubspaceAngle';
    distmat_SubspaceAngle(logical(eye(size(distmat_SubspaceAngle)))) = 0;
    
    save([code_path,'/distmat_',descriptor,'.mat'],'distmat_Chordal','distmat_SubspaceAngle');
    save([code_path,'/time_taken_',descriptor,'.mat'],'time_taken_Chordal','time_taken_SubspaceAngle');
end    

%% 1-Nearest Neighbor Classification
fprintf('\n\n******** 1-Nearest Neighbor Classification ********\n\n');
load([code_path,'/GroundTruth_SHREC2010.mat']);    

load([code_path, '/distmat_SIHKS.mat']);
distmat1 = distmat_Chordal;
distmat2 = distmat_SubspaceAngle;

load([code_path, '/distmat_HKS.mat']);
distmat1 = distmat1 + distmat_Chordal;
distmat2 = distmat2 + distmat_SubspaceAngle;

load([code_path, '/distmat_WKS.mat']);
distmat1 = distmat1 + distmat_Chordal;
distmat2 = distmat2 + distmat_SubspaceAngle;

labels = cell2mat(PDs(:,2));
[accuracy] = NearestNeighbor(distmat1,labels);
disp(['1-NN Classification Accuracy using Chordal metric = ',num2str(accuracy)]);
disp(['Average time taken to use Chordal metric = ',num2str(mean(time_taken_Chordal))]);
fprintf('\n');
[accuracy] = NearestNeighbor(distmat2,labels);
disp(['1-NN Classification Accuracy using Subspace Angle metric = ',num2str(accuracy)]);
disp(['Average time taken to use Subspace Angle metric = ',num2str(mean(time_taken_SubspaceAngle))]);
