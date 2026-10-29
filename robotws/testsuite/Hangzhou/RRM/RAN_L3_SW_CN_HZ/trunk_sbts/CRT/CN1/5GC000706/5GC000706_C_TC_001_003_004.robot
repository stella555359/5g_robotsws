*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...               owner-Xianjiao.Xie    release-5G20A    team-SG2
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{Mobility_NRHOIF}
...    @{Xn-link}
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:gscnOrSsPbchArfcn=1587
...    NRCELL/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:actIncXn=true
...    NRBTS:actInterFreqHoSA=true

...    NRBTS:actInterRatHoSA=false
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS:gNbCuType=SA+NSA
...    NRCELL:gapOffset=8
...    NRCELL:ifhoSsbSmtcOffset=8
...    NRCELL:reportIntervalSA=ms120
...    NRCELL:reportOnLeave=false
...    NRCELL:reportAmountSA=r4
...    NRCELL:drxProfile1:drxInactivityTimer=40ms
...    NRCELL:drxProfile1:drxLongCycle=80ms
...    NRCELL:drxProfile1:drxOnDurationTimer=1ms
...    NRCELL:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS/NRDRB-1:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-1:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-1:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-1:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-1:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-1:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-1:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-1:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-1:nsaDrbParam:nsa3xBearerAllowed=false
...    NRBTS/NRDRB-1:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-1:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-1:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRCELL:a1MeashoEnabled=none
...    NRCELL:a2MeashoEnabled=none
...    NRCELL:a2MeasRedirectEnabled=none
...    NRCELL:a3MeasEnabled=none
...    NRCELL:a5MeasEnabled=none
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:mgta=ms0dot5
...    NRCELL:a1MeashoEnabledSA=rsrpCombined
...    NRCELL:a2MeashoEnabledSA=rsrpCombined
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=20
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=EnabledWithBtsInputReference
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48


@{Mobility_NRHOIF}
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL/NRHOIF-1:ssbFrequency=126530
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=12
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=12
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
...    NRCELL/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=12
...    NRCELL/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=12
...    NRCELL/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms160
@{Xn-link}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-1/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:gNbId=35
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
...    XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
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
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=788
@{PARAMS_TO_MODIFY_706_C_TC001}
...    NRCELL:a2MeashoEnabledSA=rsrpCombined
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:actCDrx=true
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a5MeasEnabled=none
@{PARAMS_TO_MODIFY_706_C_TC003}
...    NRCELL:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:actCDrx=true
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a5MeasEnabled=none
@{PARAMS_TO_MODIFY_706_C_TC004}
...    NRCELL:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:actCDrx=true
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a5MeasEnabled=none
@{PARAMS_TO_MODIFY_DRX_OFF}
...    NRCELL:actCDrx=false
${ue_sa_capabilities}    SEPARATOR=
...      E1A01000075F5A1302000201404824C5800260D40C13601873E618F28581C130080C47002A0D88DAC1184341020F940224B64C5
...      5050E7C471E31CF9863CA16070387813F8000000FE00000003801C00100388C0000000040460501A01813B639F0FD028038100C
...      0301802A03000301F04401000000008000010040000100200000C01000008008000058250020300C9C1280001938250060300C0
...      300C9C1280201806019382500A0300C0300C0300C9C128040180601806019382500E0300C0300C0300C0300C980200001C01000
...      010008000090040000500200002C0B654DE54D606560CD606D60AD6E91933594B591B5809581140F04000025949410000196525
...      040000A59490100003965240400012594901000059652404010180696525040001A5949410000796524040101C0796524040002
...      25949010000996524040002A5949010000B9652404000325949010000D965240354AAAE95555038AA0D174AA2A82C5576A2BB11
...      4AA2A93455298AA47154062A81450116808D028140A05028140A05028140A05028140A05028000000200C0184
${waiting_A2_MR}    2s

*** Test Cases ***
5GC000706_ET_C001_Verify_Inter-frequency_Inter-gNB_handover_based_on_A3_with_source_and_target_on_different_bandwidths_and_FR1_bands_without_DRX
    [Tags]    QC_81794    owner-xianjiao.xie   F089    C001
    OnlineParamChange    ${PARAMS_TO_MODIFY_706_C_TC001}
    Add UE History Information List    ue_id=1     event=A3
    UE register and setup PDU session    ue_id=1    pdu_id=1
    UE Triggers Inter-Freq-rsrpCombined Inter-DU HO to Better Cell and Check Traffic    ID=1    pci=381
    UE Triggers Inter-Frequency Inter-DU HO back to Signal Cell    ue_id=1
    check wireshark log  ${CURDIR}${/}A2A_C_001${/}a2a.ini    wait_string=criticalExtensions: rrcReconfigurationComplete::5
    release ues    ue_type=all

5GC000706_ET_C003_Verify_Inter-frequency_Inter-gNB_handover_based_on_A5_measurements_with_DRX_enabled_in_target
    [Documentation]    Support to active SA inter-frequency measurement configure with measurement gap.
    [Tags]    QC_61688    owner-xianjiao.xie    C003
    OnlineParamChange     ${PARAMS_TO_MODIFY_706_C_TC003}
    Add UE History Information List    ue_id=2     event=A3
    UE register and setup PDU session    ue_id=2    pdu_id=1
    UE DRX Change    ue_id=2    DRX_Switch=off
    UE Triggers Inter-Freq-rsrpAndRsrq Inter-DU HO to Better Cell and Check Traffic   ID=2    pci=381
    UE Triggers Inter-Frequency Inter-DU HO back to Signal Cell    ue_id=2
    check wireshark log  ${CURDIR}${/}A2A_C_003${/}a2a.ini    wait_string=criticalExtensions: rrcReconfigurationComplete::5
    release ues    ue_type=all

