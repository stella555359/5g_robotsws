*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LO    team-VRF_HAZ3_07
...    owner-lijun.j.jia    release-SBTS25R1    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB_BIP_FLAG}    ${True}
${AP_BIP_FLAG}    ${False}
@{PARAMS_IN_IPHY_XML}
...    vcell:GSCN=1570|cell=2.1
@{PARAMS_IN_SCF}
#...    NRBTS:actEcpriPhase2=false
#...    NRBTS:actEcpriPhase3=false
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
...    @{PARAM_FOR_HO}
...    @{PARAM_FOR_NRCELL}
...    @{PARAM_FOR_NRREL}
...    @{PARAM_FOR_NRHOIF}

@{PARAM_FOR_NRHOIF}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=126530
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms64

@{PARAM_FOR_NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false

@{PARAM_FOR_NRCELL}
...    NRCELL-1:actCDrx=true
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=16
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a5MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=1
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=0
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:sMeasConfigSsbRsrp=10
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:actCDrx=true
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a5MeasEnabled=rsrp
...    NRCELL-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:absThreshSsbRsrpConsolidation=0
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:sMeasConfigSsbRsrp=10
...    NRCELL-2:measGapSelectionSA=favourUeThroughput

@{PARAM_FOR_HO}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:timerHOGuard=6000     #2500ms, Handover guard timer for receiving RRC Reconfiguration Complete

@{pm_counter_Check_J001_base}
...    NRBTS-1:${UE_SUPP_DL_DYNAMIC_RAT}>0
...    NRBTS-1:${UE_SUPP_DL_NO_DYNAMIC_RAT}=0
...    NRBTS-1:${DENOM_UE_RAT_SUPP}>0

@{pm_counter_Check_J001_multi}
...    NRBTS-1:${UE_SUPP_DL_DYNAMIC_RAT}>0
...    NRBTS-1:${UE_SUPP_DL_NO_DYNAMIC_RAT}>0
...    NRBTS-1:${DENOM_UE_RAT_SUPP}>0

@{pm_counter_Check_J001_multi_EDA}
...    NRBTS-1:${UE_SUPP_DL_DYNAMIC_RAT}>0
...    NRBTS-1:${UE_SUPP_DL_DYNAMIC_RAT}<450
...    NRBTS-1:${UE_SUPP_DL_NO_DYNAMIC_RAT}>0
...    NRBTS-1:${UE_SUPP_DL_NO_DYNAMIC_RAT}<450

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


@{A2_INTRAGNB_HO}
...    measurementReport
...    radioNetwork : rRM-purpose
...    SgNBModificationRequestAcknowledge
...    eventId eventA5
...    gapOffset gp0 : 12
...    drx-Config release : NULL
...    SgNBModificationConfirm

*** Test Cases ***
CB008927-5G-ET-J003_DynamicSwitch_with_UEs
    [Documentation]
    ...    1. Purpose
    ...        This case is to test the FDD scenario as below:
    ...        a. Single NSA call with DynamicSwitch in RRC Reconfiguration
    ...        b. Single SA call and RRE with DynamicSwitch in RRC Setup / Reconfiguration / Re-establishment
    ...        C. Add the EDA 04359179's check.
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
    ...        l. Check EDA 04359179
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
    [Tags]    J003    QC_11214
    Clear Counter Files
    Trigger NSA UE Attach    ue_id=31
    Trigger SA UE Attach    ue_id=1    cell_id=1
    Online Param Change    ${online_change_true}
    Trigger NSA UE ReAttach
    Trigger RRC Reestablish with cause    ue_id=1    cell_id=1    cause=otherFailure
    Trigger NSA UE Attach    ue_id=32
    Trigger SA UE Attach    ue_id=2    cell_id=1
    Trigger RRC Reestablish with cause    ue_id=2    cell_id=1    cause=otherFailure
    Online Param Change    ${online_change_false}
    Trigger RRC Reestablish with cause    ue_id=1    cell_id=1    cause=otherFailure
    Release ues    ue_type=all
    Check Counters    ${pm_counter_Check_J001_multi}
    Check WireShark Log    ${CURDIR}${/}A2A_J003${/}a2a.ini    wait_string=UEContextRelease::48
    EDA_04359179

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=30

Online Param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Trigger NSA UE Attach
    [Arguments]    ${ue_id}=31
    NSA UE attach successful    id=${ue_id}    target_cells=1
    Traffic Should Be OK    ue_id=${ue_id}    type=NSA

Trigger SA UE Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Sa CA UE Register    ue_id=${ue_id}    wait_timer=0.5    cell_id=${cell_id}    gnb_id=2
    SA CA UE Setup PDU Session    ue_id=${ue_id}    wait_timer=0.5    expect_regexp=QoS Routing Table
    Traffic Send Small    ue_id=${ue_id}

Trigger NSA UE ReAttach
    Release Ues    ue_type=nsa    ue_id=31
    NSA UE attach successful    id=31    target_cells=1
    Traffic Should Be OK    ue_id=31    type=NSA

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered    sleep_time=${wait_timer}

Traffic Send Small
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=1    UE ${ue_id}: UDP DL

SA CA UE Setup PDU Session
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${expect_regexp}=QoS Routing Table
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
    [Arguments]    ${id}=11    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

Modify Cfg
    Update Cfg    ue_param id=31 ue_nr_capabilities=${NSA_Supp_dynSwitch_UECapa}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Supp_dynSwitch_UECapa}
    ${GNB2_CELL1}    catenate
    ...    set_cell id=1 gnb=2 nr_arfcn=135760:126380 gscn=1570 eci=0x000021f pci=20:0 tac=200
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x01 tdd_cell=off mandatory_for_activation=off
    Update Cfg    ${GNB2_CELL1}

