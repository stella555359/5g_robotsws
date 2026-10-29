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
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == REFERENCES ==
...         CB008985 CFAM
...
...      == HISTORY ==
...         [14.07.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008985/SA_1_supercell_ABIO_3xAZQP_TDD_ECPRI.yaml

Suite Setup    Run Setup    reset_tl=${False}

Resource    ./resources/CB008985_keywords.robot

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/SANSA_TDD_1c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008985-A-B101_feature_activation
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to validate TDD FR1 NSA supercell feature activation with different number of subcells.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE1 - Airphone simulator
    ...  - gNB2 up
    ...  - NRCELL.actSupercell=false
    ...  - NRCELL.actBeamforming=false
    ...  - NRCELL.pucchModeSelect is set to longPucch
    ...  - NRCELL.dlMimoMode is set to 4DL4UL
    ...  - NRCELL.numOfSubSectors='0sub-sector'
    ...  - NRCELL.numOfSuperSubcells=3 (3xCHANNELGROUP configured)
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks='3 beams'  (set by OAM according to CFAM)
    ...  - NRBTS.actCarrierAggregation is set to false
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 3 simulated AZQP radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16771
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-A US#1: Feature activation and configuration
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=863952
    ...
    ...  == HISTORY ==
    ...     [14.07.2022] - TC Create
    ...     [31.08.2022] - TC passed build: SBTS00_ENB_9999_220830_000006

    [Tags]    MANUAL    B101

    Log to console   MANUAL
#    Set actSupercell parameter in NRCELL-1 object to TRUE
#    Set actBeamforming parameter in NRCELL-1 object to FALSE
#    Create 3 CHANNELGROUPs and link them to NRCELL-1
#
#    Validate prepared configuration and verify lack of errors
#    Apply network plan after validation
#
#    Verify that numOfSuperSubCells parameter in NRCELL-1 object is set to 3
#    Verify lack of alarms in gNB


CB008985-A-B202_CSI_RS_tracking
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify configuration of CSI resources for beam tracking.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE1 - Airphone simulator
    ...  - gNB2 up
    ...  - NRCELL.actSupercell is set to TRUE
    ...  - NRCELL.actBeamforming is set to FALSE
    ...  - NRCELL.pucchModeSelect is set to longPucch
    ...  - NRCELL.dlMimoMode is set to 4DL4UL
    ...  - NRCELL.numOfSubSectors is set to '0sub-sector'
    ...  - NRCELL.numOfSuperSubcells is set to 4 (4xCHANNELGROUP configured)
    ...  - NRCELL.frameStructureType is set to semiStatic
    ...  - NRCELL.ulDlDataSlotRatio is set to 1/4
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks='4 beams'  (set by OAM according to CFAM)
    ...  - NRBTS.actCarrierAggregation is set to false
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 4 simulated AZQP radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16785, 5G_CP_ARC_ALG_7855
    ...                           CB008985-SR-A-b3_CSI-RS for Tracking with multiple SS/PBCH blocks
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     - CB008985-A US#2: TDD FR1 NSA call on supercell
	...     Related CFAM requirement:
	...     - CB008985-7878 - Handling of csiRsTrackingResourceSet in frequency range FR1
	...     - 2.2.1. CSI RS for tracking tables when MRBTS/NRBTS/NRCELL/numOfSubSectors = 0
	...     - SS/PBCH blocks count is 4 (NRCELL.numOfSuperSubcells=4)
    ...
    ...  == HISTORY ==
    ...     [10.08.2022] - TC Create
    ...     [31.08.2022] - TC passed build: SBTS00_ENB_9999_220830_000006

    [Tags]  MANUAL  B202

    Log to console    MANUAL
#    Start collecting Emil trace
#    Try to reach onAir
#
#    Stop collecting Emil trace
#
#    Verify that Itf_L2_Ps_Cell_CellGroupSetupReq message contains CSI-RS Tracking parameters

    # csiTrackingResourceSet has 4 list items:
    # list item with ssbIndex eq 0 contains csirsTrackingResource with 4 items:
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_4
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_8
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_4
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_8
    # list item with ssbIndex eq 1 contains csirsTrackingResource with 4 items:
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_4
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_8
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_4
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_8
    # list item with ssbIndex eq 2 contains csirsTrackingResource with 4 items:
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_5
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_9
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_5
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_9
    # list item with ssbIndex eq 3 contains csirsTrackingResource with 4 items:
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_5
    # - csirsTrackingSlotOffset is set to 21 and csirsTrackingSymbol is set to symbol_9
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_5
    # - csirsTrackingSlotOffset is set to 22 and csirsTrackingSymbol is set to symbol_9

CB008985-A-B301_SA_SIB_broadcast_in_all_subcells
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to validate SIB1 broadcast for idle state UEs located anywhere in the supercell.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE1 - Airphone simulator
    ...  - NRCELL.actSupercell is set to TRUE
    ...  - NRCELL.actBeamforming is set to FALSE
    ...  - NRCELL.pucchModeSelect is set to longPucch
    ...  - NRCELL.dlMimoMode is set to 4DL4UL
    ...  - NRCELL.numOfSubSectors='0sub-sector'
    ...  - NRCELL.numOfSuperSubcells=4 (4xCHANNELGROUP configured)
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks='4 beams'  (set by OAM according to CFAM)
    ...  - NRBTS.actCarrierAggregation is set to false
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 4 simulated AZQP radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16786
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-A US#3: TDD FR1 SA- SIB broadcast in all subcells
    ...
    ...  == HISTORY ==
    ...     [22.07.2022] - TC Create

    [Tags]    MANUAL    B301

    Log to console    MANUAL
#    Try to reach onAir

#    Verify that gNB sent NGAP: NG SETUP REQUEST message to AMF1
    # NG SETUP REQUEST message includes:
    #- Global RAN Node ID
    #- TAC
    #- Broadcast PLMNs
    #- Default Paging DRX
#    Verify that gNB received NGAP: NG SETUP RESPONSE from AMF1

    Verify that supercell NRCELL-1 is onAir
    Verify that supercell NRCELL-1 broadcast SIB1 messages from all 4 subcells
#    Verify lack of alarms in gNB
