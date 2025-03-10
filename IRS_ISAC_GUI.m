function IRS_ISAC_GUI()
    % IRS_ISAC_GUI: Creates a GUI for simulating IRS-ISAC system performance without graphical simulation.

    % Create UI figure
    fig = uifigure('Name', 'IRS-ISAC System Simulator', 'Position', [100, 100, 800, 400]); % Reduced figure height as no metrics panel

    % Create UI components (dropdowns, buttons, displays, and system blocks)
    [channelModeDropDown, protocolDropDown, networkTypeDropDown, algorithmDropDown, ...
     runSimulationButton, stopButton, saveToExcelButton, ... % Removed metricsPanel and saveToExcelButton from output
     dataRateDisplay, delayTimeDisplay, efficiencyDisplay, throughputDisplay, ...
     BERDisplay, packetLossDisplay, SNRDisplay, iterationDisplay] = createUIComponents(fig); % Removed block/text/line outputs

    % Store UI components and simulation state in app data
    appdata = struct();
    appdata.isRunning = false;
    appdata.iterationCount = 0;
    appdata.simulationData = []; % Initialize to store simulation data for Excel
    appdata.timer = timer('Period', 1, 'ExecutionMode', 'fixedRate', ... % Increased timer period as no blinking
        'TimerFcn', @(src, event) updateSimulation_noarg(fig, dataRateDisplay, delayTimeDisplay, efficiencyDisplay, throughputDisplay, BERDisplay, packetLossDisplay, SNRDisplay, iterationDisplay, channelModeDropDown, protocolDropDown, networkTypeDropDown, algorithmDropDown)); % Modified TimerFcn, removed block/line handles
    appdata.channelModeDropDown = channelModeDropDown;
    appdata.protocolDropDown = protocolDropDown;
    appdata.networkTypeDropDown = networkTypeDropDown;
    appdata.algorithmDropDown = algorithmDropDown;
    appdata.dataRateDisplay = dataRateDisplay;
    appdata.delayTimeDisplay = delayTimeDisplay;
    appdata.efficiencyDisplay = efficiencyDisplay;
    appdata.throughputDisplay = throughputDisplay;
    appdata.BERDisplay = BERDisplay;
    appdata.packetLossDisplay = packetLossDisplay;
    appdata.SNRDisplay = SNRDisplay;
    appdata.iterationDisplay = iterationDisplay;


    fig.UserData = appdata; % Store appdata in the figure

    % Button callbacks
    runSimulationButton.ButtonPushedFcn = @(btn, event) runSimulationButtonPushed(fig);
    stopButton.ButtonPushedFcn = @(btn, event) stopButtonPushed(fig);
    saveToExcelButton.ButtonPushedFcn = @(btn, event) saveToExcelButtonPushed(fig); % Added callback for saveToExcelButton

    % Dropdown callbacks (if needed)
    channelModeDropDown.ValueChangedFcn = @(dd, event) channelModeDropDownValueChanged(fig);
    protocolDropDown.ValueChangedFcn = @(dd, event) protocolDropDownValueChanged(fig);
    networkTypeDropDown.ValueChangedFcn = @(dd, event) networkTypeDropDownValueChanged(fig);
    algorithmDropDown.ValueChangedFcn = @(dd, event) algorithmDropDownValueChanged(fig);


end

