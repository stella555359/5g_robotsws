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
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...       - I_MN_RAN_RD_VRF_WRO2_6_GMS <I_MN_RAN_RD_VRF_WRO2_6@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [20.10.2021] - Create Test Suite
...         [05.12.2024] - Switching TL VARIANT to VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    CONFIGURED    CRT    PY310    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource    ./resources/CB007564_A_keywords.robot
Resource    ./resources/CB007564_common_keywords.robot
Resource    ./resources/CB007564_HO_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/wireshark_plugin.robot
Resource    ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     ta5g_file_system

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
...    AND      Upload Fixed Iphy Plug
...    AND      Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND      Run Setup
...    AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}

Suite Teardown    Compress Test Logs

*** Variables ***
@{FAULT_IDS}=         6450    4383
${LUA_CFG}=    ${CURDIR}/config/egate_2c_TDD.lua
${delta_configuration}=   ${CURDIR}/config/SBTS/delta_7564_actGnbInitRlf_enable.json

*** Test Cases ***
CB007564-A-A107_Counters_for_reestablishment
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    Purpose of this test is to verify correct behaviour of CB007564 counters in cases related with NR-RRC
    ...    Reestablishment
    ...
    ...  == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIB + ABIO
    ...    - both NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...    - AMF1 simulated
    ...    - UE - Airphone simulator
    ...    - MRBTS/NRBTS.rrcReestabTypeSA set to sameGNB
    ...
    ...    - gNB2 up and running with two SA TDD cell OnAir
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...    - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  gNB(ASIB + ABIO) with simulated AEQE radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_508
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...    - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...    - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-A#US7 Qos Flow Setup and Setup Success due to Intra DU / Intra-gNB re-establishment
    ...
    ...  == HISTORY ==
    ...     [09.12.2021] - TC Create

    [Setup]  Run Keywords    Prepare test environment A107
    ...      AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Tags]  A107  GQC_PLAN:FEATURE:CB007564-5G-A

    Attach UE1 to gNB2 NRCELL-1 and setup initial PDU Session with one QoS Flow
    Verify that UE1 was attached to gNB2
    Add secondary QoS flow to UE1 initial PDU Session
    Trigger intra-gNB reestablishment for UE1 to NRCell-2
    Verify that gNB sends RRC Reestablishment to UE1

    Collect PM counters file
    Verify that M55125C09023 NG_FLOW_STP_ATT_REEST_IADU counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09024 NG_FLOW_STP_SUC_REEST_IADU counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09023 NG_FLOW_STP_ATT_REEST_IADU counter is equal 2 in NRCELL-2 cell in gNB2
    Verify that M55125C09024 NG_FLOW_STP_SUC_REEST_IADU counter is equal 2 in NRCELL-2 cell in gNB2

    Add secondary PDU Session to UE1 with one QoS Flow
    Set UE1 reestablishment to fail by ignoring gNB2 RRC Reestablishment message
    Trigger failed intra-gNB reestablishment for UE1 to NRCell-2
    Verify that UE1 reestablishment failed due to lack of RRC Reestablishment Complete
    Verify that UE1 was released after reestablishment failure

    Collect PM counters file
    Verify that M55125C09023 NG_FLOW_STP_ATT_REEST_IADU counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09024 NG_FLOW_STP_SUC_REEST_IADU counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09023 NG_FLOW_STP_ATT_REEST_IADU counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09024 NG_FLOW_STP_SUC_REEST_IADU counter is equal 0 in NRCELL-2 cell in gNB2

    [Teardown]  Run Keywords    Cleanup after test A107
    ...    AND      Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND      Find Errors
    ...    AND      Add Scout Scf Id To Test Data
    ...    AND      Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

*** Keywords ***
Prepare test environment A107
    Send delta commissioning    input_filepath=${delta_configuration}
    Perform Parameter Commissioning    parameter=rrcReestabTypeSA  value=sameGNB

Cleanup after test A107
    Execute egate command  cmd=kill_ue id=1
    Execute egate command  cmd=ue_change_location id=1 enb=2 cell=1
