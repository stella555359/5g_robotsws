*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            sherry.zhang    team-SGT&A    release-SBTS23R4    AP_REG
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${BTSLOG_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}
...    4681

@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

@{PARAMS_IN_SCF}
...    @{32SSB}
...    @{beamswitch}
...    @{5GC002478_B007}
...    @{add_AMF2_AMF3}
...    @{CB008285_e_enable}

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251

@{beamswitch}
...    NRCELL:actRrcReconfigAtBeamSwitch=false

@{CB008285_e_enable}
...    NRBTS-1/NRCELLGRP-0:ssBurstSetPeriod=40
...    NRBTS-1/NRCELLGRP-1:ssBurstSetPeriod=40
...    NRCELL:prachConfigurationIndex=121
...    NRCELL:type0SearchSpaceConfigurationIndex=13
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:inactiveSsbFr2=576733998676505104
...    NRCELL:numOfPagingFrames=oneEighthT
...    NRCELL:fPdcchMonOccsnPo=0

@{5GC002478_B007}
...    NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=230
...    MRBTS-1/NRBTS-1:ngUeRetentionTmr=300

@{add_AMF2_AMF3}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:defaultAMF=true
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:defaultAMF=true
...    SERVEDAMF-2:administrativeState=Locked
...    SERVEDAMF-3:amfIPAddress=10.0.1.101
...    SERVEDAMF-3:defaultAMF=false
...    SERVEDAMF-3:administrativeState=Locked
#...    NRCELL-3:administrativeState=Locked
#...    NRCELL-4:administrativeState=Locked
#...    NRCELL-6:administrativeState=Locked
#...    NRCELL-7:administrativeState=Locked
#...    NRCELL-8:administrativeState=Locked
...    delete:NRCELL:ranAC

@{3AMFs}
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-3:administrativeState=Unlocked

@{actRanSharing}
...    NRBTS-1:actRanSharing=true
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    delete:NRCELL:trackingAreaDN
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-3:administrativeState=Locked

@{Change_param}
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=180

*** Test Cases ***
CB008285-ET-B016_5GC002478_B007_Verify_cell_is_still_deactive_after_NG_link_unlock_as_cell_set_to_lock
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...    it will cover NGLink lock, GNB state from OnAir change to Configured and cell state from "Enabled,unbarred" change to "
    ...    Disabled,unbarred", then unlock NGLink, GNB state change to OnAir and cell state turn into "Enabled,unbarred"; as well cover
    ...    all NGLink and cell is locked, unlock cell or NGLink, cell is still deactive, when all NGLink and cell is unlock,cell will turn into
    ...    "Enabled,unbarred"; in addition, verify CellDeactDelayTimer is correct
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    3. Test Case Steps:
    ...        1.UE register to cell1
    ...        2.Trigger first lock AMF1 and cell1, unlock AMF1 and cell1
    ...        3.Trigger second lock cell1 and AMF1, unlock AMF1 and cell1
    ...        4.UE deregister From GNB
    ...    4. Expected Results:
    ...        1.UE register to cell1 succeed
    ...        2.AMF1 locked and NG link is down,cell1 is locked and offline, disabled, unbarred
    ...          AMF1 is unlocked and NG link is active,cell is unlocked and online, enabled, unbarred
    ...        3.cell1 is locked and offline disabled unbarred, AMF1 is locked and NG link is down
    ...          AMF1 is unlocked and NG link is active, cell is unlocked and online enabled unbarred
    ...        4.UE deregister succeed
    [Tags]    QC_302803    B016
    Precondition for case B016
    first lock NG and cell and check
    second lock NG and cell and check
    UE Deregister From GNB

