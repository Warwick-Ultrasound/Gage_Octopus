function handle =  gage_close(handle)
    % closes the connection to the card
    CsMl_FreeSystem(handle);
    handle = [];
end