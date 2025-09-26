function I_Na = INa_Curr(key,sol,param,V_m,Erev)

    if ~exist("key","var")
        Ona5 = sol(:,4); BOna5 = sol(:,13);
        I_Na = param(end).*(Ona5 + BOna5).*(V_m - Erev);
   
    elseif key == "I"
        Ona5 = sol(:,4); BOna5 = sol(:,13);
        I_Na = param(end).*(Ona5 + BOna5).*(V_m - Erev);
   
    elseif key == "M"
        O = sol(:,7);
        I_Na = param(end).*O.*(V_m - Erev);

    elseif key == "Z"
        O = sol(:,4);
        I_Na = param(end).*O.*(V_m - Erev);
    
    elseif key == "Mod6"
        O = sol(:,3);
        I_Na = param(end).*O.*(V_m - Erev);

    elseif key == "IR"
        Ona5 = sol(:,4); 
        I_Na = param(end).*Ona5.*(V_m - Erev);
    
    elseif key == "FINa"
        Ona5 = sol(:,4); 
        I_Na = param(end).*Ona5.*(V_m - Erev);
    
    elseif key == "Mahaj"
        m = sol(:,1); h = sol(:,2); j = sol(:,3);
        I_Na = param(end).* (m.^3).*h .*j.*(V_m - Erev);
    
    elseif key == "None"
        
        Ona5 = sol(:,1); 
        I_Na = zeros(length(Ona5),1);
 
    else
        Ona5 = sol(:,4); BOna5 = sol(:,13);
        I_Na = param(end).*(Ona5 + BOna5).*(V_m - Erev);
   
    end
end