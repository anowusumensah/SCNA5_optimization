 
function dstate=emiLioModel(t,state,Vcm,param,Protocol,wait)
        C1			= state(1,:);
		C2			= state(2,:);
        O1			= state(3,:);
        I1			= state(4,:);
        I2          = state(5,:);
      
        

        % % Trec = 295;  % Temperature that it was recorded
        % % Q10 = 3;
        % % Tfactor = 1.0./(pow(Q10, (37.0-(Trec-273))./10.0)); % Temperature correction factor
        V = Protocol(t, Vcm,wait); % Apply protocol
        % Nav1.5 channel transitions
        % % param = [9.435,39.70,441.1,6.593,11.17,11.64,...
        % %         0.000037,7.770,0.2241,21.13,0.000020,...
        % %         13.07,0.000302,47.08,0.000230,57.21,...
        % %         0.01296,85.62,15.64,2.146,1.823,92.78,...
        % %         0.000315,965.2,10,...
        % %     ];


        % % Rate
        % % R_hyp = Bhy.* 1./(1 + exp((V - Vhyp)./K_hyp));
        % % R_dep = Bdep.*1./(1 + exp(V - Vdep)./-K_dep);       
        % % C1C2 = param(1).*1./(1 + exp(V - param(2))./-param(3));
        
        C1C2 = param(1) * 1./(1 + exp((V-param(2))./-param(3)));
        C2C1 = param(4).* 1./(1 + exp((V + param(5))./ param(6))) + ...
            param(1) * 1./(1 + exp((V-param(2))./-param(3)));
        
        C2O1 = param(7) * 1./(1 + exp((V-param(8))./-param(9)));
        O1C2 = param(10).* 1./(1 + exp((V + param(11))./ param(12))) + ...
            param(7) * 1./(1 + exp((V-param(8))./-param(9)));
        
        O1I1 = param(13).* 1./(1 + exp((V + param(14))./ param(15))) + ...
            param(16) * 1./(1 + exp((V-param(17))./-param(18)));
        I1O1 = param(19).* 1./(1 + exp((V + param(20))./ param(21)));

        
        I1C1 = param(22).* 1./(1 + exp((V + param(23))./ param(24)));
        C1I1 = param(25) * 1./(1 + exp((V+param(26))./-param(27)));

        I1I2 =  param(28) * 1./(1 + exp((V + param(29))./-param(30)));   
        I2I1 =  param(31).* 1./(1 + exp((V + param(32))./ param(33)));


        dC1 = I1C1*I1 + C2C1*C2 - (C2C1 + C1I1)*C1;
        dC2 = C1C2*C1 + O1C2*O1 - (C2C1 + C2O1)*C2;
        dO1 = C2O1*C2 + I1O1*I1 - (O1C2 + O1I1)*O1;
        dI1 = I2I1*I2 + C1I1*C1 + O1I1*O1 - (I1C1 + I1I2 + I1O1)*I1;
        dI2 = I1I2*I1 - I2I1*I2;
        
                
        dstate = [dC1;dC2;dO1;dI1;dI2];
          
        % % function out = pow(a,b)
        % %     out = a.^b;
        % % end
end
