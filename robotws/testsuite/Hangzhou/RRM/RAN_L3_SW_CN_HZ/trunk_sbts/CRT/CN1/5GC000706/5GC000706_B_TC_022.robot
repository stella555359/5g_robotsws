*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    team-SG2
...               owner-junhui.he    release-5G20A    5GC000706
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{5GC000706_Base}    @{NRCELL}    @{NRADJNRCELL}    @{NRHOIF}    @{NRADJGNB}    @{NRREL}    @{NRDRB}    @{NRCELL_FDD}
@{5GC000706_Base}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true

...    MRBTS-1/NRBTS-1:actInterRatHoSA=false
...    MRBTS-1/NRBTS-1:actInterRatHoSADlDataForward=false
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=false
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=EnabledWithBtsInputReference
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250

@{NRCELL}
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=126900
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=1587
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:mgta=ms0dot5
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL-1:gapOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-1:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxLongCycle=80ms
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxOnDurationTimer=1ms
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40

@{NRCELL_FDD}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1:nrarfcnDl=126900
...    MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1:nrarfcnUl=136100
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48


@{NRDRB}
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitGainThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:nsa3xBearerAllowed=false
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:prioritizeX2Period=500
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:ulDataPath=ulOverNr
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:ulDataSplitThreshold=infinity

@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=71
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=126530
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200

@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=126530
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms160

@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=-6dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=-8dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mncLength=3

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3

${UE_CAPA_B_UE}    SEPARATOR=
...    E1A01000075F5A1302000201404824C5800260D40C13601873E618F28581C130080C47002A0D88DAC1184341020F
...    940224B64C55050E7C471E31CF9863CA16070387813F8000000FE00000003801C00100388C0000000040460501A0
...    1813B639F0FD028038100C0301802A03000301F04401000000008000010040000100200000C01000008008000058
...    250020300C9C1280001938250060300C0300C9C1280201806019382500A0300C0300C0300C9C1280401806018060
...    19382500E0300C0300C0300C0300C980200001C01000010008000090040000500200002C0B654DE54D606560CD60
...    6D60AD6E91933594B591B5809581140F04000025949410000196525040000A594901000039652404000125949010
...    00059652404010180696525040001A5949410000796524040101C079652404000225949010000996524040002A59
...    49010000B9652404000325949010000D965240354AAAE95555038AA0D174AA2A82C5576A2BB114AA2A93455298AA
...    47154062A81450116808D028140A05028140A05028140A05028140A05028000000200C0184

@{PARAMS_TO_MODIFY_706_B_TC22}
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq

@{PARAMS_TO_MODIFY_706_B_TC2202}
...    MRBTS-1/NRBTS-1/NRCELL-1:maxNumOfRrcSA=0

*** Test Cases ***
5GC000706-ET-B022_Verify_A5_rsrpC_If_perUE_MG_Inter-gNB_ho_to_multi_cells_with_AC_failure
    [Documentation]    Support to active SA inter-frequency measurement configure with measurement gap.
    ...    UE cap: independentGapConfig off
    ...    NRCELL-1: measGapSelectionSA:favorUeMeasurements, mgta: msdot5, gapOffset 8
    ...             a2MeashoEnabledSA:rsrp+rsrq, a1MeashoEnabledSA:rsrp
    ...    NRCELL-1/NRHOIF-1: a5MeasEnabled:rsrp+rsrq
	[Tags]    QC_61670
    Online Update Parameters    ${PARAMS_TO_MODIFY_706_B_TC22}
    Add UE History Information List    A5
    Register UE
    UE Triggers HO from Real GNB cell to SIM GNB cell    4    A5    8    8
    Online Update Parameters    ${PARAMS_TO_MODIFY_706_B_TC2202}
    HO fails due to admission control fails    A5    8    8    35    35
    Analyze wireshark log
    [Teardown]    Teardown For 706B

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
    ${V_1}    catenate
    ...    ue_param id=1 ue_nr_capabilities=${UE_CAPA_B_UE}
    Update Cfg    ${V_1}
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=20:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=136100:126900 gscn=1587 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=135760:126380
    ...    gscn=1582 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb3_cell2}    catenate    set_cell id=2 gnb=3 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=135760:126380
    ...    gscn=1582 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell2}

Register UE
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table

UE Triggers HO from Real GNB cell to SIM GNB cell
    [Arguments]      ${measid}      ${event}    ${srsrp1}    ${srsrq1}
    UE Triggers A2
    sleep    2s    reason=Waiting for A2 measurement report sending complete
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${measid} event=${event} srsrp_nr=${srsrp1} srsrq_nr=${srsrq1}
    ...    phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ...    phycell_id=382 nrsrp_nr=20 nrsrq_nr=20
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=handover from EXT_ENB-2.1 to ENB-3.1 perf
    Set Test Variable    ${ho_log}

UE Triggers A2
    Execute Egate Command     ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=8 srsrq_nr=8
    ...    pass_regexp=eventA5

HO fails due to admission control fails
    [Arguments]    ${event2}    ${srsrp2}    ${srsrq2}    ${nrsrp}    ${nrsrq}
    sleep    2s    reason=Waiting for A2 measurement report sending complete
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=${event2} srsrp_nr=${srsrp2} srsrq_nr=${srsrq2}
    ...    phycell_id=60 nrsrp_nr=${nrsrp} nrsrq_nr=${nrsrq} rs_type=ssb index=1 nrs_result=10:10:10
    Execute Egate Command    ${cmd}    pass_regexp=HandoverPreparation is received. Handover canceled.

Add UE History Information List
    [Arguments]      ${event}
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=96
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=${event}

Online Update Parameters
    [Arguments]      ${PARAMS_TO_MODIFY}
    Delta Commission Parameters    ${PARAMS_TO_MODIFY}
    BuiltIn.Log To Console    Online Update Parameters is done

Analyze wireshark log
    Check Wireshark Log     ${CURDIR}${/}a2a${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    BuiltIn.Log To Console    Wirshark check is done

Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Teardown For 706B
    Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Common Test Teardown And Stop Capture Logs
