*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Aleksandra Vesely
...              :contact: aleksandra.vesely@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ute_wtssim
Library      ta5g_testline_management
Variables    CB008053_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}


*** Variables ***
${LOGS_COMPRESSION}=    ${False}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=    ${CURDIR}/config/basic_setup.cfg
${SCFC}=    CB008053-B_B2_scfc.xml
${GNB_ID}=    2
${FDD_PCELL_ID}=    1
${UE_FDD_PCELL_1}=    10
${PDU_FDD_PCELL_1}=    1
${SCELL_ADD_A1_MEAS_ID}=    1
${SCELL_CHANGE_A1_MEAS_ID}=    4
${A1_FOR_SCELL_ADDITION}=    EventA1
&{A1_RSRP_50}=    Threshold=RSRP 50
@{FREQUENCIES_A1}=    392410

*** Test Cases ***
CB008053-B_B2a_Interaction_with_SCell_Change
    Attach UE And Verify Establishing PDU Session    ue_id=${UE_FDD_PCELL_1}    cell_id=${FDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_1}    gw_id=${UE_FDD_PCELL_1}
    Verify Measurements Are Configured At UE    ue_id=${UE_FDD_PCELL_1}    event_type=${A1_FOR_SCELL_ADDITION}
    ...    event_params=${A1_RSRP_50}    frequencies=${FREQUENCIES_A1}
    Trigger A1 Based SCell Addition With 3CC FFF    ue_id=${UE_FDD_PCELL_1}    gNB_id=${GNB_ID}
    Verify 3CC FFF A1 Based SCell Addition Message Contents    ue_id=${UE_FDD_PCELL_1}
    Trigger SCell Change to 4CC FTTT At UE    ue_id=${UE_FDD_PCELL_1}    gNB_id=${GNB_ID}
    Verify 4CC FTTT A1 Based SCell Change Message Contents    ue_id=${UE_FDD_PCELL_1}
    Verify 4CC CA Counters    ${FDD_PCELL_ID}
    Release UE

*** Keywords ***
Trigger A1 Based SCell Addition With 3CC FFF
    [Arguments]    ${ue_id}    ${gNB_id}
    Expect SCell Addition Messages Flow    ue_id=${ue_id}    gNB_id=${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_ADD_A1_MEAS_ID} event=A1 srsrp_nr=70
    Check If SCell Addition Messages Flow Occured    ue_id=${ue_id}

Verify 3CC FFF A1 Based SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FFF_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FFF_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_3CC_FFF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_3CC_FFF_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurements_config_for_FFF_3CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Trigger SCell Change to 4CC FTTT At UE
    [Arguments]    ${ue_id}    ${gNB_id}
    Wait For Next Full Pm Interval
    Expect SCell Change messages flow    ue_id=${ue_id}    gNB_id=${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_CHANGE_A1_MEAS_ID} event=A1 srsrp_nr=90
    Check if SCell Change messages flow occured    ue_id=${ue_id}

Verify 4CC FTTT A1 Based SCell Change Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_and_removed_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_SCell_Change_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP_SCell_Change}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_4CC_FTTT_UE_CON_MOD_RESP_SCell_Change}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurements_config_for_FTTT_4CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellChange_UE${ue_id}

Verify 4CC CA Counters
    [Arguments]    ${cell_id}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55138C03001    1    GNB_SCELL_3_ADMI_REQ_SA
    ...    M55138C03002    1    GNB_SCELL_3_ADMI_SUCC_SA
    ...    M55139C03001    1    GNB_DU_SCELL_3_ADMI_REQ_SA
    ...    M55139C03002    1    GNB_DU_SCELL_3_ADMI_SUCC_SA
    ...    M55118C06506    1    SCELL_CHANGE_ATT_SA
    ...    M55118C06507    1    SCELL_CHANGE_SUCC_SA
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    file_path=${pm_counter_file}

Release UE
    Release PDU session    ue_id=${UE_FDD_PCELL_1}    pdu_id=${PDU_FDD_PCELL_1}
    Deregister UE    ue_id=${UE_FDD_PCELL_1}
