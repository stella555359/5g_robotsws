*** Settings ***
Documentation
...   author: shifu.lan@nokia-sbell.com
...   contact: shifu.lan@nokia-sbell.com

Suite Setup         Cloud Suite Setup
Suite Teardown      Cloud Suite Teardown
Test Setup          Cloud Test Setup
Test Teardown       Cloud Test Teardown
Test Timeout        90 minutes

Library    String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/General_SiSo_RU_module_reset_from_GUI_Cloud.robot

*** Variables ***

*** Test Cases ***
[1]CB010889-CR-A_General_SiSo_RU_module_reset_from_GUI
    [Tags]    RF50
    General_SiSo_RU_module_reset_from_GUI   with_call=${True}
