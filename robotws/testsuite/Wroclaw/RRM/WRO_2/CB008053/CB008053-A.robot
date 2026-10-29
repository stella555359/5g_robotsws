*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Aleksandra Sienkiel
...              :contact: aleksandra.sienkiel@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
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
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${False}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/basic_setup.cfg
${scfc}=              CB008053-A.xml
${DELTA_4CC_DEACTIVATION}=    4CC_deactivation.json
${DELTA_4CC_ACTIVATION}=    4CC_activation.json
${BF_AND_BR_ACTIVATION}=    Beamforming_and_beamrefinement_activation.json
${ROLLBACK_A-B1c}=    Rollback_A-B1c.json
${GNB_ID}=    2
${FDD_PCELL_ID}=    1
${TDD_PCELL_ID}=    4
${UE_FDD_PCELL_1}=     1
${PDU_FDD_PCELL_1}=    1
${UE_FDD_PCELL_2}=     10
${PDU_FDD_PCELL_2}=    2
${UE_FDD_PCELL_3}=     11
${PDU_FDD_PCELL_3}=    3
${UE_TDD_PCELL_1}=     4
${PDU_TDD_PCELL_1}=    4
${UE_TDD_PCELL_2}=     40
${PDU_TDD_PCELL_2}=    5
${UE_TDD_PCELL_3}=     41
${PDU_TDD_PCELL_3}=    6


*** Test Cases ***
CB008053-A_B1c_gNB_configuration_and_Blind_SCell_Addition_with_Beamforming_and_beam_refinement_enabled
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
    ...        AND    With Gnb Configuration    commissioning=${scfc}
    ...        AND    Reboot Testline
    ...        AND    Activate Beamforming And Beam Refinement
    ...        AND    With Simulator Configuration    config=${BASIC_SETUP}
    ...        AND    Create gNB Alias
    ...        AND    Wait For Next Full Pm Interval

    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_TDD_PCELL_1}    cell_id=${TDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_1}    gw_id=${UE_TDD_PCELL_1}
    Verify 4CC TTTF UE1 Blind SCell Addition Message Contents    ue_id=${UE_TDD_PCELL_1}
    Verify Traffic Is Scheduled On All Cells 4CC    ue_id=${UE_TDD_PCELL_1}    pdu_id=${PDU_TDD_PCELL_1}
    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_FDD_PCELL_1}    cell_id=${FDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_1}    gw_id=${UE_FDD_PCELL_1}
    Verify 4CC FTTT Blind SCell Addition Message Contents    ue_id=${UE_FDD_PCELL_1}
    Verify Traffic Is Scheduled On All Cells 4CC    ue_id=${UE_FDD_PCELL_1}    pdu_id=${PDU_FDD_PCELL_1}

    Deactivate 4CC CA
    Verify 4CC CA Counters    ${FDD_PCELL_ID}    ${TDD_PCELL_ID}

    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_TDD_PCELL_2}    cell_id=${TDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_2}    gw_id=${UE_TDD_PCELL_2}
    Verify 3CC TTT Blind SCell Addition Message Contents    ue_id=${UE_TDD_PCELL_2}
    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_FDD_PCELL_2}    cell_id=${FDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_2}    gw_id=${UE_FDD_PCELL_2}
    Verify 3CC FTT Blind SCell Addition Message Contents    ue_id=${UE_FDD_PCELL_2}

    Activate 4CC CA

    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_TDD_PCELL_3}    cell_id=${TDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_3}    gw_id=${UE_TDD_PCELL_3}
    Verify 4CC TTTF UE2 Blind SCell Addition Message Contents    ue_id=${UE_TDD_PCELL_3}
    Verify Traffic Is Scheduled On All Cells 4CC    ue_id=${UE_TDD_PCELL_3}    pdu_id=${PDU_TDD_PCELL_3}
    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_FDD_PCELL_3}    cell_id=${FDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_3}    gw_id=${UE_FDD_PCELL_3}
    Verify 4CC FTTT Blind SCell Addition Message Contents    ue_id=${UE_FDD_PCELL_3}
    Verify Traffic Is Scheduled On All Cells 4CC    ue_id=${UE_FDD_PCELL_3}    pdu_id=${PDU_FDD_PCELL_3}

    Verify 4CC CA Counters    ${FDD_PCELL_ID}    ${TDD_PCELL_ID}
    Release All UEs
    [Teardown]    Rollback Configuration Changes


