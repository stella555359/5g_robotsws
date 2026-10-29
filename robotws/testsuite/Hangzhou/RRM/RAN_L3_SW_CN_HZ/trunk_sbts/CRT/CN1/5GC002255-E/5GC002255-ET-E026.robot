*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CRT  CLOUD_5G_I_BOO_AP_LOO
...     team-DevHZ5_SG2    5GC002255
...     owner-keyun.ma    release-5G21A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN127180}    127210    #cell12 ssbfreq  band71
@{PARAMS_IN_SCF}
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1589
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRBTS-1:srb3SupportEnabled=false
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS:actInterRatHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:sCellActivationMethod=blind
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

...    NRCELL-12:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-12:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-12:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-12:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL-12:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-12:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-12:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL-12:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-12:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0

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
...    NRCELL-12:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly

...    NRBTS-1/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS-1/NRHOIR-1:b2MeashoEnabled=rsrp
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRBTS-1/NRHOIR-1:earfcnValue=1
...    NRBTS-1/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS-1/NRHOIR-1:presenceAntennaPort1=false
...    NRBTS-1/NRHOIR-1:reportAmount=r8
...    NRBTS-1/NRHOIR-1:reportInterval=ms240
...    NRBTS-1/NRHOIR-1:widebandRsrqMeas=false
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrqVoNr=ms480

...    NRCELL-12/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-12/NRRELE-1:eNodeBId=18
...    NRCELL-12/NRRELE-1:eutranCellExcluded=false
...    NRCELL-12/NRRELE-1:lcrId=1
...    NRCELL-12/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-12/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-12/NRRELE-1:ecgiPlmn:mncLength=3

...    NRBTS-1/NRADJECELL-1:eNodeBId=18
...    NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    NRBTS-1/NRADJECELL-1:earfcnValue=1
...    NRBTS-1/NRADJECELL-1:lcrId=1
...    NRBTS-1/NRADJECELL-1:physCellId=11
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3

...    NRCELL-2:fPdcchMonOccsnPo=0
...    NRCELL-4:fPdcchMonOccsnPo=0

${SOS_REPORT_FLAG}     pass:True,fail:True
${DEBUG_LOG_LEVEL}    0

${GNB_BIP_FLAG}    True

*** Test Cases ***
5GC002255-ET-E026_Verify_SA_B2_rsrp_InterRAT_HO_success_from_CA_to_LTE_with_perUE_measGap
    [Documentation]    This case will test B2 rsrp inter-Freq, InterRAT HO from CA to LTEENB with perUE
    ...    Case steps:
    ...    1.Setup CA successfully
    ...    2.Trigger A2 measurement report
    ...    3.check traffic, then Trigger B2 measurement report to HO to interRAT LTE
    [Tags]    E026    QC_83622
    Attach UE for waiting L3 call OK
    Report A2 and configured B2 for UE
    Verify Throughput
    Report B2 and Trigger HO from cell12 to lte cell
    Ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_26${/}a2a.ini    wait_string=UEContextRelease

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    ${ue_83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
    ...    nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_83}
    Update Cfg    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.14 daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${V1}    catenate
    ...    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=$SERVER_IP:12220 nrci=0x1 tdd_cell=on bw=20MHz technology=lte
    ...    mandatory_for_activation=off
    Update Cfg    ${V1}
    Update Cfg    gnb_param id=5 xn_listening_socket=off

Attach UE for waiting L3 call OK
    [Arguments]    ${ueid}=83
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
	Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
	Execute Egate Command    set_pdu_param ue=${ueid} pdu=2 trf_type=internal
	Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ueid} nwslice=1 gw=1    SCellIndex 1 activated successfully at airphone
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=dl mbps=100 trf_id=1    UDP DL TRF
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=ul mbps=10 trf_id=1    UDP UL TRF

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=90    ${Tput_ul}=9    ${sleep_time}=15s    ${ue_id}=83
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Report A2 and configured B2 for UE
    [Arguments]    ${ue_id}=83   ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
	...    rrcReconfigurationComplete

Report B2 and Trigger HO from cell12 to lte cell
    [Arguments]    ${ue_id}=83
    ${mea_id}    get nr meas id for specific type and frequency    ${ue_id}    1    B2    EUTRAN
	${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=B2 srsrp_nr=11 srsrq_nr=11 phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
	Execute Egate Command    ${A3_cmd}    Successful handover from EXT_ENB-2.12 to ENB-5.1

Ue Deregister
    Execute Egate Command    ue_deregister id=83 ue_deregister_type=switch_off    UE83: Released
