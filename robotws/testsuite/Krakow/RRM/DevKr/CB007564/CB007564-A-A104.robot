*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB007564: NR Additional PM Counters
...         This feature provides new Performance Measurement counters that are used for Network
...         Performance measurement and creation of new or improvement of existing KPIs. The Feature
...         introduces PM counters related to Stand Alone Architecture: Accessibility counters,
...         Retainability counters and Non Stand Alone Architectre: RACH counters
...
...      == TEST SET NAME ==
...         CB007564 - NR Additional PM Counters
...
...      == TESTING SPLIT ==
...         CB007564-A Accessibility counters
...         CB007564-A-A101 Development enabler
...         CB007564-A-A102 PDU Session Resource Setup
...         CB007564-A-A103 PDU Session Resource Modify
...         CB007564-A-A104 Initial Context Setup Failure
...         CB007564-A-A105 Initial Context Setup Response
...         CB007564-A-A106 Handover Scenarios
...         CB007564-A-A107 RRC Re-estabishment
...         CB007564-B Retainability counters
...         CB007564-B-B101 Release of UE/PDU Session/QoS Flow in all procedures
...         CB007564-B-B102 NG Reset
...         CB007564-B-B103 AMF initiated release
...         CB007564-B-B104 Handover Scenarios
...         CB007564-C RACH counters
...
...      == CONTACTS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [07.12.2021] - Create Test Suite
...         [25.04.2022] - Switching TL type to CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...         [25.10.2022] - Switching TL type to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB007564_A_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run yaml setup

*** Variables ***
${LUA_CFG}=         ${CURDIR}/config/egate_2c_FDD.lua
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}

*** Test Cases ***
CB007564-A-A104_Counters_for_ICS_failure
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behavior of CB007564 counters in cases related to Initial Context
    ...  Setup procedure failures due to different causes
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIL + ASIB
    ...  - NRCELL simulated on AHLOA radio module - NR_BAND: n71
    ...  - AMF1 simulated
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with one SA FDD cell OnAir
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIB) with simulated AHLOA radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_368
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-A#US5 QosFlow Setup Fail due to failure-in-radio-interface-procedure
    ...
    ...  == HISTORY ==
    ...     [07.12.2021] - TC Create

    [Setup]  Prepare test environment A104
    [Tags]  A104

    Block UE1 response to UE Capability Enquiry
    Try to attach UE1 to gNB2 and setup initial PDU Session with one QoS Flow
    Verify that gNB2 sends ICS Failure with cause: "radioNetwork: failure-in-radio-interface-procedure" for UE1

    Unblock UE1 response to UE Capability Enquiry

    Set UE2 to ignore RRC Reconfiguration messages
    Try to attach UE2 to gNB2 and setup initial PDU Session with one QoS Flow
    Verify that gNB2 sends ICS Failure with cause: "radioNetwork: failure-in-radio-interface-procedure" for UE2

    Set UE2 to stop ignoring RRC Reconfiguration messages

    Collect PM counters file
    Verify that M55125C09010 NG_FLOW_SETUP_FAIL_RADIO_PROC counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 0 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test A104
