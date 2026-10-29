*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    CRT    team-L3CN3_SG2    owner-huib.miao    release-5G21A
...    CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    master_vDU    vDUCNF00    5GC000708
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${SA_UE_ID}    1

@{PARAMS_IN_SCF_CU}    @{HO}    @{A2_event}

@{HO}
...    NRBTS:actRedirect=false
...    NRBTS:sgnbRelForNoHandoverEnabled=true

@{A2_event}
...    NRCELL:a2MeasRedirectEnabled=rsrp
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a5MeasEnabled=none

@{delta_004}
...    NRCELL:a2MeasRedirectEnabled=none
...    NRBTS:actRedirect=true

*** Test Cases ***
5GC000708_A_0004_gNB should not configure A2 measurement event when a2MeasRedirectEnabled disabled
    [Documentation]    This user scenario describes the gNB behavior, when a UE for which context is
    ...    being created in a cell is not configured with required A2 measurement for redirection.
    [Tags]    QC_277298
    Delta Commission Parameters Cu    ${delta_004}
    UE Register To Cell1 Successfully And Traffic OK
    Release Ues    ue_id=${SA_UE_ID}    ue_type=sa

*** Keywords ***
UE Register To Cell1 Successfully And Traffic OK
    SA UE Register And PDU Setup
    Send Throughput
    Verify Throughput

Send Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 protocol=udp mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 protocol=udp mbps=5    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Throughput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

SA UE Register And PDU Setup
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=1
    ...    pass_regexp=QoS Routing Table    timeout=20s
    Should not contain    ${ret}    eventId eventA2