CB008285-ET-B018_5GC002478_B005_Verify_gNB_and_cell_state_due_to_AMF1_SCTP_failure_when_candidate_AMF_NG-C_link_locked
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...    it will cover candidate AMF NG-C link locked and SCTP failure on AMF1, verify cell state is enabled, barred;
    ...    as well cover before NGInducedCellDeactDelayTimer time out, sctpWaitTimeInitSeqRetry time out NGlink will result to Active
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       ngInducedCellDeactDelayTimer=60,sctpWaitTimeInitSeqRetry=230,waitForRecovBeforeCellBarringTimer=30
    ...       after online change:
    ...       ngInducedCellDeactDelayTimer=180,sctpWaitTimeInitSeqRetry=230,waitForRecovBeforeCellBarringTimer=30
    ...    3. Test Case Steps:
    ...        1.UE register to cell1
    ...        2.Trigger lock AMF2 and AMF3
    ...        3.Set SCTP failure on AMF1 and Wait for ngInducedCellDeactDelayTimer expires
    ...        4.Wait for ng link up(sctpWaitTimeInitSeqRetry Timer expires)
    ...        5.online change ngInducedCellDeactDelayTimer paramter
    ...        6.Set SCTP failure on AMF1
    ...        7.Wait for ng link up
    ...        8.UE deregister From GNB
    ...    4. Expected Results:
    ...        1.UE register to cell1 succeed
    ...        2.AMF2 and AMF3 is locked and NG link is down
    ...        3.NG link1 is down but cell is enabled, barred,after ngInducedCellDeactDelayTimer expires GNB State Is Configured,
    ...          cell is disabled, unbarred and UE is released,NG SCTP endpoint broken alarm is visible
    ...        4.NG link1 is OK and cell is enabled, unbarred,NG SCTP endpoint broken alarm is clear
    ...        5.online change ngInducedCellDeactDelayTimer successfully
    ...        6.NG link1 is down but cell is enabled, barred,NG SCTP endpoint broken alarm is visible
    ...        7.NG link1 is OK and cell is enabled, unbarred,NG SCTP endpoint broken alarm is clear
    ...        8.UE deregister succeed
    [Tags]    QC_302792    B018
    OnlineParamChange    ${3AMFs}
    Trigger one L3 call
    Lock NG link2 and NG link3
    Set SCTP failure on NGlink1 and check 1st
    Wait SCTP on NGlink and check result
    OnlineParamChange    ${Change_param}
    Set SCTP failure on NGlink1 and check 2nd
    Wait SCTP on NGlink and check result
    UE Deregister From GNB

CB008285-ET-B017_5GC002478_B002_Verify_gNB_and_cell_state_not_changed_with_RanSharing_when_original_AMF_inactive
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...    it will cover 2 AMFs on same PLMN when one NG link lock with RanSharing, meanwhile verify gNB and cell state
    ...    is not change
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    3. Test Case Steps:
    ...        1.Trigger two L3 call
    ...        2.Lock AMF1
    ...    4. Expected Results:
    ...        1.Two L3 call can be successful
    ...        2. AMF1 is locked and NG link is down.Cell is online, enabled, unbarred. Two UE is not Released.
    [Tags]    QC_302793    B017
    OnlineParamChange    ${actRanSharing}
    Make Sure NG Link1 And NG Link2 Are UP
    Trigger two L3 call
    Disable NG Link1
    Check cell status and two UE not released

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=2 pointer=2 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.101:38412 region=1 set_id=2 pointer=3 name=SimModeAMF3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 ue=all amf=1-3 default=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1-3
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 ue=all amf=1-3
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on
    update cfg    amf_ng_setup_param id=2 relative_capacity=100
    update cfg    amf_ng_setup_param id=3 relative_capacity=100
    update cfg    set_backup_amf main=1 backup_amfs=2,3

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    wait until keyword succeeds    3min    10s    Cells Should Be OnAir    cell_id=1

Precondition for case B016
    All Cells Should Be OnAir
#    Cells Should Be OnAir    cell_id=1
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Ue Attach to Cell1    ue_id=1    gw_id=1
    Verify Throughput    ue_id=1    sleep_time=10s

All Cells Should Be OnAir
    Cells Should Be OnAir    cell_id=1
    Cells Should Be Onair    cell_id=2    check_sib=${False}
    Cells Should Be Onair    cell_id=3    check_sib=${False}
    Cells Should Be Onair    cell_id=4    check_sib=${False}
    Cells Should Be Onair    cell_id=5
    Cells Should Be Onair    cell_id=6    check_sib=${False}
    Cells Should Be Onair    cell_id=7    check_sib=${False}
    Cells Should Be Onair    cell_id=8    check_sib=${False}

