*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_MP_AP_LO

Documentation    :copyright: Nokia
...              :authors: Dominik Rejman
...              :contact: dominik.rejman@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     CB007517_keywords.robot
Resource     ../keywords/logging.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta_messaging
Library      ta5g_ue_measurements
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.logging
Library      setup_with_reboot.py
Variables    CB007517_messaging_filters.py

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${A4RETRYTIMER_LENGTH_1}=    5
${A4RETRYTIMER_LENGTH_2}=    10
${UE_RRC_DELAY}=           3
${UE_ID}=                  1
${GNB_ID}=                 2
${CELL_ID}=                1
${PHYSCELL_ID}=            50
${EVENT_TYPE}=            EventA4
&{EVENT_PARAMS}=           Threshold=RSRP 34
@{FREQUENCIES}=            2043739    2079163
${EVENT_TYPE_A4}=         EventA4
${EVENT_TYPE_A2}=         EventA2
&{EVENT_PARAMS_A4}=        Threshold=RSRP 34
&{EVENT_PARAMS_A2}=        Threshold=RSRP 90
@{FREQUENCIES_A4}=         2043739    2079163
@{FREQUENCIES_A2}=         636576
${A4SUPERVISIONTIMER_LENGTH}=    10

*** Test Cases ***
CB007517-A_Configuration_Of_A4_Measurement_For_Mobility_To_Higher_NR_Frequency_Priority_After_SgNB_Addition_Procedure

    [Setup]    Run Keywords    Find Scfc And Fix And Send Full Commissioning
    ...    scfc_7517_A_B1.xml
    ...            AND             Set Custom SCTP RTO Min Time
    ...            AND             Start Vm Ethernet Interfaces
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${CURDIR}/config/egate_e5_nr78_257_258_DRX_ABIP.cfg
    ...            AND             Attach UE With RRC Delay In NSA Mode And Verify Success
    ...    ue_id=${UE_ID}    cell_id=${CELL_ID}    gNB_id=${GNB_ID}    ue_rrc_delay=${UE_RRC_DELAY}    a4retrytimer_length=${A4RETRYTIMER_LENGTH_1}

    Verify A4 Measurements Configuration For UE    ue_id=${UE_ID}    gNB_id=${GNB_ID}    a4retrytimer_length=${A4RETRYTIMER_LENGTH_1}
    Verify A4 Measurements Are Configured At UE    ue_id=${UE_ID}
    ...    event_types=${EVENT_TYPE}    event_params=${EVENT_PARAMS}    frequencies=${FREQUENCIES}
    Verify All Caught Messages Content For UE    ue_id=${UE_ID}    physcell_id=${PHYSCELL_ID}

    Add Scout Data Info To Testcase

    [Teardown]    Run Keywords      Detach UE    ue_id=${UE_ID}
    ...            AND             Stop Vm Ethernet Interfaces
    ...            AND             Stop Default Logging


CB007517-A_FR2_A4_Measurement_For_Mobility_Setup_Or_Removal_In_The_UE_On_An_NSA_3X_Call_On_FR1_PSCell
    [Setup]    Run Keywords    Find Scfc And Fix And Send Full Commissioning
    ...    scfc_7517_A_B4.xml
    ...            AND             Set Custom SCTP RTO Min Time
    ...            AND             Start Vm Ethernet Interfaces
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${CURDIR}/config/egate_e5_nr78_257_258_DRX_ABIP.cfg
    ...            AND             Attach UE In NSA Mode And Verify Success    ue_id=${UE_ID}    gNB_id=${GNB_ID}    cell_id=${CELL_ID}

    #Configuration Of A2 Measurement
    Verify A2 Measurement Configuration    ue_id=${UE_ID}
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A2}    event_params=${EVENT_PARAMS_A2}    frequencies=${FREQUENCIES_A2}
    #Configuration Of A4 Measurements
    Verify Measurements Setup Or Removal    ue_id=${UE_ID}    gNB_id=${GNB_ID}    timer_length=${A4RETRYTIMER_LENGTH_2}
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
    Verify Measurements Setup Or Removal  ue_id=${UE_ID}    gNB_id=${GNB_ID}    timer_length=${A4RETRYTIMER_LENGTH_2}
    ...    filter=${A4_measurements_reconfiguration_in_SgNBModReq_B4}    alias_name=A4_reconf
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A4}    event_params=${EVENT_PARAMS_A4}    frequencies=${FREQUENCIES_A4}

    Add Scout Data Info To Testcase

    [Teardown]    Run Keywords      Detach UE    ue_id=${UE_ID}
    ...            AND             Stop Vm Ethernet Interfaces
    ...            AND             Stop Default Logging