function [channelModeDropDown, protocolDropDown, networkTypeDropDown, algorithmDropDown, ...
    runSimulationButton, stopButton, saveToExcelButton, ... % Removed metricsPanel from output
    dataRateDisplay, delayTimeDisplay, efficiencyDisplay, throughputDisplay, ...
    BERDisplay, packetLossDisplay, SNRDisplay, iterationDisplay] = createUIComponents(fig) % Removed block/text/line outputs from function definition

    % Channel Mode Dropdown
    channelModeLabel = uilabel(fig, 'Position', [20, 350, 100, 22], 'Text', 'Channel Mode:'); % Shifted up
    channelModeDropDown = uidropdown(fig, 'Position', [120, 350, 150, 22], 'Items', {'AWGN', 'Rayleigh', 'Rician', 'Nakagami'}, 'Value', 'Rayleigh');

    % Protocol Dropdown
    protocolLabel = uilabel(fig, 'Position', [20, 300, 100, 22], 'Text', 'Protocol:'); % Shifted up
    protocolDropDown = uidropdown(fig, 'Position', [120, 300, 150, 22], 'Items', {'NR-U', 'ISAC', 'D2D', 'mMTC'}, 'Value', 'ISAC');

    % Network Type Dropdown
    networkTypeLabel = uilabel(fig, 'Position', [300, 350, 100, 22], 'Text', 'Network Type:'); % Shifted up
    networkTypeDropDown = uidropdown(fig, 'Position', [400, 350, 150, 22], 'Items', {'Point-to-Point', 'Point-to-MultiPoint', 'MultiPoint-to-Point', 'Standalone D2D'}, 'Value', 'Point-to-MultiPoint');

    % Algorithm Dropdown
    algorithmLabel = uilabel(fig, 'Position', [300, 300, 100, 22], 'Text', 'Algorithm:'); % Shifted up
    algorithmDropDown = uidropdown(fig, 'Position', [400, 300, 200, 22], 'Items', {'Phase Optimization with CDLMS', 'Target Detection', 'Angle Estimation', 'Range Estimation', 'Doppler Tracking', 'IRS Beam Steering', 'ML-Based Prediction'}, 'Value', 'IRS Beam Steering');

    % Run Simulation Button
    runSimulationButton = uibutton(fig, 'Position', [20, 250, 100, 30], 'Text', 'Run Simulation'); % Shifted up

    % Stop Button
    stopButton = uibutton(fig, 'Position', [140, 250, 100, 30], 'Text', 'Stop Simulation', 'Enable', 'off'); % Shifted up

    % Save to Excel Button
    saveToExcelButton = uibutton(fig, 'Position', [260, 250, 100, 30], 'Text', 'Save to Excel', 'Enable', 'on'); % Added Save to Excel Button

    % Metrics Displays (positioned directly in figure, no panel)
    dataRateLabel = uilabel(fig, 'Position', [20, 170, 100, 22], 'Text', 'Data Rate:'); % Shifted up
    dataRateDisplay = uilabel(fig, 'Position', [120, 170, 150, 22], 'Text', 'N/A');
    delayTimeLabel = uilabel(fig, 'Position', [20, 130, 100, 22], 'Text', 'Delay:'); % Shifted up
    delayTimeDisplay = uilabel(fig, 'Position', [120, 130, 150, 22], 'Text', 'N/A');
    efficiencyLabel = uilabel(fig, 'Position', [270, 170, 100, 22], 'Text', 'Efficiency:'); % Shifted up
    efficiencyDisplay = uilabel(fig, 'Position', [370, 170, 150, 22], 'Text', 'N/A');
    throughputLabel = uilabel(fig, 'Position', [270, 130, 100, 22], 'Text', 'Throughput:'); % Shifted up
    throughputDisplay = uilabel(fig, 'Position', [370, 130, 150, 22], 'Text', 'N/A');
    BERLabel = uilabel(fig, 'Position', [520, 170, 100, 22], 'Text', 'BER:'); % Shifted up
    BERDisplay = uilabel(fig, 'Position', [620, 170, 150, 22], 'Text', 'N/A');
    packetLossLabel = uilabel(fig, 'Position', [520, 130, 100, 22], 'Text', 'Packet Loss:'); % Shifted up
    packetLossDisplay = uilabel(fig, 'Position', [620, 130, 150, 22], 'Text', 'N/A');
    SNRLabel = uilabel(fig, 'Position', [20, 90, 100, 22], 'Text', 'SNR:'); % Shifted up
    SNRDisplay = uilabel(fig, 'Position', [120, 90, 150, 22], 'Text', 'N/A');

    % Iteration Display
    iterationLabel = uilabel(fig, 'Position', [20, 50, 100, 22], 'Text', 'Iteration:'); % Added Iteration Label, Shifted up
    iterationDisplay = uilabel(fig, 'Position', [120, 50, 150, 22], 'Text', '0'); % Iteration Display, initialized to 0, Shifted up

end


