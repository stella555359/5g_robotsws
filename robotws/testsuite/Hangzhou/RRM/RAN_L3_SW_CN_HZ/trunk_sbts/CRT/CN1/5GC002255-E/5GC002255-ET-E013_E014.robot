*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-keyun.ma@nokia-sbell.com  release-5G21A    5GC002255
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN127180}    127210    #cell12 ssbfreq
${NRARFCN508020}    508110    #cell3 ssbfreq
${NRARFCN518580}    518910
${NRARFCN127200}    127230    #simulated gnb4 ssbfreq
${NRARFCN513234}    513150    #simulated gnb3 ssbfreq
@{PARAMS_IN_SCF}
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1589
...    NRBTS-1:srb3SupportEnabled=false
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRPMRNL:miNrRelReportCu=disable
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:actCDrx=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=35
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=36
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=1
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=30 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=513150
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=513150
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJGNB-1:gNodeBId=35
...    NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS-1/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS-1/NRADJGNB-2:gNbIdLength=22
...    NRBTS-1/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS-1/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS-1/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJGNB-2:gNodeBId=36
...    NRBTS-1/NRADJGNB-2:xnLinkRef=2
...    XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS-1/NRADJNRCELL-2:cellDepType=SA
...    NRBTS-1/NRADJNRCELL-2:fiveGsTac=0
...    NRBTS-1/NRADJNRCELL-2:freqBandIndicatorNR=71
...    NRBTS-1/NRADJNRCELL-2:gNbId=36
...    NRBTS-1/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-2:lcrId=1
...    NRBTS-1/NRADJNRCELL-2:nrarfcn=127230
...    NRBTS-1/NRADJNRCELL-2:physCellId=382
...    NRBTS-1/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRCELL-2:fPdcchMonOccsnPo=0
...    NRCELL-4:fPdcchMonOccsnPo=0
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disable
@{Deltacommission08}
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr
@{Deltacommission10}
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=127230
@{Deltacommission11}
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=30 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=513150
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrpCombined
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
${ATT_IF_INTER_GNB_HO_SLICE}    M55149C00570       #The number of Inter-Frequency Inter-gNB HOs attempted
${SUCC_OG_IF_INTER_GNB_HO_SLICE}    M55149C00571   #The number of Inter-Frequency Inter-gNB Outgoing HO successful
${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}    M55145C00351  #The number of outgoing inter-frequency inter-gNB HO attempts for SA per PLMN-ID
${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}    M55145C00352  #The number of successful outgoing inter-frequency inter-gNB HOs for SA per PLMN-ID
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${UE_PSCELL_ACT_SCELL_DL}    M55316C02000
${UE_PSCELL_ACT_SCELL_UL}    M55316C02001
${PSCELL_UE_1_ACT_SCELL_DL}    M55316C03001
${MAX_PSCELL_UE_1_ACT_SCELL_DL}    M55316C05001
@{PM_Counters_List13}
...    NRCELL-12/MCC-311/MNC-489:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}=1
...    NRCELL-12/MCC-311/MNC-489:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}=1
...    NRCELL-12:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${GNB_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-12:${GNB_SCELL_1_ADMI_SUCC_SA}=2
...    NRCELL-3:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-3:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=2
...    NRCELL-3:${UE_PSCELL_ACT_SCELL_DL}>0
...    NRCELL-3:${UE_PSCELL_ACT_SCELL_UL}=0
...    NRCELL-12:${PSCELL_UE_1_ACT_SCELL_DL}>0
...    NRCELL-12:${MAX_PSCELL_UE_1_ACT_SCELL_DL}=1
${SOS_REPORT_FLAG}     pass:True,fail:True
${DEBUG_LOG_LEVEL}    0

${GNB_BIP_FLAG}    True

*** Test Cases ***
5GC002255-ET-E013_Verify_SA_A3_rsrp_Interfreq_IntergNB_HO_success_from_FDD_to_CA_with_perFR1_meas_Gap
    [Documentation]    This case will test A3 rsrp inter-Freq, IntergNB HO from CA to FDD with perFR1
    ...    Case steps:
    ...    1.Setup CA successfully
    ...    2.Trigger A2 measurement report
    ...    3.Trigger A3 measurement report to HO to FDD
    ...    4.Trigger A3 to handover to real GNB CA check traffic
    [Tags]    E013    QC_83627
    clear counter files
    delta commission parameters    ${Deltacommission10}
    Attach UE for waiting L3 call OK
    Report A2 and configured A3 for UE
    Report A3 and Trigger HO
    Report A3 and Trigger HO from simulated gnb to real gnb
    Verify Throughput
    Ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_13${/}a2a.ini    wait_string=UEContextRelease::2
    check counters    ${PM_Counters_List13}

5GC002255-ET-E014_Verify_SA_A3_rsrp_Interfreq_IntergNB_HO_success_from_TDD_to_CA_with_perFR1_meas_Gap
    [Documentation]    This case will test A5 rsrpCombined inter-Freq, IntergNB HO from CA to TDD with perFR1
    ...    Case steps:
    ...    pre-condition: CA : FDD +TDD
    ...    1.Setup CA successfully
    ...    2.Trigger A2 measurement report
    ...    3.Trigger A5 measurement report to HO to TDD
    ...    4.Trigger A5 to handover to real GNB CA check traffic
    [Tags]    E014    QC_83626
    clear counter files
    delta commission parameters    ${Deltacommission11}
    Attach UE for waiting L3 call OK
    Report A2 and configured A5 for UE
    Report A5 and Trigger HO    ssbfreq=${NRARFCN513234}    phycell_id=381
    Report A5 and Trigger HO from simulated gnb to real gnb
    Verify Throughput
    Ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_14${/}a2a.ini    wait_string=UEContextRelease::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=fddtdd_sansa_cmwv/L1B/6cells_4T2F

Modify Cfg
   ${ue_82}    catenate
    ...    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
    ...    nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645482 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_82}
    ${ue_nr_capabilities}   catenate   SEPARATOR=
    ...    EFA09000574F5E13020002C0A0241220C00130703018806804C0203114020299C01EA3614606B04610D04083A4022CB64C550D0E7C471E819F604F8C73E6
    ...    18F28581C0E1E05C0017C0070005F0001C00E0541B11B582308682041E201145B262A84873EC09F11C78C73E618F28581C0E1E09FC0000007F00000001C0
    ...    0E0012C1C28080000020EA0E0A00E230000010902006014404605032028113639F0E14E9DB1CF863D02C03800381C0C0381802A038003012002030141080
    ...    0000140C13440073E618F28581814108004000C80C13500010E208108A8101F0800100000000800001004000000020000080100000600800004004000028
    ...    02000018010008020080200001C0100001000800400000010000120080000A00400005C928010300C2E494000185C928030300C0300C2E49401018060185
    ...    C928060300C0300C0300C030B9250080601806018061724A01C0C0300C0300C0300C030B825000061724A0000C4E49400818062724A0080C0300C4E09400
    ...    0189C928070300C0300C0300C0300C4E4940181806018062724A0000C0E49403818060180601806018060704A0000C0E494018180601806060672A6B2A6B
    ...    052B032B036B056B066B296B266B016B022B012B7480702000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA
    ...    48080003CB29202000112CA48080004CB29202000152CA480802058172CA4A080005CB292820000E2CA480800010B292016A55574AAAA95455058AA07154
    ...    1A2A94C5D2A8AA4D154062A8145576A0093C0828140A05028140A05028140A05028140A01008040201008040201008040201008040201008000200101800
    ...    8202004000080500A3144200020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E82848C80
    Update Cfg    ue_param id=82 ue_nr_capabilities=${ue_nr_capabilities}

