*** Settings ***
Documentation     author: wuxia
...               contact: xia.wu@nokia-sbell.com
...               squad group: MMW_SG3

Test Timeout    1000 min

Resource    ./Resources/CB010564_Common_Keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T904
#${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}/CB010564
${scf_file}    904_SCF.xml

*** Test Cases ***
[1]CB010564_A_06_CPRI_non_CBRS_LTE_NR_RU_power_off
    [Documentation]    RU Lock Reset Unlock for 2 times
    [Setup]    Case Setup
    [Teardown]    Case Teardown
    Run Keyword and Continue on Failure    RU Lock Reset Unlock for 2 times



