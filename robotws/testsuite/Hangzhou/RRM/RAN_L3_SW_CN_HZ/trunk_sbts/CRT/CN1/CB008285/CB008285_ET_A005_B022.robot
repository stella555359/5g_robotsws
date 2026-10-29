*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    CLOUD_5G_I_LO_AP_LO
...            owner-ha.zheng    team-CN1ET    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{beamswitch}
...    @{prach_C2}
...    @{32SSB}

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251

@{beamswitch}
...    NRCELL-1:actRrcReconfigAtBeamSwitch=true
...    NRCELL-5:actRrcReconfigAtBeamSwitch=true

@{prach_C2}
...    NRCELL:rangeExtension=0-2.3km
...    NRBTS-1/NRCELLGRP-0:ssBurstSetPeriod=20
...    NRBTS-1/NRCELLGRP-1:ssBurstSetPeriod=20
...    NRCELL:prachConfigurationIndex=175
...    NRCELL:type0SearchSpaceConfigurationIndex=8
...    NRCELL:zeroCorrelationZoneConfig=0
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:inactiveSsbFr2=576733998676505104
...    NRCELL:numOfPagingFrames=oneEighthT
...    NRCELL:fPdcchMonOccsnPo=0
...    NRCELL:totalNumberOfRAPreambles=32
...    NRCELL:cbraPreamblesPerSsb=n32

@{OnlineParam_B022_1}
...    NRBTS-1:actCsiReportsMuxOnPucch=true
...    NRBTS-1/NRCELLGRP-0:pucchF2MaxCodeRate=zeroDot15
...    NRBTS-1/NRCELLGRP-1:pucchF2MaxCodeRate=zeroDot25

@{OnlineParam_B022_2}
...    NRBTS-1:actCsiReportsMuxOnPucch=false
...    NRBTS-1/NRCELLGRP-1:pucchF2MaxCodeRate=zeroDot15

*** Test Cases ***
CB008285-ET-A005_FR2_SA_Call_setup_succ_and_tput_normal_with_32SSB
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with two CELLGROUPs which contain FR2 SA Cells.
    ...       These two CELLGROUPs are configured on two Radio Units.
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    configure NRBTS/NRCELL.actDlPtrs=true and NRBTS/NRCELL.actUlPtrs=true due to UPD001
    ...    ue cap: onePortsPTRS '11'B
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On pcell cell1
    ...        b. UE2 Register On scell cell2
    ...        c. UE3 Register And PDU Session Setup On pcell cell5
    ...        d. UE4 Register On scell cell6
    ...    3. Expected Results:
    ...        Step a: UE1 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step b: UE2 Register failed.
    ...        Step c: UE3 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step d: UE4 Register failed.
    ...        Step e: check Dlptrs and Ulptrs
    [Tags]    QC_300526    A005    LABEL-8T(8*100MHz_TDD_n257)    CIT
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=1    cell_id=1    pdu_id=1
    UE Attach To Target Cell failed    ue_id=2    cell_id=2
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=3    cell_id=5    pdu_id=2
    UE Attach To Target Cell failed    ue_id=4    cell_id=6
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_A_005${/}a2a_gnb.ini    wait_string=UEContextRelease::24

CB008285-ET-B022_UPD003_mux_pucch_resource_could_fail_or_succ_in_different_configure_of_pucchF2MaxCodeRate
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with two CELLGROUPs which contain FR2 SA Cells.
    ...       These two CELLGROUPs are configured on two Radio Units.
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    configure NRBTS:actCsiReportsMuxOnPucch=true due to UPD003
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On pcell cell1
    ...        b. UE3 Register And PDU Session Setup On pcell cell5
    ...    3. Expected Results:
    ...        Step a: UE1 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step b: UE3 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step c: check mux plexing failed of UE1 when ICS to cell1, mux plexing successfully of UE3 when ICS
    ...                to cell5.
    [Tags]    QC_305449    B022    LABEL-8T(8*100MHz_TDD_n257)    CRT
    OnlineParamChange    ${OnlineParam_B022_1}
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=1    cell_id=1    pdu_id=1
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=3    cell_id=5    pdu_id=2
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_B_022${/}a2a_gnb.ini    wait_string=UEContextRelease::24
    [Teardown]    B022_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param1}
    Delta Commission Parameters    ${Online_Param1}
    Cells Should Be Onair    cell_id=1

B022_Teardown
    OnlineParamChange    ${OnlineParam_B022_2}
    Common Test Teardown And Stop Capture Logs

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1
    ...    pass_regexp=QoS Routing Table    timeout=10s
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}

UE Attach To Target Cell failed
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ${ret}=    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=MIB or SIB1 not recieved
    Should Not Contain    ${ret}    UE now in NG RM Register

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pcell    ue_id=${ue_id}    sleep_time=10s

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_tput_except_dl}=510    ${pcell_tput_except_ul}=130    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${pcell_tput_except_ul}
