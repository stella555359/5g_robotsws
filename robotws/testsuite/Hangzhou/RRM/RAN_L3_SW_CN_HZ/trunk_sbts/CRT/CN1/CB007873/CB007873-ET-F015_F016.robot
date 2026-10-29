*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-L3CN3_SG2    owner-Song.xiuli    release-5G22R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***

@{PARAMS_IN_SCF}    @{Common_Config}    @{CELL12_Config}
@{Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:srb3SupportEnabled=false
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=true

@{CELL12_Config}
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
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
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=9
...    NRCELL-2:fPdcchMonOccsnPo=0
...    NRCELL-4:fPdcchMonOccsnPo=0

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

...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=36
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    delete:NRCELL-12/NRREL-1:sCellAdditionMethod

...    NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=71
...    NRBTS-1/NRADJNRCELL-1:cellDepType=NSA
...    NRBTS-1/NRADJNRCELL-1:gNbId=36
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=127200
...    NRBTS-1/NRADJNRCELL-1:physCellId=382
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJNRCELL-1:ssbFrequency=127230

...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:cellDepType=NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=127230

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=35
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=1
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    delete:NRCELL-12/NRREL-2:sCellAdditionMethod

...    NRBTS-1/NRADJNRCELL-2:freqBandIndicatorNR=41
...    NRBTS-1/NRADJNRCELL-2:cellDepType=NSA
...    NRBTS-1/NRADJNRCELL-2:gNbId=35
...    NRBTS-1/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-2:lcrId=1
...    NRBTS-1/NRADJNRCELL-2:nrarfcn=513234
...    NRBTS-1/NRADJNRCELL-2:physCellId=381
...    NRBTS-1/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJNRCELL-2:ssbFrequency=513150

...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:cellDepType=NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-2:scs=15 KHz
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-2:ssbFrequency=513150

@{enable_srb3}
...    NRBTS:srb3SupportEnabled=true

@{PM_Counters_Check_F015}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_F016}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL}>0

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
CB007873_5G_ET_F015_Verify NSA A3 rsrp interfreq intergNB HO successful without SRB3 from CA to FDD
    [Documentation]    This case will test A3 rsrp inter-Freq, IntergNB HO from CA to FDD without SRB3
    ...    Case steps:
    ...    1.CA(F+T pscell is cell 12) setup:scell added(scell is cell3),A2 configured drx setup without SRB3
    ...    2.Trigger A2 measurement report, expected result is A3 rsrp configured, measGap setup, drx release
    ...    3.Trigger A3 to handover to GNB4: phycellId:382
    ...    4.Trigger A3 to handoverback to real GNB CA(Pscell is cell 12,scell is cell3)
    [Tags]    QC_89197    F015
    Clear Counter files
    Ue Attach and Initial ENDC setup x2 link with gNB4
    Trigger A2 measurement report
    Triigger A3 Measurement Report to gNB4 cell1
    Trigger MeNB coordinate Measurement Gap Setup    ue_id=11
    Trigger A2 measurement report back from gNB4 cell1
    Trigger MeNB coordinate Measurement Gap off    ue_id=11
    Trigger A3 Measurement Report back to gNB2 cell12
    Check Counters    ${PM_Counters_Check_F015}
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_F015${/}a2a.ini


