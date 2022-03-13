classdef meta
    %
    %   Class:
    %   tdms.meta
    
    %{
        file_path = '/Users/jim/Library/CloudStorage/Box-Box/__non_shared/HOME/files_for_code_problems/matlab_tdms/2022_03_01__AdamDempsey/2022-02-08_MEEN6995_Rail_P_sweep_Run006_raw_processed.tdms';
        wtf = tdms.file(file_path);
    
    %}
    
    properties
        options tdms.options
        chans_info tdms.meta_chans_info
        chans tdms.meta_chan_info
        groups
        segs tdms.meta_seg_info
        
        %{1 x n_groups}
        unique_group_names
        
        %[1 x n_groups]
        group_indices
        
        %{1 x n_chans}
        chan_names
        
        %{1 x n_groups}
        group_chan_map
        
        %[1 x n_chans]
        is_chan
        
        n_chans
        n_segs
    end
    
    methods
        function obj = meta(fid, file_path, options)
            
            if nargin == 1
                options = tdms.options();
            end
            
            obj.options = options;
            
            DEBUG = options.verbose;
            N_BYTES_LEAD_IN = 28;
            STRING_ENCODING = 'UTF-8';
            
            [fid, last_letter, is_index_fid] = h__openFile(fid, file_path,options);
            
            chans_info = tdms.meta_chans_info(options);
            seg_info = tdms.meta_seg_info.initialize(options);
            read_order = tdms.read_order();
            
            %Note, this adjusts fid temporarily to get eof position
            file_positions = tdms.file_position(fid);
            
            data_file_byte_index = 0;
            n_segs = 0;
            while ~file_positions.atMetaEnd()
                
                n_segs = n_segs + 1;
                if n_segs > length(seg_info)
                    seg_info = seg_info.grow(options);
                end
                seg = seg_info(n_segs);
                
                
                lead_in = tdms.lead_in(fid,last_letter);
                %lead_in: tdms.lead_in
                seg.is_new_obj_list = lead_in.kTocNewObjList;
                seg.is_interleaved = lead_in.is_interleaved;
                seg.is_big_endian = lead_in.is_big_endian;

                if lead_in.eof_error
                    %This should only happen once at the end
                    fprintf(2,['WARNING: File was not closed properly.\n' ...
                        'Data will most likely be missing at the end of the file\n']);
                    n_segs = n_segs - 1; 
                    obj.n_segs = n_segs;
                    break
                end
                
                seg.data_start_position = data_file_byte_index + N_BYTES_LEAD_IN + lead_in.meta_length;
                data_file_byte_index = data_file_byte_index + N_BYTES_LEAD_IN + lead_in.segment_length;
                
                %QUIRK
                if n_segs == 1
                    lead_in.kTocNewObjList = true;
                end
                
                if lead_in.has_meta_data
                    
                    %Get # of changed objects
                    n_new_obj_in_seg = fread(fid,1,'uint32');
                    
                    %Reinitialize order list if new
                    if lead_in.kTocNewObjList
                        read_order.initialize(n_new_obj_in_seg);
                    end
                    
                    for i = 1:n_new_obj_in_seg
                        obj_path_length = fread(fid,1,'uint32');
                        byte_name = fread(fid,obj_path_length,'*uint8');
                        object_name = native2unicode(byte_name, STRING_ENCODING)'; %#ok<*N2UNI>
                        
                        chan = chans_info.getObject(object_name);
                        
                        chan.setOrUpdate(fid,DEBUG);
                        
                        read_order.update(chan,lead_in);
                        
                        chan.updateProps(fid);
                    end
                end
                
                %TODO: Handle data organization ...
                %----------------------------------------------------------
                seg.is_new_obj_list = seg.is_new_obj_list;
                byte_size_raw = lead_in.segment_length - lead_in.meta_length;
                if ~lead_in.has_raw_data || byte_size_raw == 0
                    seg.n_chunks = 0;
                else
                    
                    seg_read_order = read_order.getSegmentReadOrder(chans_info.channels);
                    
                    seg.populateSegmentReadInfo(...
                        seg_read_order,chans_info.channels,byte_size_raw);
                    
                    chans_info.populateDataReadInfo(seg);

                    %This needs to be handled in some manner for RawDaqMx
                    if ~is_index_fid
                        fseek(fid,byte_size_raw,'cof');
                    end
                end
            end
            
            obj.segs = seg_info(1:n_segs);
            obj.n_chans = chans_info.n_objects;
            obj.n_segs = n_segs;
            obj.chans_info = chans_info;
            obj.chans = chans_info.channels(1:obj.chans_info.n_objects);
            object_paths = {obj.chans.name};
            
            temp = TDMS_getGroupChanNames(object_paths);
            
            obj.chan_names = temp.chan_names;
            obj.is_chan = temp.is_chan;
            obj.groups = obj.chans(obj.is_chan);
            obj.group_indices = find(obj.is_chan);
            
            obj.unique_group_names = unique(obj.group_names,'stable');
            
            n_groups = length(obj.unique_group_names);
            temp2 = cell(1,n_groups);
            for i = 1:n_groups
                cur_group_name = obj.unique_group_names{i};
                mask1 = strcmp(temp.group_names,cur_group_name);
                mask2 = obj.is_chan;
                temp2{I} = find(mask1 & mask2);
            end
            obj.group_chan_map = temp2;
        end
    end
