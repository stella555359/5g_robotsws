*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova, Vira Solomashenko
...              :contact: palina.krasnova@nokia.com, vira.solomashenko@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Variables    ta5g_global_var

Suite Setup    Run Keywords    With Retry Context    3
...                            Update And Put Iphy Xml    input_filepath=${iphy}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${wts_config}
...            AND             Wait For Next Full Pm Interval

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY

${iphy}=    ${CURDIR}/config/iphy_xml_6733.xml
${scfc}=    scf_gNB_CB006733_B_B6_RRC_reestablishment.xml
${wts_config}=    ${CURDIR}/config/wts_6733_basic.cfg

${UE_ID}=    1
${SOURCE_CELL_ID}=    1
${TARGET_CELL_ID}=    4
${GNB_ID}=    2
${PDU_ID}=    1
${GW_ID}=    1
${SOURCE_PHY_CELL_ID}=    51

${A4_RETRY_TIMER}=    5

${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4

*** Test Cases ***
CB006733-B_B6_Activate_A4_measurements_for_FR1_CA_SCell_Addition_after_successful_RRC_Re-establishment
    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${SOURCE_CELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}

    Perform Ue Reestablishment And Verify RRC Reestablishment Request And A4 Measurements Are Not Activated
    ...    ue_id=${UE_ID}    gnb_id=${GNB_ID}    source_phy_cell_id=${SOURCE_PHY_CELL_ID}    target_cell_id=${TARGET_CELL_ID}
    Wait For A4 Retry Timer Expiration And Verify A4 Measurements Activation
    ...    a4_retry_timer=${A4_RETRY_TIMER}    ue_id=${UE_ID}    gnb_id=${GNB_ID}

    Verify Pm Counter For Number Of A4 Measurements Activations    local_moid=${LOCAL_MOID}

    [Teardown]    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
