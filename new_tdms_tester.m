%new_tdms_tester

file_path = 'C:\D\JimProjects\forFEX_Backups\tdms2\tempTDMS\testFiles\132_Block-093.tdms';
file_path2 = 'C:\D\JimProjects\forFEX_Backups\tdms2\tempTDMS\testFiles\132_Block-093.tdms_index';

profile on
TDMS_reader(file_path2);

profile on
tic
TDMS_readTDMSFile(file_path2)
toc
profile off
profile viewer

tic
temp = fileread(file_path2);
toc