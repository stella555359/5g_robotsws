*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G
...               Regression_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD  team-CN1  owner-alex.2.wang  release-5G21B
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/3cells_1T2F
@{PARAMS_IN_SCF}
...  @{CA_Basic}
...  @{CB007893}
...  @{Mobility}

@{CA_Basic}
...  NRDU-1:actInterNumerologyCa=true
...  NRDU-1:flexibleCAMode=MixedCAMode
...  NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...  NRCELL-1:pucchModeSelect=longPucch
...  NRBTS:cipherPrefL:nea0=9
...  NRBTS:sCellActivationMethod=bufferBased

@{CB007893}
...  NRBTS:actMeasBasedSCellAdditionSa=A1-based
...  NRBTS:actMeasBasedSCellAdditionNsa=true
...  NRCELL-1:a1MeasSCellAddEnabled=rsrpCombined
...  NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...  NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...  NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...  NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=20|a1TimeToTriggerSCellAddSsbRsrq=320ms
...  NRCELL-2:a2MeasSCellRelEnabled=rsrpCombined
...  NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...  NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...  NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...  NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-10:gNbId=2
...  NRCELL-1/NRREL-10:gNbIdLength=22
...  NRCELL-1/NRREL-10:lcrId=2
...  NRCELL-1/NRREL-10:removeNotAllowed=false
...  NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1

${ue_eutra_nr_capabilities}  SEPARATOR=
...  A11FF82382C0C0388C00000404440B84C0C030500711800001048881709818070A000308C0003091102E130300E140007118000000488810050
...  11A0140030505D04853A76C73E1C49D1276C73E1C403639F0E201B1CF860C018800020101002008040300608000402020180308000201010020
...  00040300610000402020040100806000 ue_nr_capabilities=E9A09000575F5A13160003C12016093170019C3D0304D9061CF9863CA160704
...  C020311C02EE3614606B04610D04083A40236B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C0017C0070005F000240070
...  2A0D883AC1184341020F1008CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB0000001220380030F506C46D608C
...  21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F0000001FC00000009001C00550388C080000240A838280388
...  C000004240AC3C28000C2300008240AC1C28080006020EB0F0A000305000040107003011A0140283902C09DB1CF870A74ED8E7C3851276C73E1
...  C089B1CF870A24ED8E7C31E81E00F000A070300E0600A80E000C0480080C07C120040000000200000401000000008000010040000100200000C
...  0100000800800005004002008020080000600400003802001000000040000400200002401000806018020000280100001600800409024010000
...  180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B29
...  2020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480629555D2A
...  AAA55174AA2A82C55038AA0D154A62A93455018AA051549AAA83C5030BC04A8140A05028140A05028140A05028140A05028140A000800101E01
...  8202004000080600C101002008040300000080C004101002008040080018A1F000102030406070A0B0C0D101112131418191B1C1D1F21252627
...  28292A2D2F41400

@{PM_COUNTERS_F01_F03_F04_F05}
...  NRCELL-1:${RRC_RECONF_1_SCELL_DL_ATT}=1
...  NRCELL-1:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...  NRCELL-1:${A2MEAS_REL1DLSCELL_ATT_NSA}=1
...  NRCELL-1:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1

@{PM_COUNTERS_F02}
...  NRCELL-1:${RRC_RECONF_1_SCELL_DL_ATT}=4
...  NRCELL-1:${RRC_RECONF_1_SCELL_DL_SUCC}=4
...  NRCELL-1:${A2MEAS_REL1DLSCELL_ATT_NSA}=4
...  NRCELL-1:${A2MEAS_REL1DLSCELL_SUCC_NSA}=4

${RRC_RECONF_1_SCELL_DL_ATT}  M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}  M55118C03000
${A2MEAS_REL1DLSCELL_ATT_NSA}  M55118C06503
${A2MEAS_REL1DLSCELL_SUCC_NSA}  M55118C06504
@{5GC000578_srb3support}  NRBTS:srb3SupportEnabled=true
@{5GC000578_srb3notsupport}  NRBTS:srb3SupportEnabled=false

