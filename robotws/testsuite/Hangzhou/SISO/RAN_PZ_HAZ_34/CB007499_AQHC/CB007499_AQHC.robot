*** Settings ***
Documentation    This is for CB007499 AQHC regression

Suite Setup          SBTS Suite Setup
Suite Teardown       Suite Teardown
Test Setup           SBTS Test Setup
Test Teardown        SBTS Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_RU_module_reset_from_GUI_with_L3call.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_REC_Radio_Module_power_reset.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Peak_with_Given_Information.robot

Force Tags

*** Variables ***
${ssh_username}      ${tl.enbs[0].system_module.common_units[0].lmp_connection.username}
${ssh_password}      ${tl.enbs[0].system_module.common_units[0].lmp_connection.password}

*** Test Cases ***
[1]CB007499_SR_D_b_SISO_AQHC_03_General_SiSo_RU_module_reset_from_GUI
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _7499.xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    General_SiSo_RF_module_reset_from_GUI    dl_tp=128    ul_tp=14
    ...    target_avg_percent=0.8   min_percent=0.6    scf_path=${SCF_Path}


*** Keywords ***
Suite Teardown
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    Commissioning SCF And Check On Air for Common    scf_path=${Golden_SCF_Path}
    robot_common_operations.Common Suite Teardown
    log to console    \n***SBTS Suite Teardown***
    COAM Teardown gnb connections