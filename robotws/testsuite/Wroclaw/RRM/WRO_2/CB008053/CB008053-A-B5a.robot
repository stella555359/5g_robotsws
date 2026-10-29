*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Izabela Prosniak
...              :contact: izabela.prosniak@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource    ../keywords/tshark_verifying.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB008053_messaging_filters.py
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${False}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/basic_setup.cfg
${scfc}=    CB008053-A-B5a.xml
${UE_ID}=                  40
${PCELL_ID}=               4
${PCELL_ID_2}=             3
${SCELL_ID_1}=             5
${SCELL_ID_2}=             6
${GNB_ID}=                 2
${PHYSCELL_ID}=            54
${PHYSCELL_ID_2}=          53
${PDU_PCELL_1}=            1
${GW_ID}=                  1
${A2_cmd}=
...    id=${UE_ID} meas_id=6 event=A2 srsrp_nr=5 srsrq_nr=5
...    scell=1 scell_rsrp=90 scell_rsrq=90
...    scell=2 scell_rsrp=34 scell_rsrq=10
...    scell=3 scell_rsrp=34 scell_rsrq=10


*** Test Cases ***
CB008053-A_B5a_Successful_A2_Measurement_PCell_triggered_PCell_change_to_FDD_SCell

    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify A1 Measurement Configuration    ue_id=${UE_ID}
    Trigger A1 Based SCell Addition With 4CC TFTT    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Verify 4CC TFTT SCell Addition Message Contents    ue_id=${UE_ID}
    Trigger PCell Change    ue_id=${UE_ID}    gNB_id=${GNB_ID}    A2_cmd=${A2_cmd}
    Verify Successful PCell Change And SCells Release    ue_id=${UE_ID}
    Trigger A1 Measurement To Verify CA Successful    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Verify Successful CA    ue_id=${UE_ID}
    Verify 4CC CA Counters    scell_1=${PCELL_ID}    scell_2=${SCELL_ID_1}    scell_3=${SCELL_ID_2}    pcell=${PCELL_ID_2}
    Release UE

*** Keywords ***
Verify A1 Measurement Configuration
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurements_configuration_in_RRCReconfiguration_B5}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_UE${ue_id}

Trigger A1 Based SCell Addition With 4CC TFTT
    [Arguments]    ${ue_id}    ${gNB_id}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=2 event=A1 srsrp_nr=90
    Check If SCell Addition Messages Flow Occured    ${ue_id}

Verify 4CC TFTT SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify 4CC TFTT Common SCell Addition Message Contents    ue_id=${ue_id}

Verify 4CC TFTT Common SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_TFTT_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_4CC_UE_CON_MOD_RESP_PCell_Change}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_TFTT_B5}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Trigger PCell Change
    [Arguments]    ${ue_id}    ${gNB_id}    ${A2_cmd}
    Wait For Next Full Pm Interval
    Expect PCell Change messages flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr ${A2_cmd}
    Check if PCell Change messages flow occured    ${ue_id}

Verify Successful PCell Change And SCells Release
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_PREP_in_UE_CON_MOD_REQ_B5}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_UE_CON_MOD_RESP_RELEASE_B5}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_FTTT_B5}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=PCellChange_UE${ue_id}

Trigger A1 Measurement To Verify CA Successful
    [Arguments]    ${ue_id}    ${gNB_id}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=7 event=A1 srsrp_nr=90
    Check If SCell Addition Messages Flow Occured    ${ue_id}

Verify Successful CA
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ_B5}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP_B5}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC CA Counters
    [Arguments]    ${scell_1}    ${scell_2}    ${scell_3}    ${pcell}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C11009    >0    UE_SCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_1}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C11009    >0    UE_SCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_2}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C11009    >0    UE_SCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_3}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell}
    ...    file_path=${pm_counter_file}

Expect PCell Change messages flow
    [Arguments]    ${ue_id}    ${gNB_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    alias=PCellChange_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Check if PCell Change messages flow occured
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=PCellChange_UE${ue_id}

Release UE
    Release PDU session    ue_id=${UE_ID}    pdu_id=${PDU_PCELL_1}
    Deregister UE    ue_id=${UE_ID}
