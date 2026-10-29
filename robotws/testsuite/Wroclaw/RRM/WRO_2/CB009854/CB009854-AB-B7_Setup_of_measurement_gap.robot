*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation    :copyright: Nokia
...              :authors: Aleksandra Vesely, Malgorzata Muth
...              :contact: aleksandra.vesely@nokia.com, malgorzata.muth@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB009854_keywords.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_testline_management
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Variables    CB009854_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_9854.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}
...            AND             Create gNB Alias
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${False}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${scfc}=              CB009854-AB-B7.xml
${BASIC_SETUP}=       ${CURDIR}/config/wts_9854_basic.cfg
${GNB_ID}=            2
${PCELL_ID}=          3
${PHYSCELL_ID}=       53
${UE_ID}=             3
${PDU_PCELL_1}=       3
${GW_ID}=             3
${TIMEOUT}=           240
${EVENT_TYPE_A2}=     EventA2
&{A2_RSRP_60}=        Threshold=RSRP 60
@{FREQUENCIES_A2}=    125070
${OVERALL_TIMEOUT}=   60
${TIMER_LENGTH}=      20

*** Test Cases ***
CB009854-AB-B7a_Setup_of_measurement_gap_for_UE_configured_with_5CC_DL_CA_with_3_FDD_and_2_TDD_serving_cells

    Attach UE And Verify Establishing PDU Session And DRX Setup With Blind SCell Addition    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify 5CC FFTTT Blind SCell Addition Message Contents    ue_id=${UE_ID}
    Verify Measurements Are Configured At UE    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A2}
    ...    event_params=${A2_RSRP_60}    frequencies=${FREQUENCIES_A2}
    Trigger A2 Measurement For A1 A3 A5 Measurements Configuration    ue_id=${UE_ID}    gNB_id=${GNB_ID}    overall_timeout=${OVERALL_TIMEOUT}
    Verify 5CC FFTTT Measurement Configuration and Meas Gap Setup After A2    ue_id=${UE_ID}
    Verify DRX Release After A2    ue_id=${UE_ID}
    Release UE
