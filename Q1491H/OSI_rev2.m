function [p1_hold,p2_hold,INa_hold] = OSI_rev2(odeFun, param,tVary,Erev,INa_Curr)

% % Function written by Anthony Owusu-Mensah
% % Function returns peak current when the InActivation
% % protocol from Quentin et al (doi: 10.1016/j.cjco.2020.09.023) 
% is applied.
% %  Fuction accepts 2 paramters
% % ode Function, Paramters and time duration to vary command voltages
  
  
  
    % Constants
    % % F     = 96486.7;        %units(J / kmol / K);
    % % R     = 8314.3;         %units(C / mol);
    % % T = 310.0;              %units(K);
    % % RTonF = R * T / F;      %units(mV);
    % % Nae     = 140.0;        %units(mM);
    % % Nai     = 8.8;          %units(mM);
    % % GNa   = param(end-1);             %units(mS / cm^2);
    % % E_Na = RTonF * log(Nae / Nai);
    % % alpha = param(end); % To account for residual or persisent current

    %% OdeSolver
    dt = 0.02;
    wait = 90;
    tend = 4996.5;
    sol_at = 0:dt:tend;

    % Initial conditions for state variables
     global ic

    opts=odeset('MaxStep', dt,'Vectorized','on');
    nx = length(tVary);
  
    Protocol = @slowInactivationNew; %% Voltage protocol for onset of slow inactivation
    global key
    step = 10;
    parfor i = 1:nx
        
        try
            [tmat,sol]=ode23t(@(t,state) odeFun(t,state,tVary(i),param,Protocol,wait),sol_at, ic,opts);
            % Calculate INa current at the voltage step
            V_m = Protocol(tmat,tVary(i),wait);
            I_Na = INa_Curr(key,sol,param,V_m,Erev)
            % % Ona5 = sol(:,4); BOna5 = sol(:,13);
            % % I_Na = param(end).*(Ona5 + BOna5).*(V_m - Erev);
            I_Na(sol_at>=(wait-dt) & sol_at < wait) = 0; % Reset the INa peak incase of any capacitive transient
            INa_hold(i,:) = I_Na; % All INa current values at the solutions times
           % % Indixes to searchC_hold
            pidx_1 = sol_at <= (wait + tVary(i) + step); % sweep to get P1 
            pidx_2 = (sol_at >  (wait + tVary(i) + step))  & (sol_at <=  (wait + tVary(i) + 60 + step)) ; % sweep to get P2
            P1(i,1) = min(I_Na(pidx_1));
            P2(i,1) = min(I_Na(pidx_2));
        
        catch ME
           disp(ME.message);
           INa_hold(i,:) = NaN
           P1(i,1) = NaN;
           P2(i,1) = NaN;
        end
          
    end
    
    %% 
    p1_hold = P1; % Peak of Prepulse
    p2_hold = P2; % % Peak of Testpulse  

end  
   