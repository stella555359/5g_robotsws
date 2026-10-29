*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Blanka Gozdek, Lukasz Klimowicz
...              :contact: blanka.gozdek@nokia.com, lukasz.klimowicz@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB009854_keywords.robot
Library      ta_messaging
Library      ta5g_iphy
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Variables    CB009854_messaging_filters.py
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_9854.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}
...            AND             Create gNB Alias

*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${scfc}=              CB009854-AA-B6c.xml
${BASIC_SETUP}=       ${CURDIR}/config/AAB6c_wts_7cells_3FDD_n25_30MHzn66n71_20MHz_4TDD_n41_40_60MHz_n77_80_40MHz.cfg
${GNB_ID}=    2
${Trigger_CA_Meas_ID}=    1
${FDD_PCELL_ID}=     3
${UE_FDD_PCELL_3}=     3
${PDU_FDD_PCELL_3}=     3

*** Test Cases ***
CB009854-AA-B6c_A1_PCell_Measurement_report_not_meeting_secondary_report_quantity_threshold_does_not_trigger_SCell_Addition
    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_FDD_PCELL_3}
    ...    cell_id=${FDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_3}    gw_id=${UE_FDD_PCELL_3}
    Trigger A1 Based CA    ue_id=${UE_FDD_PCELL_3}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Release UE    ue_id=${UE_FDD_PCELL_3}    pdu_id=${PDU_FDD_PCELL_3}


