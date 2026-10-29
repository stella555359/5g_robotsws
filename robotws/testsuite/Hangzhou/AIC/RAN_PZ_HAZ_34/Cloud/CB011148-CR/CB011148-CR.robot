*** Settings ***
Documentation
...   author: kaihui.fan@nokia-sbell.com
...   contact: tingting.zhong@nokia-sbell.com
...   update: jie.2.li@nokia-sbell.com Activate collect ru logs: https://jiradc.ext.net.nokia.com/browse/LEOPARD-2126

Suite Setup         Cloud Suite Setup
Suite Teardown      Cloud Suite Teardown
Test Setup          run keywords    robot_common_operations.common case setup    fail_with_alarms=${False}    AND    Cloud Test Setup
Test Teardown       run keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

Force Tags
...    PY39
...    CLOUD_5G_AIC                               #TL_TYPE
...    STATE_ON_AIR                               #gNB_STATE
...    5G_RAN                                     #CA
...    master_allincloud_int                      #vDU_Branch_name
...    RAN_RD_VRF_HAZ4                            #Orginazation
...    TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT         #Detailed Automation Level

Test Timeout    90 minutes

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB011148-CR_02_AVQC_1S1CC_4D4U_different Capture type select_RF scan test with full mode in online mode
    [Tags]    RF50
    Cloud_General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode
