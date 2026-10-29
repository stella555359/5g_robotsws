*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com   xiaofei.li@nokia-sbell.com

Library   String
Variables   ../../libraries/global_vars.py
Resource   coam.robot
Resource   coam_admin.robot
Resource   collect_log.robot
Library    ../../libraries/utils/csv_operation.py
Resource   ../../common/qc_tag.robot
Library   OperatingSystem
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/COAM.robot
Library    taf.hw.rf_attenuator    WITH NAME    attenuator

*** Variables ***
${ue_index}   0
${DEBUG}   False
${suite_setup}   ${false}
${suite_setup_pass}   ${false}
${lmp_ip_addr}   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${swconfig_path}   ${CURDIR}/../Resource/debug_swconfig.txt

*** Keywords ***
Get Test Json File
    [Arguments]   ${type}=file_name   ${case_name}=None
    ${case_aggregate}   Run Keyword If   '${case_name}'=='None'   Get Regexp Matches    ${TEST_NAME}   5GC00\\d+_\[AB\]_0\\d+
    ...   ELSE    Get Regexp Matches    ${case_name}   CB0\\d+-SR-E_0\\d+
#    ${case_1778}   Run Keyword If   '${case_name}'=='None'   Get Regexp Matches    ${TEST_NAME}   5GC00\\d+_\[AB\]_0\\d+
#    ...   ELSE   Set Variable   ${case_name}
#    ${case_aggregate}   Run Keyword If   $case_1778==[]   Get Regexp Matches    ${TEST_NAME}   CB0\\d+-SR-E_0\\d+
#    ...   ELSE   Set Variable   ${case_1778}
    ${json_file_name}   Set Variable If   '${type}'=='file_name'   ${case_aggregate[0]}   5GC000864_common
    [Return]   ${CURDIR}/../libraries/${json_file_name}.json

Remove Cell Trace Object
    ${remove_res}   Run Keyword and Return Status   Remove Cell Trace Object If Exists
    run keyword if  not ${remove_res}   Restore gNB ENV
    run keyword if  not ${remove_res}   Remove Cell Trace Object If Exists

Commission Cell Trace CU and PCMD CU Flags
    [Arguments]   ${cell_trace_flag}=true   ${PCMD_flag}=false   ${cell_trace_details}=all
    [Timeout]   1h
    Log to Console   Start CellTrace=${cell_trace_flag} PCMD_CU=${PCMD_flag} MO Available settings.
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d_%H%M%S
    ${cell_trace_details}   Set Variable If   '${cell_trace_flag}'=='false'   none   ${cell_trace_details}
    wait until keyword succeeds   3x   30s   Remove Cell Trace Object
    ${emil_last_file}   Get Latest Trace File Name
    Set Suite Variable   ${emil_last_file}
    Add Cell Trace Object Without Activate   celltrace_cu=${cell_trace_flag}   pcmd_cu=${PCMD_flag}
    ...   rrc=${cell_trace_details}   x2=${cell_trace_details}   xn=${cell_trace_details}   ngap=${cell_trace_details}
    Modify Parameter actCellTraceReport To ${cell_trace_flag}
    Modify Parameter actPCMDReport To ${PCMD_flag}
    Validate and Activate Plan
#    wait until keyword succeeds   3x   10s   Check Session Setup   setup=${session_setup}
    [Teardown]   Run Keyword If   $KEYWORD_STATUS == 'FAIL'   selenium_coam.save_screenshot
    ...   filename=screen_commission_${timestamp}.png   screenshot_dir=${OUTPUT_DIR}

Cell Trace Suite Setup
    [Timeout]  2h
    [Arguments]   ${cell_trace_flag}=true   ${PCMD_flag}=false   ${cell_trace_details}=all   ${l3call}=${true}
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    Start Catch Relative Log
    robot_common_operations.Common Suite Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login   display=${${DEBUG}}
    Close Web Startup View Window
    Set Suite Variable   ${suite_setup}   ${true}
#    Check SMOD and Change QC Set   location=${case_path}
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir   connection=COAM
    Commission Cell Trace CU and PCMD CU Flags   cell_trace_flag=${cell_trace_flag}   PCMD_flag=${PCMD_flag}
    ...   cell_trace_details=${cell_trace_details}
    Run Keyword If   ${l3call}   L3CALL Precondition
    Set Suite Variable   ${suite_setup_pass}   ${true}
    Get Common Tags Info
#    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}/qc_id_def.csv
#    Set Suite Variable   ${QC_DEF}

