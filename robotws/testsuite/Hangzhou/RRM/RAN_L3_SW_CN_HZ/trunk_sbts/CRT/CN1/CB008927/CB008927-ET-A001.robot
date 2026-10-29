*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LO    team-CN1ET
...    owner-lijun.j.jia    release-SBTS25R1    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{online_change}
...    NRBTS:actFdmScheduling=true
...    NRCELL:actFdmSchedulingInitialBWP=true
...    NRCELL:actFdmInitialDedicatedFdd=true
...    NRCELL:minRbReservedForNonSiPaging=34
...    NRCELL:raMsg2TargetRate=MCS0_SF0
...    NRBTS:actLteNrDss=false
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actRat1Alloc=true
...    NRBTS-1:rrcReestabTypeSA=sameGNB

*** Test Cases ***
CB008927-5G-ET-A001A002_RAT1_on_FR1_FDD_with_NSA_UE_attach_and_SA_UE_attach_and_RRE
    [Documentation]
    ...    1. Purpose
    ...        This case is to test the FDD scenario as below:
    ...        a. Single NSA call with Resource Allocation Type1 (RAT1) in RRC Reconfiguration
    ...        b. Single SA call and RRE with Resource Allocation Type1 (RAT1) in RRC Setup / Reconfiguration / Re-establishment
    ...    2. Configuration
    ...        actRat1Alloc set to true
    ...        rrcReestabTypeSA set to sameGNB
    ...        actFdmInitialDedicatedFdd set to true
    ...    3. Test Case Steps
    ...        a. attach NSA UE16 to cell1, Start DL traffic
    ...        b. attach SA UE1 to cell1, Start DL traffic
    ...        c. perform RRE for UE1
    ...    4. Expected Results
    ...        a. RAT1 used in NSA call
    ...        b. RAT1 used in SA call
    ...        c. RAT1 used in SA RRE procedure
    [Tags]    QC_342174    lijun.j.jia@nokia-sbell.com    A001    A002
    Online Param Change    ${online_change}
    NSA UE attach successful    id=16    target_cells=1    nwslice=1
    Traffic Should Be OK    ue_id=16    type=NSA
    Sa CA UE Register    ue_id=1    wait_timer=0.5    cell_id=1    gnb_id=2
    SA CA UE Setup PDU Session    ue_id=1    wait_timer=0.5    cell_id=1    gnb_id=2    expect_regexp=QoS Routing Table
    Traffic Send Small    ue_id=1
    Trigger RRC Reestablish with cause    ue_id=1    cell_id=1    cause=otherFailure
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A001${/}a2a.ini    wait_string=UEContextRelease

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=15

Online Param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered    sleep_time=${wait_timer}

Traffic Send Small
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=1    UE ${ue_id}: UDP DL

SA CA UE Setup PDU Session
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${expect_regexp}=QoS Routing Table
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}
    ...    sleep_time=${wait_timer}
    ${RAN_UE_NGAP_ID}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1

Trigger RRC Reestablish with cause
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed    timeout=20s

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

NSA UE attach successful
    [Arguments]    ${id}=11    ${target_cells}=1    ${nwslice}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}