*** Keywords ***
Attach UE With RRC Delay In NSA Mode And Verify Success
    [Arguments]    ${ue_id}    ${cell_id}    ${ue_rrc_delay}    ${a4retrytimer_length}    ${gNB_id}
    Create SANSA Aliases    ue_id=${ue_id}
    Delay SgNBReconfigurationComplete Message On UE    ue_id=${ue_id}    ue_rrc_delay=${ue_rrc_delay}
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Expect ENDC Flow For UE    ue_id=${ue_id}    gNB_id=${gNB_id}
    Expect No SgNBModification Before A4RetryTimerExpiration
    ...    ue_id=${ue_id}    ue_rrc_delay=${ue_rrc_delay}    a4retrytimer_length=${a4retrytimer_length}    gNB_id=${gNB_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=${gNB_id}    target_cells=${cell_id}    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell ${cell_id}\\) reported successful RA
    Check If ENDC Messages Flow Occured    ue_id=${ue_id}

Delay SgNBReconfigurationComplete Message On UE
    [Arguments]    ${ue_id}    ${ue_rrc_delay}
    ${rrc_delay_ms}=    Evaluate    ${ue_rrc_delay}*1000
    ${rrc_timer_ms}=    Evaluate    ${rrc_delay_ms}+500
    Execute Egate Command    cmd=enb_timer T_RRC_TRANSACTION=${rrc_timer_ms}ms
    Execute Egate Command    cmd=ue_param id=${ue_id} if_rrc_reconf_contains=reconfiguration_with_sync nth=1 delay=${rrc_delay_ms}ms action=none

Expect No SgNBModification Before A4RetryTimerExpiration
    [Arguments]    ${ue_id}    ${ue_rrc_delay}    ${a4retrytimer_length}    ${gNB_id}
    # This is to make sure that a4RetryTimer starts after X2AP_SgNBReconfigurationComplete
    # and not immediately after X2AP_SgNBAdditionRequestAcknowledge.
    # Under the assumption that A4RETRYTIMER_LENGTH > UE_RRC_DELAY if a4RetryTimer starts right after SgNBAdditionRequestAcknowledge
    # it will expire during this keyword timeout but after SNStatusTransfer message so CP-CU will actually send X2AP_SgNBModificationRequired
    # and test will fail
    ${timeout}=    Evaluate    ${ue_rrc_delay}+${a4retrytimer_length}
    Expect Message Will Not Occur
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (SgNBtoMeNBContainer is present) as SgnbModReq
    ...    alias=no_A4_conf_UE${ue_id}
    ...    overall_timeout=${timeout}

Verify A4 Measurements Configuration For UE
    [Arguments]    ${ue_id}    ${a4retrytimer_length}    ${gNB_id}
    Expect A4 For Mobility Configuration Flow For UE    ue_id=${ue_id}     a4retrytimer_length=${a4retrytimer_length}    gNB_id=${gNB_id}
    Check If No A4 Configuration Occured Before A4RetryTimerExpiration    ue_id=${ue_id}
    Check If A4 For Mobility Configuration Flow Occured    ue_id=${ue_id}

Expect A4 For Mobility Configuration Flow For UE
    [Arguments]    ${ue_id}    ${a4retrytimer_length}    ${gNB_id}
    ${margin}=    Set Variable    5    # Safety margin for parsing messages, simulator operations etc - equal to timer tDCoverall
    ${timeout}=    Evaluate    ${a4retrytimer_length}+${margin}
    Expect Message Flow
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (SgNBtoMeNBContainer is present) as SgnbModReq
    ...    gNB${gNB_id}:X2AP_SgNBModificationConfirm (MeNBtoSgNBContainer is present) as SgnbModConf
    ...    alias=A4_conf_UE${ue_id}
    ...    overall_timeout=${timeout}

Check If No A4 Configuration Occured Before A4RetryTimerExpiration
    [Arguments]    ${ue_id}
    Flow Not Occurred For Message  alias=no_A4_conf_UE${ue_id}

Check If A4 For Mobility Configuration Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=A4_conf_UE${ue_id}

Verify A4 Measurements Are Configured At UE
    [Arguments]    ${ue_id}    ${event_types}    ${event_params}    ${frequencies}
    Get UE Measurement Configuration    ue_id=${ue_id}    alias=UE${ue_id}
    Verify That Specified Events Are Active On Given Frequencies And Have Specified Thresholds
    ...  event_type=${event_types}
    ...  event_params=${event_params}
    ...  frequencies=${frequencies}
    ...  alias=UE${ue_id}

Verify All Caught Messages Content for UE
    [Arguments]    ${ue_id}    ${physcell_id}
# All those keyword are moved to the end of the test due to time sensitive nature of previous operations
# Time needed for parsing messages could vary so it might affect a4RetryTimer and a4SupervisionTimer expiration
    Verify SgNBAddition Messages Flow Content For UE    ue_id=${ue_id}    physcell_id=${physcell_id}
    Verify That Message Fulfills Query    ${A4_measurements_configuration_in_SgNBModReq}  message_alias=SgnbModReq  flow_alias=A4_conf_UE${ue_id}
    Verify That Message Fulfills Query    ${RRCReconfCmp_in_SgnbModConf}  message_alias=SgnbModConf  flow_alias=A4_conf_UE${ue_id}

Verify A2 Measurement Configuration
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...    ${A2_measurements_configuration_in_SgNBAddReqAck}    message_alias=SgnbAddReqAck    flow_alias=EN-DC_X2AP_UE${ue_id}