@{Mobility}
...  NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...  NRBTS:tDCoverall=10000
...  NRBTS:timerX2UeProcGuard=15000
...  NRBTS:cipherPrefL:nea0=9
...  NRBTS:cipherPrefL:nea2_128=0
...  NRBTS:cipherPrefL:nea1_128=0
...  NRBTS:cipherPrefL:nea3_128=9
...  NRBTS/NRADJNRCELL-4915:cellDepType=NSA
...  NRBTS/NRADJNRCELL-4915:gNbId=3
...  NRBTS/NRADJNRCELL-4915:gNbIdLength=22
...  NRBTS/NRADJNRCELL-4915:lcrId=3
...  NRBTS/NRADJNRCELL-4915:nrarfcn=127210
...  NRBTS/NRADJNRCELL-4915:physCellId=381
...  NRBTS/NRADJNRCELL-4915:gnbPlmn:mnc=255
...  NRBTS/NRADJNRCELL-4915:gnbPlmn:mcc=250
...  NRBTS/NRADJNRCELL-4915:gnbPlmn:mncLength=3
...  delete:NRBTS/NRADJNRCELL-4915:freqBandIndicatorNR
...  NRCELL-1/NRREL-1:gNbId=3
...  NRCELL-1/NRREL-1:gNbIdLength=22
...  NRCELL-1/NRREL-1:lcrId=3
...  NRCELL-1/NRREL-1:gnbPlmn:mnc=255
...  NRCELL-1/NRREL-1:gnbPlmn:mcc=250
...  NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...  NRCELL-1:a3MeasEnabled=rsrp
...  NRCELL-1:absThreshSsbRsrpConsolidation=1
...  NRCELL-1:sMeasConfigSsbRsrp=1
...  NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...  NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...  NRBTS:actInterFreqIntraGnbMobilityNSA=true
...  NRBTS:actInterMeNBMobility=true
...  NRBTS:actIntraMeNBMobility=true
...  NRCELL-1:a1MeashoEnabled=rsrp
...  NRCELL-1:a2MeashoEnabled=rsrp
...  NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...  NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...  NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...  NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=40
...  NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL-1/NRHOIF-1:cellDepType=NSA
...  NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...  NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...  NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...  NRCELL-1/NRHOIF-1:ssbFrequency=518670
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...  NRCELL-2:a1MeashoEnabled=rsrp
...  NRCELL-2:a2MeashoEnabled=rsrp
...  NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...  NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...  NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...  NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=40
...  NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL-2/NRHOIF-1:cellDepType=NSA
...  NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...  NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...  NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...  NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...  NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...  NRCELL-2/NRHOIF-1:ssbFrequency=127210
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...  NRCELL-2/NRREL-10:gNbId=2
...  NRCELL-2/NRREL-10:gNbIdLength=22
...  NRCELL-2/NRREL-10:lcrId=1
...  NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...  NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...  NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...  NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...  NRCELL-2:a3MeasEnabled=rsrp
...  NRCELL-2:absThreshSsbRsrpConsolidation=1
...  NRCELL-2:sMeasConfigSsbRsrp=1
...  NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...  NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

${candidate_cells_mn_hex_for_menb_ho_to_PCI50}  0907c3a82190
${candidate_cells_mn_hex_for_menb_ho_to_PCI60}  0907C3A821E0
@{PM_COUNTERS_F10}
...  NRCELL-1:${RRC_RECONF_1_SCELL_DL_ATT}=2
...  NRCELL-1:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...  NRCELL-1:${A2MEAS_REL1DLSCELL_ATT_NSA}=0
...  NRCELL-1:${A2MEAS_REL1DLSCELL_SUCC_NSA}=0
${set_enb_11}  set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222
...  x2=10.0.1.127 x2u=10.0.1.137 type=simulated x2_peers=none
@{PM_Counters}
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
${SOS_REPORT_FLAG}    pass:False,fail:False

*** Test Cases ***
CB007893-EA-B1_ET_07_01_PCell A1 trigger SCell addition for NSA without SRB3 after MeNB initiated SgNB Addition Request procedure with PSCell change
  [Documentation]
  ...  This case is to verify
  ...  when srb3SupportEnabled is disable in GNB, after SgNB Addition Request procedure with PSCell change by eNB HO,
  ...  A1 report to trigger Scell
  ...  Addition without SRB3
  [Tags]    CRT
  clear counter files
  Set UE Parameters Before Attach
  UE Attach and establish EN-DC on TDD cell
  inter-eNB handover Trigger Pcell change to FDD Cell
  Pcell A1 report to trigger Scell Addition  meas_id=5
  Check counters  ${PM_Counters}
  check wireshark log  ${CURDIR}${/}a2a_CB007893-EA-B1_ET_07_01${/}a2a.ini

