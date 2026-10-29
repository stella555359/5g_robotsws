*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    QC_350559    QCD_MN_RAN    QCP_RAN_ET

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Resource     CB005934_keywords.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Variables    CB005934_messaging_filters.py
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

${iphy}=    ${CURDIR}/config/iphy_AP_LOO_AHFII_AHFIB_AEQE_AHFII_gnb_ABIO_4FDD_2TDD.xml
${scfc}=    scf_gNB_BOO_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_A_B9.xml
${wts_config}=    ${CURDIR}/config/wts_4cells_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.cfg

${UE_ID}=    1
${PCELL_ID}=    1
${SCELL_TO_RELEASE}=    1
${GNB_ID}=    2
${PDU_ID}=    1
${GW_ID}=    1
${A1_MEAS_ID}=    1
${A2_MEAS_ID}=    2

${SRSRP_NR}=    90
${SCELL_RSRP}=    5
&{A2_RSRP}=    Threshold=RSRP 50
&{A1_RSRP}=    Threshold=RSRP 90
@{A2_FREQUENCIES}=    395090  430850  125070
@{A1_FREQUENCIES}=    389570

${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1


*** Test Cases ***
CB005934-SR-A-B9_Single_UE_Call-SCell_Release_based_on_A2-SCell_measurement_for_4CC_DL_CA_with_FDD_PCell_and_3_FDD_SCells
    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}

    Trigger A1 Measurement    ue_id=${UE_ID}    meas_id=${A1_MEAS_ID}    srsrp_nr=${SRSRP_NR}
    Verify A1 Measurement Removal And A2 Measurement Activation After A1 Event Trigger    ue_id=${UE_ID}
    ...    a2_event_params=${A2_RSRP}    a2_frequencies=${A2_FREQUENCIES}
    ...    a1_event_params=${A1_RSRP}    a1_frequencies=${A1_FREQUENCIES}

    Trigger A2 Measurement And Expect Measurements Configuration And SCell Release Messages Flow    gnb_id=${GNB_ID}
    ...    ue_id=${UE_ID}     meas_id=${A2_MEAS_ID}    scell_id=${SCELL_TO_RELEASE}    scell_rsrp=${SCELL_RSRP}
    Verify SCell Release Based On A2 Measurement Messages Content After A2 Event Trigger    ue_id=${UE_ID}

    Verify Pm Counters After SCell Release    local_moid=${LOCAL_MOID}

    [Teardown]    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