Attach UE for waiting L3 call OK
    [Arguments]    ${ueid}=82
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
	Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
	Execute Egate Command    set_pdu_param ue=${ueid} pdu=2 trf_type=internal
	Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ueid} nwslice=1 gw=2    SCellIndex 1 activated successfully at airphone
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=dl mbps=100 trf_id=1    UDP DL TRF
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=ul mbps=20 trf_id=1    UDP UL TRF

Trigger A2 and A1 MR receive
    Execute Egate Command    ue_measurement_send_nr id=82 meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30    rrcReconfigurationComplete
	Execute Egate Command    ue_measurement_send_nr id=82 meas_id=2 event=A1 srsrp_nr=60 srsrq_nr=60    rrcReconfigurationComplete

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=90    ${Tput_ul}=18    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=82    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=82    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=82 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Report A2 and configured A3 for UE
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
	...    rrcReconfigurationComplete

Report A2 and configured A5 for UE
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
	...    rrcReconfigurationComplete

Report A3 and Trigger HO
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN127200}   ${phycell_id}=382
	${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A3
	${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
	...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
	Execute Egate Command    ${A3_cmd}    Inter-eNB handover from EXT_ENB-2.12 to ENB-4.1 performed

Report A5 and Trigger HO
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN513234}   ${phycell_id}=381
	${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A5
	${A5_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11
	...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
	Execute Egate Command    ${A5_cmd}    Inter-eNB handover from EXT_ENB-2.12 to ENB-3.1 performed

Report A3 and Trigger HO from simulated gnb to real gnb
    [Arguments]    ${handover_string}=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.12 performed
	Execute Egate Command    ue_measurement_send_nr id=82 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7    rrcReconfigurationComplete
	${A3_cmd2}    catenate    ue_measurement_send_nr id=82 meas_id=29 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
	${retvlue}    Execute Egate Command    ${A3_cmd2}   SCellIndex 1 activated successfully at airphone
	Should Contain    ${retvlue}    ${handover_string}

Report A5 and Trigger HO from simulated gnb to real gnb
    [Arguments]    ${handover_string}=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.12 performed
	Execute Egate Command    ue_measurement_send_nr id=82 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7    rrcReconfigurationComplete
	${A5_meas_id}    get nr meas id for specific type and frequency    82    ${NRARFCN127180}    A5
	${A5_cmd2}    catenate    ue_measurement_send_nr id=82 meas_id=${A5_meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=61
	...    nrsrp_nr=60 nrsrq_nr=60
	${retvlue}    Execute Egate Command    ${A5_cmd2}    SCellIndex 1 activated successfully at airphone
	Should Contain    ${retvlue}    ${handover_string}

Ue Deregister
    Execute Egate Command    ue_deregister id=82 ue_deregister_type=switch_off    rrcRelease