Ue Attach to Cell1
    [Arguments]    ${ue_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=100 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=40 trf_id=1    pass_regexp=Started Uplink

Verify Throughput
    [Arguments]    ${ue_id}    ${Tput_dl}=90    ${Tput_ul}=35    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

first lock NG and cell and check
    Lock NG link and cell
    Unlock NG link and cell

second lock NG and cell and check
    Lock cell and NG link
    Unlock NG link and cell

Lock NG link and cell
    Disable NG Link1
    Check result for lock NG link
    Lock cell1
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred

Unlock NG link and cell
    Lock or unlock NG link    operation=Unlocked
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Check BTS state
    Unlock Cell1
    Check result for unlock cell

Lock cell and NG link
    Lock cell1
    Check result for lock cell
    Disable NG Link1
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Check BTS state    operationalState=configured

Check result for lock NG link
    Check BTS state
    Check cell state as expected    operationalState=enabled    barringStatus=barred
    wait until keyword succeeds    2min    10s    Check BTS state    operationalState=configured
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    sleep    5s
    UE should be IDLE
    UE Deregister From GNB

Check result for unlock cell
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Check BTS state
    All Cells Should Be OnAir
#    Cells Should Be OnAir    cell_id=1
    Ue Attach to Cell1    ue_id=1    gw_id=1
    sleep    10s
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Verify Throughput    ue_id=1    sleep_time=10s

Check result for lock cell
    Sleep    5s
    UE should be released
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Check BTS state

Lock or unlock NG link
    [Arguments]    ${operation}
    delta commission parameters    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=${operation}

Check BTS state
    [Arguments]    ${operationalState}=onAir    ${timeout}=120
    Object Should Exist    NRBTS:operationalState=${operationalState}    timeout=${timeout}

Check cell state as expected
    [Arguments]    ${operationalState}    ${barringStatus}    ${timeout}=120
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=${operationalState}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=${barringStatus}

UE should be released
    [Arguments]    ${ue_id}=1
    execute egate command    ue_disp id=${ue_id} state=OFF     pass_regexp=OFF

UE should be IDLE
    [Arguments]    ${ue_id}=1
    execute egate command    ue_disp id=${ue_id} state=IDLE     pass_regexp=IDLE

UE Deregister From GNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached

Make Sure NG Link1 And NG Link2 Are UP
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Active
    Object Should Exist    SERVEDAMF-2:ngLinkStatus=Active

Trigger two L3 call
    Ue Attach to Cell1    ue_id=1    gw_id=1
    Ue Attach to Cell1    ue_id=2    gw_id=2
    Verify Throughput    ue_id=1    sleep_time=10s
    Verify Throughput    ue_id=2    sleep_time=10s

Check cell status and two UE not released
    Check cell state as expected    operationalState=enabled     barringStatus=unbarred
    Check BTS state
    Verify Throughput    ue_id=1    sleep_time=10s
    Verify Throughput    ue_id=2    sleep_time=10s

Lock NG link2 and NG link3
    Disable NG Link2
    Disable NG Link3

Trigger one L3 call
    Ue Attach to Cell1    ue_id=1    gw_id=1
    Verify Throughput    ue_id=1    sleep_time=10s

Set SCTP failure on NGlink1 and check 1st
    Execute Egate Command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=abort    NG Link Drop
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Inactive
    Check BTS state    operationalState=onAir
    Check Alarm 7304 Raised
    Check cell state as expected    operationalState=enabled    barringStatus=barred
    Check BTS state    operationalState=configured    timeout=60
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    UE should be IDLE
    UE Deregister From GNB

Set SCTP failure on NGlink1 and check 2nd
    Execute Egate Command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=abort    NG Link Drop
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Inactive
    Check BTS state    operationalState=onAir
    Check Alarm 7304 Raised
    Check cell state as expected    operationalState=enabled    barringStatus=barred
    Check BTS state    operationalState=configured    timeout=180
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    UE should be IDLE
    UE Deregister From GNB

Wait SCTP on NGlink and check result
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Active    timeout=230
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Check BTS state
    Check Alarm 7304 cleared
    wait until keyword succeeds    2min    10s    Cells Should Be OnAir    cell_id=1
    Ue Attach to Cell1    ue_id=1    gw_id=1
    Verify Throughput    ue_id=1    sleep_time=10s

Check Alarm 7304 Raised
    ${fault7304}    create list    fault_id=7304
    fm fault should be raised    ${fault7304}

Check Alarm 7304 cleared
    ${fault7304}    create list    fault_id=7304
    fm fault should be cleared    ${fault7304}
