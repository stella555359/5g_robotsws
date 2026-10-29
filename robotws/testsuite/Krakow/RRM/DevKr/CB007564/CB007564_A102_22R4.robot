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
...         [20.10.2021] - Create Test Suite
...         [02.11.2022] - Creating separate file for old branches

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB007564_A_keywords.robot
Resource    ../resources/yaml_config_paths.robot
Library     ta_emss

Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/egate_2c_FDD.lua
${delta_configuration}=   ${CURDIR}/config/SBTS/delta_7564_actGnbInitRlf_enable.json

*** Test Cases ***
CB007564-A-A102_Counters_for_PDU_Session_Resource_Setup
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behaviour of CB007564 counters in cases related to failed QoS Flow
    ...  setup due different causes
    ...
    ...  == Precondition: ==
    ...    - gNB2 classical - real hardware - ABIL + ASIK
    ...    - NRCELL simulated on AHLOA radio module - NR_BAND: n71
    ...    - AMF1 simulated
    ...    - UE - Airphone simulator
    ...
    ...    - gNB2 up and running with one SA FDD cell OnAir
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...    - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  gNB(ABIL + ASIB) with simulated AHLOA radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_366, 5G_PM_368
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...    - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...    - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-A#US3 QosFlow Setup Fail due to Wrong Message from Core
    ...     -  CB007564-A#US5 QosFlow Setup Fail due to failure-in-radio-interface-procedure
    ...
    ...  == HISTORY ==
    ...     [26.11.2021] - TC Create

    [Tags]  A102
    [Setup]  Prepare CB007564_A102

    Attach UE1 and setup initial PDU Session with one QoS Flow
    Verify that UE1 was attached to gNB2
    Try to add to UE1 PDU session with one QoS Flow and S-NSSAI unsupported by gNB
    Verify that UE1 second PDU Session Setup failed with cause "RadioNetwork: slice-not-supported"

    Collect PM counters file
    Verify that M55125C09012 NG_FLOW_SETUP_FAIL_WRONG_MSG counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 1 in NRCELL-1 cell in gNB2

    Setup UE1 for procedure 2
    Try to add to UE1 PDU session with only 5QI-2
    Verify that UE1 second PDU Session Setup failed with cause "RadioNetwork: invalid-qos-combination"

    Collect PM counters file
    Verify that M55125C09012 NG_FLOW_SETUP_FAIL_WRONG_MSG counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 0 in NRCELL-1 cell in gNB2

    Setup UE1 for procedure 3
    Set RRC Reconfiguration to fail during UE1 PDU Session Resource Setup
    Try to add to UE1 PDU session with one QoS Flow
    Verify that gNB2 received RRC Reestablishmment Request with cause "reconfigurationFailure" for UE1
    Verify that UE1 second PDU session setup failed with cause "RadioNetwork: failure-in-radio-interface-procedure"

    Collect PM counters file
    Verify that M55125C09010 NG_FLOW_SETUP_FAIL_RADIO_PROC counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08501 NG_FLOW_SETUP_ATT_TOT counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C08502 NG_FLOW_SETUP_SUCC counter is equal 0 in NRCELL-1 cell in gNB2

*** Keywords ***
Prepare CB007564_A102
    Send delta commissioning    input_filepath=${delta_configuration}
    setup emss          bts_id=1
    Set         drbInactivityTimerSA        600
    Set         srbInactivityTimerSA        600
    configure           ${SA_srb_drb_inactivity_yaml_path}



Setup UE1 for procedure 2
    Execute egate command  cmd=qosflow_modify qos_flow=2 default=on ue=1

Setup UE1 for procedure 3
    Execute egate command  cmd=qosflow_modify qos_flow=5 default=on ue=1

Set RRC Reconfiguration to fail during UE1 PDU Session Resource Setup
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cause=reconfigurationFailure

Try to add to UE${ue_id} PDU session with one QoS Flow and S-NSSAI unsupported by gNB
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_setup_not_supp_slice
    ...     overall_timeout=30

    Execute egate command  cmd=ue_pdu_session_setup pdu=2 ue=1 gw=2 nwslice=2

Verify that UE${ue_id} second PDU Session Setup failed with cause "RadioNetwork: slice-not-supported"
    Flow occurred as expected  alias=UE${ue_id}_PDU_setup_not_supp_slice

    Verify That Message Fulfills Query
    ...     (cause contains (radioNetwork eq 'slice-not-supported'))
    ...     message_alias=PDU_Resp
    ...     flow_alias=UE${ue_id}_PDU_setup_not_supp_slice

Try to add to UE${ue_id} PDU session with only 5QI-2
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_setup_only_5qi2
    ...     overall_timeout=30

    Execute egate command  cmd=ue_pdu_session_setup pdu=3 ue=1 gw=3 nwslice=1

Verify that UE${ue_id} second PDU Session Setup failed with cause "RadioNetwork: invalid-qos-combination"
    Flow occurred as expected  alias=UE${ue_id}_PDU_setup_only_5qi2

    Verify That Message Fulfills Query
    ...     (cause contains (radioNetwork eq 'invalid-qos-combination'))
    ...     message_alias=PDU_Resp
    ...     flow_alias=UE${ue_id}_PDU_setup_only_5qi2

Try to add to UE${ue_id} PDU session with one QoS Flow
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_setup_reestablish_fail
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentRequest as RRCReestablish
    ...     alias=UE${ue_id}_reestablish_req
    ...     overall_timeout=30

    Execute egate command  cmd=ue_pdu_session_setup pdu=4 ue=1 gw=4 nwslice=1

Verify that gNB2 received RRC Reestablishmment Request with cause "reconfigurationFailure" for UE${ue_id}
    Flow occurred as expected  alias=UE${ue_id}_reestablish_req

    Verify That Message Fulfills Query
    ...     (reestablishmentCause eq 'reconfigurationFailure')
    ...     message_alias=RRCReestablish
    ...     flow_alias=UE${ue_id}_reestablish_req

Verify that UE${ue_id} second PDU session setup failed with cause "RadioNetwork: failure-in-radio-interface-procedure"
    Flow occurred as expected  alias=UE${ue_id}_PDU_setup_reestablish_fail

    Verify That Message Fulfills Query
    ...     (cause contains (radioNetwork eq 'failure-in-radio-interface-procedure'))
    ...     message_alias=PDU_Resp
    ...     flow_alias=UE${ue_id}_PDU_setup_reestablish_fail