EDA_04359179
    Clear Counter Files
    Online Param Change    ${online_change_true}
    Trigger NSA UE Attach and send traffic    ue_id=32
    Ue Ho To target gNB Cell2        ue_id=32
    SgNB release without SgNB X2AP ID
    Trigger NSA UE Attach and send traffic
    Ue Ho To target gNB Cell2    ue_id=31
    SgNB release without SgNB X2AP ID    ue_id=31
    Check Counters    ${pm_counter_Check_J001_multi_EDA}

Trigger NSA UE Attach and send traffic
    [Arguments]    ${ue_id}=31
    NSA UE attach successful    id=${ue_id}    target_cells=1
    Send traffic for five minutes and verify throuput

Ue Ho To target gNB Cell2
    [Arguments]    ${ue_id}=31
    Set MeasurementGap and Initial A2 Event    carrierfreq=125570    ue_id=${ue_id}
    Initial InterFreA3 Ho    carrierfreq=126530    phycell_id=61    ue_id=${ue_id}

Set MeasurementGap and Initial A2 Event
    [Arguments]    ${carrierfreq}    ${ue_id}=32
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL

Initial InterFreA3 Ho
    [Arguments]    ${carrierfreq}    ${phycell_id}    ${ue_id}=32
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    Execute Egate Command    ue_rrc_reconf_param id=${ue_id} if_contains=reconfiguration_with_sync delay=5000 action=none
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=70 nrsrq_nr=70
    ...    pass_regexp=Hit on RRC Reconfiguration Rule    timeout=3s

SgNB release without SgNB X2AP ID
    [Arguments]    ${ue_id}=32
    Execute Egate Command    enb_ue_dc_release ue=${ue_id} by=enb cause=RN_load_balancing exclude_sgnb_ue_x2ap_id=true
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful

Send traffic for five minutes and verify throuput
    [Arguments]    ${ue_id}=32
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5    UE 32: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    UE 32: UDP UL
    Sleep  300s
    Verify Throuput

Verify Throuput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=32    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=32    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
