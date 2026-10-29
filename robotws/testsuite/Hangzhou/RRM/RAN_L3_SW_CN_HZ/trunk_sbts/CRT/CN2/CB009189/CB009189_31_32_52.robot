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
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB-13:discardTimer=200ms
...    NRBTS-1:actServiceAwarePDCPConfig=true
...    @{intragnb_interfreq_HO}
...    @{5GC000706_Base}
...    @{NRADJNRCELL}
...    @{NRHOIF}
...    @{NRREL}
...    @{NRADJGNB}

@{intragnb_interfreq_HO}
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633330
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:lcrId=2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

@{5GC000706_Base}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250

...    MRBTS-1/NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n60
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=false
...    MRBTS-1/NRBTS-1/NRCELL-1:gapOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:mgta=ms0dot5
...    MRBTS-1/NRBTS-1/NRCELL-1:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-1:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms64
...    TRACKINGAREA-200:fiveGsTac=0
...    MRBTS-1/NRBTS-1/XNLINK-3:cPlaneIpAddr=10.0.1.122
@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200
@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160

@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=3
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3

${MAX_NUM_OOD_CAP_UE}    M55181C00001    #Maximum number of OutOfOrderDelivery capable UEs
${AVG_NUM_OOD_CAP_UE_NOM}    M55181C00002    #Average number of OutOfOrderDelivery capable Ues Numerator
${AVG_NUM_UE_DENOM}    M55181C00003    #Average number of UEs denominator

@{PM_Counters_Check_A31_1}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300
@{PM_Counters_Check_A31_2}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=0
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=0
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=300
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300

@{PM_Counters_Check_A32_1}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
@{PM_Counters_Check_A32_2}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=300
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300


*** Test Cases ***
CB009189_31_SA_DRB_setup_wo_outoforder_both_link_then_Interfreq_InterDU_HO_use_A5
    [Documentation]
    ...    1. This user scenario describes Inter-frequency Intra-gNB handover to target cell to verify
    ...    the PDCP behavior for the transmission when DRB set up with out of order.
    ...    2. Configuration
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for 5QI_8
    ...    d.A5 is configured for NRCELL-1 and SimNRCELL.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_8 is setup with out of order.
    ...    b.Ho to intra_gnb cell2.
    ...    c.UE detach.
    [Tags]    QC_223937
    UE Attach To Target Cell    ue_id=1    cell_id=1
    UE Triggers Inter-Frequency Intra-gNB HO and check outoforder
    A31 counters check
    UE Deregister From gNB    ue_id=1

CB009189_32_SA_DRB_setup_with_outoforder_both_link_then_Interfreq_IntergNB_XnHO_use_A3
    [Documentation]
    ...    1. This user scenario describes Inter-frequency Inter-gNB Xnhandover to target cell to verify
    ...    the PDCP behavior for the transmission when DRB set up with out of order.
    ...    2. Configuration
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for 5QI_8
    ...    d.A3 is configured for NRCELL-1 and SimNRCELL.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_8 is setup with out of order.
    ...    b.Ho to Sim GNB.
    ...    c.Ho back to Real GNB.5QI_8 is setup with out of order.
    ...    d.UE detach.
    [Tags]    QC_223944
    XN setup
    UE Attach To Target Cell    ue_id=1    cell_id=1
    UE Triggers Inter-Frequency Inter-gNB HO and check outoforder
    UE HO back from sim_gNB and check outoforder
    A32 counters check
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_32${/}a2a.ini    wait_string=UEContextReleaseComplete::6

CB009189_52_SA_Interfreq_IntergNB_XnHO_NonGBR_DRB_setup_with_PDCP_Discard_Timer_use_A3
    [Documentation]
    ...    1. This user scenario describes Inter-frequency Inter-gNB Xnhandover to target cell to verify
    ...    gNB behavior for the transmission of PDCP PDUs when DiscardTimer for non-GBR bearers is enabled.
    ...    2. Configuration
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB-13:discardTimer=200ms for 5QI_8
    ...    d.A3 is configured for NRCELL-1 and SimNRCELL.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_8 is setup with DiscardTimer.
    ...    b.Ho to Sim GNB.
    ...    c.Ho back to Real GNB.5QI_8 is setup with DiscardTimer.
    ...    d.UE detach.
    [Tags]    QC_223940
    XN setup
    UE Attach To Target Cell    ue_id=1    cell_id=1
    UE Triggers Inter-Frequency Inter-gNB HO
    UE HO back from sim_gNB
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_52${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_52${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

XN setup
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=3 sa_ho=xn_based

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${OOO_UE_Capabilities}
    Update Cfg    set_qosflow id=2 5qi=6
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633372:633372
    ...    gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb3_cell2}    catenate    set_cell id=2 gnb=3 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell2}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Triggers Inter-Frequency Inter-gNB HO and check outoforder
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE 1: UDP UL
    Send A2 MR
    Send A3 MR Then HO and check outoforder

UE Triggers Inter-Frequency Inter-gNB HO
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE 1: UDP UL
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId381

UE Triggers Inter-Frequency Intra-gNB HO and check outoforder
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE 1: UDP UL
    Clear Counter Files
    Send A2 MR
    Send A5 MR Then HO and check outoforder

Send A2 MR
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3

Send A3 MR Then HO and check outoforder
    Start RRC Log     Check_SIM_Outoforder
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId381
    Check RRC log    ${CURDIR}${/}a2a_CB009189_32${/}a2a.ini

Send A5 MR Then HO and check outoforder
    Start RRC Log     intragnb_Outoforder
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=5 event=A5 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId51
    Verify Throuput
    Check RRC log    ${CURDIR}${/}a2a_CB009189_31${/}a2a.ini

UE HO back from sim_gNB and check outoforder
    Start RRC Log     Check_Real_Outoforder
    Clear Counter Files
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Verify Throuput
    Check RRC log    ${CURDIR}${/}a2a_CB009189_32${/}a2a2.ini

UE HO back from sim_gNB
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Verify Throuput

Verify Throuput
    [Arguments]    ${Tput_dl}=9    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

A31 counters check
    Check Counters    ${PM_Counters_Check_A31_1}
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A31_2}

A32 counters check
    Check Counters    ${PM_Counters_Check_A32_1}
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A32_2}
