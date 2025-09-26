close all; clear; clc;
    delete(gcp('nocreate'))
    % % parpool('local',20) 
    poolsize = 20;
    parpool(poolsize)
    % % to = tic;
    
    % %==========================================================================
    % % Initial condtions
    % % ====================================================================
    
    global ic
    ic = [0.6478, 0.0178, 0.0002, 0.0000,0.2595,...
    0.0071, 0.0001 , 0.0014, 0.0650, 0.0000, ...
    0.0000, 0.0000 , 0.0000, 0.0010 ];
    % % ic = ic(1:12);
    ic = ic(1:5);
    
    % %===============================================================================
    % %  Experimental Data
    % %    I-V Curve 
    % %===============================================================================
    % % locQ = "/home/anthonyowusu-mensah/Desktop/QuentinOptimization/NewDawn/";
    filename = "Quentin.xlsx";
    % % filename = locQ + "/" + filename;
    %%% I-V Curve
    sel = 1;
    Erevs = [3.24745, 6.75739, 4.33322];
    cols = [2, 5 ,8];
    col = cols(sel); % WT column
    global expINaIVData;
    IV = xlsread(filename,1);
    expINaIVData(:,1) = IV(:,1);
    % % load("scaleMahaj.mat")
    % % expINaIVData(:,2) = IV(:,col).*scale_Mahaj;
    load("scaleMahaj.mat")
    % % scaleVal = 8/12;
    scaleVal = 1.0;
    % % expINaIVData(:,2) = IV(:,col).*scale_Mahaj*scaleVal;
    scale_Mahaj = 1.0;
    expINaIVData(:,2) = IV(:,col).*scaleVal;

    
    % % Activation Curve
    global ActivationCurve
    act = xlsread(filename,2);
    ActivationCurve(:,1) = act(:,1);
    ActivationCurve(:,2) = act(:,col);
    
    % % %%% InActivation Curve
    global InActivationCurve
    Inact = xlsread(filename,3);
    InActivationCurve(:,1) = Inact(:,1);
    InActivationCurve(:,2) = Inact(:,col);
    
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
    dataW = data.WT;
    % % WT
    t_w = dataW(:,1); 
    d_w = dataW(:,3);
    len_w = length(d_w); 
    t_w  = t_w(1:len_w);
    idxTval = find(isnan(t_w));
    t_w(idxTval) = [];
    d_w(idxTval) = [];
    Persistent = zeros(length((t_w)), 1);
    Persistent(:,1) =  t_w;
    Persistent(:,2) =  0.58;
    % % Persistent(:,2) =  0.1853;
    persVal= Persistent(:,2);
    persVal = persVal(1); 

    % %======================================================================
    % % Parameters
    % %========================================================================
    % % nvars = 25;
    nvars = 34;
    % % startValue = 50;
    % % boundFac = 100;
    % % paramBounds = startValue .* ones(nvars, 1);
    lb = 0 .* ones(nvars, 1);
    ub = inf .*ones(nvars, 1);  

    % %============================================================================  
    global odeFun;
    odeFun = @emiLioModel;
    global Erev;
     %% Reversal Potents
    Erev = Erevs(sel); % Reversal Potential From Paper
    global fac;
    fac = 1;
    global INa_Curr;  
    INa_Curr = @INa_Curr;
    global key
    key = "EM";
    % % Minimization of objective function
    fun = @SCORE_TRY_PSO_IV_ACT_SSA_REC_PERS_Rev;
    % % default_valsF1 = textread('Vent_WT.txt'); % % Default Parameters
    % % load('MahajZheng-PSW-295-WT-Score-12347-0.1853.mat')
    % % default_valsF1 = valsF1';
    % % default_fvalF1 = fun(default_valsF1); 
    % % param = default_valsF1;
    % % param = [9.435,39.70,441.1,6.593,11.17,11.64,...
    % %                 0.000037,7.770,0.2241,21.13,0.000020,...
    % %                 13.07,0.000302,47.08,0.000230,57.21,...
    % %                 0.01296,85.62,15.64,2.146,1.823,92.78,...
    % %                 0.000315,965.2,10,...
    % %             ];

    % % Emilio Model
    param = [8,16,9,2,82,5,8,26,9,3,92,5,8,50,4,6,10,100,...	
    1.0e-05,20,10,0.35,122,9,...
    0.04,78,10,0.00018,60,5,0.001825,88,31,10];

    default_valsF1 = param';
    default_fvalF1 = fun(default_valsF1);
    
    % % ============================================================
    % % Run Fminsearch
    

    % %=======================================================================
    MaxIterFminSearch = 150;
    optsFmin = optimset('PlotFcns',@optimplotfval,'Display','iter','TolFun',1e-2, 'TolX', 1e-2, 'MaxFunEvals', 500000000, 'MaxIter',MaxIterFminSearch);
    curDir = pwd;
    % % FileFmin=curDir + "/emilioModel-Fmin-295-WT-Score-12346-log-" + num2str(persVal) + ".mat";
    FileFmin=curDir + "/emilioModel-Fmin-295-WT-Score-12346-log-" + "Test" + ".mat";
    if ~exist(FileFmin,'file')
	    try
	         % [valsF1 , fvalF1] = particleswarm(fun,nvars,lb,ub,opts);
	    [valsFm , fvalFm] = fminsearchbnd(fun,param,lb,ub,optsFmin);
	    catch ME
	        disp(ME.message);
	        valsFm = default_valsF1;
	        fvalFm = default_fvalF1;
	    end
	    save(FileFmin,"valsFm","fvalFm")
   else
      start =load(FileFmin);
      valsFm = start.valsFm;
      fvalFm = start.fvalFm;
    end

    % % ====================================================================
    % % Run PSO
    % %=======================================================================
    SwarmSize = 100; %% SwarmSize
    MaxIterationsFminc = 5; % % Maximum number of iterations (Fminc)
    MaxIterationsPSO = 250; % % Maximum number of iterations (PSO)
    minFac = 0.25; % Minimum Factor for bouunds
    maxFac = 5; % Maximum Factor for bouunds

    % % Generate Initial Matrix
    repIni = repmat(valsFm,SwarmSize,1);
    initialSwarmMatrix = repIni .* (minFac + (maxFac - minFac)* rand(SwarmSize, nvars));
    initialSwarmMatrix(1,:) = valsFm;
    % % lbPSO = minFac * valsFm;
    % % ubPSO = maxFac *  valsFm;
    lbPSO = 0 .* ones(nvars, 1);
    ubPSO = inf .*ones(nvars, 1);
    % % threshVal = 1.5 * 10^6; 
    % % ubPSO = threshVal .*ones(nvars, 1);

    % % % % PSO Solver options
    hypbripots = optimoptions('fmincon','MaxIterations', MaxIterationsFminc, 'Display', 'iter','MaxFunctionEvaluations',500000);
    optsPSO = optimoptions('particleswarm','PlotFcn','pswplotbestf','SwarmSize',SwarmSize,'Display', 'iter',...
    'MaxIterations',MaxIterationsPSO,'InitialSwarmMatrix',initialSwarmMatrix);
    optsPSO.MinNeighborsFraction = 1;

    % % hypbripots = optimoptions('fmincon','MaxIterations', MaxIterationsFminc, 'Display', 'iter','MaxFunctionEvaluations',500000);
    % % optsPSO = optimoptions('particleswarm','PlotFcn','pswplotbestf','SwarmSize',SwarmSize,'Display', 'iter',...
    % %     'MaxIterations',MaxIterationsPSO,'InitialPoints',initialSwarmMatrix);
    % % optsPSO.MinNeighborsFraction = 1;

    for k = 1
    	filePSW="emiLioModel-PSW-295-WT-Score-12346-iter-log-" + num2str(k) + "-" + num2str(persVal) + ".mat";
	    try

	        [valsF1 , fvalF1] = particleswarm(fun,nvars,lbPSO,ubPSO, optsPSO);

	    catch ME
	        disp(ME.message);
	        valsF1 = default_valsF1;
	        fvalF1 = default_fvalF1;
	    end
	    save(filePSW,"valsF1","fvalF1")
    end

    % % % % tend = toc;
delete(gcp('nocreate'))
