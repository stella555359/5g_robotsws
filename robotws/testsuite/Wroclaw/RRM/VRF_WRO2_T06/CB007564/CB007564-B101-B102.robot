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
...         [26.04.2022] - Switching TL type to CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...         [06.05.2022] - Removed RLF test procedure due to the changes introduced in 5G_L3_FLOW_59779 for PR644597
...         [05.12.2024] - Switching TL VARIANT to VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource    ./resources/CB007564_B_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource    ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     ta5g_file_system
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/wireshark_plugin.robot

Force Tags    CONFIGURED    CRT    PY310    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
...    AND      Upload Fixed Iphy Plug
...    AND      Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}

Suite Teardown    Compress Test Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/CB007564-B-101_QoS_Flow_Release_due_to_Redirection

*** Variables ***
@{FAULT_IDS}=             6450    4383
${delta_conf_procedure_1}=      ${CURDIR}/config/SBTS/delta_7564_actVoNR_disable_default.json
${delta_conf_procedure_3}=      ${CURDIR}/config/SBTS/delta_7564_actVoNR_enable.json
${delta_conf_procedure_4}=      ${CURDIR}/config/SBTS/delta_7564_maxNumOfGBRBearersSA_enable.json
${delta_conf_teardown}=         ${CURDIR}/config/SBTS/delta_7564_B101_teardown.json


