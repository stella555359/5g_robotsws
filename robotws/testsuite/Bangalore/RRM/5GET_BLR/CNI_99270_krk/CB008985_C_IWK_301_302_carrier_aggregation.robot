*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008985: NR FR1 TDD super cell
...         This feature supports NR FR1 TDD super cell RRM part. The super cell is a logical cell created by several sub-cells.
...         The same Physical Cell ID (PCI) is assigned to each sub-cell of the super cell. Each sub-cell of the super cell operates
...         on the same carrier frequency without resource multiplexing. Benefits for customers are: reduced handover ratio, improved
...         call service quality (i.e. call drop rate)
...
...      == TEST SET NAME ==
...         CB008985 - NR FR1 TDD super cell
...
...      == TESTING SPLIT ==
...         CB008985-A Basic function and performance of supercell
...         CB008985-B High speed supercell support
...         CB008985-C Interworking with other key features
...
...      == CONTACTS ==
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == MAINTAINER ==
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == REFERENCES ==
...         CB008985 CFAM
...         CB007922: TDD FR1 DL CA up to 2 CCs
...
...      == HISTORY ==
...         [31.08.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)

#Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
#    ...    CLOUD_5G_I_LO_AP_LOOO
#    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
#    ...    CONFIGS_Krakow/CB008985/SA_3_supercells_LO_AP_LOOO_6xAZQP_TDD_ECPRI.yaml

Suite Setup    Prepare test suite   ute_ca=${True}

Resource    ./resources/CB008985_keywords.robot
Resource    ../resources/robot/configuration_id.robot

*** Variables ***
${LUA_CFG}=    ${CURDIR}/configs/SANSA_TDD_3c_1eNBsim_1gNBsim.lua
${SCFC}=       ${CURDIR}/configs/SCF_3_supercells_3x2_subcells_6_AZQP_CA_setup.xml
${AP_XML}=     ${CURDIR}/configs/iphy_3_supercells_3x2_subcells_6_AZQP_CA_setup.xml

&{UE11}   1=9   2=8
&{UE12}   1=8   2=9

*** Test Cases ***

