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
...       - I_MN_RAN_RD_VRF_WRO2_12_GMS <I_MN_RAN_RD_VRF_WRO2_12@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [20.10.2021] - Create Test Suite
...         [25.04.2022] - Changing TL type to LO_AP_LO

Resource    ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB007564_A_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/wireshark_plugin.robot
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     ta5g_file_system

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    SANSA_FS_ECPRI_CMWV_TDD_GMC

Suite Setup     Run Keywords    Upload Fixed Iphy Plug
...    AND      Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND      Run yaml setup

Suite Teardown     Compress Test Logs

*** Variables ***
@{FAULT_IDS}=             6450    4383
${LUA_CFG}=         ${CURDIR}/config/egate_2c_TDD_APoABIO.lua
${7564A103_yaml_file}=     ${CURDIR}/config/yaml_config/7564A103.yaml
${delta_conf_procedure_4_in_A_A103}=     ${CURDIR}/config/SBTS/delta_7564_actVoNR_disable_cell1.json
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
...                             ${7564A103_yaml_file}

*** Test Cases ***
CB007564-A-A103_Counters_for_PDU_Session_Resource_Modify
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behaviour of CB007564 counters in cases related with PDU Session
    ...  Resource Modification
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - AMF1 simulated
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with two SA TDD cell OnAir
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_360, 5G_PM_366, 5G_PM_367, 5G_PM_368
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-A#US1 QosFlow Setup Fail due to Radio Connection With Ue Lost
    ...     -  CB007564-A#US3 QosFlow Setup Fail due to Wrong Message from Core
    ...     -  CB007564-A#US4 QosFlow Setup Fail due to Unspecified Reasons
    ...     -  CB007564-A#US5 QosFlow Setup Fail due to failure-in-radio-interface-procedure
    ...
    ...  == HISTORY ==
    ...     [15.12.2021] - TC Create

    [Setup]  Run Keywords    Prepare test environment A103
    ...      AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Tags]  A103  GQC_PLAN:FEATURE:CB007564-5G-A

    Attach UE1 and setup initial PDU Session with one QoS Flow
    Verify that UE1 was attached to gNB2
    Setup secondary PDU Session in UE1 with one QoS Flow
    Set UE1 to ignore RRC Reconfiguration messages
    Trigger PDU Session Resource Modify for UE1 second PDU session to add one QoS flow
    Verify that gNB does not receive RRC Reconfiguration Complete from UE1 and the rrcGuardTimer times out
    Verify that gNB sends PDU Session Resource Modify Response for UE1 with cause: "radioNetwork: radio-connection-with-ue-lost"
    Verify that UE1 was released
    Set RRC Reconfiguration to work correctly for UE1

    Attach UE2 and setup initial PDU Session with one QoS Flow
    Verify that UE2 was attached to gNB2
    Setup secondary PDU Session in UE2 with one QoS Flow
    Trigger PDU Session Resource Modify for UE2 second PDU session to delete unexisting QoS flow
    Verify that gNB sends PDU Session Resource Modify Response for UE2 with cause: "radioNetwork: unkown-qos-flow-ID"

    Attach UE3 and setup initial PDU Session with one QoS Flow
    Verify that UE3 was attached to gNB2
    Setup secondary PDU Session in UE3 with one QoS Flow
    Trigger PDU Session Resource Modify for UE3 second PDU session with multiple QoS Flow ID instances
    Verify that gNB sends PDU Session Resource Modify Response for UE3 with cause: "radioNetwork: multiple-qos-flow-ID-instances"

    Setup environment for CB007564-A-A103 procedure 4      #VoNR is disabled
    Attach UE4 and setup initial PDU Session with one QoS Flow
    Verify that UE4 was attached to gNB2
    Setup secondary PDU Session in UE4 with one QoS Flow
    Trigger PDU Session Resource Modify for UE4 second PDU session with not supported 5QI-1 value
    Verify that gNB sends PDU Session Resource Modify Response for UE4 with cause: "radioNetwork: not-supported-5QI-value"

    Collect PM counters file
    Verify that M55125C09009 NG_FLOW_SETUP_FAIL_UE_LOST counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C09012 NG_FLOW_SETUP_FAIL_WRONG_MSG counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C09003 NG_FLOW_REL_GNB_RLF counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 11 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 8 in NRCELL-1 cell in gNB2

    Attach UE5 and setup initial PDU Session with one QoS Flow
    Verify that UE5 was attached to gNB2
    Setup secondary PDU Session in UE5 with one QoS Flow
    Trigger PDU Session Resource Modify for UE5 second PDU session with new QoS flow without mandatory IE
    Verify that gNB sends PDU Session Resource Modify Response for UE5 with cause: "protocol: semantic-error"

    Attach UE6 and setup initial PDU Session with one QoS Flow
    Verify that UE6 was attached to gNB2
    Setup secondary PDU Session in UE6 with one QoS Flow
    Set RRC Reconfiguration to fail for UE6
    Trigger PDU Session Resource Modify for UE6 second PDU session to add one QoS flow and expect reestablishment
    Verify that gNB receives from UE6 RRC Reestablishment Request message with the cause set to "reconfigurationFailure"
    Verify that gNB sends PDU Session Resource Modify Response for UE6 with cause: "radioNetwork: radio-connection-with-ue-lost"

    Set RRC Reconfiguration to work correctly for UE6
    Collect PM counters file
    Verify that M55125C09011 NG_FLOW_SETUP_FAIL_UNSPECIFIED counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C09009 NG_FLOW_SETUP_FAIL_UE_LOST counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 7 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 6 in NRCELL-1 cell in gNB2

    [Teardown]  Run Keywords    Cleanup after test A103
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Find Errors
    ...    AND         Add Scout Scf Id To Test Data
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report
