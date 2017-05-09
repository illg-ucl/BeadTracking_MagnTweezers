function [row] = FileRow(fileinfo,rownum)

%[row] = FileRow(fileinfo,rownum)
%
%FileRow.m is a front end which unifies the commands necessary to read
%rows from common file formats. While typically, frame by frame operation 
%is more desireable, sometimes it is necessary to know the value of a pixel 
%at all times. Generally, memory limitations prohibit reading in all values 
%of all pixels. As a compromise,instead of operating upon all pixels at all 
%times, we operate upon a row of pixels at all times. 
%
%INCLUDE:   SpeRow.m
%           SifRow.m
%           CineRow.m
%
%INPUTS:    FILEINFO:   A structure containing pertinent information about
%                       the file, generated by FileDetails.m
%           ROWNUM:     The y coordinate in the array of the desired row.
%
%OUTPUTS:   ROW:     An array, for which each row gives the value of the
%                       selected row at the corresponding frame number.
%                       Size of the array is 'frame width (or height)' x
%                       'number of frames'
%
%Copyright Stephen Anthony 10/2009 U. Illinois Urbana-Champaign
%Last modified by Scott Parker on 10/27/2009

%Call the appropriate function dependent upon file type, by comparing the
%file extension in a non-case sensitive fashion
if strcmpi(fileinfo.format,'.sif')
    %Andor Technology MultiChannel File Format
    row=SifRow(fileinfo,rownum);
elseif strcmpi(fileinfo.format,'.spe')
    %SPE File format (WinSpec)
    row=SpeRow(fileinfo,rownum);
elseif strcmpi(fileinfo.format,'.cine')
    %CINE Vision Research File Format
    row=CineRow(fileinfo,rownum);
end