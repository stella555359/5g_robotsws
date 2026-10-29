*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-DevHZ5_SG2
...    owner-jianfen.shen    5GC002177    release-5G20A    CDRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NSA_UE_ID}    31
@{PARAMS_IN_SCF}    @{5GC002177_full}

@{5GC002177_full}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:actA2SgnbRelease=true
...    @{nea}
...    @{a2MeasRelease}

@{nea}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{a2MeasRelease}
...    NRCELL:a2MeasReleaseEnabled=rsrp
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0

${X2_SGNB_REL_REQUIRED_SENT_A2}    M55112C05001
${X2_SGNB_REL_CONF_RECEIVE_A2}    M55112C05002
${X2_SGNB_REL_REQUIRED_SENT}    M55112C00007
${X2_SGNB_REL_CONF_RECEIVED}    M55112C00008


@{PM_Counters_Check}
...    NRCELL-1:NX2CC:${X2_SGNB_REL_REQUIRED_SENT_A2}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_CONF_RECEIVE_A2}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_REQUIRED_SENT}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_CONF_RECEIVED}=1


*** Test Cases ***
5GSW-CP-CIT028_Verify_Classical_NSA_TDD_cmWave_SgNB_release_due_to_A2_event_with_RSRP_SRB3_is_successful
    [Documentation]    This Test case is to verify sgnb release due to A2 event via SRB3
    ...    pre-condition:
    ...    srb3SupportEnabled:true, actA2SgnbRelease:true, a2MeasReleaseEnabled:rsrp
    ...    a2HysteresisReleaseSsbRsrp:0, a2ThresholdReleaseSsbRsrp:75, a2TimeToTriggerReleaseSsbRsrp:ms0
    ...    check msg:
    ...    check srb3 in msg SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ...    check A2 measurement configuration in msg SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ...    check A2 measurement report
    ...    check release cause "action-desirable-for-radio-reasons" in msg SgNBReleaseRequired
    ...    check msg SgNBReleaseConfirm
    ...    check counter:
    ...    M55112C05001(X2_SGNB_REL_REQUIRED_SENT_A2), M55112C05002(X2_SGNB_REL_CONF_RECEIVE_A2),
    ...    M55112C00007(X2_SGNB_REL_REQUIRED_SENT), M55112C00008(X2_SGNB_REL_CONF_RECEIVED)
    [Tags]    QC_61710
    Clear Counter files
    NSA UE Attach and Traffic
    SgNB Release Due To A2 Event Via SRB3
    Check Counters    ${PM_Counters_Check}
    check wireshark log    ${CURDIR}/a2a_CIT028/a2a.ini    wait_string=BearerContextReleaseComplete
    Release Ues    ue_type=nsa    ue_id=${NSA_UE_ID}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=reported successful RA
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}

Send Throughput
    [Arguments]    ${ue_id}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
    &{BearInfoDict}    Ap Get Bearer Stats Info    ue=${ue_id}    id=2    dir=ul    dc_cell_group=scg
    Should Be True    &{BearInfoDict}[Total packets sent]>0

SgNB Release Due To A2 Event Via SRB3
    ${meas_id_a2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${NSA_UE_ID}    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${NSA_UE_ID} meas_id=${meas_id_a2} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