function updateSimulation_noarg(fig, dataRateDisplay, delayTimeDisplay, efficiencyDisplay, throughputDisplay, BERDisplay, packetLossDisplay, SNRDisplay, iterationDisplay, channelModeDropDown, protocolDropDown, networkTypeDropDown, algorithmDropDown) % Removed block/text/line handles from arguments
    % Modified updateSimulation to get appdata from fig.UserData
    appdata = fig.UserData; % Get appdata from fig.UserData

    if ~isstruct(appdata) % Debugging check
        disp('Error: appdata is NOT a struct in updateSimulation_noarg!');
        return;
    end
    if ~isfield(appdata, 'timer') % Debugging check
        disp('Error: appdata does NOT have a timer field in updateSimulation_noarg!');
        return;
    end


    if ~appdata.isRunning
        stop(appdata.timer);
        return;
    end

    appdata.iterationCount = appdata.iterationCount + 1;

    channelMode = channelModeDropDown.Value;
    protocol = protocolDropDown.Value;
    networkType = networkTypeDropDown.Value;
    algorithm = algorithmDropDown.Value;

    [dataRate, delayTime, efficiency, throughput, BER, packetLoss, snrValue] = calculateMetrics(appdata.iterationCount, channelMode, protocol, networkType, algorithm); % Corrected output variable name

    updateMetricsDisplay(dataRateDisplay, delayTimeDisplay, efficiencyDisplay, throughputDisplay, BERDisplay, packetLossDisplay, SNRDisplay, iterationDisplay, appdata.iterationCount, dataRate, delayTime, efficiency, throughput, BER, packetLoss, snrValue); % Modified to pass iterationCount

    % Store simulation data
    appdata.simulationData = [appdata.simulationData; ...
                                 appdata.iterationCount, dataRate, delayTime, efficiency, throughput, BER, packetLoss, snrValue];
    fig.UserData = appdata; % Update appdata in fig.UserData

    % Optional: Log the output to command window for monitoring
    fprintf('Iteration: %ds, Data Rate: %.1f Mbps, Delay: %.2f ms, Efficiency: %.2f %%, Throughput: %.4f Mbps, BER: %.5f, Packet Loss: %.2f %%, SNR: %.4f dB\n', ...
        appdata.iterationCount, dataRate, delayTime, efficiency, throughput, BER, packetLoss, snrValue, snrValue); % Corrected variable name in fprintf

    % No more blinkLines call


end


function updateMetricsDisplay(dataRateDisplay, delayTimeDisplay, efficiencyDisplay, throughputDisplay, BERDisplay, packetLossDisplay, SNRDisplay, iterationDisplay, iterationCount, dataRate, delayTime, efficiency, throughput, BER, packetLoss, snrValue) % Modified to accept iterationCount
    dataRateDisplay.Text = sprintf('%.2f Mbps', dataRate);
    delayTimeDisplay.Text = sprintf('%.2f ms', delayTime);
    efficiencyDisplay.Text = sprintf('%.2f %%', efficiency);
    throughputDisplay.Text = sprintf('%.2f Mbps', throughput);
    BERDisplay.Text = sprintf('%.5f', BER);
    packetLossDisplay.Text = sprintf('%.2f %%', packetLoss);
    SNRDisplay.Text = sprintf('%.2f dB', snrValue);
    iterationDisplay.Text = sprintf('%d', iterationCount); % Use passed iterationCount
end


function runSimulationButtonPushed(fig)
    appdata = fig.UserData;
    if ~appdata.isRunning
        fprintf('>> IRS_ISAC_GUI - Run Simulation\n'); % Indicate new run in command window
        appdata.isRunning = true;
        appdata.iterationCount = 0; % Reset iteration count for a new run
        appdata.simulationData = []; % Clear previous simulation data
        fig.UserData = appdata;
        start(appdata.timer);
        runSimulationButton = findobj(fig, 'Text', 'Run Simulation');
        stopButton = findobj(fig, 'Text', 'Stop Simulation');
        iterationDisplay = findobj(fig, 'Type', 'UILabel', 'Position', [120, 50, 150, 22]); % Find iteration display label, updated position
        iterationDisplay.Text = '0'; % Reset iteration display when starting new run
        runSimulationButton.Enable = 'off';
        stopButton.Enable = 'on';
    end
end

function stopButtonPushed(fig)
    appdata = fig.UserData;
    if appdata.isRunning
        fprintf('>> IRS_ISAC_GUI - Stop Simulation\n'); % Indicate stop in command window
        appdata.isRunning = false;
        fig.UserData = appdata;
        stop(appdata.timer);
        runSimulationButton = findobj(fig, 'Text', 'Run Simulation');
        stopButton = findobj(fig, 'Text', 'Stop Simulation');
        runSimulationButton.Enable = 'on';
        stopButton.Enable = 'off';
    end
