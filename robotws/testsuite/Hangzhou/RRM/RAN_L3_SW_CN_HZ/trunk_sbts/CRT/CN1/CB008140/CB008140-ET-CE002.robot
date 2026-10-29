*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               release-SBTS23R1    owner-jean.jing    team-jazz
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}
...    @{Param_CE002}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}
...    @{PARAMS_FOR_GNB2}

@{CB008140_config_GNB1}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=12
...    NRBTS/NRADJNRCELL-2:nrarfcn=153400
...    NRBTS/NRADJNRCELL-2:physCellId=61
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=12
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{CB008140_config_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=40
...    NRBTS/NRCELL-3:chBw=100MHz
...    NRBTS/NRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRCELL-3:nrarfcn=653400
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=45
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=45
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{CA_basic_config}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actRanSharing=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1

...    NRBTS:intGnbScellTempBlockTmr=60
...    delete:NRCELL/NRPLMNSET_NSA-1
...    delete:NRCELL/NRPLMNSET_SA-1
...    NRCELL:configuredEpsTac=200
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{Param_CE002}
...    @{DRB_16}
...    @{5QI_129_254}

@{PARAMS_FOR_GNB2}
...    NRCELL-11:sCellDeactivationTimerGNB=ms1280
...    NRCELL-12:sCellDeactivationTimerGNB=ms1280

@{5QI_129_254}
...    MRBTS-1/NRBTS-1/NRDRB_5QI-7:fiveqiValueList=129
...    MRBTS-1/NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    MRBTS-1/NRBTS-1/NRDRB_5QI-8:fiveqiValueList=254
...    MRBTS-1/NRBTS-1/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16

@{DRB_16}
...    MRBTS-1/NRBTS-1/NRDRB-16:actDddsReduction=false
...    MRBTS-1/NRBTS-1/NRDRB-16:actLostPduFastRetx=false
...    MRBTS-1/NRBTS-1/NRDRB-16:discardTimer=infinity
...    MRBTS-1/NRBTS-1/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    MRBTS-1/NRBTS-1/NRDRB-16:dscp=0
...    MRBTS-1/NRBTS-1/NRDRB-16:endMarkerTimer=2000
...    MRBTS-1/NRBTS-1/NRDRB-16:maxDataRateGbrDl=1000
...    MRBTS-1/NRBTS-1/NRDRB-16:maxDataRateGbrUl=1000
...    MRBTS-1/NRBTS-1/NRDRB-16:maxDddsPeriodCpuOvld=40
...    MRBTS-1/NRBTS-1/NRDRB-16:maxRlcQueueingDelayGbr=20
...    MRBTS-1/NRBTS-1/NRDRB-16:maxTransferDelayGbr=20
...    MRBTS-1/NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    MRBTS-1/NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    MRBTS-1/NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS-1/NRBTS-1/NRDRB-16:numSduDiscard=1
...    MRBTS-1/NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    MRBTS-1/NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=750
...    MRBTS-1/NRBTS-1/NRDRB-16:resType=nonGBR
...    MRBTS-1/NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    MRBTS-1/NRBTS-1/NRDRB-16:schedulWeight=1
...    MRBTS-1/NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=500

@{PM_Counters_Check_CE002_PRIM}
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODREQ_RECD}=2
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODRSP_SUCC_SENT}=2
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>1

...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1

@{PM_Counters_Check_CE002_EXT}
...    NRBTS-2:AGNBM:${IGNB_CA_ADD_REQ_SA_ADJ}=1

${NNGCC_PDUSESMODREQ_RECD}     M55125C03501
#Number of PDU SESSION RESOURCE MODIFICATION REQUEST received
${NNGCC_PDUSESMODRSP_SUCC_SENT}     M55125C03502
#Number of PDU SESSION RESOURCE MODIFICATION RESPONSE Success sent
${GNB_DU_SCELL_2_ADMI_REQ_SA}     M55139C01501
#This counter describes the number of radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It is measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_2_ADMI_SUCC_SA}     M55139C01502
#This counter describes the number of radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It is measured in PCell in SA mode in DU only.
${UE_PCELL_2_CONF_SCELL_DL_SA}     M55118C07001
#The sum of total number of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL in SA mode.
${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
#Number of times two S-Cell Inter gNB CA addition attempted SA
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
#Number of times two S-Cell Inter gNB CA addition success
${IGNB_CA_ADD_REQ_SA_ADJ}    M55199C00001
#Counts the number of inter gNB CA addition requests from prime-gNB-CU in ext-gNB-CU for SA

*** Test Cases ***
CB008140-ET-CE002_Verify_add-Delete_QoS_Flow_with_oneUE_multiPDU_3CC_TFF_scell_addition_blind_when_scell_deactivation
    [Documentation]
    ...    [purpose]:
    ...        The purpose is to check Verify_add-Delete_QoS_Flow_with_oneUE_multiPDU_3CC_scell_addition_blind_when_scell_deactivation.
    ...        Add and delete QoS flow with 1st PDU session. 3CC is TFF
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 CE
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
    ...    GNB-2 ext: cell3-TDD(n77)(pci:51) cell4-TDD(n77)(pci:52) cell11-FDD(n3)(pci:60) cell12-FDD(n28)(PCI61)
    ...    scell gnb2-cell11 and gnb2-cell12
    ...    [Test Case Steps]
    ...         a.UE register to gnb1-cell1
    ...         b.PDU1 session with QosFlow1 setup, PDU2 session with QosFlow6,7 setup
    ...         c.run dl/ul traffic for UE,
    ...         d.stop traffic
    ...         e.pdu1 modify QosFlow add 3 del 1.
    ...         f.UE context release
    ...         g.Check counters and logs
    ...    [Expected Results]:
    ...         b.PDU 2 QosFlow 6 and 7 are UM, so no traffic on scell
    ...         c.scell activited
    ...         d.scell deactived
    ...         e. QFI change

    [Tags]    QC_47069    CE002
    Clear Counter Files    ${False}
    Clear Counter Files GNB2
    Ue register and pdu session setup    ue_id=1    gateway=1    enb_id=2    cell_id=1
    PDU_Modify_QoS_add
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}A2A_CE_002${/}a2a.ini    wait_string=UEContextRelease::10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_CE_002${/}a2a_gnb2.ini    wait_string=UEContextRelease::4
    Check Counters    ${PM_Counters_Check_CE002_PRIM}
    Check Counters GNB2    ${PM_Counters_Check_CE002_EXT}

