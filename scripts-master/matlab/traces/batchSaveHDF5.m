% Code to batch load trace structures & behavior and save as HDF5 Files
% Requires /scripts/matlab/utilities to be added to path

% Get Input Data
%basedir = '/mnt/eng_research_handata/eng_research_handata2/Kyle/TonePuff-Rebecca/4540/4540_d9_s1';%'/mnt/eng_research_handata/Kyle/AliEyeBlink/ali26_d5_s2'; %'/mnt/eng_research_handata/eng_research_handata2/Kyle/NewTonePuff-Robb/1750/1750_d7_s1'; %'/mnt/eng_research_handata/eng_research_handata2/Kyle/TonePuff-Rebecca/2983/2983_d9_s1'; %'/mnt/HD_6TB/Kyle/CopyProcessing/'; %'/mnt/eng_research_handata/Kyle/MoonaPVLabel/Mouse3311/11232016s1_lastTraining/ProcessedData';
basedir = '/mnt/eng_handata/eng_research_handata2/Kyle_Hansen/TonePuff_Rebecca2/2712/2712_d4_s1';
trace_filename = 'trace_kyleFinal.mat'; %'trace_kyleFinalwDoughnut_AllBGs_matched.mat'; %'trace_ACSAT_Autorun.mat'; % %'Images/MotionCorrected/circleTracesROIsMoonaLabelled.mat'; %Filename in Base Directory
behavior_filename = 'Behavior/SyncedBehavior.mat'; %Behavior in nested Behavior Folder
all_trace_files = findNestedFiles(basedir, trace_filename); %Find all trace file paths
all_behav_files = findNestedFiles(basedir, behavior_filename); %Find all behavior file paths
all_paths = findCommonPaths(all_trace_files, all_behav_files); %Find Intersection of Path Sets
two_diverging_paths = 1; %Use for Loading if trace and behavior filenames in different base paths (Moona's Mice)

% Output Parameters
labelType = [];
imSize = [1024,1024];
chunkSize = [];

% Loop Setup
if two_diverging_paths
    loop_paths = {basedir};
else
    loop_paths = all_paths;
end

for idx = 1:numel(loop_paths)
    %Filename Grabbing/Formatting
    if two_diverging_paths
        f_path = basedir;
    else
        f_path = all_paths{idx};
    end
    
    f_name_split = split(trace_filename, '.');
    f_name = f_name_split{1};
    f_trace = fullfile(f_path, trace_filename);
    f_behavior = fullfile(f_path, behavior_filename);
    f_name_out = fullfile(f_path, strcat(f_name, '_BinaryVideo.hdf5'));
    sprintf(f_path)
    
    %Load Input Structure (Assume named r_out)
    load(f_trace);
    
    %Do Conversion for Trace Structure
    struct2hdf5(r_out, f_name_out, labelType, imSize, chunkSize);
    
    %Load Input Behavior (Assume named binPuffs, binSounds, binTrials)
    load(f_behavior);
    
    %Do Conversion for Behavior & Add to HDF5
    behavior2hdf5(binSounds, binPuffs, binTrials, eye_trace, pupil_trace, f_name_out);
end