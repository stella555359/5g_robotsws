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
...
...      == MAINTAINER ==
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...
...      == REFERENCES ==
...         CB008985 CFAM
...
...      == HISTORY ==
...         [10.08.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008985/SA_1_supercell_ABIO_3xAZQP_TDD_ECPRI.yaml

Suite Setup    Run Setup    reset_tl=${False}

Resource    ./resources/CB008985_keywords.robot

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/SANSA_TDD_1c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008985-A-B203_UE_configuration_for_reporting_of_best_SSB_beams
    [Tags]    B203
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Check if CSI-SSB resources are properly allocated for UE during ICS on supercell
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE1-3 - Airphone simulator
    ...  - NRCELL.proceduralStatus=configured - Supercell
    ...  - NRCELL.actSupercell=true
    ...  - NRCELL.actBeamforming=false
    ...  - NRCELL.actCellCsiRsImTddNonBf=false
    ...  - NRCELL.actCsirsMultiplexing=true
    ...  - NRCELL.actPerCsiReportBundlingTddFr1=false
    ...  - NRCELL.dlMimoMode='2x2 Closed Loop Spatial Multiplexing' (50)
    ...  - NRCELL.nrCellType=2DL2UL
    ...  - NRCELL.numOfSubSectors='0sub-sector'
    ...  - NRCELL.numOfSuperSubcells=3 (3xCHANNELGROUP configured)
    ...  - NRCELL.pucchModeSelect=longPucch
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks='3 beams'  (set by OAM according to CFAM)
    ...  - NRBTS.actCarrierAggregation=false
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 3 simulated AZQP radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16872
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP, F1AP pcap
    ...
    ...  == CONTACTS ==
    ...  - Marek Kieltyka (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  US CB008985-A#5: TDD FR1 SA call on supercell
    ...
    ...  == HISTORY ==
    ...     [10.08.2022] - TC Create

    Verify that supercell NRCELL-1 is onAir
    Verify that supercell NRCELL-1 broadcast SIB1 messages from all 3 subcells

    Attach UE1 to gNB2 NRCELL-1 subcell_1
    Attach UE2 to gNB2 NRCELL-1 subcell_2
    Attach UE3 to gNB2 NRCELL-1 subcell_3

    Verify that CSI-SSB resources are properly allocated for UE1 by supercell which has 3 beams
    Verify that CSI-SSB resources are properly allocated for UE2 by supercell which has 3 beams
    Verify that CSI-SSB resources are properly allocated for UE3 by supercell which has 3 beams

    [Teardown]  Run keywords
    ...  Detach and kill UE1
    ...  Detach and kill UE2
    ...  Detach and kill UE3
