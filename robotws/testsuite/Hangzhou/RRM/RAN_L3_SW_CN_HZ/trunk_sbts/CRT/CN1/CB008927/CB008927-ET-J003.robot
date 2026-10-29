*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LO    team-CN1ET
...    owner-lijun.j.jia    release-SBTS25R1    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB_BIP_FLAG}    ${True}
${AP_BIP_FLAG}    ${False}
@{PARAMS_IN_IPHY_XML}
...    vcell:GSCN=1570|cell=2.1
@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:actDlDynSwitchAlloc=false
...    NRBTS:actFdmScheduling=true
...    NRCELL:actFdmSchedulingInitialBWP=true
...    NRCELL:actFdmInitialDedicatedFdd=true
...    NRCELL:minRbReservedForNonSiPaging=34
...    NRCELL:raMsg2TargetRate=MCS0_SF0
...    NRBTS:actLteNrDss=false
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actRat1Alloc=true
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRCELL:actAdaptiveReTxResMcs=true
...    NRCELL:targetPctResourceReservedMcsDl=75
...    NRCELL:minPctResourceReservedMcsDl=50
...    NRCELL:targetPctResourceReservedMcsUl=75
...    NRCELL:minPctResourceReservedMcsUl=50
...    NRCELL-1:gscnOrSsPbchArfcn=1570

@{pm_counter_Check_J001_base}
...    NRBTS-1:${UE_SUPP_DL_DYNAMIC_RAT}>0
...    NRBTS-1:${UE_SUPP_DL_NO_DYNAMIC_RAT}=0
...    NRBTS-1:${DENOM_UE_RAT_SUPP}>0

@{pm_counter_Check_J001_multi}
...    NRBTS-1:${UE_SUPP_DL_DYNAMIC_RAT}>0
...    NRBTS-1:${UE_SUPP_DL_NO_DYNAMIC_RAT}>0
...    NRBTS-1:${DENOM_UE_RAT_SUPP}>0

${UE_SUPP_DL_DYNAMIC_RAT}    M55139C00029    #Number of UEs that support dynamic switching for resource allocation type in downlink
${UE_SUPP_DL_NO_DYNAMIC_RAT}    M55139C00030    #Number of UEs that don't support dynamic switching for resource allocation type
${DENOM_UE_RAT_SUPP}    M55139C00031    #UE capability denominator for RAT type

@{online_change_true}
...    NRCELL:actDlDynSwitchAlloc=true

@{online_change_false}
...    NRCELL:actDlDynSwitchAlloc=false

${NSA_Supp_dynSwitch_UECapa}    SEPARATOR=
...    E1201000014F5E030AC0020840009041B38987C284804D8041FF9863CA160704C060188A0300A61000A0F88DAC31B47498A823F96526CA0D00416C9824060C78C7FE618F285
...    81C0E1E026FFDC06FFDC000210602372687C0390400000290400000A90400001292500001A601F036F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB2
...    9282000092CA4A480002A9652501740F6E956DD03D9A55B34AB62BBB02C00F0034020100000010 dual_conn=eutra_nr ue_eutra_nr_capabilities=a10181102c0c0388
...    c000000888160641c460000024400401c0462002100008040401803080008020200c0180

${SA_Supp_dynSwitch_UECapa}    SEPARATOR=
...    E1A01000014F5E030AC0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63000A0F88DAC31B47498A823F96525CA0D00416C9824060C78C7FE618F285
...    81C0E1E026FFDD86FFDD802001800000000388C00000000841808DC9A1F00E41000000A41000002A41000004A494000069805C0DBC8DADD600A0800004B29282000032CA4A0
...    800014B29282000072CA4A0800024B292920000AA5949404D03DBA47B742B66956C577605801E006804020000000000080100210

