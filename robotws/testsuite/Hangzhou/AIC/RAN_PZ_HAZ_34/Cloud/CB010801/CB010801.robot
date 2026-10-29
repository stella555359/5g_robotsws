*** Settings ***
Documentation
...   author: shifu.lan@nokia-sbell.com
...   contact: shifu.lan@nokia-sbell.com
...   update: jie.2.li@nokia-sbell.com Activate collect ru logs: https://jiradc.ext.net.nokia.com/browse/LEOPARD-2126

Suite Setup         Cloud Suite Setup
Suite Teardown      Cloud Suite Teardown
Test Setup          Cloud Test Setup
Test Teardown       Cloud Test Teardown
Test Timeout        90 minutes

Library    String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/Cloud_Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB010801_CR_B_3CC_06_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    RF50
    [Setup]    Cloud Specific Setup
    Cloud_Manual_SiSo_SM_RF_Module_lock_unlock   with_call=${True}    duration=${300}
    [Teardown]    Run Keywords    Cloud Specific Teardown    AND    Cloud Test Teardown

*** Keywords ***
Cloud Specific Setup
    [Arguments]    ${cu_scf_name}=SCF_vCUCNF00_1S-3CC-4D4U.xml    ${vdu_scf_name}=SCF_vDUCNF00_1S-3CC-4D4U.xml
    robot_common_operations.common case setup    fail_with_alarms=${False}
    ${CB010801_CU_SCF_Path}    Replace String Using Regexp    ${Golden_CU_SCF_Path}    SCF_vCUCNF00.xml    ${cu_scf_name}
    ${CB010801_VDU_SCF_Path}    Replace String Using Regexp    ${Golden_VDU_SCF_Path}    SCF_vDUCNF00.xml    ${vdu_scf_name}
    Cloud Full Commission    cu_scf_path=${CB010801_CU_SCF_Path}    vdu_scf_path=${CB010801_VDU_SCF_Path}

Cloud Specific Teardown
    robot_common_operations.Common Case Teardown
    Cloud Full Commission    cu_scf_path=${Golden_CU_SCF_Path}    vdu_scf_path=${Golden_VDU_SCF_Path}
