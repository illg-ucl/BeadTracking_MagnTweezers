function good_tracks = goThroughBeadTracksVideo(image_label,n_traj_start,n_traj_end,minPointsTraj) 
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
% Plot video of image with tracks overlaid on top for a given image sequence 'image_label', from trajectory
% 'n_traj_start' to 'n_traj_end'.
% The user is requested for input after each track is shown to say if it is
% a "good" one (1) or not (0).
% 
% It works well for short tracks. It is similar to showManyTrajAnalysis2.m.
% It does not save a .avi video file of the track.
%
% NOTE: before running this function you should move into a directory which
% contains both the .sif/video image (labelled by 'image_label') which has previously been analysed with
% 'FindTrajects.m' and 'linkTrajSegments.m' to produce the .xls file which
% contains the trajectory results, which should be in the same directory as the .sif file.
%
% INPUTS: 
% - 'image_label' string that labels the image sequence under analysis, e.g. '101'.
% - 'n_traj_start': first trajectory we want to analyse and check.
% - 'n_traj_end': last trajectory we want to analyse and check. If the
% string 'end' is entered, we go through to the last analysed trajectory.
% - minPointsTraj: minimum number of data points that a trajectory must have in order to be
% analised. A value of 3 is used for "showTrajAnalysis2.m" and
% "showManyTrajAnalysis2.m". 
% A value of at least 6 needs to be used for all methods in
% "showTrajAnalysis.m" (and therefore "showManyTrajAnalysis.m") to work
% well.
% -----------------
% IMPORTANT NOTE!!!: The values of all inputs: "image_label",
% "n_traj_start", "n_traj_end" and "minPointsTraj" here need to be the same
% as those used later on for functions "showManyTrajAnalysis.m" or "showManyTrajAnalysis2.m", 
% otherwise the trajectory numbers will be different!.
% -----------------
%
% OUTPUT: 
% - good_tracks is a structure with fields:
% good_tracks.image_label = image_label; input value.
% good_tracks.n_traj_start = n_traj_start; input value.
% good_tracks.n_traj_end = n_traj_end; input value.
% good_tracks.minPointsTraj = minPointsTraj, input value.
% good_tracks.track_numbers: is a row vector containing the numbers of tracks considered as
% "good" by the user after seing the videos of the track overlaid on the
% image sequence.
% The output is saved as a .mat file.
%
% Example of how to call this function:
% gt = goThroughTracksVideo('1757_1',1,'end',3);
% gt = goThroughTracksVideo('498',1,'end',6);
% ------------------------------------


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


%% Open and analyse all trajectory data (excel file): 
% (.xls file previously generated with functions 'FindTrajects' and 'linkTrajSegments'):
% ======================
% The following derives from old function analyseTraj(file,tsamp,minPointsTraj):

% Sampling time between frames, use tsamp = 1 here, so the time is in units of frames (irrelevant since this function is only used for a visual check).
tsamp = 1;

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
disp('File Loaded successfully!');

% Get individual tracks:

% List the points at which the trajectory number first appears:
[A,I,J] = unique(traj,'first'); % [A,I,J] = UNIQUE(traj,'first') returns the vector I to index the first occurrence of each unique value in traj.  
% A has the same values as in traj but with no repetitions. A will also be sorted.
% List the points at which the trajectory number last appears:
[A,Y,Z] = unique(traj,'last'); % UNIQUE(traj,'last'), returns the vector Y to index the last occurrence of each unique value in traj.

% Get the number of tracks (no. of different trajectories):
numtracks = numel(A);

% Create tracks structure:
tracks(1:numtracks) = struct('trajNumber',[],'xvalues0',[],'yvalues0',[],'xvalues',[],'yvalues',[],'intensity',[],'I0_IspotFit',[],'sigma_IspotFit',[],'msd_unavg',[],'frame',[],'timeabs',[],'timerel',[],'numel',[],'minNumPointsInTraj',[],'deltaTime',[],'msd',[],'errorMsd',[],'errorMsdRelPercent',[],'disp',[],'SNR',[],'bg_noise_offset_afterBGsubtract',[],'BgNoiseStd',[],'IbgAvg',[],'IinnerTot',[],'rsqFit',[]);
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
    % all values in pixels.
    tracks(i).xvalues0 = data{i}(1:end,ID.CentreX); % original xvalues in image (used later for plotting traj on image).
    tracks(i).yvalues0 = data{i}(1:end,ID.CentreY); % original xvalues in image (used later for plotting traj on image).
    % Set origin to zero:
    tracks(i).xvalues = tracks(i).xvalues0 - (tracks(i).xvalues0(1)); % xvalues relative to the first one in the trajectory.
    tracks(i).yvalues = tracks(i).yvalues0 - (tracks(i).yvalues0(1)); % % yvalues relative to the first one in the trajectory.
    tracks(i).msd_unavg = tracks(i).xvalues.^2+tracks(i).yvalues.^2; % squared displacement from the origin: x^2 + y^2.
    tracks(i).frame = data{i}(1:end,ID.FrameNumber); % frame number.
    tracks(i).timeabs = data{i}(1:end,ID.FrameNumber).*tsamp; % tsamp is the time between frames.
    tracks(i).timerel = tracks(i).timeabs-tracks(i).timeabs(1); % Set the first frame analysed as time zero reference (not used for now). 
    tracks(i).numel = b-a+1; % Number of points in the track. Isabel: it used to be b-a, I changed it to b-a+1.
    tracks(i).minNumPointsInTraj = minPointsTraj;
    tracks(i).rsqFitX = data{i}(1:end,ID.rsqFitX); % r-square of parabolic fit to centre peak of cross-correlation along x, for bead centre finding.
    tracks(i).rsqFitY = data{i}(1:end,ID.rsqFitY); % same along y.
    tracks(i) = getDisplacement(tracks(i),tsamp); % calculate msd and its error and add it to result structure.
    
    else
        % save indices to delete later:
        del(i) = i;     
    end
    
