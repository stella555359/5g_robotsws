*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Resource     Keywords_CB011081.robot
Resource     Variables_CB011081.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var
Library      ta5g_ue_mobility


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy_booloo}
...            AND             Find Scfc And Fix And Send Full Commissioning    ${scfc_ab14_ab18}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs


*** Test Cases ***
CB011081-AB18_RRC_inactive_and_resume_with_DL_6CC_CA_UE
    Perform CB011081_AB18 UE Resume
    ...    UE_ID_6CC=${UE_ID_6CC}
    ...    SOURCE_CELL_ID=${SOURCE_CELL_ID}
    ...    GNB_ID=${GNB_ID}
    ...    cmd_ue_resume_configuration=${cmd_ue_resume_configuration}
    ...    PDU_ID=${PDU_ID}
    ...    GW_ID=${GW_ID}
    ...    A1_MEAS_ID=${A1_MEAS_ID}
    Verify Inactive UE State
    ...    rrc_resume_element=${rrc_resume_element}
    ...    rrc_resume_complete_element=${rrc_resume_complete_element}
    [Teardown]    Add Scout Data Info To Testcase

CB011081-AB14_SCell_Release_based_on_A2_SCell_measurement
    Trigger A2 Measurement    ue_id=${UE_ID_6CC}    meas_id=3    SCELL_INDEX=2
    Verify Scell Release    A2_meas_element=${A2_meas_element}    cell_release_after_A2=${cell_release_after_A2}
    [Teardown]    Add Scout Data Info To Testcase
