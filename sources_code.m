eeglab

% Load the data and name it 'RAW DATA'
EEG = pop_biosig('PATH\to\raw\data');
EEG.setname='EEG RAW DATA';
EEG = eeg_checkset( EEG );

% Select the channels
EEG = pop_select( EEG,'channel',{'Fp1' 'Fp2' 'F3' 'F4' 'C3' 'C4' 'P3' 'P4' 'O1' 'O2' 'F7' 'F8' 'T3' 'T4' 'T5' 'T6' 'Fz' 'Cz' 'Pz' 'A1' 'A2'});
EEG.setname='EEG RAW DATA CHANNEL SELECTED';
EEG = eeg_checkset( EEG );

%save into EDF file type
pop_writeeeg(EEG, 'PATH\to\save', 'TYPE','EDF');

% Insert channels location
EEG=pop_chanedit(EEG, 'lookup','PATH\to\channel\location');
EEG = eeg_checkset( EEG );
    
% Rereference the signal to the average of all the channels
EEG = pop_reref( EEG, []);
EEG = eeg_checkset( EEG );

% Apply low pass filter between 5-15 Hz
EEG = pop_eegfiltnew(EEG, 'locutoff',5,'hicutoff',15,'plotfreqz',1);
EEG = eeg_checkset( EEG );

% Apply PCA using SVD and makes the variance of the signal 1
[pc, eigvec, sv] = runpca(EEG.data);
pc = pc/sqrt(sv)

% Apply ICA 100 times with random initialization on the weight matrix
ICAsso = icassoEst('randinit', pc, 100);
ICAsso = icassoExp(ICAsso);
[Iq, A, W, S]=icassoResult(ICAsso);

% Update the variables into EEGLAB
EEG.icaweights = W;
EEG.icasphere = eye(size(EEG.data,1));
EEG.icawinv = A;
EEG = eeg_checkset( EEG );  
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw

% Plot Topoplot of ICA weights
a = figure('Position', get(0, 'Screensize'))
for i = 1:size(S)
    subplot(5,5,i);
    topoplot(W(i,:), loc, 'style', 'both', 'electrodes', 'on'); % plot peta komponen
    colorbar
    title(num2str(i));
end

% ICA Visualization
icassoShow(ICAsso)