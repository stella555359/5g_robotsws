*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    release-Legacy
...               DevHZ5_SG4    owner-chenghong.li    owner-rebecca.zhong
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{Related_Feature_Switch}
@{Related_Feature_Switch}
...    LNCEL-1:inactivityTimer=2000
...    LNCEL/SIB-0:siWindowLen=20ms
...    LNCEL/LNCEL_TDD-0:tddFrameConf=1
...    LNCEL/LNCEL_TDD-0/MPUCCH_TDD-0:cellSrPeriod=40ms
...    LNCEL/LNCEL_TDD-0:tddSpecSubfConf=5
...    LNCEL/LNCEL_TDD-0:maxNumUeDlDwPTS=0
...    LNCEL-1/SIB-0:sib2xTransmit=true
...    LNCEL-1:threshold2InterFreq=60
...    LNCEL-1:actOtdoa=true
...    LNCEL-1/LNCEL_TDD-0:prsConfigurationIndex=474
...    LNCEL-1:prsBandwidth=50 PRB
@{delta_para_A_04-02}
...    LNBTS-1:actCMAS=true
...    LNCEL-1/SIB-0:sib2Scheduling:siMessagePeriodicity=160ms
...    LNCEL-1/SIB-0:sib3Scheduling:siMessagePeriodicity=160ms
...    LNCEL/SIB-0:sibSchedulingList:siMessagePeriodicity=320ms|siMessageSibType=SIB6
...    LNCEL/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB6
...    LNCEL/SIB-0:sibSchedulingList:siMessagePeriodicity=160ms|siMessageSibType=SIB7
...    LNCEL/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB7
...    LNCEL/SIB-0:sibSchedulingList:siMessagePeriodicity=160ms|siMessageSibType=SIB12
...    LNCEL/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB12
...    LNCEL-1/SIB-0:siWindowLen=20ms
...    delete:LNCEL-1:qci1ProtectionTimer
...    LNCEL/UFFIM-1:tResUtra=1
...    LNBTS:warnAreaCoAllowed=true
...    LNBTS:actCmasTransOptimization=false
${TTITRACE_FLAG}    ${True}
${wait_sib_collect}    60s

*** Test Case ***
LTE2120-A_04_02_ETWS_CMAS_Frame1_5_with PRS_320ms
    [Tags]
    Delta Commission Parameters    ${delta_para_A_04-02}
    UE attach to eNB1
    Send Inter_freq A2 MR
    Send CMAS info
    RELEASE ALL UES
    check enb ttitrace    ${CURDIR}/LTE2120-A-04-02/a2a.ini

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=100
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

UE attach to eNB1
    Execute Uex Command    ue_attach id=1 cell=1

Send Inter_freq A2 MR
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=57    #A2 RSRP=-80

Send CMAS info
    [Arguments]    
    ${V_1}  catenate
    ...    mme_warn_request enb=1 msg_id=4370 warn_msg_contents=1111111111111111111111111111111111111111111111111111 rep_period=20
    ...    data_coding_scheme=1
    Execute Egate Command    ${V_1}    #CMAS warning
    sleep    ${wait_sib_collect}