CB007893-EA-B1_ET_04_01_PCell A1 triggered SCell addition for NSA with SRB3 after intra gNB HO
  [Documentation]
  ...  This case is to verify
  ...  A1 report to trigger Scell Addition via SRB3 after NSA call HO from TDD Cell to FDD Cell
  [Tags]    CRT
  clear counter files
  Set UE Parameters Before Attach
  Enable sbr3
  UE Attach and establish EN-DC on TDD cell
  Trigger intra gnb HO without Menb change
  UE report A1 measurement report via SRB3  meas_id=6
  Check RRC Log  ${CURDIR}${/}a2a_CB007893-EA_ET_04${/}a2a.ini
  Check counters  ${PM_Counters}

CB007893-F_ET_01_01_PCell A1 triggered SCell addition for NSA without SRB3 after EN-DC establish then Scell A2 measurement report
  [Documentation]  Disable SRB3 feature , then trigger AI to add scell successfully , then release scell.
  [Tags]    CRT
  clear counter files
  Set UE Parameters Before Attach
  UE Attach and establish EN-DC
  Pcell A1 report to trigger Scell Addition
  Scell A2 report to trigger Scell Release
  Check RRC Log  ${CURDIR}${/}a2a_CB007893-F_ET_01${/}a2a.ini
  Check Counters  ${PM_COUNTERS_F01_F03_F04_F05}

CB007893-F_ET_02_01_PCell A1 triggered SCell addition for NSA with SRB3 after EN-DC establish then Scell A2 measurement report
  [Documentation]
  ...  Enable SRB3,then trigger A1 to add scell would via SBR3, cause there was one PR due to counter update noty
  ...  correctly with SRB3 enable,
  ...  so add 3 more times A1 add and A2 release.
  [Tags]    CIT    RAN_5G    RAN_5G_TDD
  clear counter files
  Set UE Parameters Before Attach
  Enable sbr3
  UE Attach and establish EN-DC
  UE report A1 measurement report via SRB3
  Scell A2 report to trigger Scell Release
  Repat 3 times to check counters with srb3 enable  meas_id=3,3,3
  Disable sbr3
  Check RRC Log  ${CURDIR}${/}a2a_CB007893-F_ET_02${/}a2a.ini
  Check Counters  ${PM_COUNTERS_F02}

CB007893-F_ET_03_01_PCell A1 triggered SCell addition for NSA without SRB3 after intra gNB HO then Scell A2 measurement report
  [Documentation]  GNB side trigger intra HO from TDD cell to FDD cell ,then triggrer A1 to add scell , A2 to release scell.
  [Tags]    CRT
  clear counter files
  Set UE Parameters Before Attach
  UE Attach and establish EN-DC on TDD cell
  Trigger intra gnb HO without Menb change
  Pcell A1 report to trigger Scell Addition  meas_id=6
  Scell A2 report to trigger Scell Release  meas_id=0
  Check RRC Log  ${CURDIR}${/}a2a_CB007893-F_ET_03${/}a2a.ini
  Check Counters  ${PM_COUNTERS_F01_F03_F04_F05}

CB007893-F_ET_04_01_PCell A1 triggered SCell addition for NSA without SRB3 after MeNB initiated SgNB Modification
  [Documentation]  Case name : PCell A1 triggered SCell addition for NSA without SRB3 after MeNB initiated SgNB Modification
  ...  procedure withPSCell change then Scell A2 measurement report
	...  This case is to verify after pscell change which triggered by intra-enb HO , then scell addition via A1 and scell
	...  via A2 colud execution normally.
	[Tags]    CRT
  clear counter files
  Set UE Parameters Before Attach
  UE Attach and establish EN-DC on TDD cell
  Intra-eNB HO trigger PSCell Change
  Pcell A1 report to trigger Scell Addition  meas_id=5
  Scell A2 report to trigger Scell Release  meas_id=0
  Recover environment
  Check RRC Log  ${CURDIR}${/}a2a_CB007893-F_ET_04${/}a2a.ini
  Check Counters  ${PM_COUNTERS_F01_F03_F04_F05}

