*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-keyun.ma@nokia-sbell.com  release-5G21A    5GC0002255
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
...    NRPMRNL:miNrRelReportCu=disbale
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
@{PM_Counters_List10}
...    NRBTS-1/MCC-311/MNC-489:${ATT_IF_INTER_GNB_HO_SLICE}=1
...    NRBTS-1/MCC-311/MNC-489:${SUCC_OG_IF_INTER_GNB_HO_SLICE}=1
...    NRCELL-12/MCC-311/MNC-489:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}=1
...    NRCELL-12/MCC-311/MNC-489:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}=1
${SOS_REPORT_FLAG}     pass:True,fail:True
${DEBUG_LOG_LEVEL}    0

${GNB_BIP_FLAG}    True
*** Test Cases ***
5GC002255-ET-E008_Verify_SA_removal_of_A5_rsrq_InterFreq_and_config_A2_measurement_successfully_when_receipt_of_A1_MR
    [Documentation]    This case will verify SA A2 can be configured to UE successfully and inter frequency A5
    ...    can be removed after A1 MR is received when CA is enabled.
    ...    Case steps:
    ...    1.Setup CA successfully
    ...    2.Trigger A2 measurement report
    ...    3.Trigger A1 measurement report, A5 remove and A2 reconfig, check message
    [Tags]    E008    QC_83629
    delta commission parameters    ${Deltacommission08}
    Attach UE for waiting L3 call OK
    Trigger A2 and A1 MR receive
    Verify Throughput
    Ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_08${/}a2a.ini    wait_string=UEContextRelease::1

5GC002255-ET-E010_Verify_SA_A3_rsrp_InterFreq_IntergNB_HO_success_from_CA_to_FDD_with_perUE_measGap
    [Documentation]    This case will test A3 rsrp inter-Freq, IntergNB HO from CA to FDD with perUE
    ...    Case steps:
    ...    1.Setup CA successfully
    ...    2.Trigger A2 measurement report
    ...    3.Trigger A3 measurement report to HO to FDD
    ...    4.Trigger A3 to handover to real GNB CA check traffic
    [Tags]    E010    QC_83628
    clear counter files
    delta commission parameters    ${Deltacommission10}
    Attach UE for waiting L3 call OK
    Report A2 and configured A3 for UE
    Report A3 and Trigger HO
    Report A3 and Trigger HO from simulated gnb to real gnb
    Verify Throughput
    Ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_10${/}a2a.ini    wait_string=UEContextRelease::2
    check counters    ${PM_Counters_List10}

5GC002255-ET-E011_Verify_SA_A5_rsrpCombined_InterFreq_IntergNB_HO_success_from_CA_to_TDD_with_perUE_measGap
    [Documentation]    This case will test A5 rsrpCombined inter-Freq, IntergNB HO from CA to TDD with perUE
    ...    Case steps:
    ...    pre-condition: CA : FDD +TDD
    ...    1.Setup CA successfully
    ...    2.Trigger A2 measurement report
    ...    3.Trigger A5 measurement report to HO to TDD
    ...    4.Trigger A5 to handover to real GNB CA check traffic
    [Tags]    E011    QC_83630
    clear counter files
    delta commission parameters    ${Deltacommission11}
    Attach UE for waiting L3 call OK
    Report A2 and configured A5 for UE
    Report A5 and Trigger HO    ssbfreq=${NRARFCN513234}    phycell_id=381
    Report A5 and Trigger HO from simulated gnb to real gnb
    Verify Throughput
    ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_11${/}a2a.ini    wait_string=UEContextRelease::2
    check counters    ${PM_Counters_List10}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=fddtdd_sansa_cmwv/L1B/6cells_4T2F

