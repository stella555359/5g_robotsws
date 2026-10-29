*** Settings ***
Documentation    Test Suite with automated TC for Zaraza TL.

Resource    ../Resources/cloud_frame.robot
Resource    ../Tests/HA/CB007800_B_CB007406_C_Cloud_CPConfig_Noncritical_Process_Container_Loop_Failure.robot
Resource    ../Tests/HA/CB007800_B_CB007406_C_Cloud_Oamagent_Critical_Container_Failure.robot
Resource    ../Tests/HA/OAM__CLOUD_Master_SLD_Pod_Recovery_After_Pod_Failure_CB007467_E.robot
Resource    ../Tests/HA/OAM__vDU_RU_HW_Detection_After_Reboot__5GC001662-E.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

Test Setup       TC Setup
Test Teardown    TC Teardown

Force Tags    RF50    QCP_RAN_VRF    QCD_MN_RAN

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8693/__init__.py

*** Test Cases ***
CB007800_B_CB007406_C_Cloud_Oamagent_Critical_Container_Failure
    [Setup]    Run Keywords
     ...    Set Library Search Order    CB007800_B_CB007406_C_Cloud_Oamagent_Critical_Container_Failure
     ...    AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    240min
    [Tags]       RF50    CB007800_B_CB007406_C
    Run Keyword If    '${SW_INFO}[vDU][release]'=='26R2'    Set Tags    QC_75769
    CB007800_B_CB007406_C_Cloud_Oamagent_Critical_Container_Failure

TC__CB007800_B_CB007406_C_Cloud_CPConfig_Noncritical_Process_Container_Loop_Failure
    [Setup]    Run Keywords
     ...    Set Library Search Order    TC__CB007800_B_CB007406_C_Cloud_CPConfig_Noncritical_Process_Container_Loop_Failure
     ...    AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    240min
    [Tags]       RF50    CB007800_B_CB007406_C
    Run Keyword If    '${SW_INFO}[vDU][release]'=='26R2'    Set Tags    QC_75770
    TC__CB007800_B_CB007406_C_Cloud_CPConfig_Noncritical_Process_Container_Loop_Failure

OAM__vDU_RU_HW_Detection_After_Reboot__5GC001662-E
    [Setup]    Run Keywords
     ...    Set Library Search Order    OAM__vDU_RU_HW_Detection_After_Reboot__5GC001662-E
     ...    AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    240min
    [Tags]       RF50    5GC001662-E
    Run Keyword If    '${SW_INFO}[vDU][release]'=='26R2'    Set Tags    QC_75721
    OAM__vDU_RU_HW_Detection_After_Reboot__5GC001662-E

OAM__CLOUD_Master_SLD_Pod_Recovery_After_Pod_Failure_CB007467_E
    [Setup]    Run Keywords
     ...    Set Library Search Order    OAM__CLOUD_Master_SLD_Pod_Recovery_After_Pod_Failure_CB007467_E
     ...    AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    240min
    [Tags]       RF50    CB007467_E
    Run Keyword If    '${SW_INFO}[vDU][release]'=='26R2'    Set Tags    QC_275841
    OAM__CLOUD_Master_SLD_Pod_Recovery_After_Pod_Failure_CB007467_E
