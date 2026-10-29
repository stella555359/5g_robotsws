*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marek Kocela
...              :contact: marek.kocela@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/traffic.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB011081.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_booloo.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create SA Aliases    ue_id=${UE_ID_5CC}    gNB_id=${GNB_ID}
...            AND             Create UE Alias    alias=UE${UE_ID_6CC}    ue_id=${UE_ID_6CC}    id_type=wts_5g
...            AND             Wait For Next Full Pm Interval

Test Teardown    Run Keywords    Release UE    ue_id=${UE_ID_5CC}    pdu_id=${PDU_ID}
...              AND    Release UE    ue_id=${UE_ID_6CC}    pdu_id=${PDU_ID}
...              AND    Add Scout Data Info To Testcase

*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_basic.cfg
${scfc}=              full_scfc_CB006733_ab1_ab3.xml

${SOURCE_CELL_ID}=    3
${GNB_ID}=    2
${PDU_ID}=    3
${GW_ID}=    3

${UE_ID_5CC}=    30
${UE_ID_6CC}=    3

@{COUNTER_IDs_PCELL_P1}=    M55138C03504    M55138C03507    M55139C03003    M55139C03006    M55118C00001    M55118C00004    M55156C00027
...    M55316C05005
@{COUNTER_NAMEs_PCELL_P1}=    GNB_SCELL_5_ADMI_REQ_SA    GNB_SCELL_5_ADMI_SUCC_SA    GNB_DU_SCELL_5_ADMI_REQ_SA    GNB_DU_SCELL_5_ADMI_SUCC_SA
...    RRC_RECONF_ADD5DLSCELL_ATT_SA    RRC_RECONF_ADD5DLSCELL_SUCC_SA    MAX_UE_PCELL_5_CONF_SCEL_DL_SA    MAX_PSCELL_UE_5_ACT_SCELL_DL

@{COUNTER_IDs_PCELL_P2}=    M55118C00013    M55118C10005    M55316C03005    M55316C04001    M55118C10001    M55118C10002    M55316C06001
@{COUNTER_NAMEs_PCELL_P2}=    UE_PCELL_5_CONF_SCELL_DL_SA    UE_PCELL_1_CONF_SCELL_UL_SA    PSCELL_UE_5_ACT_SCELL_DL    PSCELL_UE_1_ACT_SCELL_UL
...    RRC_RECONF_ADD1ULSCELL_ATT_SA    RRC_RECONF_ADD1ULSCELL_SUCC_SA    MAX_PSCELL_UE_1_ACT_SCELL_UL

@{COUNTER_ID_SCELL_6}=    M55118C10006
@{COUNTER_NAME_SCELL_6}=    UE_SCELL_5_CONF_SCELL_DL_SA

@{COUNTER_ID_SCELLs}=    M55118C00018
@{COUNTER_NAME_SCELLs}=    UE_SCELL_1_CONF_SCELL_UL_SA

${LOCAL_MOID_PCELL}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${LOCAL_MOID_SCELL_2}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${LOCAL_MOID_SCELL_4}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${LOCAL_MOID_SCELL_5}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
${LOCAL_MOID_SCELL_6}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
${LOCAL_MOID_SCELL_7}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
@{ALL_SCELL_MOID}=    ${LOCAL_MOID_SCELL_2}    ${LOCAL_MOID_SCELL_4}    ${LOCAL_MOID_SCELL_5}    ${LOCAL_MOID_SCELL_6}    ${LOCAL_MOID_SCELL_7}

${NR_CELL_IDENTITY_2}=    '0b000000000000000000000100000000000010'
${NR_CELL_IDENTITY_4}=    '0b000000000000000000000100000000000100'
${NR_CELL_IDENTITY_5}=    '0b000000000000000000000100000000000101'
${NR_CELL_IDENTITY_6}=    '0b000000000000000000000100000000000110'
${NR_CELL_IDENTITY_7}=    '0b000000000000000000000100000000000111'
@{5CC_NR_CELL_IDENTITIY}=    ${NR_CELL_IDENTITY_2}    ${NR_CELL_IDENTITY_5}    ${NR_CELL_IDENTITY_6}    ${NR_CELL_IDENTITY_7}
@{6CC_NR_CELL_IDENTITIY}=    ${NR_CELL_IDENTITY_2}    ${NR_CELL_IDENTITY_4}    ${NR_CELL_IDENTITY_5}    ${NR_CELL_IDENTITY_6}    ${NR_CELL_IDENTITY_7}

${SCELL_PHYSCELL_ID_2}=    52
${SCELL_PHYSCELL_ID_4}=    54
${SCELL_PHYSCELL_ID_5}=    55
${SCELL_PHYSCELL_ID_6}=    56
${SCELL_PHYSCELL_ID_7}=    57
@{5CC_SCELL_PHYSCELL_ID}=    ${SCELL_PHYSCELL_ID_2}    ${SCELL_PHYSCELL_ID_5}    ${SCELL_PHYSCELL_ID_6}    ${SCELL_PHYSCELL_ID_7}
@{6CC_SCELL_PHYSCELL_ID}=    ${SCELL_PHYSCELL_ID_2}    ${SCELL_PHYSCELL_ID_4}    ${SCELL_PHYSCELL_ID_5}    ${SCELL_PHYSCELL_ID_6}
...    ${SCELL_PHYSCELL_ID_7}
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB011081_AB1_AB3_activation_deactivation_and_blind_SCell_addition_6CC_DL_2CC_UL
    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE_ID_5CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE_ID_5CC}    cell_id=${SOURCE_CELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Activate Feature CB011081
    Expect SCell ToBeSetupMod And ToAddModList   ue_id=${UE_ID_6CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE_ID_6CC}    cell_id=${SOURCE_CELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Start Specific Data DL Traffic    ue_id=${UE_ID_6CC}   pdu_id=${PDU_ID}
    Verify SCell Addition Messages For 5CC    ue_id=${UE_ID_5CC}    5cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY}
    ...    5cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID}
    Release UE    ue_id=${UE_ID_5CC}    pdu_id=${PDU_ID}
    Deactivate Feature CB011081
    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE_ID_5CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE_ID_5CC}    cell_id=${SOURCE_CELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify DL Traffic Is Scheduled On All Cells   ue_id=${UE_ID_6CC}
    Stop DL and UL traffic on PDU for UE    ue_id=${UE_ID_6CC}    pdu_id=${PDU_ID}
    Verify SCell Addition Messages For 5CC    ue_id=${UE_ID_5CC}    5cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY}
    ...    5cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID}
    Verify SCell Addition Messages For 6CC    ue_id=${UE_ID_6CC}    6cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY}
    ...    6cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID}
    Verify Pm Counters AB1 AB3


*** Keywords ***
Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
