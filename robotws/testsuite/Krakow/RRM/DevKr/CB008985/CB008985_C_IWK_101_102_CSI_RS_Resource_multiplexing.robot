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
...         CB008247: SRS based DL beamforming
...
...      == HISTORY ==
...         [31.08.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)
...         [21.04.2023] - moving actCsirsMultiplexing set to true to the SCFC file

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
    ...    CONFIGS_Krakow/CB008985/SA_1_supercell_ABIO_4xAZQU_TDD_ECPRI.yaml

Suite Setup    Prepare test suite   ute_ca=${True}

Resource    ./resources/CB008985_keywords.robot

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_1c_1eNBsim_1gNBsim.lua
${SCFC}=       ${CURDIR}/../../../../../custom-config/Krakow/CB008985/SCF_1_supercell_4_subcells_4_AZQU.xml
${AP_XML}=     ${CURDIR}/../../../../../custom-config/Krakow/CB008985/iphy_1_supercell_4_subcells_4_AZQU.xml

&{UE11}   1=8
&{UE12}   1=8

*** Test Cases ***
CB008985_C_IWK101_CSI_RS_Resource_multiplexing_during_attach_in_SA_mode
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify that in TDD FR1 supercell, when UE specific CSI-RS multiplexing is activated (actCsirsMultiplexing = true)
    ...  it is allowed that 2 UE specific CSI-RS resources are allocated in the same symbol.
    ...  Test verifies gNB in SA configuration.
    ...  == Precondition: ==
    ...  - gNB2 classical - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs SA - Airphone simulator
    ...  - NRCELL.actSupercell=true
    ...  - NRCELL.actCsirsMultiplexing=true
    ...  - NRCELL.actBeamforming=false
    ...  - NRCELL.pucchModeSelect=longPucch
    ...  - NRCELL.dlMimoMode='4x4 or 4x2 Closed Loop Spatial Multiplexing' (40)
    ...  - NRCELL.nrCellType=4DL4UL
    ...  - NRCELL.numOfSubSectors='0sub-sector'
    ...  - NRCELL.numOfSuperSubcells=4 (4xCHANNELGROUP configured)
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks='4 beams'  (set by OAM according to CFAM)
    ...  - NRBTS.actCarrierAggregation=false
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 4 simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16788
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-C US#1: UE specific CSI-RS frequency multiplexing in TDD FR1 super cell
    ...     Other:
    ...     -  5G_CP_ARC_ALG_681, 5G_CP_ARC_ALG_5007, CB008247-13231
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=866500
    ...
    ...  == HISTORY ==
    ...     [31.08.2022] - TC Create

    [Tags]  IWK101_SA    SKIPRUN

    Attach UE1 to gNB2 NRCELL-1 subcell_1
    Attach UE2 to gNB2 NRCELL-1 subcell_2

    Verify that channel acquisition parameters are equal in RRCSetup for both UE1 and UE2

    Trigger subcell switch for UE1 from NRCELL-1 subcell_1 to subcell_2
    Trigger subcell switch for UE2 from NRCELL-1 subcell_2 to subcell_3

    [Teardown]  Teardown test IWK101_SA


CB008985_C_IWK102_CSI_RS_Resource_multiplexing_in_NSA_mode_with_SgNB_change
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify that in TDD FR1 supercell, when UE specific CSI-RS multiplexing is activated (actCsirsMultiplexing = true)
    ...  it is allowed that 2 UE specific CSI-RS resources are allocated in the same symbol.
    ...  Test verifies gNB in NSA configuration with incoming SgNB Addition and SgNB Change procedures.
    ...  == Precondition: ==
    ...  - gNB2 classical - ASIL + ABIO
    ...  - eNB1 simulated
    ...  - gNB3 simulated
    ...  - MME simulated
    ...  - AMF1 simulated
    ...  - UEs NSA - Airphone simulator
    ...  - NRCELL.actSupercell=true
    ...  - NRCELL.actCsirsMultiplexing=true
    ...  - NRCELL.actBeamforming=false
    ...  - NRCELL.pucchModeSelect=longPucch
    ...  - NRCELL.dlMimoMode='4x4 or 4x2 Closed Loop Spatial Multiplexing' (40)
    ...  - NRCELL.nrCellType=4DL4UL
    ...  - NRCELL.numOfSubSectors='0sub-sector'
    ...  - NRCELL.numOfSuperSubcells=4 (4xCHANNELGROUP configured)
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks='4 beams'  (set by OAM according to CFAM)
    ...  - NRBTS.actCarrierAggregation=false
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 4 simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16788
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US (alternate scenario in NSA mode):
    ...     -  CB008985-C US#1: UE specific CSI-RS frequency multiplexing in TDD FR1 super cell
    ...     Other:
    ...     -  5G_CP_ARC_ALG_681, 5G_CP_ARC_ALG_5007, CB008247-13231
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=866500
    ...
    ...  == HISTORY ==
    ...     [31.08.2022] - TC Create

    [Tags]  IWK102_NSA

    EXPECT FLOW[timeout=10]: gNB2 X2AP 2*sgNBAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB2 X2AP 2*snStatusTransfer

    Attach UE11 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure without message flows for UE11 with NRCELL_1 on gNB2

    Attach UE12 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure without message flows for UE12 with NRCELL_1 on gNB3
    Trigger SgNB Change procedure for UE12 from gNB3 to gNB2

    PASS FLOW[timeout=10]: gNB2 X2AP 2*sgNBAdditionPreparation
    PASS FLOW[timeout=10]: gNB2 X2AP 2*snStatusTransfer

    Verify that channel acquisition parameters are equal in SgNBAdditionRequestAcknowledge for both UE11 and UE12

    Trigger subcell switch for UE11 from NRCELL-1 subcell_1 to subcell_4
    Trigger subcell switch for UE12 from NRCELL-1 subcell_1 to subcell_2

    [Teardown]  Teardown test IWK102_NSA


*** Keywords ***
Teardown test IWK101_SA
    Detach and kill UEs from 1 to 2

Teardown test IWK102_NSA
    Detach and kill UEs from 11 to 12

Verify that channel acquisition parameters are equal in RRCSetup for both UE${ue1:\d+} and UE${ue2:\d+}
    ${flow_ue_1}=     Get Flow Name
    ...     RRCSetup
    ...     device=UE_${ue1}
    ...     protocol=NR-RRC

    ${flow_ue_2}=     Get Flow Name
    ...     RRCSetup
    ...     device=UE_${ue2}
    ...     protocol=NR-RRC

    verify_pair_of_ues_is_allocated_in_the_same_first_ofdm_symbol_in_time_domain
    ...    flow_ue1=${flow_ue_1}
    ...    flow_ue2=${flow_ue_2}

Verify that channel acquisition parameters are equal in SgNBAdditionRequestAcknowledge for both UE${ue1:\d+} and UE${ue2:\d+}
    ${nsa_flows}=     Get Flow Name
    ...     procedure=2*sgNBAdditionPreparation
    ...     device=gNB2
    ...     protocol=X2AP

    verify_pair_of_ues_is_allocated_in_the_same_first_ofdm_symbol_in_time_domain_in_nsa_mode
    ...    nsa_flows=${nsa_flows}
