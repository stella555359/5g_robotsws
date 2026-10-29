*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...               team-DevHZ5_SG2    owner-huibo.miao    release-5G21B    CB007873-F
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN127180}    127210    #cell12_ssbfreq_band71

@{PARAMS_IN_SCF}
...    @{CA_Common_Config}
...    @{non-srb3}
...    @{CELL12_Config}

@{CA_Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
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

@{CELL12_Config}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1589

...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:rsrpThresholdSSB=11
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:filterCoeffSsbRsrp=fc4
...    NRCELL-12:sMeasConfigSsbRsrp=1

...    NRCELL-12:actCDrx=true
...    NRCELL-12:cbraPreamblesPerSsb=n60

...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed

...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=36
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed

...    NRADJNRCELL-1:cellDepType=NSA
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=127180
...    NRADJNRCELL-1:physCellId=382
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:freqBandIndicatorNR=71

@{srb3}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{PM_Counters_Check_F033_F035}
...    ${X2_SGNB_CHG_REQD_SENT}=2
...    ${X2_SGNB_CHG_CONF_RECEIVED}=2
...    ${X2_SGNB_ADD_REQ_SN_CH_RCVD}=2
...    ${X2_SGNB_ADD_REQ_ACK_SN_CH_SENT}=2
...    ${X2_SGNB_RECONF_SN_CH_RCVD}=2
...    ${X2_SGNB_RECONF_ACK_SN_CH_RCVD}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=4
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=4
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=4
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=4
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=4
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=4
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=4
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=4
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_REQ}=4
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_SUCC}=4
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL}>0

${X2_SGNB_CHG_REQD_SENT}             M55112C02501
${X2_SGNB_CHG_CONF_RECEIVED}         M55112C02502
${X2_SGNB_ADD_REQ_SN_CH_RCVD}        M55112C02503
${X2_SGNB_ADD_REQ_ACK_SN_CH_SENT}    M55112C02504
${X2_SGNB_RECONF_SN_CH_RCVD}         M55112C02505
${X2_SGNB_RECONF_ACK_SN_CH_RCVD}     M55112C02506
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000


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
CB007873-5G-ET-F033-F035_Verify_NSA_A3_rsrp_intrafreq_intergNB_HO_successful_from_CA_to_FDD
    [Documentation]    Test A3 rsrp intrafreq IntergNB HO from CA(n71+n41) to FDD and HO back including with and without SRB3 
    ...    Case steps:
    ...    1.F+T: pscell is cell-12 (phycellId=61), blind scell added cell-3 (phycellId=52),drx setup without SRB3
    ...    2.Trigger A3 to handover to GNB4: phycellId:382
    ...    3.Trigger A3 to handoverback to real GNB CA(Pscell is cell-12,scell is cell-3)
    ...    4.Configuration modified from without SRB3 to with SRB3
    ...    5.Repeat step1 to step3
    [Tags]    QC_89201    
    Clear Counter files
    X2 Link for simulated gNB4
    F-T CA Intra-freq inter-gnb HO and back
    UE Detach From GNB
    Delta Commission Parameters    ${srb3}
    F-T CA Intra-freq inter-gnb HO and back
    UE Detach From GNB
    Check Counters    ${PM_Counters_Check_F033_F035}
    Check Wireshark Log    ${CURDIR}${/}a2a_F033_F035${/}a2a_wireshark.ini    wait_string=UEContextRelease::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    update Cfg    set_gnb id=4 s1u=10.0.1.125 plmn=311:489 gnb_id=0x24:22 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.125:36422
    ${V3}    catenate
    ...    set_cell id=1 gnb=4 pci=127:1 tac=777 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999
    ...    nr_arfcn=134980:127180 gscn=1589 mandatory_for_activation=off
    update Cfg    ${V3}

X2 Link for simulated gNB4
    Execute Egate Command    enb_x2_link_up enb=1 target=4    
    ...    pass_regexp=is UP

F-T CA Intra-freq inter-gnb HO and back
    Ue Attach To Cell and Initial Endc Blind Ca
    Triigger A3 Measurement Report to gNB4 cell1
    Trigger A3 Measurement Report back to gNB2 cell12
    Verify Throuput

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
    ...    SCellIndex 9 activated successfully
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=15s

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    #Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8           
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>135

Triigger A3 Measurement Report to gNB4 cell1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN127180}    event_type=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=382 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${V2}    SgNBChangeConfirm

Trigger A3 Measurement Report back to gNB2 cell12
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN127180}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${V3}    SgNBChangeConfirm

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command    ue_detach id=91    ${expect_string}
