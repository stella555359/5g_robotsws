*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               release-SBTS23R1    owner-jolin.fan    team-jazz
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}
...    @{Param_CE011}

@{CB008140_config_GNB1}
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRBTS:sCellActivationMethod=blind
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
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa
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
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=364000
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=12
...    NRBTS/NRADJNRCELL-2:nrarfcn=374000
...    NRBTS/NRADJNRCELL-2:physCellId=61
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=40
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MRBTS/NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    MRBTS/NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    MRBTS/NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    MRBTS-2/NRBTS-2/NRDRB-10:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS-2/NRBTS-2/NRDRB-10:rlcMode=RLC_UM
...    delete:MRBTS-2/NRBTS-2/NRDRB-10:nrDrbRlcAmDN
...    MRBTS-2/NRBTS-2/NRDRB-12:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS-2/NRBTS-2/NRDRB-12:rlcMode=RLC_UM
...    delete:MRBTS-2/NRBTS-2/NRDRB-12:nrDrbRlcAmDN

@{CA_basic_config}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actRanSharing=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1

...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    delete:NRCELL/NRPLMNSET_NSA-1
...    delete:NRCELL/NRPLMNSET_SA-1
...    NRCELL:configuredEpsTac=200
...    NRCELL:actCDrx=false

@{Param_CE011}
...    MRBTS-2/NRBTS-2/NRDRB-10:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS-2/NRBTS-2/NRDRB-10:rlcMode=RLC_UM
...    delete:MRBTS-2/NRBTS-2/NRDRB-10:nrDrbRlcAmDN
...    MRBTS-2/NRBTS-2/NRDRB-12:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS-2/NRBTS-2/NRDRB-12:rlcMode=RLC_UM
...    delete:MRBTS-2/NRBTS-2/NRDRB-12:nrDrbRlcAmDN


@{PM_Counters_CE011_GNB2}
...     NRCELL-1:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...     NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507

@{PM_Counters_CE011}
...     NRCELL-11:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...     NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...     NRCELL-11:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...     NRCELL-11:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...     NRBTS-1:AGNBM:${IGNB_CA_ADD_REQ_SA_ADJ}=1

${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${IGNB_CA_ADD_REQ_SA_ADJ}    M55199C00001
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004



*** Test Cases ***
CB008140-ET-CE011_Verify_add-2DBRS_RLC_UM_then_delete_last_one_RLC_AM_DRB_2CC_TF
    [Documentation]
    ...    [purpose]:
    ...    this case is to varify the successful PDU Qos modification with blind inter-gNB 2CC CA SCell addition for a SA UE,
    ...    when two UM DRB is configured match to Qos flow 2,3.
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 CE
    ...    [Configuration]:
    ...    GNB-2 Prime: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    GNB-1 ext: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    [Test Case Steps]
    ...    a.UE register to gnb2-cell1
    ...    b.PDU session setup and Scell gnb1-cell11 added
    ...    c.run dl/ul traffic for UE
    ...    d.PDU Modify QoS add 2,3(two UM DRB 5,6) dele 1(AM DRB 4), UM DRBs added failed cause:IgNBCAUeContextModificationFailure
    ...    e.PDU Modify QoS add 1(AM DRB 7) succesfully
    ...    f.run dl/ul traffic for UE
    ...    g.Check counters and logs

    [Tags]    QC_47072    CE011    jifan
    Ue register and pdu session setup    ue_id=1    gateway=1    enb_id=3    cell_id=1
    Run traffic and Verify Throughput    ue_id=1    Tput_dl=400    Tput_ul=8
    PDU_Modify_QoS_add_dele    ue_id=1    pdu=1    qosadd=2,3    qosdel=1 
    Run traffic and Verify Throughput    ue_id=1    Tput_dl=400    Tput_ul=8
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_CE011}
    Check Counters GNB2    ${PM_Counters_CE011_GNB2}
    Check WireShark Log    ${CURDIR}${/}A2A_CE_011${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_CE_011${/}a2a_gnb2.ini    wait_string=UEContextRelease::10
    Check userstop cause shall be correct

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11    ${cmd_regexp}=UE now in NG RM Registere    
    ...    ${cmd_pdu_regexp}=SCellIndex 1 activated successfully
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}

PDU_Modify_QoS_add_dele
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qosadd}=2    ${qosdel}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosadd} qosflows_to_del=${qosdel} by=amf
    ...    pass_regexp=QoS Routing Table:::2
    Should Contain    ${ret1}    Added QosFlow with QFI:2 fiveQI:5
    Should Contain    ${ret1}    Added QosFlow with QFI:3 fiveQI:7
    Should Contain    ${ret1}    Deleted QoSFlow with QFI 1 SEID 1
    ${ret2}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosdel} by=amf
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret2}    Added QosFlow with QFI:1 fiveQI:6

Run traffic
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE 1: UDP UL

Run traffic and Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=30s
    Run traffic
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}gnb2${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 3
    should be equal As Numbers    ${number}    1

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

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
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4,5,6,11 qos_rules=1,2,3,4,5,6,11
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=1,2,6,7,8,9 qos_rules=1,2,6,7,8,9
