*** Settings ***
Documentation
...      INTRODUCTION:  5GC000281: CPLANE OVERLOAD PROTECTION
...                     Feature introduce new functions with gNB support CPLANE overload protection mechanism aimed at
...                     critical resource exhaustion and avoiding any software crash in gNB-CU.
...
...      TEST SET NAME: 5GC000281
...
...      TESTING SPLIT: 5GC000281-B - NSA Counter measures and associated PM Counters and parameters
...                     5GC000281-B-a Incoming NSA addition rejections
...                     5GC000281-B-b NSA measurement report discards
...                     5GC000281-B-c SgNB Modifiaction Request from MeNB for additional E-RAB additions
...                     5GC000281-B-d SgNB Modifiaction Request from from Inter LTE HO
...                     5GC000281-C - SA Counter measures and associated PM Counters and parameters
...                     5GC000281-C-a Incoming SA Call RRC Call Rejection for non-emergency
...                     5GC000281-C-b Measurement report discard for non-emergency for SA
...                     5GC000281-C-c PDU Session Resource Request for new E-RABs (for non-emergency UEs) for SA
...                     5GC000281-C-d XnAP:Handover Request rejection of non-emergency UEs
...                     5GC000281-C-e Beam Switch/Port modification Request refusal for both NSA and SA
...      == AUTHORS ==
...                     - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...                     - Mateusz Matusik <mateusz.matusik@nokia.com>
...                     - Michał Szymakowski <michal.szymakowski@nokia.com>
...                     - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...                      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...                     5GC000281 CFAM
...                     https://nokia.sharepoint.com/:w:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC0200-5GC0399/5GC000281%20C-plane%20overload%20protection
...                     /CP1%20Material/CP1%20CFAM%205GC000281%20ReviewVersion.docx?web=1
...
...      HISTORY:
...         [12.01.2022] - Created TC instance for ABIN FDD

Resource    ./resources/5GC000281_C_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    ...    CONFIGS_Krakow/5GC000281/configABIN_SA.yml

Suite Setup  Run ABIN suite setup

*** Variables ***
${lua_cfg_file}=    ${CURDIR}/config/SA/egate_2c_emer_n71.lua

*** Test Cases ***
CB007271_5GC000281-C-5_Emergency_UE_handling_in_cpln_ovl_state_ABIN_FDD
    [Tags]    C5    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and feature 5GC000784 - Emergency calls handling in SA mode
    ...  is enabled on gNB then countermeasure should not be applied to Emergency UEs.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIN + ASIB
    ...  - gNB3 - simulated gNB with nr_cell_1_n71
    ...  - NRCELL simulated on AHLOA radio module - NR_BAND: n71
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - gNB2 not in CPLANE overload state
    ...  - NRBTS-actCuOvlProt is set to TRUE
    ...  - NRBTS-ovlSaRrcRej is set to TRUE
    ...  - NRBTS-ovlSaMeasDiscard is set to TRUE
    ...  - NRBTS-ovlSaPduRej is set to TRUE
    ...  - NRBTS-ovlSaHoRej is set to TRUE
    ...  - Xn link is up between gNB2 and gNB3
    ...  - gNB2 configured with 5GC000784 - NRCELL-actEmergencyCall is set to TRUE
    ...  - AMF supports Emergency services
    ...  - NRBTS/NRCELL/arpPrioEmergencyCall set to 1
    ...  - UEs are capable of VoNR
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIN + ASIB) with simulated AHLOA radio module - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     REQUIREMENTS IN SCOPE: 5G_RAN_CP_12361044 5G_RAN_CP_12361047 5G_RAN_CP_12361048 5G_RAN_CP_12359173
    ...
    ...  == REQUIRED LOGS ==
    ...  - NR_RRC
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     - 5GC000281-C#US1 Incoming SA Call RRC Call Rejection for non-emergency UEs due to overload
    ...     - 5GC000281-C#US2 Measurement report discarding for non-emergency UEs due to overload
    ...     - 5GC000281-C#US3 PDU Session Resource Setup/Modify Request (for new QoS Flow for non-emergency UEs) rejections
    ...     - 5GC000281-C#US4 XnAP:Handover Request rejection of non-emergency UEs due to overload
    ...  == HISTORY ==
    ...     [12.01.2022]  - Created TC

    [Setup]  Prepare test environment ABIN

    UE1 attach to gNB2
    Verify that Establishment Cause IE not set to emergency for UE1
    Verify that UE1 is attached to gNB2
    Emergency UE2 attach to gNB2
    Verify that Establishment Cause IE set to emergency for UE2
    Verify that UE2 is attached to gNB2

    Perform CPLANE OVL activation via R&D mechanism

    Try to attach UE3 to gNB2 during active OVL
    Verify that Establishment Cause is not set to emergency for UE3
    Verify that gNB2 sends RRC Reject to UE3
    Emergency UE4 attach to gNB2
    Verify that Establishment Cause IE set to emergency for UE4
    Verify that UE4 is attached to gNB2
    AMF sends NGAP: PDU Session Resource Setup Request with Emergency ARP priority equal to 5

    Emergency UE5 attach to gNB3
    Emergency UE5 triggers handover to gNB2
    Verify that gNB3 sends XNAP: Handover Request to gNB2 for UE5
    Verify that gNB2 sends XNAP: Handover Request Acknowledge to gNB3 for UE5
    Verify that Emergency UE5 is successfully handovered to gNB2 in cpln OVL state

    [Teardown]  Cleanup after test C5
