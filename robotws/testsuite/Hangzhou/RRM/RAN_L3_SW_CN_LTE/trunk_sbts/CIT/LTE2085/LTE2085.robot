*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4LAPO_CUS    team-DevHZ5_SG_OPS
...               release-SBTS18    owner-chao.3.zhang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{ENABLE_ETWS}
@{ENABLE_ETWS}
...    LNBTS:actETWS=true
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB10
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB10
...    LNCEL-1/SIB-0:siWindowLen=20ms
...    LNCEL-2/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB10
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB10
...    LNCEL-2/SIB-0:siWindowLen=20ms
...    LNCEL-3/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB10
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB10
...    LNCEL-3/SIB-0:siWindowLen=20ms
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB11
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB11
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB11
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB11
...    LNCEL-2/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB11
...    LNCEL-3/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB11
@{PM_COUNTERS_ETWS}
...    LNCEL-1:LTE_Cell_Load:${NUM_WARN_ETWS_PRIM}>1
...    LNCEL-1:LTE_Cell_Load:${NUM_WARN_ETWS_SEC}>1
${NUM_WARN_ETWS_PRIM}    M8001C231
${NUM_WARN_ETWS_SEC}    M8001C232
${PM_COUNTER_INTERVAL}    1min

*** Test Cases ***
LTE2085_Interaction_with_ETWS_Broadcast
    [Tags]    CDRT    RAN_4G    RAN_4G_FDD
    Attach UE and transfer data
    Measurement Gap Configured
    Start Rtpm Counter
    Perform ETWS Broadcast
    Check Rtpm Counters    ${PM_COUNTERS_ETWS}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Attach UE and transfer data
    Execute Uex Command    ue_attach id=1 cell=1
    Execute Uex Command    trf_data_start ue=1 dir=dl Mbps=20 protocol=udp 

Measurement Gap Configured
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=meas_gap_cfg    overall_timeout=90
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=5 srsrq=20
    Flow Occurred As Expected    alias=meas_gap_cfg

Perform ETWS Broadcast
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType11 (warningMessageSegment is present)
    ...    CELL_1:RRC_SystemInformationBlockType11 (dataCodingScheme eq '0x0F')
    ...    alias=SIB11    overall_timeout=90
    ${V_2}    catenate
    ...    warn_request enb=1 msg_id=4352 rep_period=3 number=1 cell=1 warn_msg_contents=00:20:03:04:05:06:07:08:09:10:11:12:13:14:15:16:17:18:19:20
    ...    data_coding_scheme=15 concurrent=off type=earthquake alert=on popup=on
    Execute Egate Command    ${V_2}      pass_regexp=WriteReplaceWarningResponse
    Flow Occurred As Expected    alias=SIB11
    