*** Settings ***
Suite Setup       Test Suite Setup
#Suite Teardown    cOAM Common Suite Teardown
#Test Timeout      300min

Library           taf.sbts.oam.coam.admin   WITH NAME   coam
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/collect_log.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/gnb_handler.py
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot

*** Variables ***
${upgrade_package_path}     /home/ute/${target_version}.zip
${loopcount}    2
${fault_check}    ${True}
@{Fault_list}      10   6450
${connection_gnbcoam}    COAM_GNB
${connection_gnbhandle}    gnb
@{connection_enbcoam}    COAM_1_ENB    COAM_2_ENB    COAM_3_ENB
@{connection_enbhandle}    1_enb   2_enb   3_enb
${blackbox_check}    ${True}
${timeout_hour}    50

*** Test Cases ***
SW_Upgrade_loops_COAM_single_gnb
    [Setup]    Single Case Setup
    [Timeout]   ${timeout_hour}h
    FOR    ${i}    IN RANGE    ${loopcount}
        log to console    [${i+1}]:--- start upgrade---
        Bts Upgrade and check cell   hostip=${WEBUI_ADDR}
        ...   connection_coam=${connection_gnbcoam}   connection_handle=${connection_gnbhandle}
        log to console    [${i+1}]:--- start rallback---
        Bts Rollback and check cell    hostip=${WEBUI_ADDR}
        ...   connection_coam=${connection_gnbcoam}   connection_handle=${connection_gnbhandle}
    END
    [Teardown]   Single Case Teardown

SW_Upgrade_loops_COAM_Concurrent_gnb
    [Setup]    Concurrent Case Setup
    [Timeout]   ${timeout_hour}h
    FOR    ${i}    IN RANGE    ${loopcount}
        log to console    [${i+1}]:--- start upgrade---
        #gNB UPGRADE
        Bts Upgrade and check cell   hostip=${WEBUI_ADDR}
        ...   connection_coam=${connection_gnbcoam}   connection_handle=${connection_gnbhandle}
        ENBs Upgrade
        log to console    [${i+1}]:--- start rallback---
        ENBs Rollback
        # gNB ROLLBACK
        Bts Rollback and check cell    hostip=${WEBUI_ADDR}
        ...   connection_coam=${connection_gnbcoam}   connection_handle=${connection_gnbhandle}
    END
    [Teardown]   Concurrent Case Teardown


*** Keywords ***
Test Suite Setup
     Clean VM Space
     Check taget SW package exist in taf server    version=${target_version}
     ${bts_id}   convert to string   ${MRBTS_ID}
     set suite variable    ${bts_id}
     Convert fault_list to list type

Single Case Setup
    Mluti Login    bts_ip=${WEBUI_ADDR}    connection_coam=${connection_gnbcoam}    connection_handle=${connection_gnbhandle}

Single Case Teardown
    run keyword if test failed    Save logs for single gnb
    run keyword and ignore error   Mluti Logout    connection_coam=${connection_gnbcoam}    connection_handle=${connection_gnbhandle}

Convert fault_list to list type
    @{Fault_list}    Split String   ${faultlist}   ,
    set suite variable   @{Fault_list}

Concurrent Case Setup
    Mluti Login    bts_ip=${WEBUI_ADDR}    connection_coam=${connection_gnbcoam}    connection_handle=${connection_gnbhandle}
    ${enb_length}   Get Length   ${ENBs}
    ${enb_length}    Convert To Integer    ${enb_length}
    set Test variable   ${enb_number}    ${enb_length-1}
    FOR     ${index}    IN RANGE    ${enb_number}
         ${index}   set variable   ${index+1}
         Mluti Login    bts_ip=${ENBs[${index}]['addr']}
         ...    connection_coam=${connection_enbcoam[${index}]}   connection_handle=${connection_enbhandle[${index}]}
    END