Cell Trace Suite Teardown
    [Arguments]   ${collect_log}=${True}
    robot_common_operations.Common Suite Teardown
    run keyword if   ${collect_log}   Run Keyword If Any Tests Failed    Collect Relative Log
    run keyword if all tests passed   Delete BTS log in VM
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout

Initial gNB for Testing
    Wait Until Keyword Succeeds   15m   30s   COAM Login    alias=gnb_init
    COAM RESET SITE   connection=gnb_init
    Sleep   300s
    Wait Until Keyword Succeeds   15m   30s   COAM Check All Cells Onair   connection=gnb_init
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Stop Firefox Pids
    COAM WEBUI Login
    Close Web Startup View Window
    Remove Cell Trace Object
    [Teardown]   COAM Logout   connection=gnb_init

Case Common Setup
#    Run Keyword and Ignore Error    Check Extra Reset From Blackbox
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
#    Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login   display=${${DEBUG}}
#    Close Web Startup View Window
    ${if_onair}   Run Keyword and Return Status   Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir   connection=COAM
    run keyword if  not ${if_onair}    Restore gNB ENV
    run keyword and ignore error   Start Catch Relative Log   log_dir_name=${TEST NAME}
    COAM Remove PCMD Object
#    wait until keyword succeeds   3x   1m   Remove Cell Trace Object
#    Close Web Startup View Window
#    Get Common Tags Info
#    Make L3 Call

Case Common Teardown
#    Check Extra Reset From Blackbox
    robot_common_operations.Common Case Teardown
#    run keyword if test failed  Collect Relative Log
#    run keyword if test passed   Delete BTS log in VM
#    run keyword if test failed   Restore gNB ENV
    Run Keyword If   $KEYWORD_STATUS=='FAIL'   Collect Relative Log
    Run Keyword If   $KEYWORD_STATUS=='FAIL'   Restore gNB ENV
    Run Keyword If   $KEYWORD_STATUS=='PASS'   Delete BTS log in VM
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
    CI_interface.Common Case Teardown


864 Common Suite Setup
    [Timeout]  2h

    # Start Catch Relative Log
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair

    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    robot_common_operations.Common Suite Setup


    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Set Suite Variable   ${suite_setup}   ${true}
    ${emil_last_file}   Get Latest Trace File Name
    Set Suite Variable   ${emil_last_file}
    Remove And Add PCMD Object
    L3CALL Precondition
    Set Suite Variable   ${suite_setup_pass}   ${true}
    Get Common Tags Info


864 Common Suite Teardown
    [Arguments]   ${collect_log}=${True}
    robot_common_operations.Common Suite Teardown
    run keyword if   ${collect_log}   Run Keyword If Any Tests Failed   Collect Relative Log
    run keyword if all tests passed   Delete BTS log in VM
    # Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout

864 Common Case Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    # ${selenium_status}   Run Keyword and Return Status   Close Web Startup View Window
    # run keyword if  not ${selenium_status}   COAM WEBUI Login   display=${${DEBUG}}
    Run Keyword And Ignore Error   Start BTS Log Collection


864 Common Case Teardown
    robot_common_operations.Common Case Teardown
#    Check Extra Reset From Blackbox on Teardown
    run keyword and ignore error   Collect Relative Log
    run keyword if Test passed   Delete BTS log in VM
    CI_interface.Common Case Teardown
    # run keyword if test failed   Reset site and wait to onair

Restore gNB ENV
    COAM WEBUI Whether Close Start Up View Window
#    gNB reboot from SSH
    run keyword and ignore error   COAM Login
    run keyword and ignore error   COAM Reset Site
    Sleep   180 sec
    wait until keyword succeeds   5m   10s   Try Connect gNB
    wait until keyword succeeds   15m   20s   COAM Check All Cells Onair
    COAM WEBUI Whether Close Start Up View Window
    [Teardown]     run keyword and ignore error  COAM Logout

L3CALL Precondition
    [Arguments]   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Get Attached Cell Index
    ${nrcell_identity}   Get Attached Cell Indentity
    ${cell_list}   COAM Get Cell List
    FOR   ${index}    IN RANGE    len(${cell_list})
       ${nrcell_id}   selenium_coam.get_parameter_value   dist_name=${INSID}/NRCELL-${index+1}
       ...   filter_param=NR Cell Identity
       Return From Keyword If   '${nrcell_id}'=='${nrcell_identity}'   ${index+1}
    END
    [Return]   ${0}

Cell Lock Unlock and Check Status with index ${cell_idx:\d+}
    [Documentation]   Block the cell and wait for it has been blocked state