CB008985_C_IWK301_SA_Intra_band_CA_FR1_TDD_SCell_addition_blind_or_covBasedA1_for_PCell_supercell_and_SCell_supercell
    [Tags]    IWK301_SA
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  When 3 gNB cells are supercells in SA mode (NRCELL-1 as PCell, NRCELL-2 as SCell, NRCELL-3 as SCell), verify that:
    ...  - SCell Addition (blind or covBasedA1) is successful for CA capable UEs
    ...  - A6 SCell Swap from supercell to another supercell is successful (CB008290)
    ...  - Subcell switch is successful on PCell and SCell independently
    ...  - A2 SCell Release is successful
    ...  - attach to SCell supercell (acting then as PCell) is successful
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - ASIL + ABIO
    ...  - AirPhone - ASIL + 3xABIO
    ...  - 3 supercells TDD FR1 are configured and OnAir
    ...  - AMF1 simulated
    ...  - UEs SA - Airphone simulator
    ...         UE1-3 is capable of FR1-TDD FR1 CA with up to 2 CCs
    ...         UE1-3 support 2CC n78C band combination
    ...             supportedBandCombinationList.bandList.nr.bandNR = 78
    ...             supportedBandwidthCombinationSet = '111'B
    ...
    ...  CA settings
    ...  - NRBTS.actCarrierAggregation=true
    ...  - NRBTS.actMeasBasedSCellAddition=true (5GC001765)
    ...  - NRBTS.caConfigurationSupport=2CCDL_2CCUL
    ...  - NRBTS.maxNumScellsDl=2
    ...  - NRBTS.maxNumScellsUl=2
    ...  - NRBTS.sCellActivationMethod=blind
    ...  - NRBTS.actBcsCheck=enabled_FR1 (1)
    ...  - NRBTS.rejectSuppBcs=none (0)
    ...  - NRBTS.NRDU.carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa
    ...  - NRBTS.NRDU.flexibleCAMode=ConfigurationIndependent
    ...  - NRBTS.actFdmScheduling=true
    ...  - NRCELL-1.actK1Opt=intra-gNB
    ...  - NRCELL-1.actK1OptForDPA=true
    ...  - NRCELL-1.chBw=100MHz
    ...  - NRCELL-1.nrarfcn=626668
    ...  - NRCELL-1.gscnOrSsPbchArfcn=7777
    ...  - NRCELL-1.freqBandIndicatorNR=78
    ...  - NRCELL-1.allowUnsuppBcOrBcs=accept unknown BCSs (2)
    ...  - NRCELL-1.sCellDeactivationTimergNB=infinity (0)
    ...  - NRCELL-1.a1MeasSCellAddEnabled=rsrp
    ...  - NRCELL-1.a1MeasSCellAddSsbRsrp is configured
    ...  - NRCELL-1.a2MeasSCellRelEnabled=rsrp
    ...  - NRCELL-1.a2MeasSCellRelSsbRsrp is configured
    ...  - NRCELL-1.a6MeasSCellSwapEnabled=rsrp
    ...  - NRCELL-1.a6MeasSCellSwapSsbRsrp is configured
    ...  - NRCELL-1.NRREL-1.sCellAdditionMethod=covBasedA1  (relation to NRCELL-2)
    ...  - NRCELL-1.NRREL-2.sCellAdditionMethod=covBasedA1  (relation to NRCELL-3)
    ...
    ...  - NRCELL-2.actK1Opt=intra-gNB
    ...  - NRCELL-2.actK1OptForDPA=true
    ...  - NRCELL-2.chBw=100MHz
    ...  - NRCELL-2.nrarfcn=636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn=7880
    ...  - NRCELL-2.freqBandIndicatorNR=78
    ...  - NRCELL-2.sCellDeactivationTimergNB=infinity (0)
    ...  - NRCELL-2.NRREL-1.sCellAdditionMethod=blind  (relation to NRCELL-1)
    ...
    ...  - NRCELL-3.actK1Opt=intra-gNB
    ...  - NRCELL-3.actK1OptForDPA=true
    ...  - NRCELL-3.chBw=100MHz
    ...  - NRCELL-3.nrarfcn=636666
    ...  - NRCELL-3.gscnOrSsPbchArfcn=7880
    ...  - NRCELL-3.freqBandIndicatorNR=78
    ...  - NRCELL-3.sCellDeactivationTimergNB=infinity (0)
    ...  - NRCELL-3.NRRELs are not configured
    ...
    ...  CB008985 Supercells settings (NRCELL-1, NRCELL-2, NRCELL-3)
    ...  - NRCELL-1.actSupercell=true
    ...  - NRCELL-1.actBeamforming=false
    ...  - NRCELL-1.pucchModeSelect=longPucch
    ...  - NRCELL-1.dlMimoMode='2x2 Closed Loop Spatial Multiplexing' (50)
    ...  - NRCELL-1.nrCellType=2DL2UL
    ...  - NRCELL-1.numOfSubSectors='0sub-sector'
    ...  - NRCELL-1.numOfSuperSubcells=2 (2xCHANNELGROUP configured)
    ...  - NRCELLGRP-1.numberOfTransmittedSsBlocks='2 beams'  (set by OAM according to CFAM)
    ...  - NRCELL-2 has the same supercell configuration as NRCELL-1
    ...  - NRCELL-3 has the same supercell configuration as NRCELL-1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 6 simulated AZQP radio modules
    ...       2xAZQP for NRCELL-1
    ...       2xAZQP for NRCELL-2
    ...       2xAZQP for NRCELL-3
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16877, 5G_RAN_USR_RRM_5768, 5G_CP_IF_RRC_9364,
    ...    5G_CP_OTH_3540: UC SCell addition for FR1 CA for SA call
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  US CB008985-C#3: TDD FR1+TDD FR1 CA multiple UE connection setup and DL/UL data scheduling in SA option 2
    ...        with 3 supercells (interworking with CB007922)
    ...     -  USCB007922-D#2 Multiple UE connection setup and DL/UL data scheduling in SA option 2
    ...        with BF and blind SCell addition on Loki based hardware
    ...        (NRCELL-1.actBeamforming=false, NRCELL-2.actBeamforming=false, NRCELL-3.actBeamforming=false)
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=866500
    ...  == HISTORY ==
    ...     [05.09.2022] - TC Create

    Attach UE1 to gNB2 NRCELL-2 subcell_1 with SCell blind activation
    Verify that blind SCell addition NRCELL-1 is successful for UE1
    Verify that CSI-SSB resources are properly allocated for UE1 by PCell which has 2 beams
    Verify that CSI-SSB resources are properly allocated for UE1 by SCell which has 2 beams

    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Trigger subcell switch for UE1 from NRCELL-2 subcell_1 to subcell_2
    Trigger subcell switch for UE1 from NRCELL-1 subcell_1 to subcell_2

    Attach UE2 to gNB2 NRCELL-1 subcell_1
    Verify that SCell NRCELL-2 is not configured for UE2
    Verify that UE2 configured A1 measurement during Initial Context Setup
    Verify that CSI-SSB resources are properly allocated for UE2 by supercell which has 2 beams

    Trigger A1 measurement for UE2 with result greater than TDD threshold   # a1ThresholdSCellAddSsbRsrpTDD
    Verify that covBasedA1 SCell addition NRCELL-2 is successful for UE2
    Verify that UE2 configured A2 measurement during SCell Addition
    Verify that UE2 configured A6 measurement during SCell Addition
    Verify that CSI-SSB resources are properly allocated for UE2 after A1 measurement by PCell and SCell with 2 beams

    Run 100Mbps DL traffic-1 on UE2 PDU1 QFI1 and wait 1 seconds
    Run 100Mbps DL traffic-2 on UE2 PDU1 QFI1 and wait 1 seconds
    Run 100Mbps DL traffic-3 on UE2 PDU1 QFI1 and wait 1 seconds
    Run 100Mbps DL traffic-4 on UE2 PDU1 QFI1 and wait 1 seconds

    Trigger subcell switch for UE2 from NRCELL-1 subcell_1 to subcell_2
    Trigger subcell switch for UE2 from NRCELL-2 subcell_1 to subcell_2

    Trigger A6 measurement for UE2 for SCell Swap
    Verify that SCell Change from NRCELL-2 to NRCELL-3 is successful for UE2
    Verify that CSI-SSB resources are properly allocated for UE2 after A6 measurement by PCell and SCell with 2 beams

    Trigger subcell switch for UE2 from NRCELL-1 subcell_2 to subcell_1
    Trigger subcell switch for UE2 from NRCELL-3 subcell_1 to subcell_2

    Trigger A2 measurement for UE2 with result lower than SCell Release threshold for SCELL-2
    Verify that UE2 released NRCELL-3 SCell

    Attach UE3 to gNB2 NRCELL-3 subcell_2
    Verify that SCell NRCELL-1 is not configured for UE3
    Verify that UE3 is in ACTIVE state in subcell_2
    Verify that CSI-SSB resources are properly allocated for UE3 by supercell which has 2 beams

    [Teardown]  Run Keywords    Teardown test environment IWK301_SA
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