Concurrent Case Teardown
    run keyword if test failed   Save logs for Concurrent gnb
    run keyword and ignore error   Mluti Logout    connection_coam=${connection_gnbcoam}    connection_handle=${connection_gnbhandle}
    FOR     ${index}    IN RANGE    ${enb_number}
         ${index}   set variable   ${index+1}
         run keyword and ignore error   Mluti Logout
         ...    connection_coam=${connection_enbcoam[${index}]}   connection_handle=${connection_enbhandle[${index}]}
     END

Mluti Login
    [Arguments]    ${bts_ip}    ${connection_coam}    ${connection_handle}
    wait until keyword succeeds     5 min   10 sec     COAM Login    bts_host=${bts_ip}    alias=${connection_coam}
    gnb_handler.login   ip=${bts_ip}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ...    gnb_type=coam   connection=${connection_handle}   admin_api_log_dir=${OUTPUT_DIR}/${TEST_NAME}

Mluti Logout
    [Arguments]    ${connection_coam}    ${connection_handle}
    COAM Logout    connection=${connection_coam}
    gnb_handler.logout   connection=${connection_handle}

COAM Update
    [Arguments]   ${hostip}    ${connection}   ${file_path}   ${activate}=yes
    Log To Console   Start Software Updating...
    ${should_activate}   Set Variable If   '${activate}'=='yes'   ${True}
    ...   '${activate}'=='no'   ${False}
    coam.update_software   sw_package=${file_path}   should_activate=${True}   timeout=${5400}   connection=${connection}
    Log To Console   Software Update Finished, Waiting For Resetting...
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${True}
    Log To Console   Reset finished!
    Log To Console   COAM SWM Update Done!

COAM Rollback
    [Arguments]    ${hostip}    ${connection}
    Log To Console   Start Software Rollback...
    coam.rollback_software   timeout=${7200}   connection=${connection}
    Log To Console   Software Update Finished, Waiting For Resetting...
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${True}
    Log To Console   Reset finished!
    Log To Console   COAM SWM Rollback Done!

Bts Upgrade and check cell
    [Arguments]    ${hostip}   ${connection_coam}    ${connection_handle}
    ...    ${TAF_addr}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${TAF_user}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${TAF_password}=${tl.test_pc.default_ssh_connection_details.password}
    run keyword and ignore error    Start Catch BTSlog    hostip=${TAF_addr}    user=${TAF_user}   password=${TAF_password}
    log to console    ***${hostip} start to upgrade***
    COAM Update    hostip=${hostip}    connection=${connection_coam}   file_path=${upgrade_package_path}
    Mluti Logout   connection_coam=${connection_coam}    connection_handle=${connection_handle}
    Mluti Login    bts_ip=${hostip}    connection_coam=${connection_coam}    connection_handle=${connection_handle}
    wait until keyword succeeds   40min   30s
    ...   Check fault and cell meantime    connection_coam=${connection_coam}    connection_handle=${connection_handle}
    run keyword if  ${blackbox_check}    Check Extra Reset from Blackbox File   action=upgrade    host=${hostip}
    run keyword and ignore error    Stop Catch BTSlog    hostip=${TAF_addr}    user=${TAF_user}   password=${TAF_password}

Bts Rollback and check cell
    [Arguments]    ${hostip}    ${connection_coam}    ${connection_handle}
    ...    ${TAF_addr}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${TAF_user}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${TAF_password}=${tl.test_pc.default_ssh_connection_details.password}
    run keyword and ignore error    Start Catch BTSlog   hostip=${TAF_addr}    user=${TAF_user}   password=${TAF_password}
    log to console    ***${hostip} start to rollback***
    COAM Rollback    hostip=${hostip}    connection=${connection_coam}
    Mluti Logout   connection_coam=${connection_coam}    connection_handle=${connection_handle}
    Mluti Login    bts_ip=${hostip}    connection_coam=${connection_coam}    connection_handle=${connection_handle}
    wait until keyword succeeds   40min   30s
    ...   Check fault and cell meantime    connection_coam=${connection_coam}    connection_handle=${connection_handle}
    run keyword if  ${blackbox_check}    Check Extra Reset from Blackbox File   action=rollback    host=${hostip}
    run keyword and ignore error    Stop Catch BTSlog    hostip=${TAF_addr}    user=${TAF_user}   password=${TAF_password}

