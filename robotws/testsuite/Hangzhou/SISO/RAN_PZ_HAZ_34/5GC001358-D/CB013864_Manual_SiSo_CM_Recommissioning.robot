*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03

Suite Setup    CI_interface.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Test Timeout    1000 min

Resource    Resources/TL924_Robust_Common_Keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot




*** Variables ***
${testline_name}    7_5_UTE5G402T2065
${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}


*** Test Cases ***

[1][2.0] Manual_SiSo_CM_Recommissioning
    [Tags]    HAZ3_T03
    [Setup]    Test Case setup
    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    [Teardown]    Test Case teardown

[1][1.0] General_SiSo_BB_sub-unit_lock_and_unlock_with_L3_call
    [Setup]    Test Case setup
    Run Keyword and Continue on Failure    BBMOD lock/unlock 1 times
    [Teardown]    Test Case teardown

[1][1.0] General_SiSo_BB_sub-unit_reset_with_L3_call
    [Setup]    Test Case setup
    Run Keyword and Continue on Failure    BBMOD reset 1 times
    [Teardown]    Test Case teardown

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Setup]    Test Case setup
    Run Keyword and Continue on Failure    Site reset 1 times
    [Teardown]    Test Case teardown

[1][1.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Setup]    Test Case setup
    Run Keyword and Continue on Failure    RU lock/unlock 1 times
    [Teardown]    Test Case teardown

[1][1.0] General_SiSo_Auto_RF_module_power_reset
    [Setup]    Test Case setup
    Run Keyword and Continue on Failure    RU reset 1 times
    [Teardown]    Test Case teardown


