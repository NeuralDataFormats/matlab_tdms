BASE_PATH = 'F:\Projects\matlab\tdms\data_examples';

%This file is very highly segmented
file_path = fullfile(BASE_PATH,'data_2013_07_19_4.tdms');

%
file_path = fullfile(BASE_PATH,'test1(reshaped).tdms');

%Example from Labview 2014
file_path = fullfile(BASE_PATH,'Example TDMS Advanced Synchronous Write.tdms');

file_path = fullfile(BASE_PATH,'Example TDMS Advanced Asynchronous Write.tdms');

%Has interleaved data
file_path = fullfile(BASE_PATH,'Java--Block-005-- States.tdms');

%Has lots of variety
file_path = fullfile(BASE_PATH,'132_Block-093.tdms');

%file_path = 'Z:\RAWDATA\2010\02182010 - Quadzilla\kinematicsPS\006_Block-021.tdms';
%file_path = 'C:\Users\RNEL\Desktop\TDMSproblems\Demo3.tdms_index';
%file_path = 'C:\D\JimProjects\forFEX_Backups\tdms2\fromOthers\Voltage1.tdms_index';
%file_path = 'Z:\RAWDATA\2012\02282012 - Zapper\stim_data\tdt_isi_stim\Block-015.tdms';
%file_path = 'L:\TDT_Controller\Modules\Robot\Matt Robot Stuff\Robocat\002FakeRobotData.tdms';
%file_path = 'C:\Users\RNEL\Desktop\online_example\example_NI.tdms';
%file_path = 'L:\TDT_Controller\Modules\Robot\Matt Robot Stuff\Robocat\001TempBlk000.tdms_index';
file_path = fullfile(BASE_PATH,'068_Block-052.tdms');
file_path = fullfile(BASE_PATH,'test123_12-11-06_1647_001.tdms');
% profile on



%file_path = 'C:\D\Projects\tdms\data_2013_07_19_4.tdms';

%NOTE: Apparently root and group objects may be missing ...

tic
wtf = convertTDMS(false,file_path);
toc

tic
profile on
temp = tdms.meta(file_path);
profile off
toc
profile viewer

tic
temp = tdms.meta(file_path);
toc

tic
temp2 = TDMS_getStruct(file_path);
% profile off
% profile viewer
toc

% profile off
% profile viewer