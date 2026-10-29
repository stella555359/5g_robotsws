*** Setting ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Resource    ../common_robot/DevHZ5_common_resource.robot
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.collect_ru_logs
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${SCF_TEMPLATE_PATH}  ${CURDIR}/../../../../../../../../commissionings/HGZ
${RRU_LMI_FLAG}    ${True}
${ERR_WARN_ANALYSE_FLAG}    ${False}
&{ERR_WARN_ARGS}    Fail_Case=False
...                 Clear_log=True

*** Keywords ***
Common Suite Setup And Setup BTS env
    [Arguments]    ${scf}=SCFC_1.xml    ${swconfig}=swconfig.txt
    DevHZ5_common_resource.Common Suite Setup
    Import Suite Variables
    Set Suite Variable    ${BTS_NUMBER}    1
    Return From Keyword If  ${DEBUG}
    _Decide Config Path For UTE Cloud
    ${onair_status_1}  _Start BTS For The First Time    ${scf}    ${swconfig}
    run keyword if  not ${onair_status_1}    fail    fail to startup BTS
    #bts startup retry
#    Run Keyword Unless  ${onair_status_1}  _Retry To Start BTS

Common Suite Setup And Setup 2BTS env
    [Arguments]    ${scf1}=SCFC_1.xml    ${scf2}=SCFC_2.xml    ${swconfig1}=swconfig.txt    ${swconfig2}=swconfig_2.txt
    DevHZ5_common_resource.Common Suite Setup
    Import Suite Variables
    Set Suite Variable    ${BTS_NUMBER}    2
    Return From Keyword If  ${DEBUG}
    _Decide Config Path For UTE Cloud
    Setup BTS2
    ${onair_status_1}  _Start 2BTS For The First Time    ${scf1}    ${scf2}    ${swconfig1}    ${swconfig2}
    run keyword if  not ${onair_status_1}    fail    fail to startup BTS
    #bts startup retry
#    Run Keyword Unless  ${onair_status_1}  _Retry To Start BTS

Collect Logs For Startup
  [Arguments]  ${tag}  ${onair_status}
  Log To Console With Time Prefix  collecting logs
  Run Keyword If  '${onair_status}'=='${False}' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot BTS1  ${tag}
#  Run Keyword If  '${BTS_NUMBER}'=='2' and '${onair_status}'=='${False}' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
#  ...  Run Keyword And Ignore Error  Collect Snapshot BTS2  ${tag}
  Run Keyword If  '${onair_status}'=='${True}' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot BTS1  ${tag}
#  Run Keyword If  '${BTS_NUMBER}'=='2' and '${onair_status}'=='${True}' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
#  ...  Run Keyword And Ignore Error  Collect Snapshot BTS2  ${tag}
#  ${tmp_statup_sos}=  Run Keyword If  '${tag}'=='startup_1'  Set Variable  ${SOS_REPORT_STARTUP_1_FLAG_DIC}
#  ...  ELSE IF  '${tag}'=='startup_${${BTS_STARTUP_RETRY}+1}'  Set Variable  ${SOS_REPORT_FLAG_DIC}
#  ...  ELSE   Create Dictionary  pass=false  fail=false
#  ${SOS_REPORT_FLAG_WORK}  Set Variable If  '${onair_status}'=='${False}'  ${tmp_statup_sos['fail']}  ${tmp_statup_sos['pass']}
#  Set Suite Variable  ${SOS_REPORT_FLAG_WORK}
  Run Keyword And Ignore Error  Stop Capture Logs  ${tag}
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir  ${tag}
#  run keyword and ignore error  _Copy Config Files To Log Dir BTS2  ${tag}
  Analyze Logs  ${tag}  ${onair_status}
  Compress Directory  ${SAVE LOG DIRECTORY}/${tag}_logs
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Compress Directory
#  ...  ${SAVE LOG DIRECTORY}${/}${BTS2_ALIAS}/${tag}_logs

