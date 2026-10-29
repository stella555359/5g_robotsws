*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com

Resource   ./emil.robot
Resource   ./common.robot
Library    ../libraries/emil_messages.py
Resource   ../../common/gnb.robot
Variables  ../../libraries/global_vars.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${dcap_private_key_path}   ${CURDIR}/../libraries/utfuser.private.key

*** Keywords ***
Check Emil log
    [Arguments]   ${emil_file}   ${type}=file_name   ${found}=${true}
    ${txt_file}   Covert Emil Logs to TXT   file_list=${emil_file}   local_dir=${OUTPUT_DIR}
    ${target_file}   Get Test Json File   type=${type}
    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}   should_found=${found}
    [Return]   ${txt_file}

Test Common Step
    [Arguments]   ${emil_last_file}=${emil_last_file}   ${type}=common   ${found}=${true}
    [Timeout]   3h
    Repeat Keyword   3x   Wait Until Keyword Succeeds   3x   10s   Attach UE and Detach
    ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${emil_last_file}   local_dir=${OUTPUT_DIR}
    ${txt_file}   Check Emil log   emil_file=${file_list}   type=${type}   found=${found}
    [Return]   ${txt_file}

Attach UE and Detach
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    power_ue.UE Attach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    Run Keyword If   '${mode_status}'!='0'   Sleep   10s
    ...   ELSE    UE Forced Reboot   ue_index=${ue_index}   detach_request=${false}
    [Teardown]   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Test Common Teardown
    robot_common_operations.Common Case Teardown
    run keyword if test failed   selenium_coam.save_screenshot   filename=${TEST_NAME[:15]}.png   screenshot_dir=${OUTPUT_DIR}
    Close Web Startup View Window
#    Check Extra Reset From Blackbox
    run keyword if test failed   Collect Relative Log
    run keyword if Test passed   Delete BTS log in VM
    CI_interface.Common Case Teardown
    run keyword if test failed   Reset site and wait to onair
    Start BTS Log Collection

Test Common Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    ${selenium_status}   Run Keyword and Return Status   Close Web Startup View Window
    run keyword if  not ${selenium_status}   COAM WEBUI Login   display=${${DEBUG}}

Reset site and wait to onair
    [Timeout]   30m
    Close Web Startup View Window
    selenium_coam.reset_site
    Sleep   180 sec
    wait until keyword succeeds   5m   10s   Try Connect gNB
    Close Web Startup View Window
    wait until keyword succeeds   15m   20s   COAM Check All Cells Onair

Tracer Connection Operation
    [Arguments]   ${addr}=${tl.gnbs[0].cu.oam_http_connection_details.addr}   ${action}=start   ${connection}=ltetracer
    ${param}   Set Variable If   '${action}'=='start'   -D   -I
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${trace_host}   username=${trace_user}    key_path=${dcap_private_key_path}   alias=${connection}
#    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}   alias=${connection}
    csn.Execute   command=sudo iptables ${param} INPUT -s ${addr} -j DROP   connection=${connection}
    [Teardown]   csn.Disconnect   connection=${connection}

Check Fault 8000 Exists
    [Arguments]   ${should_exist}=${true}
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    ${alarm_exists}      Set Variable If   ${should_exist}   Present   Absent
    Run Keyword   Expect Fault Should ${alarm_exists}    faultId=8000   connection=COAM   is_need_to_setup_gnb_connection=${False}