end

% Delete tracks which were too short: 
tracks(find(del))=[];

% tracks is a structure with fields XLS
%     trajNumber: traj number (original one)
%     xvalues: vector with xvalues 
%     yvalues: vector with yvalues
%     msd_unavg 
%     frame : vector of frame numbers.
%     timeabs: vector of absolute times (equal to frame number only if tsamp=1.), in seconds if appropriate tsamp (time between frames in seconds) is chosen.
%     timerel: same as timeabs but all times relative to that of the first data point in trajectory. So first one is always zero.
%     numel : number of points in the track
%     deltaTime: vector of delta t values: time differences (in frames).
%     msd: vector of average mean square displacements for each delta t.
%     errorMsd: vector of absolute errors of the msd values.
%     errorMsdRelPercent: vector of relative errors of the msd values in percentage.
%     disp : cell structure: complete list of pair-wise displacements (x and y), and delta
%        time before averaging for each delta t (see getDisplacement).
%        eg: output.disp{1} is a cell structure with fields 'xdiff', 'ydiff' and
%        'tdiff' (see getDisplacement). Eg, output.disp{1}.tdiff is the
%        delta time for the differences for the first delta t,
%        output.disp{2} is the second set, etc...
%
% % AID PLOTS:      
% subplot(2,2,1);plot(output(2).timeabs,output(2).xvalues);title('x vs frame number');...
% subplot(2,2,3);plot(output(2).timeabs,output(2).yvalues);title('y vs frame number');...
% subplot(2,2,2);plot(output(2).timeabs,output(2).intensity,'g--x');title('Intensity vs frame number');...
% subplot(2,2,4);plot(output(2).deltaTime,output(2).msd,'r--x');title('Mean Square Displacements vs Delta t (frames)');

analysedAllTraj = tracks;
% ======================


if isempty(analysedAllTraj)
    disp('The total number of long enough trajectories (to analyse) for this file is zero.');
    disp('Exiting program');
    return % exits function.
end

%'The total number of trajectories analysed (long enough) in the file is: 
n_trajs_analysed = length(analysedAllTraj);
disp(['The number of long enough tracks to go through for this image sequence is: ' num2str(n_trajs_analysed)])

if strcmp(n_traj_end,'end') % string compare, true if equal
    % go through all analysed trajectories til the last one: 
   n_traj_end = n_trajs_analysed;
end


%% Read in the image-sequence data:

% Read image-sequence file:
[numFrames frame_Ysize frame_Xsize image_data image_path] = extract_image_sequence_data(image_label);
% See "extract_image_sequence_data.m".
% numFrames is the number of frames in the image sequence.
% To get frame number "p" do: image_data(p).frame_data.
% Frame dimensions are frame_Ysize and frame_Xsize.



%% Loop selected trajectories:

good_track_numbers = []; % initialise empty vector where I will store numbers of tracks labelled as "good" by the user.

for n = n_traj_start:n_traj_end
    
    % n
    
    % Close any pre-existing figures:
    close(findobj('Tag','Trajectory results'));
    % close(all); % close all figures.
   
    % Show video of trajectory overlaid on actual image:
    frames_list = analysedAllTraj(n).frame; % list of frame numbers in trajectory n.
    x_values = analysedAllTraj(n).xvalues0; % list of original x centres of spots in trajectory n.
    y_values = analysedAllTraj(n).yvalues0; % list of original y centres of spots in trajectory n.
    
    
    % Loop through frames in each trajectory analysed:
    figure('Tag','Data video','Units','normalized','Position',[0 1 0.2 0.2]); % Figure number 2.   
    % 'position' vector is [left, bottom, width, height].
    % left, bottom control the position at which the window appears when it
    % pops.
    
    for k = 1:length(frames_list)
        
        frame = image_data(frames_list(k)).frame_data; % extract frame data which is stored in field 'frame_data'.
        frame = double(frame);
        
        imshow(frame,[],'Border','tight'); % show image scaled between its min and max values ([]).
        hold on;
        
        plot(x_values(k),y_values(k),'o','Color','g','MarkerSize',12) % plot accepted spot centres in green.
        pause(0.1); % this pause is needed to give time for the plot to appear (0.1 to 0.3 default)
        hold off;
        
    end
        
    disp(['Track number ',num2str(n),' out of ' num2str(n_trajs_analysed) ' tracks:'])

    % Request user input: for GOOD tracking or not:
    good_tracking_flag = input('Is the tracking "good" for this trajectory? (1 for "yes", anything else for "no"): '); 
    % flag saying if trajectory is a good one or not (bgnd point, not good tracking, etc.).
       
    close(findobj('Tag','Data video')); % close video figure;
    
    if good_tracking_flag == 1
        good_track_numbers = [good_track_numbers n]; % append to good_tracks (track numbers) vector.
    end
    
end

% OUTPUT: structure with two fields;
good_tracks.image_label = image_label;
good_tracks.n_traj_start = n_traj_start;
good_tracks.n_traj_end = n_traj_end;
good_tracks.minPointsTraj = minPointsTraj;
good_tracks.good_track_numbers = good_track_numbers;

% Save result (as .mat):
output_filename = strcat('good_track_nums_',image_label);
save(output_filename,'good_tracks') % save variable good_tracks.

% --------------------
