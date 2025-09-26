% This is a worker function  for generating
% I-V and steady state activation curves
function [INa_holdN,p_holdR,peak60, INa_holdR,sol_at,wait] = persistACT_rev2(odeFun,param,Vcm,Erev,tVals,INa_Curr)
% % function [p_hold,INa_hold] = ACT(odeFun,Vcm)
    % Constants
    % % F     = 96486.7;        %units(J / kmol / K);
    % % R     = 8314.3;         %units(C / mol);
    % % % % T = 310.0; 
    % % global T;
    % % RTonF = R * T / F;      %units(mV);
    % % Nae     = 140.0;        %units(mM);
    % % Nai     = 8.8;          %units(mM);
    % % GNa     =  20;             %units(mS / cm^2);
    % % E_Na = RTonF * log(Nae / Nai);
   
    % % E_Na = 3.24745;
   
    dt = tVals(2) - tVals(1);
    
    wait = 1.25;
    % % wait = 50; % Holding time before protocol
     % Sweep  to look for peak 
    sol_at = tVals;
    idx60 = find(tVals >= 60); % Fin
    idx60 = idx60(1); % Index corresponding to 60ms 

    idx = sol_at >= (wait + dt);
    % % idx = sol_at > 0.2;
    
    global ic % Make the initial conditions global
    opts=odeset('MaxStep', dt,'Vectorized','on');
    nx = length(Vcm);
    p_hold = zeros(nx ,1); % hold Peak for every voltage step
    % % Colors = colormap(jet(nx));
    Protocol = @persistINa; %% Voltage protocol INa-Activation
    % % vals = arrayfun(@num2str,Vcm,'UniformOutput',false);
    
    global key
    parfor i = 1:nx
        % % disp("Solving Persistent Current")
        try
            [tmat,sol]=ode23t(@(t,state) odeFun(t,state,Vcm(i),param,Protocol,wait),sol_at, ic,opts);
            % % [tmat,sol]=ode23t(@(t,state) odeFun(t,state,Vcm(i),Protocol),sol_at, ic,opts);
            % Calculate INa current at the voltage step
             V_m = Protocol(tmat,Vcm(i),wait);
             % % O = sol(:,7); % Open State Probability
             I_Na = INa_Curr(key,sol,param,V_m,Erev)
             I_Na(sol_at>=(wait-dt) & sol_at < wait) = 0; % Reset the INa peak incase of any capacitive transient
             % before the +30 mV step voltage
             INa_hold(i,:) = I_Na; % All INa current values at the solutions times
             p_hold(i,1) =  min(I_Na(idx)); % Peak INa value (Current direction changes after reversal potential)
             peak60(i,1) = I_Na(idx60);
        catch ME
             disp(ME.message);
             INa_hold(i,:) = NaN; %% Set the values to NaN
             p_hold(i,1) = NaN;
             peak60(i,1) = NaN;
              
        end

                  % % leng{i}= vals(i); 
    end
    p_holdR = p_hold;
    INa_holdR = INa_hold;
    INa_holdN = -(INa_hold/p_hold);
    % % legend('-100', '-95', '-85')
    % % 
end


