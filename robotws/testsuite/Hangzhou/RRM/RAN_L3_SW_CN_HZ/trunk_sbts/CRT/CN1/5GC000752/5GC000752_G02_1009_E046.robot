*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_TDD  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-SG2
...  owner-dan.liu  release-19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRCELL-1:maxNumOfRrcSA=0
...    NRBTS-1:cipherPrefL:nea0=9
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRCELLGRP-0:maxNumOfUsers=0
...    NRCELL-1:actDl256Qam=true
...    NRCELL-1:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL-1:dlMimoMode=2x2 Closed Loop Spatial Multiplexing

@{Online_Param_openresouce}
...    NRCELL-1:maxNumOfRrcSA=275
...    NRCELLGRP-0:maxNumOfUsers=550
...    NRBTS-1:actInactDetNSAUe=true
...    NRBTS-1:nsaInactivityTimer=40
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxInactivityTimer=20ms
...    NRCELL:drxProfile1:drxLongCycle=80ms
...    NRCELL:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot

@{Online_Param_DRX_64qam}
...    NRCELL-1:actDl256Qam=false
...    NRBTS-1:nsaInactivityTimer=30
...    NRCELL:drxProfile1:drxInactivityTimer=40ms
...    NRCELL:drxProfile1:drxLongCycle=40ms
...    NRCELL:drxProfile1:drxOnDurationTimer=40ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot

*** Test Cases ***
5GC000752_G02_1009_Verify_UE_call_with_DRX_and_ue_released_by_inactivetimer
    [Documentation]
    ...    1. The purpose to verify 5GC000752.5GC000772,5GC002497,5GC001009_E feature funciton verify.
    ...         1gnb2cell.gnb type=both 
    ...    2. Test Case Step:
    ...        a, UE-1 register on cell-1 setup noraml call failed by no-radio-resouce.
    ...        b, UE-31 attach failed on cell-1 by reject 
    ...        c, Online modify maxNumOfRrcSA=275 and maxNumOfUsers=550 and drx is ture
    ...        d, UE-1 and UE-31 attach success with drx and nsa be relesed after 45s
    ...        e, online modify drx with incorrect value and nsaInactivityTimer=30
    ...        f, UE-31 and UE-1 attach success without drx ,but nsa not be relesed after 25s
    [Tags]    QC_61055
    Check UE failed by no resouce
    Ue attach and check NSA be released
    Ue attach and check NSA not be released

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check UE failed by no resouce
    start to capture wireshark log    UEs_failed
    NSA UE Register failed
    sleep    1s
    SA UE Register failed
    check wireshark log    ${CURDIR}/a2a_5GC000752/a2a_UEs_failed.ini    name=UEs_failed    wait_string=UEContextReleaseComplete

Ue attach and check NSA be released
    delta commission parameters    ${Online_Param_openresouce}
    start to capture wireshark log    UEs_Success
    SA UE Attach and check traffic
    NSA ue attach and check traffic     45
    check wireshark log    ${CURDIR}/a2a_5GC000752/a2a_UEs_Success.ini    name=UEs_Success    wait_string=SgNBReleaseConfirm

Ue attach and check NSA not be released
    delta commission parameters    ${Online_Param_DRX_64qam}
    start to capture wireshark log    UEs_noDRX
    SA UE Attach and check traffic
    NSA ue attach and check traffic     25
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000752${/}a2a_UEs_noDRX.ini    name=UEs_noDRX    wait_string=UEContextModificationResponse::2

NSA UE attach
    [Arguments]    ${ue_id}=31    ${cell_id}=1    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    successful RA


SA UE attach
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table


NSA UE Register failed
    [Arguments]    ${ue_id}=31    ${cell_id}=1    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    no-radio-resources-available-in-target-cell
    [Teardown]    NSA UE Detach From GNB

SA UE Register failed
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    RRC Reject was received

SA UE Deregister From GNB
    [Arguments]  ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_detach id=${ue_id}    detached

NSA ue attach and check traffic
    [Arguments]    ${wait_time}
    NSA UE attach     
    traffic should be ok    ue_id=31    type=NSA
    sleep    ${wait_time}
    [Teardown]    NSA UE Detach From GNB

SA UE Attach and check traffic
    [Arguments]    ${ue_id}=1
    SA UE attach
    traffic should be ok    ue_id=${ue_id}    type=SA
    [Teardown]    SA UE Deregister From GNB 
