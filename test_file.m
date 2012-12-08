%file_path = 'Z:\RAWDATA\2010\02182010 - Quadzilla\kinematicsPS\006_Block-021.tdms';
%file_path = 'C:\Users\RNEL\Desktop\TDMSproblems\Demo3.tdms_index';
%file_path = 'C:\D\JimProjects\forFEX_Backups\tdms2\fromOthers\Voltage1.tdms_index';
%file_path = 'Z:\RAWDATA\2012\02282012 - Zapper\stim_data\tdt_isi_stim\Block-015.tdms';
%file_path = 'L:\TDT_Controller\Modules\Robot\Matt Robot Stuff\Robocat\002FakeRobotData.tdms';
%file_path = 'C:\Users\RNEL\Desktop\online_example\example_NI.tdms';
%file_path = 'L:\TDT_Controller\Modules\Robot\Matt Robot Stuff\Robocat\001TempBlk000.tdms_index';
file_path = 'Z:\RAWDATA\2012\06052012 - Aht\ENG\0001_Block-171.tdms_index';
% profile on

%NOTE: Apparently root and group objects may be missing ...

% tic
% wtf = convertTDMS(false,file_path);
% toc

tic
%profile on
temp = tdms.meta(file_path);
%profile off
%profile viewer
toc

%tic
%temp2 = TDMS_getStruct(file_path);
% % profile off
% % profile viewer
%toc

% profile off
% profile viewer