*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    QC_350553    QCD_MN_RAN    QCP_RAN_ET

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     CB005934_keywords.robot
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Variables    CB005934_messaging_filters.py
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

${iphy}=    ${CURDIR}/config/iphy_AP_LOO_AHFII_AHFIB_AEQE_AHFII_gnb_ABIO_4FDD_2TDD.xml
${scfc}=    scf_gNB_BOO_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.xml
${wts_config}=    ${CURDIR}/config/wts_4cells_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.cfg

@{UE_IDs}=     1    10    11
@{PDU_IDs}=    1    2     3
@{GW_IDs}=     1    10    11
${PCELL_ID}=    1
${GNB_ID}=    2
${A1_MEAS_ID}=    1

${SRSRP_NR}=    90
&{A1_RSRP}=    Threshold=RSRP 70
@{A1_FREQUENCIES}=    389570


*** Test Cases ***
CB005934-SR-B-B1_Multiple_UEs_Call-Setup_4CC_FDD_DL_CA
    Attach Multiple UEs And Verify Establishing PDU Sessions    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    ...    gw_ids=${GW_IDs}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}

    Verify A1 Measurements Are Configured At Multiple UEs    ue_ids=${UE_IDs}
    ...    a1_event_params=${A1_RSRP}    a1_frequencies=${A1_FREQUENCIES}
    Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs    gnb_id=${GNB_ID}
    ...    ue_ids=${UE_IDs}    meas_id=${A1_MEAS_ID}    srsrp_nr=${SRSRP_NR}
    Verify SCell Addition Messages Content After A1 Event Trigger For Multiple UEs    ue_ids=${UE_IDs}

    Start Data Traffic For Multiple UEs    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    Verify Traffic on PCell and All SCells For Multiple UEs    ue_ids=${UE_IDs}

    [Teardown]    Release Multiple UEs    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
