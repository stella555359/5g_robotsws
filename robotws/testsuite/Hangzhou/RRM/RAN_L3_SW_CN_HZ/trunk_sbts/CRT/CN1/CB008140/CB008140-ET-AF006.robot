*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               release-SBTS23R3    owner-jolin.fan    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}

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
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=653400
...    NRBTS/NRADJNRCELL-1:physCellId=52
...    NRBTS/NRADJNRCELL-1:ssbFrequency=650688
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=11
...    NRBTS/NRADJNRCELL-2:nrarfcn=368400
...    NRBTS/NRADJNRCELL-2:physCellId=60
...    NRBTS/NRADJNRCELL-2:ssbFrequency=368430
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
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
...    NRCELL:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpAddr=fd5f:4268:2387:a881:40:43ff:fe80:197
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpPrefixLength=128
#...    NRBTS/NRDU-1:interNodeUplaneIpConfig:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
#...    delete:NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1
...    delete:NRDU-1:xgUplane:ipV4AddressDN1


@{CA_basic_config}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa

...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
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
...    NRCELL:sCellDeactivationTimerGNB=infinity

#@{RD_Counters_AF006}
#...    NRCELL-1:IGNB_CA_ATT_1_SCELL_SA=1
#...    NRCELL-1:IGNB_CA_ATT_SA_REJ=1

#@{RD_Counters_AF006_GBN2}
#...    IGNB_CA_ADD_REQ_SA_NRADJ=1
#...    IGNB_CA_SCELL_ADMI_REQ_SA=1
#...    IGNB_CA_SCELL_ADMI_SUCC_SA=1
#...    IGNB_CA_ADD_REQ_SA_REJ_NRADJ=1

@{PM_Counters_AF006}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REJ}=1

@{PM_Counters_AF006_GNB2}
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=1

${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_SA_REJ}    M55118C11007
${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}    M55175C00002

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502

*** Test Cases ***
CB008140-ET-AF006_Inter-gNB_TT_CA_Blind_Scell_Addition_Failure_cause_transport_resource_unavailable_from_ext_Gnb_DU
    [Documentation]
    ...    [purpose]: When Xp Uplane IP protocol version is incompatible between ext gNB and prime gNB, inter-gNB CA
    ...               SCell addition for a SA UE context having one candidate SCell only in an ext-gNB will fail due to
    ...               rejection in execution phase from target ext-gNB-DU.
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140
    ...    [Test Case Steps]:
    ...         a.UE register
    ...         b.PDU session setup
    ...         c.Check logs
    ...         d.Check counters
    ...    [Expected Results]:
    ...         a.CA UE register to Prime GNB1 CELL-1(tdd)
    ...         b.PDU session setup successfully and Scell addition fail due to incompatible Uplane IP protocol version
    ...         c.F1AP:IGNB CA UE CONTEXT SETUP FAILURE with cause transport:transport-resource-unavailable
    ...         d.counters update in Ptime GNB1:
    ...            M55139C01003: The number of radio admission requests for 1 Scell in SA mode in DU
    ...            IGNB_CA_ATT_1_SCELL_SA:Counted by the number of XnAP: IgNB CA ADDITION REQUEST message sent from
    ...                                   Prime-gNB CU to ext-gNB CU to add one S-Cell for SA.
    ...            IGNB_CA_ATT_SA_REJ:Counted by the number of XnAP: IgNB CA ADDITION REQUEST REJECT message for any
    ...                                   cause received from ext-gNB-CU to prime-gNB-CU for SA.
    ...           counters update in ext-GNB2:
    ...            M55139C01001: The number of radio admission requests for the SCell in SA mode in DU
    ...            IGNB_CA_ADD_REQ_SA_NRADJ:Counted by the number of XnAP: IgNB CA ADDITION REQUEST message sent from
    ...                                     Prime-gNB CU to ext-gNB CU to add SCell(s) for SA.
    ...            IGNB_CA_SCELL_ADMI_REQ_SA:Counter is pegged when S-Cell setup is requested in the ext-gNB-CU during
    ...                                      Inter gNB CA by the message XnAP: IgNB CA ADDITION REQUEST.
    ...            IGNB_CA_SCELL_ADMI_SUCC_SA:Counter is pegged when S-Cell setup requested by the message XnAP: IgNB
    ...                                       CA ADDITION REQUEST is successful in the ext-gNB-CU.
    ...            IGNB_CA_ADD_REQ_SA_REJ_NRADJ:When the IgNB-CA is rejected by ext-gNB-DU, per ext-CU the counter will
    ...                                         be pegged.
    ...
    [Tags]    AF006    QC_217450
    Ue register and pdu session setup without blind scell addition    1    1    2    1
    Send And Verify Throuput for no scell UE    1    10
    release_ues    ue_type=sa    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_AF_006${/}a2a.ini
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AF_006${/}a2a_gnb2.ini    wait_string=IgNBCAAdditionReject::1
    Check Counters    ${PM_Counters_AF006}
    Check Counters GNB2    ${PM_Counters_AF006_GNB2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Ue register and pdu session setup without blind scell addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${cmd_pdu_regexp}=sCellIndex 1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=${cmd_pdu_regexp}

Send And Verify Throuput for no scell UE
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell for no scell UE    sleep_time=10s

Verify Throuput on Pscell for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>60
    Should Be True    ${ul_throughput}/1000>8
