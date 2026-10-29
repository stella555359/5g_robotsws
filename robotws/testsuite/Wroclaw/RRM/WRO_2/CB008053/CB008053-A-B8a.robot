*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPP_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    ...    CONFIGS_Wroclaw/RAN_L3_SW_WRO_2/CB008053.yaml

Documentation    :copyright: Nokia
...              :authors: Aleksandra Sienkiel
...              :contact: aleksandra.sienkiel@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB008053_messaging_filters.py
Variables    logging_policy.py


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests
${LOGS_COMPRESSION}=    ${False}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/basic_setup.cfg
${A1_ADD_A2_REL_ACTIVATION}=    A1_SCell_Addition_A2_SCell_Release_activation.json
${scfc}=              CB008053_AB8a_LPQ.xml
${ROLLBACK_A-B8a}=    Rollback_A-B8a.json
${UE_ID}=    4
${PCELL_ID}=    4

*** Test Cases ***
CB008053-A_B8a_PUCCH_reconfiguration_at_SCell_release_TDD_SCell_to_be_released_first
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
    ...        AND    With Gnb Configuration    commissioning=${scfc}
    ...        AND    Reboot Testline
    ...        AND    With Simulator Configuration    config=${BASIC_SETUP}

    Add Scout Data Info To Testcase
    Wait For Next Full Pm Interval

    Attach UE And Verify Establishing PDU Session    ue_id=${UE_ID}    cell_id=${PCELL_ID}    pdu_id=${PCELL_ID}
    Trigger And Verify A1-Based SCell Addition and A2 Measurement for SCell Release
    Trigger And Verify A2-Based SCell Release For 3th SCell TDD
    Trigger And Verify A2-Based SCell Release For 2nd SCell TDD
    Trigger And Verify A2-Based SCell Release For 1st SCell FDD

    Verify CA Counters Of Releasing SCell In DL Triggered By A2 Measurement For SA   ${PCELL_ID}

    Release UE

*** Keywords ***
Reboot Testline
    Run Keyword If    ${REBOOT} == ${True}    Trigger Site Reset
    Wait For Testline ICMP Echo Replies And SSH Services
    Set Suite Variable    $REBOOT    ${True}

Activate A1 SCell Addition and A2 SCell Release
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${A1_ADD_A2_REL_ACTIVATION}    retries=10    retry_timer=90

Rollback Configuration Changes
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${ROLLBACK_A-B8a}

Trigger And Verify A1-Based SCell Addition and A2 Measurement for SCell Release
    Expect SCell Addition messages flow    ue_id=${UE_ID}
    Send A1 Measurement For SCell Addition Purposes
    Check if SCell Addition messages flow occured    ue_id=${UE_ID}
    Verify 4CC And PUCCH And A2 Measurement Configuration

Trigger And Verify A2-Based SCell Release For 3th SCell TDD
    Expect SCell Release messages flow    ${UE_ID}
    Send A2 Measurement For SCell Release Purposes    meas_id=4    scell_id=3
    Check if SCell Release messages flow occured    ${UE_ID}
    Verify 3th TDD Scell Release

Trigger And Verify A2-Based SCell Release For 2nd SCell TDD
    Expect SCell Release messages flow    ${UE_ID}
    Send A2 Measurement For SCell Release Purposes    meas_id=3    scell_id=2
    Check if SCell Release messages flow occured    ${UE_ID}
    Verify 2nd TDD Scell Release

Trigger And Verify A2-Based SCell Release For 1st SCell FDD
    Expect SCell Release messages flow    ${UE_ID}
    Send A2 Measurement For SCell Release Purposes    meas_id=2    scell_id=1
    Check if SCell Release messages flow occured    ${UE_ID}
    Verify 1st FDD Scell Release

Send A1 Measurement For SCell Addition Purposes
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A1 srsrp_nr=51
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Send A2 Measurement For SCell Release Purposes
    [Arguments]    ${meas_id}    ${scell_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=33
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Verify 4CC And PUCCH And A2 Measurement Configuration
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_REQ_AB8}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP_AB8}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${maxCodeRate_and_maxPayloadSize_config_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${CSI_meas_config_with_beamforming_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${A2_measurements_config_for_SCells_release_TTTF_4CC_CA_in_RRCReconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${UE_ID}

Verify 3th TDD Scell Release
    Verify That Message Fulfills Query
    ...      ${selected_3th_SCell_for_TDD_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_3th_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${PUCCH_config_for_3th_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${CSI_meas_config_for_3th_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${measurements_config_for_3th_TDD_SCell_Release_in_TTTF_4CC_CA_in_RRCReconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellRelease_UE${UE_ID}

Verify 2nd TDD Scell Release
    Verify That Message Fulfills Query
    ...      ${selected_2nd_SCell_for_TDD_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_2nd_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${PUCCH_config_for_2nd_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${CSI_meas_config_for_2nd_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${measurements_config_for_2nd_TDD_SCell_Release_in_TTTF_4CC_CA_in_RRCReconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellRelease_UE${UE_ID}

Verify 1st FDD Scell Release
    Verify That Message Fulfills Query
    ...      ${selected_1st_SCell_for_FDD_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_1st_SCell_FDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${PUCCH_config_for_1st_SCell_FDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${CSI_meas_config_for_1st_SCell_FDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${measurements_config_for_1st_FDD_SCell_Release_in_TTTF_4CC_CA_in_RRCReconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellRelease_UE${UE_ID}

Verify CA Counters Of Releasing SCell In DL Triggered By A2 Measurement For SA
    [Arguments]    ${cell_id}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C06501    3    A2MEAS_REL1DLSCELL_ATT_SA
    ...    M55118C06502    3    A2MEAS_REL1DLSCELL_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    file_path=${pm_counter_file}

Release UE
    Release PDU session    ue_id=${UE_ID}   pdu_id=${PCELL_ID}
    Deregister UE    ue_id=${UE_ID}
