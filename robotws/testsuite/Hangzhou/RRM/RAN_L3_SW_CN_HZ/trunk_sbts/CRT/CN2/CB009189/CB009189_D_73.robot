*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-niya.ma
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{5qi80_related_modification}
...    @{inter_gNB_HO_TDD_modification}
...    @{2271_related_modification}

@{5qi80_related_modification}
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:discardTimer=infinity
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:endMarkerTimer=2000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=nonGBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-15:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB_5QI-3:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15

@{inter_gNB_HO_TDD_modification}
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
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocCancelN=2000
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=3
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=66
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=344000
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS-1/XNLINK-1:cPlaneIpAddrCtrl=oamControlled

@{CASE_75}
...    NRCELL-1/NRREL-1:handoverAllowedSA=XnHoNotAllowed
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocCancelN=2000

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL-1:srPeriodicity=slots80
...    NRCELL-2:srPeriodicity=slots80
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL-2:srPeriodicityMin=slots40
...    NRCELL-1:srPeriodicityMin=slots10
...    NRCELL:vonrReservation=30
...    NRCELL-1:preferredVoNrSrPeriod=slots40
...    NRCELL-2:preferredVoNrSrPeriod=slots40
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-12:preferredVoNrSrPeriod=slots20
...    NRCELL-13:preferredVoNrSrPeriod=slots20
...    NRCELL-14:preferredVoNrSrPeriod=slots20
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actServiceAwareConfig=true

${ue_id}    81

*** Test Cases ***
CB009189-D_ID_73_5QI80_setup_ICS_wo_PDU_session_then_Interfreq_IntergNB_XnHO
    [Documentation]
    ...    1. inter_freq_inter_gnb_XnHO enable
    ...    2. cell1 config NRHOIF for intergNB :gnb-3 cell2 (gnb-3 support 5QI80)
    ...    3. 5QI-80 DRB profile is configured and DRB mapped to RLC-UM
    ...    4. Initial Context Setup without PDU session for 5qi80
    [Tags]    QC_224572    owner-niya.ma
    Trigger Xn Setup From Remote GNB
    ICS Without PDU    ue_id=81    cell_id=1    amf_id=1    qos_flow_default=9
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=30    send_ul=10    sleep_time=10s    pdu=1
    Trigger A2    carrierfreq=518910    phycell_id=50
    Trigger A3    carrierfreq=424090    sleep_time=5s    phycell_id=381    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Trigger A3 Back    carrierfreq=424090    sleep_time=5s    phycell_id=60    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.11 performed
    Verify Throuput    ue_id=81    qfi=1    Tput_dl=27    Tput_ul=9    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189D073${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80 default=on
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999
    ...    nr_arfcn=344000:424000 gscn=5300 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 rlc_config=80:um:size_12

Change Default 5qi
    [Arguments]    ${ue_id}    ${cell_id}    ${qos_flow_default}    ${qos_flow_add}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow_default} priority=15
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow_add} by=amf
    ...    UE81: Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 80 qfi 2

ICS Without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${amf_id}    ${qos_flow_default}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=${amf_id} send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow_default} priority=15
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    amf_param id=${amf_id} send_ics_registration=off

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}    ${pdu}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger Xn Setup From Remote GNB
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    gnb_param id=${gnb_id} send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=${gnb_id} sa_ho=xn_based

Trigger NG Setup From Remote GNB
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    gnb_param id=${gnb_id} send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=${gnb_id} sa_ho=ng_based

Trigger A3
    [Arguments]    ${ue_id}=81    ${carrierfreq}=424090    ${sleep_time}=2s    ${phycell_id}=381
    ...    ${pass_regexp}=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    sleep    ${sleep_time}    sleep for A3 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_regexp}

Trigger A3 Back
    [Arguments]    ${ue_id}=81    ${carrierfreq}=424090    ${sleep_time}=2s    ${phycell_id}=60
    ...    ${pass_regexp}=Inter-eNB handover from EXT_ENB-3.1 to ENB-2.11 performed
    sleep    ${sleep_time}    sleep for A3 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Trigger A2
    [Arguments]    ${ue_id}=81    ${carrierfreq}=518910    ${phycell_id}=50    ${rsrp}=30
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${rsrp}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    Execute Egate Command    ${cmd}        pass_regexp=eventId eventA3
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
