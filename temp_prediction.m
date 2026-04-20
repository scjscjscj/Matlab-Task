function [time_data, temp_data, rate_data, predict_data] = temp_prediction(a, pin_green, pin_yellow, pin_red, sensor_pin, V0C, Tc, duration)
configurePin(a, pin_green, 'digitaloutput');  % Set green LED pin as digital output
configurePin(a, pin_yellow, 'digitaloutput'); % Set yellow LED pin as digital output
configurePin(a, pin_red, 'digitaloutput');    % Set red LED pin as digital output

% Initialize all LEDs to off (low level)
writeDigitalPin(a, pin_green, 0);
writeDigitalPin(a, pin_yellow, 0);
writeDigitalPin(a, pin_red, 0);

window_size = 5;  % Sliding window size for noise reduction (5 samples)
temp_history = [];
time_history = [];
start_time = tic; % Start timing

% Initialize output arrays to store monitoring data
time_data = [];
temp_data = [];
rate_data = [];
predict_data = [];

% Create dual-subplot window for temp & change rate
figure('Color','w', 'Position', [100, 100, 800, 600]);
subplot(2,1,1); 
h_temp = plot(0, 0, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 12);
title('Real-time Temperature & Change Rate (MCP9700A)', 'FontSize', 14);
grid on;
xlim([0, duration]);
ylim([0, 40]);
legend('Temperature', 'Location', 'best');

subplot(2,1,2);
h_rate = plot(0, 0, 'r-*', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Change Rate (°C/min)', 'FontSize', 12);
grid on;
xlim([0, duration]);
ylim([-10, 10]);
legend('Change Rate', 'Location', 'best');

while true
    V_out = readVoltage(a, sensor_pin);  % Read sensor voltage (A1 pin)
    current_temp = (V_out - V0C) / Tc;  % Convert voltage to temperature (MCP9700A formula)
    current_time = toc(start_time);     % Get elapsed time

    % Update sliding window (keep latest N samples for noise reduction)
    temp_history = [temp_history, current_temp];
    time_history = [time_history, current_time];
    if length(temp_history) > window_size
        temp_history(1) = [];
        time_history(1) = [];
    end

    % Calculate temperature change rate (°C/s → °C/min)
    if length(temp_history) >= 2
        delta_T = temp_history(end) - temp_history(1);
        delta_t = time_history(end) - time_history(1);
        rate_Cs = delta_T / delta_t;          % Change rate (°C/s)
        rate_Cmin = rate_Cs * 60;            % Convert to °C/min
    else
        rate_Cs = 0;
        rate_Cmin = 0;
    end
    predict_temp = current_temp + rate_Cs * 300;  % Predict temp in 5 mins (300s)

    % Update data arrays
    time_data = [time_data, current_time];
    temp_data = [temp_data, current_temp];
    rate_data = [rate_data, rate_Cmin];
    predict_data = [predict_data, predict_temp];
    
    % LED alert logic based on change rate (threshold: ±4°C/min)
    if rate_Cmin > 4
        writeDigitalPin(a, pin_green, 0);
        writeDigitalPin(a, pin_yellow, 0);
        writeDigitalPin(a, pin_red, 1);    % Red LED on (temp rising too fast)
    elseif rate_Cmin < -4
        writeDigitalPin(a, pin_green, 0);
        writeDigitalPin(a, pin_yellow, 1); % Yellow LED on (temp dropping too fast)
        writeDigitalPin(a, pin_red, 0);
    else
        writeDigitalPin(a, pin_green, 1);  % Green LED on (stable temp)
        writeDigitalPin(a, pin_yellow, 0);
        writeDigitalPin(a, pin_red, 0);
    end
    
    % Update real-time plots
    set(h_temp, 'XData', time_data, 'YData', temp_data);
    xlim(h_temp.Parent, [0, max(current_time, duration)]);
    ylim(h_temp.Parent, [min(temp_data)-2, max(temp_data)+2]);
    set(h_rate, 'XData', time_data, 'YData', rate_data);
    xlim(h_rate.Parent, [0, max(current_time, duration)]);
    drawnow;
    
    % Print real-time data to console
    fprintf(' %.1fs | Now：%.2f ℃ | rate of change：%.2f ℃/min | 5min Forecast：%.2f ℃\n', ...
        current_time, current_temp, rate_Cmin, predict_temp);

    % Stop loop when reaching set duration
    if current_time >= duration
        disp([' The monitoring duration has reached(', num2str(duration/60), 'min), automatic stop']);
        break;
    end

    pause(1);  % 1s sampling interval
end

% Turn off all LEDs after monitoring
writeDigitalPin(a, pin_green, 0);
writeDigitalPin(a, pin_yellow, 0);
writeDigitalPin(a, pin_red, 0);
disp(' All leds have been turned off and the monitoring has ended normally！');
disp(' Real-time data has been retained and can be viewed through the output parameters');
disp('   - time_data：Sampling time (seconds)');
disp('   - temp_data：Real-time temperature (℃)');
disp('   - rate_data：Real-time rate of change (℃/min)');
disp('   - predict_data：5-minute predicted temperature (℃)');

end