*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BLLL_AP_LOO    VARIANT_PRIVATE_SANSA_FS_ECPRI_CMWV_FDD_2CELLS

Documentation    :copyright: Nokia

Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Resource     ../keywords/logging.robot
Library     Keywords5GC001167.py
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging

Suite Setup       Prepare Test Environement And Reach Onair With Retry
    ...				iphy_xml=${CURDIR}/config/5GC001167-A3/iphy_3CC_n66.xml
    ...				scfc=fdd_3CC_n66_Intra_HO.xml
    ...             egate_cfg=${TS_CONFIG_DIR}/basic_fs_sa_call_fdd_cmwv_3CC_n66_non_continuous_1ue.cfg
    ...             cell_number=3
    ...             disablel1bypass=False
Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TS_CONFIG_DIR}=    ${CURDIR}/config/5GC001167-A3/5GC001167_A3_I_IntraBand_HO_NonCA_CA
${LOGGING_POLICY}=    FULL_POLICY

*** Test Cases ***
5GC001167_A3_i_3CC_IntraBand_CA_HO_From_PCell_To_SCell_Without_NRRels_Config_Drop_Of_CA_Then_HO_To_Third_Cell_Reconfig_Of_3CC_CA
    Attach UE With Scell Configuration    ue_id=1    pdu_id=1    gw_id=1    nwslice=1  # o
    Verify ICS On NGAP
    Verify Successful Reconfiguration    packet_filter=${F1AP_RECONFIGURE_TO_3CC_SCELLS_B_C}
    Perform UE Handover    ue_id=1    a2_meas_id=1    a3_meas_id=3    phycell_id=51
    Verify If SCells B And C Are Released After HO
    Perform UE Handover    ue_id=1    a2_meas_id=4    a3_meas_id=6    phycell_id=52
    Verify HO Without CA
    Verify Successful Reconfiguration    packet_filter=${F1AP_RECONFIGURE_TO_3CC_SCELLS_A_B}
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1
        ...            AND          Add Scout External Execution ID To Reporting Portal

