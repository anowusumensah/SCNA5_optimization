function out = INaActivationNew(tNow, Vcm,wait)
    Vhold = -100;
    out = (tNow <= wait).*Vhold + ...
        (wait < tNow & tNow <= (50 + wait)).*Vcm + ...
        (tNow > 50 + wait).*Vhold;
    
end
