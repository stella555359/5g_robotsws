*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags     QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-jazz
...             owner-jean.jing    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_A1_for_NRCELL_1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_11}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB

...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=false


@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
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
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB2_CA_for_NRCELL_11}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
#...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    delete:NRCELL-11/NRREL-1:sCellAdditionMethod
...    NRCELL-11:actVoNR=false
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=45
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity

@{GNB1_A1_for_NRCELL_1}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=85
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1

@{GNB1_NRREL_blind}
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind


@{PM_Counters_Check_BB002_PRIM}
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=1
...    NRCELL-1:NRRCC:${NRRCC_RRC_RECONF_SENT}=3
...    NRCELL-1:NRRCC:${NRRCC_RRC_RECONF_CMP_RECD}=3
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL}=1


${A2MEAS_REL1DLSCELL_ATT_SA}     M55118C06501
#This counter describes Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for SA
${A2MEAS_REL1DLSCELL_SUCC_SA}     M55118C06502
#Counts the number of inter gNB CA addition requests from prime-gNB-CU in ext-gNB-CU for SA.
${NRRCC_RRC_RECONF_SENT}     M55124C03001
#This counter provides the number of RRC: RRC RECONFIGURATION messages sent from gNB-CU.
${NRRCC_RRC_RECONF_CMP_RECD}     M55124C03002
#This counter provides the number of RRC: RRC RECONFIGURATION COMPLETE messages received at gNB-CU.
${UE_PCELL_1_CONF_SCELL_DL_SA}     M55118C05507
#Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.
${IGNB_CA_ATT_SA_REL}       M55118C11008

*** Test Cases ***
CB008140-ET-BB002_Inter-gNB_TF_CA_online_change_from_coverBaseA1_to_blind_After_Event_A2_measurement_rsrpCombined_based_triggered_no_A1_config
    [Documentation]
    ...    [purpose]: The purpose of this test case is to check following scenarios:
    ...    this case is to based on scell released successfully after FDD-TDD 2CC DL inter-GNB scell addition succeed.
    ...    when sCellAdditionMethod is set to "blind" after the addition of SCell and then gNB receives A2 measurement
    ...    report on SCell (for SCell release), gNB triggers A2 measurement based SCell release, but A1 measurement on
    ...    PCell for SCell addition is not configured on UE
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140-BB
    ...    [Test Case Steps]:
    ...         a.make a normal SA CA_TF ue with coverBased
    ...         b. A1 add scell
    ...         c. online change from coverBased to blind
    ...         d. A2 release scell
    ...    [Expected Results]:
    ...         a. L3 call successfully, A1 config
    ...         b. scell add successfully, A2 config
    ...         c. change successfully
    ...         d. scell release successfully, no A1 config
    [Tags]    QC_221986    BB002
    Clear Counter Files    ${False}
    Clear Counter Files GNB2
    Make Normal CA SA UE
    Delta Commission Parameters    ${GNB1_NRREL_blind}
    after online change A2 release
    Check Counters    ${PM_Counters_Check_BB002_PRIM}    wait=${True}
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_BB_002${/}a2a_gnb2.ini    wait_string=UEContextRelease::4
    Check Wireshark Log    ${CURDIR}${/}A2A_BB_002${/}a2a.ini    wait_string=UEContextRelease::10
    Check userstop cause shall be correct

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Make Normal CA SA UE
    Sa Ue Attach    1    1    2    1
    Setup pdu session with scell add covBasedA1
    Triggered Scell Addition by A1    pcell=1
    Send And Verify Throuput    1    20

after online change A2 release
    A2 release
    UE Deregister From gNB    1

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Setup pdu session with scell add covBasedA1
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=sCellIndex 1

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell    sleep_time=30s

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>50
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>220
    Should Be True    ${ul_throughput}/1000>8

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput on Pscell for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>220
    Should Be True    ${ul_throughput}/1000>8

A2 release
    [Arguments]    ${ue_id}=1    ${carrierfreq}=368430    ${sleep_time}=15s    ${phycell_id}=50
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=1 scell_rsrp=35 scell_rsrq=35
    ...    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pscell for no scell UE

Triggered Scell Addition by A1
    [Arguments]    ${pcell}    ${ue_id}=1    ${rsrp}=120    ${rsrq}=120    ${scell_num}=1
    Execute Egate Command    ue_disp
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    663360    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=scellIdx:1

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 1
    should be equal As Numbers    ${number}    1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}gnb2${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 1
    should be equal As Numbers    ${number}    1
