% Fuction written by Anthony Owusu-Mensah, current August 2023
% Function replicates onset of slow inactivation protocol
% in Quentin et. al paper (doi: 10.1016/j.cjco.2020.09.023)
% Function accepts duration of stimulation and time you intend to vary
% the onset of slow inactivation
% tNow = simulation times
% tVary = Onsetinactivation time duration


function out = slowInactivationNew(tNow, tVary,wait)
    % % wait = 500;
    vHold = -140; % holding Potential
    vTest = -30; % Test Potential
    out = (tNow <= wait ).* vHold + ...
      (tNow > wait &  tNow <= (tVary + wait)).*vTest + ...
      ((tVary + wait) < tNow & tNow <=(tVary + wait + 20)).* vHold + ...
      (tNow > (tVary + wait + 20) & tNow <= (tVary + wait + 60)).* vTest + ...
      (tNow > (tVary + wait + 60)).* vHold;
end


