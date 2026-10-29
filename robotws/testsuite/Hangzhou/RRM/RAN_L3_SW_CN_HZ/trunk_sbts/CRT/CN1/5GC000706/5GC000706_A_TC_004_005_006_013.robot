*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    team-SG2
...    owner-baijie.zhu    release-5G20A    5GC000706
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000706_Base}
...    @{NRCELL}
...    @{NRADJNRCELL}
...    @{NRHOIF}
...    @{NRADJGNB}
...    @{NRREL}
...    @{NRCELL_FDD}

@{5GC000706_Base}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9
...    NRBTS:actDDDSPeriodOptimization=true
...    NRBTS:actFdmEnhancedScheduling=false
...    delete:NRBTS:blockingState
...    delete:NRBTS:ngInducedCellDeactDelayTimer
...    delete:NRBTS:sCCNumber
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS:actIncXn=true
...    NRBTS:actInterFreqHoSA=true

...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

@{NRCELL}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:actCDrx=false
...    NRCELL-1:mgta=ms0dot5
...    NRCELL-1:gapOffset=8
...    NRCELL-1:reportIntervalSA=ms120
...    NRCELL-1:reportOnLeave=false
...    NRCELL-1:reportAmountSA=r4
...    NRCELL-1:ifhoSsbSmtcOffset=8
...    NRCELL-1:gscnOrSsPbchArfcn=1587
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=10
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=40
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms64
...    NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=10
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms64

@{NRADJNRCELL}
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=257
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=2071675
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071675
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms160
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=5
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=40
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=75
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms5120
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160

@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-1/NRREL-10:gNbId=35
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3

@{NRADJGNB}
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3

@{NRCELL_FDD}
...    NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=136100

${UE_CAPA_A_UE}    SEPARATOR=
...    E5A000000147580303000049A3000481A0603100D0098040621803506C46D618C21A0C54083E500892D931541439F60478C73E618F28581C
...    0E1E04FE0000003F80000000A00E0741B402A9582308682041F297AAAAAAA9EAAAAAAA05007000401E23000740000000001988C004D00003
...    D02C02800341C0C0301802A030003014008000008018268000E7CC31E50B0303E008020000000100000200F286B0268020800003AE928200
...    002EBA4800E94555028A0219008A05028140A05028140A0000040C008018020040600400C0100210A0304414246400

${UE_CAPA_FR1}    SEPARATOR=
...    E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE594932834
...    0105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0390400000290400000A904000
...    01292500001A6017036F236B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA48480002A9652401340E2E91C5D
...    0A89A55115D8816007801A010080000000000200400840

@{PARAMS_TO_MODIFY_706_A_TC04}
...    NRCELL-1:a2MeashoEnabledSA=rsrp

@{ORG_PARAMS_TO_MODIFY_706_A_TC04}
...    NRCELL-1:a2MeashoEnabledSA=rsrpCombined

@{PARAMS_TO_MODIFY_706_A_TC05}
...    NRCELL-1:a1MeashoEnabledSA=rsrqCombined
...    NRCELL-1:a2MeashoEnabledSA=rsrqCombined
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrqCombined
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrqCombined

@{ORG_PARAMS_TO_MODIFY_706_A_TC05}
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq

@{PARAMS_TO_MODIFY_706_A_TC06}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none

@{ORG_PARAMS_TO_MODIFY_706_A_TC06}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq

@{PARAMS_TO_MODIFY_706_A_TC13}
...    NRCELL-1:a1MeashoEnabledSA=rsrq
...    NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrq
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none

@{ORG_PARAMS_TO_MODIFY_706_A_TC13_TC14}
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq

@{PARAMS_TO_MODIFY_706_A_TC14}
...    NRCELL-1:a1MeashoEnabledSA=rsrqCombined
...    NRCELL-1:a2MeashoEnabledSA=rsrqCombined
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrq
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none

*** Test Cases ***
5GC000706-ET-A004_Verify_A2_mesconfig_configured_successfully_with_ICS_optimized_with_PDU_Session_and_UE_Capability
    [Documentation]    This case is designed to verify:
    ...                1.ICS contain PDU session.
    ...                2.measConfig IE all values are set as NIDD.
    ...                3.no measurement gap contains in F1AP: UE Context Setup Response
    ...                4.independentGapConfig was configured in UE capability
    [Tags]    QC_61652    A004
    Online Update Parameters    ${PARAMS_TO_MODIFY_706_A_TC04}
    Register UE And Check A2 MeasConfig    ${CURDIR}${/}a2a_A004${/}Check_A2_MeasConfig.ini
    Ue Deregister And Restore Parameters    ${ORG_PARAMS_TO_MODIFY_706_A_TC04}
    Check Wireshark Log    ${CURDIR}${/}a2a_A004${/}a2a.ini    wait_string=InitialContextSetupResponse::2

5GC000706-ET-A005_Verify_A2_measurement_event_triggered_successfully_with_ICS_optimized_with_PDU_Session_and_UE_Capability
    [Documentation]    This case is designed to verify:
    ...                1.ICS contain PDU session.
    ...                2.measConfig IE all values are set as NIDD.
    ...                3.no measurement gap contains in F1AP: UE Context Setup Response.
    ...                4.independentGapConfig was configured in UE capability(per-FR).
    ...                5.A3/A5/A1 measurement is configured and a2 measurement is removed as NIDD setting in measConfig.
    [Tags]    QC_61657    A005
    Online Update Parameters    ${PARAMS_TO_MODIFY_706_A_TC05}
    Register UE And Check A2 MeasConfig    ${CURDIR}${/}a2a_A005${/}Check_A2_MeasConfig.ini
    Send A2 MR And Check Result
    Ue Deregister And Restore Parameters    ${ORG_PARAMS_TO_MODIFY_706_A_TC05}
    Check Wireshark Log    ${CURDIR}${/}a2a_A005${/}a2a.ini    wait_string=InitialContextSetupResponse::2