CB007893-F_ET_10_01_Scell release due to MeNB initiated SgNB Modification procedure with allowedBC-List change
  [Documentation]
  ...  Firstly ,UE report A1 to add scell successfully , then trigger Menb to not support F-T CA , and CA would release
  ...  but not update A2
  ...  related counters , then make it to support F-T , and report A1 one more time , scelll addition successfully.
  [Tags]    CRT
  clear counter files
  Set UE Parameters Before Attach
  UE Attach and establish EN-DC
  Pcell A1 report to trigger Scell Addition
  MeNB initiated SgNB Modification procedure with allowedBC-List change to do not support F-T CA
  MeNB initiated SgNB Modification procedure with allowedBC-List change to support F-T CA again
  Pcell A1 report to trigger Scell Addition
  Check RRC Log  ${CURDIR}${/}a2a_CB007893-F_ET_10${/}a2a.ini
  Check Counters  ${PM_COUNTERS_F10}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=${GNB1_CONFIG}
    Comment    Debug Enter Into Egate

Modify Cfg
  Update Cfg  enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
  ${set_cell12}  catenate  set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890
  ...  earfcn=2000:20000 mandatory_for_activation=off
  Update Cfg  ${set_cell12}
  ${set_gnb2}  catenate  set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422
  ...  x2_peers=none ng=10.0.1.2 xn=10.0.1.2 amf=1 nssai=0x1:0xd143a5
  Update Cfg  ${set_gnb2}
  Update Cfg  ${set_enb_11}
  Update Cfg  enb_param id=11 drb_id_begin=3 endc_capable_qci=all
  Update Cfg
  ...  set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000 mandatory_for_activation=off
  Update Cfg  enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14

Set UE Parameters Before Attach
    Execute Egate Command  enb_x2_link_up enb=11 target=2  ENB-11: X2AP Link with GNB-2
    Execute Egate Command  trace enb=11 protocol=all on
    Disable sbr3
    Execute Egate Command  ue_change_location id=31 enb=1 cell=1  location  #move to origin place
    Execute Egate Command  ue_enb_param id=31 measurement_gap=off

inter-eNB handover Trigger Pcell change to FDD Cell
  [Arguments]  ${ue_id}=31  ${cell_id_Target}=1
  ...  ${candidate_cells_mn_hex_for_menb_ho}=${candidate_cells_mn_hex_for_menb_ho_to_PCI60}
  Execute Egate Command  enb_cell_param enb=11 id=${cell_id_Target} allow_endc=on
  Execute Egate Command  ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
  ${ret1}  Execute Egate Command  ue_ho id=31 enb=11 cell=${cell_id_Target}  Intra-SGW X2 Handover \\(eNB 1 -> eNB 11\\) completed
  Should not Contain  ${ret1}  servCellIndex 9
  Should Contain  ${ret1}  servCellIndex 8
  Should Contain  ${ret1}  eventId eventA1
  Should Contain  ${ret1}  Proxy (eNB 2 cell 1) reported successful RA
  Should Contain  ${ret1}  Inter-eNB handover from ENB-1.1 to ENB-11.1 performed

UE Attach and establish EN-DC
  Start RRC Log  establish_EN-DC
  Execute Egate Command  ue_attach id=31 ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}  UE IS ACTIVE
  Execute Egate Command  ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
  ...  UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
  Get RRC Log

Pcell A1 report to trigger Scell Addition
  [Arguments]  ${meas_id}=3
  Start RRC Log  Scell_Addition_${meas_id}
  ${ret1}=  Execute Egate Command
  ...  ue_measurement_send_nr id=31 meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
  ...  SgNBModificationConfirm  timeout=20s
  Should Contain  ${ret1}  Successfully reconfigured dual connectivity  #CA succesffully ,pci 51 as scekll
  Should Contain  ${ret1}  rrcConnectionReconfigurationComplete  #NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50
  Should Contain  ${ret1}  eventA2
  Should Contain  ${ret1}  sCellToAddModList
  Get RRC Log

Scell A2 report to trigger Scell Release
  [Arguments]  ${meas_id}=3
  Start RRC Log  Scell_Release_${${meas_id}+1}
  ${ret1}  Execute Egate Command
  ...  ue_measurement_send_nr id=31 meas_id=${${meas_id}+1} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
  ...  SgNBModificationConfirm
  Should Contain  ${ret1}  eventId eventA1
  Should Contain  ${ret1}  a1-Threshold rsrp : 70  #NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
  Should Contain  ${ret1}  sCellToReleaseList
  Get RRC Log

