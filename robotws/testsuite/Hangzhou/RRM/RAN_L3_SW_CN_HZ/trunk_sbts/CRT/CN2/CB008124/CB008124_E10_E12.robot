*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

${cg2_UE_Capabilities}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

@{PARAMS_IN_SCF}
...    @{5GC000706_Base}
...    @{NRADJNRCELL}
...    @{NRHOIF}
...    @{NRREL}
...    @{NRADJGNB}
...    @{multidrbs}
...    @{8124_related_modification}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:actUlCgType2=false
...    NRCELL-2:actUlCgType2=true
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=40
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=36
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=40
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRBTS:actFullRRCConfigurationSaHo=enabled

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
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-2:actGBRAdmissionControl=GBRService

@{5GC000706_Base}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250

...    MRBTS-1/NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n60
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=false
...    MRBTS-1/NRBTS-1/NRCELL-1:gapOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:mgta=ms0dot5
...    MRBTS-1/NRBTS-1/NRCELL-1:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-1:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms64
...    TRACKINGAREA-200:fiveGsTac=0
...    MRBTS-1/NRBTS-1/XNLINK-3:cPlaneIpAddr=10.0.1.122

@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200

@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160

@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=3
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3

@{PM_Counters_Check}
...    NRCELL-1:NRCCD:${No_cg2_setup}=0
...    NRCELL-1:NRCCD:${No_cg2_rel}=0
...    NRCELL-1:RSADU:${No_cg2_att}=0
...    NRCELL-2:NRCCD:${No_cg2_setup}=1
...    NRCELL-2:NRCCD:${No_cg2_rel}=0
...    NRCELL-2:RSADU:${No_cg2_att}=1
...    NRCELL-1:NCELA:${No_cg2_act}=0
...    NRCELL-2:NCELA:${No_cg2_act}>=1

${No_cg2_setup}    M55166C00005    #No of RRC reconfiguration complete received with UL configured grant type2 setup
${No_cg2_rel}    M55166C00006    #No of RRC reconfiguration complete received with UL configured grant type2 release
${No_cg2_att}    M55139C00017    #UL configured grant Type2 resource allocation attempts
${No_cg2_act}    M55308C00021    #Successful UL configured grant type 2 activation attempts
*** Test Cases ***
CB008124_E12_CG_Type2_deactivated_at_source_cell_but_activated_at_target_cell_during_Xn_IntergNB_HO
    [Documentation]
    ...    1. This scenario describes the gNB behaviour associated with inter-gNB handover of UE with CG Grant Type 2
    ...    setup on target cell for full config due to DRB to QoS flow mapping usage.
    ...    2. Configuration
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.A3 is configured for NRCELL-1 and SimNRCELL.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.Cg resource is not setup.
    ...    b.Ho to Sim GNB.Cg resource is not setup.
    ...    c.Ho back to Real GNB.QoS flow mapping is missing.Cg resource is setup for full config.
    ...    d.UE detach.
    [Tags]    QC_282064
    Clear Counter Files
    XN setup
    UE Attach To Target Cell with more QoS flows    ue_id=1    cell_id=1
    Start Traffic on UL
    UE Triggers Inter-Frequency Inter-gNB HO
    Verify Multi drbs UL Throuput
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_E12${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${PM_Counters_Check}

CB008124_E10_PDU_Session_setup_with_Muilt_DRBs_CG_Type2_activated_during_Xn_HO_with_5QI_mapping_missing
    [Documentation]
    ...    1. This scenario describes the gNB behaviour associated with inter-gNB handover of UE with CG Grant Type 2
    ...    setup on target cell for full config due to DRB to QoS flow mapping usage.
    ...    2. Configuration
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.A3 is configured for NRCELL-1 and SimNRCELL.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.Cg resource is not setup.
    ...    b.Ho to Sim GNB.Cg resource is not setup.
    ...    c.Ho back to Real GNB.QoS flow mapping is missing.Cg resource is setup for full config.
    ...    d.UE detach.
    [Tags]    QC_281556
    Clear Counter Files
    XN setup
    UE Attach To Target Cell with more QoS flows    ue_id=1    cell_id=1
    Start Traffic on UL
    UE Triggers Inter-Frequency Inter-gNB HO Qos to drb mapping is missing
    Verify Multi drbs UL Throuput
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_E10${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${PM_Counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

XN setup
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=3 sa_ho=xn_based
    Execute Egate Command    smf_param id=1 reset

Modify Cfg
    Update Cfg    ue_param id=1-2 ue_nr_capabilities=${cg2_UE_Capabilities}
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633372:633372
    ...    gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb3_cell2}    catenate    set_cell id=2 gnb=3 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell2}
    Update Cfg    set_qosflow id=4 5qi=6
    Update Cfg    set_qosflow id=5 5qi=4 gfbr_ul=5000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all

UE Attach To Target Cell with more QoS flows
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    QoS Routing Table

Start Traffic on UL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=2 mbps=2    UE 1: UDP UL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=2 dir=ul trf_id=4 mbps=2    UE 1: UDP UL
    Execute Egate Command    data_trf_start ue=1 pdu=2 qfi=1 dir=ul trf_id=2 mbps=2    UE 1: UDP UL
    Execute Egate Command    data_trf_start ue=1 pdu=2 qfi=2 dir=ul trf_id=4 mbps=2    UE 1: UDP UL
    sleep    10s    for tput stable

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Triggers Inter-Frequency Inter-gNB HO
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3
    sleep    3s    for HO interval
    Send A3 MR Then HO
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=ENB-3.1 to EXT_ENB-2.2 performed

Send A3 MR Then HO
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId381
    sleep    3s    for HO interval

Verify Multi drbs UL Throuput
    [Arguments]    ${Tput_ul}=0.2
    sleep    10s    for tput stable
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=2    direction=ul    rate_type=ave
    ${ul_throughput3}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${ul_throughput4}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput1}/1000>${Tput_ul}
    Should Be True    ${ul_throughput2}/1000>${Tput_ul}
    Should Be True    ${ul_throughput3}/1000>${Tput_ul}
    Should Be True    ${ul_throughput4}/1000>${Tput_ul}

UE Triggers Inter-Frequency Inter-gNB HO Qos to drb mapping is missing
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3
    sleep    3s    for HO interval
    Send A3 MR Then HO
    ${xn}    Catenate    gnb_xn_handover_preparation_param id=3
    ...    action=modify_drb_qos_mapping drb_qos_map_modification=exclude_mapping pdu_sessions=1
    Execute Egate Command    ${xn}
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=ENB-3.1 to EXT_ENB-2.2 performed
    Execute Egate Command    gnb_xn_handover_preparation_param id=3 reset
