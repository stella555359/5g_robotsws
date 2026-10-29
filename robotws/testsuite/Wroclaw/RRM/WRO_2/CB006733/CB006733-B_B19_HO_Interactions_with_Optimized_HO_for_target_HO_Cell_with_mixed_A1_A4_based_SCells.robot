*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Variables    ta5g_global_var

Suite Setup    Run Keywords    With Retry Context    3
...                            Update And Put Iphy Xml    input_filepath=${iphy}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${wts_config}

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY

${iphy}=    ${CURDIR}/config/iphy_xml_6733.xml
${scfc}=    scf_gNB_CB006733_B_B19.xml
${wts_config}=    ${CURDIR}/config/wts_6733_B_B19.cfg

${UE_ID}=    4
${SOURCE_CELL_ID}=    4
${TARGET_CELL_ID}=    2
${GNB_ID}=    2
${PDU_ID}=    4
${GW_ID}=    4
${SOURCE_PHY_CELL_ID}=    54
${TARGET_PHY_CELL_ID}=    52
${SCELL_PHY_CELL_ID_BEFORE_HO}=    52
${SCELL_PHY_CELL_ID_AFTER_HO}=    53

${A1_MEAS_ID}=    1
${A2_MEAS_ID}=    3

${A1_SRSRP_NR}=    90
${A1_SRSRQ_NR}=    95

${A2_CMD}=
...    id=${UE_ID} meas_id=3 event=A2 srsrp_nr=5 srsrq_nr=10
...    scell=1 scell_rsrp=90 scell_rsrq=90

*** Test Cases ***
CB006733-B_B19_HO_Interactions_with_Optimized_HO_for_target_HO_Cell_with_mixed_A1_A4_based_SCells
    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${SOURCE_CELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}

    Trigger A1 Measurement And Start High DL non-GBR Data Traffic To SCell Addition    ue_id=${UE_ID}    A1_meas_id=${A1_MEAS_ID}    pdu_id=${PDU_ID}
    ...    gnb_id=${GNB_ID}    srsrp_nr=${A1_SRSRP_NR}    srsrq_nr=${A1_SRSRQ_NR}
    ...    scell_phy_cell_id=${SCELL_PHY_CELL_ID_BEFORE_HO}

    Trigger A2 Measurement For PCell Change And Start High DL non-GBR Data Traffic To SCell Addition    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    ...    A2_cmd=${A2_CMD}    A2_meas_id=${A2_MEAS_ID}    pdu_id=${PDU_ID}    scell_phy_cell_id=${SCELL_PHY_CELL_ID_AFTER_HO}
    ...    source_phy_cell_id=${SOURCE_PHY_CELL_ID}    target_phy_cell_id=${TARGET_PHY_CELL_ID}

    [Teardown]    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
