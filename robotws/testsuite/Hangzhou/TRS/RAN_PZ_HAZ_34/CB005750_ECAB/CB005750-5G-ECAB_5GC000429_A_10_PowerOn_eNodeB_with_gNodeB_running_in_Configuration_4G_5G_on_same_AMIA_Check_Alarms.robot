# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Sync
# 
# 
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    resources/ECAB_comm.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Test Cases ***
# [1]CB005750-5G-ECAB_5GC000429_A_10_PowerOn_eNodeB_with_gNodeB_running_in_Configuration_4G_5G_on_same_AMIA_Check_Alarms
#     [Documentation]
#     ...    To validate that there are no new alarms and synchro is OK when we switch ON the eNodeb 4G installed in
#     ...    left part of AMIA when gNodeb in right part is running 2.TEST ENVIRONMENT AND SETTINGS
#     ...    -03.02.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21A    CRT_TRUNK    CB005750_429    CRT_21B    CRT_22R2    CRT_22R4
#     [Setup]    case_setup
#     Check BTS Should Be Normal
#     ${fault_id_list01}    Get BTS Alarm FaultID
#     Reboot DU
#     Check BTS Should Be Normal
#     ${fault_id_list02}    Get BTS Alarm FaultID
#     remove from list     ${fault_id_list02}    2
#     lists should be equal    ${fault_id_list01}    ${fault_id_list02}
#     Check Sync Status    expect_syncInputType=TOPP
#     [Teardown]    case_teardown
# 
# *** Keywords ***
# case_setup
#     Setup Commission SCF
#     Check BTS Should Be Normal
#     Delete GPS And Change Sync Input Type To TOPP    synctype=TOPP
# 
# Reboot DU
#     ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
#     ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
#     sleep    2s
#     Log To Console    Reboot DU
#     ssh.send_command    command=reboot    connection=VM
#     sleep    200s
#     [Teardown]    ssh.Disconnect    connection=VM
# 
# case_teardown
#     Add And Change Sync Input Type To TOPP    synctype1=TOPP    synctype2=1pps/ToD from Sync Hub Master
#     CI_interface.Common Case Teardown
# 
# Suite Setup
#     TRANS Common Setup
# 
# Suite Teardown
#     TRANS Common Teardown
