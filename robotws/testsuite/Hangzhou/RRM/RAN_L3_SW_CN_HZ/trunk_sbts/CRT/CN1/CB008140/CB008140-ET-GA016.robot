*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-jazz    owner-delun.li    release-SBTS23R3
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_A1_for_NRCELL_1}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_A2_for_NRCELL_3_4}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL:beamSet:basicBeamSet=beamSet_1
...    NRCELL:cellCsiImLocationList:resourceId=0
...    NRCELL:cellCsiImLocationList:setId=set_1
...    NRCELL:cellCsiImLocationList:subcarrierLocation=3840
...    NRCELL:cellCsiRsLocationList:firstOFDMSymbol=13
...    NRCELL:cellCsiRsLocationList:frequencyDomainAllocation=3
...    NRCELL:cellCsiRsLocationList:offset=15
...    NRCELL:cellCsiRsLocationList:resourceId=0
...    NRCELL:cellCsiRsLocationList:setId=set_1
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL:actCellCsiRsImTddNonBf=true
...    NRCELL:cellCsiRsImLocationMode=manual

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:ssbFrequency=655008
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:ssbFrequency=648096
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:beamSet:basicBeamSet=beamSet_1
...    NRCELL-3:cellCsiImLocationList:resourceId=0
...    NRCELL-3:cellCsiImLocationList:setId=set_1
...    NRCELL-3:cellCsiImLocationList:subcarrierLocation=3840
...    NRCELL-3:cellCsiRsLocationList:firstOFDMSymbol=13
...    NRCELL-3:cellCsiRsLocationList:frequencyDomainAllocation=3
...    NRCELL-3:cellCsiRsLocationList:offset=15
...    NRCELL-3:cellCsiRsLocationList:resourceId=0
...    NRCELL-3:cellCsiRsLocationList:setId=set_1
...    NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL-3:actCellCsiRsImTddNonBf=true
...    NRCELL-3:cellCsiRsImLocationMode=manual
...    NRCELL-4:beamSet:basicBeamSet=beamSet_1
...    NRCELL-4:cellCsiImLocationList:resourceId=0
...    NRCELL-4:cellCsiImLocationList:setId=set_1
...    NRCELL-4:cellCsiImLocationList:subcarrierLocation=3840
...    NRCELL-4:cellCsiRsLocationList:firstOFDMSymbol=13
...    NRCELL-4:cellCsiRsLocationList:frequencyDomainAllocation=3
...    NRCELL-4:cellCsiRsLocationList:offset=15
...    NRCELL-4:cellCsiRsLocationList:resourceId=0
...    NRCELL-4:cellCsiRsLocationList:setId=set_1
...    NRCELL-4:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL-4:actCellCsiRsImTddNonBf=true
...    NRCELL-4:cellCsiRsImLocationMode=manual

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:pucchF3MaxCodeRate=zeroDot15
...    NRCELL:pucchF3ModulationScheme=pi2bpsk

@{GNB2_A2_for_NRCELL_3_4}
...    NRCELL-3:a2MeasSCellRelEnabled=rsrq
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelEnabled=rsrq
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{GNB1_A1_for_NRCELL_1}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms

${SA_Capa_Support_3CC_TTT_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782
...    F55555553D5555554260001C012587898001C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F80400181
...    B03098061300006160562E0100060080C0D800102C0AC7C02000C030181B0309A00050B02B1700800303606130000C160561E01000613000
...    0E160561E0100060080010160561E0D800606C0012160561E0100060180014160561E03000606C0016160562E0100060180C0D800302C0AC
...    3C1B000E2600000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8980018020303600100B02B1F1340030040
...    60180C0D800442C08048037001A0264002809A1E81D212851226C73E1C4891226C4261C4891226C73E1C68912244D8E7C38912244D8E7C38
...    D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891
...    226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D04C00F000A070500703009401C00180
...    90010180F82400800000004002000000080000300400000802000008010000060080000400400002802001004010040000300200001C0100
...    08000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D602
...    5604560ED0341000009652504000065949810000196524040000E594901000049652404000165949810000696524040001E5949010000896
...    52404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA03154
...    0A2A93555078A1202F012A05028140A05028140A05028140A05028140A050280088404008010100200440200400808010020200400880403
...    00501002004040080118080600A020180280801002020040088040400501010014040580B18080600C02018028080600C020040088040300
...    50100C014040080108080600A02004008404030050100C014202018030080600C10100C018040300508080600A02018028804030050100C0
...    18040300508080600C020040088040080101002004040300518080100202004008080600A02018028804008010100C018040300618080100
...    202018028080600C02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168


*** Test Cases ***
CB008140-ET-GA016_scell_addition_success_with_7601_enable_dlMImode22_with_coverbasedscelladd
    [Documentation]
    ...    5G UE capability:
    ...    simultaneousCSI-ReportsPerCC=4 for each band, simultaneousCSI-ReportsAllCC=8, Maximum number of CSI-RS supported
    ...    among all CCs are limited with 5:
    ...    RF-Parameters::BandCombination-v1540::CA-ParametersNR-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb{
    ...    maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC = 5;
    ...    totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllC = 40;

    ...    This case is to Verify SCell addition and SCell release success.
	...    It interworks with 7601 feature, dlMImode22 means 2*2 port2
	...    Ini file checks maxUlHarqTransmission and maxDlHarqTransmission
	...    CSI-ReportConfig.reportConfigId for scell 3 and 4
	...    CSI-IM-ResourceId for scell 3 and 4
	...    NZP-CSI-RS-Resource.resourceMapping.nrofPorts=1 for scell 3 and 4, here 1 means p2, if 2 means p4, 3 means p8.
	...    PUCCH-Resource.pucch-ResourceId for scell 3 and 4
    ...    [Configuration]:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz ssb=663360
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssb=657984
    ...    Cell id=3 gnb=2 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz ssb=655008
    ...    Cell id=4 gnb=2 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz ssb=663360
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz ssb=657984

    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On NRCELL-1
    ...         b. Trigger A1 to add scell3 and scell4
    ...         c. UE1 Start Traffic And Verify Throughput
    ...         d. Trigger A2 to release scell
    [Tags]    GA016    QC_252604
    Make Normal CA SA UE with A1add and A2release
    UE Deregister From gNB
    Check WireShark Log    ${CURDIR}${/}A2A_GA_016${/}a2a.ini    wait_string=UEContextRelease::10

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_TTT_CA}

Make Normal CA SA UE with A1add and A2release
    Sa Ue Attach    ue_id=1    gateway=1    enb_id=2    cell_id=1
    Setup pdu session with no scelladd
    trigger A1 MR to add scell    rsrp=95
    Send And Verify Throuput
    trigger A2 MR to release scell
    Send And Verify Throuput for no scell UE

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=sCellIndex 1
    Should Contain    ${ret1}    physCellId 52
    Should Contain    ${ret1}    physCellId 53

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    ${ret2}=    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Should Contain    ${ret2}    nrofPorts p2

trigger A2 MR to release scell
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=655008    event_type=A2
    ${ret3}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=1 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret3}    sCellToReleaseList



Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=sCellIndex 1

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=90 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell    sleep_time=30s

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for traffic stable
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>220
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>370
    Should Be True    ${ul_throughput}/1000>81

Send And Verify Throuput for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s    ${expect_dl_TP}=60
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell for no scell UE    sleep_time=30s    expect_dl_TP=${expect_dl_TP}

Verify Throuput on Pscell for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s    ${expect_dl_TP}=60
    sleep    ${sleep_time}    sleep for traffic stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${expect_dl_TP}
    Should Be True    ${ul_throughput}/1000>8

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
