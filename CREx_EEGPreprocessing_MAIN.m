%% CREx_EEGPreprocessing_MAIN

%% SETUP CONFIGURATION STRUCTURE TO CONTAIN TRIGGER INFORMATION FOR CURRENT STUDY
DIRmain = fullfile(filesep,'Volumes','deepassport','Projects','projet-MotInterbis','JugeSon','JugeSon_Processing',filesep);
%DIRmain = fullfile(filesep,'Users','bolger','Documents','work','Projects','ACE_data',filesep);
Tcfg = JugePhon_make_trigstruct(DIRmain); 

%Tcfg = ACE_make_trigstruct(DIRmain);
%% CALL OF FUNCTION TO CARRY OUT EEG PREPROCESSING PIPELINE

paramfile_nom = 'JugeSon_parameters.txt';      %Name of parameters file
paramfile_path = fullfile(filesep,'Volumes','deepassport','Projects','projet-MotInterbis','JugeSon','JugeSon_Processing',paramfile_nom);   %full path to parameters file.
condoi = 'DYS';

bline = CREx_EEGPreprocessing_pipeline_simple(paramfile_path, Tcfg,condoi);        %Function call

%% CALL OF FUNCTION TO REJECT BAD ELECTRODES

CREx_RejBadChans();

%% CALL OF FUNCTION TO CARRY OUT ICA ON CONTINUOUS DATA

CREx_ICA_calc();

%% MARK THOSE TRIALS THAT ARE INCORRECT OR WHOSE RESPONSE > 2.5seconds
global EEG ALLEEG CURRENTSET

JugePhon_exclude_badtrials(ALLEEG, EEG,CURRENTSET)

%% CALL OF FUNCTION TO SEGMENT THE CONTINUOUS DATA

%trigfile_path = fullfile(filesep,'Users','bolger','Documents','work','Projects','ACE_data','ACEtrigger_info.mat');
trigfile_path = fullfile(filesep,'Volumes','deepassport','Projects','projet-MotInterbis','JugeSon',...
    'JugeSon_Preprocessing','Jugeson_trigger_info.mat');
toseg = 'allconds';   %or 'singleconds' or 'allconds'
bl_correct = 'no';
if ~exist('bline','var')
    bline = [-0.2 0];
end

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_loadset();

[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(EEG.setname),'gui','off'); % current set = xx;
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',char(EEG.setname),'filepath',EEG.filepath); 
eeglab redraw


CREx_EEGPreprocessing_segement_v2(EEG, ALLEEG,CURRENTSET, trigfile_path, bline,toseg,bl_correct);

%% Section to segment several subjects at once. 

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_loadset();

[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(EEG.setname),'gui','off'); % current set = xx;
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',char(EEG.setname),'filepath',EEG.filepath); 
eeglab redraw

trigfile_path = fullfile(filesep,'Volumes','deepassport','Projects','projet-MotInterbis','JugePhoneme',...
    'JugePhoneme_Preprocessing','Jugephon_trigger_info.mat');
cfgin = load(trigfile_path);
fn = fieldnames(cfgin);
cfg = cfgin.(genvarname(fn{1,1}));

Conds_all = cfg.condgroups;    %each column corresponds to a group.
Group_all = cfg.groupnames;
Conds_all = reshape(Conds_all,[cfg.condnum_all 1]);

limbl_low = -0.2;
lim_upper = 0.8;
limbl_upper = 0;
bline_lim = [limbl_low limbl_upper];
blcorrect = 'no';

dir_save = '/Volumes/deepassport/Projects/projet-MotInterbis/JugePhoneme/JugePhoneme_Preprocessing/ProcessedData/NOL/';

ln = listdlg('PromptString','Select one or several conditions','SelectionMode','multiple','ListString',Conds_all);
assignin('base','ln',ln)
conds2seg = Conds_all(ln,1);

for eegcnt = 1:length(ALLEEG)

    for condcnt = 1:length(conds2seg)
       
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',eegcnt,'study',0);
        EEG = eeg_checkset( EEG );
        eeglab redraw
        
        disp(EEG.setname)
        %i = find(strcmp(event_curr,cond2seg{condcnt,1}));
        condcurr_name = strcat(EEG.setname(1:7),conds2seg{condcnt,1});
        EEG = pop_epoch( EEG, {conds2seg{condcnt,1}}, [limbl_low lim_upper], 'newname', char(condcurr_name), 'epochinfo', 'yes');
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(condcurr_name),'gui','off');
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',char(condcurr_name),'filepath',dir_save);
        EEG = eeg_checkset( EEG );
        eeglab redraw;
        
        if strcmp(blcorrect,'yes')
            
            baseline_low = bline_lim(1)*1000;  % Change here to change baseline to use for correction.
            baseline_hi = bline_lim(2) ;
            disp('--------------------Baseline correction-----------------------------------');
            Enom_bl=strcat(condcurr_name,'-bl');
            EEGbl = pop_rmbase( EEG, [baseline_low baseline_hi]);
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(Enom_bl),'gui','off');
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG, 'filename',char(Enom_bl),'filepath',dir_save);
            EEG = eeg_checkset( EEG );
            eeglab redraw
        end
        
        
    end
end
%% Baseline Correct Only

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_loadset();

[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(EEG.setname),'gui','off'); % current set = xx;
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',char(EEG.setname),'filepath',EEG.filepath); 
eeglab redraw


limbl_low = -0.05;
lim_upper = 0.8;
limbl_upper = 0;
bline_lim = [limbl_low limbl_upper];

dir_save = '/Users/bolger/Desktop/JudgeSon/Baseline50ms/DYS/';

for eegcnt = 1:length(ALLEEG)
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',eegcnt,'study',0);
    EEG = eeg_checkset( EEG );
    eeglab redraw
    
    condcurr_name = EEG.setname;
    baseline_low = bline_lim(1)*1000;  % Change here to change baseline to use for correction.
    baseline_hi = bline_lim(2) ;
    disp('--------------------Baseline correction-----------------------------------');
    Enom_bl=strcat(condcurr_name,'-bl');
    EEGbl = pop_rmbase( EEG, [baseline_low baseline_hi]);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(Enom_bl),'gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',char(Enom_bl),'filepath',dir_save);
    EEG = eeg_checkset( EEG );
    eeglab redraw
    
end

%% RUN FUNCTION TO LOCATE BAD EPOCHS AND CHANNELS VISUALLY.
% This works best on segmented data but can also work on continuous also,
% but can be very slow

EpochChan_dlg(EEG); 