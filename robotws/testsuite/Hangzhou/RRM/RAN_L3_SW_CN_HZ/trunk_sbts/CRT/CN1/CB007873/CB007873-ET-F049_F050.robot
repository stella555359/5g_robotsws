*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G   RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-L3CN3_SG2    owner-Song.xiuli    release-5G22R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/6cells_4T2F

@{PARAMS_IN_SCF}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:srb3SupportEnabled=false
...    NRDU-1:flexibleCAMode=MixedCAMode
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=false

...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:actCDrx=true
...    NRCELL-12:cbraPreamblesPerSsb=n60
...    NRCELL-12:rsrpThresholdSSB=15
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=3
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly

...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-1:cellDepType=NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=508110
...    NRCELL-12/NRHOIF-1:scs=30 KHz

...    NRCELL-2:a1MeasSCellAddEnabled=none
...    NRCELL-3:a1MeasSCellAddEnabled=none
...    NRCELL-11:a1MeasSCellAddEnabled=none
...    NRCELL-2:fPdcchMonOccsnPo=1
...    NRCELL-4:fPdcchMonOccsnPo=1
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=9

@{PM_Counters_Check_F049}
...    NRCELL-12:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=3
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=3
...    NRCELL-12:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=3
...    NRCELL-12:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=3
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-3:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-3:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=3
...    NRCELL-12:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-3:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_F050}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=3
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=3
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=3
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=3
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=3
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=3
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_SUCC}=3

