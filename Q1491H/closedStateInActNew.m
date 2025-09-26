% Fuction written by Anthony Owusu-Mensah, current August 2023
% Function replicates onset of closed State Inactivation protocol
% in Quentin et. al paper (doi: 10.1016/j.cjco.2020.09.023)
% Function accepts duration of stimulation and time you intend to vary
% the closed State Inactivation
% tNow = simulation times
% tVary = closed State Inactivation time duration



% % 
function out = closedStateInActNew(tNow, tVary,wait)
vHold = -140; % holding Potential
vTest1 = -100; % Test Potential
vTest2 = -30; % Test Potential
% % wait = 500;
    out = (tNow <= wait).*vHold + ...
            ((tNow > wait) & (tNow <= (wait + tVary))) .* vTest1 + ...
            ((tNow > (wait + tVary)) & (tNow <= (wait + tVary + 5))).*vTest2 + ...
            (tNow > (wait + tVary + 5)).*vHold;
            
end


