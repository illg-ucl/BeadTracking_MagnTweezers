function scriptToRun
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


%% To analyse an entire video sequence: 
%
% STEP BY STEP GUIDE for BeadTracking_MT:
%
% E.g., to analyse video "210217r25.tif":
% 
% - 1. Make sure the folder containing the BeadTracking_MT source code is
% added to the Matlab search path. Go to Home tab -> Set Path -> Add with
% subfolders (select appropriate folder) -> save.
%
% - 2. The source code has been tested using MATLAB R2016a (9.0.0.341360),
% 64-bit (Win64), February 11, 2017. It requires some MATLAB packages to
% run. These are usually included in default MATLAB installations but check
% by typing in the command window:
% >> license('inuse')
% The following packages should appear:
% curve_fitting_toolbox
% image_toolbox
% matlab
% signal_toolbox
% statistics_toolbox
% If they do not appear, they should be installed.
%
% - 3. Make sure the Current Folder within Matlab is the folder that contains
% your image video files. 
% data_folder = 'C:\Users\isabel\ISABEL\UCL_Isabel\Crick\ExperimentalData\MTsampleData';
data_folder = 'C:\Users\isabel\ISABEL\UCL_Isabel\DataAnalysis\JohnnyNguyen_PSmagnetophoresis';
cd(data_folder)

% - 4. Define image_label: 
% image_label = '210217r25';
image_label = 'PPS5um_0d6MnCl2_x2_014_crop';
% - image_label: string that labels a given image sequence found in current
% folder. The code finds the path of the image file automatically based on a string label 
% that is equal to the file name without the file extension. For example,
% for image video file "210217r25.tif", image_label would be the
% string '210217r25'. Same throughout the entire BeadTracking_MT code.
% 
% - 5. PARAMETERS: There are a number of important parameters that need to be set right.
% These are within functions FindTrajectsBeads.m and
% linkTrajSegmentsBeads.m. Find these functions in the
% "BeadTracking_MT\MTanalysis_Isabel\TrackingBeads\" folder that contains the source code
% and tweak these parameters on the PARAMETERS section at the beginning of
% each .m file.
%
% The key parameters in BeadTracking_MT\MTanalysis_Isabel\TrackingBeads\FindTrajectsBeads.m are:
% - subarray_halfwidth (Default: 60 pixels). Halfwidth of image square subarray which includes bead and background around it.
% - inner_circle_radius (Default: 50 pixels); Radius of circular mask that contains the entire bead. 
% - d_01_max (Default: 30 pixels); Max distance in pixels between bead
% centres in one frame and the next one, so that they can be linked into a
% trajectory. This depends on the bead size on the image, the frame rate
% and how much beads move between frames. Tweak to match experimental
% conditions.
% - d_02_max (Default: 30 pix). Similar to above but for linking one frame
% and two frames later.
%
% The key parameters in BeadTracking_MT\MTanalysis_Isabel\linkTrajSegmentsBeads are:
% - d_01_max (Default: 30 pixels); Max distance in pixels between bead
% centres for linking different trajectory segments, i.e., for linking end
% bead position in one trajectory with start bead position in another trajectory.
% - Frames_away_max (Default: 5 pix); Max separation in frames (i.e., prop
% to time) for trajectory segments to be linked. Write 1 if you want no
% jumps (no frame jumps) in the segment linking. 
% For magnetic tweezers, consider how many frames might be dark when magnet
% is brought above sample.
% The remaining parameters can be left as they are. All parameters are
% saved in separate tabs to the excel file ending in "fullTrajs.xls".
%
% - 6a. DEFINE data_set_label:
data_set_label = 'tests';
% - data_set_label: used to produce an excel file for further analysis of
% individual tracks. data_set_label appears in name of excel file generated
% by linkTrajSegmentsBeads and in name of folder that contains further
% analysis generated by function showManyBeadTrajAnalysis.m.
% - 6b. DEFINE minimum number of points in track for it to be accepted:
minPointsTraj = 10;
%
% - 7. Find trajectories and output them to one excel file in the current
% directory.
% Use functions FindTrajectsBeads and linkTrajSegmentsBeads: 
% bead_results = FindTrajectsBeads(image_label,start_frame,end_frame,excludedRegions)
%
% - last input: excludedRegions: to exclude certain regions from image. 
% Enter [] (so that isempty(excludedRegions) = 1) if you
% don't want to exclude any regions.
% Input a structure as follows to exclude one or several regions.
% Regions to exclude are given by start coordinates (x_start, y_start) for
% top left corner of rectangle on image and end coordinates (x_end, y_end)
% for bottom right corner of rectangle. Coordinates delimit rectangular
% boxes on image and several rectangles can be defined. All rectangles are
% put together in structure input excludedRegions:
% Example, for Sonia's images we exclude the following regions:
% excludedRegions.list_xstart = [1 1 1 130];
% excludedRegions.list_xend = [820 112 100 215];
% excludedRegions.list_ystart = [581 492 1 1];
% excludedRegions.list_yend = [614 580 175 54];
%
% linkTrajSegmentsBeads(image_label,start_frame,end_frame,bead_results,data_set_label).
% E.g., for frames 1 to 20 in video "210217r25.tif" in the current directory:
%t25 = FindTrajectsBeads(image_label,1,20);
% Note: you can use 'end' as input when you don't know the total number of
% frames in a video.
% ALSO: when you don't know the number of frames in a given image you can do:
% frame1 = extract1frameB(1);
% and select the image from a folder. The command window will print the
% number of frames on the image sequence, the file path and frame size.

