function out = persistINa(tNow,Vcm,wait)
    Vhold = -140;
    out = (tNow <= wait).*Vhold + ...
        (wait < tNow & tNow <= (400 + wait)).*Vcm + ...
        (tNow > 400 + wait).*Vhold;
    
end
