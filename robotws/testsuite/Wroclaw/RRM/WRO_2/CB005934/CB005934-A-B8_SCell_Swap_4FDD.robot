*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Izabela Prosniak, Malgorzata Muth
...              :contact: izabela.prosniak@nokia.com, malgorzata.muth@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     CB005934_keywords.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var
Variables    CB005934_messaging_filters.py
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_5934_b8_LOO.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_5934-a-b8-LOO.cfg
${scfc}=    CB005934_A_B8_SCell_Swap_BOOLOO.xml
${UE_ID}=                  1
${PCELL_ID}=               1
${GNB_ID}=                 2
${PHYSCELL_ID}=            51
${PDU_PCELL_1}=            1
${GW_ID}=                  1

*** Test Cases ***
CB005934-SR-A-B8_A6_event_measurement_triggered_SCell_swap_for_SA_call_with_4CC_DL_CA_with_FDD_PCell_and_3_FDD_SCells

    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify A1 Measurement Configuration    ue_id=${UE_ID}
    Trigger A1 Based SCell Addition    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Verify 4CC FFFF SCell Addition For SCell Swap Message Contents    ue_id=${UE_ID}
    Start Data Traffic
    Verify Traffic Is Scheduled On All Cells 4CC DL And UL On PCell
    Trigger A6 For SCell Swap    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Verify Successful SCell Swap Message Contents    ue_id=${UE_ID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_PCELL_1}
    Verify SCell Swap Counters    pcell=${PCELL_ID}
