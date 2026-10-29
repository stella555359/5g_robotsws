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
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [19.10.2021] - Created TC
...         [19.10.2021] - Review started
...         [19.11.2021] - Test finished
...         [23.11.2021] - Review closed  https://collab.ext.net.nokia.com/ui#review:id=845524
...         [10.02.2023] - Switching TL type to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB007564_B_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup    Run Setup alternative

*** Variables ***
${LUA_CFG}=                     ${CURDIR}/config/egate_2c_FDD.lua
${delta_conf_procedure_3}=      ${CURDIR}/config/SBTS/delta_7564_actVoNR_enable.json
${delta_conf_procedure_4}=      ${CURDIR}/config/SBTS/delta_7564_maxNumOfGBRBearersSA_enable.json
${delta_conf_teardown}=         ${CURDIR}/config/SBTS/delta_7564_B101_teardown.json
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}   ${CURDIR}/config/yaml_config/7564B101.yaml

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

    [Setup]  Prepare test environment for CB007564-B-101

    Setup environment for procedure 1
    Attach UE1 and setup initial PDU Session with one QoS Flow

    Trigger sending A2 measurement
    Verify that RRC Connection Release for UE_1 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_1 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 1 in NRCELL-1 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-1 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-1 cell in gNB2


    Setup environment for procedure 2  #VoNR is disabled
    Attach UE2 and setup initial PDU Session with one QoS Flow
    Setup second QoS FLow for UE_2

    Try to setup Qos Flow for 5QI-1 for UE_2
    Verify that RRC Connection Release for UE_2 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_2 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 2 in NRCELL-1 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 2 in NRCELL-1 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 2 in NRCELL-1 cell in gNB2

    Setup environment for procedure 3  #VoNR is enabled, UE is not supporting VoNR
    Attach UE3 and setup initial PDU Session with one QoS Flow

    Try to setup QoS Flow for 5QI-1 for UE_3
    Verify that RRC Connection Release for UE_3 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_3 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 1 in NRCELL-1 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-1 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-1 cell in gNB2

    Setup environment for procedure 4  #maxNumOfGBRBearersSA =1, VoNR is enabled, UE supports VoNR
    Attach UE4 and setup initial PDU Session with one QoS Flow
    Try to setup QoS Flow for 5QI-1 for UE_4

    Attach UE5 and setup initial PDU Session with one QoS Flow
    Try to setup QoS Flow for 5QI-1 for UE_5
    Verify that RRC Connection Release for UE_5 was sent
    Verify that NgAP:UEContextReleaseRequest for UE_5 was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"

    Collect PM counters file
    Verify that M55125C09002 NG_FLOW_REL_GNB_REDIRECT counter is equal 1 in NRCELL-1 cell in gNB2
#    Verify that M55125C08503 NG_FLOW_REL counter is equal 1 in NRCELL-1 cell in gNB2
#    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 1 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup test environment for CB007564-B-101

*** Keywords ***
Run Setup
    Log To Console    Setup started
    Check radios availability
    Sleep  1
    Reach Onair with retries    lua_cfg=${LUA_CFG}
    Setup devices aliases


Prepare test environment for CB007564-B-101
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