*** Test Cases ***
CB007564-B-101 QoS Flow Release due to Redirection
    [Documentation]
    ...  == DESCRIPTION ==
    ...    - This user scenario checks whether counter "NG_FLOW_REL_GNB_REDIRECT" is updated after UE redirection triggerred to varoius reasons.
    ...    - Procedure 1: Redirection due to sending A2 measurement
    ...    - Procedure 2: Redirection due to unsuccessful setup of VoNR due to VoNR feature being disabled.
    ...    - Procedure 3: Redirection due to unsuccessful setup of VoNR due to VoNR NOT supported by UE.
    ...    - Procedure 4: Redirection due to unsuccessful setup ov VoNR due to exceeded max number of GBR bearers.
    ...
    ...  == PRECONDITIONS common for all procedures ==
    ...    - 5G UE/airphone is running with good channel condition for both UL and DL.
    ...    - two FDD Cells are operating in FR1.
    ...    - AMR Voice codec is configured.
    ...    - RLC-UM mode is supported in gNB/UE.
    ...    - UE should be within the cell since Mobility is not enabled.
    ...    - 5G Cell is configured and active for SA operation
    ...    - 5QI-5 setup as part of PDU Session Resource Setup
    ...    - Voice Fallback to LTE is enabled: NRBTS/actNormVCFallback
    ...    - MRBTS.NRBTS.actRedirect = true (5GC000708 is enabled)
    ...    - MRBTS.NRBTS.NRCELL.NRREDRT is configured with redirRat = 1 (EUTRA target)
    ...    - UE supports frequency configured as possible EUTRA target
    ...
    ...  == PRECONDITIONS specific for Procedure 1 ==
    ...    - UE is capable of Voice over NR
    ...
    ...  == PRECONDITIONS specific for Procedure 2 ==
    ...    - Voice over NR feature is disabled  NRBTS/NRCELL/actVoNR
    ...    - UE is capable of Voice over NR
    ...
    ...  == PRECONDITIONS specific for Procedure 3  ==
    ...    - Voice over NR feature is enabled  NRBTS/NRCELL/actVoNR
    ...    - UE is NOT capable of Voice over NR
    ...
    ...  == PRECONDITIONS specific for Procedure 4 ==
    ...    - Voice over NR feature is enabled  NRBTS/NRCELL/actVoNR
    ...    - UE is capable of Voice over NR
    ...    - maxNumOfGBRBearersSA = 1
    ...
    ...  == POSTCONDITIONS ==
    ...    - Redirection to LTE is successful
    ...    - Counter NG_FLOW_REL_GNB_REDIRECT is updated according to number of QoS Flows that were released.
    ...
    ...  == TESTING TOOLS ==
    ...    - Airphone, EPCSIM, EMSSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...    - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    - REQUIREMENTS IN SCOPE:  5G_PM_359
    ...
    ...  == REQUIRED LOGS ==
    ...    - NR-RRC, NGAP
    ...
    ...  == CONTACTS ==
    ...    - Maciej Madej    <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...    - CB007564 CFAM
    ...    - CB007564-1604 - CB007564-B-101 QosFlow Setup Fail due to Voice Fallback
    ...
    ...  == HISTORY ==
    ...     [19.10.2021] - Created TC
    ...     [19.10.2021] - Review started
    ...     [19.11.2021] - Test finished
    ...     [23.11.2021] - Review closed  https://collab.ext.net.nokia.com/ui#review:id=845524

    Set Test Variable    ${LUA_CFG}                     ${CURDIR}/config/egate_2c_FDD.lua
    Set Test Variable    @{yaml_paths_to_configure}     ${disable_ciphering_yaml_path}   ${CURDIR}/config/yaml_config/7564B101.yaml
    Run yaml setup
    Prepare test environment for CB007564-B-101

    Setup environment for procedure 1
    Attach UE1 and setup initial PDU Session with one QoS Flow

    Trigger sending A2 measurement
    Verify that RRC Connection Release for UE_1 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_1 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 1 in NRCELL-3 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-3 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-3 cell in gNB2


    Setup environment for procedure 2  #VoNR is disabled
    Attach UE2 and setup initial PDU Session with one QoS Flow
    Setup second QoS FLow for UE_2

    Try to setup Qos Flow for 5QI-1 for UE_2
    Verify that RRC Connection Release for UE_2 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_2 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 2 in NRCELL-3 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 2 in NRCELL-3 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 2 in NRCELL-3 cell in gNB2

    Setup environment for procedure 3  #VoNR is enabled, UE is not supporting VoNR
    Attach UE3 and setup initial PDU Session with one QoS Flow

    Try to setup QoS Flow for 5QI-1 for UE_3
    Verify that RRC Connection Release for UE_3 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_3 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 1 in NRCELL-3 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-3 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-3 cell in gNB2

    Setup environment for procedure 4  #maxNumOfGBRBearersSA =1, VoNR is enabled, UE supports VoNR
    Attach UE4 and setup initial PDU Session with one QoS Flow
    Try to setup QoS Flow for 5QI-1 for UE_4

    Attach UE5 and setup initial PDU Session with one QoS Flow
    Try to setup QoS Flow for 5QI-1 for UE_5
    Verify that RRC Connection Release for UE_5 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_5 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 1 in NRCELL-3 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-3 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-3 cell in gNB2

    [Teardown]  Run Keywords    Cleanup test environment for CB007564-B-101
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Find Errors
    ...    AND         Add Scout Scf Id To Test Data
    ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/CB007564-B-101_QoS_Flow_Release_due_to_Redirection
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/CB007564-B-101_QoS_Flow_Release_due_to_Redirection
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/CB007564-B-101_QoS_Flow_Release_due_to_Redirection
    ...                omit_collectors=sos_report

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
    [Tags]  B102
    Set Test Variable    ${LUA_CFG}               ${CURDIR}/config/egate_2c_TDD_APoABIO_GMC.lua
    Set Test Variable    ${enable_actGnbInitRlf_yaml_file}     ${CURDIR}/config/yaml_config/enable_actGnbInitRlf.yaml
    Set Test Variable    ${disable_actSeparatePduRelForGtpuError_yaml_file}    ${CURDIR}/config/yaml_config/disable_actSeparatePduRelForGtpuError.yaml
    Set Test Variable    @{yaml_paths_to_configure}     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
    ...                             ${enable_actGnbInitRlf_yaml_file}    ${disable_actSeparatePduRelForGtpuError_yaml_file}
    Run yaml setup
    Prepare test environment B102


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
    Trigger NG Reset from gNB2 by locking cell
    Verify that gNB2 sent NG Reset message to AMF1 after cell lock

    Collect PM counters file
    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 3 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 3 in NRCELL-1 cell in gNB2
    Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2

    [Teardown]  Run Keywords
    ...           Cleanup after test B102 with cell lock
    ...    AND    Find Errors
    ...    AND    Add Scout Scf Id To Test Data
    ...    AND    Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

*** Keywords ***
Prepare test environment for CB007564-B-101
    Send delta commissioning    input_filepath=${delta_conf_procedure_1}
    Execute egate command  cmd=amf_param voice_fallback=on id=1

Setup environment for procedure 1
    Set observers for redirection for UE_1

Setup environment for procedure 2
    Set observers for redirection for UE_2

Setup environment for procedure 3
    Send delta commissioning    input_filepath=${delta_conf_procedure_3}
    Set observers for redirection for UE_3

Setup environment for procedure 4
    Send delta commissioning    input_filepath=${delta_conf_procedure_4}
    Set observers for redirection for UE_5

Cleanup test environment for CB007564-B-101
    Execute egate command  cmd=kill_ue id=1-5
    Send delta commissioning    input_filepath=${delta_conf_teardown}