ENBs Upgrade
    FOR     ${index}    IN RANGE    ${enb_number}
        ${index}   set variable   ${index+1}
        Bts Upgrade and check cell   hostip=${ENBs[${index}]['addr']}
        ...   connection_coam=${connection_enbcoam[${index}]}   connection_handle=${connection_enbhandle[${index}]}
        ...   TAF_addr=${enb_pcs[${index-1}]['addr']}
        ...   TAF_user=${enb_pcs[${index-1}]['username']}
        ...   TAF_password=${enb_pcs[${index-1}]['password']}
    END

ENBs Rollback
    FOR     ${index}    IN RANGE    ${enb_number}
        ${index}   set variable   ${index+1}
        Bts Rollback and check cell   hostip=${ENBs[${index}]['addr']}
        ...   connection_coam=${connection_enbcoam[${index}]}   connection_handle=${connection_enbhandle[${index}]}
        ...   TAF_addr=${enb_pcs[${index-1}]['addr']}
        ...   TAF_user=${enb_pcs[${index-1}]['username']}
        ...   TAF_password=${enb_pcs[${index-1}]['password']}
    END


Save logs for single gnb
    [Arguments]    ${hostip}=${WEBUI_ADDR}
    ...    ${TAF_addr}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${TAF_user}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${TAF_password}=${tl.test_pc.default_ssh_connection_details.password}
    Catch Snapshot COAM   filename=${hostip}    connection=${connection_gnbcoam}
    Save BTSlOG and Clean TMP    hostip=${TAF_addr}    user=${TAF_user}   password=${TAF_password}

Save logs for Concurrent gnb
    Catch Snapshot COAM   filename=${tl.test_pc.default_ssh_connection_details.addr}    connection=${connection_gnbcoam}
    Save BTSlOG and Clean TMP    hostip=${tl.test_pc.default_ssh_connection_details.addr}
    FOR     ${index}    IN RANGE    ${enb_number}
         ${index}   set variable   ${index+1}
         Catch Snapshot COAM   filename=${enb_pcs[${index-1}]['addr']}    connection=${connection_enbcoam[${index}]}
         Save BTSlOG and Clean TMP    hostip=${enb_pcs[${index-1}]['addr']}
    END

Check fault and cell meantime
    [Arguments]    ${connection_coam}    ${connection_handle}
    log to console    check cell status and fault!
    common.Get Cell Status Coam    connection=${connection_handle}
    run keyword if  ${fault_check}
    ...     Faults Should Not Be Present in Active and History   ${Fault_list}     alias=${connection_coam}

Clean VM Space
    Delete Code and Log from TAF
    RUN   find /opt/transformers.dynamic.nsn-net.net/workspace/CRT/Master/WebTrigger -mtime +1 -type d -delete
    RUN   cd /opt/CIUpgradeSW/;rm -rf *

Start Catch BTSlog
    [Arguments]   ${hostip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...             ${user}=${tl.test_pc.default_ssh_connection_details.username}
    ...             ${password}=${tl.test_pc.default_ssh_connection_details.password}
    Remove Btslog From Temp Folder    TAF_ADDR=${hostip}   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    Create Btslog log collection on remote machine for UUF    host=${hostip}

Stop Catch BTSlog
    [Arguments]   ${hostip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...             ${user}=${tl.test_pc.default_ssh_connection_details.username}
    ...             ${password}=${tl.test_pc.default_ssh_connection_details.password}
    wait until keyword succeeds   3x   10s   Clean BTSlog on Remote Machine   host=${hostip}   user=${user}   password=${password}

Save BTSlOG and Clean TMP
    [Arguments]     ${hostip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...             ${user}=${tl.test_pc.default_ssh_connection_details.username}
    ...             ${password}=${tl.test_pc.default_ssh_connection_details.password}
    Download Btslog To Log Path    dir=${EMPTY}    TAF_ADDR=${hostip}   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    Remove Btslog From Temp Folder    TAF_ADDR=${hostip}   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
