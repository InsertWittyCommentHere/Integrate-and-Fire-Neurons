function integrate_fire_neuronPartB()
% INTEGRATE_FIRE_NEURON — Beginner version with Refractory Period
% Shows how multiple inputs add together.

    % ===================== Student Parameters =====================
    % Step 1: 240pA from 100–300 ms
    step1_amp  = 240e-12;   % Step 1 Current Injection Amount (In amperes, 180 picoamperes)
    step1_on   = 100e-3;   % Step 1 Time when Injection Begins (In seconds, 100 ms)
    step1_off  = 300e-3;   % Step 1 Time when Injection Ends (In seconds, 300 ms)
    
    % Basically, pa                     use for 100 ms before injecting 180 pA for 200 ms
    
    % ===============================================================

    % Simulation settings
    dt    = 1e-4;          % seconds, simulation time step (0.1 ms)
    T_end = 0.5;           % seconds, total simulation time (200 ms)
    T     = (0:dt:T_end)'; % time vector. Column vector from 0 to T_end with step-size of dt
    N     = numel(T); % numel counts the number of elements. This is the total number of time steps (num elements in T). 

    % Neuron parameters
    V_reset = -0.080;  % Volts, membrane voltage after a spike
    V_th    = -0.050;  % Volts, threshold membrane potential for a spike
    Rm      = 10e6;    % Ohms, membrane resistance
    Cm      = 100e-12; % Total membrane capacitance (Farads)
    g_L     = 10e-9;   % Leak conductance (Siemens)
    E_L     = -0.070;  % Resting leak potential (Volts)
    tau_m   = Cm/g_L;   % seconds, membrane time constant (τ).
    

    % Build input current: TWO steps
    I_input = zeros(N,1); % Initializes a vector of inputs to 0. N values in the vector because N time steps (see above)
    I_input(T>=step1_on & T<=step1_off) = I_input(T>=step1_on & T<=step1_off) + step1_amp; % Entries in indexes between step1_on and step1_off become step1_amp           
    
    % NOTE: the code supports overlap, so the two input injections are allowed to overlap. They will be summed together

    % Initialize membrane voltage
    Vm = zeros(N,1); % Stores membrane voltage in every timestep
    Vm(1) = V_reset; % Set the first (initial) membrane voltage to the membrane voltage right after a spike has just been fired
    spike_times = []; % Stores the times when there are spikes

    % Euler integration of LIF equation. Basically, if membrane voltage exceeds threshold, fire (so the neuron spikes),
    % record spike time, and reset Vm to V_reset
    refractory_period = 50e-3;  % seconds, 5 ms
    t_last_spike = -Inf;  % Time of last spike, initialized to negative infinity

    for i = 1:N-1
        if (T(i) - t_last_spike) < refractory_period
            Vm(i + 1) = V_reset;

        elseif Vm(i) >= V_th
            spike_times(end+1,1) = T(i); 
            t_last_spike = T(i);
            Vm(i+1) = V_reset;
        else
            dVdt = (-g_L * (Vm(i) - E_L) + I_input(i)) / Cm;
            Vm(i+1) = Vm(i) + dt * dVdt;
        end
    end

    % ----------- Plot results -----------
    figure('Color','w','Position',[100 100 1000 800]);

    % (1) Input current (one step), blue line shows the two step currents
    subplot(3,1,1);
    plot(T*1e3, I_input*1e12, 'b', 'LineWidth', 2);
    ylabel('Current (pA)');
    title('Input Current Stimulus');
    xlim([0 T_end]*1e3);
    grid on;
    
    % (2) Membrane voltage Vm over time (in mV) with yellow dashed line at threshold voltage
    subplot(3,1,2);
    plot(T*1e3, Vm*1e3, 'g', 'LineWidth', 2); hold on;
    plot([0 T_end]*1e3, [V_th V_th]*1e3, 'y--', 'LineWidth', 1.5); % threshold line
    ylabel('Membrane Voltage (mV)');
    title('Membrane Potential');
    xlim([0 T_end]*1e3);
    legend({'V_m','Threshold'}, 'Location', 'best');
    grid on;
    
    % (3) Spike markers (vertical pink line from V_reset to V_th at spike time
    subplot(3,1,3);
    for s = spike_times.'
        line([s s]*1e3, [0 1], 'Color', 'm', 'LineWidth', 1.5); hold on;
    end
    ylim([0 1.2]);
    xlim([0 T_end]*1e3);
    ylabel('Spike');
    xlabel('Time (ms)');
    title('Spike Times');
    grid on;
   
end

