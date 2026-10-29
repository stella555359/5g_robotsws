# *** Settings ***
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND    Suite Teardown
# 
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# #Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    Resources/CB011206_common_keywords.robot
# 
# 
# Documentation
# ...    Author:Guo Zhenzhen
# ...    contact:zhenzhen.guo@nokia-sbell.com
# ...    squad group:mmw_SG_03
# ...    Feature CB011206
# 
# *** Variables ***
# ${download_dir}    /tmp
# ${TS_CASE_LOG_PATH}    /tmp 
# ${M40003C0_1}    51752
# ${M40003C2}      8272
# ${M40003C3_5}    330359
# ${M40004C0}      9670
# ${M40004C1_3}    386334
# ${M40004C4_5}    52136
# 
# *** Test Cases ***
# [1]CB011206_03_Enable_embedded_power_meter_for_Pulsar_radio_with_RF_locked_unlocked_loops
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     #...    AND    Scf commition and wair for on-air    scf_name=${scf_path}/${8T8R_scf_name}
#     Run Keyword And Ignore Error    Verify all cells should be onair    connection=GNB_OAM	
#     Selenium Login And Disable Screen Lock    download_dir=/tmp
#     Perform RU Reset repetition via WebEM     repitition_num=10
#     Perform RU lock unlock repetition via WebEM    repitition_num=10
#     Selenium Logout And Close Browser
#     Selenium Login And Disable Screen Lock    download_dir=/tmp
#     Get and Check real time measurements    interval=1min
#     Wait for New Interval BTS counters Generate    interval=15min    
#     Check BTS Counter M40004C    interval=15min
#     Check BTS Counter M40002C   interval=15min
#     Check BTS Counter M40003C    interval=15min
#     CB011206_common_keywords.Collect snapshot log
#     Get snapshot and check energy consumption counter
#     Delete snapshot     ${local_file_path}   ${unzipped}
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 	
# 
