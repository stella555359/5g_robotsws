# *** Settings ***
# Suite Setup     Suit setup for CB008294 E2E TMO MIX ROBOT
# Suite Teardown    CI_Common_Suit_Teardown
# 
# Documentation
# ...   author: pengliang.wu@nokia-sbell.com
# ...   contact: pengliang.wu@nokia-sbell.com
# ...   CB007835-5G-B-SyVe_Key_customer_scenario_testing_for-KDDI-E2E_Sleeping_Cell_Cases
# 
# Resource    ./resources/common_keywords.robot
# Resource    ../CB007835_B_NEW/resources/common_keywords.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009467_TL750/resources/CB010600_common_keyword.robot
# Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009467_TL750/resources/CB010600_common_keyword.py
# 
# *** Variables ***
# ${testline_name}
# ${target_version}
# ${test_iteration}       ${1}   #testing numbers
# @{AWGUD_Lcrid}        401    402    403    404
# 
# *** Test Cases ***
# TC003_CB008294_-4CCDL_4CCUL_contiguous_FR2_Cell_block_unblock
#     [Tags]    UTE    TRUNK
#     [Documentation]
#     ...    -pengliang.wu@nokia-sbell.com
#     [Setup]    Common case setup
#     ${DLtput}  Set Variable    ${2000}
#     ${ULtput}  Set Variable    ${525}
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR cell block and unblock start..
#         ${result}    Run Keyword And Return Status    Separately CELL block unblock    if_given=${True}
#         ...    given_cell_list=${AWGUD_Lcrid}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    common_keywords.Save Snapshot Log
#         Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}
#         ...    dl_tp=${DLtput}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# TC001_CB008294_4CCDL_4CCUL_contiguous_UL_DL_data_Peak
#     [Tags]    UTE    TRUNK
#     [Documentation]
#     ...    -pengliang.wu@nokia-sbell.com
#     [Setup]    Common case setup
#     ${DLtput}  Set Variable    ${2000}
#     ${ULtput}  Set Variable    ${525}
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         ${result}    Run Keyword And Return Status    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}
#         ...    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}    dl_tp=${DLtput}
#         ...    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    common_keywords.Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# TC002_CB008294_4CCDL_4CCUL_contiguous_online_modification_4CCDL_2CCUL
#     [Tags]    UTE    TRUNK
#     [Documentation]
#     ...    -pengliang.wu@nokia-sbell.com
#     [Setup]    Common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         ${DLtput}  Set Variable    ${2000}
#         ${ULtput}  Set Variable    ${260}
#         modify parameters online    input_list=${MODIFY_Parameter_for_maxNumScellsUlFr2SA_2CCUL}
#         Log to console    Sleep 20s
#         sleep    20s
#         ${result}    Run Keyword And Return Status    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}
#         ...    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}    dl_tp=${DLtput}
#         ...    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    common_keywords.Save Snapshot Log
#         ${DLtput}  Set Variable    ${2000}
#         ${ULtput}  Set Variable    ${525}
#         modify parameters online    input_list=${MODIFY_Parameter_for_maxNumScellsUlFr2SA_4CCUL}
#         Log to console    Sleep 20s
#         sleep    20s
#         ${result}    Run Keyword And Return Status    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}
#         ...    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}    dl_tp=${DLtput}
#         ...    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    common_keywords.Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Suit setup for CB008294 E2E TMO MIX ROBOT
#     CI_Common_Suit_Setup
#     common_keywords.Adapt to ute cloud commission scf
#     Select and setup gNB Commission SCF
#     Get SBTS Release Version
# 
# Common case setup
#     Check BTS Should Be Normal
#     Check Alarm after OAM opraetion
#     robot_common_operations.Common case Setup
# 
# modify parameters online
#     [Arguments]    ${input_list}=${EMPTY}    ${connection}=GNB_OAM_3
#     Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
#     Modify BTS Parameters with json    input_list=${input_list}    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
