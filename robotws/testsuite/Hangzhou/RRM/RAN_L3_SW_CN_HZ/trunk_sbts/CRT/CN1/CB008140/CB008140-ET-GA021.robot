*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    	CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-L3CN1_SG14    release-SBTS23R4    owner-chunjian.yang
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:actCDrx=false
...    NRCELL:configuredEpsTac=200
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

@{PARAMS_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=519000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:ssbFrequency=518670
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=531960
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:ssbFrequency=531870
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:actUlSrsBm=false
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:actUeCsirsCoexistCellCsirs=true
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL-1:srsForBeamMgmt:cSRS=12
...    NRCELL-1:srsForBeamMgmt:bSRS=3
...    NRCELL-1:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRCELL-1:beamSet:upperEdgeAngle=60

@{PARAMS_FOR_GNB2}
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:weightForSCellSelection=10
...    NRCELL-3:weightForSCellSelection=30
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=2
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=506010
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-1:ssbFrequency=505950
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{PARAMS_FOR_OTHERS}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60


...    NRBTS:actRanSharing=false
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

${SA_Capa_Support_3CC_TTT_CA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA170000381DC6C28AAD608C21A00107483401B5B262AC68B5E25AF42D7B16BC628B5E45AF52D7996BDE160B038782F555
...    55553D55555542E00007004960E140000000B02B170A0003850001C28000002160562E0100061300C26000082C0AC7C02000C0D8184C03098
...    00030B02B170080030040606C0008160563E0100060180C0D8184D0002858158B80400181B0309800060B02B0F00800309800070B02B0F008
...    00300400080B02B0F06C00303600090B02B0F00800300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160561E0D800713000
...    006858158B89800184C03004000E0B02B1F130003098060080C0D8003C2C0AC5C4C000C010181B0008058158F89A0018020300C0606C00221
...    60402C01B800D0132001404D80502E801CE12811362130E24E9D3B62130E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7
...    C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E2448913639F0E3448
...    91226C73E1C4891226C73E1C68912244D8E7C303624318C6318C6318C6318C63183D05C0078005038280381804A00E000C0480080C07C1200
...    40000000200000001000006008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002
...    000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA068200001
...    2CA48080000CB29282000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000
...    152CA48080005CB29282000192CA480800018B292019A55174AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142C02F01
...    2A05028140A05028140A05028140A05028140A0502800880040100210080100202004008080100220100C0140400801010020046020180280
...    80600A02004008080100220101001404040050101602C602018030080600A02018030080100220100C0140403005010020042020180280801
...    00210100C014040300508080600C02018030404030060100C014202018028080600A20100C01404030060100C014202018030080100220100
...    200404008010100C014602004008080100202018028080600A20100200404030060100C018602004008080600A02018030080600A3543E000
...    20406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0




*** Test Cases ***
CB008140-ET-GA021_Pcell_PSRS_reconfig_to_ASRS_as_antennaSwitching_SRS_is_not_supported_in_BC_and_Csirs_downgrade_after_scell_addition
    [Documentation]
    ...    5G UE capability:
    ...    simultaneousCSI-ReportsPerCC=4 for each band, simultaneousCSI-ReportsAllCC=8, Maximum number of CSI-RS supported
    ...    among all CCs are limited with 5:
    ...    RF-Parameters::BandCombination-v1540::CA-ParametersNR-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb{
    ...    maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC = 5;
    ...    totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllC = 40;
    ...    Note: UE capabilities not mentioned above are not the bottleneck to do SCell addition and do CSI-RS allocation.
    ...    antennaSwitching SRS is supported in nonCA case.
    ...    antennaSwitching SRS is not supported for the band combination of TTT

    ...    This case is to verify inter-gNB CA is well supported when CB008247 is enabled in
    ...    PCell(NRBTS/NRCELL/actDlSrsBm=true), Pcell PSRS will be reconfigured to ASRS due to antennaSwitching SRS is
    ...    not supported in BC(refer to above UE capability) and Csirs downgrade after scell_addition
    ...    Ini file checks maxUlHarqTransmission and maxDlHarqTransmission
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n41)(pci:50)
    ...    GNB-2 ext: cell2-TDD(n41)(pci:51) cell3-TDD(n41)(pci:52)
    ...    scell gnb2-cell2 and gnb2-cell3

    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On NRCELL-1
    ...         b. Trigger A1 to add scell3 and scell4
    ...         c. Trigger A2 to release scell1
    ...         d. Trigger A2 to release scell2

    ...    3.[Expected Results]:
    ...        a.UE attch success,UE specific csirs(P4) configure to UE.P-SRS and TAS configured to UE
    ...        b.Scell added success, Pcell changed to 2 cell specific csirs(P8 P8),Scell1 2 csirs(P8,P8),
    ...          Scell2 1 csirs(P8)
    ...        c.after release scell1, Pcell changed to 4 csirs(P8,P8,P8,P8), Scell2 still 1 csirs(P8)
    ...        d.after scell2 released, Pcell changd back to UE specific csirs(P4)
    [Tags]    QC_252624    GA021    CA_LABEL-TTT (60MHZ_TDD_n41+60MHZ_TDD_n41+60MHZ_TDD_n41)
    Clear Counter Files for 2GNB
    Make Normal CA SA UE
    trigger A2 MR to release scell    carrierfreq=518670    scell_index=1
    trigger A2 MR to release scell    carrierfreq=531870    scell_index=2
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_GA_021${/}a2a.ini    wait_string=UEContextRelease::10

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/3cells_gnb1_1T_gnb2_2T

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_TTT_CA}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Make Normal CA SA UE
    Sa Ue Attach    1    1    2    1    ${SA_Capa_Support_3CC_TTT_CA}
    Setup pdu session with no scelladd
    trigger A1 MR to add scell    95
    Send And Verify Throuput    1    10

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${UE_Capa}=${SA_Capa_Support_3CC_TTT_CA}
    ...    ${pass_regexp}=NG RM Register
    Update UE capa    ${ue_id}    ${UE_Capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=QoS Routing Table
    Should Not Contain    ${ret1}    sCellIndex 1

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=95
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=505950    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId51
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId52

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=1    Tput_dl=885    Tput_ul=8
	
Update UE capa
    [Arguments]    ${ue_id}=1    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}
	
trigger A2 MR to release scell
    [Arguments]    ${carrierfreq}=663360    ${scell_index}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A2
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret2}    sCellToReleaseList
