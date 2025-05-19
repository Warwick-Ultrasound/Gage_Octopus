function [Acq, Chan, Trig, SysInfo] = gage_getCurrentSettings(handle)
    % Retrives the current acquistion, channel and trigger settings from
    % the card, along with the system information. Note that the structs
    % returned by the card using this function contain different fields
    % than those used to set the configuration of the card so they should
    % be used for information only unless you know what you're doing.
    
    [ret, SysInfo] = CsMl_GetSystemInfo(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    
    for ii = SysInfo.ChannelCount:-1:1
        [ret, Chan(ii)] = CsMl_QueryChannel(handle, ii);
        CsMl_ErrorHandler(ret, 1, handle);
    end
    
    [ret, Acq] = CsMl_QueryAcquisition(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    
    for ii = SysInfo.TriggerCount:-1:1
        [ret, Trig(ii)] = CsMl_QueryTrigger(handle, ii);
        CsMl_ErrorHandler(ret, 1, handle);
    end
end