${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007

${IntraMeNBMobility}    NRBTS:actIntraMeNBMobility=true
${InterMeNBMobility}    NRBTS:actInterMeNBMobility=true

${BTS_STARTUP_RETRY}    2

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C12016093170019C3D0304D9061CF9863CA160704C020311C02EE3614606B046
...    10D04083A40236B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C0017C0070005F000
...    2400702A0D883AC1184341020F1008CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC0
...    00003FB0000001220380030F506C46D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC3
...    1E50B0381C3C27F0000001FC00000009001C00550388C080000240A838280388C000004240AC3C28000C23
...    00008240AC1C28080006020EB0F0A000305000040107003011A0140283902C09DB1CF870A74ED8E7C38512
...    76C73E1C089B1CF870A24ED8E7C31E81E00F000A070300E0600A80E000C0480080C07C1200400000002000
...    00401000000008000010040000100200000C01000008008000050040020080200800006004000038020010
...    00000040000400200002401000806018020000280100001600800409024010000180672A6B2A6B052B032B
...    066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA4808
...    00024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172
...    CA4A0800064B29202000062CA480629555D2AAAA55174AA2A82C55038AA0D154A62A93455018AA051549AA
...    A83C5030BC04A8140A05028140A05028140A05028140A05028140A000800101E018202004000080600C101
...    002008040300000080C004101002008040080018A1F000102030406070A0B0C0D101112131418191B1C1D1
...    F2125262728292A2D2F41400

${Capa_LTE}    SEPARATOR=
...    A11FF82384C0C03850001C46000000122205C160601C46000002022205C160601828000104888170785000
...    18460001848881005011A0140030F003282449D1276C73E1C29D3B60000224E893B600002201B000000600
...    C4000100808010040201803040002010100C0182000100808010001010020080403000

*** Test Cases ***
CB007873_5G_ET_F049 Verify NSA after A2 then intrafreq intraMeNB intraCell HO without SCGChange
    [Documentation]    This case will test intraMeNB HO without SCGchange after A2 MR  measgap is released.
    ...    Precondication:actIntraMeNBMobility=true
    ...    Case steps:
    ...    1.CA(F+T pscell is cell12:phycel-61 and scell is cell3:phycel-52 blind add scell drx setup without SRB3.
    ...    2.Trigger A2 MR of gNB side.
    ...    3.intraMeNB intracell HO without SCG change:enb1 cell 1 HO to enb1 cell
    [Tags]    QC_97169    F049
    Clear Counter files    False
    Delta Commission Enable Intra MeNB Mobility
    Ue Attach To gNB and Initial ENDC
    Trigger MeNB coordinate Measurement Gap Setup    ue_id=11
    Trigger A2 measurement report
    Triigger IntraMeNB IntraCell HO    ue_id=11
    Triigger IntraMeNB IntraCell HO    ue_id=11
    Trigger MeNB coordinate Measurement Gap off
    Check Counters    ${PM_Counters_Check_F049}
    check wireshark log    ${CURDIR}${/}a2a_F049${/}a2a.ini

CB007873_5G_ET_F050_Verify NSA after A2 then intrafreq interMeNB intraCell HO without SCGChange
    [Documentation]    This case will test interMeNB HO without SCGchange after A2 MR  measgap is released.
    ...    precondition:actInterMeNBMobility=true
    ...    Case steps:
    ...    1.CA(F+T pscell is cell12:phycel-61 and scell is cell3:phycel-52,blind add scell,drx setup without SRB3.
    ...    2.Trigger A2 MR of gNB side.
    ...    3.interMeNB HO between eNB-11 cell-1 and eNB-1 cell-1 then HO back without SCG change.
    [Tags]    QC_97170    F050
    Clear Counter files    False
    Delta Commission Enable Inter MeNB Mobility
    Ue Attach To gNB and Initial ENDC
    Trigger MeNB coordinate Measurement Gap Setup    ue_id=11
    Trigger A2 measurement report
    Triigger InterMeNB InterCell HO without SCGChange   ue_id=11    enb_id=11    cell_id=1
    Triigger InterMeNB InterCell HO without SCGChange   ue_id=11    enb_id=1    cell_id=1
    Trigger MeNB coordinate Measurement Gap off
    Check Counters    ${PM_Counters_Check_F050}
	check wireshark log    ${CURDIR}${/}a2a_F050${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}    ue_count=5

Modify Cfg
    ${V2}    catenate
    ...    ue_param id=11 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V3}    catenate
    ...    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+zuc nea=null+zuc imsi=311:489:21645500
    ${V4}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
    ...    type=simulated x2_peers=none
    ${V5}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    ${V4}
    Update Cfg    ${V5}
    Update Cfg    set_bearer id=2 ue=11 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14

Delta Commission Enable Intra MeNB Mobility
    Delta Commission Parameters    ${IntraMeNBMobility}

Delta Commission Enable Inter MeNB Mobility
    Delta Commission Parameters    ${InterMeNBMobility}

Setup X2 lINK and Allowed ENDC on with eNB11
    [Arguments]    ${enb_id}=1    ${cell_id}=1
    Execute Egate Command    enb_x2_link_up enb=${enb_id} target=2    pass_regexp=ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${cell_id} allow_endc=on

Ue Attach To gNB and Initial ENDC
    Setup X2 lINK and Allowed ENDC on with eNB11    enb_id=11
    UE attach gNB cell1    ue_id=11
    Initial ENDC    ue_id=11    target_gnb=2    target_cells=12    bearer_id=2
    Send And Verify Throuput    ue_id=11

UE attach gNB cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial ENDC
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
	${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
	...    Sending SgNB Modification Confirm    timeout=20s
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
	Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5    UE 11: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    UE 11: UDP UL
    Verify Throuput    ue_id=11

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6

Trigger MeNB coordinate Measurement Gap Setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered

Trigger A2 measurement report
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=11    carrierfreq=126750    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    SgNBModificationConfirm

Trigger MeNB coordinate Measurement Gap off
    Execute Egate Command    ue_enb_param id=11 measurement_gap=off

Triigger IntraMeNB IntraCell HO
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_reauth id=${ue_id}    pass_regexp=SgNBModificationConfirm

Triigger InterMeNB InterCell HO without SCGChange
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${cell_id}    Sending SgNB Modification Confirm
