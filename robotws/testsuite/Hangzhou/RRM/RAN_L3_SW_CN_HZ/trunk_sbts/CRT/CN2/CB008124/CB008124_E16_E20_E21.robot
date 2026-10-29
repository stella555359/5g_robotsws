*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-Meredith.ma
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${cg2_UE_Capabilities}    SEPARATOR=
...    E9A09000575F7A13160003C420005801262E003387A12013641873E618F28581C130180623809DC6C28C0D608C21A08107483401B5B262AC6
...    873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8002E030070004200602A0D883AC1184341020F1068032B64C55
...    890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000B80C01C001080180AA3626EB04610D04083A41A00C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00170000381506C46D608C21A0810788340195B262AC4873E238F604F8
...    C48E3C873EA39F30C7942C0E070F09FFF000007FFC000005C0000E000000003DE1E26800710400000858081507850001C46000002160561E2
...    30007104000018581587850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C
...    4D000E2080070A000002058158B89A001C46000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D
...    000E20800711800001058158B850001C46000E230000020B02B1713400388C001C28000008160561E230007118000018581007011A014404D
...    80822E801760F851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F02240810
...    3639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF8002E1E318C6318C6318C6318C3D05C0
...    078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200
...    80200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19A
...    C15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA
...    48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162
...    A83455298AA4D154062A8145526AAA0F142C02F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010
...    080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A
...    87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    @{multidrbs}
...    @{CA_related}
...    @{Pcellswitch}
...    @{8124_related_modification}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:actUlCgType2=true
...    NRCELL-11:actUlCgType2=true
...    NRBTS/NRDRB-3:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=500
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=16
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms5
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=500
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=16
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms5
...    NRCELL-1:maxGBRTrafficLimit=80
...    NRCELL-1:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=90
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=16
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-11:maxGBRTrafficLimit=80
...    NRCELL-11:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=90
...    NRCELL-11:ulConfiguredGrantType2:ulCgMaxNumPrbs=16
...    NRCELL-11:ulConfiguredGrantType2:ulCgMaxNumUeUl=2
...    NRCELL-11:ulConfiguredGrantType2:ulCgPrbStartOffset=0

@{multidrbs}
...    NRDRB_5QI-10:fiveqiValueList=4
...    NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:rlcMode=RLC_AM
...    NRDRB-3:maxDataRateGbrDl=30720
...    NRDRB-3:maxDataRateGbrUl=30720
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:discardTimer=50ms
...    NRDRB-3:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-3:maxRlcQueueingDelayGbr=20
...    NRDRB-3:maxTransferDelayGbr=20
...    NRDRB-3:queuingDelayDiscarding=Disabled
...    NRDRB-3:dscp=46
...    NRDRB_MAC-5:lcgid=5
...    NRDRB_MAC-5:delayTarget=50
...    NRDRB_MAC-5:schedulBSD=20ms
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-11:actGBRAdmissionControl=GBRService

@{CA_related}
...    MRBTS-1/NRBTS-1:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlAndUl
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=50
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:removeNotAllowed=false

@{Pcellswitch}
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-11/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=60
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms

@{case16}
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1

*** Test Cases ***
CB008124_E21_CG_Type2_deactivated_during_F_T_blind_CA_then_add_a_drb_configurated_CG_tpye2
    [Documentation]
    ...    1. This scenario describes the gNB behaviour associated with configuration of carrier aggregation for UE with
    ...    Configured Grant Type 2 already setup
    ...    2. Configuration
    ...    a.Pcell:SA FDD cell is configured with frequency in band n66 with 20MHz bandwidths.
    ...    b.Scell:SA TDD cell is configured with frequency in band n41 with 100MHz bandwidths.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.Sell addition is successful.
    ...    b.PDU session modification to add a new 5QI.CG Type 2 is setup for UE
    ...    c.UE detach.
    [Tags]    QC_281170
    UE Attach To Target Cell with one QoS flows    ue_id=81    cell_id=11    gw_id=1
    Add more drbs    ue_id=81
    Verify Multi drbs Throuput
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log     ${CURDIR}${/}a2a_CB008124_E21${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_E20_CG_Type2_activated_during_F_T_blind_CA
    [Documentation]
    ...    1. This scenario describes the gNB behaviour associated with configuration of carrier aggregation for UE with
    ...    Configured Grant Type 2 already setup
    ...    2. Configuration
    ...    a.Pcell:SA FDD cell is configured with frequency in band n66 with 20MHz bandwidths.
    ...    b.Scell:SA TDD cell is configured with frequency in band n41 with 100MHz bandwidths.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.Sell addition is successful. CG Type 2 is setup for UE
    ...    b.UE detach.
    [Tags]    QC_281169
    UE Attach To Target Cell with more QoS flows    ue_id=81    cell_id=11
    Verify Multi drbs Throuput
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log     ${CURDIR}${/}a2a_CB008124_E20${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_E16_CG_Type2_activated_at_source_and_target_cells_during_Pcell_switch
    [Documentation]
    ...    1. This scenario describes the gNB behaviour associated with inter-frequency intra-gNB intra-DU handover to
    ...    SCell (PCell switch) for UE with CG Grant Type 2 already setup on source PCell.
    ...    2. Configuration
    ...    a.Pcell:SA FDD cell is configured with frequency in band n66 with 20MHz bandwidths.
    ...    b.Scell:SA TDD cell is configured with frequency in band n41 with 100MHz bandwidths.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.CG Type 2 is setup for UE
    ...    b.A1 trigger scell addition
    ...    c.A1 trigger pscell switch
    ...    d.UE detach.
    [Tags]    QC_281171
    OnlineParamChange    ${case16}
    UE Attach To Target Cell with more QoS flows    ue_id=81    cell_id=11
    A1 Trigger Scell Addition
    Trigger A1 Pcell Switch
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log     ${CURDIR}${/}a2a_CB008124_E16${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=700 gfbr_dl=700 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    ue_param id=81-83 ue_nr_capabilities=${cg2_UE_Capabilities}

UE Attach To Target Cell with more QoS flows
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=1    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=1    UE 81: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl trf_id=4 mbps=1    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=5 mbps=1    UE 81: UDP UL

A1 Trigger Scell Addition
    Execute Egate Command    ue_measurement_send_nr id=81 event=A1 meas_id=1 srsrp_nr=100 srsrq_nr=100    SCellIndex 1 activated

Trigger A1 Pcell Switch
    Execute Egate Command    ue_measurement_send_nr id=81 event=A1 meas_id=2 srsrp_nr=30 scell=1 scell_rsrp=100    SCellIndex 1 activated
    Verify Multi drbs Throuput

Verify Multi drbs Throuput
    [Arguments]    ${Tput_dl}=0.9    ${Tput_ul}=0.9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput1}/1000>${Tput_ul}
    Should Be True    ${dl_throughput2}/1000>${Tput_dl}
    Should Be True    ${ul_throughput2}/1000>${Tput_ul}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Attach To Target Cell with one QoS flows
    [Arguments]    ${ue_id}    ${cell_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    QoS Routing Table

Add more drbs
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf    QoS Routing Table
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=1    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl trf_id=4 mbps=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=5 mbps=1    UE ${ue_id}: UDP UL
