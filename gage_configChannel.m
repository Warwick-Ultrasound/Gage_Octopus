function chan = gage_configChannel(num, varargin)
    % creates a structure with all of the required fields that can be put
    % into the channel structure array. The first input is the cahnnel number, 
    % followed by name argument pairs for any values you want to set. 
    % Otherwise default values are used. 
    %
    % Optional Arguments are (default)
    %     Coupling (DC)
    %     DiffInput (off)
    %     InputRange (20V pk-pk)
    %     Impedance (50 Ohms)
    %     DcOffset (0 mV)
    %     DirectAdc (off)
    %     Filter (off)
    %
    % After this call gage_configure to apply the settings.
    
    % handle name value pairs and assign defaults
    p = inputParser();
    addOptional(p, "Coupling", "DC"); % DC coupling
    addOptional(p, "DiffInput", 0); % off
    addOptional(p, "InputRange", 20E3); % 20V pk-pk
    addOptional(p, "Impedance", 50); % 50 Ohms
    addOptional(p, "DcOffset", 0); % 0mV
    addOptional(p, "DirectAdc", 0); % off
    addOptional(p, "Filter", 0); % off
    parse(p, varargin{:});
    
    chan = p.Results;
    chan.Channel = num;
    chan.Coupling = CsMl_Translate(chan.Coupling, 'Coupling');
    
end