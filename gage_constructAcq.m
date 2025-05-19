function Acq = gage_constructAcq(handyAcq)
    % the acquisition struct that must be sent to the card doesn't have
    % practically useful units like time, but works in samples. This
    % function helps you make that struct by inputting useful parameters
    % like the number of averages, sample length etc.
    %
    % The input to this fucntion, handyacq, must have fields:
    %   SampleRate: sample rate in Hz
    %   Start: time (s) between trigger and start of acquisition
    %   Stop: time (s) between trigger and acquisition end
    %   Avgs: number of averages
    %   Timeout: Trigger Timeout (s)
    
    if handyAcq.SampleRate > 25E6
        handyAcq.SampleRate = 25E6;
        warning('Sample rate too high, set to maximum (25MHz).');
    end
    
    Acq.SampleRate = handyAcq.SampleRate;
    Acq.ExtClock = 0;
    Acq.Mode = CsMl_Translate("Octal", 'Mode');
    Acq.SegmentCount = handyAcq.Avgs;
    Acq.TriggerTimeout = floor(handyAcq.Timeout/1E-6);
    Acq.TriggerHoldoff = 0;
    Acq.TriggerDelay = floor(handyAcq.Start*Acq.SampleRate);
    Acq.Depth = ceil(handyAcq.Stop*Acq.SampleRate) - Acq.TriggerDelay;
    Acq.SegmentSize = Acq.Depth;
    Acq.TimeStampConfig = 0;
end
    
    