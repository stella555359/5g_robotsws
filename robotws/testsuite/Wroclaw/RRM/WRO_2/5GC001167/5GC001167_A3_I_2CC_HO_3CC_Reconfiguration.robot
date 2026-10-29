*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BLLL_AP_LOO

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Resource     ../keywords/logging.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library     ta5g_pm_counters
Library     Keywords5GC001167.py
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging

Suite Setup       Prepare Test Environement And Reach Onair With Retry
    ...				iphy_xml=${TS_CONFIG_DIR}/ap/iphy_APoABIO.xml
    ...				scfc=scfc_3CC_n66_n5_n2_HO_Reconf_APoABIO.xml
    ...             egate_cfg=${TS_CONFIG_DIR}/basic_fs_sa_call_fdd_cmwv_3CC.cfg
    ...             cell_number=3
    ...             disablel1bypass=False

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}


*** Variables ***
${TS_CONFIG_DIR}=    ${CURDIR}/config/5GC001167-A3/5GC001167_A3_i_Reconfiguration_from_2CC_to_3CC_after_HO_interband_CA
${LOGGING_POLICY}=    FULL_POLICY

*** Test Cases ***
5GC001167_A3_i_Reconfiguration_From_2CC_To_3CC_After_HO_Interband_CA
    Change UE Cell Location      ue_id=1     cell_id=2
    Attach UE And Start Data Traffic    ue_id=1    cell_id=2
    Verify ICS On NGAP
    Verify Successful 2CC On NGAP And F1AP Messages
    Perform UE Handover    ue_id=1    a2_meas_id=1    a3_meas_id=5    phycell_id=50
    Verify If SCells C are Released After HO
    Verify Successful Reconfiguration    packet_filter=${F1AP_RECONFIGURE_TO_3CC_SCELLS_B_C}
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1


*** Keywords ***
Verify Successful 2CC On NGAP And F1AP Messages
    Verify Ngap Messages    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log      f1ap.SCell_ToBeSetupMod_List == 1 && f1ap.nRCellIdentity == 00:00:04:00:30
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_C_TO_ADD_MOD_LIST}   relation_symbol= >=
