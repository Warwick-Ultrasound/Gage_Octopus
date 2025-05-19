function [out, time] = gage_acquire(handle, Chan)
    % Use this function to acquire the data and send it from the card to
    % the PC. The second argument, Chan, is the structure you use to set
    % the channel configurations.
    
    % Perform acquisition and wait for it to complete
    ret = CsMl_Capture(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    status = CsMl_QueryStatus(handle);
    while status ~= 0
        status = CsMl_QueryStatus(handle);
    end
    
    % get acquisition info
    acqInfo = gage_getCurrentSettings(handle);
    
    % Get timestamp information
    transfer.Channel = 1;
    transfer.Mode = CsMl_Translate('TimeStamp', 'TxMode');
    transfer.Length = acqInfo.SegmentCount;
    transfer.Segment = 1; 
    transfer.Mode = CsMl_Translate('Default', 'TxMode');
    transfer.Start = -acqInfo.TriggerHoldoff;
    transfer.Length = acqInfo.SegmentSize;
    
    % cycle through active channels transfering the data
    channels = [Chan.Channel]; % extract channel numbers
    out = cell(size(channels)); % averaged output data
    for cc = 1:length(channels)
        
        transfer.Channel = channels(cc);
        data = cell(acqInfo.SegmentCount);
        for ii = 1:acqInfo.SegmentCount % cycle through segments - each of these is a single-shot trace
            
            %transfer
            transfer.Segment = ii;
            [ret, data{ii}, actual] = CsMl_Transfer(handle, transfer);
            CsMl_ErrorHandler(ret, 1, handle);
            
            % adjust size to ensure that only the length of acquisition is
            % saved
            len = size(data{ii}, 2);
            if len > actual.ActualLength
                data{ii}(actual.ActualLength:end) = [];
            end     
        end
        
        % check all records are the same length
        minlen = 0;
        maxlen = inf;
        for ii = 1:length(data)
            if length(data{ii})>minlen
                minlen = length(data{ii});
            elseif length(data)<maxlen
                maxlen = length(data{ii});
            end
        end
        
        % if one is shorter, crop them all
        if minlen<maxlen
           for ii = 1:length(data)
               data{ii} = data{ii}(1:minlen);
           end
        end
        
        % perform averaging
        out{cc} = zeros(size(data{1}));
        for ii = 1:length(data)
            out{cc} = out{cc} + data{ii};
        end
    end % end data transfer
    
    % construct time array
    tStart = actual.ActualStart/acqInfo.SampleRate;
    tStop = (actual.ActualStart + actual.ActualLength)/acqInfo.SampleRate;
    time = linspace(tStart, tStop, length(data{1}));
    
end