CB008985_C_IWK302_NSA_Intra_band_CA_FR1_TDD_SCell_addition_blind_for_PCell_supercell_and_SCell_supercell
    [Tags]    IWK302_NSA    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  When 3 gNB cells are supercells in NSA mode (NRCELL-1 as PCell, NRCELL-2 as SCell, NRCELL-3 as SCell), verify that:
    ...  - SCell addition (blind or covBasedA1) is successful for CA capable UEs
    ...  - Subcell switch is successful on PCell and SCell independently
    ...  - SgNB Addition on SCell supercell (acting then as PCell) is successful
    ...  - A2 SCell Release is successful
    ...  - attach to SCell supercell (acting then as PCell) is successful
    ...
    ...  == Precondition: ==
    ...  - eNB1 - simulated eNB with CELL-1 onAir
    ...  - gNB2 classical - ASIL + ABIO
    ...  - AirPhone - ASIL + 3xABIO
    ...  - 3 supercells TDD FR1 are configured and OnAir
    ...  - X2 link established between eNB1 and gNB2
    ...  - UEs NSA - Airphone simulator
    ...         UE11-13 is capable of FR1-TDD FR1 CA with up to 2 CCs
    ...         UE11-12 support 2CC n78C band combination
    ...             supportedBandCombinationList.bandList.nr.bandNR = 78
    ...             supportedBandwidthCombinationSet = '111'B
    ...
    ...  CA settings
    ...  - NRBTS.actCarrierAggregation=true
    ...  - NRBTS.actMeasBasedSCellAddition=true (5GC001765)
    ...  - NRBTS.caConfigurationSupport=2CCDL_2CCUL
    ...  - NRBTS.maxNumScellsDl=2
    ...  - NRBTS.maxNumScellsUl=2
    ...  - NRBTS.sCellActivationMethod=blind
    ...  - NRBTS.actBcsCheck=enabled_FR1 (1)
    ...  - NRBTS.rejectSuppBcs=none (0)
    ...  - NRBTS.NRDU.carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Nsa
    ...  - NRBTS.NRDU.flexibleCAMode=MixedCAMode (1)
    ...  - NRBTS.actFdmScheduling=true
    ...  - NRCELL-1.actK1Opt=intra-gNB
    ...  - NRCELL-1.actK1OptForDPA=true
    ...  - NRCELL-1.chBw=100MHz
    ...  - NRCELL-1.nrarfcn=626668
    ...  - NRCELL-1.gscnOrSsPbchArfcn=7777
    ...  - NRCELL-1.freqBandIndicatorNR=78
    ...  - NRCELL-1.allowUnsuppBcOrBcs=accept unknown BCSs (2)
    ...  - NRCELL-1.sCellDeactivationTimergNB=infinity (0)
    ...  - NRCELL-1.a1MeasSCellAddEnabled=rsrp
    ...  - NRCELL-1.a1MeasSCellAddSsbRsrp is configured
    ...  - NRCELL-1.a2MeasSCellRelEnabled=rsrp
    ...  - NRCELL-1.a2MeasSCellRelSsbRsrp is configured
    ...  - NRCELL-1.NRREL-1.sCellAdditionMethod=covBasedA1  (relation to NRCELL-2)
    ...  - NRCELL-1.NRREL-2.sCellAdditionMethod=covBasedA1  (relation to NRCELL-3)
    ...
    ...  - NRCELL-2.actK1Opt=intra-gNB
    ...  - NRCELL-2.actK1OptForDPA=true
    ...  - NRCELL-2.chBw=100MHz
    ...  - NRCELL-2.nrarfcn=636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn=7880
    ...  - NRCELL-2.freqBandIndicatorNR=78
    ...  - NRCELL-2.sCellDeactivationTimergNB=infinity (0)
    ...  - NRCELL-2.NRREL-1.sCellAdditionMethod=blind  (relation to NRCELL-1)
    ...
    ...  - NRCELL-3.actK1Opt=intra-gNB
    ...  - NRCELL-3.actK1OptForDPA=true
    ...  - NRCELL-3.chBw=100MHz
    ...  - NRCELL-3.nrarfcn=636666
    ...  - NRCELL-3.gscnOrSsPbchArfcn=7880
    ...  - NRCELL-3.freqBandIndicatorNR=78
    ...  - NRCELL-3.sCellDeactivationTimergNB=infinity (0)
    ...  - NRCELL-3.NRRELs are not configured
    ...
    ...  CB008985 Supercells settings (NRCELL-1, NRCELL-2, NRCELL-3)
    ...  - NRCELL-1.actSupercell=true
    ...  - NRCELL-1.actBeamforming=false
    ...  - NRCELL-1.pucchModeSelect=longPucch
    ...  - NRCELL-1.dlMimoMode='2x2 Closed Loop Spatial Multiplexing' (50)
    ...  - NRCELL-1.nrCellType=2DL2UL
    ...  - NRCELL-1.numOfSubSectors='0sub-sector'
    ...  - NRCELL-1.numOfSuperSubcells=2 (2xCHANNELGROUP configured)
    ...  - NRCELLGRP-1.numberOfTransmittedSsBlocks='2 beams'  (set by OAM according to CFAM)
    ...  - NRCELL-2 has the same supercell configuration as NRCELL-1
    ...  - NRCELL-3 has the same supercell configuration as NRCELL-1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 6 simulated AZQP radio modules
    ...       2xAZQP for NRCELL-1
    ...       2xAZQP for NRCELL-2
    ...       2xAZQP for NRCELL-3
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16877, 5G_RAN_USR_RRM_5768, 5G_CP_IF_RRC_9364,
    ...    5G_CP_OTH_3540: UC SCell addition for FR1 CA for SA call
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  US CB008985-C#3: TDD FR1+TDD FR1 CA multiple UE connection setup and DL/UL data scheduling in SA option 2
    ...        with 3 supercells (interworking with CB007922)
    ...     -  USCB007922-D#2 Multiple UE connection setup and DL/UL data scheduling in SA option 2
    ...        with BF and blind SCell addition on Loki based hardware
    ...        (NRCELL-1.actBeamforming=false, NRCELL-2.actBeamforming=false, NRCELL-3.actBeamforming=false)
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=866500
    ...  == HISTORY ==
    ...     [05.09.2022] - TC Create

    Attach UE11 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE11 with NRCELL_2 subcell_1 on gNB2
    Verify that blind NSA SCell addition NRCELL-1 is successful for UE11
    Verify that CSI-SSB resources are properly allocated for UE11 in NSA mode by PCell and SCell

    Run 5Mbps DL traffic on split bearer for UE11 and wait 5 seconds

    Trigger subcell switch for UE11 from NRCELL-2 subcell_1 to subcell_2
    Trigger subcell switch for UE11 from NRCELL-1 subcell_1 to subcell_2

    Attach UE12 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE12 with NRCELL_1 subcell_1 on gNB2
    Verify that SCell NRCELL-2 is not configured in NSA mode for UE12
    Verify that UE12 configured A1 measurement during SgnbAddition
    Verify that CSI-SSB resources are properly allocated for UE12 in NSA mode by PCell only

    Run 5Mbps DL traffic on split bearer for UE12 and wait 5 seconds

    Trigger A1 measurement in NSA mode for UE12 with result greater than TDD threshold  # a1ThresholdSCellAddSsbRsrpTDD
    Verify that covBasedA1 SCell addition NRCELL-2 is successful for UE12
    Verify that UE12 configured A2 measurement during NSA SCell Addition
    Verify that CSI-SSB resources are properly allocated for UE12 after A1 measurement by PCell and SCell with 2 beams

    Run 100Mbps DL traffic on split bearer for UE12 and wait 5 seconds

    Trigger subcell switch for UE12 from NRCELL-1 subcell_1 to subcell_2
    Trigger subcell switch for UE12 from NRCELL-2 subcell_1 to subcell_2

    Trigger A2 measurement for UE12 in NSA mode with result lower than SCell Release threshold for NRCELL-2
    Verify that UE12 released NRCELL-2 SCell

    Attach UE13 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE13 with NRCELL_3 subcell_2 on gNB2
    Verify that SCell NRCELL-1 is not configured in NSA mode for UE13
    Verify that UE13 is in ACTIVE state in subcell_2
    Verify that CSI-SSB resources are properly allocated for UE13 in NSA mode by PCell only

    Run 5Mbps DL traffic on split bearer for UE13 and wait 5 seconds

    Trigger subcell switch for UE13 from NRCELL-3 subcell_2 to subcell_1

    [Teardown]  Run Keywords    Teardown test environment IWK302_NSA
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Attach UE${ue_id:\d+} to gNB2 NRCELL-${supercell_id:\d+} subcell_${subcell_id:\d+} with SCell blind activation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification

    Execute egate command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${subcell_id} beamaction=attach scell=0
    Attach UE${ue_id} to gNB2 cell${supercell_id} with ICS during PDU session setup

    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification

Teardown test environment IWK301_SA
    Detach and kill UEs from 1 to 3
    Execute egate command
    ...    cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=on



Teardown test environment IWK302_NSA
    Execute egate command   cmd=trf_data_stop ue=11 id=2
    Execute egate command   cmd=trf_data_stop ue=12 id=2
    Execute egate command   cmd=trf_data_stop ue=13 id=2
    Detach and kill UEs from 11 to 13