CB007873_5G_ET_F016_Verify NSA A3 rsrp interfreq intergNB HO successful without SRB3 from CA to TDD
    [Documentation]    This case will test A3 rsrp inter Freq, IntergNB HO from CA(F+T) to TDD without SRB3
    ...    Case steps:
    ...    1.CA(F+T pscell is cell12) setup:scell added(scell is cell3),A2 configured drx setup without SRB3
    ...    2.Trigger A2 measurement report, expected result is A3 rsrp configured, measGap setup, drx release
    ...    3.Trigger A3 to handover to GNB3:phycellId:381
    ...    4.Trigger A3 to handoverback to real GNB CA(Pscell is cell 12,scell is cell3)
    ...    5.Trigger A2 measurement report, expected result is A3 rsrp configured, measGap setup, drx release
    ...    6.Trigger A1 measurement report
    [Tags]    QC_105256    F016
    Clear Counter files
    Ue Attach and Initial ENDC setup x2 link with gNB3
    Trigger A2 measurement report
    Trigger Inter gNB Inter Cell HO with PsCellChange from CA to Tdd
    Trigger Inter gNB Inter Cell HO back with PsCellChange from Tdd to CA
    check wireshark log    ${CURDIR}${/}a2a_F016${/}a2a.ini
    delta commission parameters    ${enable_srb3}
    Trigger A2 measurement report
    Trigger A1 Measurement Report    A1_measId=1
    Check Counters    ${PM_Counters_Check_F016}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F    ue_count=5

Modify Cfg
    ${V2}    catenate
    ...    ue_param id=11 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ${V2}
    update Cfg    set_gnb id=3 s1u=10.0.1.122 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422
    update Cfg    set_gnb id=4 s1u=10.0.1.125 plmn=311:489 gnb_id=0x24:22 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.125:36422

Setup X2 lINK
    [Arguments]    ${eNB_ID}=1    ${gNB_ID}=1
    Execute Egate Command
    ...    enb_x2_link_up enb=${eNB_ID} target=${gNB_ID}
    ...    is up

Ue Attach and Initial ENDC setup x2 link with gNB4
    Setup X2 lINK    eNB_ID=1    gNB_ID=4
    UE attach    ue_id=11
    Initial ENDC    ue_id=11    target_cells=12
    Send And Verify Throuput    ue_id=11

Ue Attach and Initial ENDC setup x2 link with gNB3
    Setup X2 lINK    eNB_ID=1    gNB_ID=3
    UE attach    ue_id=11
    Initial ENDC    ue_id=11    target_cells=12
    Send And Verify Throuput    ue_id=11

UE attach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial ENDC
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    Sending SgNB Modification Confirm    timeout=20s
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=175    UE 11: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE 11: UDP UL
    Verify Throuput

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=11    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=11    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=11    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=11    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

Trigger MeNB coordinate Measurement Gap Setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_enb_param id=11 measurement_gap=gp0:12 gap_trigger=gnb_triggered

Trigger A2 measurement report
    Trigger MeNB coordinate Measurement Gap Setup    ue_id=11
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=11    carrierfreq=126750    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    SgNBModificationConfirm
    Trigger MeNB coordinate Measurement Gap off    ue_id=11

Trigger MeNB coordinate Measurement Gap off
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off

Triigger A3 Measurement Report to gNB4 cell1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=11    carrierfreq=127230    event_type=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=382 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    SgNBChangeConfirm

Trigger Inter gNB Inter Cell HO with PsCellChange from CA to Tdd
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=11    carrierfreq=513150    event_type=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    SgNBChangeConfirm


Trigger A2 measurement report back from gNB4 cell1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=11    carrierfreq=127230    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    rrcReconfigurationComplete

Trigger A2 measurement report back from gNB-3
    Trigger MeNB coordinate Measurement Gap Setup    ue_id=11
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=11    carrierfreq=513150    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    rrcReconfigurationComplete
    Trigger MeNB coordinate Measurement Gap off    ue_id=11

Trigger A3 Measurement Report back to gNB2 cell12
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=11    carrierfreq=126750    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBChangeConfirm
    Verify Throuput

Trigger Inter gNB Inter Cell HO back with PsCellChange from Tdd to CA
    Trigger A2 measurement report back from gNB-3
    Trigger A3 Measurement Report back to gNB2 cell12

Trigger A1 Measurement Report
    [Arguments]    ${A1_measId}=2
    Execute Egate Command    ue_measurement_send_nr id=11 meas_id=${A1_measId} event=A1 srsrp_nr=8 srsrq_nr=8 ssinr_nr=8
    ...    Successfully reconfigured dual connectivity
    Verify Throuput