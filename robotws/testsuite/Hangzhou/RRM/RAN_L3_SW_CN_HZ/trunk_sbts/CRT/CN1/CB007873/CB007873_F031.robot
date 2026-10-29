*** Settings ***
Suite Setup      Common Suite Setup And Setup Airphone Env
Suite Teardown   Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup       Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags       QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO
...              team-DevHZ5_SG2    owner-huibo.miao    release-5G21B    CB007873-F
Resource         ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN126900}    126750

@{PARAMS_IN_SCF}
...    @{CA_Common_Config}
...    @{non-srb3}
...    @{DRX}
...    @{CFRA}
...    @{A3_A5}
...    @{F031_precondition}
...    @{CELL12_CELL-1}
...    @{CELL12_CELL-14}
...    @{CELL14_CELL-12}
...    @{CELL14_CELL-1}

@{F031_precondition}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-14/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=20MHz
#...    NRCELL-14:type0CoresetConfigurationIndex=2
...    NRCELL:sCellDeactivationTimerGNB=infinity	

@{CA_Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=true

@{non-srb3}
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{DRX}
...    NRCELL:actCDrx=true

@{CFRA}
...    NRCELL:cbraPreamblesPerSsb=n60

@{A3_A5}
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:rsrpThresholdSSB=11
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{CELL12_CELL-1}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly

@{CELL12_CELL-14}
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=1
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed

@{CELL14_CELL-12}
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:gNbIdLength=22
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=false
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-12:handoverAllowedSA=allowed

@{CELL14_CELL-1}
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly
@{PM_Counters_Check_F031}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-14:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=3

${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C12016093170019C3D0304D9061CF9863CA160704C020311C02E
...    E3614606B04610D04083A40236B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0
...    E070F05C0017C0070005F0002400702A0D883AC1184341020F1008CAD931562439F604F88E
...    3C62471E439F51CF9863CA1607038784FEC000003FB0000001220380030F506C46D608C21A
...    081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F0000001FC00
...    000009001C00550388C080000240A838280388C000004240AC3C28000C2300008240AC1C28
...    080006020EB0F0A000305000040107003011A0140283902C09DB1CF870A74ED8E7C3851276
...    C73E1C089B1CF870A24ED8E7C31E81E00F000A070300E0600A80E000C0480080C07C120040
...    000000200000401000000008000010040000100200000C0100000800800005004002008020
...    08000060040000380200100000004000040020000240100080601802000028010000160080
...    0409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A08
...    00004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034
...    B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B2920
...    2000062CA480629555D2AAAA55174AA2A82C55038AA0D154A62A93455018AA051549AAA83C
...    5030BC04A8140A05028140A05028140A05028140A05028140A000800101E01820200400008
...    0600C101002008040300000080C004101002008040080018A1F000102030406070A0B0C0D1
...    01112131418191B1C1D1F2125262728292A2D2F41400

${Capa_LTE}    SEPARATOR=
...    A11FF82384C0C03850001C46000000122205C160601C46000002022205C16060182800010
...    488817078500018460001848881005011A0140030F003282449D1276C73E1C29D3B600002
...    24E893B600002201B000000600C4000100808010040201803040002010100C01820001008
...    08010001010020080403000

*** Test Cases ***
CB007873-5G-ET-F031_Verify_NSA_A3_rsrp_intrafreq_intragNB_HO_successful_without_SRB3_with_Pcell_different_bandwidth_from_CA_to_CA
    [Documentation]    Test A3 rsrp intra-Freq, IntragNB HO from CA(FDD+TDD) to CA(FDD+TDD) with Pcell different bandwidth
    ...    Case steps:
    ...    1.F+T: pscell is cell-12 (phycellId=61), blind scell added cell-1 (phycellId=50),drx setup without SRB3
    ...    2.Trigger A3 to handover to cell-14 (phycellId=63) with blind scell of cell-1
    ...    3.Trigger A3 to handoverback to CA(Pscell is cell-12,scell is cell-1)
    [Tags]    QC_89268    F031
    Clear Counter files
    Ue Attach To Cell and Initial Endc Blind Ca
    Trigger Measurement Report to cell14 and scell addition    A3
    Trigger Measurement Report back to cell12 and scell addition    A3
    Verify Throuput
    Check Counters    ${PM_Counters_Check_F031}
    Check Wireshark Log    ${CURDIR}${/}a2a_F031${/}a2a_wireshark.ini    wait_string=SgNBModificationConfirm::5
    UE Detach From GNB

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Ue Attach To Cell and Initial Endc Blind Ca
    Execute Egate Command    ue_change_location id=91 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=91
    Initial Endc And Blind Ca    ue_id=91    target_gnb=2    target_cells=12    bearer_id=2
    Send And Verify Throuput

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=30s

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8           
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

Trigger Measurement Report to cell14 and scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN126900}    event_type=${event_type}
    ${V2}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=63 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${output2}    Execute Egate Command    ${V2}    SgNBModificationConfirm
    Should Contain    ${output2}    SCellIndex 9 activated successfully

Trigger Measurement Report back to cell12 and scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN126900}    event_type=${event_type}
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${output3}    Execute Egate Command    ${V3}    SgNBModificationConfirm
    Should Contain    ${output3}    SCellIndex 9 activated successfully

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command    ue_detach id=91    ${expect_string}
