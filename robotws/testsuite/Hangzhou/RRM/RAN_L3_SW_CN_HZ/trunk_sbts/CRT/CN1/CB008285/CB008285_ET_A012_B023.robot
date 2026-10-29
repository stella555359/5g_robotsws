*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-ha.zheng    team-CN1ET    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{32SSB}
...    @{NSA_CELL}
...    @{5GC000732_Base}
...    @{HO_PARAMS}
...    @{actRedirect}

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251
...    NRCELL:prachConfigurationIndex=175

@{NSA_CELL}
...    NRBTS:gNbCuType=SA+NSA
...    NRCELL-5:cellDepType=NSA
...    NRCELL-6:cellDepType=NSA
...    NRCELL-7:cellDepType=NSA
...    NRCELL-8:cellDepType=NSA
...    delete:NRCELL-5:trackingAreaDN
...    delete:NRCELL-6:trackingAreaDN
...    delete:NRCELL-7:trackingAreaDN
...    delete:NRCELL-8:trackingAreaDN
...    delete:NRCELL-5:ranAC
...    delete:NRCELL-6:ranAC
...    delete:NRCELL-7:ranAC
...    delete:NRCELL-8:ranAC
...    NRCELL-5:configuredEpsTac=200
...    NRCELL-6:configuredEpsTac=200
...    NRCELL-7:configuredEpsTac=200
...    NRCELL-8:configuredEpsTac=200

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB

@{HO_PARAMS}
...    NRBTS-1:actIncXn=true
...    NRBTS-1:actIntraFreqHoSA=false
...    NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=11
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20
...    MRBTS-1/NRBTS-1:actConflictConfiguration=false
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms320
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=24
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:freqBandIndicatorNR=257
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=24
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=2071675
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1/NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRBTS-1/NRCELL-1:filterCoeffSsbRsrq=fc4

...    MRBTS-1/NRBTS-1:actInterFreqHoSA=false
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
...    NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-2:gNbId=1
...    NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-2:lcrId=4
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=257
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=32 beams
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms160

@{actRedirect}
...    MRBTS-1/NRBTS-1:actRedirect=false
...    MRBTS-1/NRBTS-1/NRCELL:a2MeasRedirectEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0:redirFreqNr=2071387
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0:redirSsbScs=240 KHz

@{OnlineParam_B023_1}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actRedirect=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

@{OnlineParam_B023_2}
...    NRBTS-1:actIntraFreqHoSA=false
...    NRBTS-1:actInterFreqHoSA=false
...    NRBTS-1:actRedirect=false
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled

@{pass_regexp_ue1}
...    UE1: NR RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete

*** Test Cases ***
CB008285-ET-A012_FR2_Cells_with_32SSB_and_2cellgroup_with_4_SA_cells_and_4_NSA_cells
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with two CELLGROUPs one CELLGROUP contains
    ...       FR2 SA Cells and the other contains FR2 NSA cells.
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
    ...    cellgroup1 contains cell1, cell2, cell3, cell4 which are FR2 SA cells
    ...    cellgroup2 contains cell5, cell6, cell7, cell8 which are FR2 NSA cells
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On pcell cell1
    ...        b. UE2 Register On scell cell2
    ...        c. UE91 Attach On pcell cell5 and setup bearer
    ...        d. UE92 Attach On scell cell6 and setup bearer
    ...    3. Expected Results:
    ...        Step a: UE1 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step b: UE2 Register failed.
    ...        Step c: UE91 Attach and setup bearer Successfully, tput noraml.
    ...        Step d: UE92 Attach and setup bearer Successfully, tput noraml.
    [Tags]    QC_300516    A012    LABEL-8T(8*100MHz_TDD_n257)
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=1    cell_id=1    pdu_id=1
    UE Attach To Target Cell failed    ue_id=2    cell_id=2
    Release Ues    ue_type=all
    NSA UE Attach To Target Cell Then Send And Verify Throughput    ue_id=91    cell_id=5
    Release Ues    ue_type=all
    NSA UE Attach To Target Cell Then Send And Verify Throughput    ue_id=92    cell_id=6
    Release Ues    ue_type=all

CB008285-ET-B023_UPD002_Cells_Failed_Admission_Control_during_InitialAccess_and_RrcReestablishment
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with two CELLGROUPs one CELLGROUP contains
    ...       FR2 SA Cells and the other contains FR2 NSA cells.
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
    ...    configure NRBTS:actIntraFreqHoSA=true, NRBTS:actInterFreqHoSA=true, NRBTS:actRedirect=true
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On pcell cell1
    ...           check MR of intra frequency A3, A5 inter frequency A2, A2 redirect
    ...        b. trigger UE1 RRC reestablishment request to pcell cell1
    ...           check MR of intra frequency A3, A5 inter frequency A2, A2 redirect
    ...    3. Expected Results:
    ...        Step a: UE1 Register And PDU Session Setup Successfully, tput noraml, no related MR exist
    ...        Step b: UE1 RRC reestablishment to pcell cell1 Successful, no related MR exist
    [Tags]    QC_305450    B023
    OnlineParamChange    ${OnlineParam_B023_1}
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=1    cell_id=1    pdu_id=1
    Trigger RRC Reestablish with cause
    Release Ues    ue_type=all
    [Teardown]    B023_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param1}
    Delta Commission Parameters    ${Online_Param1}
    Cells Should Be Onair    cell_id=1

B023_Teardown
    OnlineParamChange    ${OnlineParam_B023_2}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all qos_flows=1,2 qos_rules=1,2 amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all qos_flows=1,2 qos_rules=1,2 amf=1
    BuiltIn.Log    update CFG    console=${True}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:24
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${GNB3_CFG}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
    ${CELL_381}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=2071675:2071675 gscn=22446 mandatory_for_activation=off
    Update Cfg    ${CELL_381}

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1
    ...    pass_regexp=QoS Routing Table    timeout=10s
    Should Not Contain    ${ret}    EventA2
    Should Not Contain    ${ret}    EventA3
    Should Not Contain    ${ret}    EventA5
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
    [Arguments]    ${ue_id}=1    ${pcell_tput_except_dl}=510    ${pcell_tput_except_ul}=130    ${sleep_time}=10s    ${scell}=0
    sleep    ${sleep_time}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell}    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell}    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${pcell_tput_except_ul}

NSA UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=91    ${wait_timer}=0.5    ${cell_id}=5
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE    sleep_time=${wait_timer}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA    timeout=10s
    Send And Verify Throuput NSA    ue_id=${ue_id}

Send And Verify Throuput NSA
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul trf_id=1 mbps=150    UE ${ue_id}: UDP UL
    Verify Throuput on Pcell    ue_id=${ue_id}    sleep_time=10s    scell=8

Trigger RRC Reestablish with cause
    [Arguments]    ${ue_id}=1    ${cause}=reconfigurationFailure    ${pass_regexp}=${pass_regexp_ue1}
    ${ret}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${cause}
    ...    pass_regexp=${pass_regexp}
    Should Not Contain    ${ret}    EventA2
    Should Not Contain    ${ret}    EventA3
    Should Not Contain    ${ret}    EventA5
