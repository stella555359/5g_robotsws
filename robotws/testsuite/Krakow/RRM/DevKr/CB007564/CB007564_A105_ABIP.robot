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
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [07.12.2021] - Create Test Suite

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD
    ...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB007564/trunk/a105_config_abip.yml

Resource    ./resources/CB007564_A_keywords.robot

Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/egate_2c_TDD_lte_enb.lua
${actEmergencyFallback_disable}=  ${CURDIR}/config/SBTS/delta_7564_actEmergencyFallback_disable.json
${delta_conf_procedure_3}=   ${CURDIR}/config/SBTS/delta_7564_actVoNR_disable.json
${delta_conf_procedure_4}=   ${CURDIR}/config/SBTS/delta_7564_maxNumOfGBRBearersSA_enable.json

*** Test Cases ***
CB007564-A-A105_Counters_for_ICS_fallback
    [Tags]    A105
    ...    GQC_PLAN:FEATURE:CB007564-5G-A
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behaviour of CB007564 counters in cases related with fallback occuring
    ...  during Initial Context Setup procedure
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIL + ASIK
    ...  - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - AMF1 simulated
    ...  - UE - Airphone simulator
    ...  - MRBTS/NRBTS/NRCELL.actVoNR set to false
    ...  - MRBTS/NRBTS.actRedirect set to true
    ...  - NRBTS.actNormVCfallback set to true
    ...  - MRBTS/NRBTS/NRCELL.voiceFBmode set to redirection
    ...  - MRBTS/NRBTS.actEmergencyFallback set to true
    ...  - MRBTS/NRBTS/NRCELL.actEmergencyCall set to false
    ...  - MRBTS/NRBTS/NRCELL.emergencyFBMode set to redirection
    ...  - MRBTS/NRBTS/NRCELL/NRREDRT is configured with redirRat = 1 (EUTRA target)
    ...
    ...  - gNB2 up and running with one SA TDD cell OnAir
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIL) with 2 simulated AEQA radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_363, 5G_PM_367
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...  - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-A#US2 QosFlow Setup Fail due to Voice Fallback
    ...     -  CB007564-A#US4 QosFlow Setup Fail due to Unspecified Reasons
    ...
    ...  == HISTORY ==
    ...     [07.12.2021] - TC Create

    Setup environment for procedure 1
    Try to attach UE1 to gNB2 with initial PDU Session with one QoS Flow and Emergency fallback indicator
    Verify that gNB2 sends ICS Response with cause "RadioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered"
    Verify that UE1 is released

    Collect PM counters file
    Verify that M55125C09008 NG_FLOW_SETUP_FAIL_FALLBACK counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 0 in NRCELL-1 cell in gNB2

    Setup environment for procedure 2
    Try to attach UE2 to gNB2 with initial PDU Session with one QoS Flow and Emergency fallback indicator
    Verify that gNB2 sends ICS Failure with cause "RadioNetwork: Unspecified"
    Verify that UE2 is released

    Collect PM counters file
    Verify that M55125C09011 NG_FLOW_SETUP_FAIL_UNSPECIFIED counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 0 in NRCELL-1 cell in gNB2

    Setup environment for procedure 3
    Attach UE3 and setup initial PDU Session with one QoS Flow
    Verify that UE3 was attached to gNB2
    Try to add 5QI-1 QoS flow to UE3 initial PDU Session
    Verify that gNB2 rejects 5QI-1 QoS flow setup with cause "RadioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered"
    Verify that UE3 is released

    Collect PM counters file
    Verify that M55125C09008 NG_FLOW_SETUP_FAIL_FALLBACK counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 1 in NRCELL-1 cell in gNB2

    Setup environment for procedure 4
    Attach UE4 and setup initial PDU Session with one QoS Flow
    Try to setup QoS Flow for 5QI-1 for UE_4
    Attach UE5 and setup initial PDU Session with one QoS Flow
    Try to setup QoS Flow for 5QI-1 for UE_5
    Verify that gNB sends PDU Session Resource Modify Response with cause: "RadioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered"
    Verify that UE5 is released

    Collect PM counters file
    Verify that M55125C09008 NG_FLOW_SETUP_FAIL_FALLBACK counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 4 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 3 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test A105