5GC000706_ET_C004_Verify_Inter-gNB_ho_based_on_A3_measurements_with_source_cell_supporting_DRX_and_target_cell_not_supporting_DRX
    [Documentation]    Support to active SA inter-frequency measurement configure with measurement gap.
    ...    UE cap: independentGapConfig off actCDrx: true
    ...    NRCELL-1: measGapSelectionSA:favorUeMeasurements, mgta: msdot5, gapOffset 8
    ...             a2MeashoEnabledSA:rsrp+rsrq, a1MeashoEnabledSA:rsrp
    ...    NRCELL-1/NRHOIF-1: a3MeasEnabled:rsrp
    [Tags]    QC_61689    owner-xianjiao.xie    C004
    OnlineParamChange    ${PARAMS_TO_MODIFY_706_C_TC004}
	Add UE History Information List    ue_id=3     event=A3
	UE DRX Change    ue_id=3    DRX_Switch=off
    UE register and setup PDU session    ue_id=3    pdu_id=1
    UE Triggers Inter-Freq-rsrpAndRsrq Inter-DU HO to Better Cell and Check Traffic    ID=3    pci=381
    UE DRX Change    ue_id=3    DRX_Switch=on
    OnlineParamChange    ${PARAMS_TO_MODIFY_DRX_OFF}
    UE Triggers Inter-Frequency Inter-DU HO back to Signal Cell    ue_id=3
    check wireshark log  ${CURDIR}${/}A2A_C_004${/}a2a.ini    wait_string=procedureCode: id-uEContextRelease::4
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells
    Comment    Debug Enter Into Egate

Modify Cfg
    ${SIM-GNB3}  catenate  set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...  nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${SIM-GNB3}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=40
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=135760:126380 gscn=1582
    Update Cfg    set_cell id=2 gnb=3 pci=127:1 tac=788 nrci=0x02 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=135760:126380 gscn=1582
    ${GNB2}  catenate  set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22 daemon=10.0.2.1:22222
    ...  xn=10.0.1.2 x2_peers=none amf=1
    Update Cfg    ${GNB2}
    ${GNB2_cell1}  catenate  set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    ...  nr_arfcn=136100:126900 gscn=1587
    Update Cfg    ${GNB2_cell1}

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be OnAir

Add UE History Information List
    [Arguments]    ${ue_id}   ${event}
    Execute Egate Command     ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=96
    Execute Egate Command     ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command     ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command     ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command     ue_enb_param id=${ue_id} ue_history_list=${ue_id}
    Execute Egate Command     gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=${event}

UE register and setup PDU session
    [Arguments]   ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command     set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command     ue_register id=${ue_id} ue_nr_capabilities=${ue_sa_capabilities}    NG RM Registered
    ${ret1}  Execute Egate Command     ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=drx-SlotOffset 0
    Should Contain    ${ret1}    Initial Context Setup Successful

UE Triggers Inter-Freq-rsrpCombined Inter-DU HO to Better Cell and Check Traffic
    [Arguments]    ${ID}    ${pci}
    trigger A2 event when set a2MeashoEnabledSA rsrpCombined    ue_id=${ID}
    trigger A3 event    ue_id=${ID}    phycell_id=${pci}
    traffic should be ok    ue_id=${ID}    type=SA

UE Triggers Inter-Freq-rsrpAndRsrq Inter-DU HO to Better Cell and Check Traffic
    [Arguments]    ${ID}    ${pci}
    trigger A2 event when set a2MeashoEnabledSA rsrpAndRsrq    ue_id=${ID}
    trigger A3 event    ue_id=${ID}    phycell_id=${pci}
    traffic should be ok    ue_id=${ID}    type=SA

UE Triggers Inter-Frequency Inter-DU HO back to Signal Cell
    [Arguments]      ${ue_id}
    sleep    ${waiting_A2_MR}    #Waiting for A2 measurement report sending complete
    ${meas_id}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=8 srsrq_nr=8
    ...    phycell_id=60 nrsrp_nr=35 nrsrq_nr=35 rs_type=ssb index=1 nrs_result=10:10:10
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

trigger A2 event when set a2MeashoEnabledSA rsrpCombined
    [Arguments]    ${ue_id}
    ${meas_id}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126990    event_type=A2
    ${ret2}=    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=8 srsrq_nr=8
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret2}=    Remove String    ${ret2}    \r    \n    ${SPACE}
    Should Contain    ${ret2}    measurementReport
    Should Contain    ${ret2}    measConfig
    Should Contain    ${ret2}    measIdToRemoveList{${meas_id}}
    Should Contain    ${ret2}    eventIdeventA1
    Should Contain    ${ret2}    eventIdeventA3
    Should not Contain    ${ret2}    eventIdeventA2

trigger A2 event when set a2MeashoEnabledSA rsrpAndRsrq
    [Arguments]    ${ue_id}
    ${meas_id}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126990    event_type=A2
    ${ret2}=    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=8 srsrq_nr=8
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret2}=    Remove String    ${ret2}    \r    \n    ${SPACE}
    Should Contain    ${ret2}    measurementReport
    Should Contain    ${ret2}    measConfig
    Should Contain    ${ret2}    measIdToRemoveList{${meas_id},2}
    Should Contain    ${ret2}    eventIdeventA1
    Should Contain    ${ret2}    eventIdeventA3
    Should not Contain    ${ret2}    eventIdeventA2

trigger A3 event
    [Arguments]    ${ue_id}    ${phycell_id}=51
    ${meas_id}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126530    event_type=A3
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR

UE DRX Change
    [Arguments]   ${ue_id}    ${DRX_Switch}
    Execute Egate Command    ue_gnb_param id=${ue_id} drx_config=${DRX_Switch}