5GC000706-ET-A006_Verify_A2_measurement_configuration_not_sent_to_UE_when_A3_and_A5_measurement_not_configured
    [Documentation]    This case is designed to verify:
    ...                1. NRHOIF exist but not configure A3/A5.
    ...                2. UE registered successfully and no A2 configured in RRC Reconfiguration.
    ...                3. Measconfig always exists for 5G_CP_ARC_ALG_6168 and 5G_CP_IF_RRC_8445/8446/8447
    ...                [SA] [PR623363] If no measurements associated with the serving cell frequency are to be configured to the UE
    ...                 (and therefore no measObjectNR associated with the serving cell in RRC Reconfiguration).gNB-CU-CP shall
    ...                configure a PCell MeasObjectNR as per [5G_CP_IF_RRC_7295] if R&D parameter rdConfigureDefaultPcellMeasObject.
    ...                [5G_ARC_ALG_6168] is set to True[End PR623363] [End SA]
    [Tags]    QC_61654    A006
    Online Update Parameters    ${PARAMS_TO_MODIFY_706_A_TC06}
    Regester UE And Check The MeasConfig Exists But No A2    ${CURDIR}${/}a2a_A006${/}Check_A2_MeasConfig.ini
    Ue Deregister And Restore Parameters    ${ORG_PARAMS_TO_MODIFY_706_A_TC06}
    Check Wireshark Log    ${CURDIR}${/}a2a_A006${/}a2a.ini    wait_string=InitialContextSetupResponse::2

5GC000706-ET-A013_A014_Verify_MeasConfig_With_UE_Set_To_FR1_or_FR2_Capability_When_Source_Is_FR1_Target_Is_FR2
    [Documentation]    This case is designed to verify:
    ...                     A013 Check Point:
    ...                1. Set NRCELL/NRHOIF/freqBandIndicator configured with FR2
    ...                2. Set MRBTS/NRBTS/NRCELL.nrarfcn set to corresponding value with FR1.
    ...                3. Set UE Capability configured with FR1.
    ...                4. UE regester with patial Measconfig and no A2.
    ...                     A014 Check Point:
    ...                1. Set NRCELL/NRHOIF/freqBandIndicator configured with FR2
    ...                2. Set MRBTS/NRBTS/NRCELL.nrarfcn set to corresponding value with FR1.
    ...                3. Set UE Capability configured with FR1 + FR2.
    ...                4. UE regester with Measconfig.
    [Tags]    QC_61655    A013_A014
    Online Update Parameters    ${PARAMS_TO_MODIFY_706_A_TC13}
    Online Update UE Capability    ${UE_CAPA_FR1}
    Regester UE And Check The MeasConfig Exists But No A2    ${CURDIR}${/}a2a_A013_A014${/}Check_MeasConfig_13.ini
    Ue Deregister
    Online Update Parameters    ${PARAMS_TO_MODIFY_706_A_TC14}
    Online Update UE Capability    ${UE_CAPA_A_UE}
    Register UE And Check A2 MeasConfig    ${CURDIR}${/}a2a_A013_A014${/}Check_MeasConfig_14.ini
    Ue Deregister And Restore Parameters    ${ORG_PARAMS_TO_MODIFY_706_A_TC13_TC14}
    Check Wireshark Log    ${CURDIR}${/}a2a_A013_A014${/}a2a.ini    wait_string=InitialContextSetupResponse::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    GNB-3: XnAP Link with GNB-2
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    match_string=${match_string}

Modify Cfg
    ${V_1}    catenate
    ...    ue_param id=1 ue_nr_capabilities=${UE_CAPA_A_UE}
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
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633372:633372
    ...    gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb3_cell2}    catenate    set_cell id=2 gnb=3 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=2071675:2071675
    ...    gscn=22447 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell2}

Online Update Parameters
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    BuiltIn.Log To Console    Online Update Parameters is done

Ue Deregister
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Ue Deregister And Restore Parameters
    [Arguments]    ${ORG_Param}
    Ue Deregister
    Delta Commission Parameters    ${ORG_Param}

Register UE And Check A2 MeasConfig
    [Arguments]    ${RRC_Ini}
    Start RRC Log    Check_A2_MeasConfig
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=Initial Context Setup Successful
    Check RRC log    ${RRC_Ini}

Regester UE And Check The MeasConfig Exists But No A2
    [Arguments]    ${RRC_Ini}
    Start RRC Log     Check_A2_MeasConfig
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    ${egate_log}    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=Initial Context Setup Successful
    should contain     ${egate_log}    measConfig
    should not contain    ${egate_log}    eventA2
    Check RRC log    ${RRC_Ini}

Send A2 MR And Check Result
    Start RRC Log     Check_A3_A5_MeasConfig
    ${A2_egate_log}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    should not contain     ${A2_egate_log}    measGapConfig
    Check RRC log    ${CURDIR}${/}a2a_A005${/}Check_A3_A5_MeasConfig.ini

Online Update UE Capability
    [Arguments]    ${UE_CAPA}=${UE_CAPA_A_UE}
    Execute Egate Command    ue_param id=1 ue_nr_capabilities=${UE_CAPA}