Common Suite Teardown And Restore BTS Configuration Parameters
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Recover Vendor Parameters
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Recover Vendor Parameters BTS2
  Recover Enb Config Ini
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Recover Enb Config Ini BTS2
  Delete Cp Runtime Ini
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Delete Cp Runtime Ini BTS2
  DevHZ5_common_resource.Common Suite Teardown
  Run Keyword And Ignore Error  Execute Cmd On Pc  timedatectl
  Log To Console  LOG_DIR=${SUITE_LOG_DIRECTORY}

Common Test Setup And Start To Capture Logs
  DevHZ5_common_resource.Common Test Setup    allowed_faults_default=49
  Run Keyword And Ignore Error  Run Keyword If  ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage
#  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2' and ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage Bts2
  Start To Capture Logs
#  Get Initial Active Faults
  ${case_begin_time}  Get Current Bts Time
  Set Test Variable  \${case_begin_time}

Common Test Teardown And Stop Capture Logs
  # collect bip log immediately because it could be covered
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error
  ...    Stop To Capture GNB BIP Log  ${EMPTY}  combine_flag=False
#  Run Keyword If    ${GNB_BIP_FLAG} is ${True} and '${BTS_NUMBER}'=='2'    Run Keyword And Ignore Error
#  ...    Stop To Capture GNB BIP Log BTS2  ${EMPTY}  combine_flag=False
  Run Keyword If  ${GNB_BIP_FLAG} is not ${True}  Sleep  10s  # make sure UE release procedure finished
#  Run Keyword If  ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage
#  Run Keyword If  '${BTS_NUMBER}'=='2' and ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage Bts2
#  run keyword and ignore error    Check No New Active Faults
  # collect and analyze logs
#  Run Keyword If Test Failed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['fail']}
#  Run Keyword If Test Passed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['pass']}
  Stop Capture Logs
#  Stop RRC Log
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir
#  run keyword and ignore error  _Copy Config Files To Log Dir BTS2
  Run Keyword If Test Failed  Set Test Variable  ${test_status}  FAIL
  Run Keyword If Test Passed  Set Test Variable  ${test_status}  PASS
  Analyze Logs  test_status=${test_status}
  DevHZ5_common_resource.Common Test Teardown
  run keyword if    ${ERR_WARN_ANALYSE_FLAG}    run keyword and ignore error
  ...    _Check ERR And WRN
  Run Keyword And Ignore Error  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If Test Passed
  ...  Remove Directory  ${SAVE LOG DIRECTORY}  ${True}
  Run Keyword If  '${REMOVE_LOGS}'=='off'  Compress Directory  ${SAVE LOG DIRECTORY}
#  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error
#  ...  Execute Cmd On Pc Bts2  rm -rf ${SAVE LOG DIRECTORY}  600
  robot_common_operations.Common Case Teardown
  CI_interface.common case teardown    # in order to show peak case in powerBI

_Check ERR And WRN
    execute cmd on pc    mkdir -p ${SAVE LOG DIRECTORY}/gnb_udp_logs
    execute cmd on pc    mv ${SAVE LOG DIRECTORY}/btslog*.LOG ${SAVE LOG DIRECTORY}/gnb_udp_logs
    Check ERR Or WRN From Syslog    sys_logs_path=${SAVE LOG DIRECTORY}/gnb_udp_logs    &{ERR_WARN_ARGS}

Wait BTS Onair And Return Status
    [Arguments]    ${tag}
    Log To Console With Time Prefix    step: wait GNB SSH connected
    Make Sure GNB SSH OK
    Run Keyword If    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture Wireshark Log    ${tag}
    Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture GNB BIP Log    ${tag}
    Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Start To Capture Trs Traffic On Backhaul
    ${onair_status}    Wait BTS Onair
    Return From Keyword    ${onair_status}

