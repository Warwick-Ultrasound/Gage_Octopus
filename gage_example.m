clear;
clc;
close all;

% connect to card
[handle,sysinfo] = gage_connect();

% configure acquisition parameters
ha.SampleRate = 25E6;
ha.Start = 10E-6;
ha.Stop = 200E-6;
ha.Avgs = 1;
ha.Timeout = 100E-6;
Acq = gage_constructAcq(ha);
    
% configure trigger
Trig.Trigger = 1;
Trig.Slope = CsMl_Translate('Positive', 'Slope');
Trig.Level = 50;
Trig.Source = "External";
Trig.ExtCoupling = CsMl_Translate('DC', 'Coupling');
Trig.ExtRange = 20E3;

% configure channels - any you specify here will be acquired, others are
% ignored
Chan(1) = gage_configChannel(1, "InputRange", 2000);

% apply configuration settings and retreive info from scope
[Acq, Chan, Trig] = gage_configure(handle, 'Acq', Acq, 'Trig', Trig, 'Chan', Chan);
[AcqInfo, ChanInfo, TrigInfo, SysInfo] = gage_getCurrentSettings(handle);

[data, time] = gage_acquire(handle, Chan);
handle = gage_close(handle);

for ii = 1:length(data)
    
    figure;
    sig = data{ii};
    SIG = fftshift(fft(sig));
    fs = 1/(time(2)-time(1));
    freq = linspace(-fs/2, fs/2, length(SIG));
    plot(freq/1E6, abs(SIG), 'rx'); 
    %xlim([0, 2]);
    title(Chan(ii).Channel);
    
    figure;
    plot(time/1E-6, data{ii});
    title(Chan(ii).Channel);
end