Modify Cfg
   ${ue_83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+zuc nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_83}
    ${ue_nr_capabilities}   catenate   SEPARATOR=
    ...    EFA09000574F5E13020002C0A0241220C0013070103100D00980406228040533803D46C28C0D608C21A081074804596C98AA1A1CF88E3D033EC09F18E7
    ...    CC31E50B0381C3C0B8002F800E000BE000180702A0D88DAC1184341020F1008A2D931542439F604F88E3C639F30C7942C0E070F04FE0000003F8000000
    ...    0601C002583850100000041D41C1401C46000002120400C028808C060C80A044D8E7C3853A76C73E18F40B00E000A070101C0C01501C0018090010180A
    ...    084000000A0213440073E618F28581814108004000C80426A00021C41021150203E1000200000001000002008000000040000100200000C01000008008
    ...    000050040000300200100401004000038020000200100080000002000024010000140080000B925002060185C92800030B92500606018060185C928020
    ...    300C030B92500C060180601806018061724A0100C0300C0300C2E49403818060180601806018061704A0000C2E494000189C928010300C4E4940101806
    ...    0189C12800031392500E060180601806018060189C928030300C0300C4E494000181C928070300C0300C0300C0300C0E094000181C928030300C0300C0
    ...    C0CE54D654D60A56065606D60AD60CD652D64CD602D604560256E900E04000025949410000196525040000A59490100003965240400012594901000059
    ...    6524040001A594901000079652404000225949010000996524040002A5949010040B02E5949410000B96525040001C594901000021652402D4AAAE9555
    ...    52A8AA0B1540E2A83455298BA551549A2A80C55028AAED401278105028140A05028140A05028140A050281402010080402010080402010080402010080
    ...    4020100004002030010404008000100A014628840004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05091900
    Update Cfg    ue_param id=83 ue_nr_capabilities=${ue_nr_capabilities}

Attach UE for waiting L3 call OK
    [Arguments]    ${ueid}=83
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
	Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
	Execute Egate Command    set_pdu_param ue=${ueid} pdu=2 trf_type=internal
	Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ueid} nwslice=1 gw=2    SCellIndex 1 activated successfully at airphone
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=dl mbps=100 trf_id=1    UDP DL TRF
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=ul mbps=20 trf_id=1    UDP UL TRF

Trigger A2 and A1 MR receive
    Execute Egate Command    ue_measurement_send_nr id=83 meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30    rrcReconfigurationComplete
	Execute Egate Command    ue_measurement_send_nr id=83 meas_id=2 event=A1 srsrp_nr=60 srsrq_nr=60    rrcReconfigurationComplete

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=90    ${Tput_ul}=18    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=83    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=83    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=83 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Report A2 and configured A3 for UE
    [Arguments]    ${ue_id}=83   ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
	...    rrcReconfigurationComplete

Report A2 and configured A5 for UE
    [Arguments]    ${ue_id}=83   ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
	...    rrcReconfigurationComplete

Report A3 and Trigger HO
    [Arguments]    ${ue_id}=83   ${ssbfreq}=${NRARFCN127200}   ${phycell_id}=382
	${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A3
	${A3_cmd}    catenate    ue_measurement_send_nr id=83 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
	...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
	Execute Egate Command    ${A3_cmd}    Inter-eNB handover from EXT_ENB-2.12 to ENB-4.1 performed

Report A5 and Trigger HO
    [Arguments]    ${ue_id}=83   ${ssbfreq}=${NRARFCN513234}   ${phycell_id}=381
	${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A5
	${A5_cmd}    catenate    ue_measurement_send_nr id=83 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11
	...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
	Execute Egate Command    ${A5_cmd}    Inter-eNB handover from EXT_ENB-2.12 to ENB-3.1 performed

Report A3 and Trigger HO from simulated gnb to real gnb
    [Arguments]    ${handover_string}=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.12 performed
	Execute Egate Command    ue_measurement_send_nr id=83 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7    rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    83    127210    A3
	${A3_cmd2}    catenate    ue_measurement_send_nr id=83 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
	${retvlue}    Execute Egate Command    ${A3_cmd2}   SCellIndex 1 activated successfully at airphone
	Should Contain    ${retvlue}    ${handover_string}

Report A5 and Trigger HO from simulated gnb to real gnb
    [Arguments]    ${handover_string}=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.12 performed
	Execute Egate Command    ue_measurement_send_nr id=83 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7    rrcReconfigurationComplete
	${A5_meas_id}    get nr meas id for specific type and frequency    83    ${NRARFCN127180}    A5
	${A5_cmd2}    catenate    ue_measurement_send_nr id=83 meas_id=${A5_meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=61
	...    nrsrp_nr=60 nrsrq_nr=60
	${retvlue}    Execute Egate Command    ${A5_cmd2}    SCellIndex 1 activated successfully at airphone
	Should Contain    ${retvlue}    ${handover_string}

Ue Deregister
    Execute Egate Command    ue_deregister id=83 ue_deregister_type=switch_off    rrcRelease
