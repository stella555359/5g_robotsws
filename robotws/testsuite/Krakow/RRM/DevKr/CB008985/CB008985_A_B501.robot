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
...         [01.08.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008985/SA_1_supercell_ABIO_4xAZQU_TDD_ECPRI.yaml

# AZQU mMIMO: numberOfTransmittedSsBlocks=4, basicBeamSet=beamSet_4
# AZQU non mMIMO:  numberOfTransmittedSsBlocks=1, basicBeamSet=beamSet_1

Suite Setup    Run Setup    reset_tl=${False}

Resource    ./resources/CB008985_keywords.robot

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/SANSA_TDD_1c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008985-A-B501_SA_call_on_supercell
    [Tags]    B501
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Check if all subcells of supercell are able to perform successful UE SA L3 call
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE1-4 SA - Airphone simulator
    ...  - NRCELL.proceduralStatus=configured - Supercell
    ...  - NRCELL.actSupercell=true
    ...  - NRCELL.actBeamforming=false
    ...  - NRCELL.actCellCsiRsImTddNonBf=false
    ...  - NRCELL.actCsirsMultiplexing=true
    ...  - NRCELL.dlMimoMode='4x4 or 4x2 Closed Loop Spatial Multiplexing' (40)
    ...  - NRCELL.nrCellType=4DL4UL
    ...  - NRCELL.numOfSubSectors='0sub-sector'
    ...  - NRCELL.numOfSuperSubcells=4 (4xCHANNELGROUP configured)
    ...  - NRCELL.pucchModeSelect=longPucch
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks='4 beams' (set by OAM according to CFAM)
    ...  - NRBTS.actCarrierAggregation=false
    ...  - NRBTS.actGeneralConnectivitySilver=true
    ...  - NRPMRNL.miNrBeamforming=5min
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 4 simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16872
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Marek Kieltyka (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     - US CB008985-A#5: TDD FR1 SA call on supercell
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=864247
    ...
    ...  == HISTORY ==
    ...     [01.08.2022] - TC Create

    Verify that supercell NRCELL-1 is onAir
    Verify that supercell NRCELL-1 broadcast SIB1 messages from all 4 subcells

    Repeat UE SA L3 call on supercell subcell_1
    Repeat UE SA L3 call on supercell subcell_2
    Repeat UE SA L3 call on supercell subcell_3
    Repeat UE SA L3 call on supercell subcell_4

    [Teardown]    Detach and kill UEs from 1 to 4

*** Keywords ***
Repeat UE SA L3 call on supercell subcell_${id:[1-4]}
    Attach UE${id} to gNB2 NRCELL-1 subcell_${id}
    Verify that UE${id} is in ACTIVE state in subcell_${id}
    Verify that CSI-SSB resources are properly allocated for UE${id} by supercell which has 4 beams

    Run 5Mbps UL and DL traffic on UE${id} PDU1 QFI1 and wait 5 seconds
    Verify 5Mbps UL and DL traffic on UE${id} PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=${id}