end



function [fid, last_letter, is_index_fid] = h__openFile(fid,file_path,options)
STRING_ENCODING = 'UTF-8';
TDMS_INDEX_EXT  = '.tdms_index';
MACHINE_FORMAT  = 'ieee-le'; %NOTE: Eventually this could be passed into
%fread for support of different endianess

%FIGURING OUT WHICH FILE TO READ
%==========================================================================
[file_root,name_no_ext] = fileparts(file_path);
is_index_fid = false;
if options.use_index || options.index_debug
    if options.index_debug
        indexFile = tdmsFileName;
    else
        indexFile = fullfile(file_root,[name_no_ext TDMS_INDEX_EXT]);
    end
    if exist(indexFile,'file')
        fid = fopen(indexFile,'r',MACHINE_FORMAT,STRING_ENCODING);
        is_index_fid = true;
    else
        %Just use the tdms file, which we have already tested to exist
        if options.index_debug
            %NOTE: With INDEX_DEBUG we explicitly passed in the index
            %file to read and parse (generally for debugging purposes
            %so if it doesn't exist, then we have a problem
            error('Specified tdms_index file doesn not exist')
        end
    end
end

if is_index_fid
    last_letter = double('h');  %used for .tdms_index files
else
    last_letter = double('m');  %used for .tdms files
end


end

function metaStruct = TDMS_getGroupChanNames(object_paths)
%TDMS_getGroupChanNames  Small function to get group/channel names from paths
%
%   metaStruct = TDMS_getGroupChanNames(metaStruct)
%
%   INPUT
%   =======================================================================
%   metaStruct (structure) containing field:
%   	.objectNameList : (cellstr), name of each object (unmodified from
%                          file) of format => /'<group>'/'<chan>'
%
%   OUTPUT
%   =======================================================================
%   metaStruct (structure) with added fields:
%       .groupNames : (cellstr), same length as objectNameList, group name
%                      for each input object, root will be empty
%       .chanNames  : (cellstr), "     ", channel name for each object,
%                      root and group objects will be empty
%       .isChan     : (logical)
%
%   EXAMPLE OUTPUT (of relevant fields)
%   =======================================================================
%     objectNameList: {1x68 cell}
%         groupNames: {1x68 cell}
%          chanNames: {1x68 cell}
%             isChan: [1x68 logical]
%
%   See Also: TDMS_readTDMSFile

%PARSING RULES:
%=============================================================
%A path follows the following format:
%channel objects /'<group>'/'<chan>'
%groups objects  /'<group>'
%root            '/'

%ACTUAL SPECIFICATION =====================================================
%http://zone.ni.com/devzone/cda/tut/p/id/5696
%
%Every TDMS object is uniquely identified by a path. Each path is a string
%including the name of the object and the name of its owner in the TDMS
%hierarchy, separated by /. Each name is enclosed by the ' ' symbols. Any'
%symbol within an object name is replaced with two ' symbols. The following
%table illustrates path formatting examples for each type of TDMS object:
%
%It might be possible to get by the current filter ..., CONSIDER REWRITING
%/'myGroup''/''name'/' <- 


pat1 = '/''(?<groupNames>.*?)''/''(?<chanNames>.*?)''$'; %Channel Object
pat2 = '/''(?<groupNames>.*?)''$(?<chanNames>)';  %Group Object
pat3 = '/(?<groupNames>)(?<chanNames>)';  %Root object
pat = [pat1 '|' pat2 '|' pat3];
temp = regexp(object_paths,pat,'names');

metaStruct.group_names = cellfun(@(x) x.groupNames,temp,'UniformOutput',false);
metaStruct.chan_names  = cellfun(@(x) x.chanNames,temp,'UniformOutput',false);
metaStruct.is_chan     = ~cellfun('isempty',metaStruct.chan_names);
end
