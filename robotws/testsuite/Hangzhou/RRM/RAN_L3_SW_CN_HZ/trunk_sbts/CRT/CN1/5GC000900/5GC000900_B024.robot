*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-SG02    owner-yige.g.zhang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    release-SBTS22R1
...    STATE_CONFIGURED    RAN_5G

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{ET_B024}

@{ET_B024}
...    MRBTS-1/NRBTS-1:nsaCellActivationAlarmTimer=180
...    MRBTS-1/NRBTS-1:saCellActivationAlarmTimer=180
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=300
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=239

@{fault_7304}    fault_id=7304    fault_name=NG SCTP endpoint broken

*** Test Cases ***
5GC000900-ET-B024_Verify_SA_call_released_with_Ng_linkdown_after_one_SA_call_and_one_NSA_call_setup_in_one_cell
    [Documentation]
    ...    1.Purpose
    ...      This case is to verify both cell
    ...     A.set NG Link down,trigger 7304 alarm and the SA UE dosen not attach successful
    ...     B.set NG Link up,the cell will cancel 7304 alarm ,and the SA UE can attach successful & MeNBX2-C is available
    ...    2. Test Case Steps:
    ...    Step 1. Update NIDD parameter
    ...         2. lock cell
    ...         3. Trigger NG link down and 7304 alarm raise
    ...         4. unlock cell and check 7304 still exist
    ...         5. UE attach fail
    ...         6. NG link recover and cancel 7304 alarm
    ...         7. UE attach successful
    [Teardown]    Common Test Setup And Stop To Capture Logs On B024
    [Tags]    QC_60981
    Modify waitForRecovBeforeCellBarringTimer parameter 60s
    Lock Cell1
    Trigger NG link down and 7304 alarm raise
    Unlock Cell1
    Check 7304 still exist
    SA attach fail with cell barred
    Trigger NG link up and 7304 alarm will cancel
    UEs attach to 2 cells
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check cell barred message
    ${out}    execute egate command    ib_enb_cell_disp enb=2 cell=1    SIB1
    should contain    ${out}    MIB    40    0    yes
    should contain    ${out}    SIB1    80    0    no

SA attach fail with cell barred
    execute egate command    ue_register id=1    UE1: detached
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=barred
    Check cell barred message

Modify waitForRecovBeforeCellBarringTimer parameter 60s
     Delta Commission Parameters    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=60

Trigger NG link down and 7304 alarm raise
    execute command on enb    iptables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
    execute command on enb    ip6tables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
    execute command on enb    iptables -L -n
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive    timeout=180
    wait until keyword succeeds    16 min    60 sec    fm fault should be raised    ${fault_7304}

Trigger NG link up and 7304 alarm will cancel
    execute command on enb    iptables -t filter -F OUTPUT
    execute command on enb    ip6tables -t filter -F OUTPUT
    execute command on enb    iptables -L -n
    object should exist    SERVEDAMF-1:ngLinkStatus=Active    timeout=180
    fm fault should be cleared    ${fault_7304}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred
    wait until keyword succeeds    16 min    10 sec    cells should be on air

Check 7304 still exist
    fm fault should be raised    ${fault_7304}

Common Test Setup And Stop To Capture Logs On B024
    execute command on enb    iptables -t filter -F OUTPUT
    execute command on enb    ip6tables -t filter -F OUTPUT
    execute command on enb    iptables -L -n
    Unlock Cell1
    Common Test Teardown And Stop Capture Logs

UEs attach to 2 cells
   nsa ue attach successful    31    1
   sa ue attach successful    1    1    1
   nsa ue attach successful    32    2
   sa ue attach successful    2    1    1

sa ue attach successful
    [Arguments]    ${id}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=${pdu} nwslice=${nwslice} gw=${id}    ${cmd_pdu_regexp}
    traffic should be ok    ue_id=${id}    type=SA

nsa ue attach successful
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}
    traffic should be ok    ue_id=${id}    type=NSA

Modify Cfg
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${set_ue1}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue1}