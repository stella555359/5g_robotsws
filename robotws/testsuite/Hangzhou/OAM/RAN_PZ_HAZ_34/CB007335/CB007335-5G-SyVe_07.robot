# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   OAM
# 
# Suite Setup         Case_Suite_Setup
# Suite Teardown      Case_Suite_Teardown
# 
# Resource    ../CB006769_A/resources/comm_6769A.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# *** Variable ***
# @{cell_info}    ${0}
# ${swpakge_url}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS24R2/
# ${build}    SBTS24R2_ENB_0000_000635_000000
# ${pakage}    SBTS24R2_ENB_0000_000635_000000_release_BTSSM_downloadable_A54.zip
# 
# *** Test Cases ***
# [1]CB007335-5G-SyVe_07_BTS_Reset_Schedule_after_SW_upgrade_or_rollback_ASIB
#     [Documentation]
#     ...    Operator can schedule to sync BTS SW and configuration from active to passive partition periodically.
#     ...    -17.01.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_TRUNK    CB007335
#     [Setup]    case_setup
#     Check BTS Should Be Normal    all_cell_info=@{cell_info}
#     Rest Login DU
#     Set Scheduled Date Of BTS Sync    actpartsync_value=true    syncSchedule_value=${10}
#     ${latestCopyDate_value1}    Get Syncscheduled Parameter    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/MNL_CONF_M-1/MNL_R-1
#     ...    pattern=latestCopyDate
#     Rollback SW And Check BTS Normal
#     Check Current Scheduled Date    latestCopyDate_value1=${latestCopyDate_value1}
#     Check Nextconpydate Update
#     [Teardown]    case_teardown
# 
# [1]CB007335-5G-SyVe_07_BTS_Reset_Schedule_after_SW_upgrade_or_rollback_ASIM
#    [Documentation]
#     ...    Operator can schedule to sync BTS SW and configuration from active to passive partition periodically.
#     ...    -17.01.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_23R2    CRT_TRUNK   ute_cloud
#     [Setup]    case_setup
#     Check BTS Should Be Normal    all_cell_info=@{cell_info}
#     Rest Login DU
#     Set Scheduled Date Of BTS Sync    actpartsync_value=true    syncSchedule_value=${10}
#     ${latestCopyDate_value1}    Get Syncscheduled Parameter    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/MNL_CONF_M-1/MNL_R-1
#     ...    pattern=latestCopyDate
#     Rollback SW And Check BTS Normal
#     Check Current Scheduled Date    latestCopyDate_value1=${latestCopyDate_value1}
#     Check Nextconpydate Update
#     [Teardown]    case_teardown
# 
# *** Keywords ***
# Case_Suite_Setup
#     CI_interface.Common Suite Setup
#     robot_common_operations.Common Suite Setup
# 
# Case_Suite_Teardown
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common Suite Teardown
# 
# WEBUI Login
#     [Arguments]      ${virtual_enable}=${True}
#     [Documentation]   WEBUI Login
#     Log To Console  START:WEBUI Login
#     Log To Console  Try to login...
#     selenium_coam.Enable_Virtual_Display
#     selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     Log To Console  Login successfully...
#     Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
#     Sleep    15s
#     Log To Console  END:WEBUI Login!
# 
# WEBUI Logout
#     [Arguments]     ${virtual_disable}=${True}
#     [Documentation]   WEBUI Logout
#     Log To Console  Try to logout...
#     Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
#     Run Keyword And Ignore Error  selenium_coam.Logout
#     Log To Console  Logout successfully...
#     Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
#     Sleep    3s
#     Log To Console  END:WEBUI Logout!
# 
# Get SW version
#     WEBUI Login
#     Log To Console    get active and passive software version
#     ${version}     selenium_coam.check_current_software_version
#     ${active_version}    get from dictionary    ${version}    Active
#     ${passive_version}    get from dictionary    ${version}    Passive
#     ${version_list}    create list    ${active_version}    ${passive_version}
#     [Return]    ${version_list}
#     [Teardown]    WEBUI Logout
# 
# Set Scheduled Date Of BTS Sync
#     [Arguments]    ${actpartsync_value}    ${syncSchedule_value}    ${connection}=default
#     Log To Console    Set Scheduled Date Of BTS Sync
#     ${dict1}    create dictionary    parameterName=actPassivePartSync    operation=update    value=${actpartsync_value}
#     ${dict2}    create dictionary    parameterName=syncSchedule    operation=update    value=${syncSchedule_value}
#     ${list}    create list    ${dict1}    ${dict2}
#     coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1    parameter=${list}
#     ...    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     sleep    3s
#     Wait Until BTS Should Be Normal    all_cell_info=${cell_info}
# 
# Get Syncscheduled Parameter
#     [Arguments]    ${dist_name}    ${pattern}    ${connection}=default
#     Log To Console    Get Syncscheduled Parameter
#     ${pattern_dic}    coam.get_parameters    dist_name=${dist_name}    pattern=${pattern}    connection=${connection}
#     ${pattern_value}    get from dictionary    ${pattern_dic}    ${pattern}
#     [Return]    ${pattern_value}
# 
# Rollback SW And Check BTS Normal
#     [Arguments]    ${connection}=default
#     Log To Console    rollback software
#     Start Catch BTS Log
#     coam.rollback_software    connection=${connection}
#     sleep    2min
#     Log To Console    wait until BTS normal
#     Wait Until BTS Should Be Normal    all_cell_info=${cell_info}
#     Stop and collect btslog on local machine
# 
# Check Current Scheduled Date
#     [Arguments]    ${latestCopyDate_value1}
#     Log To Console    get current scheduled date
#     ${latestCopyDate_value2}    Get Syncscheduled Parameter    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/MNL_CONF_M-1/MNL_R-1
#     ...    pattern=latestCopyDate
# #    should be true    '${latestCopyDate_value2}' == '${latestCopyDate_value1}'
# 
# Check Nextconpydate Update
#     [Arguments]    ${bts_logs_dir}=/tmp/btslog2
#     Log To Console    Check Nextconpydate Update
#     ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
#     sleep    2s
#     ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'SwRollbackOngoing is finished, resetting scheduler'
#     ...    connection=VM
#     sleep    2s
#     ${output}    ssh.read output    connection=VM
#     run keyword and continue on failure    should not be empty    ${output}
#     ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'Timer for scheduler was started*'
#     ...    connection=VM
#     sleep    2s
#     ${output}    ssh.read output    connection=VM
#     run keyword and continue on failure    should not be empty    ${output}
#     [Teardown]    ssh.disconnect    connection=VM
# 
# case_setup
#     CI_interface.Common Case Setup
#     robot_common_operations.Common case Setup
# #    Common setup for 7335
#     ${version_list}    Get SW version
#     ${status}    run keyword and return status    should not be equal    ${version_list[0]}    ${version_list[1]}
#     ${sw_package}    run keyword if    ${status} == False    Make Software Version Inconsistent
#     run keyword if    ${status} == False    Rollback SW And Check BTS Normal
#     ${version_list}    Get SW version
#     Log To Console    check active version is different with passive version
#     should not be equal    ${version_list[0]}    ${version_list[1]}
# 
# case_teardown
#     run keyword and ignore error    Set Scheduled Date Of BTS Sync    actpartsync_value=false    syncSchedule_value=${EMPTY}
#     Rest Logout DU
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 
# Make Software Version Inconsistent
#     ${sw_package}    Download Software
#     WEBUI Login
#     ${result}    selenium_coam.load_software_package_from_local_drive    file_path=${sw_package}
#     should be equal    ${result}    software package load success
#     Log To Console    start update software
#     selenium_coam.software_update    is_activate=${True}
#     wait until keyword succeeds    20min    5s    Check Software Update Completed
#     WEBUI Logout
#     Log To Console    wait site reset
#     sleep    5min
#     Check BTS Should Be Normal    all_cell_info=@{cell_info}
#     Log To Console    remove sw_package
#     ssh.connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=UTE
#     ssh.execute    command=rm -rf ${sw_package}    connection=UTE
#     sleep    5s
#     [Teardown]    ssh.disconnect    connection=UTE
#     [Return]    ${sw_package}
# 
# Check Software Update Completed
#     Log To Console    Check Software Update Completed
#     ${result}    selenium_coam.check_software_update_progress
#     should be equal    &{result}[percentage]    100% completed
#     should not be equal    &{result}[status]    Activating software...
# 
# Download Software
#     [Arguments]    ${connection}=UTE
#     Log To Console    connect to UTE
#     ssh.connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=${connection}
#     Log To Console    download software
#     ssh.execute    command=cd /home/ute;wget ${swpakge_url}/${build}/${pakage}    connection=${connection}
#     sleep    3min
#     ${sw_package}   set variable    /home/ute/${pakage}
#     [Return]    ${sw_package}
#     [Teardown]    ssh.disconnect    connection=${connection}
