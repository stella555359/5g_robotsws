*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

${OOO_UE_Capabilities}    SEPARATOR=
...    E1A03000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C001
...    03278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286
...    80965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C0010
...    3278FAA8000028000000841C4D000000002026878003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA1288A0

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB-6:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRBTS/NRDRB-6:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-3:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-6:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-13:discardTimer=100ms
...    NRBTS/NRDRB-13:discardTimerUl=20ms
...    NRBTS-1:actServiceAwarePDCPConfig=true
...    @{intermeNB}
...    @{interRAT}

@{intermeNB}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterMeNBMobility=true
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

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

@{PM_Counters_Check_A45_1}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300
@{PM_Counters_Check_A45_2}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=0
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=0
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=300
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300

${MAX_NUM_OOD_CAP_UE}    M55181C00001    #Maximum number of OutOfOrderDelivery capable UEs
${AVG_NUM_OOD_CAP_UE_NOM}    M55181C00002    #Average number of OutOfOrderDelivery capable Ues Numerator
${AVG_NUM_UE_DENOM}    M55181C00003    #Average number of UEs denominator

@{PM_Counters_Check_A63_1}
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300
@{PM_Counters_Check_A63_2}
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=300
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300

*** Test Cases ***

CB009189_45_NSA_interMeNB_PSCell_change_with_outoforder_both_link_use_A3
    [Documentation]
    ...    1. This user scenario describes the PDCP behavior for the transmission when DRB set up with out of order.
    ...    2. Configuration
    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.QCI_9 is setup with out of order.
    ...    b.InterMeNB IntragNB Pscell change with SRB3.
    ...    c.UE detach.
    [Tags]    QC_224657
    Set UE Parameters Before Attach
    NSA UE Attach To Target Cell
    NSA InterMeNB Interfreq Pscell Change
    A45 counters check
    UE Detach    ue_id=16
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_45${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_45${/}a2a.ini

CB009189_63_IRAT_L2N_HO_with_outoforder_both_link_and_PDCP_Discard_Timer
    [Documentation]
    ...    1. This user scenario describes the PDCP behavior for the transmission when DRB set up with out of order and discardtimer.
    ...    2. Configuration
    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true
    ...    d.NRBTS/NRDRB:discardTimer=100ms , NRBTS/NRDRB:discardTimerUL=20ms
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_8 drb is setup with out of order and discardtimer.
    ...    b.IRAT N2L HO
    ...    c.IRAT L2N HO,5QI_8 drb is setup with out of order and discardtimer.
    ...    d.UE detach.
    [Tags]    QC_224656
    UE Attach To Target Cell    ue_id=1    cell_id=1
    Send A2 to Trigger B2    carrierfreq=636576    event_type=A2
    Trigger_B2_MR_to_HO_to_LTE    ue_id=1    carrierfreq=1    event_type=B2    phycell_id=11
    Trigger_HO_back_from_LTE    ue_id=1    target_cell=2
    A63 counters check
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_63${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_63${/}a2a.ini


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    ue_param id=1-2 ue_nr_capabilities=${OOO_UE_Capabilities}
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

Set UE Parameters Before Attach
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_cell_param enb=11 id=1 allow_endc=on

NSA UE Attach To Target Cell
    Execute Egate Command    ue_attach id=16 profile=1    UE IS ACTIVE
    Execute Egate Command
    ...    ue_dc_enb_start ue=16 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    reported successful RA
    Send Nsa Throuput

Send Nsa Throuput
    [Arguments]    ${ue_id}=16
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10    UDP DL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UDP UL TRF

NSA InterMeNB Interfreq Pscell Change
    Clear Counter Files
    Execute Egate Command    ue_enb_endc_param id=16 candidate_cells_mn_hex_for_menb_ho=0926DA802198
    Execute Egate Command
    ...    ue_ho id=16 ho_mode=INTRA_LTE enb=11 cell=1
    ...    Inter-eNB handover from ENB-1.1 to ENB-11.1 performed
    Verify Nsa Throuput

Verify Nsa Throuput
    [Arguments]    ${ue_id}=16    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>9
    Should Be True    ${ul_throughput1}/1000>9


UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE 1: UDP UL

Trigger_B2_MR_to_HO_to_LTE
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_type}    ${phycell_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    ...    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${meas_para}    pass_regexp=UeContextReleaseComplete


Verify Throuput
    [Arguments]    ${Tput_dl}=9    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger_HO_back_from_LTE
    [Arguments]    ${ue_id}    ${target_cell}
    Clear Counter Files
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
    sleep    2s    sleep for A3 MR

A45 counters check
    Check Counters    ${PM_Counters_Check_A45_1}
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A45_2}

A63 counters check
    Check Counters    ${PM_Counters_Check_A63_1}
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A63_2}
