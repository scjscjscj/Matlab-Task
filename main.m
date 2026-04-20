clear; clc; close all;

% Hardware configuration - Arduino & pin definitions
arduino_port = 'COM3';       % Arduino serial port
arduino_board = 'Uno';       % Arduino board model
pin_green = 'D2';            % Green LED digital pin (18-24°C range)
pin_yellow = 'D3';           % Yellow LED digital pin (<18°C)
pin_red = 'D4';              % Red LED digital pin (>24°C)
sensor_pin = 'A1';           % Temperature sensor analog pin

% MCP9700A sensor calibration parameters
V0C = 0.4;                   % Voltage at 0°C (V)
Tc = 0.01953;                % Temperature coefficient (V/°C)
monitor_duration = 600;      % Monitoring duration (10 mins = 600s)

% Clear existing Arduino connection to avoid conflict
if exist('a', 'var')
    clear a;
    disp(' The old Arduino connection has been cleared. ');
end

% Establish Arduino communication (critical for hardware control)
try
    a = arduino(arduino_port, arduino_board);  % Create Arduino communication object
    disp(' The Arduino connection was successful!');
catch ME
    error('Arduino connection failed.');
end

disp([' Start the temperature monitoring system... (Duration: ', num2str(monitor_duration/60), 'min)']);

% Execute temperature prediction function (Task 3 core logic)
try
%    temp_monitor(a, pin_green, pin_yellow, pin_red, sensor_pin, V0C, Tc, monitor_duration);
    temp_prediction(a, pin_green, pin_yellow, pin_red, sensor_pin, V0C, Tc, monitor_duration);
catch ME
    disp([' Monitoring interrupted/error: ', ME.message]);
end

% Cleanup - turn off all LEDs and release Arduino connection
if exist('a', 'var')
    writeDigitalPin(a, pin_green, 0);  % Set pin to low (turn off LED)
    writeDigitalPin(a, pin_yellow, 0);
    writeDigitalPin(a, pin_red, 0);
    clear a;
    disp(' Resource cleanup completed! ');
else
    disp(' There is no valid Arduino connection. No need to clean ');
end