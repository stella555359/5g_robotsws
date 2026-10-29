*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_L1B_CPRI_CMWV_FDD
...               release-SBTS23R1    owner-jolin.fan    team-jazz    CRT
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
...    NRBTS/NRCELL-2:chBw=40MHz
...    NRBTS/NRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRCELL-2:nrarfcn=658000
...    NRBTS/NRCELL-2:a1MeasSCellAddEnabled=rsrq
...    NRBTS/NRCELL-2:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=3
...    NRBTS/NRCELL-2:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=70
...    NRBTS/NRCELL-2:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=64ms
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=2
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=3
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:sCellOperationalMode=dlOnly
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
...    NRBTS/NRCELL-3:chBw=100MHz
...    NRBTS/NRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRCELL-3:nrarfcn=653400
...    NRCELL:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL

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

@{PM_Counters_BA006}
...     NRCELL-2:${GNB_DU_SCELL_1_ADMI_REQ_SA}=0
...     NRCELL-2:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=0
...     NRCELL-2:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=0
...     NRCELL-2:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=0

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004


*** Test Cases ***
CB008140-ET-BA006_A1_based_RSRQ_Inter-gNB_TT_CA_Scell_addition_Failed_due_to_contiguous_Scell
    [Documentation]
    ...    [purpose]:
    ...        The purpose is to check that when inter-gNB CA SCell addition is not attempted because the only
    ...        candidate SCell belongs to an ext-gNB and operates at a carrier frequency which is in the same frequency band and
    ...        contiguous to the UE PCell.
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 BA
	...    [Configuration]:
	...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
	...    GNB-2 ext: cell3-TDD(n77)(pci:51) cell4-TDD(n77)(pci:52) cell11-FDD(n3)(pci:60) cell12-FDD(n3)(PCI61)
	...    scell gnb2-cell3(scell) has the same frequency band and contiguous to gnb1-cell2(pcell) for UE1
    ...    [Test Case Steps]
    ...         a.UE register to gnb1-cell1
	...         b.PDU session setup
    ...         c.run dl/ul traffic for UE
    ...         d.trigger A1 based Scell addition
	...         e.UE context release
	...         f.Check counters and logs
    ...    [Expected Results]:
    ...         ue register to GNB-1 CELL-2, and PDU session is setup successfully, no scell added.
    [Tags]    QC_220769    jifan    BA006
    Ue register and pdu session setup    ue_id=1    gateway=1    enb_id=2    cell_id=2
    Start traffic    ue_id=1
    Trigger A1 based Scell addition    ue_id=1
    Verify Throughput    ue_id=1
    release_ues    ue_type=sa    ue_id=1
    Check Counters    ${PM_Counters_BA006}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}

Trigger A1 based Scell addition
    [Arguments]    ${ue_id}=1    ${cmd_A1_regexp}=SCellIndex 1 activated successfully
    ${meas_cfg}    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=80 srsrq_nr=80    fail_regexp=${cmd_A1_regexp}

Start traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=120    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
