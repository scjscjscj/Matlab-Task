%% PRELIMINARY TASK:
clear; clc; close all;

arduinoPort = 'COM3';       
arduinoBoard = 'Uno';       
try
    a = arduino;            % Create Arduino communication object
    disp('The Arduino connection was successful!');
catch ME
    error('Arduino connection failed.');
end
ledPin = 'D12';             % LED digital pin (flashing test)
blinkCount = 10;            
disp(['Start flashing LED，A total of ', num2str(blinkCount), ' times.']);

for i = 1:blinkCount
    writeDigitalPin(a, ledPin, 1);  % Turn on LED (high level)
    pause(0.5);                    

    writeDigitalPin(a, ledPin, 0);  % Turn off LED (low level)
    pause(0.5);                    
end
clear a;                     
disp('The flashing is complete. The Arduino connection has been closed!');


%%
%Task 1:
duration = 600;              
sample_interval = 1;         
sensor_pin = 'A1';           % Temperature sensor analog pin (MCP9700A)
arduino_port = 'COM3';       
arduino_board = 'Uno';       
V_0C = 0.4;                  % MCP9700A voltage at 0°C (V)
T_C = 0.01953;               % MCP9700A temp coefficient (V/°C)

try
    a = arduino(arduino_port, arduino_board);  
disp(' The Arduino connection was successful!');
catch ME
    error('Arduino connection failed.');
end

num_samples = duration / sample_interval;  
time_vec = 0:sample_interval:duration-sample_interval;  
temp_vec = zeros(1, num_samples);          

disp([' Start collecting. ', num2str(duration/60), 'min temperature data']);
for i = 1:num_samples
    V_out = readVoltage(a, sensor_pin);    % Read sensor voltage
    temp_vec(i) = (V_out - V_0C) / T_C;    % Convert voltage to temperature
    pause(sample_interval);                
end
disp(' Data collection completed! ');
max_temp = max(temp_vec);    
min_temp = min(temp_vec);    
avg_temp = mean(temp_vec);   

figure('Color','w');
plot(time_vec/60, temp_vec, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Time (minutes)', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 12);
title(['Temperature vs. Time (', num2str(duration/60), ' minutes)'], 'FontSize', 14);
grid on;
saveas(gcf, 'temperature_plot.png');  % Save temperature curve to file
disp(' The temperature curve has been saved as temperature_plot.png');

current_date = datestr(now, 'dd/mm/yyyy');  
location = 'Nottingham';                    

fprintf('Data logging initiated - %s\n', current_date);
fprintf('Location - %s\n\n', location);
max_minute = ceil(duration/60);
for minute = 0:max_minute
    idx = minute * 60 + 1;                  
    if idx > num_samples
        temp_val = temp_vec(end);           
    else
        temp_val = temp_vec(idx);           
    end
    fprintf('Minute\t\t%d\n', minute);
    fprintf('Temperature\t%.2f C\n\n', temp_val);
end
fprintf('Max temp\t%.2f C\n', max_temp);
fprintf('Min temp\t%.2f C\n', min_temp);
fprintf('Average temp\t%.2f C\n\n', avg_temp);
fprintf('Data logging terminated\n');

fid = fopen('capsule_temperature.txt', 'w');  % Open log file (write mode)
if fid == -1
    error(' The log file cannot be created!');
end

fprintf(fid, 'Data logging initiated - %s\n', current_date);
fprintf(fid, 'Location - %s\n\n', location);

for minute = 0:max_minute
    idx = minute * 60 + 1;
    if idx > num_samples
        temp_val = temp_vec(end);
    else
        temp_val = temp_vec(idx);
    end
    fprintf(fid, 'Minute\t\t%d\n', minute);
    fprintf(fid, 'Temperature\t%.2f C\n\n', temp_val);
end

fprintf(fid, 'Max temp\t%.2f C\n', max_temp);
fprintf(fid, 'Min temp\t%.2f C\n', min_temp);
fprintf(fid, 'Average temp\t%.2f C\n\n', avg_temp);
fprintf(fid, 'Data logging terminated\n');

fclose(fid);  % Close log file (save data)
disp(' The log has been written capsule_temperature.txt');

clear a;      
disp(' The Arduino connection has been closed!');