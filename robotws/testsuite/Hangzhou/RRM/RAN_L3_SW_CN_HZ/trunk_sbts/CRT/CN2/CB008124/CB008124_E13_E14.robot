*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

${cg2_UE_Capabilities}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    @{multidrbs}
...    @{interRAT}
...    @{RRE}
...    @{8124_related_modification}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:actUlCgType2=true
...    NRCELL-2:actUlCgType2=true
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=40
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=36
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=40
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0


@{multidrbs}
...    NRDRB_5QI-10:fiveqiValueList=4
...    NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:rlcMode=RLC_AM
...    NRDRB-3:maxDataRateGbrDl=30720
...    NRDRB-3:maxDataRateGbrUl=30720
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:discardTimer=50ms
...    NRDRB-3:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-3:maxRlcQueueingDelayGbr=20
...    NRDRB-3:maxTransferDelayGbr=20
...    NRDRB-3:queuingDelayDiscarding=Disabled
...    NRDRB-3:dscp=46
...    NRDRB_MAC-5:lcgid=5
...    NRDRB_MAC-5:delayTarget=50
...    NRDRB_MAC-5:schedulBSD=20ms
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-2:actNonVoNRGbrService=true


@{interRAT}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:actInterRatHoSA=true
...    NRBTS:nonContentRachAcFullConfigHo=true
...    NRBTS:tNgRelocExecDeltL=5000
...    NRBTS/NRADJECELL-1:eNodeBId=18
...    NRBTS/NRADJECELL-1:ePSTrackingAreaCode=0
...    NRBTS/NRADJECELL-1:earfcnValue=1
...    NRBTS/NRADJECELL-1:lcrId=1
...    NRBTS/NRADJECELL-1:physCellId=11
...    NRBTS/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS/NRADJECELL-1:enbPlmn:mncLength=3
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a1MeashoEnabled=rsrpAndRsrq
...    NRCELL-1:a2MeashoEnabled=rsrpAndRsrq
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=18
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:removeNotAllowed=false
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-1/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512

@{RRE}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:actGnbInitRlf=false

@{PM_Counters_Check}
...    NRCELL-1:NRCCD:${No_cg2_setup}=2
...    NRCELL-1:NRCCD:${No_cg2_rel}=0
...    NRCELL-1:RSADU:${No_cg2_att}=2
...    NRCELL-1:NCELA:${No_cg2_act}>=2
${No_cg2_setup}    M55166C00005    #No of RRC reconfiguration complete received with UL configured grant type2 setup
${No_cg2_rel}    M55166C00006    #No of RRC reconfiguration complete received with UL configured grant type2 release
${No_cg2_att}    M55139C00017    #UL configured grant Type2 resource allocation attempts
${No_cg2_act}    M55308C00021    #Successful UL configured grant type 2 activation attempts
*** Test Cases ***
CB008124_E14_CG_Type2_activated_and_RRE_back
    [Documentation]
    ...    1. This scenario describes the gNB behaviour for the successful setup of CG Type 2 configuration during RRC
    ...    Connection re-establishment to the selected cell in serving gNB-DU with valid UE context.
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.
    ...    b.RRE to another cell,CG Type 2 is setup for UE successful during RRE
    ...    c.UE detach.
    [Tags]    QC_280384   owner-meredith.ma
    Clear Counter Files
    UE Attach To Target Cell with more QoS flows    ue_id=1    cell_id=1
    Start traffic
    Trigger_RRE_back
    Check Counters    ${PM_Counters_Check}
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_E14${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_E13_CG_Type2_activated_during_IRAT
    [Documentation]
    ...    1. This scenario describes the gNB behaviour associated with setup of CG grant Type 2 during inter-RAT UE handover from LTE.
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or bothl
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.
    ...    b.IRAT N2L HO
    ...    c.IRAT L2N HO,CG Type is setup for UE successful during IRAT Handover.
    ...    d.UE detach.
    [Tags]    QC_281174   owner-meredith.ma
    Clear Counter Files
    UE Attach To Target Cell    ue_id=1    cell_id=1
    Send A2 to Trigger B2    carrierfreq=636576    event_type=A2
    Trigger_B2_MR_to_HO_to_LTE    ue_id=1    carrierfreq=1    event_type=B2    phycell_id=11
    Trigger_HO_back_from_LTE    ue_id=1    target_cell=1
    Check Counters    ${PM_Counters_Check}
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_E13${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    ue_param id=1-2 ue_nr_capabilities=${cg2_UE_Capabilities}
    ${V4}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
    ...    type=simulated x2_peers=none
    ${V5}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${V4}
    Update Cfg    ${V5}
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=9
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.15 daemon=10.0.2.1:22222 gnb_id=0x12:28
    ...    nssai=0x01:0xD143A5
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=true
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=5000 gfbr_dl=5000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE 1: UDP UL

UE Attach To Target Cell with more QoS flows
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    QoS Routing Table

Start traffic
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=5    UE 1: UDP UL
    Execute Egate Command    data_trf_start ue=1 pdu=2 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=2 qfi=1 dir=ul trf_id=5 mbps=5    UE 1: UDP UL
    Execute Egate Command    data_trf_start ue=1 pdu=2 qfi=2 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=2 qfi=2 dir=ul trf_id=5 mbps=5    UE 1: UDP UL
    Sleep    60s    sleep for Tput stable

Trigger_RRE_back
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure    Reestablishment sucessfully
    Verify Multi drbs Throuput1
    Verify Multi drbs Throuput2
    Execute Egate Command    smf_param id=1 reset

Trigger_B2_MR_to_HO_to_LTE
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_type}    ${phycell_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    ...    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${meas_para}    pass_regexp=UeContextReleaseComplete
    sleep    5s    sleep for HO back to NR

Verify Throuput
    [Arguments]    ${Tput_dl}=9    ${Tput_ul}=4.5    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Multi drbs Throuput1
    [Arguments]    ${Tput_dl}=9    ${Tput_ul}=4.5    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput1}/1000>${Tput_ul}
    Should Be True    ${dl_throughput2}/1000>${Tput_dl}
    Should Be True    ${ul_throughput2}/1000>${Tput_ul}

Verify Multi drbs Throuput2
    [Arguments]    ${Tput_dl}=9    ${Tput_ul}=4.5
    ${dl_throughput3}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput3}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput3}/1000>${Tput_dl}
    Should Be True    ${ul_throughput3}/1000>${Tput_ul}

Trigger_HO_back_from_LTE
    [Arguments]    ${ue_id}    ${target_cell}
    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=${target_cell} plmn=311:489
    ...    pass_regexp=ENB-5.1 to EXT_ENB-2.${target_cell}
    Verify Throuput

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send A2 to Trigger B2
    [Arguments]    ${carrierfreq}    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=${event_type}
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_type} srsrp_nr=7 srsrq_nr=7    ReconfigurationComplete
    sleep    5s    sleep for B2 MR