*** Keywords ***
UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Start traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=ul mbps=10 trf_id=11    UE ${ue_id}: UDP UL

PDU_Modify_QoS_add
    [Arguments]    ${ue_id}=1
    Stop traffic    1    1
    Stop traffic    1    2
    sleep    2s    sleep for traffic stop
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 qosflows_to_del=1 by=amf    pass_regexp=QoS Routing Table
    Start traffic    1
    Verify Throuput on Pscell    1    2

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=7
    Update Cfg    set_qosflow id=4 5qi=8
    Update Cfg    set_qosflow id=5 5qi=9
    Update Cfg    set_qosflow id=6 5qi=129
    Update Cfg    set_qosflow id=7 5qi=254
    Update Cfg    set_qosflow id=8 5qi=79
    Update Cfg    set_qosflow id=9 5qi=80
    Update Cfg    set_qosflow id=11 5qi=1
    Update Cfg    set_qosrule id=1 proto=udp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=tcp qos_flow=4
    Update Cfg    set_qosrule id=5 proto=udp qos_flow=5
    Update Cfg    set_qosrule id=6 proto=tcp qos_flow=6
    Update Cfg    set_qosrule id=7 proto=udp qos_flow=7
    Update Cfg    set_qosrule id=8 proto=tcp qos_flow=8
    Update Cfg    set_qosrule id=9 proto=udp qos_flow=9
    Update Cfg    set_qosrule id=11 proto=udp qos_flow=11
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4,5,6,7,11 qos_rules=1,2,3,4,5,6,7,11
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=1,2,6,7,8,9 qos_rules=1,2,6,7,8,9

Traffic For PDU1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=11    UE ${ue_id}: UDP UL

PDU2 session setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=2    pass_regexp=PDU Session ID 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6,7 qosflows_to_del=1 by=amf    pass_regexp=QFI:3
Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${scell1pci}=60    ${scell2pci}=61    ${cmd_pdu_regexp}=scellIdx:2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}
    Rrc Should Contain    sCellToAddModList    physCellId ${scell1pci}    physCellId ${scell2pci}
    PDU2 session setup    ue_id=1
    Traffic For PDU1    ue_id=1
    Traffic For PDU2    ue_id=1
    Verify Throuput on Pscell

Scell traffic check
    [Arguments]    ${scell1_tput1}    ${scell1_tput2}    ${scell1_tput1_except}=30    ${scell1_tput2_except}=30
    ...    ${scell1_tput1_except_max}=90    ${scell1_tput2_except_max}=130
    Should Be True    ${scell1_tput1}/1000>${scell1_tput1_except}
    Should Be True    ${scell1_tput1}/1000<${scell1_tput1_except_max}
    Should Be True    ${scell1_tput2}/1000>${scell1_tput2_except}
    Should Be True    ${scell1_tput2}/1000<${scell1_tput2_except_max}

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=10s    ${scell1_tput1_except}=30    ${scell1_tput2_except}=30
    ...    ${dl_throughput_except}=500    ${scell1_tput1_except_max}=90    ${scell1_tput2_except_max}=130
    sleep    ${sleep_time}
    ${scell1_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    ${scell1_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Scell traffic check    ${scell1_tput1}    ${scell1_tput2}    ${scell1_tput1_except}    ${scell1_tput2_except}
    ...    ${scell1_tput1_except_max}    ${scell1_tput2_except_max}
    ${scell1_tput0}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput0}/1000>${dl_throughput_except}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>9

Traffic For PDU2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=2 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=3 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=3 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=3 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL

Stop traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    FOR    ${num}    IN    5
        Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} trf_id=${num} dir=dl
    END
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} trf_id=11 dir=ul
