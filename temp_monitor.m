function temp_monitor(a, pin_green, pin_yellow, pin_red, sensor_pin, V0C, Tc, duration)

configurePin(a, pin_green, 'digitaloutput');  % Set green LED pin as digital output
configurePin(a, pin_yellow, 'digitaloutput'); % Set yellow LED pin as digital output
configurePin(a, pin_red, 'digitaloutput');    % Set red LED pin as digital output

% Initialize all LEDs to off (low level)
writeDigitalPin(a, pin_green, 0);
writeDigitalPin(a, pin_yellow, 0);
writeDigitalPin(a, pin_red, 0);

% Create real-time plot window
figure('Color','w', 'Position', [100, 100, 800, 500]);
h_plot = plot(0, 0, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 12);
title(['Real-time Temperature Monitoring (MCP9700A) - ', num2str(duration/60), 'minute'], 'FontSize', 14);
grid on;
xlim([0, duration]);
ylim([0, 40]);
legend('Temperature', 'Location', 'best');
time_list = [];  % Store time data for plot
temp_list = [];  % Store temperature data for plot
start_time = tic; % Start timing

while true
    V_out = readVoltage(a, sensor_pin);  % Read sensor output voltage (A1 pin)
    temp = (V_out - V0C) / Tc;          % Convert voltage to temperature (MCP9700A formula)
    current_time = toc(start_time);     % Get elapsed time
    time_list = [time_list, current_time];
    temp_list = [temp_list, temp];
    
    % Update real-time plot data and refresh
    set(h_plot, 'XData', time_list, 'YData', temp_list);
    xlim([0, max(current_time, duration)]);
    ylim([min(temp_list)-2, max(temp_list)+2]); 
    drawnow;
    
    % LED control logic based on temperature range
    if temp >= 18 && temp <= 24
        writeDigitalPin(a, pin_green, 1);  % Green LED on (comfort range: 18-24°C)
        writeDigitalPin(a, pin_yellow, 0);
        writeDigitalPin(a, pin_red, 0);
        pause(1); 
        
    elseif temp < 18
        writeDigitalPin(a, pin_green, 0);
        writeDigitalPin(a, pin_red, 0);
        
        writeDigitalPin(a, pin_yellow, 1); % Yellow LED blink (0.5s on/off)
        pause(0.5);
        writeDigitalPin(a, pin_yellow, 0);
        pause(0.5);
        
    else
        writeDigitalPin(a, pin_green, 0);
        writeDigitalPin(a, pin_yellow, 0);
        
        writeDigitalPin(a, pin_red, 1);    % Red LED blink (0.25s on/off)
        pause(0.25);
        writeDigitalPin(a, pin_red, 0);
        pause(0.25);
    end
    
    % Stop monitoring when reaching set duration
    if current_time >= duration
        disp([' The monitoring duration has reached（', num2str(duration/60), 'minutes）,Stop automatically. ']);
        break;
    end
    fprintf(' %.1fs | temperature: %.2f ℃\n', current_time, temp);
end
% Turn off all LEDs after monitoring ends
writeDigitalPin(a, pin_green, 0);
writeDigitalPin(a, pin_yellow, 0);
writeDigitalPin(a, pin_red, 0);
disp('All leds have been turned off and the monitoring has ended normally!');
end