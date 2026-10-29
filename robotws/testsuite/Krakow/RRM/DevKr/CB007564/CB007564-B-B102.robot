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
...         [20.10.2021] - Create Test Suite
...         [26.04.2022] - Switching TL type to CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...         [06.05.2022] - Removed RLF test procedure due to the changes introduced in 5G_L3_FLOW_59779 for PR644597

Resource    ./resources/CB007564_B_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run yaml setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_APoABIO.lua
${enable_actGnbInitRlf_yaml_file}=     ${CURDIR}/config/yaml_config/enable_actGnbInitRlf.yaml
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
...                             ${enable_actGnbInitRlf_yaml_file}

*** Test Cases ***
CB007564-B-B102_QoS_flow_release_due_to_issues_with_links
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behaviour of CB007564 counters in cases related to QoS Flow release
    ...  due to NG Reset, transport error or radio link failure
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - AMF1 simulated
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - NRBTS-actGnbInitRlf is set to TRUE
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_365, 5G_PM_369, 5G_PM_370, 5G_PM_442
    ...
    ...  == REQUIRED LOGS ==
    ...    F1AP, NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
#    ...     -  CB007564-B#US5 QosFlow Release due to Radio Link Failure - removed because of PR644597
    ...     -  CB007564-B#US6 QosFlow Release due to NG Reset initiated by AMF
    ...     -  CB007564-B#US7 QosFlow Release due to NG Reset initiated by gNB
    ...     -  CB007564-B#US8 QosFlow Release due to Transport Errors
    ...
    ...  == HISTORY ==
    ...     [20.10.2021] - TC Create

    [Setup]  Prepare test environment B102
    [Tags]  B102  GQC_PLAN:FEATURE:CB007564-5G-B

# Test removed due to the changes introduced in 5G_L3_FLOW_59779 for PR644597
#    Attach UE1 and setup initial PDU Session with one QoS Flow
#    Verify that UE1 was attached to gNB2
#    Start DL traffic over UE1 PDU Session
#    Trigger Radio Link Failure for UE1
#    Verify that gNB2 sent F1AP: UE Context Modification Required message with cause "rl-failure-others" for UE1
#    Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "Radionetwork: unspecified" for UE1
#    Verify that UE1 was released
#
#    Deactivate Radio Link Failure for UE1

    Attach UE2 and setup initial PDU Session with one QoS Flow
    Verify that UE2 was attached to gNB2
    Start DL traffic over UE2 PDU Session
    Trigger sending GTP-U Error Indication message to gNB2 for UE2
    Verify that gNB2 received GTP-U error indication message
    Verify that gNB2 sent E1AP: Bearer Context Modification Required message with cause "transport-resource-unavailable" for UE2
    Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "Transport: unspecified" for UE2
    Verify that UE2 was released

    Attach UE3 and setup initial PDU Session with one QoS Flow
    Verify that UE3 was attached to gNB2
    Add secondary QoS flow to UE3 initial PDU Session
    Attach UE4 and setup initial PDU Session with one QoS Flow
    Verify that UE4 was attached to gNB2
    Start DL traffic over UE3 PDU Session
    Start DL traffic over UE4 PDU Session
    Trigger NG Reset from AMF1 for UE3 only
    Verify that gNB2 received NG Reset message from AMF1
    #  Reset Type is set to partOfNG_Interface
    #  AMF_UE_NGAP_ID refers to UE3

    Collect PM counters file
#    Verify that M55125C09003 NG_FLOW_REL_GNB_RLF counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C09007 NG_FLOW_REL_GNB_TRS counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C09017 NG_FLOW_REL_NG_RESET_AMF counter is equal 2 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 3 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2

    Attach UE5 and setup initial PDU Session with one QoS Flow
    Verify that UE5 was attached to gNB2
    Add secondary PDU Session to UE5 with one QoS Flow
    Start DL traffic over UE5 secondary PDU Session
    Trigger NG Reset from gNB2 for all UEs by breaking SCTP on F1 interface
    Verify that gNB2 sent NG Reset message to AMF1
    #  cause: Release Due to NG-RAN Generated Reason
    #  Reset Type is set to nG_Interface

    Collect PM counters file
    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 3 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 3 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test B102
