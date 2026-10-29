*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB007564: NR Additional PM counters for KPIs - I
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
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [08.11.2021] - Create Test Suite
...         [25.04.2022] - TL type switch to CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Resource    ./resources/CB007564_B_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run yaml setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_1c_TDD_sim_eNB.lua
${B101_UE_lost_yaml_file}=     ${CURDIR}/config/yaml_config/7564B101_UE_lost.yaml
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
...                             ${B101_UE_lost_yaml_file}

*** Test Cases ***
CB007564-B-B101_Counters_for_UE_lost
    [Tags]    B101_UE_lost
    ...    GQC_PLAN:FEATURE:CB007564-5G-B
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behaviour of CB007564 counters in cases related to QoS Flow release
    ...  due to Connection with UE Lost or UE Inactivity
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - AMF1 simulated
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with two SA cell OnAir
    ...	 - A1/A2 measurements are enabled and configured
    ...		-a1MeashoEnabledSA = rsrp
    ...		-a2MeashoEnabledSA = rsrp
    ...	 - drbInactivityTimerSA = 10
    ...	 - srbInactivityTimerSA = 10
    ...	 - activityNotificationLevelSA = UE
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_361, 5G_PM_362
    ...
    ...  == REQUIRED LOGS ==
    ...    F1AP, NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-B#US2 QosFlow Release due to Radio Connection With Ue Lost
    ...     -  CB007564-B#US4 QosFlow Release due to User Inactivity
    ...
    ...  == HISTORY ==
    ...     [08.11.2021] - TC Create

    [Setup]  Prepare test environment B101_UE_lost

# A1/A2 measurement report handling

    Attach UE1 and setup initial PDU Session with one QoS Flow
    Verify that UE1 was attached to gNB2
    Block sending RRC Reconfiguration Complete from UE_1
    Trigger A2 measurement send to gNB2 for UE1
    Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "radioNetwork: radio-connection-with-ue-lost" for UE1
    Verify that UE1 was released

    Unblock sending RRC Reconfiguration Complete from UE1
    Collect PM counters file
    Run Keyword And Continue On Failure     Verify that M55125C09005 NG_FLOW_REL_GNB_UE_LOST counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2

# PDU Session Setup procedure

    Attach UE2 and setup initial PDU Session with one QoS Flow
    Verify that UE2 was attached to gNB2
    Block sending RRC Reconfiguration Complete from UE2 during PDU Session Setup procedure
    Add secondary PDU Session to UE2 with one QoS Flow
    Verify that gNB2 sent PDU Session Resource Setup Response with failed PDU session and cause "radioNetwork: failure-in-radio-interface-procedure"
    Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "radioNetwork: radio-connection-with-ue-lost" for UE2
    Verify that UE2 was released

    Unblock sending RRC Reconfiguration Complete from UE2
    Collect PM counters file
    Run Keyword And Continue On Failure     Verify that M55125C09005 NG_FLOW_REL_GNB_UE_LOST counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C09010 NG_FLOW_SETUP_FAIL_RADIO_PROC counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2

# PDU Session Release procedure

    Attach UE3 and setup initial PDU Session with one QoS Flow
    Verify that UE3 was attached to gNB2
    Block sending RRC Reconfiguration Complete from UE3 during PDU Session Release procedure
    Trigger PDU session release for UE3
    Verify that gNB2 sent PDU Session Resource Release Command with cause "nas: normal-release"
    Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "radioNetwork: radio-connection-with-ue-lost" for UE3
    Verify that UE3 was released

    Unblock sending RRC Reconfiguration Complete from UE3
    Collect PM counters file
    Run Keyword And Continue On Failure     Verify that M55125C09005 NG_FLOW_REL_GNB_UE_LOST counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C09019 NG_FLOW_REL_AMF_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2

# UE Context Release due to DRB inactivity

    Attach UE4 and setup initial PDU Session with one QoS Flow
    Verify that UE4 was attached to gNB2
    Wait 10s for drbInactivityTimerSA to expire for UE4
    Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "radioNetwork: user-inactivity" for UE4
    Verify that UE4 was released

    Collect PM counters file
    Run Keyword And Continue On Failure     Verify that M55125C09004 NG_FLOW_REL_GNB_UE_INACTIVITY counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test B101
