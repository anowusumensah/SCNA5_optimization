
function out = evaluateTransition(V, param)

    threshVal = 5 * 10^6;
    if length(param) < 24
        param(1:25) = threshVal;
    end

    a1 = exp(log(param(1)) + (V/param(2)));
    a2 = exp(log(param(3)) + (V/param(4)));
    a3 = exp(log(param(5)) + (V/param(6)));
    B1 = exp(log(param(7)) + (V/-param(8)));
    B2 = exp(log(param(9)) + (V/-param(10)));
    Q1 = exp(log(param(11)) + (V/-param(12)));
    Q2 = exp(log(param(13)) + (V/-param(14)));
    Q3 = exp(log(param(15)) + (V/-param(16)));
    g  = param(17);
    a  = param(18);
    f  = param(19);
    c  = param(20);
    p1 = g./(1 + exp((-(V + a)/f)));
    p2 = exp(log(param(21)) + (V/param(22)));
    p3 = exp(log(param(23)) + (V/param(24)));
    B3 = ((B2*(c^4)*p1*a3*Q2)./ (a2*p2*Q1));
    % % out = [a1, a2, a3, B1, B2, Q1, Q2, Q3, g, a, f, c,p1, p2, p3, B3];
    out = [a1, a2, a3, B1, B2, Q1, Q2, Q3,p1, p2, p3, B3];
end