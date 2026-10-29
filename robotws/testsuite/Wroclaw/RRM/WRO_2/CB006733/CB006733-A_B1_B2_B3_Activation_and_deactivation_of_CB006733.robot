*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Aleksandra Vesely
...              :contact: aleksandra.vesely@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Variables    ta5g_global_var
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_basic.cfg
${SCFC}=    scfc_sunny_day_before_step_1.xml
${DELTA}=    delta_6733_sunny_day.json
${DELTA_FOR_DEACTIVATION}=    delta_6733_deactivation.json
${UE_ID}=                  4
${PCELL_ID}=               4
${GNB_ID}=                 2
${PHYSCELL_ID}=            54
${PDU_PCELL_1}=            1
${GW_ID}=                  1
${PDU_2}=                  2  #Second session for UE=4 after feature deactivation
${GW_ID_2}=                2
${COUNTER_ID}=             M55118C00030
${COUNTER_NAME}=           A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4


*** Test Cases ***
CB006733-A_B1_B2_Activation_of_CB006733_A4_based_NR_FR1_SCell_addition_in_the_gNB_and_A4_measurements_for_SCell_addition_after_ICS
    Activate feature 6733
    Attach UE And Verify Establishing PDU Session With A4 Configuration    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify that UEContextModificationRequest_3 of 3 contains measConfig with A4 configuration for gNB2
    Verify in UECtxModResp_3 out of 3 that measGapConfigIE is present for gNB2
    Verify 6733 Activation Message Contents    ue_id=${UE_ID}
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_PCELL_1}
    Deactivate feature 6733
    Attach UE And Verify Establishing PDU Session After Deactivation    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_2}    gw_id=${GW_ID_2}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_2}
