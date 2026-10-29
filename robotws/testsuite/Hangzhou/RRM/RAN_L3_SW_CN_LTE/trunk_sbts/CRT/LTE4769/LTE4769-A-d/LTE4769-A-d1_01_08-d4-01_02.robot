*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               owner-yu.1.zhou    team-SG4    release-SBTS19A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_01_02_FLAG}
...    @{rtpm_params_for_01_02}
@{PARAMS_FOR_01_02_FLAG}
...    LNBTS/PMRNL-1:mtUEQuantity=15min
@{rtpm_params_for_01_02}
...    LNBTS:actRtPerfMonitoring=All_PM_Counters
...    PMCADM-1:rTPmCollEntity:rTPmCollEntityHost=10.0.1.1
...    PMCADM-1:rTPmCollEntity:rTPmCollEntityPortNum=49525
...    PMCADM-1:rTPmCollEntity:rTPmCollInterval=60s
@{PARAMS_FOR_FEATURE_01_08_FLAG}
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_TDD-0:actConvVoice=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actHOtoWcdma=true
...    LNBTS:actHoFromUtran=true
...    LNBTS:actRedirect=enabled
...    LNBTS:actServBasedMobThr=true
...    LNBTS:pwrFallbackCa=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=40742
...    LNCEL-2/LNCEL_TDD-0:earfcn=40940
...    LNCEL-3/LNCEL_TDD-0:earfcn=41138
...    LNCEL:a2RedirectQci1=enabled
...    LNCEL:ulsMinTbs=104
...    LNCEL:ulsMinRbPerUe=3
...    LNCEL:actUePowerBasedMobThr=true
...    LNCEL:rsrqRedirectParams:threshold4Rsrq=-38
...    LNCEL:cellTechnology=TDD
...    LNCEL-1:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-1:rsrqMobilityParams:threshold2aRsrq=34
...    LNBTS/LNBTS_TDD-0:preventPsHOtoWcdma=None
...    LNBTS:actDLCAggr=false
...    LNCEL-1:inactivityTimer=60000
...    LNCEL/CDFIM-1:rttBdClList:idleLBRttCelResPrio=2
@{PRAMS_FOR_HIGH_PRIORITY_01_08}
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS/LNBTS_TDD-0:actIMSEmerSessR9=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNBTS/LNBTS_TDD-0:actHighPrioServices=true
...    LNBTS:hpsSessConfig:hpsSessArpMax=4
...    LNBTS:hpsSessConfig:hpsSessArpMin=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrcEmergency=15
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=7
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addEmergencySessions=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:minNumEmergencySessions=8
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:minNumRrcNoDrb=5
...    LNCEL-1/LNCEL_TDD-0:maxNumQci1Drb=0
...    LNCEL-1/LNCEL_TDD-0:maxNumActDrb=2
...    LNCEL-1/LNCEL_TDD-0:maxNumActUE=2
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUeDc=1
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=1
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=1
...    LNCEL-1/LNCEL_TDD-0:addNumDrbRadioReasHo=0
...    LNCEL-1/LNCEL_TDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_TDD-0:addNumQci1DrbTimeCriticalHo=1
...    LNCEL-1/LNCEL_TDD-0:addNumQci1DrbRadioReasHo=1
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=false
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addAUeRrHo=0
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addAUeTcHo=0
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemCap=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=true
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false
...    LNBTS:imsEmerPlmnConfig:emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessMnc=3
...    LNBTS:imsEmerPlmnConfig:emerSessMncLen=2
${UE_EUTRA_CAPABILITIES_CAT20_TDD}
...    SEPARATOR=
...    D180000A40007F068C4F0010C3890AA5643400C1086006104218210C108600407C54604301D2000820F480020B484103A4001242E900041690
...    82D21041E900049690820B4849E90004103A4001343000000000000001FF900000BF58010020478CBCD0200A40F3405F831000E72820739020
...    41039C8102002CE738000801149000C200000400015800
${ACTIVE_UE_DL_CAT_21_AVG}    M8051C180
${ACTIVE_UE_DL_CAT_20_AVG}    M8051C179
${ACTIVE_UE_DL_CAT_19_AVG}    M8051C137
${ACTIVE_UE_DL_CAT_18_AVG}    M8051C136
${ACTIVE_UE_DL_CAT_17_AVG}    M8051C135
${ACTIVE_UE_DL_CAT_16_AVG}    M8051C9
${ACTIVE_UE_DL_CAT_15_AVG}    M8051C8
${ACTIVE_UE_DL_CAT_14_AVG}    M8051C7
${ACTIVE_UE_DL_CAT_13_AVG}    M8051C6
${ACTIVE_UE_DL_CAT_12_AVG}    M8051C5
${ACTIVE_UE_DL_CAT_11_AVG}    M8051C4
${ACTIVE_UE_DL_CAT_10_AVG}    M8051C3
@{PM_COUNTERS_FOR_01_02_BEFORE}
...    LNCEL-1:${ACTIVE_UE_DL_CAT_21_AVG}=0
...    every LNCEL-1:${ACTIVE_UE_DL_CAT_20_AVG}=30
...    LNCEL-1:${ACTIVE_UE_DL_CAT_19_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_18_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_17_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_16_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_15_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_14_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_13_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_12_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_11_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_10_AVG}=0
@{PM_COUNTERS_FOR_01_02_AFTER}
...    every LNCEL-1:${ACTIVE_UE_DL_CAT_20_AVG}=0
${Timer_waste_rtpm_produce}    120

*** Test Cases ***
LTE4769_A_d4_ET_01_02_Counter_DL Category 20_TDD
    [Tags]
    Thirty Two UEs attach
    Do Data Transfer to Make Sure UE Active    ue_id_start=3    ue_id_stop=32
    Wait Time to Make Rtmp in Next Loop
    Start Rtpm Counter    tag=1st
    Check Rtpm Counters    ${PM_COUNTERS_FOR_01_02_BEFORE}    tag=1st
    Stop Data Transfer FOR CASE 01_02 UE    ue_id_start=3    ue_id_stop=32
    Thirty Two Ues detach
    Wait Time to Make Rtmp in Next Loop
    Start Rtpm Counter    tag=2nd
    Check Rtpm Counters    ${PM_COUNTERS_FOR_01_02_AFTER}    tag=2nd

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    3CELLs    ue_count=32
    execute egate command    sim_trace mme=1 protocol=s1 on

Thirty Two UEs attach
    [Arguments]    ${ue_id}=3..32
    ${V_3}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CAT20_TDD} enb=1 cell=1
    execute uex command    ${V_3}

Do Data Transfer to Make Sure UE Active
    [Arguments]    ${ue_id_start}=${UE1}    ${ue_id_stop}=${UE1}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
        execute uex command    trf_data_start ue=${ue_id} qci=8 dir=dl kbps=30 protocol=udp
    END

Stop Data Transfer FOR CASE 01_02 UE
    [Arguments]    ${ue_id_start}=${UE1}    ${ue_id_stop}=${UE1}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
        execute uex command    trf_data_stop ue=${ue_id}
    END

Wait Time to Make Rtmp in Next Loop
    Sleep    ${Timer_waste_rtpm_produce}

Thirty Two Ues detach
    [Arguments]    ${ue_id}=3..32
    execute uex command    ue_detach id=${ue_id}