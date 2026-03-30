%% Loading vec file
stimulus_frequency = 20; %frames/s
time_before_program_quits_automatically = 3000; %s

n_spot = 25;  % User input number of dh spot (up to 300)

baseDir = 'E:\VisualStim_DMD\data\binvecs\00_DigitalHolography\VEC';
fileName = sprintf('DigitalHolography_20Hz_%dHoloSpots_20rep.vec', n_spot);

YourVecFile = fullfile(baseDir, fileName);
%YourVecFile='E:\VisualStim_DMD\data\binvecs\05_Victor\Vec\Surround_white_disc_delay_DH_25.vec';
tab=load(YourVecFile,'-ascii');


ShutterStim = 10*tab(2:end,4); %TEST mod((1:length(tab(2:end,4))),4);%
MaskStim = 5*tab(2:end,1); %5*(randi(2,[2000 1])-1);%

% % comment this out for synch problems
% ShutterStimNew(1:2:2*length(ShutterStim)-1) = ShutterStim;
% ShutterStimNew(2:2:2*length(ShutterStim)) = ShutterStim;
% 
% MaskStimNew(1:2:2*length(MaskStim)-1) = MaskStim;
% MaskStimNew(2:2:2*length(MaskStim)) = MaskStim;

% ShutterStim = ShutterStimNew;
% MaskStim = MaskStimNew;
% % 


% ShutterStim = 1*(randi(2,[1,1000])-1);0

%SIgnal sent to shutter. Ideally, will be read directly on the vec file
% ShutterStim(1:2:end) = 10; 
% ShutterStim(2:2:end) = 0;


%% Clocked signals
disp('file loaded initializing acq');
s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1','ao0','Voltage');
addAnalogOutputChannel(s,'Dev1','ao1','Voltage');

s.Rate = stimulus_frequency;%Expected rate from clock. Should match the DMD fq

c = addClockConnection(s,'External','Dev1/PFI0','ScanClock');

disp('Queueing...')


tic

queueOutputData(s,[ShutterStim(:) MaskStim(:)]);

%queueOutputData(s,ShutterStim(:));
toc

s.ExternalTriggerTimeout = Inf;%Max number of seconds waiting for the signal to come, change it if DMD takes too much time. 
% dataIn = startForeground(s);
% startForeground(s);
startBackground(s);
disp('GO ')

return

%% Start Trig

ShutterStim = randi(2,[1,1000])-1;%Signal sent to shutter. Ideally, will be read directly on the vec file

daq.getDevices

s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1',3,'Voltage');%Shutter on AO 3

s.Rate = 100;%Acq Frequency

disp('Modifying Timeout...')

s.ExternalTriggerTimeout = 20;%20 s before tmieout, feel free to change it. 

%ADD TRIGGER
disp('Add Trigger...')

addTriggerConnection(s,'External','Dev1/PFI12','StartTrigger')%DMD channel received here on PFI12


disp('Queueing...')
tic
queueOutputData(s,[ShutterStim(:)]);
toc


disp('Stimulating...')
tic
dataIn = s.startForeground;
toc

 