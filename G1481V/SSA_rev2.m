% This is a worker function  for generating
% I-V and steady state Inctivation curve
function [p_holdR,INa_holdR] = SSA_rev2(odeFun,param,Vcm,Erev,INa_Curr)
% % function [p_hold,INa_hold] = ACT(odeFun,Vcm)
    % % % Constants
    % % F     = 96486.7;        %units(J / kmol / K);
    % % R     = 8314.3;         %units(C / mol);
    % % % % T = 310.0; 
    % % global T;
    % % % % T = 295; %units(K);     % Temperature that INa was recorded
    % % RTonF = R * T / F;      %units(mV);
    % % Nae     = 140.0;        %units(mM);
    % % % % Nae     = 35.0;        %units(mM); % From Quentin et. al
    % % Nai     = 8.8;          %units(mM);
    % % % % Nai     = 35.0;          %units(mM); % From Quentin et. al
    % % GNa     =  20;             %units(mS / cm^2);
    % % E_Na = RTonF * log(Nae / Nai);
    % % 
    % % E_Na = 3.24745;
    
    dt = 0.02;
    wait = 15;
    % % wait = 50; % The waiting period before patch clamp recordings
    tend = 799.66;
    sol_at = 0:dt:tend;
    % % global wait;
    %%wait = 50;
    % % wait = 500;
     % Sweep  to look for peak
    idx = sol_at >= (wait + 500 - dt);
     % % idx = sol_at >= (tend - dt);

    % % idx = sol_at > 0.2   
    global ic % Make the initial conditions global
    opts=odeset('MaxStep', dt,'Vectorized','on');
    nx = length(Vcm);
    p_hold = zeros(nx ,1); % hold Peak for every voltage step
    % % Colors = colormap(jet(nx));
    Protocol = @INaInActivationNew; %% Voltage protocol INa Inactivation
    % % vals = arrayfun(@num2str,Vcm,'UniformOutput',false);

    global key
  
    parfor i = 1:nx
        try
            [tmat,sol]=ode23t(@(t,state) odeFun(t,state,Vcm(i),param,Protocol,wait),sol_at, ic,opts);
            % % [tmat,sol]=ode23t(@(t,state) odeFun(t,state,Vcm(i),Protocol),sol_at, ic,opts);
            % Calculate INa current at the voltage step
             V_m = Protocol(tmat,Vcm(i),wait);
             % % O = sol(:,7); % Open State Probability
             % % I_Na = GNa.*O.*(V_m - E_Na); 
             I_Na = INa_Curr(key,sol,param,V_m,Erev);
             % % Ona5 = sol(:,4); BOna5 = sol(:,13);
             % % I_Na = param(end).*(Ona5 + BOna5).*(V_m - Erev); 
             I_Na(sol_at>=(wait-dt) & sol_at < wait) = 0; % Reset the INa peak incase of any capacitive transient
             % before the +30 mV step voltage
             INa_hold(i,:) = I_Na; % All INa current values at the solutions times
             % % plot(tmat, INa_hold(i,:),'Color',Colors(i,:),'LineWidth',1.5); hold on;
             p_hold(i,1) =  min(I_Na(idx)); % Peak INa value a
             % % leng{i}= vals(i);
    
             % % [p_hold(i,1)] =  min(I_Na(idx));
        catch ME
            disp(ME.message);
            INa_hold(i,:) = NaN; % Handle errors by assigning NaN
            p_hold(i,1) = NaN;
        end
        
    end
        p_holdR = p_hold;
        INa_holdR = INa_hold;

    % % legend('-100', '-95', '-85')
    % % 
end


