*** Settings ***
Force Tags    PY36

Suite Setup       Case Suite Setup
Suite Teardown    Case Suite Teardown

Documentation    Suite description
...   author: miao.1.lu@nokia-sbell.com

Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB007335/Resources/CB007335_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${CURDIR_path}             ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T7421
${CURDIR_path1}            ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T7421/SCF_SBTS22R4.xml
${CURDIR_path1_trunk}            ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T7421/SCF_SBTS00.xml
${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${enb_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${LOG_PATH}                  ${OUTPUT_DIR}
${gNB_MRBTS_ID}                ${tl.gnbs[0].instance_id}
${connection}                GNB_OAM
${copyfailed_id}             4564
${swpakge_url}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS23R2
${build}    SBTS23R2_ENB_0000_000795_000000
${pakage}    SBTS23R2_ENB_0000_000795_000000_release_BTSSM_downloadable_A54.zip

*** Test Cases ***
[1]CB007335-5G-SyVe_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_ASIB_WEBEM
    [Documentation]    To verify successful copy BTS sw and configuration from active to passive partition
    [Tags]   CRT_22R2    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup
    Connect to DU
    Check Version not equal
    log to console    Send copy command
    Start BTSlog
    Add COPYSWTOPASSIVEREQ-1
    log to console    check copy version
    Wait Until Keyword Succeeds    10min    20s
    ...    Check copy version
    Wait Until Keyword Succeeds    10min    20s
    ...   Check copy response
    log to console  check alarm
    ${faultid_list_current}     Run keyword and continue on failure        Get Active Alarm List    bts_host=${gNB_ip}
    ${faultid_list_history}     Run keyword and continue on failure        Get history Alarm List    bts_host=${gNB_ip}
    should not contain    ${faultid_list_current}    ${copyfailed_id}
    should not contain    ${faultid_list_history}    ${copyfailed_id}
    log to console    check btslog
    Run Keyword And Continue On Failure     Stop BTSlog and check Message
     ...         regexp=Software backup requested, health check is: true
    Disconnect from DU
    log to console    rollback
    Rollback SW And Check BTS Normal
    [Teardown]   CI_interface.Common Case Teardown

[1]CB007335-5G-SyVe_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_ASIM_WEBEM
    [Documentation]    To verify successful copy BTS sw and configuration from active to passive partition
    [Tags]   CRT_23R2   CRT_TRUNK   UTE_CLOUD
    [Setup]    case_setup
    Connect to DU
    Check Version not equal
    log to console    Send copy command
#    Start BTSlog
    Add COPYSWTOPASSIVEREQ-1
    log to console    check copy version
    Wait Until Keyword Succeeds    10min    20s
    ...    Check copy version
    Wait Until Keyword Succeeds    10min    20s
    ...   Check copy response
    log to console  check alarm
    ${faultid_list_current}     Run keyword and continue on failure        Get Active Alarm List    bts_host=${gNB_ip}
    ${faultid_list_history}     Run keyword and continue on failure        Get history Alarm List    bts_host=${gNB_ip}
    should not contain    ${faultid_list_current}    ${copyfailed_id}
    should not contain    ${faultid_list_history}    ${copyfailed_id}
    log to console    check btslog
#    Run Keyword And Continue On Failure     Stop BTSlog and check Message
#     ...         regexp=Software backup requested, health check is: true
    Disconnect from DU
    log to console    rollback
    Rollback SW And Check BTS Normal
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[1]CB007335-5G-SyVe_06_Scheduled_sync_of_BTS_SW_and_configuration_from_active_to_passive_partition_ASIB
    [Documentation]    To verify Reset during Copy BTS SW and configuration from active to passive_partitio
    [Tags]   CRT_22R2    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup
    Connect to DU
    Check Version not equal
    log to console    Send copy command
    Start BTSlog
    Add COPYSWTOPASSIVEREQ-1
    log to console    reset_site
    selenium_coam.reset_site
    log to console    check copy version
    Wait Until Keyword Succeeds    10min    10s
    ...    Check copy version
    sleep  1min
    Wait Until Keyword Succeeds    10min    20s
    ...   Check BTS Normal
    Connect to DU
    Wait Until Keyword Succeeds    10min    10s
    ...    Check copy response
    log to console    check btslog
    Run Keyword And Continue On Failure     Stop BTSlog and check Message
     ...         regexp=Software backup requested, health check is: true
    log to console  check alarm
    ${faultid_list_current}     Run keyword and continue on failure        Get Active Alarm List    bts_host=${gNB_ip}
    ${faultid_list_history}     Run keyword and continue on failure        Get history Alarm List    bts_host=${gNB_ip}
    should not contain    ${faultid_list_current}    ${copyfailed_id}
    should not contain    ${faultid_list_history}    ${copyfailed_id}
    Disconnect from DU
    [Teardown]   CI_interface.Common Case Teardown

[1]CB007335-5G-SyVe_06_Reset_during_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_ASIM
    [Documentation]    To verify Reset during Copy BTS SW and configuration from active to passive_partitio
    [Tags]   CRT_23R2    CRT_TRUNK    UTE_CLOUD
    [Setup]    case_setup
    Connect to DU
    Check Version not equal
    log to console    Send copy command
    Start BTSlog
    Add COPYSWTOPASSIVEREQ-1
    log to console    reset_site
    selenium_coam.reset_site
    log to console    check copy version
    Wait Until Keyword Succeeds    10min    10s
    ...    Check copy version
    sleep  1min
    Wait Until Keyword Succeeds    10min    20s
    ...   Check BTS Normal
    Connect to DU
    Wait Until Keyword Succeeds    10min    10s
    ...    Check copy response
    log to console    check btslog
    Run Keyword And Continue On Failure     Stop BTSlog and check Message
     ...         regexp=Software backup requested, health check is: true
    log to console  check alarm
    ${faultid_list_current}     Run keyword and continue on failure        Get Active Alarm List    bts_host=${gNB_ip}
    ${faultid_list_history}     Run keyword and continue on failure        Get history Alarm List    bts_host=${gNB_ip}
    should not contain    ${faultid_list_current}    ${copyfailed_id}
    should not contain    ${faultid_list_history}    ${copyfailed_id}
    Disconnect from DU
    [Teardown]    case Teardown

*** Keywords ***
Case Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Iptables UDP destination port ACCEPT
#    Adapt to ute cloud commission scf
#    Common setup for 7335
    
Case Suite Teardown
    CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown

case_setup
    CI_interface.Common Case Setup
    robot_common_operations.Common case Setup
    Connect to DU
    ${status}    run keyword and return status    Check Version not equal
    Disconnect from DU
    ${sw_package}    run keyword if    ${status} == False    Make Software Version Inconsistent
    run keyword if    ${status} == False    Rollback SW And Check BTS Normal

case Teardown
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=5min
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}
    ...     password=${gNB_password}    connection=${connection}
    ${snapshot_path}    Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Make Software Version Inconsistent
    ${sw_package}    Download Software
    Connect to DU
    ${result}    selenium_coam.load_software_package_from_local_drive    file_path=${sw_package}
    should be equal    ${result}    software package load success
    Log To Console    start update software
    selenium_coam.software_update    is_activate=${True}
    wait until keyword succeeds    20min    5s    Check Software Update Completed
    Disconnect from DU
    Log To Console    wait site reset
    sleep    5min
    Wait Until Keyword Succeeds    20min    20s   Check BTS Normal
    Log To Console    remove sw_package
    ssh.connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=UTE
    ssh.execute    command=rm -rf ${sw_package}    connection=UTE
    sleep    5s
    [Teardown]    ssh.disconnect    connection=UTE
    [Return]    ${sw_package}

Check Software Update Completed
    Log To Console    Check Software Update Completed
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[percentage]    100% completed
    should not be equal    ${result}[status]    Activating software...

Download Software
    [Arguments]    ${connection}=UTE
    Log To Console    connect to UTE
    ssh.connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    Log To Console    download software
    ssh.execute    command=cd /home/ute;wget ${swpakge_url}/${build}/${pakage}    connection=${connection}
    sleep    3min
    ${sw_package}   set variable    /home/ute/${pakage}
    [Return]    ${sw_package}
    [Teardown]    ssh.disconnect    connection=${connection}
