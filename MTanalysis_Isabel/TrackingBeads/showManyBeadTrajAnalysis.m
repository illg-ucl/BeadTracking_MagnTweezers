function processedManyTrajs = showManyBeadTrajAnalysis(image_label,n_traj_start,n_traj_end,start_frame,tsamp,pixelsize_nm,showVideo,minPointsTraj) 
%
% ========================================
% BeadTracking_MT.
% Copyright (c) 2017. Isabel Llorente-Garcia, Dept. of Physics and Astronomy, University College London, United Kingdom.
% Released and licensed under a BSD 2-Clause License:
% https://github.com/illg-ucl/BeadTracking_MT/blob/master/LICENSE
% This program is free software: you can redistribute it and/or modify it under the terms of the BSD 2-Clause License.
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the BSD 2-Clause License for more details. You should have received a copy of the BSD 2-Clause License along with this program.
% Citation: If you use this software for your data analysis please acknowledge it in your publications and cite as follows.
% -	Citation example 1: 
% BeadTracking_MT software. (Version). 2017. Isabel Llorente-Garcia, 
% Dept. of Physics and Astronomy, University College London, United Kingdom.
% https://github.com/illg-ucl/BeadTracking_MT. (Download date).
% 
% -	Citation example 2:
% @Manual{... ,
% title  = {BeadTracking_MT software. (Version).},
% author       = {{Isabel Llorente-Garcia}},
% organization = { Dept. of Physics and Astronomy, University College London, United Kingdom.},
% address      = {Gower Place, London, UK.},
% year         = 2017,
% url          = {https://github.com/illg-ucl/BeadTracking_MT}}
% ========================================
%
% This function uses showBeadTrajAnalysis.m, getDisplacement.m, etc.
%
% Analyse all trajectory data for a given image sequence (), from trajectory
% 'n_traj_start' to 'n_traj_end', only for the trajectory numbers in "good_track_nums_image_label.mat", i.e., selected as
% "good ones" either going through videos of all tracks by eye using function
% goThroughTracksVideo(image_label,n_traj_start,n_traj_end,minPointsTraj)
% or generating the mat file by hand.
% The input list of "good track" numbers must be contained in a .mat file in the current directory (see below).
%
% Shows results of trajectory analysis and saves them, can show the
% trajectory overlayed on the image sequence on a video to check or not,
% saves results of trajectory analysis to an excel file (done within
% showBeadTrajAnalysis.m), saves output to a .mat file with name
% ('procManyTraj'+image_label) within a new folder named data_set_label +
% image_label in current directory.
% 
% NOTE: before running this function you should move into a directory which
% contains both the image sequence (labelled by 'image_label') which has previously been analysed with
% 'FindTrajectsBeads.m' and 'linkTrajSegmentsBeads.m' to produce the .xls file which
% contains the trajectory results, which should be in the same directory as the image sequence file.
%
% INPUTS: 
% - 'image_label' string that labels the image sequence under analysis, e.g. '101'.
% - 'n_traj_start': first trajectory we want to analyse and check.
% - 'n_traj_end': last trajectory we want to analyse and check. If the
% string 'end' is entered, we go through to the last analysed trajectory.
% - 'start_frame' is the number of frame considered as the origin of time
% (as t=0), in frames. It is the first frame for which the shutter is fully open and detecting images.
% - 'tsamp' is the sampling time (time between frames in seconds), used to calibrate the absolute time, to go from frames to time in seconds. 
% Use tsamp = 1 for the time to be in units of frames. A proper calibration
% would have tsamp = 40*10^(-3), i.e., 40ms per frame, for example.
% start_frame*tsamp is therefore the absolute time origin in seconds.
% - 'pixelsize_nm': pixel size in nm (e.g. 35.333nm for fluorescence data).
% - 'showVideo' is an input parameter to show a video of the trajectory
% overlaid on the image sequence or not.
% - minPointsTraj: Minimum number of data points that a trajectory must have in order to be
% analised (default minPointsTraj = 10, at least 3). 
%
%
% OUTPUT: 
% 'processedManyTrajs' is a cell array with as many elements (processedManyTrajs{n}) as
% analysed trajectories (those with good tracking only).
% The first element within trajectory {n} in the cell array, {n}{1}, is a structure with fields:
% fieldnames(processedManyTrajs{1}{1}):
%             track_with_jumps_flag
%                good_tracking_flag
%                  short_track_flag
%                   long_track_flag
%              very_long_track_flag
%        max_NumFramesForShortTrack
%         min_NumFramesForLongTrack
%     min_NumFramesForVeryLongTrack
%                           XLSpath
%                minNumPointsInTraj
%                           TrajNum
%                   OriginalTrajNum
%                    FirstTrajFrame
%                     LastTrajFrame
%                     NumDataPoints
%                     TrajStartTime
%                       TrajEndTime
%                      TrajDuration
%                 TimeBetweenFrames
%                FrameForTimeOrigin
%                     AbsTimeOrigin
%                      pixelsize_nm
%                       Track_meanX
%                       Track_meanY
%                Track_meanX_offset
%                Track_meanY_offset
%
% fieldnames(processedManyTrajs{1}{2}):
%     'frame'
%     'timeabs'
%     'xvalues'
%     'yvalues'
%     'xvalues_offset'
%     'yvalues_offset'
%
%
% fieldnames(processedManyTrajs{1}{3}): MSD data with error bar <150%:
%     'deltaTime'
%     'msd'
%     'errorMsd'
%     'errorMsdRelPercent'
%
% fieldnames(processedManyTrajs{1}{4}): all MSD data:
%     'deltaTime'
%     'msd'
%     'errorMsd'
%     'errorMsdRelPercent'
%
% fieldnames(processedManyTrajs{1}{5}): results of MSD fitting
% structure with the field 'results_mobility'
%
% Eg.  T0 = showManyBeadTrajAnalysis('101',5,7,5,0.04,35.333,1);  
% image '101' in folder, look at analysed trajectories 5 to 7, with frame 5
% being the time origin and 40ms between frames.
% Eg. to show only one trajectory (no. 8 of ATPase-GFP_101fullTrajs.xls, eg) do:
% T0 = showManyBeadTrajAnalysis('101',8,8,5,0.04,35.333,1);
% eg. analyse only traj number 2 for image 500 in data set 'cybD-mCherry-ATPase-GFp':  T500 = showManyBeadTrajAnalysis('500',2,2,5,0.04,35.333,1);
% To get results, do T500{1}{i},   for i from 1 to 8.  
% ------------------------------------


%% PARAMETERS: 

% Set the "quickLook" parameter as 1 if you are just looking quickly at
% "good" trajectories and you don't want to be asked for user input as to
% whether the trajectory is "good" or not (to flag them), and you don't
% want to save the result structure as a .mat in a user specified folder
% either...
quickLook = 0;


%% Get path for trajectory data (excel file):

% You need to be in the correct directory before running the function!!!!
% Find paths in current folder which contain 'image_label' string:
trajXlsPath0 = dir(strcat('*',image_label,'*.xls')); % Trajectory data path (excel file with the full trajectories as returned by function "linkTrajSegments.m").
% Error control:
if isempty(trajXlsPath0) % If there is no .xls trajectory data file for such image number, show error and exit function:
    error('Check you are in the correct directory and run again. No .xls file found for that image number. Make sure image number is in between quotes ''.'); 
end
trajXlsPath = trajXlsPath0.name;
% trajXlsPath0 is a structure and the file names is stored in the field 'name'.


%% Create new directory for saving trajectory-analysis result structure for this image sequence:

% Make new folder (new directory) to save trajectory analysis results:
pos1 = strfind(trajXlsPath,'fullTrajs.xls'); % position of the start of the string 'fullTraj.xls' in the xls input file name.
new_folder_name = trajXlsPath(1:(pos1-1)); % Take the name of the input excel file (with the end bit 'fullTraj.xls' removed) as the new folder name.
% Note that the directory "new_folder_name" is created by function
% showTrajAnalysis2.m when called from this function.

%% Get path for .mat file with the numbers of the good tracks:

% A file with a name "good_track_nums_1757.mat" (eg) is produced by
% function "goThroughTracksVideo.m":
good_tracks_path = dir(strcat('*good_track_nums','*',image_label,'*.mat'));
load(good_tracks_path.name); % This loads the structure "good_tracks" onto the workspace.
% good_tracks is a structure with fields:
% good_tracks.image_label = image_label; input value.
% good_tracks.n_traj_start = n_traj_start; input value.
% good_tracks.n_traj_end = n_traj_end; input value.
% good_tracks.minPointsTraj = minPointsTraj, input value.
% good_tracks.track_numbers: is a row vector containing the numbers of tracks considered as
% "good" by the user after seing the videos of the track overlaid on the
% image sequence.


%% Read in all trajectory data (excel file with all tracks): 
% (.xls file previously generated with functions 'FindTrajectsBeads' and 'linkTrajSegmentsBeads'):

% error control:
if 2~=exist('xlsread') 
    error('Check file dependencies - you need to install xlsread'); 
end

% Open excel file and read the data:
[NUMERIC,TXT,RAW]=xlsread(trajXlsPath,'Track results'); % import the data in the sheet named 'Track results'.
% Import the column heads and assign ID
colheads = TXT;
% The column titles are: CentreX, CentreY, ClipFlag, rsqFitX, rsqFitY,
% FrameNumber, BeadNumber,	TrajNumber.

% Generate ID: ID is a structure with fiels with the same names as the
% column titles, and each has an ID value of 1, 2, 3, etc (see below).
for i=1:numel(colheads) 
    ID.(colheads{i}) = find(strcmp(TXT,colheads{i})); 
end
% eg. ID = 
%         CentreX: 181.1559
%         CentreY: 393.0774
%        ClipFlag: 0
%         rsqFitX: 0.9997
%         rsqFitY: 0.9991
%     FrameNumber: 1
%      BeadNumber: 3
%      TrajNumber: 3

% The trajectory number column:
traj = NUMERIC(:,ID.TrajNumber); % NUMERIC is the numeric data read from the excel file (without the row of column titles).
disp('Excel file read successfully.');

% Get individual tracks:

% List the points at which the trajectory number first appears:
[A,I,J] = unique(traj,'first'); % [A,I,J] = UNIQUE(traj,'first') returns the vector I to index the first occurrence of each unique value in traj.  
% A has the same values as in traj but with no repetitions. A will also be sorted.
% List the points at which the trajectory number last appears:
[A,Y,Z] = unique(traj,'last'); % UNIQUE(traj,'last'), returns the vector Y to index the last occurrence of each unique value in traj.

% Get the number of tracks (no. of different trajectories):
numtracks = numel(A);

% Create tracks structure:
tracks(1:numtracks) = struct('trajNumber',[],'xvalues',[],'yvalues',[],...
    'mean_xvalue',[],'mean_yvalue',[],'xvalues_offset',[],'yvalues_offset',...
    [],'msd_unavg',[],'frame',[],'timeabs',[],'timerel',[],'numel',[],...
    'minNumPointsInTraj',[],'deltaTime',[],'msd',[],'errorMsd',[],...
    'errorMsdRelPercent',[],'disp',[]);

del = []; % initialise for later.

for i=1:numtracks 
    % i
    a = I(i); % index for starting point in trajectory.
    b = Y(i); % index for ending point in trajectory.
    
    % Delete tracks that are less than minPointsTraj data points long:
    if b-a+1 >= minPointsTraj  % Only analyse tracks which have at least "minPointsTraj" points (frames) in them (5, or 15, e.g.).
    
    data{i} = NUMERIC(a:b,:);
    % tracks(i).XLS.track_index = A(i);
    tracks(i).trajNumber = A(i);
    tracks(i).numel = b-a+1; % Number of points in the track.
    tracks(i).frame = data{i}(1:end,ID.FrameNumber); % frame numbers.
    tracks(i).timeabs = data{i}(1:end,ID.FrameNumber).*tsamp; % Absolute time in seconds. tsamp is the time between frames in s.
    tracks(i).minNumPointsInTraj = minPointsTraj;
    % All absolute position values in pixels:
    tracks(i).xvalues = data{i}(1:end,ID.CentreX); % xvalues of particle centre on image (used later for plotting traj on image).
    tracks(i).yvalues = data{i}(1:end,ID.CentreY); % yvalues of particle centre on image.           
    tracks(i).mean_xvalue = mean(data{i}(1:end,ID.CentreX)); % mean x value. 
    tracks(i).mean_yvalue = mean(data{i}(1:end,ID.CentreY)); % mean y value.
    % Set spatial origin to position of first point in track:
    tracks(i).xvalues_offset = tracks(i).xvalues - (tracks(i).xvalues(1)); % xvalues relative to the first point in the trajectory.
    tracks(i).yvalues_offset = tracks(i).yvalues - (tracks(i).yvalues(1)); % % yvalues relative to the first point in the trajectory.
    tracks(i).msd_unavg = tracks(i).xvalues_offset.^2+tracks(i).yvalues_offset.^2; % absolute squared displacement from the origin (0,0): x^2 + y^2.
    % Set time origin to first point in track:
    tracks(i).timerel = tracks(i).timeabs-tracks(i).timeabs(1); % Time relative to first point in track. Set the first frame analysed as time zero reference (not used for now). 
    % Calculate and add to structure the 2D mean square displacement (msd):
    tracks(i) = getDisplacement(tracks(i),tsamp); % calculate msd and its error and add it to result structure.
    % getDisplacement.m adds the following fields to the tracks structure:
    % 'deltaTime','msd','errorMsd','errorMsdRelPercent' and 'disp'.
    else
        % save indices to delete later:
        del(i) = i;     
    end
    
end

% Delete tracks which were too short: 
tracks(find(del))=[];

% ========================

%% Analyse all trajectory data (get msd): 
analysedAllTraj = tracks; 

if isempty(analysedAllTraj)
    disp('The total number of long enough trajectories (to analyse) for this file is zero.');
    disp('Exiting program');
    return % exits function.
end

%'The total number of trajectories analysed (long enough) in the file is: 
n_trajs_analysed = length(analysedAllTraj);


if strcmp(n_traj_end,'end') % string compare, true if equal
    % go through all analysed trajectories til the last one: 
   n_traj_end = n_trajs_analysed;
end


%% Error control: IMPORTANT!!
% Check that the "minPointsTraj" (min no. of points in track for it to be
% analysed) and all other inputs for function "goThroughTracksVideo.m" were
% the same as for this function:
if (good_tracks.minPointsTraj ~= minPointsTraj) || ...
        (strcmp(good_tracks.image_label,image_label)~=1) || ...
        (good_tracks.n_traj_start ~= n_traj_start) || ...
        (good_tracks.n_traj_end ~= n_traj_end)
    disp('ERROR: parameters minPointsTraj, image_label, n_traj_start, n_traj_end must be the same as those used to create list of "good track" numbers with function goThroughTracksVideo.m or goThroughTracksVideo2.m. Exiting function...')
    return % exit function.
end
% row vector with  numbers of "good" tracks:
good_track_numbers = good_tracks.good_track_numbers;


%% Read in the image-sequence data:

% Read image-sequence file:
[numFrames frame_Ysize frame_Xsize image_data image_path] = extract_image_sequence_data(image_label);
% See "extract_image_sequence_data.m".
% numFrames is the number of frames in the image sequence.
% To get frame number "p" do: image_data(p).frame_data.
% Frame dimensions are frame_Ysize and frame_Xsize.



%% Loop selected trajectories:

n_good_tracking = 1; % initialise index for trajs with good tracking which are saved within loop.

for n = n_traj_start:n_traj_end
    
    % Check if track number n is one of the "good" ones:
    B = ismember(good_track_numbers,n); % result is a vector with zeros at all positions except at the position of n in vector good_track_numbers, if it is a "good" one.
    % sum(B) is equal to 0 if "n" is not a "good" track, and equal to 1 if
    % "n" is on the list of "good" track numbers.
    
    if sum(B) == 1 % If track number "n" is a "good" one:
        
        % Close any pre-existing figures:
        close(findobj('Tag','Trajectory results'));
        % close(all); % close all figures.
        
        frames_list = analysedAllTraj(n).frame; % list of frame numbers in trajectory n.
        x_values = analysedAllTraj(n).xvalues; % list of original x centres of beads in trajectory n.
        y_values = analysedAllTraj(n).yvalues; % list of original y centres of beads in trajectory n.
        
        % Show video of trajectory overlaid on actual image:
        if showVideo == 1 % 'showVideo' is input parameter.
            
            % Loop through frames in each trajectory analysed:
            figure('Tag','Data video','units','inches','position',[12 4 6 6]); % Figure number 2.
            
            %         % Create video file:
            %         set(gca,'nextplot','replacechildren');
            
            % 'position' vector is [left, bottom, width, height].
            % left, bottom control the position at which the window appears when it pops.
            
            for k = 1:length(frames_list)
                
                frame = image_data(frames_list(k)).frame_data; % extract frame data which is stored in field 'frame_data'.
                frame = double(frame);
                
                imshow(frame,[],'Border','tight','InitialMagnification',150); % show image scaled between its min and max values ([]).
                hold on;
                
                plot(x_values(k),y_values(k),'o','Color','g','MarkerSize',12) % plot accepted spot centres in green.
                pause(0.3); % this pause is needed to give time for the plot to appear (0.1 to 0.3 default)
                hold off;
                
                %             % Save each frame to the video:
                %             track_video(k) = getframe;
                
            end
            
        end
        
        % For a quick analysis of "good" trajectories, quickLook = 1, no user
        % input requested and trajectories flagged as "good tracking":
        if quickLook ==1
            good_tracking_flag = 1;
        else
            % CHECK: skip the following visual check of every track or not.
            good_tracking_flag = 1;
            % good_tracking_flag = input('Is the tracking "good" for this trajectory? (1 for "yes", anything else for "no"): '); % request user input.
            % flag saying if trajectory is a good one or not (bgnd point, not good tracking, etc).
        end
        
        close(findobj('Tag','Data video')); % close video figure;
        
        if good_tracking_flag == 1
            % only analyse n-th trajectory if tracking is good (and folder created for good-tracking trajectories only).
            % "good_tracking_flag" is added to result structure in
            % "showTrajAnalysis.m", always 1, because if tracking is no good, the
            % trajectory is not analysed.
            
            % Analyse n-th trajectory data, produce result plots and save them:
            processedTraj = showBeadTrajAnalysis(trajXlsPath,image_data,analysedAllTraj,n,start_frame,tsamp,pixelsize_nm);
            
            % output: structure array, starting at element 1, only save to results trajs with good tracking.
            processedManyTrajs{n_good_tracking} = processedTraj; % Function output: cell array, starting at element 1.
            
            % Note that saving is done within function "showTrajAnalysis.m".
            
            n_good_tracking = n_good_tracking + 1;
        end
        
    end
end



%% Save result (as .mat) in output folder which contains track results for this image sequence:

cd(new_folder_name) % move into folder corresponding to track results for this image sequence.
output_filename = strcat('procManyTraj',image_label);
save(output_filename,'processedManyTrajs'); % save variable processedManyTrajs to a .mat file
cd('..') % go back to previous folder.

% Save result (as .mat) in a folder specified by user input:
% % Do not save if we are just having a quick look at good trajectories
% % (quickLook = 1):
% if quickLook ~=1
%     uisave('processedManyTrajs','procManyTraj')
% end