close all; clear; clc;
    delete(gcp('nocreate'))
    % % parpool('local',20) 
    % % poolsize = 30;
    % % parpool(poolsize)
    % % to = tic;
    
    % %======================================================================
    % % Initial condtions
    % %==========================================================================
    global ic
    ic = [0.6478, 0.0178, 0.0002, 0.0000,0.2595,...
    0.0071, 0.0001 , 0.0014, 0.0650, 0.0000, ...
    0.0000, 0.0000 , 0.0000, 0.0010 ];
    ic = ic(1:12);
    
    % %===============================================================================
    % %  Experimental Data
    % %    I-V Curve 
    % %===============================================================================
    % % locQ = "/home/anthonyowusu-mensah/Desktop/QuentinOptimization/NewDawn/";
    filename = "Quentin.xlsx";
    % % filename = locQ + "/" + filename;
    % % I-V Curve
    col = 5; % WT column
    global expINaIVData;
    IV = xlsread(filename,1);
    expINaIVData(:,1) = IV(:,1);
    load("scaleMahaj.mat")
    expINaIVData(:,2) = IV(:,col).*scale_Mahaj;
    
    % % Activation Curve
    global ActivationCurve
    act = xlsread(filename,2);
    ActivationCurve(:,1) = act(:,1);
    % % Vhalf_EXP = -33.5;
    % % K_EXP = -14.2;
    % % Y_EXP = 1./(1 + exp((act(:,1) - Vhalf_EXP)/K_EXP));
    ActivationCurve(:,2) = act(:,col);
    % % ActivationCurve(:,2) = Y_EXP;
    
    % % %%% InActivation Curve
    global InActivationCurve
    Inact = xlsread(filename,3);
    InActivationCurve(:,1) = Inact(:,1);
    InActivationCurve(:,2) = Inact(:,col);
    % % InActivationCurve(:,2) = Y_EXP;
    
    % % Recovery Curve
    global RecoveryCurve
    RecCurve = xlsread(filename,4);
    RecoveryCurve(:,1) = RecCurve(:,1); 
    RecoveryCurve(:,2) = RecCurve(:,col);
    
    % % Closed State Inactivation
    global ClosedStateInactivation
    CSI = xlsread(filename,5);
    ClosedStateInactivation(:,1) = CSI(:,1);
    CSI_2 = CSI(:,col);
    % % CSI_2(CSI_2 > 1.0) = 1.0;
    ClosedStateInactivation(:,2) = CSI_2;
    
    % % Slow Inactivation
    global slowInactivation
    OSI = xlsread(filename,6);
    slowInactivation(:,1) = OSI(:,1);
    slowInactivation(:,2) = OSI(:,col);
    
    % % Persistent Current
    global Persistent
    data = importdata('Persitent current.xlsx');
    data = data.data;
    dataQ = data.Q1491H;
    % % Q1491H
    t_q = dataQ(:,1); 
    d_q = dataQ(:,3);
    len_q = length(d_q);
    t_q  = t_q(1:len_q);
    idxTval = find(isnan(t_q));
    t_q(idxTval) = [];
    d_q(idxTval) = [];
    Persistent = zeros(len_q, 2);
    Persistent(:,1) =  t_q;
    % % Persistent(:,2) =  2.66;
    Persistent(:,2) =  0.85; 
    persVal= Persistent(:,2);
    persVal = persVal(1); 
    
    % %======================================================================
    % % Parameters
    % %========================================================================
    nvars = 25;
    % % startValue = 50;
    % % boundFac = 100;
    % % paramBounds = startValue .* ones(nvars, 1);
    lb = 0 .* ones(nvars, 1);
    ub = inf .*ones(nvars, 1);  

    % %============================================================================  
    global odeFun;
    odeFun = @zhengParam;
    global Erev;
    Erev = 6.75739; % Reversal Potential From Paper
    global fac;
    fac = 100;
    global INa_Curr;  
    INa_Curr = @INa_Curr;
    global key
    key = "Z";
    % % Minimization of objective function
    fun = @SCORE_TRY_PSO_IV_ACT_SSA_REC_PERS;
    % % default_valsF1 = textread('optimizedQ1491H.txt'); % % Default Parameters
    load('MahajZheng-PSW-295-Q1491H-Score-12347-Pers-0.85.mat')
    default_valsF1 = valsF1;
    default_fvalF1 = fun(default_valsF1);
    param = default_valsF1;
    
    % % ============================================================
    % % Run Fminsearch

    % %=======================================================================
    MaxIterFminSearch = 150;
    optsFmin = optimset('PlotFcns',@optimplotfval,'Display','iter','TolFun',1e-2, 'TolX', 1e-2, 'MaxFunEvals', 500000000, 'MaxIter',MaxIterFminSearch);
    fileFmin="MahajZheng-Fmin-295-Q1491H-Score-12347-Pers-" + num2str(persVal) + ".mat";
    if ~exist(fileFmin,'file')
	    try
	         % [valsF1 , fvalF1] = particleswarm(fun,nvars,lb,ub,opts);
	    [valsFm , fvalFm] = fminsearchbnd(fun,param,lb,ub,optsFmin);
	    catch ME
	        disp(ME.message);
	        valsFm = default_valsF1;
	        fvalFm = default_fvalF1;
	    end
	     save(fileFmin,"valsFm","fvalFm") 
    else
	start=load(fileFmin);
        valsFm= start.valsFm;
        fvalFm= start.fvalFm;
    end


    % % =======================================================================
    % % Run PSO

    % %=======================================================================
    SwarmSize = 100; %% SwarmSize
    MaxIterationsFminc = 5; % % Maximum number of iterations (Fminc)
    MaxIterationsPSO = 50; % % Maximum number of iterations (PSO)
    minFac = 0.25; % Minimum Factor for bounds
    maxFac = 5; % Maximum Factor for bounds

    % % Generate Initial Matrix
    repIni = repmat(valsFm',SwarmSize,1);
    initialSwarmMatrix = repIni .* (minFac + (maxFac - minFac)* rand(SwarmSize, nvars));
    initialSwarmMatrix(1,:) = valsFm;
    lbPSO = minFac * valsFm;
    ubPSO = maxFac *  valsFm;
    % % lbPSO = 0 .* ones(nvars, 1);
    % % ubPSO = inf .*ones(nvars, 1);
    
    % % % % PSO Solver options
    hypbripots = optimoptions('fmincon','MaxIterations', MaxIterationsFminc, 'Display', 'iter','MaxFunctionEvaluations',500000);
    optsPSO = optimoptions('particleswarm','PlotFcn','pswplotbestf','SwarmSize',SwarmSize,'Display', 'iter',...
    'MaxIterations',MaxIterationsPSO,'InitialSwarmMatrix',initialSwarmMatrix);
    optsPSO.MinNeighborsFraction = 1;

    % % hypbripots = optimoptions('fmincon','MaxIterations', MaxIterationsFminc, 'Display', 'iter','MaxFunctionEvaluations',500000);
    % % optsPSO = optimoptions('particleswarm','PlotFcn','pswplotbestf','SwarmSize',SwarmSize,'Display', 'iter',...
    % %     'MaxIterations',MaxIterationsPSO,'InitialPoints',initialSwarmMatrix);
    % % optsPSO.MinNeighborsFraction = 1;
    for k = 1:3
 	    filePSW="MahajZheng-PSW-295-Q1491H-Score-12347-Pers-iter-" + num2str(k) + "-" + num2str(persVal) + ".mat";
	    try

	        [valsF1 , fvalF1] = particleswarm(fun,nvars,lbPSO,ubPSO, optsPSO);

	    catch ME
	        disp(ME.message);
	        valsF1 = default_valsF1;
	        fvalF1 = default_fvalF1;
	    end
	    save(filePSW,"valsF1","fvalF1")
    end
    %tend = toc;
delete(gcp('nocreate'))

%%

