*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marek Kocela
...              :contact: marek.kocela@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py


Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_b_b11.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}


*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_b_b11.cfg
${scfc}=              full_scfc_CB006733_B_B11.xml

${UE_ID}=    4
${SOURCE_CELL_ID}=    4
${GNB_ID}=    2
${PDU_ID}=    1
${GW_ID}=    1
${capabilityRequestFilter_hex_n25_n66_n71_n41_n77_n38}=    '0x802C0188083011A014404C804A'


*** Test Cases ***
CB006733-B_B11_MFBI_5GC001416_interaction_PCell_in_alternative_band_A4_measurement_for_FR1_SCell_Addition_not_activated
    Attach UE And Verify Establishing PDU Session With MFBI   ue_id=${UE_ID}    cell_id=${SOURCE_CELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}    capa_filter=${capabilityRequestFilter_hex_n25_n66_n71_n41_n77_n38}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
