function [Acq, Chan, Trig] = gage_configure(handle, varargin)
    % allows configuration of the channels, trigger and timebase with a
    % single function call. The only required input is the device handle,
    % and optional additional arguments can be defined for the acquisition
    % parameters, channel settings and trigger configuration.
    %
    % Acq: A struct with fields
    %   SampleRate: sampling rate in Hz
    %   ExtClock: a flag which enables external clocking (0 = off)
    %   Mode: A flag for single, dual, quad or octal mode. Use
    %       CsMl_Translate('[Mode]', 'Mode') to set this flag.
    %   SegmentCount: The number of segments to be acquired (?)
    %   Depth: The post trigger depth of acquisition
    %   SegmentSize: The size of memory allocated for the segment
    %   TriggerTimeout: The trigger timeout value (us)
    %   TriggerDelay: the trigger delay value (samples)
    %   TriggerHoldoff: Number of samples after a trigger event to ignore
    %       additional trigger events. Useful if you need pre-trigger data.
    %   TimeStampConfig: Flag, if nonzero, resets the timestamp counter
    %       when acquisition begins.
    %
    % Chan: A struct array, one element for each channel, with fields
    %   Channel: The channel number starting with 1
    %   Coupling: Select AC or DC coupling using e.g. CsMl_Translate('DC', 'Coupling')
    %   DiffInput: Flag, if nonzero, sets the channel to differential
    %       coupling if available
    %   InputRange: The y scale range for the channel (mv). Uses full scale
    %       so +/-100mV would require an input of 200.
    %   Impedance: The channel terminating impedance in Ohms.
    %   DcOffset: Offset the DC channel before acquisition (mV)
    %   DirectAdc: Flag, if nonzero, sets channel to direct-to-ADC input
    %   coupling, if available.
    %
    % Trig: A struct or array of stuctures (one for each trigger, usually just want one)
    %   Trigger: Trigger engine numbe, starting with 1
    %   Slope: Trigger slope (positive=rising, negative=falling), use e.g. CsMl_Translate('Positive', 'Slope')
    %   Level: The trigger level as a percentage [-100,100] of the iptut
    %       channel range
    %   Source: The channel number the trigger is applied to (or External
    %   for the dedicated channel)
    %   ExtCoupling: Input coupling (AC or DC) of the external trigger channel
    %   ExtRange: The input range for the external trigger
    %
    % returns those structs back so that if default values are used the
    % structs can still be passed to other functions.
    
    % get system info and handle any errors
    [ret, sysinfo] = CsMl_GetSystemInfo(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    
    % default values of structs:
    dAcq.SampleRate = 10000000;
    dAcq.ExtClock = 0;
    dAcq.Mode = CsMl_Translate('Octal', 'Mode');
    dAcq.SegmentCount = 5;
    dAcq.Depth = 8160;
    dAcq.SegmentSize = 8160;
    dAcq.TriggerTimeout = 10000000;
    dAcq.TriggerHoldoff = 0;
    dAcq.TriggerDelay = 0;
    dAcq.TimeStampConfig = 0;
    for i = sysinfo.ChannelCount:-1:1
        dChan(i).Channel = i;
        dChan(i).Coupling = CsMl_Translate('DC', 'Coupling');
        dChan(i).DiffInput = 0;
        dChan(i).InputRange = 2000;
        dChan(i).Impedance = 50;
        dChan(i).DcOffset = 0;
        dChan(i).DirectAdc = 0;
        dChan(i).Filter = 0;
    end
    dTrig.Trigger = 1;
    dTrig.Slope = CsMl_Translate('Positive', 'Slope');
    dTrig.Level = 0;
    dTrig.Source = 1;
    dTrig.ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
    dTrig.ExtRange = 2000;
    
    % handle name value pairs
    p = inputParser();
    addOptional(p, "Acq", dAcq);
    addOptional(p, "Chan", dChan);
    addOptional(p, "Trig", dTrig);
    parse(p, varargin{:});
    Acq = p.Results.Acq;
    Chan = p.Results.Chan;
    Trig = p.Results.Trig;
    
    % configure acquisition and handle any errors
    [ret] = CsMl_ConfigureAcquisition(handle, Acq);
    CsMl_ErrorHandler(ret, 1, handle);
    
    % set channel info and handle errors
    [ret] = CsMl_ConfigureChannel(handle, Chan);
    CsMl_ErrorHandler(ret, 1, handle);
    
    % set trigger config and handle errors
    [ret] = CsMl_ConfigureTrigger(handle, Trig);
    CsMl_ErrorHandler(ret, 1, handle);
    
    % commit the changes to the card
    ret = CsMl_Commit(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    
end