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
CB008985-A-B401_SA_Idle_state_paging
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to validate paging broadcast for idle state UEs in supercell.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE1 - Airphone simulator
    ...  - gNB2 up
    ...  - NRCELL.actSupercell is set to TRUE
    ...  - NRCELL.actBeamforming is set to FALSE
    ...  - NRCELL.pucchModeSelect is set to longPucch
    ...  - NRCELL.dlMimoMode is set to 2DL2UL
    ...  - NRBTS.actPaging is set to true
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
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16873
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-A US#4: TDD FR1 SA - Idle State Paging
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=863952
    ...
    ...  == HISTORY ==
    ...     [27.07.2022] - TC Create
    ...     [09.12.2022] - PASS: SBTS23R1_ENB_0000_000337_000000

    [Setup]  Prepare test environment B401
    [Tags]  B401

    Attach UE1 to gNB2 NRCELL-1 subcell_1
    Wait for UE1 to enter IDLE state

    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE1
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE1 is in ACTIVE state in subcell_1

    Trigger subcell switch for UE1 from NRCELL-1 subcell_1 to subcell_2
    Wait for UE1 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE1
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE1 is in ACTIVE state in subcell_2

    Trigger subcell switch for UE1 from NRCELL-1 subcell_2 to subcell_3
    Wait for UE1 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE1
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE1 is in ACTIVE state in subcell_3

    Trigger subcell switch for UE1 from NRCELL-1 subcell_3 to subcell_1
    Wait for UE1 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE1
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE1 is in ACTIVE state in subcell_1

    Detach and kill UE1


    Attach UE2 to gNB2 NRCELL-1 subcell_2
    Wait for UE2 to enter IDLE state

    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE2
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE2 is in ACTIVE state in subcell_2

    Trigger subcell switch for UE2 from NRCELL-1 subcell_2 to subcell_3
    Wait for UE2 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE2
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE2 is in ACTIVE state in subcell_3

    Trigger subcell switch for UE2 from NRCELL-1 subcell_3 to subcell_1
    Wait for UE2 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE2
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE2 is in ACTIVE state in subcell_1

    Trigger subcell switch for UE2 from NRCELL-1 subcell_1 to subcell_2
    Wait for UE2 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE2
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE2 is in ACTIVE state in subcell_2

    Detach and kill UE2


    Attach UE3 to gNB2 NRCELL-1 subcell_3
    Wait for UE3 to enter IDLE state

    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE3
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE3 is in ACTIVE state in subcell_3

    Trigger subcell switch for UE3 from NRCELL-1 subcell_3 to subcell_2
    Wait for UE3 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE3
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE3 is in ACTIVE state in subcell_2

    Trigger subcell switch for UE3 from NRCELL-1 subcell_2 to subcell_1
    Wait for UE3 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE3
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE3 is in ACTIVE state in subcell_1

    Trigger subcell switch for UE3 from NRCELL-1 subcell_1 to subcell_3
    Wait for UE3 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE3
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE3 is in ACTIVE state in subcell_3

    Detach and kill UE3

    [Teardown]  Cleanup after test B401

*** Keywords ***
Prepare test environment B401
    Execute egate command    cmd=amf_paging_param id=1 max_paging_retries=10
    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20

Cleanup after test B401
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Set UE IDLE timers on gNB: drbInactivityTimerSA=600 srbInactivityTimerSA=600
