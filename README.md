# Gage_Octopus
A MATLAB wrapper library for the Gage octopus - A PC with an 8 channel oscilloscope card.

## gage_example
An example script of how to use this wrapper library. 

## gage_connect
Connects to the card and returns the handle for the device. The second output argument is the system info struct that is returned by the driver.

## gage_contructAcq
In order to configure the acquisition (timebase, sample rate and mode etc) you need a struct to pass to the driver. This function makes the struct for you so that you can use useful parameters like acquisition time rather than number of samples, and you don't have to worry about configuring buffer memory and so on. The input is a struct with the following fields:
- SampleRate: the sampling frequency in Hz
- Start: The time in seconds between a trigger event and the start of data acquisition
- Stop: The time in seconds between a trigger event and the end of data acquisition
- Avgs: The number of averages to accumulate on each channel
- Timeout: The trigger timeout period in seconds
It returns Acq, which is the struct that is passed to the driver.

## gage_configChannel(num, name-value)
This function creates a struct which defines the channel parameters. You need one of these for each channel you want to use and they should be constructed into a struct array before being passed to the driver. The first input is the channel number, and the name-value pairs set the parameters you need. Any name value pairs which are not assigned will take the default values in brackets below:
- Coupling (DC): a string, either "DC" or "AC"
- DiffInput (off): boolean which determines whether the input is differential or not
- InputRange (20V pk-pk): the input range specified in mV (peak to peak)
- Impedance (50 Ohms): The input impedance in Ohms
- DcOffset (0 mV): add a DC offset here in mV
- DirectAdc (off): if boolean 1, signal goes straight into the ADC (no terminating resistor)
- Filter (off): see documentation, not availible on our unit
It returns Chan - one element of the channel array which is passed to the driver. Suggested usage is "Chan(1) = gage_configChannel(1, "InputRange", 2000);" and so on for any other channels you want to enable.

## [Acq, Chan, Trig] = gage_configure(handle, name-value)
This is the function which takes all of your settings and configures the card accordingly. Default values are available (see function definition for what these are) if you don't set one of the structs. The first input must be the device handle, then the following name-value pairs can be passed to configure the card:
- Acq: The struct created by gage_constructAcq.
- Chan: The array of structures created by repeated calls of gage_configChannel (or just a struct if only one channel is to be enabled).
- Trig: A stuct defining the trigger configuration with arguments:
  - Trigger: Trigger engine number, starting at 1. Use this if you want to create multiple trigger conditions by creating a struct array with multiple trigger engines.
  - Slope: "Positive" or "Negative". Set using e.g. CsMl_Translate('Positive', 'Slope').
  - Level: Trigger level as a % of max range of that channel, in the interval [-100,100].
  - Source: A number to specify a channel, or "External" to use the dedicated trigger channel.
  - ExtCoupling: "DC" or "AC" to specify the coupling of the dedicated trigger channel. Set using e.g. CsMl_Translate('DC', 'Coupling').
  - ExtRange: The range (pk-pk) of the dedicated trigger channel.
The function returns these three structs back to you so that if you left any to default then you still have access to all of the parameters within.

## [AcqInfo, ChanInfo, TrigInfo, SysInfo] = gage_getCurrentSettings(handle);
Gets the current configuration of the card. Note that these structs are NOT the same as Acq and Chan, they have more fields and cannot be passed in to configure the card. Use this function when you would usually look at the scope screen to determine settings like the acquisition rate etc.

## [data, time] = gage_acquire(handle, Chan)
Acquires data on the card then manages the transfer and sorts out averaging and timebase generation. The inputs are the device handle and the channel struct array, and the outputs are a cell array containing voltages and the time array. The data cell array has the same number of cells as the number of enabled channels and is populated in the same order as Chan. If you need to see this order use \[Chan.Channel] to get an array of the channel numbers in the correct order.

## handle = gage_close(handle)
Closes the connection to the card and sets the value of handle to an empty array to confirm. Note that this must be done before attempting to open another connection to the scope.
