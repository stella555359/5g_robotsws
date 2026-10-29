*** Settings ***
Documentation
...    author:  susana.yan@nokia-sbell.com
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_AVQL_72e
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-CLOUD_5G_I_MP_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
#${AUTO_ANALYSIS_FLAG}    ${False}
${SYSCOM_FLAG}    ${True}
${RECREATE_WIRESHARK_FLAG}    ${False}
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

*** Test Cases ***
CB013355_SR_A_B_Verify the eCPRI counter works in the newly introduced Nokia proprietary 7-2e Split Front-haul solution with 64TRX RRU
    [Documentation]
    ...    The test scenario is intended to verify This user scenario:
    ...    the eCPRI counters below works in the newly introduced Nokia proprietary
    ...    7-2e Split Front-haul solution with 64TRX RRU
    ...    Counters:
    ...    M55318C00003    ECPRI_UP_MSG_RAU_RCV_ON_TIME
    ...    M55318C00005    ECPRI_UP_MSG_RAU_RCV_TOO_EARLY
    ...    M55318C00007    ECPRI_UP_MSG_RAU_RCV_TOO_LATE
    ...    M55318C00009    ECPRI_UP_MSG_RAU_RCV_CORRUPT
    ...    M55318C00020    ECPRI_CP_MSG_RAU_SEND_ALL
    ...    M55318C00021    ECPRI_MSG_RAU_SEND_ALL
    ...    M55318C00026    ECPRI_MSG_RAU_RCV_ALL
    ...    Case steps:
    ...    1.setup SA call and start traffic for UE1-5 sucessfully
    ...    2.Trigger UL Fronthaul Control Early TestMode Set to test early packets
    ...    3.Trigger UL Fronthaul Control Delay TestMode Set to test delay packets
    ...    4.Check counters.
    ...    Expected Results:
    ...        1. UE attached successfully, traffic is stable.
    ...        2-3. testmode set successfully.
    ...        4. ecpri counters should be produces, all counters should not equal to 0 except ECPRI_UP_MSG_RAU_RCV_CORRUPT(M55318C00009).
    [Tags]    QC_223446    A01    B01    B02    B04    B06    B07
    Clear Counter files
    Multi UE SA Attach To Target Cell with traffic
    UL Fronthaul Control Early TestMode Set
    UL Fronthaul Control Delay TestMode Set
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_B}

*** Keywords ***
Reset UL Fronthaul Control Testmode
    Execute Egate Command    ul_fronthaul_control_testmode_nr profile_id=1 delete=true
    Execute Egate Command    ul_fronthaul_control_testmode_nr profile_id=2 delete=true

UE SA Attach To Target Cell with traffic
    [Arguments]    ${cell_id}=1    ${ue_id}=1
    BuiltIn.Log    UE${ue_id} start to register...    console=${True}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    BuiltIn.Log    UE${ue_id} start to setup pDU session...    console=${True}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    QoS Routing Table
    Send Throuput    ue_id=${ue_id}   dlmbps=20    ulmbps=20
    Verify Throuput on Pcell    ue_id=${ue_id}   pcell_dl=14    ul=14

Multi UE SA Attach To Target Cell with traffic
    [Arguments]    ${ue_count}=6
    Reset UL Fronthaul Control Testmode
    FOR     ${ue_id}    IN RANGE    1    ${ue_count}
         UE SA Attach To Target Cell with traffic    ue_id=${ue_id}
    END

UL Fronthaul Control Early TestMode Set
    #fhTimingAction=0 means Early, fhTimingAction=1 means Delay
    Execute Egate Command    ul_fronthaul_control_testmode_nr profile_id=1 messageType=FH_TIMING_EMULATION duration=150 fhTimingAction=0
    Execute Egate Command    cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_fronthaul_control profile_id=1 action=activate

UL Fronthaul Control Delay TestMode Set
    Execute Egate Command    ul_fronthaul_control_testmode_nr profile_id=2 messageType=FH_TIMING_EMULATION duration=150 fhTimingAction=1
    Execute Egate Command    cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_fronthaul_control profile_id=2 action=activate
    sleep    5s     #wait for sometime for testmode set

Send Throuput
    [Arguments]    ${ue_id}=1    ${dlmbps}=20    ${ulmbps}=20
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${dlmbps} trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${ulmbps} trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} type=pdsch
	Execute Egate Command    ue_stats_nr id=${ue_id} type=pusch

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=14    ${ul}=14
    Execute Egate Command    ue_stats_nr id=11 scell=0-7 type=pdsch
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

