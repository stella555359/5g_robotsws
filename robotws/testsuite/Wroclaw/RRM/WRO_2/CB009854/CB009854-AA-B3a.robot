*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

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
Resource     CB009854_keywords.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    ta5g_global_var
Variables    CB009854_messaging_filters.py
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_9854.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}
...            AND             Create gNB Alias


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_9854_basic.cfg
${scfc}=              CB009854-AA-B3a.xml
${GNB_ID}=            2
${PCELL_ID}=          3
${SCELL_1}=           1
${SCELL_2}=           4
${SCELL_3}=           5
${SCELL_4}=           6
${PHYSCELL_ID}=       53
${UE_ID}=             3
${PDU_PCELL_1}=       3
${GW_ID}=             3

*** Test Cases ***
CB009854-AA-B3a_3T2F_Blind_5CC_SCell_Addition_with_weight-based_SCell_selection_with_uniformly_weighted_SCells

    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify 5CC DL And 2CC UL FFTTT Blind SCell Addition Message Contents    ue_id=${UE_ID}
    Start Data Traffic
    Verify Traffic Is Scheduled On All Cells 5CC DL And 2CC UL
    Verify 5CC CA Counters    scell_1=${SCELL_1}    scell_2=${SCELL_2}    scell_3=${SCELL_3}     scell_4=${SCELL_4}
    ...    pcell=${PCELL_ID}
    Release UE

*** Keywords ***
Verify Traffic Is Scheduled On All Cells 5CC DL And 2CC UL
    Verify DL Traffic Is Scheduled On All Cells 5CC
    Sleep    10s
    Verify UL Traffic Is Scheduled On All Cells 2CC

Verify 5CC CA Counters
    [Arguments]    ${scell_1}    ${scell_2}    ${scell_3}    ${scell_4}    ${pcell}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C10005    >0    UE_PCELL_1_CONF_SCELL_UL_SA
    ...    M55316C03004    >0    PSCELL_UE_4_ACT_SCELL_DL
    ...    M55118C10001    1    RRC_RECONF_ADD1ULSCELL_ATT_SA
    ...    M55118C10002    1    RRC_RECONF_ADD1ULSCELL_SUCC_SA
    ...    M55138C00048    1    GNB_SCELL_4_ADMI_REQ_SA
    ...    M55138C00049    1    GNB_SCELL_4_ADMI_SUCC_SA
    ...    M55139C00023    1    GNB_DU_SCELL_4_ADMI_REQ_SA
    ...    M55139C00024    1    GNB_DU_SCELL_4_ADMI_SUCC_SA
    ...    M55118C02014    1    RRC_RECONF_ADD4DLSCELL_SUCC_SA
    ...    M55118C02015    1    RRC_RECONF_ADD4DLSCELL_ATT_SA
    ...    M55118C02016    >0    UE_PCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_1}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_2}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_3}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C10006    >0    UE_SCELL_1_CONF_SCELL_UL_SA
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_4}
    ...    file_path=${pm_counter_file}