end

function saveToExcelButtonPushed(fig)
    appdata = fig.UserData;
    if ~isempty(appdata.simulationData)
        % Create a table from simulation data
        T = array2table(appdata.simulationData, 'VariableNames', ...
            {'Iteration', 'DataRate_Mbps', 'Delay_ms', 'Efficiency_Percent', 'Throughput_Mbps', 'BER', 'PacketLoss_Percent', 'SNR_dB'});

        % Default filename
        filename = 'ISAC_Simulation_Data.xlsx';

        % Write table to Excel file
        try
            writetable(T, filename);
            disp(['Simulation data saved to ', filename]);
            % Optional: Display a message box in the GUI to confirm saving
            uialert(fig, ['Data saved to ', filename], 'Save Successful');
        catch exception
            disp(['Error saving to Excel: ', exception.message]);
            uialert(fig, ['Error saving to Excel: ', exception.message], 'Save Error', 'Icon', 'error');
        end
    else
        uialert(fig, 'No simulation data to save. Run simulation first.', 'No Data', 'Icon', 'warning');
    end
end


function channelModeDropDownValueChanged(fig)
    % Placeholder
end

function protocolDropDownValueChanged(fig)
    % Placeholder
end

function networkTypeDropDownValueChanged(fig)
    % Placeholder
end

function algorithmDropDownValueChanged(fig)
    % Placeholder
end