#    [Arguments]     ${cell_idx}=1
    Log To Console    Cell ${cell_idx} will be Locked ...
    Cell Operation State   cell_index=${cell_idx}   state=Locked   INSID=${INSID}
    Wait Until Keyword Succeeds   3x   10s   Cell State Verify   cell_index=${cell_idx}   state=Locked
    Wait Until Keyword Succeeds   3x   30s   Cell Operation State   INSID=${INSID}   cell_index=${cell_idx}
    Wait Until Keyword Succeeds   15min    10 sec   Cell State Verify   cell_index=${cell_idx}
    Wait until keyword succeeds    5min    10 sec    COAM Check All Cells Onair
    Log To Console    Cell ${cell_idx} has been Unlocked ...
#    Wait until keyword succeeds    3min    20 sec    Expect Fault Should Prese

Get Common Tags Info
    ${smod_type}   Get SMOD Product Name
    ${release}   Get gnb release
    ${qc_def}   get_csv_dedicated_line   file_path=${CURDIR}/qc_id_def.csv   key_start=${smod_type}_${release}
    Set Suite Variable   ${QC_DEF}

Validate IP Reachability from Test PC
    [Arguments]  ${ip_addr}  ${exp_status}
    [Timeout]  3m
    ${ipv6}  run keyword and return status   should contain   ${ip_addr}  :
    ${output}   run keyword if  '${ipv6}' == 'True'
    ...    RUN    sudo ping6 ${asik_addr} -c 5
    ...    ELSE   RUN    sudo ping ${ip_addr} -c 5
    ${output}    Get Regexp Matches    ${output}    \\d{0,5}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    ${status}  set variable if   '${output}'== '0'   ${True}   ${False}
    should be equal   ${exp_status}   ${status}

Upload Swconfig File
    [Arguments]    ${swconfig_path}  ${asik_addr}
    [Timeout]  30m
    Wait Until Keyword Succeeds    10m    10s
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    log to console    \nUpload Swconfig File starting...
    csn.Upload File    local_path=${swconfig_path}    remote_path=/rom/swconfig.txt    connection=gnb
    csn.execute    crasign /rom/swconfig.txt    connection=gnb
    BuiltIn.sleep  2s
   ${target_flags}    csn.execute   command=cat /rom/swconfig.txt |grep -iE "0x9D000"   connection=gnb
    log to console    \n target_flags=${target_flags}
    log to console    \nUpload Swconfig File finished!!!
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Update BTSlog Config Filesize
    [Timeout]  3m
    Run   find /home/ute/btslog2/btslog.ini |xargs sudo sed -i 's|FileSize.*|FileSize=50.0|g'
    BuiltIn.sleep  2s
    Run   find /opt/btslog/configuration/btslog.ini |xargs sudo sed -i 's|FileSize.*|FileSize=50.0|g'
    ${home_btslog_filesize}   Run  cat /home/ute/btslog2/btslog.ini|grep -iE "FileSize"
    BuiltIn.sleep  2s
    ${opt_btslog_filesize}   Run  cat /opt/btslog/configuration/btslog.ini |grep -iE "FileSize"
    Log To Console   \ncurrent home_btslog_filesize: '${home_btslog_filesize}
    Log To Console   \ncurrent opt_btslog_filesize: ${opt_btslog_filesize}

Cell Trace Suite Setup with Upload Swconfig
    [Timeout]  2h
    [Arguments]   ${cell_trace_flag}=true   ${PCMD_flag}=false   ${cell_trace_details}=all   ${l3call}=${true}
    robot_common_operations.Common Suite Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    Wait Until Keyword Succeeds   10m   10s   Validate IP Reachability from Test PC
    ...   ip_addr=${lmp_ip_addr}   exp_status=${True}
    common.Upload Swconfig File   swconfig_path=${swconfig_path}   asik_addr=${lmp_ip_addr}
    Update BTSlog Config Filesize
    Start Catch Relative Log
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login   display=${${DEBUG}}
    Close Web Startup View Window
    Set Suite Variable   ${suite_setup}   ${true}
#    Check SMOD and Change QC Set   location=${case_path}
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir   connection=COAM
    Commission Cell Trace CU and PCMD CU Flags   cell_trace_flag=${cell_trace_flag}   PCMD_flag=${PCMD_flag}
    ...   cell_trace_details=${cell_trace_details}
    Run Keyword If   ${l3call}   L3CALL Precondition
    Set Suite Variable   ${suite_setup_pass}   ${true}
    Get Common Tags Info
#    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}/qc_id_def.csv
#    Set Suite Variable   ${QC_DEF}
    AlarmWatchdog.remove_allow_alarms    fault_id=6450