Enable sbr3
  Delta Commission Parameters  ${5GC000578_srb3support}

UE report A1 measurement report via SRB3
  [Arguments]  ${meas_id}=3
  Start RRC Log  Scell_Addition_SRB3_${meas_id}
  ${ret1}=  Execute Egate Command
  ...  ue_measurement_send_nr id=31 meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
  ...  SgNBModificationConfirm
  Should Contain  ${ret1}  value UL-DCCH-Message
  Should Contain  ${ret1}  criticalExtensions measurementReport  #A1 measurement report via SRB3
  Should Contain  ${ret1}   physCellId 50  #CA succesffully ,pci 51 as scekll
  Should Contain  ${ret1}  a2-Threshold rsrp : 50  #NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50
  Get RRC Log

Disable sbr3
  Delta Commission Parameters  ${5GC000578_srb3notsupport}

UE Attach and establish EN-DC on TDD cell
  Start RRC Log  establish_EN-DC_TDD
  Execute Egate Command  ue_attach id=31 ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}  UE IS ACTIVE
  Execute Egate Command  ue_dc_enb_start ue=31 target_gnb=2 target_cells=2 bearer=2 type=split_scg
  ...  UE31: Proxy \\(eNB 2 cell 2\\) reported successful RA
  Get RRC Log

Trigger intra gnb HO without Menb change
  Start RRC Log  intra_HO
  Execute Egate Command  ue_enb_param id=31 measurement_gap=gp0:20 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
  Execute Egate Command  ue_measurement_send_nr id=31 meas_id=2 phycell_id=50 event=A2 srsrp_nr=30 srsrq_nr=40
  ...  SgNBModificationConfirm
  ${ret1}=  Execute Egate Command
  ...  ue_measurement_send_nr id=31 meas_id=4 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=60 nrsrp_nr=60 nrsrq_nr=30
  ...  UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
  Should Contain  ${ret1}  a1-Threshold rsrp : 70  #NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
  Get RRC Log

Intra-eNB HO trigger PSCell Change
  [Arguments]  ${candidate_cells_mn_hex_for_menb_ho}=${candidate_cells_mn_hex_for_menb_ho_to_PCI60}
  Start RRC Log  intra_HO
  Execute Egate Command  enb_cell_param enb=1 allow_endc=on
  Execute Egate Command  ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
  ${ret1}=  Execute Egate Command  ue_ho id=31 enb=1 cell=2  Intra-eNB handover from ENB-1.1 to ENB-1.2 performed
  Should Contain  ${ret1}  a1-Threshold rsrp : 70  #NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
  Get RRC Log

MeNB initiated SgNB Modification procedure with allowedBC-List change to do not support F-T CA
  Start RRC Log  not_support_FT
  Execute Egate Command  enb_endc_param id=1 serving_cell_index_range_scg=8:8
  ${ret1}=  Execute Egate Command  enb_ue_dc_modify ue=31 by=enb cause=RN_reduce_load
  Should Not Contain  ${ret1}  eventId eventA1
  Get RRC Log

Repat 3 times to check counters with srb3 enable
  [Arguments]  ${meas_id}=3
  FOR  ${meas_id}  IN  @{meas_id.split(",")}
    Execute Egate Command  ue_measurement_send_nr id=31 meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...  SgNBModificationConfirm
    Execute Egate Command  ue_measurement_send_nr id=31 meas_id=${${meas_id}+1} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ...  SgNBModificationConfirm
  END

MeNB initiated SgNB Modification procedure with allowedBC-List change to support F-T CA again
  Start RRC Log  support_FT
  Execute Egate Command  enb_endc_param id=1 serving_cell_index_range_scg=8:9
  ${ret1}=  Execute Egate Command
  ...  enb_ue_dc_modify ue=31 by=enb cause=RN_reduce_load
  ...  UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
  Should Contain  ${ret1}  a1-Threshold rsrp : 70  #NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
  Get RRC Log

Recover environment
  Execute Egate Command  ue_detach id=31  UE IS OFF
  Execute Egate Command  ue_change_location id=31 enb=1 cell=1  location updated to eNB-1 cell 1  #move to origin place
