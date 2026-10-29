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
...       - I_MN_RAN_RD_VRF_WRO2_6_GMS <I_MN_RAN_RD_VRF_WRO2_6@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [20.10.2021] - Create Test Suite
...         [25.04.2022] - Switching TL type to CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...         [25.10.2022] - Switching TL type to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...         [05.12.2024] - Switching TL VARIANT to VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource    ./resources/CB007564_B_keywords.robot
Resource    ../resources/testing_env.robot
Resource    ../keywords/tshark_verifying.robot
Library     taf.ul.ettf.logging
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Variables    ../resources/custom_policy.py

Force Tags    CONFIGURED    CRT    PY310    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Suite Setup     Run Keywords    Enable Tshark Verification
...    AND      Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND      Run yaml setup

*** Variables ***
${LOGGING_POLICY}=        BASIC_POLICY
@{FAULT_IDS}=             6450    4383
${LUA_CFG}=         ${CURDIR}/config/egate_2c_FDD.lua
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
${second_qfi_id}=   6

*** Test Cases ***
CB007564-B-B103_Counters_for_AMF_initiated_PDU_Session_Release
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behaviour of CB007564 counters in cases related to QoS Flow release
    ...  due to AMF initiated PDU Session Resouce Release procedure with different causes
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
    ...    REQUIREMENTS IN SCOPE: 5G_PM_470, 5G_PM_471, 5G_PM_472
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-B#US10 AMF initiated QosFlow Release due to Radio Connnection With Ue Lost
    ...     -  CB007564-B#US11 AMF initiated QosFlow Release due to Normal cause
    ...     -  CB007564-B#US12 AMF initiated QosFlow Release due to Other cause
    ...
    ...  == HISTORY ==
    ...     [17.11.2021] - TC Create

    [Setup]  Prepare test environment B103
    [Tags]  B103

    Attach UE1 and setup initial PDU Session with one QoS Flow
    Verify that UE1 was attached to gNB2
    Add secondary PDU Session to UE1 with one QoS Flow
    Add secondary QoS flow to UE1 second PDU Session
    Trigger PDU Session Resource Release for UE1 second PDU session with cause: "radioNetwork: radio-connection-with-ue-lost"
    Verify that second UE1 PDU session was released with cause: "radioNetwork: radio-connection-with-ue-lost"

    Add secondary PDU Session to UE1 with one QoS Flow
    Add secondary QoS flow to UE1 initial PDU Session
    Trigger PDU Session Resource Release for UE1 second PDU session with cause: "nas: normal-release"
    Verify that second UE1 PDU session was released with cause: "nas: normal-release"

    Add secondary PDU Session to UE1 with one QoS Flow
    Add secondary QoS flow to UE1 second PDU Session
    Trigger PDU Session Resource Release for UE1 second PDU session with cause: "protocol: message-not-compatible-with-receiver-state"
    Verify that second UE1 PDU session was released with cause: "protocol: message-not-compatible-with-receiver-state"

    Collect PM counters file
    Verify that M55125C09018 NG_FLOW_REL_AMF_UE_LOST counter is equal 2 in NRCELL-3 cell in gNB2
    Verify that M55125C09019 NG_FLOW_REL_AMF_NORMAL counter is equal 1 in NRCELL-3 cell in gNB2
    Verify that M55125C09020 NG_FLOW_REL_AMF_OTHER counter is equal 2 in NRCELL-3 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 5 in NRCELL-3 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-3 cell in gNB2

    Add secondary PDU Session to UE1 with one QoS Flow
    Add secondary QoS flow to UE1 second PDU Session
    Set UE1 to ignore RRC Reconfiguration messages
    Trigger PDU Session Resource Release for UE1 second PDU session with normal cause
    Verify that second UE1 PDU Session Resource Release failed
    Verify that UE1 context was released with cause: "radioNetwork: radio-connection-with-ue-lost"

    Set UE1 to stop ignoring RRC Reconfiguration messages

    Collect PM counters file
    Verify that M55125C09018 NG_FLOW_REL_AMF_UE_LOST counter is equal 0 in NRCELL-3 cell in gNB2
    Verify that M55125C09019 NG_FLOW_REL_AMF_NORMAL counter is equal 0 in NRCELL-3 cell in gNB2
    Verify that M55125C09020 NG_FLOW_REL_AMF_OTHER counter is equal 0 in NRCELL-3 cell in gNB2
    Verify that M55125C09005 NG_FLOW_REL_GNB_UE_LOST counter is equal 4 in NRCELL-3 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 4 in NRCELL-3 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-3 cell in gNB2

    Attach UE2 and setup initial PDU Session with one QoS Flow
    Verify that UE2 was attached to gNB2
    Add secondary PDU Session to UE2 with one QoS Flow
    Add secondary QoS flow to UE2 second PDU Session
    Trigger PDU Session Modify to delete QoS flow from UE2 second PDU session with cause: "radioNetwork: radio-connection-with-ue-lost"
    Verify that modification of UE2 second PDU Session succeded

    Add secondary QoS flow to UE2 initial PDU Session
    Trigger UE2 context release with cause: "radioNetwork: slice-not-supported"
    Verify that UE2 context was released with cause: "radioNetwork: slice-not-supported"

    Collect PM counters file
    Verify that M55125C09018 NG_FLOW_REL_AMF_UE_LOST counter is equal 1 in NRCELL-3 cell in gNB2
    Verify that M55125C09019 NG_FLOW_REL_AMF_NORMAL counter is equal 0 in NRCELL-3 cell in gNB2
    Verify that M55125C09020 NG_FLOW_REL_AMF_OTHER counter is equal 3 in NRCELL-3 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 4 in NRCELL-3 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-3 cell in gNB2

    [Teardown]  Run Keywords    Cleanup after test B103
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Add Scout Scf Id To Test Data
