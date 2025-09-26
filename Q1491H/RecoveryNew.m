% Fuction written by Anthony Owusu-Mensah, current August 2023
% Function replicates onset of Recovery protocol
% in Quentin et. al paper (doi: 10.1016/j.cjco.2020.09.023)
% Function accepts duration of stimulation and time you intend to vary
% the recovery from inactivation
% tNow = simulation times
% tVary = Recovery time duration



function out = RecoveryNew(tNow, tVary, wait)
vHold = -140; % holding Potential
vTest = -30; % Test Potential
% % global wait;
out = (tNow <= (0 + wait) ).* vHold +  ...
      ((0+wait) < tNow & tNow <= (500 + wait)).* vTest + ...
      ((wait+500) < tNow & tNow <= (500 + tVary+wait)).*vHold + ...
      ((tVary + 500 + wait)< tNow & tNow <=(tVary + 520 + wait)).* vTest + ...
      (tNow > (tVary + 520 + wait)).* vHold;
    

     
    

end