Wait 2BTS Onair And Return Status
    [Arguments]    ${tag}
    Log To Console With Time Prefix    step: wait GNB SSH connected
    Make Sure GNB SSH OK
    Make Sure GNB SSH OK BTS2
    Run Keyword If    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture Wireshark Log    ${tag}
    Run Keyword If    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture Wireshark Log BTS2    ${tag}
    Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture GNB BIP Log    ${tag}
    Run Keyword If    ${GNB_BIP_FLAG} is ${True}   Run Keyword And Ignore Error    Start To Capture GNB BIP Log BTS2    ${tag}
    Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Start To Capture Trs Traffic On Backhaul
    Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Start To Capture Trs Traffic On Backhaul BTS2
    log to console with time prefix  step: === Monitoring in BTS1 ===
    ${onair_status_bts1}    Wait BTS Onair
    log to console with time prefix  step: === Monitoring in BTS2 ===
    ${onair_status_bts2}    Wait BTS Onair BTS2
    ${onair_status}    set variable if    '${onair_status_bts1}'=='${True}' and '${onair_status_bts2}'=='${True}'
    ...    ${True}    ${False}
    Return From Keyword    ${onair_status}

Start to Capture RRU logs
    [Arguments]    ${tag}=${EMPTY}
    ${rru_log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs/RRU_logs
    ...  ${SAVE LOG DIRECTORY}/RRU_logs
    Create Directory    ${rru_log_dir}
    start_to_collect_ru_logs    is_ru_log_collecting_enable=True    log_save_dir=${rru_log_dir}

Stop Capture RRU logs
    stop_to_collect_and_save_ru_logs

Start To Capture Logs
  [Arguments]  ${tag}=${EMPTY}
  Run Keyword If  'startup' in '${tag}'  Kill Edaemon And Egate
  Wait For Host Ssh  ${FCT_IP}  timeout=600
  Start To Capture BTS Logs  ${tag}
  run keyword if    ${RRU_LMI_FLAG}    run keyword and ignore error    Start to Capture RRU logs    ${tag}
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Start To Capture BTS Logs BTS2  ${tag}
  _Start To Capture UTE Wireshark  ${tag}


Stop Capture Logs
  [Arguments]  ${tag}=${EMPTY}
  _Stop Capture UTE Wireshark
  Stop Capture BTS Logs  ${tag}
  run keyword if    ${RRU_LMI_FLAG}    run keyword and ignore error    Stop Capture RRU logs
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Stop Capture BTS Logs BTS2  ${tag}
  # Copy robot/ini/pdm to case run log path
  ${case_files}    Set Variable
  ...  ${SAVE LOG DIRECTORY.rsplit("/", 1)[0]}/${SUITE SOURCE.rsplit("/", 1)[0].rsplit("/", 1)[1]}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  mkdir -p ${case_files} && cp -r ${SUITE SOURCE.rsplit("/", 1)[0]}/*.robot ${case_files}

_Copy Config Files To Log Dir
  [Arguments]  ${tag}=${EMPTY}
  ${target_dir}  set variable if  'startup' in '${tag}'   ${SAVE LOG DIRECTORY}/${tag}_logs/config
  ...  ${SAVE LOG DIRECTORY}/config
  Execute Cmd On PC  mkdir -p ${target_dir}
  Run Keyword If  'startup' in '${tag}'  Copy File  ${SUITE_LOG_DIRECTORY}/scfc_logs/scf_for_startup.xml
  ...  ${target_dir}
  admin.Get Current Scf File  local_dir_path=${target_dir}  file_name=scf_after_test.xml  export_type=configurationAndRuntimeObjects
#  Execute Cmd On PC  cp -f /opt/wts/latest/egate_console.log ${SUITE_LOG_DIRECTORY}
#  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/iphy.xml ${target_dir}
  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/swconfig_modified.txt ${target_dir}/gnb_swconfig.txt
#  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/swconfig_ap_modified.txt ${target_dir}/ap_swconfig.txt
  Run Keyword If  @{PARAMS_IN_VENDOR} != ['']  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/vendor_modified.xml ${target_dir}/vendor.xml
#  Execute Cmd On PC  cp -rf ${WTS_DIR}/*.cfg ${target_dir}
#  Execute Cmd On PC  cp -rf ${WTS_DIR}/*.xml ${target_dir}
#  Execute Cmd On PC  rm -rf ${target_dir}/sosReport.cfg

_Decide Config Path For UTE Cloud
  ${CONFIG_PATH}  Decide Configurate Files Path  test_type=ST
  Set Suite Variable  \${CONFIG_PATH}

_Start BTS For The First Time
  [Arguments]    ${scf}    ${swconfig}
  ${onair_status}    Set Variable    ${False}
  Start To Capture Logs    startup_1
  Log To Console  \n===start bts for 1st time===
#  ${sw_updated}    Judge Sw Updated
  Change Vendor Parameters    ${PARAMS_IN_VENDOR}
  Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/${swconfig}
  ${scf_for_startup}    Modify Scf And Perform Full Commission    ${CONFIG_PATH}/${scf}    ${PARAMS_IN_SCF}
#  Add NetConf Account If RRU is ORAN
#  Run Keyword If    ${sw_updated} is ${True} or ${rru_updated} is ${True}    Restart Gnb And Airphone
#  _handle cfg bts1    ${scf_for_startup}    ${ue_count}    ${tl_type}    ${cfg}
#  Log To Console With Time Prefix    step: wait GNB SSH connected
#  Make Sure GNB SSH OK
#  run keyword if    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture Wireshark Log    startup_1
  ${onair_status}    Wait BTS Onair And Return Status    tag=startup_1
  ${status}    Run Keyword And Return Status    Keyword Should Exist    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  Run Keyword If    ${status} and ${onair_status}    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  [Teardown]    Collect Logs For Startup    startup_1    ${onair_status}
  [Return]    ${onair_status}

_Start 2BTS For The First Time
  [Arguments]    ${scf1}    ${scf2}     ${swconfig1}    ${swconfig2}
  ${onair_status}    Set Variable    ${False}
  Start To Capture Logs    startup_1
  Log To Console  \n===start bts for 1st time===
#  ${sw_updated}    Judge Sw Updated
  Change Vendor Parameters    ${PARAMS_IN_VENDOR}
  Change Vendor Parameters BTS2    ${PARAMS_IN_VENDOR}
  Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/${swconfig1}
  Change Swconfig File BTS2    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/${swconfig2}
  ${scf_for_startup1}    Modify Scf And Perform Full Commission    ${CONFIG_PATH}/${scf1}    ${PARAMS_IN_SCF}
  ${scf_for_startup2}    Modify Scf And Perform Full Commission BTS2    ${CONFIG_PATH}/${scf2}     ${PARAMS_IN_SCF_BTS2}
  ${onair_status}    Wait 2BTS Onair And Return Status    tag=startup_1
  ${status}    Run Keyword And Return Status    Keyword Should Exist    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  Run Keyword If    ${status} and ${onair_status}    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  [Teardown]    Collect Logs For Startup    startup_1    ${onair_status}
  [Return]    ${onair_status}

_Start To Capture UTE Wireshark
  [Arguments]  ${tag}
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  sudo tcpdump -i eth1 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth1.pcap>& tmp_1.txt&
#  # wireshark on eth3 or eth4 will be very large if there is big traffic
#  Return From Keyword If  ${UTE_WIRESHARK_FLAG} is not ${True} and 'startup' not in '${tag}'
#  Run Keyword And Ignore Error  Execute Cmd On Pc
#  ...  sudo tcpdump -i eth3 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth3.pcap>& tmp_3.txt&
#  Run Keyword And Ignore Error  Execute Cmd On Pc
#  ...  sudo tcpdump -i eth4 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth4.pcap>& tmp_4.txt&
#  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'
#  ...  Execute Cmd On Pc  sudo tcpdump -i eth5 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth5.pca>& tmp5.txt&

_Stop Capture UTE Wireshark
    ${status}  ${pids_sys}    Run Keyword And Ignore Error    Get Linux Process Id    tcpdump    ute_wireshark
    Run Keyword And Ignore Error    Kill Linux Process  ${pids_sys}
    ${pid_check_result}=    Run Keyword And Ignore Error    Execute Cmd On Pc  ps aux | grep ute_wireshark | grep -v -w grep
    ${status}    Run Keyword And Return Status    Should Not Contain    ${pid_check_result}[1]    ute_wireshark
    run keyword if  not ${status}  Log   Kill Ute Wireshark Process Failure    level=WARN