*** Test Cases ***
CB008927-5G-ET-J003_DynamicSwitch_with_UEs
    [Documentation]
    ...    1. Purpose
    ...        This case is to test the FDD scenario as below:
    ...        a. Single NSA call with DynamicSwitch in RRC Reconfiguration
    ...        b. Single SA call and RRE with DynamicSwitch in RRC Setup / Reconfiguration / Re-establishment
    ...    2. Configuration
    ...        actRat1Alloc set to true
    ...        rrcReestabTypeSA set to sameGNB
    ...        actFdmInitialDedicatedFdd set to true
    ...    3. Test Case Steps
    ...        a. attach NSA UE31 to cell1, Start DL traffic
    ...        b. attach SA UE1 to cell1, Start DL traffic
    ...        c. Online change actDlDynSwitchAlloc to true
    ...        d. Re-attach NSA UE31, Start DL traffic
    ...        e. Perform RRE for SA UE1
    ...        f. attach NSA UE32 to cell1, Start DL traffic
    ...        g. attach SA UE2 to cell1, Start DL traffic
    ...        h. Perform RRE for SA UE2
    ...        i. Online change actDlDynSwitchAlloc to false
    ...        j. Perform RRE for SA UE1
    ...        k. Release all UEs and check counters
    ...    4. Expected Results
    ...        a. RAT1 used in for UE31 due to actDlDynSwitchAlloc=False
    ...        b. RAT1 used in for UE1 due to actDlDynSwitchAlloc=False
    ...        c. actDlDynSwitchAlloc changed to true
    ...        d. DynamicSwitch used in UE31
    ...        e. DynamicSwitch used in UE1
    ...        f. RAT1 used in for UE32 due to UECapability not support DynamicSwitch
    ...        g. RAT1 used in for UE2 due to UECapability not support DynamicSwitch
    ...        h. RAT1 used in UE2
    ...        i. actDlDynSwitchAlloc changed to false
    ...        j. DynamicSwitch used in UE1
    ...        k. Counters updated accordingly
    [Tags]    J003    QC_11214    lijun.j.jia@nokia-sbell.com
    Clear Counter Files
    Trigger NSA UE Attach    ue_id=31    cell_id=1
    Trigger SA UE Attach    ue_id=1    cell_id=1
    Online Param Change    ${online_change_true}
    Trigger NSA UE ReAttach
    Trigger RRC Reestablish with cause    ue_id=1    cell_id=1    cause=otherFailure
    Trigger NSA UE Attach    ue_id=32    cell_id=1
    Trigger SA UE Attach    ue_id=2    cell_id=1
    Trigger RRC Reestablish with cause    ue_id=2    cell_id=1    cause=otherFailure
    Online Param Change    ${online_change_false}
    Trigger RRC Reestablish with cause    ue_id=1    cell_id=1    cause=otherFailure
    Release ues    ue_type=all
    Check Counters    ${pm_counter_Check_J001_multi}
    Check WireShark Log    ${CURDIR}${/}A2A_J003${/}a2a.ini    wait_string=UEContextRelease::48

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=30

Online Param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Trigger NSA UE Attach
    [Arguments]    ${ue_id}=31    ${cell_id}=1
    NSA UE attach successful    id=${ue_id}    target_cells=1    nwslice=1
    Traffic Should Be OK    ue_id=${ue_id}    type=NSA

Trigger SA UE Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Sa CA UE Register    ue_id=${ue_id}    wait_timer=0.5    cell_id=${cell_id}    gnb_id=2
    SA CA UE Setup PDU Session    ue_id=${ue_id}    wait_timer=0.5    cell_id=${cell_id}    gnb_id=2    expect_regexp=QoS Routing Table
    Traffic Send Small    ue_id=${ue_id}

Trigger NSA UE ReAttach
    Release Ues    ue_type=nsa    ue_id=31
    NSA UE attach successful    id=31    target_cells=1    nwslice=1
    Traffic Should Be OK    ue_id=31    type=NSA

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

Modify Cfg
    Update Cfg    ue_param id=31 ue_nr_capabilities=${NSA_Supp_dynSwitch_UECapa}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Supp_dynSwitch_UECapa}
    ${GNB2_CELL1}    catenate
    ...    set_cell id=1 gnb=2 nr_arfcn=135760:126380 gscn=1570 eci=0x000021f pci=20:0 tac=200 
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x01 tdd_cell=off mandatory_for_activation=off
    Update Cfg    ${GNB2_CELL1}