t14 = FindTrajectsBeads(image_label,1,'end',[]);
save 'resultStructures.mat' 't*' % save all result structures in a .mat file.

%linkTrajSegmentsBeads(image_label,1,20,t25,data_set_label); 
linkTrajSegmentsBeads(image_label,1,'end',t14,data_set_label); 
% The above two lines generate an Excel file with all the trajectory data,
% "tests_25_fullTrajs.xls", in the current directory folder, for further
% analysis. This file contains two tabs with the parameters used in the
% analysis and another tab with the trajectory data. The key columns are
% CentreX, CentreY (x and y bead-centre positions in pixels) and
% TrajNumber, the Trajectory Number.
% Note: make sure that the start_frame and end_frame values are kept the
% same throughout all functions!!
close all

% - 8. Plot and save a .png image of the Trajectory Numbers for the found
% beads overlaid on top of first frame of the video.
% Use function  plotBeadTrajNumbers(image_label,minPointsTraj).
% Input "minPointsTraj" (Default: 10) is the minimum number of points in a trajectory for
% it to be considered (we don't want to analyse tracks with only a few
% points that might appear due to suboptimal tracking when two beads are
% very close together):
plotBeadTrajNumbers(image_label,data_set_label,minPointsTraj)
cd(data_folder); % return to data folder.

% Note: the code does not work optimally for beads that are close together
% and have overlapping diffraction rings. For these, we will have a low
% r-squared of the parabolic fits to the cross-correlation peak for finding
% the bead centre with sub-pixel precision, so they will be excluded from
% the final results. 

% - 9. Select good tracks. Two alternative methods:
% - 9a) Inspect tracks manually on a video to decide which to accept as good:
% Use function:
% good_tracks = goThroughBeadTracksVideo(image_label,data_set_label,n_traj_start,n_traj_end,minPointsTraj)
good_tracks = goThroughBeadTracksVideo(image_label,data_set_label,1,'end',minPointsTraj); 
% The above generates the structure (after visually excluding tracks 4 and 5):  
% good_tracks = 
%            image_label: '25'
%           n_traj_start: 1
%             n_traj_end: 26
%          minPointsTraj: 10
%     good_track_numbers: [1 2 3 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26]
%
% - 9b) Note, that doing the above is quite slow, particularly for long tracks
% over long videos. So the alternative is to inspect a few tracks as in 8a),
% make a note of the total number of long-enough tracks (printed on the
% command window during the analysis using goThroughBeadTracksVideo), then
% press Control+C to cancel the function evaluation (will generate no output), and 
% then generate the structure good_tracks2 by hand.
% Exclude bead numbers for beads that are close to each other with
% overlapping diffraction rings just by looking at the png image
% generated in step 7.
% E.g., to generate by hand, do:
good_tracks.image_label = image_label;
good_tracks.n_traj_start = 1;
good_tracks.n_traj_end = 26;
good_tracks.minPointsTraj = 10;
good_tracks.good_track_numbers = [1:3 6:26]; % All tracks from 1 to 26 except for tracks 4 and 5.
% Save result (as a .mat file, required for further analysis functions):
output_filename = strcat('good_track_nums_',image_label,'.mat');
save(output_filename,'good_tracks') % save variable good_tracks2.
% NOTE: make sure you don't change the name 'good_tracks' to anything else.
% It is used later by function showManyParticleTrajAanalysis.m.

% - 10. Analyse each track separatedly.
% This is based on functions showBeadTrajAnalysis.m and
% showManyBeadTrajAnalysis.m
% Running the line below produces one analysis excel file and graph per track:
% processedManyTrajs = showManyBeadTrajAnalysis(image_label,data_set_label,n_traj_start,n_traj_end,start_frame,tsamp,pixelsize_nm,showVideo,saveAvi,minPointsTraj)

%showManyBeadTrajAnalysis(image_label,data_set_label,1,'end',1,1,100,0,0,minPointsTraj);
showManyBeadTrajAnalysis(image_label,data_set_label,1,'end',1,1/14,460,0,0,minPointsTraj);


%% To carry out tests of the methods on a single frame:

% % E.g., extract frame 1 from an image sequence selected from a browsing
% % dialog:
% frame1 = extract1frameB(1);
% 
% % Find candidate positons for beads:
% [x1,y1] = findCandidateBeadPositions(frame1,1);
% 
% % Eliminate candidate positions closer to each other than 3 pixels:
% [new_x1,new_y1,pos_to_keep1] = eliminateCoincidentPositions(x1,y1,3);
% 
% % Subtract background, method 1 is faster:
% frameNoBgnd1 = removeBgnd(frame1,new_x1,new_y1,50,60,1);
% 
% % Test finding bead centre on single frame:
% s1 = findBeadCentre1frame(frameNoBgnd1,new_x1(1),new_y1(1),50,60);

%% ----------------------
% Note: can use a set of individual .tif images and use ImageJ to make
% a stack. Import -> Image Sequence. Choose first file and then tweak stack
% settings. Then save as .tif (saves stack).

