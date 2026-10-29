*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD
...    CLOUD_5G_I_BOO_AP_LOO    team-DevHZ5_SG2
...    owner-keyun.ma    release-5G21A    5GC002255
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN127180}    127210    #cell12 ssbfreq
#${NRARFCN526020}    526590    #cell4 ssbfreq
${NRARFCN124900}    125050    #cell11 ssbfreq  band71
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

...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    delete:NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr
...    delete:NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:actCDrx=false

...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1

...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3

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
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3

...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=${NRARFCN124900}
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=${NRARFCN127180}
...    NRCELL-2:fPdcchMonOccsnPo=0
...    NRCELL-4:fPdcchMonOccsnPo=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=30
@{Deltacommission31}
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
@{Restriction_Admission}
...    NRCELL-11:maxNumOfCaUsersNRCell=0
...    NRCELL-11:maxNumOfRrcSA=0
...    NRCELL-11:maxNumOfSCellAlloc=0
#...    NRCELL-11:maxNumOfUsersPerNRCell=0 remove as it will cause gNB reset from CB008717
#...    NRCELL-11:maxNumOfUsersPerCell=0
@{Recover_Admission}
...    NRCELL-11:maxNumOfCaUsersNRCell=250
...    NRCELL-11:maxNumOfRrcSA=275
...    NRCELL-11:maxNumOfSCellAlloc=250
#...    NRCELL-11:maxNumOfUsersPerNRCell=275
#...    NRCELL-11:maxNumOfUsersPerCell=275
${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}    M55145C00323  #The number of inter-freq intra-DU HO prep failures due to Admission Control for SA per PLMN-ID
@{PM_Counters_List31}
...    NRCELL-12/MCC-311/MNC-489:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}=1
${SOS_REPORT_FLAG}     pass:True,fail:True
${DEBUG_LOG_LEVEL}    0

${GNB_BIP_FLAG}    True

*** Test Cases ***
5GC002255-ET-E031_Verify_SA_A3_rsrp_InterFreq_IntragNB_HO_failed_with_target_cell_RAC_failure
    [Documentation]    The purpose of this case is to verify SA A3 rsrp Interfreq IntragNB HO failed from CA to FDD due to RAC failure.
    ...    Case steps:
    ...    1.Setup CA successfully,set source cell(CA) drx ON,set target cell drx False
    ...    2.Set case failed condition maxNumOfUsersPerNRCell,maxNumOfRrcSA,maxNumOfUsersPerCell,maxNumOfSCellAlloc,maxNumOfCaUsersNRCell value 0
    ...    3.Trigger A2 measurement report
    ...    4.Trigger A3 measurement report and HO to FDD failed
    ...    5.Set maxNumOfUsersPerNRCell,maxNumOfRrcSA,maxNumOfUsersPerCell,maxNumOfSCellAlloc,maxNumOfCaUsersNRCell value 250
    ...    6.Recover A3 measurement report to HO to FDD
    ...    7.Trigger A3 to handover to real GNB FDD+TDD check traffic
    [Tags]    E031    QC_83617
    clear counter files
    delta commission parameters    ${Deltacommission31}
    Attach UE for waiting L3 call OK    ueid=83    gwid=1    pduid=1    retvlue=SCellIndex 1 activated successfully at airphone
    delta commission parameters    ${Restriction_Admission}
    Report A2 and configured A3 for UE    ue_id=83
    Report A3 and Trigger HO from cell12 to cell11    ue_id=83    ssbfreq=${NRARFCN124900}    phycell_id=60
    delta commission parameters    ${Recover_Admission}
    Second Report A3 and Trigger HO from cell12 to cell11    ue_id=83    ssbfreq=${NRARFCN124900}    phycell_id=60
    Report A3 and Trigger HO from cell11 to cell12    SCellIndex 1 activated successfully at airphone
    Verify Throughput    ueid=83    pduid=1
    Ue Deregister    83
    Check Wireshark Log    ${CURDIR}${/}a2a_31${/}a2a.ini    wait_string=UEContextRelease
    check counters    ${PM_Counters_List31}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
   ${ue_83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
    ...    nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_83}


Attach UE for waiting L3 call OK
    [Arguments]    ${ueid}=83    ${gwid}=1    ${pduid}=1    ${retvlue}=QoS Routing Table
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ueid} pdu=${pduid} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pduid} ue=${ueid} nwslice=1 gw=${gwid}    ${retvlue}
    Execute Egate Command    trf_data_start ue=${ueid} pdu=${pduid} qfi=1 dir=dl mbps=175 trf_id=1    UDP DL TRF
    Execute Egate Command    trf_data_start ue=${ueid} pdu=${pduid} qfi=1 dir=ul mbps=10 trf_id=1    UDP UL TRF

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=150    ${Tput_ul}=9    ${sleep_time}=15s    ${ueid}=83    ${pduid}=1    ${type}=pdsch
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ueid}    pdu=${pduid}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ueid}    pdu=${pduid}    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ueid} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    2
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Scell Throughput Check
    [Arguments]    ${ue_id}=83    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0



Report A2 and configured A3 for UE
    [Arguments]    ${ue_id}=83    ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    rrcReconfigurationComplete

Report A3 and Trigger HO from cell12 to cell11
    [Arguments]    ${ue_id}=83    ${ssbfreq}=${NRARFCN127180}    ${phycell_id}=382
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A3
    ${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${A3_cmd}    fail_regexp=Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.11 performed

Second Report A3 and Trigger HO from cell12 to cell11
    [Arguments]    ${ue_id}=83    ${ssbfreq}=${NRARFCN127180}    ${phycell_id}=382
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A3
    ${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${A3_cmd}    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.11 performed

Report A3 and Trigger HO from cell11 to cell12
    [Arguments]    ${handover_string}=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.12 performed    ${ssbfreq}=${NRARFCN124900}    ${ueid}=83
    ${A2_measid}    get nr meas id for specific type and frequency    ${ueid}    ${ssbfreq}    A2
    Execute Egate Command    ue_measurement_send_nr id=${ueid} meas_id=${A2_measid} event=A2 srsrp_nr=7 srsrq_nr=7    rrcReconfigurationComplete
    ${A3_measid}    get nr meas id for specific type and frequency    ${ueid}    ${NRARFCN127180}    A3
    ${A3cmd}    catenate
    ...    ue_measurement_send_nr id=${ueid} meas_id=${A3_measid} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
    ${retvlue}    Execute Egate Command    ${A3cmd}    ${handover_string}

Ue Deregister
    [Arguments]    ${ue_id}=83
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    rrcRelease
