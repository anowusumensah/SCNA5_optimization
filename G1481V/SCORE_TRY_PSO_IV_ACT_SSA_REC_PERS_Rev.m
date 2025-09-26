function scores = SCORE_TRY_PSO_IV_ACT_SSA_REC_PERS_Rev(param)
    
    global odeFun;
    global Erev;
    global fac;
    global INa_Curr;
    
    if ~exist("fac","var")
        fac = 100;
    end

    % %================================================================
    % % Evaluate transtion rates
    % %================================================================
    % % Threshold
    threshVal = 1.30 * 10^6; %%
    V = 60; % Evaluate value at 60 mV
    transition_rates = evaluateTransition(V, param);

    penalty = 0;
    if any(transition_rates > threshVal)
        penalty = sum(max(0, abs(transition_rates - threshVal)));
    end
   
    


    %%======================================================================
    % % The I-V Curve
    %%======================================================================
    global expINaIVData;  %% Activation Current TargetodeFun,param,Vcm,Erev,INa_Curr)
    actVcm = expINaIVData(:,1);
    INaIVData = expINaIVData(:,2);
    Vcm = actVcm; % Step voltages
    [p_hold,~] = ACT_rev2(odeFun,param,Vcm,Erev,INa_Curr);
    minVal = min(INaIVData);
    maxVal = max(INaIVData);
    
    % % Values have been normalized
    expVals = Normalize(INaIVData, minVal, maxVal);
    simVals = Normalize(p_hold, minVal, maxVal);
    % % score_1 = sqrt(mean(sum((expVals - simVals).^ 2)));
    score_1 = sqrt(mean(sum((expVals*fac - simVals*fac).^ 2)));


    %%====================================================================
    % % Steady State Activation
    %%===================================================================
    global ActivationCurve
    ActivationCurveVals = ActivationCurve(:,2);
    gNa = p_hold./(Vcm - Erev); 
    gNaNorm = gNa./max(gNa); 
    % % score_2 = sqrt(mean(sum((ActivationCurveVals -  gNaNorm).^2)));
    score_2 = sqrt(mean(sum((ActivationCurveVals*fac -  gNaNorm*fac).^2)));
    % % score_2 = sum((ActivationCurveVals -  gNaNorm).^2);
    
    
    %%=====================================================================
    % % InActivation Curve
    %%=====================================================================
    global InActivationCurve
    InActivationCurveVcm = InActivationCurve(:,1); 
    InActivationCurveVals = InActivationCurve(:,2);
    VcmIn = InActivationCurveVcm; % Step voltages
    [p_holdIn,~] = SSA_rev2(odeFun,param,VcmIn,Erev,INa_Curr);
    InAct = p_holdIn./min(p_holdIn);
    % % score_3 = sqrt(mean(sum((InActivationCurveVals - InAct).^2)));
    score_3 = sqrt(mean(sum((InActivationCurveVals*fac - InAct*fac).^2)));
    % % score_3 = sum((InActivationCurveVals - InAct).^2);
    
    %%========================================================================
    % % Recovery from InActivation
    %%========================================================================
    global RecoveryCurve
    RecVcm = RecoveryCurve(:,1); 
    RecVals = RecoveryCurve(:,2);
    [p1_hold,p2_hold,~,~] = REC_rev2(odeFun, param,RecVcm,Erev,INa_Curr);
    RecCal = p2_hold./min(p1_hold);
    % % score_4 = sqrt(mean(sum((RecVals - RecCal).^2)));
    score_4 = sqrt(mean(sum((RecVals*fac - RecCal*fac).^2)));
    % % score_4 = sum((RecVals - RecCal).^2);
    
   % %  % % =================================================================
   % %  % % Closed State Inactivation
   % %  % % ==================================================================
   % %  global ClosedStateInactivation
   % %  CSIVcm = ClosedStateInactivation(:,1);
   % %  CSIVals = ClosedStateInactivation(:,2);
   % %  [p1_CSI, ~] = CSI_rev2(odeFun,param,CSIVcm,Erev,INa_Curr);
   % %  CSICal = p1_CSI./min(p1_CSI);
   % %  score_5 = sqrt(mean(sum((CSICal - CSIVals).^2)));
   % % 
   % % % % ======================================================================     
   % % % % Slow Inactivation
   % % % %======================================================================
   % %  global slowInactivation
   % %  slowVcm = slowInactivation(:,1);
   % %  slowVals = slowInactivation(:,2);
   % %  [p1_OSI,p2_OSI,~] = OSI_rev2(odeFun, param,slowVcm,Erev,INa_Curr);
   % %  OSICal = p2_OSI./p1_OSI;
   % %  score_6 = sqrt(mean(sum((OSICal - slowVals).^2)));
   % % 
   % % 
    % % ======================================================================
    % % Persistent Current
    % ====================================================================
    global Persistent
    tVals = Persistent(:,1);
    pVals = Persistent(:,2);
    E_rev = 35.2400; % % Reversal Potential for Persistent current
    Vcm_h = -30; % % Holding Potential for persistent current protocol
    [~,p_holdR,peak60,~,~,~] = persistACT_rev2(odeFun,param,Vcm_h,E_rev,tVals,INa_Curr); 
    ratPeaktoPersist  = (peak60/p_holdR)*100; 
    % % score_7 = sqrt(mean(sum((ratPeaktoPersist - pVals(1)).^2)));
    % % score_7 = sqrt(mean(sum((ratPeaktoPersist/pVals(1) - pVals(1)/pVals(1)).^2)));
    score_7 = sqrt(mean(sum(((ratPeaktoPersist/pVals(1))*fac -(pVals(1)/pVals(1)) * fac).^2)));
    % % score_7 = sum((ratPeaktoPersist - pVals(1)).^2);


    % % =====================================================================
    % % Compute Scores
    % % ====================================================================
    % % scores = sum(score_1 + score_2 + score_3 + score_4 + score_5 + score_6 + score_7);
    scores = score_1 + score_2 + score_3 + score_4 + score_7;
    scores = scores + penalty;
    if isnan(scores)
        scores = inf;
    end


end


function result = Normalize(data, minVal, maxVal)
         result = (data - minVal)./ (maxVal -minVal);
end