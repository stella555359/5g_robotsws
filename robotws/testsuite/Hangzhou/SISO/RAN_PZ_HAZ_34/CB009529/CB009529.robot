# *** Settings ***
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND    Suite Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    Resources/CB009529_common_keywords.robot
# 
# 
# Documentation
# ...    Author:Guo Zhenzhen
# ...    contact:zhenzhen.guo@nokia-sbell.com
# ...    squad group:mmw_SG_03
# ...    Feature CB009529
# 
# *** Variables ***
# ${download_dir}    /tmp
# ${TS_CASE_LOG_PATH}    /tmp 
# ${M40003C0_1}    52442
# ${M40003C2}      4643
# ${M40003C3_5}    185140
# ${M40004C0}      3291
# ${M40004C1_3}    127173
# ${M40004C4_5}    52638
# ${M40028C0}      1594
# ${M40028C0_2}    1455
# ${M40028C2}      64163
# ${M40028C2_2}    58329
# ${btsid}    ${tl.gnbs[0].global_bts_id}
# ${btsname}    TL${tl.gnbs[0].global_bts_id}
# ${28C0_Primary_path}    EQM-1/APEQM-1/CABINET-1/BBMOD-1/SBTS_BBMOD_Energy_Monitoring/BBMOD_CAP_ENERGY_CONSUMPTION
# ${28C0_Primary_full_path}    [${btsname}] MRBTS-${btsid}/${28C0_Primary_path}
# ${28C0_Secondary_path}    EQM-1/APEQM-1/CABINET-1/BBMOD-2/SBTS_BBMOD_Energy_Monitoring/BBMOD_CAP_ENERGY_CONSUMPTION
# ${28C0_Secondary_full_path}    [${btsname}] MRBTS-${btsid}/${28C0_Secondary_path}
# ${28C2_Primary_path}    EQM-1/APEQM-1/CABINET-1/BBMOD-1/SBTS_BBMOD_Energy_Monitoring/BBMOD_CAP_AVG_PWR_USAGE
# ${28C2_Primary_full_path}    [${btsname}] MRBTS-${btsid}/${28C2_Primary_path}
# ${28C2_Secondary_path}    EQM-1/APEQM-1/CABINET-1/BBMOD-2/SBTS_BBMOD_Energy_Monitoring/BBMOD_CAP_AVG_PWR_USAGE
# ${28C2_Secondary_full_path}    [${btsname}] MRBTS-${btsid}/${28C2_Secondary_path}
# 
# *** Test Cases ***
# [1]CB009529-A_01_Measurement_and_report_the_energy_consumption_for_ABIP
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     #...    AND    Scf commition and wair for on-air    scf_name=${scf_path}/${8T8R_scf_name}
# 	Power meter Feature activation
# 	PM counter update enabled
#     Run Keyword And Ignore Error    Verify all cells should be onair    connection=GNB_OAM
#     Get and Check real time measurements    interval=1min
#     Wait for New Interval BTS counters Generate    interval=15min
# 	Check BTS Counter M40028C    interval=15min
#     Check BTS Counter M40004C    interval=15min
#     Check BTS Counter M40002C   interval=15min
#     run keyword and ignore error    Check BTS Counter M40003C    interval=15min
#     CB009529_common_keywords.Collect snapshot log
#     Get snapshot and check energy consumption counter
#     Delete snapshot     ${local_file_path}   ${unzipped}
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 	
# 
# [1]CB009529-A_02_Enable_embedded_power_meter_for_ABIP_with_Dual_core
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     Power meter Feature activation
# 	PM counter update enabled
#     Run Keyword And Ignore Error    Verify all cells should be onair    connection=GNB_OAM
#     Get and Check real time measurements for dual core   interval=1min
#     Wait for New Interval BTS counters Generate    interval=15min
# 	Check BTS Counter M40028C for dual core    interval=15min
