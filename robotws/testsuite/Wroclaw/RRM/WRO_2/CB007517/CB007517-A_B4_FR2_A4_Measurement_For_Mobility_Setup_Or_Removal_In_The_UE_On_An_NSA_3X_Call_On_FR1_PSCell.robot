*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_MP_AP_LO

Documentation    :copyright: Nokia
...              :authors: Izabela Prosniak
...              :contact: izabela.prosniak@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB007517_keywords.robot
Resource     ../keywords/logging.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.logging
Variables    CB007517_messaging_filters.py


Test Setup    Run Keywords    Find Scfc And Fix And Send Full Commissioning
...    scfc_7517_A_B4.xml
...            AND             Set Custom SCTP RTO Min Time
...            AND             Start Vm Ethernet Interfaces
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_e5_nr78_257_258_DRX_ABIP.cfg
...            AND             Attach UE In NSA Mode And Verify Success    ue_id=${UE_ID}    gNB_id=${GNB_ID}    cell_id=${CELL_ID}

Suite Teardown    Run Keywords      Detach UE    ue_id=${UE_ID}
...            AND             Stop Vm Ethernet Interfaces
...            AND             Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${A4RETRYTIMER_LENGTH}=    10
${A4SUPERVISIONTIMER_LENGTH}=    10
${UE_ID}=                  1
${CELL_ID}=                1
${GNB_ID}=                 2
${PHYSCELL_ID}=            50
${EVENT_TYPE_A4}=         EventA4
${EVENT_TYPE_A2}=         EventA2
&{EVENT_PARAMS_A4}=        Threshold=RSRP 34
&{EVENT_PARAMS_A2}=        Threshold=RSRP 90
@{FREQUENCIES_A4}=         2043739    2079163
@{FREQUENCIES_A2}=         636576


*** Test Cases ***
CB007517-A_FR2_A4_Measurement_For_Mobility_Setup_Or_Removal_In_The_UE_On_An_NSA_3X_Call_On_FR1_PSCell
    #Configuration Of A2 Measurement
    Verify A2 Measurement Configuration    ue_id=${UE_ID}
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A2}    event_params=${EVENT_PARAMS_A2}    frequencies=${FREQUENCIES_A2}
    #Configuration Of A4 Measurements
    Verify Measurements Setup Or Removal    ue_id=${UE_ID}    gNB_id=${GNB_ID}    timer_length=${A4RETRYTIMER_LENGTH}
    ...    filter=${A4_measurements_configuration_in_SgNBModReq_B4}    alias_name=A4_conf
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A4}    event_params=${EVENT_PARAMS_A4}    frequencies=${FREQUENCIES_A4}
    #Deconfiguration Of A4 Measurements, A2 should be kept
    Verify Measurements Setup Or Removal  ue_id=${UE_ID}    gNB_id=${GNB_ID}    timer_length=${A4SUPERVISIONTIMER_LENGTH}
    ...    filter=${A4_measurements_deconfiguration_in_SgNBModReq}    alias_name=A4_deconf
    Verify Measurements Are Not Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A4}    event_params=${EVENT_PARAMS_A4}    frequencies=${FREQUENCIES_A4}
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A2}    event_params=${EVENT_PARAMS_A2}    frequencies=${FREQUENCIES_A2}
    #Reconfiguration Of A4 Measurements
    Verify Measurements Setup Or Removal  ue_id=${UE_ID}    gNB_id=${GNB_ID}    timer_length=${A4RETRYTIMER_LENGTH}
    ...    filter=${A4_measurements_reconfiguration_in_SgNBModReq_B4}    alias_name=A4_reconf
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A4}    event_params=${EVENT_PARAMS_A4}    frequencies=${FREQUENCIES_A4}

*** Keywords ***
Verify A2 Measurement Configuration
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...    ${A2_measurements_configuration_in_SgNBAddReqAck}    message_alias=SgnbAddReqAck    flow_alias=EN-DC_UE${ue_id}

