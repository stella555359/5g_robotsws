*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        RAN_5G        RAN_5G_TDD    QCD_MN_RAN    QCP_RAN_ET
...               5GC002498    Owner_Junhui.He    CN2    SBTS00    team-DevHZ5_SG2    release-5G21A
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7300    7107    7101    7305    1900

${ue_id}    31
@{PARAMS_1}    NRBTS-1/NRCELL-1:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN
...    NRCELL:actVoNR=false
...    NRCELL:actEmergencyCall=false
...    NRCELL:msg1FrequencyStart=13

*** Test Cases ***
5GC002498-ET-B005_Verify SgNB Addition fails with SgNB Reconfiguration Completion not received on Classical
    [Tags]    QC_61181    B005
    Cell NSA parameter set
    Start tcpdump and NSA attach UE with SgNBAddtion failure
    Stop tcpdump and verify SgNBAddtion failure

5GC002498-ET-B004_Verify X2 Outgoing Reset with E1 Reset Alignment
    [Tags]    QC_61180    B004
    Start tcpdump and register UE then trigger X2 reset
    Stop tcpdump and verify X2 reset trigger E1 reset


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Cell NSA parameter set
    Delta Commission Parameters    ${PARAMS_1}
    wait until keyword succeeds    3 min    30 sec    Cells Should Be Onair    check_sib=${False}

Start tcpdump and NSA attach UE with SgNBAddtion failure
    Start To Capture Wireshark Log      sgNBAddionFailure
    sleep    5s    #sleep for capture wireshark
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE    timeout=20s
    Execute Egate Command    enb_endc_param id=1 menb_failure_scenario=dont_send_sgnb_reconf_complete
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    SCG-split to MCG is successful
    Execute Egate Command    enb_endc_param id=1 reset

Stop tcpdump and verify SgNBAddtion failure
    #sleep    60s    #sleep for capture wireshark
    #Stop Capture Wireshark Log    sgNBAddionFailure
    UE Detach
    Check WireShark Log    ${CURDIR}${/}a2a_B_05${/}TA_B_05.ini    name=sgNBAddionFailure

Start tcpdump and register UE then trigger X2 reset
    Start To Capture Wireshark Log      X2Reset
    sleep    5s    #sleep for capture wireshark
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE    timeout=20s
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    successful RA    timeout=20s
    Execute Egate Command    x2_link_reset from=1 to=2    Bearer-type change from SCG-split to MCG is successful    timeout=20s
    sleep    5s    #sleep for X2reset

Stop tcpdump and verify X2 reset trigger E1 reset
    #sleep    60s    #sleep for capture wireshark
    #Stop Capture Wireshark Log    X2Reset
    UE Detach
    Check WireShark Log    ${CURDIR}${/}a2a_B_04${/}TA_B_04.ini    name=X2Reset

UE Detach
    execute egate command    ue_detach id=${ue_id}    UE IS OFF
