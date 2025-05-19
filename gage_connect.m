function [h, sysinfo] = gage_connect()
    % a wrapper function to enable easy connection to the board with error
    % handling. Returns the handle to the device for passing to other
    % functions, and the sysinfo stuct.
    
    systems = CsMl_Initialize;
    CsMl_ErrorHandler(systems);
    
    [ret, h] = CsMl_GetSystem;
    CsMl_ErrorHandler(ret);
    
    [ret, sysinfo] = CsMl_GetSystemInfo(h);
    CsMl_ErrorHandler(ret);
    
    Setup(h);
end