*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Malgorzata Muth
...              :contact: malgorzata.muth@nokia.com


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
Library      ta5g_ue_mobility
Variables    ta5g_global_var
Variables    CB005934_messaging_filters.py
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_5934-a-b7.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_5934-a-b7.cfg
${scfc}=    CB005934_A_B7_PCell_change.xml
${UE_ID}=                  1
${PCELL_ID}=               1
${PCELL_ID_2}=             4
${GNB_ID}=                 2
${PHYSCELL_ID}=            51
${PDU_PCELL_1}=            1
${GW_ID}=                  1
${A2_MEAS_ID}=             2
${A2_cmd}=
...    id=${UE_ID} meas_id=2 event=A2 srsrp_nr=20 srsrq_nr=60
...    scell=1 scell_rsrp=70 scell_rsrq=60
...    scell=2 scell_rsrp=10 scell_rsrq=60
...    scell=3 scell_rsrp=50 scell_rsrq=60

*** Test Cases ***
CB005934-SR-A-B7_A2_event_measurement_triggered_PCell_change_for_SA_call_with_4CC_DL_CA_with_FDD_PCell_and_3_FDD_SCells

    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify A1 Measurement Configuration   ue_id=${UE_ID}
    Trigger A1 Based SCell Addition    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Verify 4CC FFFF SCell Addition For PCell Change Message Contents    ue_id=${UE_ID}
    Trigger A2 Based PCell Change    ue_id=${UE_ID}    gnb_id=${GNB_ID}    A2_cmd=${A2_cmd}
    Verify Successful PCell Change And SCells Release    ue_id=${UE_ID}
    Trigger A1 Measurement To Verify CA Successful    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Verify Successful CA After A2    ue_id=${UE_ID}
    Verify PCell Change Counters for PCell_1 and PCell_2    pcell=${PCELL_ID}    pcell_2=${PCELL_ID_2}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_PCELL_1}
