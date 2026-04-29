function integrate_fire_neuron3x3()
% LEAKY_INTEGRATE_FIRE_NEURON — PartA

    % ===================== Student Parameters =====================
    % Sim 1: 180pA from 100–300 ms
    step1_amp  = 180e-12;   % Step 1 Current Injection Amount (In amperes, 180 picoamperes)
    step1_on   = 100e-3;   % Step 1 Time when Injection Begins (In seconds, 100 ms)
    step1_off  = 300e-3;   % Step 1 Time when Injection Ends (In seconds, 300 ms)

    % Sim 2: 210pA from 100–300 ms
    step2_amp  = 210e-12;   % Step 2 Current Injection Amount (In amperes, 210 picoamperes)
    step2_on   = 100e-3;   % Step 2 Time when Injection Begins (In seconds, 100 ms)
    step2_off  = 300e-3;   % Step 2 Time when Injection Ends (In seconds, 300 ms)

    % Sim 3: 240pA from 100–300 ms. Used in refractory as well
    step3_amp  = 240e-12;   % Step 3 Current Injection Amount (In amperes, 240 picoamperes)
    step3_on   = 100e-3;   % Step 3 Time when Injection Begins (In seconds, 100 ms)
    step3_off  = 300e-3;   % Step 3 Time when Injection Ends (In seconds, 300 ms)
    
    % Basically, pause for 100 ms before injecting 180 pA, 210 pA, or 240 pA for 200 ms
    
    % ===============================================================

    % Simulation settings
    dt    = 1e-4;          % seconds, simulation time step (0.1 ms)
    T_end = 0.5;           % seconds, total simulation time (500 ms, or 0.5 sec)
    T     = (0:dt:T_end)'; % time vector. Column vector from 0 to T_end with step-size of dt
    N     = numel(T); % numel counts the number of elements. This is the total number of time steps (num elements in T). 

    % Neuron parameters
    V_reset = -0.080;  % Volts, membrane voltage after a spike
    V_th    = -0.050;  % Volts, threshold membrane potential for a spike
    Rm      = 10e6;    % Ohms, membrane resistance. Not used
    Cm      = 100e-12; % Total membrane capacitance (Farads)
    g_L     = 10e-9;   % Leak conductance (Siemens)
    E_L     = -0.070;  % Resting leak potential (Volts)
    tau_m   = Cm/g_L;   % seconds, membrane time constant (τ). Not used because we already have Cm and g_L in equation

    % Build input current

    % Sim1 (180 pA)
    I_input1 = zeros(N,1); % Initializes a vector of inputs to 0. N values in the vector because N time steps (see above)
    I_input1(T>=step1_on & T<=step1_off) = I_input1(T>=step1_on & T<=step1_off) + step1_amp; % Entries in indexes between step1_on and step1_off become step1_amp           
    
    % Sim2 (210 pA)
    I_input2 = zeros(N,1); % Initializes a vector of inputs to 0. N values in the vector because N time steps (see above)
    I_input2(T>=step2_on & T<=step2_off) = I_input2(T>=step2_on & T<=step2_off) + step2_amp; % Entries in indexes between step2_on and step2_off become step2_amp           

    % Sim3 (240 pA)
    I_input3 = zeros(N,1); % Initializes a vector of inputs to 0. N values in the vector because N time steps (see above)
    I_input3(T>=step3_on & T<=step3_off) = I_input3(T>=step3_on & T<=step3_off) + step3_amp; % Entries in indexes between step3_on and step3_off become step3_amp           

    % Initialize membrane voltage

    % Sim1
    Vm1 = zeros(N,1); % Stores membrane voltage in every timestep
    Vm1(1) = V_reset; % Set the first (initial) membrane voltage to the membrane voltage right after a spike has just been fired
    spike_times1 = []; % Stores the times when there are spikes

    % Sim2
    Vm2 = zeros(N,1); % Stores membrane voltage in every timestep
    Vm2(1) = V_reset; % Set the first (initial) membrane voltage to the membrane voltage right after a spike has just been fired
    spike_times2 = []; % Stores the times when there are spikes

    % Sim3
    Vm3 = zeros(N,1); % Stores membrane voltage in every timestep
    Vm3(1) = V_reset; % Set the first (initial) membrane voltage to the membrane voltage right after a spike has just been fired
    spike_times3 = []; % Stores the times when there are spikes

    % Euler integration of LIF equation. Basically, if membrane voltage exceeds threshold, fire (so the neuron spikes),
    % record spike time, and reset Vm to V_reset

    % Sim 1
    for i = 1:N-1
        if Vm1(i) >= V_th
            spike_times1(end+1,1) = T(i); 
            Vm1(i+1) = V_reset;
        else
            dVdt = (-g_L * (Vm1(i) - E_L) + I_input1(i)) / Cm;
            Vm1(i+1) = Vm1(i) + dt * dVdt;
        end
    end


    % Sim 2
    for i = 1:N-1
        if Vm2(i) >= V_th
            spike_times2(end+1,1) = T(i); 
            Vm2(i+1) = V_reset;
        else
            dVdt = (-g_L * (Vm2(i) - E_L) + I_input2(i)) / Cm;
            Vm2(i+1) = Vm2(i) + dt * dVdt;
        end
    end

    % Sim 3
    for i = 1:N-1
        if Vm3(i) >= V_th
            spike_times3(end+1,1) = T(i); 
            Vm3(i+1) = V_reset;
        else
            dVdt = (-g_L * (Vm3(i) - E_L) + I_input3(i)) / Cm;
            Vm3(i+1) = Vm3(i) + dt * dVdt;
        end
    end


    % Calculate interspike intervals and firing rate for each sim

    % Sim 1 (no spikes)
    if length(spike_times1) >= 2
        InterspikeInterval = diff(spike_times1);  % in seconds
        fprintf('Interspike intervals (ms):\n');
        disp(InterspikeInterval * 1e3);
    else
        fprintf('Fewer than 2 spikes — no ISI to compute.\n');
        InterspikeInterval = [];
    end

    num_spikes = length(spike_times1); % Number of spikes
    firing_rate = num_spikes / T_end;  % spikes per second (Hz)
    fprintf('Firing rate: %.2f Hz\n', firing_rate);

   
    % Sim 2
    if length(spike_times2) >= 2
        InterspikeInterval = diff(spike_times2);  % in seconds
        fprintf('Interspike intervals (ms):\n');
        disp(InterspikeInterval * 1e3);
    else
        fprintf('Fewer than 2 spikes — no ISI to compute.\n');
        InterspikeInterval = [];
    end

    num_spikes = length(spike_times2); % Number of spikes
    firing_rate = num_spikes / T_end;  % spikes per second (Hz)
    fprintf('Firing rate: %.2f Hz\n', firing_rate);

   
    % Sim 3
    if length(spike_times3) >= 2
        InterspikeInterval = diff(spike_times3);  % in seconds
        fprintf('Interspike intervals (ms):\n');
        disp(InterspikeInterval * 1e3);
    else
        fprintf('Fewer than 2 spikes — no ISI to compute.\n');
        InterspikeInterval = [];
    end

    num_spikes = length(spike_times3); % Number of spikes
    firing_rate = num_spikes / T_end;  % spikes per second (Hz)
    fprintf('Firing rate: %.2f Hz\n', firing_rate);

    % ----------- Plot results for 3x3 -----------
    figure('Name', '3x3', 'Color','w','Position',[100 100 1200 900]);

    % Sim 1
    % (1) Input current (one step), blue line shows the two step currents
    subplot(3,3,1);
    plot(T*1e3, I_input1*1e12, 'b', 'LineWidth', 2);
    ylabel('Current (pA)');
    title('Input Current Stimulus');
    xlim([0 T_end]*1e3);
    grid on;
    
    % (2) Membrane voltage Vm over time (in mV) with yellow dashed line at threshold voltage
    subplot(3,3,2);
    plot(T*1e3, Vm1*1e3, 'g', 'LineWidth', 2); hold on;
    plot([0 T_end]*1e3, [V_th V_th]*1e3, 'y--', 'LineWidth', 1.5); % threshold line
    ylabel('Membrane Voltage (mV)');
    title('Membrane Potential');
    xlim([0 T_end]*1e3);
    legend({'V_m','Threshold'}, 'Location', 'best');
    grid on;
    
    % (3) Spike markers (vertical pink line from V_reset to V_th at spike time
    subplot(3,3,3);
    for s = spike_times1.'
        line([s s]*1e3, [0 1], 'Color', 'm', 'LineWidth', 1.5); hold on;
    end
    ylim([0 1.2]);
    xlim([0 T_end]*1e3);
    ylabel('Spike Times');
    xlabel('Time (ms)');
    title('Spike Train');
    grid on;

    % Sim 2

    % (1) Input current (one step), blue line shows the two step currents
    subplot(3,3,4);
    plot(T*1e3, I_input2*1e12, 'b', 'LineWidth', 2);
    ylabel('Current (pA)');
    title('Input Current Stimulus');
    xlim([0 T_end]*1e3);
    grid on;
    
    % (2) Membrane voltage Vm over time (in mV) with yellow dashed line at threshold voltage
    subplot(3,3,5);
    plot(T*1e3, Vm2*1e3, 'g', 'LineWidth', 2); hold on;
    plot([0 T_end]*1e3, [V_th V_th]*1e3, 'y--', 'LineWidth', 1.5); % threshold line
    ylabel('Membrane Voltage (mV)');
    title('Membrane Potential');
    xlim([0 T_end]*1e3);
    legend({'V_m','Threshold'}, 'Location', 'best');
    grid on;
    
    % (3) Spike markers (vertical pink line from V_reset to V_th at spike time
    subplot(3,3,6);
    for s = spike_times2.'
        line([s s]*1e3, [0 1], 'Color', 'm', 'LineWidth', 1.5); hold on;
    end
    ylim([0 1.2]);
    xlim([0 T_end]*1e3);
    ylabel('Spike Times');
    xlabel('Time (ms)');
    title('Spike Train');
    grid on;


    % Sim 3
    % (1) Input current (one step), blue line shows the two step currents
    subplot(3,3,7);
    plot(T*1e3, I_input3*1e12, 'b', 'LineWidth', 2);
    ylabel('Current (pA)');
    title('Input Current Stimulus');
    xlim([0 T_end]*1e3);
    grid on;
    
    % (2) Membrane voltage Vm over time (in mV) with yellow dashed line at threshold voltage
    subplot(3,3,8);
    plot(T*1e3, Vm3*1e3, 'g', 'LineWidth', 2); hold on;
    plot([0 T_end]*1e3, [V_th V_th]*1e3, 'y--', 'LineWidth', 1.5); % threshold line
    ylabel('Membrane Voltage (mV)');
    title('Membrane Potential');
    xlim([0 T_end]*1e3);
    legend({'V_m','Threshold'}, 'Location', 'best');
    grid on;
    
    % (3) Spike markers (vertical pink line from V_reset to V_th at spike time
    subplot(3,3,9);
    for s = spike_times3.'
        line([s s]*1e3, [0 1], 'Color', 'm', 'LineWidth', 1.5); hold on;
    end
    ylim([0 1.2]);
    xlim([0 T_end]*1e3);
    ylabel('Spike Times');
    xlabel('Time (ms)');
    title('Spike Train');
    grid on;
   
end

