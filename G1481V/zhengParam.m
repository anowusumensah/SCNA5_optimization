 
function dstate=zhengParam(t,state,Vcm,param,Protocol,wait)
        C1			= state(1,:);
		C2			= state(2,:);
        C3			= state(3,:);
        O			= state(4,:);
        I11			= state(5,:);
        I12			= state(6,:);
        I13			= state(7,:);
        I14			= state(8,:);
        I21			= state(9,:);
        I22			= state(10,:);
        I23			= state(11,:);
        I24			= state(12,:);

        % % Trec = 295;  % Temperature that it was recorded
        % % Q10 = 3;
        % % Tfactor = 1.0/(pow(Q10, (37.0-(Trec-273))/10.0)); % Temperature correction factor
        V = Protocol(t, Vcm,wait); % Apply protocol
        % Nav1.5 channel transitions
        % % param = [9.435,39.70,441.1,6.593,11.17,11.64,...
        % %         0.000037,7.770,0.2241,21.13,0.000020,...
        % %         13.07,0.000302,47.08,0.000230,57.21,...
        % %         0.01296,85.62,15.64,2.146,1.823,92.78,...
        % %         0.000315,965.2,10,...
        % %     ];

        a1 = param(1) * exp((V/param(2)));
        a2 = param(3) * exp((V/param(4)));
        a3 = param(5) * exp((V/param(6)));
        B1 = param(7) * exp((V/-param(8)));
        B2 = param(9) * exp((V/-param(10)));
        Q1 = param(11) * exp((V/-param(12)));
        Q2 = param(13) * exp((V/-param(14)));
        Q3 = param(15) * exp((V/-param(16)));
        g  = param(17);
        a  = param(18);
        f  = param(19);
        c  = param(20);
        p1 = g./(1 + exp((-(V + a)/f)));
        p2 = param(21) * exp((V/param(22)));
        p3 = param(23) * exp((V/param(24)));
        B3 = ((B2*(c^4)*p1*a3*Q2)./ (a2*p2*Q1));

        % % state transitions
        dC1 = B1*C2 + Q1*I11 - C1*(2*a1 + p1);
        dC2 = 2*a1*C1 + 2*B1*C3 + (Q1/c)*I12 - C2*(B1 + a1 + c*p1);
        dC3 = a1*C2 + B2*O + (Q1/(c^2))*I13 - C3*(2*B1 + a2 + (c*c*p1));
        dO = a2*C3 + Q2*I14 - O*(B2 + p2);
        dI11 = p1*C1 + (B1/c)*I12 + Q3*I21 - I11*(Q1 + 2*c*a1 + p3);
        dI12  = 2*c*a1*I11 + 2*(B1/c)*I13 + c*p1*C2 + Q3*I22 - I12*((B1/c) + (Q1/c) + c*a1 + p3);
        dI13 = c*a1*I12 + B3*I14 + c*c*p1*C3 + Q3*I23 - I13*(2*(B1/c) + a3 + (Q1/c*c) + p3);
        dI14 = a3*I13 + p2*O + Q3*I24 - I14*(B3 + Q2 + p3);
        dI21 = p3*I11 + (B1/c)*I22 - I21*(Q3 + 2*c*a1);
        dI22 = 2*c*a1*I21 + 2*(B1/c)*I23 + p3*I12 - I22*((B1/c) + Q3 + c*a1);
        dI23 = c*a1*I22 + B3*I24 + p3*I13 - I23*(2*(B1/c) + a3 + Q3);
        dI24 = a3*I23 + p3*I14 - I24*(B3 + Q3);
        
        dstate = [dC1;dC2;dC3;dO;dI11;dI12;dI13;...
                  dI14;dI21;dI22;dI23;dI24;...
            ];
        % % function out = pow(a,b)
        % %     out = a.^b;
        % % end
end