function [dataRate, delayTime, efficiency, throughput, BER, packetLoss, snrValue] = calculateMetrics(iteration, channelMode, protocol, networkType, algorithm) % Corrected output variable name
    % calculateMetrics: Calculates performance metrics based on selected parameters and iteration.
    %   Incorporates dynamic adjustments, randomness, and SNR feedback for more realistic simulation.

    % Base values
    baseDataRate = 1000; % Mbps
    baseDelay = 5;      % ms
    baseEfficiency = 60; % Reduced base efficiency
    baseBER = 0.002;
    basePacketLoss = 8;  % Increased base packet loss
    baseSNR = 40;

    % Initialize adjustments with randomness and proportionality
    SNR_adjust = 0 + 2 * randn(); % Add some random SNR variation
    BER_adjust = 0;
    dataRate_adjust = 0;
    delay_adjust = 0;
    efficiency_adjust = 0;
    packetLoss_adjust = 0;

    % Channel Mode Adjustments
    switch channelMode
        case 'AWGN'
            SNR_adjust = SNR_adjust + 5 + 1*randn();
            BER_adjust = BER_adjust - 0.0005 + 0.0001*randn();
            efficiency_adjust = baseEfficiency * (0.10 + 0.03 * randn());
        case 'Rayleigh'
            SNR_adjust = SNR_adjust - 10 - sqrt(iteration) + 2*randn();
            BER_adjust = BER_adjust + 0.005 + 0.0005*randn();
            efficiency_adjust = baseEfficiency * (-0.20 + 0.05 * randn());
        case 'Rician'
            SNR_adjust = SNR_adjust + 0 + 1.5*randn();
            BER_adjust = BER_adjust + 0.001 + 0.0002*randn();
            efficiency_adjust = baseEfficiency * (-0.10 + 0.04 * randn());
        case 'Nakagami'
            SNR_adjust = SNR_adjust - 2 - 0.2*iteration + randn();
            BER_adjust = BER_adjust + 0.002 + 0.0003*randn();
            efficiency_adjust = baseEfficiency * (-0.15 + 0.045 * randn());
    end

    % Protocol Adjustments
    switch protocol
        case 'NR-U'
            dataRate_adjust = dataRate_adjust + 100 + 0.5*randn();
            delay_adjust = delay_adjust - 2 + 0.1*randn();
            efficiency_adjust = efficiency_adjust + baseEfficiency * (0.15 + 0.03 * randn());
        case 'ISAC'
            dataRate_adjust = dataRate_adjust + 20 - 0.2*randn();
            delay_adjust = delay_adjust + 0.5 + 0.2*randn();
            efficiency_adjust = efficiency_adjust + baseEfficiency * (-0.15 + 0.04 * randn());
        case 'D2D'
            dataRate_adjust = dataRate_adjust + 50 + 0.3*randn();
            delay_adjust = delay_adjust - 1.5 + 0.15*randn();
            efficiency_adjust = efficiency_adjust + baseEfficiency * (0.12 + 0.035 * randn());
        case 'mMTC'
            dataRate_adjust = dataRate_adjust - 200 - 1.0*randn();
            delay_adjust = delay_adjust + 3 + 0.3*randn();
            efficiency_adjust = efficiency_adjust + baseEfficiency * (-0.25 + 0.06 * randn());
    end

    % Network Type Adjustments
    switch networkType
        case 'Point-to-Point'
            efficiency_adjust = efficiency_adjust + baseEfficiency * (0.10 + 0.02 * randn());
            packetLoss_adjust = packetLoss_adjust - basePacketLoss * (0.20 + 0.05 * randn());
        case 'Point-to-MultiPoint'
            efficiency_adjust = efficiency_adjust + baseEfficiency * (-0.15 + 0.04 * randn());
            packetLoss_adjust = packetLoss_adjust + basePacketLoss * (0.10 + 0.03 * randn());
        case 'MultiPoint-to-Point'
            efficiency_adjust = efficiency_adjust + baseEfficiency * (-0.12 + 0.035 * randn());
            packetLoss_adjust = packetLoss_adjust + basePacketLoss * (0.08 + 0.025 * randn());
        case 'Standalone D2D'
            efficiency_adjust = efficiency_adjust + baseEfficiency * (0.08 + 0.025 * randn());
            packetLoss_adjust = packetLoss_adjust - basePacketLoss * (0.15 + 0.04 * randn());
    end

    % Algorithm Adjustments
    switch algorithm
        case 'Phase Optimization with CDLMS'
            SNR_adjust = SNR_adjust + 1 + 0.5*randn();
            efficiency_adjust = efficiency_adjust + baseEfficiency * (0.02 + 0.01 * randn());
        case 'Target Detection'
            delay_adjust = delay_adjust + 0.2 + 0.1*randn();
            packetLoss_adjust = packetLoss_adjust + basePacketLoss * (0.05 + 0.02 * randn());
        case 'Angle Estimation'
            delay_adjust = delay_adjust + 0.1 + 0.05*randn();
        case 'Range Estimation'
            delay_adjust = delay_adjust + 0.15 + 0.07*randn();
        case 'Doppler Tracking'
            delay_adjust = delay_adjust + 0.25 + 0.12*randn();
            BER_adjust = BER_adjust + 0.00005 + 0.00002*randn();
            packetLoss_adjust = packetLoss_adjust + basePacketLoss * (0.08 + 0.03 * randn());
        case 'IRS Beam Steering'
            SNR_adjust = SNR_adjust + 2 + randn();
            efficiency_adjust = efficiency_adjust + baseEfficiency * (0.04 + 0.015 * randn());
        case 'ML-Based Prediction'
            BER_adjust = BER_adjust - 0.0001 + 0.00003*randn();
            packetLoss_adjust = packetLoss_adjust - basePacketLoss * (0.10 + 0.035 * randn());
    end

    % Time-based variations and SNR feedback
    dataRate = baseDataRate + dataRate_adjust + 0.2 * iteration * randn();
    delayTime = max(1, baseDelay + delay_adjust - 0.01 * iteration + 0.05 * randn());
    efficiency = baseEfficiency + efficiency_adjust + 0.5 * randn() + 0.05 * SNR_adjust/baseSNR * baseEfficiency; % Corrected to use SNR_adjust
    throughput = max(0, (dataRate * efficiency / 100));
    BER = max(0, baseBER + BER_adjust - 0.00002 * SNR_adjust/baseSNR + 0.0001 * randn()); % Corrected to use SNR_adjust
    packetLoss = max(0, basePacketLoss + packetLoss_adjust - 0.01 * SNR_adjust/baseSNR + 0.01 * randn()); % Corrected to use SNR_adjust
    snrValue = baseSNR + SNR_adjust - 0.1 * iteration + 0.8 * randn(); % Corrected output variable name

    % Bounding
    efficiency = min(max(efficiency, 10), 95);
    packetLoss = max(0, min(packetLoss, 50));
    snrValue = max(snrValue, 0); % Corrected variable name
end