*** Keywords ***
Reboot Testline
    Run Keyword If    ${REBOOT} == ${True}    Trigger Site Reset
    Wait For Testline ICMP Echo Replies And SSH Services
    Set Suite Variable    $REBOOT    ${True}

Deactivate 4CC CA
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA_4CC_DEACTIVATION}

Activate 4CC CA
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA_4CC_ACTIVATION}

Activate Beamforming And Beam Refinement
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${BF_AND_BR_ACTIVATION}    retries=10    retry_timer=90

Rollback Configuration Changes
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${ROLLBACK_A-B1c}

Start Large Data Traffic
    [Arguments]    ${ue_id}=1   ${pdu_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=150

Verify Traffic Is Scheduled On All Cells 4CC
    [Arguments]    ${ue_id}=1   ${pdu_id}=1
    Start Large Data Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    5s    Wait for traffic to stabilize
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=3
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=3    expected_throughput=10Mbps
    Stop DL and UL traffic on PDU for UE    ue_id=${ue_id}    pdu_id=${pdu_id}

Verify 3CC TTT Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_TTT_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_TTT_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_3CC_TTT_BF_BR_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 3CC FTT Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FTT_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FTT_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_3CC_FTT_BF_BR_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC TTTF UE1 Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_UE1_CA_in_UE_CON_MOD_REQ_A_B1c}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_UE1_CA_in_UE_CON_MOD_RESP_A_B1c}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify 4CC TTTF Common Blind SCell Addition Message Contents    ue_id=${ue_id}

Verify 4CC TTTF UE2 Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_UE2_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_UE2_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify 4CC TTTF Common Blind SCell Addition Message Contents    ue_id=${ue_id}

Verify 4CC TTTF Common Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_TTTF_CA_BF_BR_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_TTTF_CA_BF_BR_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC FTTT Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FTTT_CA_BF_BR_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_FTTT_CA_BF_BR_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC CA Counters
    [Arguments]    @{cell_id_list}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    FOR  ${cell_id}    IN    @{cell_id_list}
            Verify Any Counters In File
        ...    M55138C03001    1    GNB_SCELL_3_ADMI_REQ_SA
        ...    M55138C03002    1    GNB_SCELL_3_ADMI_SUCC_SA
        ...    M55139C03001    1    GNB_DU_SCELL_3_ADMI_REQ_SA
        ...    M55139C03002    1    GNB_DU_SCELL_3_ADMI_SUCC_SA
        ...    M55118C09503    1    RRC_RECONF_ADD3DLSCELL_ATT_SA
        ...    M55118C09502    1    RRC_RECONF_ADD3DLSCELL_SUCC_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
        ...    file_path=${pm_counter_file}
    END

Release All UEs
    Release PDU session    ue_id=${UE_FDD_PCELL_1}    pdu_id=${PDU_FDD_PCELL_1}
    Deregister UE    ue_id=${UE_FDD_PCELL_1}
    Release PDU session    ue_id=${UE_TDD_PCELL_1}    pdu_id=${PDU_TDD_PCELL_1}
    Deregister UE    ue_id=${UE_TDD_PCELL_1}
    Release PDU session    ue_id=${UE_FDD_PCELL_2}    pdu_id=${PDU_FDD_PCELL_2}
    Deregister UE    ue_id=${UE_FDD_PCELL_2}
    Release PDU session    ue_id=${UE_TDD_PCELL_2}    pdu_id=${PDU_TDD_PCELL_2}
    Deregister UE    ue_id=${UE_TDD_PCELL_2}
    Release PDU session    ue_id=${UE_FDD_PCELL_3}    pdu_id=${PDU_FDD_PCELL_3}
    Deregister UE    ue_id=${UE_FDD_PCELL_3}
    Release PDU session    ue_id=${UE_TDD_PCELL_3}    pdu_id=${PDU_TDD_PCELL_3}
    Deregister UE    ue_id=${UE_TDD_PCELL_3}

