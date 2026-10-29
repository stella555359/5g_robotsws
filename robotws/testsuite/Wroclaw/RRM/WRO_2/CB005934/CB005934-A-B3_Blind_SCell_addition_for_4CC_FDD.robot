*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Izabela Prosniak
...              :contact: izabela.prosniak@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB005934_keywords.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_egate
Library      ta5g_iphy
Variables    ta5g_global_var
Variables    CB005934_messaging_filters.py
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_5934_b3_LOO.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create gNB Alias


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_5934-a-b3-LOO.cfg
${DELTA_4CC_DEACTIVATION}=    delta_deactivation.json
${DELTA_4CC_ACTIVATION}=    delta_activation.json
${scfc}=              CB005934_A_B3_Blind_SCell_addition_BOOLOO.xml
${GNB_ID}=            2
${PCELL_ID}=          1  #Cell 1
${PHYSCELL_ID}=       51  #Cell 1
${UE_ID}=             1
${PDU_1}=             1
${GW_ID_1}=           1
${PDU_2}=             2  #Second session for UE=1 after deactivation feature
${GW_ID_2}=           2

*** Test Cases ***
CB005934-SR-A-B3_Single_UE_Call-Blind_SCell_addition_for_4CC_DL_CA_with_FDD_PCell_and_3_FDD_SCells

    Activate 4CC CA
    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_1}    gw_id=${GW_ID_1}
    Verify 4CC FFFF Blind SCell Addition Message Contents    ue_id=${UE_ID}
    Start Data Traffic
    Verify Traffic Is Scheduled On All Cells 4CC DL And UL On PCell
    Deactivate 4CC CA
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_1}
    Attach UE And Verify Establishing PDU Session Without Blind SCell Addition    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_2}    gw_id=${GW_ID_2}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_2}
