function [ALLEEG, EEG, CURRENTSET] = CREx_EEGPreprocessing_segement_v2(EEG, ALLEEG,CURRENTSET, trigfile_path,bline_lim,tosegment,...
    blcorrect)
%% Date: 08-04-2019    Programmed by: D. Bolger
% Function to segment continuous data.
% The function allows you to load the data to be segmented manually.
% Input: Trigfile_path ==> path to configuration structure resuming the trigger names and
% codes.
%**************************************************************************

%% GET THE TRIGGER NAMES

cfgin = load(trigfile_path);
fn = fieldnames(cfgin);
cfg = cfgin.(genvarname(fn{1,1}));

Conds_all = cfg.condgroups;    %each column corresponds to a group.
Group_all = cfg.groupnames;
Conds_all = reshape(Conds_all,[cfg.condnum_all 1]);
assignin('base','Conds_all',Conds_all)


%% SEGMENT THE DATA

%dir_save = '/Users/bolger/Documents/work/Projects/Project-L2-SentenceProc/';
dir_save = cfg.saveepoched;

if strcmp(tosegment,'allconds') && size(EEG.data,3)==1
    
    
    time_lim = inputdlg({'Enter trial upper limit (s)','Enter baseline upper limit (s)','Enter baseline lower limit (s)'},'Enter time limits',...
        [1 50;1 50;1 50]);
    lim_upper = str2double(time_lim{1,1});
    limbl_low = str2double(time_lim{3,1});
    limbl_up_upper = str2double(time_lim{2,1});
    assignin('base','limbl_low',limbl_low);
    assignin('base','limbl_upper',lim_upper);
    
    
    for counter = 1:length(ALLEEG)
        
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',counter,'study',0);
        EEG = eeg_checkset( EEG );
        eeglab redraw
        
        allconds_name = strcat(ALLEEG(counter).setname(1:8),'-allconds');
        EEG = pop_epoch(EEG,Conds_all, [limbl_low lim_upper], 'newname', char(allconds_name), 'epochinfo', 'yes');
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(allconds_name),'gui','off');
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',char(allconds_name),'filepath',dir_save);
        EEG = eeg_checkset( EEG );
        eeglab redraw;
        
        if strcmp(blcorrect,'yes')
            baseline_low = bline_lim(1)*1000;  % Change here to change baseline to use for correction.
            baseline_hi = bline_lim(2) ;
            disp('--------------------Baseline correction-----------------------------------');
            Enom_bl=strcat(allconds_name,'-bl');
            EEG = pop_rmbase( EEG, [baseline_low baseline_hi]);
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(Enom_bl),'gui','off');
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG, 'filename',char(Enom_bl),'filepath',dir_save);
            EEG = eeg_checkset( EEG );
            eeglab redraw
        end
    end
    
elseif strcmp(tosegment,'singleconds') && size(EEG.data,3)==1 %segmenting continuous data
    
    if length(cfg.condnames)>cfg.condnum
        Conds_all = cfg.condnames';
    end
    assignin('base','Conds_all',Conds_all)
 
    ln = listdlg('PromptString','Select one or several conditions','SelectionMode','multiple','ListString',Conds_all);
    assignin('base','ln',ln)
    conds2seg = Conds_all(ln,1);
    time_lim = inputdlg({'Enter trial upper limit (s)','Enter baseline upper limit (s)','Enter baseline lower limit (s)'},'Enter time limits',...
        [1 50;1 50;1 50]);
    lim_upper = str2double(time_lim{1,1});
    limbl_low = str2double(time_lim{3,1});
    limbl_upper = str2double(time_lim{2,1});
    
    for condcnt = 1:length(conds2seg)
        condcnt
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',1,'study',0);
        EEG = eeg_checkset( EEG );
        eeglab redraw
        
        %i = find(strcmp(event_curr,cond2seg{condcnt,1}));
        condcurr_name = strcat(ALLEEG(1).setname(1:7),conds2seg{condcnt,1});
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
    
    
elseif strcmp(tosegment,'singleconds') && size(EEG.data,3)>1
    
    
    ln = listdlg('PromptString','Select one or several conditions','SelectionMode','multiple','ListString',Conds_all);
    conds2seg = Conds_all(ln,1);
    assignin('base','conds2seg',conds2seg);
    
    for  counter = 1:length(ALLEEG)
        for condcnt = 1:length(conds2seg)
            
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',counter,'study',0);
            EEG = eeg_checkset( EEG );
            eeglab redraw
            
            indx = zeros(length(EEG.epoch),1);
            
            for icnt = 1:length(EEG.epoch)   %find only the events that correspond to T0
                x = [cell2mat(EEG.epoch(icnt).eventlatency) ==0];
                if strcmp(EEG.epoch(icnt).eventtype(x),conds2seg{condcnt,1})
                    indx(icnt) = EEG.epoch(icnt).event(x);
                end
            end
            
            event_curr = {EEG.event(indx(indx>0)).type};
            
            condcurr_name = strcat(ALLEEG(counter).setname(1:8),conds2seg{condcnt,1});
            EEG = pop_selectevent( EEG, 'event',indx(indx>0),'deleteevents','on','deleteepochs','on','invertepochs','off');
            
            EEG.setname=condcurr_name;
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',char(condcurr_name),'gui','off');
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG, 'filename',char(condcurr_name),'filepath',dir_save);
            EEG = eeg_checkset( EEG );
            eeglab redraw;
            
        end
    end        %end of ALLEEG loop
    
    
end

