*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    STATE_CONFIGURED    team-SG2    
...    owner-ying.5.chen    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    release-5G21A

Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000708}
...    @{NEIGHBOR_INFO}
...    @{HANDOVER_INFO}

@{5GC000708}
...    NRCELL:a2MeasRedirectEnabled=none
...    NRBTS:actRedirect=false
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a5MeasEnabled=none

@{HANDOVER_INFO}
...    NRBTS:sgnbRelForNoHandoverEnabled=true
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
@{NEIGHBOR_INFO}
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-11:gNbId=31
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=4
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=0
...    NRBTS/NRADJNRCELL-2:gNbId=31
...    NRBTS/NRADJNRCELL-2:lcrId=11
...    NRBTS/NRADJNRCELL-2:nrarfcn=636666
...    NRBTS/NRADJNRCELL-2:physCellId=383
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=${EMPTY}
...    NRBTS/NRADJNRCELL-3:cellDepType=NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=0
...    NRBTS/NRADJNRCELL-3:gNbId=4
...    NRBTS/NRADJNRCELL-3:lcrId=2
...    NRBTS/NRADJNRCELL-3:nrarfcn=2071591
...    NRBTS/NRADJNRCELL-3:physCellId=384
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3

@{delta_003}
...    NRCELL:a2MeasRedirectEnabled=rsrp
...    NRBTS:actRedirect=false

@{delta_004}
...    NRCELL:a2MeasRedirectEnabled=none
...    NRBTS:actRedirect=true

*** Test Cases ***
5GC000708_A_0003_gNB should not configure A2 measurement event when actRedirect disabled
    [Documentation]    This user scenario describes the gNB behavior, when a UE for which context is being created
    ...    in a cell is not configured with required A2 measurement for redirection.
    [Tags]    QC_61801    003
    OnlineParamChange    ${delta_003}
    Ue Register And Pdu Session Setup
    Detach UE
    check wireshark log    ${CURDIR}${/}a2a_003${/}a2a.ini    wait_string=UEContextReleaseComplete::1



5GC000708_A_0004_gNB should not configure A2 measurement event when a2MeasRedirectEnabled disabled
    [Documentation]    This user scenario describes the gNB behavior, when a UE for which context is
    ...    being created in a cell is not configured with required A2 measurement for redirection.
    [Tags]    QC_61800    004
    OnlineParamChange    ${delta_004}
    Ue Register And Pdu Session Setup
    Detach UE
    check wireshark log    ${CURDIR}${/}a2a_004${/}a2a.ini    wait_string=UEContextReleaseComplete::1


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Ue Register And Pdu Session Setup
    [Arguments]    ${ue_id}=1
    execute egate command    state_sim_disp
    execute egate command    ue_change_location id=1 cell=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registe
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    should not contain    ${ret1}    eventA2

Detach UE
    [Arguments]    ${ue_id}=1
    execute egate command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
