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
...
...      == HISTORY ==
...         [26.09.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008985/SCF_2_supercells_2x3_subcells_3_AZQP_3_AZQU_CA_setup.xml

Suite Setup    Run Setup    reset_tl=${False}

Resource    ./resources/CB008985_keywords.robot

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/SANSA_TDD_2c_n77_n78_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008985-A-B900_Robustness_DRX_config_for_supercell
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify interaction between supercell feature and DRX
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO + ABIO + ABIO
    ...  - AMF1 simulated
    ...  - UE1 - Airphone simulator
    ...  - UE1 is capable of FR1-TDD FR1 CA with up to 2CCs
    ...  - UE1 support 2CC n78C band combination
    ...  - gNB2 up
    ...  - NRCELL-1 and NRCELL-2 supercell configuration:
    ...  - NRCELL.actSupercell=true
    ...  - NRCELL.actCsirsMultiplexing=true
    ...  - NRCELL.actBeamforming=false
    ...  - NRCELL.pucchModeSelect=longPucch
    ...  - NRCELL.numOfSuperSubcells=3 (3xCHANNELGROUP configured)
    ...  - NRCELL-1.dlMimoMode='2x2 Closed Loop Spatial Multiplexing'
    ...  - NRCELL-2.dlMimoMode='4x4 or 4x2 Closed Loop Spatial Multiplexing'
    ...  - NRCELL-1.nrCellType=2DL2UL
    ...  - NRCELL-2.nrCellType=4DL4UL
    ...  CA settings
    ...  - NRBTS.actCarrierAggregation=true
    ...  - NRBTS.actMeasBasedSCellAddition=true
    ...  - NRDU.actInterGnbCa=disabled
    ...  - NRBTS.caConfigurationSupport=2CCDL_2CCUL
    ...  - NRBTS.maxNumScellsDl=2
    ...  - NRBTS.maxNumScellsUl=2
    ...  - NRBTS.sCellActivationMethod=blind
    ...  - NRBTS.actBcsCheck=enabled_FR1
    ...  - NRBTS.rejectSuppBcs=none
    ...  - NRBTS.NRDU.carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Nsa
    ...  - NRBTS.NRDU.flexibleCAMode=MixedCAMode
    ...  - NRBTS.actFdmScheduling=true
    ...  - NRCELL.allowUnsuppBcOrBcs=accept unknown BCSs
    ...  - NRCELL-1.NRREL.sCellAdditionMethod=covBasedA1  (relation to NRCELL-2)
    ...  DRX settings
    ...  - NRCELL.actCDrx is set to true
    ...  - drxProfile1 is configured in NRCELL:
    ...  - NRCELL.drxProfile1.drxOnDurationTimer eq 10ms
    ...  - NRCELL.drxProfile1.drxInactivityTimer eq 20ms
    ...  - NRCELL.drxProfile1.drxLongCycle eq 40ms
    ...  - UE1 supports longDRX mac-Parameters.MAC-ParametersXDD-Diff.longDRX-Cycle set to supported
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 3 simulated AZQU and 3 simulated AZQP radio modules
    ...       3xAZQP for NRCELL-1
    ...       3xAZQU for NRCELL-2
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16872
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Marek Kieltyka (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-A Predicted Robustness
    ...
    ...  == HISTORY ==
    ...     [26.09.2022] - TC Create

    [Tags]  B900

    Attach UE1 to gNB2 NRCELL-1 subcell_1 with DRX cycle activation
    Verify that CSI-SSB resources are properly allocated for DRX capable UE1 by PCell which has 3 beams
    Verify that UE1 configured DRX after ICS
    Verify that supercell CSI-SSB resources are not released by DRX configuration in 3 UEContextModificationResponse

    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
    Trigger subcell switch for UE1 from NRCELL-1 subcell_1 to subcell_3
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Trigger A1 measurement for UE1 with result greater than TDD threshold
    Verify that covBasedA1 SCell addition NRCELL-2 is successful for UE1
    Verify that CSI-SSB resources are properly allocated for UE1 after A1 measurement by PCell and SCell with 3 beams
    Verify that UE1 configured DRX after SCell addition
    Verify that supercell CSI-SSB resources are not released by DRX configuration in 4 UEContextModificationResponse

    Trigger subcell switch for UE1 from NRCELL-1 subcell_3 to subcell_2
    Trigger subcell switch for UE1 from NRCELL-2 subcell_1 to subcell_2

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]  Detach and kill UE1


*** Keywords ***
Attach UE${ue_id:\d+} to gNB2 NRCELL-${supercell_id:\d+} subcell_${subcell_id:\d+} with DRX cycle activation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification

    Execute egate command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${subcell_id} beamaction=attach scell=0
    Attach UE${ue_id} to gNB2 cell${supercell_id} with ICS during PDU session setup

    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification

Verify that UE${ue_id:\d+} configured DRX after ICS
    ${flow}=    Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     mac-CellGroupConfig contains (drx-Config contains (setup contains (drx-InactivityTimer is present)))
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow}

    ${flow}=    Get flow name
    ...     procedure=4*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     mac-CellGroupConfig contains (drx-Config contains (setup contains (drx-InactivityTimer is present)))
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}

Verify that UE${ue_id:\d+} configured DRX after SCell addition
    ${flow}=    Get flow name
    ...     procedure=3*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     mac-CellGroupConfig contains (drx-Config contains (setup contains (drx-InactivityTimer is present)))
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}

Verify that CSI-SSB resources are properly allocated for DRX capable UE${ue_id:\d+} by PCell which has ${numberOfTransmittedSsBlocks:\d+} beams
    ${flow}=    Get flow name
    ...     procedure=4*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${nzp_CSI_RS_ResourceSetToAddModList_length}     Evaluate  ${numberOfTransmittedSsBlocks} + 1
    Verify That Message Fulfills Query
    ...     length(nzp-CSI-RS-ResourceSetToAddModList) eq ${nzp_CSI_RS_ResourceSetToAddModList_length}
    ...     message_alias=UEContextModificationResponse_2  # _4 means that 4th UEContextModificationResponse contains IEs to verify
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-SSB-ResourceSetToAddModList is present)
    ...     message_alias=UEContextModificationResponse_2
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     length(csi-SSB-ResourceList) eq ${numberOfTransmittedSsBlocks}
    ...     message_alias=UEContextModificationResponse_2
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10)
    ...     message_alias=UEContextModificationResponse_2
    ...     flow_alias=${flow}

    verify_that_ue_has_csi_ssb_resources_configured_by_supercell  flow_alias=${flow}  message_alias=UEContextModificationResponse_2

Verify that supercell CSI-SSB resources are not released by DRX configuration in ${msg_count:[1-4]} UEContextModificationResponse
    ${flow}=    Get flow name
    ...     procedure=4*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     nzp-CSI-RS-ResourceSetToReleaseList is not present
    ...     message_alias=UEContextModificationResponse_${msg_count}
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     csi-ResourceConfigToReleaseList is not present
    ...     message_alias=UEContextModificationResponse_${msg_count}
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     csi-ReportConfigToReleaseList is not present
    ...     message_alias=UEContextModificationResponse_${msg_count}
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     csi-SSB-ResourceSetToReleaseList is not present
    ...     message_alias=UEContextModificationResponse_${msg_count}
    ...     flow_alias=${flow}
