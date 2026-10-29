# *** Settings ***
# Documentation
# ...  author:        Yang Di
# ...  contact:       di.yang@nokia-sbell.com
# ...  maintainer:    di.yang@nokia-sbell.com
# ...  Description:   This feature verifies the discard mechanism for PDCP SDUs with new NIDD parameters with
# ...                 TCP and UDP transmission check on COAM.
# 
# Resource        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002098/resources/keywords.robot
# Resource        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/setup_teardown.robot
# Resource        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/common_kw.robot
# Resource        ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# Force Tags    SBTS00    SBTS22R3    RAN_5G    CA_5G_RRM    RAN_5G_FDD_MP
# ...    PY36
# ...           RAN_5G_FDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB
# 
# #...  21A_classicalbts__WITH__CLOUD_5G_CLASSICAL_ANDROID_ATT_ASIKL_ABILB1_AHFIB_3xAHLOA_21A__WITH__CONFIGS_migration_WRO7_UTE5GCLOUDT151
# #...  20Bb1_classicalbts__WITH__CLOUD_5G_CLASSICAL_ANDROID_ATT_ASIKL_ABILB1_AHFIB_3xAHLOA_20B__WITH__CONFIGS_migration_WRO7_UTE5G286CLASS041
# #...  master_classicalbts_all__WITH__CLOUD_5G_CLASSICAL_ANDROID_ATT_ASIKL_ABILB1_AHFIB_3xAHLOA__WITH__CONFIGS_migration_WRO7_UTE5GCLOUDT161
# 
# Suite Setup         Run keywords
# ...                 robot_common_operations.Common Suite Setup    AND
# ...                 CI_interface.Common Suite Setup    AND
# ...                 Get BTS id and set as suite variable    AND
# ...                 Download SCF    AND
# ...                 Remove tmp btslog dir  AND
# ...                 Replace swconfig    feature=5GC002098
# 
# Suite Teardown      Run keywords    robot_common_operations.Common Suite Teardown
# #...                 Recommission to default
# 
# Test Setup          Run keywords
# ...                 robot_common_operations.Common Case Setup     AND
# ...                 power_ue.Prepare UE    ue_type=samsung  AND
# ...                 power_ue.UE Detach    ue_type=samsung  
# #...                 Start BTSlog
# 
# Test Teardown       Run Keywords
# ...                 robot_common_operations.Common Case Teardown     AND
# ...                 Collect Snapshot  AND
# ...                 power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=samsung  AND
# ...                 power_ue.UE Detach    ue_type=samsung  
# #...                 Stop BTSlog
# 
# *** Variables ***
# ${UE_CAPABILITIES}      REAL_UE
# ${UE_ALIAS}             AT_BASED_UE_1
# ${DT_ALIAS}             DT_DL_1
# ${TPUT_DURATION}        1700s
# ${LOG_DURATION}         1560s 
# ${TPUT_BANDWITH}        600
# ${TPUT_DEVIATION}       0.6
# ${TPUT_TARGET}          0.7
# ${UE_TYPE}              samsung
# 
# *** Test Cases ***
# [1]5GC002098_C_Queuing_Delay_Discard_mechanism_with_UDP_transmission_check_on_COAM
#     [Documentation]
#     ...     Description: This case tests discard mechanism for PDCP SDUs
#     ...     with new NIDD parameters with UDP transmission check on COAM.
#     [Tags]  UDP    SBTS00    SBTS22R3
#     ${list_of_cell_ids}    Create List    32374815
#     Perform commissioning 5GC002098
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}    attach_mode=5G_NSA
#     power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
#     power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${TPUT_BANDWITH}M    duration=${TPUT_DURATION}    ue_type=${UE_TYPE}
#     ...    protocol=udp    buffer_size=1400B    window=8M
#     ${log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    filter=L2Lo    duration=${LOG_DURATION}    
#     ${all_tp}    power_ue.Check Tput    ue_type=${UE_TYPE}    direction=DL    log=${log}    cells=${list_of_cell_ids}
#     ...    target_throughput=${TPUT_BANDWITH}    target_avg_percent=${TPUT_TARGET}    min_percent=${TPUT_DEVIATION}
#     Wait for counters  1 min
#     Check M55320C09009 counter
# 
# [1]5GC002098_C_Queuing_Delay_Discard_mechanism_with_TCP_transmission_check_on_COAM
#     [Tags]  TCP
#     [Documentation]
#     ...     Description: This case tests discard mechanism for PDCP SDUs
#     ...     with new NIDD parameters with TCP transmission check on COAM.
#     Queuing_Delay_TCP_Case_Steps
