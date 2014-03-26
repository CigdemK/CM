%% INITIALIZATION
clc, clear;

%Read fixation maps
pathKeyFrames = 'C:\Users\ckocb_000\Thesis\BACKUP\CAMO\AVISelectedVideos_KeyFrames\';
pathPrevKeyFrames = 'C:\Users\ckocb_000\Thesis\BACKUP\CAMO\AVISelectedVideos_PreviousKeyFrames\';

fileName  = dir(fullfile(pathKeyFrames, '*.jpg')); % all dir paths includes files with the same name, lets use pathStatic
fileNamePrev  = dir(fullfile(pathPrevKeyFrames, '*.jpg')); % all dir paths includes files with the same name, lets use pathStatic

C = cell(length(fileName), 2);
M = zeros(length(fileName),1);
for k = 1:length(fileName)
    currentFileName = fileName(k).name;
    tmp = strtok(currentFileName,'0');
    if      strcmp(tmp , 'Dolly');      M(k,1) = 1;
    elseif  strcmp(tmp , 'Panning');    M(k,1) = 2;
    elseif  strcmp(tmp , 'Pedestal');   M(k,1) = 3;
    elseif  strcmp(tmp , 'Tilt');       M(k,1) = 4;
    elseif  strcmp(tmp , 'Trucking');   M(k,1) = 5;
    elseif  strcmp(tmp , 'Zoom');       M(k,1) = 6;
    end
   
    currentFileNamePrev = fileNamePrev(k).name;
    C{k,2} = imread(strcat(pathKeyFrames,currentFileName));
    C{k,1} = imread(strcat(pathPrevKeyFrames,currentFileNamePrev));
end

%Init variables
[ height width depth] = size( C{ 1 , 1 } );
numberOfPatches = length( C ) * floor( height / 90 ) * floor( width / 90 );
CM = zeros(3,3,numberOfPatches);

%% PREPARE PATCHES
vars = whos('-file','C:\Users\ckocb_000\Thesis\bin\H.mat');
load('C:\Users\ckocb_000\Thesis\bin\H.mat', vars(3).name);
windowSize = 15;
tmp = zeros(3,3,120);
i=1;
% H = [];
% for n = 1 : length( C )
%     tic;
%     currentImage = C{n,2};
%     previousImage = C{n,1};
%     try
%         [h mappedImg2] = homography( previousImage,currentImage);
%     catch err
%         h = zeros(3);   
%     end
%     H = cat(3,H,h);
%     toc;
% end
for n = 1 : length( C )
%     if(n==15)
%         a=1;
%     end
%      if n<15
%          lowerBound = n;
%          upperBound = n+windowSize;
%      elseif (length(C) - n) < windowSize
%          lowerBound = n-windowSize;
%          upperBound = length(C);
%      else
%          lowerBound = n-windowSize+1;
%          upperBound = n+windowSize;
%      end
%      n
%      lowerBound
%      for x = lowerBound:upperBound
%          
%          tmp(:,:,n) = tmp(:,:,n)+H(:,:,x);    
%      end
%      tmp(:,:,n) = tmp(:,:,n)/(upperBound-lowerBound+1);
     
    % Divide into patches
    for k = 1 : floor( height / 90 )
        for t = 1 : floor( width / 90 )
            CM(:,:,i) = H(:,:,n);      
            i = i + 1;
        end
    end
end

% save('C:\Users\ckocb_000\Thesis\bin\CM.mat','CM');

           