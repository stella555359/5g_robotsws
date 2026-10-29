*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Library    OperatingSystem
Library    String
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG8.resources.DevHZ5_lib_py.src.devhz5_lib  WITH NAME  devhz5_lib
Library    Process
Library    XML  use_lxml=True
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    ute_syslog
Library    ute_admin_infomodel
Library    DateTime
#Library    ta_a2a
Library    taf.collectors.core   WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.sw.dcap.rd    WITH NAME    rd
Library    taf.sw.scout    WITH NAME    scout
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${DEBUG}  ${False}
@{PARAMS_IN_SCF}  ${EMPTY}
@{PARAMS_IN_VENDOR}  ${EMPTY}
@{PARAMS_IN_SWCONFIG}  ${EMPTY}
@{PARAMS_IN_CP_UE_RD}  ${EMPTY}
@{PARAMS_IN_CP_CL_RD}  ${EMPTY}
@{PARAMS_IN_CP_RUNTIME}  ${EMPTY}
@{PARAMS_IN_EMIL}  ${EMPTY}
${PM_COUNTER_INTERVAL}    5min
@{PARAMS_IN_SCF_BTS2}  ${EMPTY}
@{PARAMS_IN_VENDOR_BTS2}  ${EMPTY}
@{PARAMS_IN_SWCONFIG_BTS2}  ${EMPTY}
@{PARAMS_IN_CP_UE_RD_BTS2}  ${EMPTY}
@{PARAMS_IN_CP_CL_RD_BTS2}  ${EMPTY}
@{PARAMS_IN_CP_RUNTIME_BTS2}  ${EMPTY}
@{PARAMS_IN_EMIL_BTS2}  ${EMPTY}
${BTS1_ALIAS}  bts1
${BTS2_ALIAS}  bts2
@{FAULTS_EXCLUDED_CHECKING}
${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}  Perform Steps After Onair
${KEYWORD_PERFORM_STEPS_BEFORE_CONFIG}  Perform Steps Before Setup Airphone Env
${SNAPSHOT_FLAG}     pass:True,fail:True
${BTSLOG_FLAG}  ${True}
${WIRESHARK_FLAG}  ${True}
${XPSYSCOM_FLAG}  ${False}
${SYSCOM_FLAG}  ${False}  # flag for syscom in wireshark log
${NOKIA_XNAP_PLUGIN_FLAG}  ${False}
${NOKIA_F1AP_PLUGIN_FLAG}  ${False}
${NOKIA_XNAP_PLUGIN_VERSION}  ${EMPTY}  # for example: 17.2.0-27
${NOKIA_F1AP_PLUGIN_VERSION}  ${EMPTY}  # for exampe: 17.2.0-29
${NSETAPX_PLUGIN_VERSION}  ${EMPTY}  # for exampe: 1.7.2
${TTITRACE_FLAG}  ${False}
${EMIL_FLAG}  ${False}
${SHERPA_FLAG}  ${False}
${IM_FLAG}  ${True}
${TRS_BACKHAUL_FLAG}  ${False}
${UTE_WIRESHARK_FLAG}  ${False}
${GNB_BIP_FLAG}  ${False}
${GNB_BIP_SIZE}  1000  #unit: M
${RESOURCES_LEAKAGE_FLAG}  ${True}
${AUTO_ANALYSIS_FLAG}  ${True}
${AUTO_FIX_VALIDATION_ERRORS}  ${False}
${RECREATE_WIRESHARK_FLAG}  ${True}
#${MANUAL_AUTO_REPORT}  ${False}
#${ONLY_REPORT_REP}  ${False}
${FCT_IP}   192.168.255.1
${FTM_IP}   192.168.255.129
${REMOVE_LOGS}  off
#${TCE_IP}   10.0.1.1
${TCE_PORT}  49100
${OMS_PORT}  49392
${BTS_STARTUP_RETRY}  1
${EMIL_DOCKER_COMPOSE_FILE}    ${CURDIR}${/}DevHZ5_lib${/}src${/}tools${/}emil${/}docker-compose.yml
${EMIL_START_CMD}    ${CURDIR}${/}DevHZ5_lib${/}src${/}tools${/}emil${/}emil_start_cmd.txt
# SOS only for AP
${SOS_REPORT_FLAG}    pass:False,fail:True
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
${L1_TYPE}    FS
${ERR_WRN_STATISTICS}    False

*** Keywords ***
Common Suite Setup
  ${time}  Get Time
  Log To Console  current time is ${time}
  Log Variables
  Log    ${tl}
  _Conver some variables
  set library search order    devhz5_lib    taf.sbts.oam.coam.admin
  Run Keyword And Ignore Error  Kill Useless Local Hosts
  Run Keyword And Ignore Error  Execute Cmd On Pc  df -h ${OUTPUT_DIR}
  _Create Suite Log Directory
  _get testline info
  _get gnb information
  Run Keyword And Ignore Error  Download Wireshark Plugin
  Set Suite Variable  ${BTS_NUMBER}  1
  [Teardown]  _Analyze Failure Of eNB SSH Issue

Common Suite Teardown
  Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
  Run Keyword And Ignore Error  Teardown All Aliases For Enb Fsmaccess
  Run Keyword And Ignore Error  Teardown All Aliases For Wts Fsmaccess
  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If All Tests Passed  Remove Directory
  ...  ${SUITE_LOG_DIRECTORY}  ${True}
  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error  Execute Cmd On Pc Bts2
  ...  rm -rf ${SUITE_LOG_DIRECTORY}  600
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep CM_EXECUTION_ID
  Run Keyword And Ignore Error  Execute Cmd On Pc  rm -rf /home/ute/scf_* /home/ute/gnb*/scf_*
  #Run Keyword And Ignore Error  Suite Teardown Report Rep  ${OUTPUT FILE}  ${MANUAL_AUTO_REPORT}

Common Test Setup
  [Arguments]    ${allowed_faults_default}=${EMPTY}
  _Create Test Log Directory
  ${case_start_time}    DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
  set test variable    ${case_start_time}
  ${allowed}    catenate  SEPARATOR=,    @{FAULTS_EXCLUDED_CHECKING}    ${allowed_faults_default}
  robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed}

Common Test Teardown
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Collect Snapshot BTS1
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If
  ...  '${BTS_NUMBER}'=='2' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'  Collect Snapshot BTS2
  run keyword if test passed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Collect Snapshot BTS1
  Run Keyword If Test passed  Run Keyword And Ignore Error  Run Keyword If
  ...  '${BTS_NUMBER}'=='2' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'  Collect Snapshot BTS2
  Run Keyword And Ignore Error  admin.Get current scf file  ${SAVE LOG DIRECTORY}  scf_after_test.xml
  ...  export_type=configurationAndRuntimeObjects    connection=${BTS1_ALIAS}
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'  admin.Get current scf file
  ...  ${SAVE LOG DIRECTORY}${/}${BTS2_ALIAS}  scf_after_test.xml
  ...  export_type=configurationAndRuntimeObjects
  ...  connection=${BTS2_ALIAS}

Import Suite Variables
    ${suite_path}    ${suite_name}    Split Path    ${SUITE SOURCE}
    ${suite_wo_ext}    ${ext}    Split Extension    ${suite_name}
    ${release_path}    select release path    ${suite_path}/test_data
    Log    ${suite_path}/test_data/${release_path}/${suite_wo_ext}_var.py
    ${status}    run keyword and return status    import variables    ${suite_path}/test_data/${release_path}/${suite_wo_ext}_var.py
    run keyword if    not ${status}    log    import ${suite_path}/test_data/${release_path}/${suite_wo_ext}_var.py failed    level=WARN


collect snapshot once
  [Arguments]  ${snapshot_dir}    ${alias}    ${remote_host}=None
  ${bts_port}  ${use_ssl}  Define Admin Port
  admin.Setup Admin  bts_port=${bts_port}  use_ssl=${use_ssl}  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs
  ...  timeout=120  remote_host=${remote_host}  bts_host=${FTM_IP}  alias=${alias}
#  ${status}=  Run Keyword And Return Status  Collect Snapshot  ${snapshot_dir}/snapshot.zip
#  Run Keyword Unless  ${status}  Execute Aashell Cmd  log -c full -a -z snapshot.zip  timeout=180
#  Run Keyword Unless  ${status}  Get Enb File  /tmp/snapshot.zip  ${snapshot_dir}/snapshot.zip
  admin.Collect Snapshot  ${snapshot_dir}/snapshot.zip  connection=${alias}
  [Teardown]    admin.teardown_admin    connection=${alias}

Collect Snapshot BTS1
  [Arguments]  ${tag}=${EMPTY}
  Execute Cmd On Pc    df -h ${OUTPUT_DIR}    # 20G is needed for snapshot capturing according to PR722687
  ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}
  Wait Until Keyword Succeeds    10x    1min    collect snapshot once    snapshot_dir=${snapshot_dir}    alias=snapshot_bts1

Collect Snapshot BTS2
  [Arguments]  ${tag}=${EMPTY}
  Execute Cmd On Pc    df -h ${OUTPUT_DIR}
  Execute Cmd On Pc bts2    df -h ${OUTPUT_DIR}    # 20G is needed for snapshot capturing according to PR722687
  ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${BTS2_ALIAS}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}/${BTS2_ALIAS}
  Wait Until Keyword Succeeds    10x    1min    collect snapshot once    snapshot_dir=${snapshot_dir}    alias=snapshot_bts2
  ...    remote_host=${BTS2_PC_IP}

Compress Directory
  [Arguments]  ${directory}
  ${directory}  Set Variable If  ${directory.endswith("/")}  ${directory[:-1]}  ${directory}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  cd ${directory}/../; zip -r ${directory}.zip ${directory.split("/")[-1]};cd ~  timeout=300
  ${zip_status}  run keyword and return status  file should exist  ${directory}.zip
  Run Keyword And Ignore Error  Run Keyword If  ${zip_status}  Remove Directory  ${directory}  ${True}

Make Sure GNB SSH OK
  Comment  ${status}  Is Host Ping Ok  ${FCT_IP}  2
  Comment  run keyword if  not ${status}  Wait For All Hosts  ${FTM_IP}  timeout=300
  Comment  run keyword if  not ${status}  admin.Disable Ethernet Port Security    connection=${BTS1_ALIAS}
  Comment  run keyword if  not ${status}  Wait For All Hosts  ${FCT_IP}  timeout=300
  Wait For All Hosts  ${FTM_IP}  ${FCT_IP}  timeout=300
  Run Keyword And Ignore Error  Wait For Host Ssh  ${FCT_IP}  timeout=180

Make Sure GNB SSH OK BTS2
  Wait For All Hosts  ${FTM_IP}  ${FCT_IP}  timeout=300  remote_host=${BTS2_PC_IP}
  Run Keyword And Ignore Error  Wait For Host Ssh  ${FCT_IP}  timeout=180  remote_host=${BTS2_PC_IP}

Start To Capture BTS Logs
  [Arguments]  ${tag}=${empty}
  Execute Cmd On Pc  netstat -na | grep 1500
  Start To Capture BTS UdpLogs  ${tag}
  Run Keyword And Ignore Error    Start To Capture Infomodel Log
  run keyword if  not 'startup' in '${tag}' and ${WIRESHARK_FLAG}    Run Keyword And Ignore Error
  ...    Start To Capture Wireshark Log  ${tag}
  run keyword if  not 'startup' in '${tag}' and ${XPSYSCOM_FLAG}    Run Keyword And Ignore Error
  ...  Start To Capture xpsyscom Log  ${tag}
  run keyword if  not 'startup' in '${tag}' and ${SHERPA_FLAG}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Sherpa    ${tag}
  run keyword if  not 'startup' in '${tag}' and ${TTITRACE_FLAG}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Ttitrace    ${tag}
  run keyword if  not 'startup' in '${tag}' and ${GNB_BIP_FLAG}    Run Keyword And Ignore Error
  ...    Start To Capture GNB BIP Log    ${tag}
  Run Keyword if     ${EMIL_FLAG} is ${True} and 'startup' not in '${tag}'    Run Keyword And Ignore Error
  ...    Collect EMIL from GNB DCAP
  #...     Capturing EMIL log    ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True} and 'startup' not in '${tag}'    Start To Capture Trs Traffic On Backhaul

Start To Capture BTS Logs BTS2
  [Arguments]  ${tag}=${empty}
  Start To Capture BTS UdpLogs BTS2  ${tag}
  Run Keyword And Ignore Error  Start To Capture Infomodel Log BTS2
  run keyword if  not 'startup' in '${tag}' and ${WIRESHARK_FLAG}    Start To Capture Wireshark Log BTS2  ${tag}
  run keyword if  not 'startup' in '${tag}' and ${XPSYSCOM_FLAG}
  ...  Start To Capture xpsyscom Log BTS2  ${tag}
  run keyword if  not 'startup' in '${tag}' and ${SHERPA_FLAG}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Sherpa BTS2    ${tag}
  run keyword if  not 'startup' in '${tag}' and ${TTITRACE_FLAG}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Ttitrace BTS2    ${tag}
  run keyword if  not 'startup' in '${tag}' and ${GNB_BIP_FLAG}    Run Keyword And Ignore Error
  ...    Start To Capture GNB BIP Log BTS2   ${tag}
  run keyword if  not 'startup' in '${tag}' and ${EMIL_FLAG}    Run Keyword And Ignore Error
  ...    Collect EMIL from BTS2 DCAP
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True} and 'startup' not in '${tag}'    Start To Capture Trs Traffic On Backhaul BTS2

Start To Capture BTS UdpLogs BTS2
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  Run Keyword And Ignore Error  collect_syslog_results  alias=${BTS2_ALIAS}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${BTS2_ALIAS}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}/${BTS2_ALIAS}
  Comment  Run Keyword And Ignore Error  start_syslog  ${btslog_dir}  ${btslog_name}  192.168.255.126  alias=${BTS2_ALIAS}
  ...  host_ip=${BTS2_PC_IP}
  Run Keyword And Ignore Error    Start Collect Btslog With Taf    btslog_name=${BTS2_ALIAS}    host_ip=${BTS2_PC_IP}

Stop Capture BTS Logs
  [Arguments]  ${tag}=${empty}
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log  ${tag}  combine_flag=False
  run keyword if  not 'startup' in '${tag}' and ${SHERPA_FLAG}    Run Keyword And Ignore Error
  ...  Stop Capture Gnb Sherpa    ${tag}
  run keyword if  not 'startup' in '${tag}' and ${TTITRACE_FLAG}    Run Keyword And Ignore Error
  ...  Stop Capture Gnb Ttitrace    ${tag}
  run keyword if    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    Stop Capture Wireshark Log  ${tag}
  run keyword if    ${XPSYSCOM_FLAG} is ${True}    Run Keyword And Ignore Error    Stop Capture xpsyscom Log  ${tag}
  Run Keyword And Ignore Error    Stop To Capture Infomodel Log  ${tag}
  Run Keyword If    ${EMIL_FLAG} is ${True} and 'startup' not in '${tag}'  Run Keyword And Ignore Error  Dcap Stop Trace
#  ...    Stop emil log
  Stop Capture BTS UdpLogs  ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Stop To Capture Trs Traffic On Backhaul    ${tag}

Start To Capture BTS UdpLogs
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  Run Keyword And Ignore Error  collect_syslog_results  alias=enb1
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  start_syslog  ${btslog_dir}  ${btslog_name}  192.168.255.126  alias=enb1
                                ...    ssh_password=iW_K#8.ute%A10h0m0ra

Stop Capture BTS UdpLogs
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  collect_syslog_results  alias=enb1
  split text file by size    ${btslog_dir}/${btslog_name}

Stop Capture BTS UdpLogs BTS2
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Comment  Run Keyword And Ignore Error  collect_syslog_results  alias=${BTS2_ALIAS}
  Run Keyword And Ignore Error  Stop Collect Btslog With Taf    ${BTS2_ALIAS}

Collect EMIL from GNB DCAP
    Set Suite Variable    ${DCAP_ALIAS}    DCAP
    Set Suite Variable    ${GNB_TRACE_ID}    ${EMPTY}
    Dcap Setup for BTS1
    Create Dcap Session    host=${testline_ip}    alias=${DCAP_ALIAS}
    ${GNB_TRACE_ID}    DCAP Start Trace    alias=${DCAP_ALIAS}
    Set suite variable    ${GNB_TRACE_ID}    ${GNB_TRACE_ID['tracer_id']}

Collect EMIL from BTS2 DCAP
    Get BTS2 testline ip address
    Set Suite Variable    ${BTS2_DCAP_ALIAS}    BTS2_DCAP
    Set Suite Variable    ${BTS2_TRACE_ID}    ${EMPTY}
    Dcap Setup for BTS2
    Create Dcap Session    host=${testline2_ip}    alias=${BTS2_DCAP_ALIAS}
    ${BTS2_TRACE_ID}    DCAP Start Trace    alias=${BTS2_DCAP_ALIAS}
    Set suite variable    ${BTS2_TRACE_ID}    ${BTS2_TRACE_ID['tracer_id']}

Start Collect Btslog With Taf
  [Arguments]      ${btslog_name}=btslog     ${host_ip}=${BTS2_PC_IP}
  run keyword and ignore error    core.teardown_collectors    names=${btslog_name}
  ${executor_test_vm}=  Create Dictionary  host=${host_ip}  user=ute  password=ute
  btslog.create_btslog_collector     name=${btslog_name}    executor=${executor_test_vm}  log_dir=/tmp/btslog2
  btslog.set suite Alias    ${btslog_name}    # keep btslog tool is alive
  core.setup_collectors      names=${btslog_name}
  core.start_collectors      names=${btslog_name}

Stop Collect Btslog With Taf
  [Arguments]      ${btslog_name}=btslog1    ${target_dir}=${SAVE LOG DIRECTORY}
  core.stop_collectors      names=${btslog_name}
  core.collect_collectors      names=${btslog_name}     target_dir=${target_dir}
  [Teardown]      run keyword and ignore error     core.teardown_collectors      names=${btslog_name}

Setup BTS2
  ${BTS2_PC_IP}    ${BTS2_IP}    Get Bts2 IPs
  Set Suite Variable    ${BTS2_PC_IP}
  Set Suite Variable    ${BTS2_IP}
  Log    BTS2_PC_IP=${BTS2_PC_IP}    console=True
  Log    BTS2_IP=${BTS2_IP}    console=True
  Setup Enb Fsm Access  remote_host=${BTS2_PC_IP}  alias=${BTS2_ALIAS}
  ${RACK_POSITION_BTS2}  Get Rack Position BTS2
  Set Suite Variable  ${RACK_POSITION_BTS2}
  Log  rack_position\=${RACK_POSITION_BTS2} in BTS2  console=True
#  Config IP on UTE2

Change Rd Parameters
  Change Enb Conf Ini    node_type=CPUE    params=${PARAMS_IN_CP_UE_RD}
  Change Enb Conf Ini    node_type=CPCL    params=${PARAMS_IN_CP_CL_RD}
  Create Cp Runtime ini    params=${PARAMS_IN_CP_RUNTIME}

Change Rd Parameters 2GNB
  Change Enb Conf Ini    node_type=CPUE    params=${PARAMS_IN_CP_UE_RD}
  Change Enb Conf Ini    node_type=CPCL    params=${PARAMS_IN_CP_CL_RD}
  Change Enb Conf Ini BTS2    node_type=CPUE    params=${PARAMS_IN_CP_UE_RD_BTS2}
  Change Enb Conf Ini BTS2    node_type=CPCL    params=${PARAMS_IN_CP_CL_RD_BTS2}
  Create Cp Runtime ini    params=${PARAMS_IN_CP_RUNTIME}
  Create Cp Runtime ini BTS2    params=${PARAMS_IN_CP_RUNTIME_BTS2}

Get Initial Active Faults
  ${initial_act_alarm_list}    Get Current Active Faultid
  Set Test variable    ${initial_act_alarm_list}
#  ${initial_act_alarm_list_bts2} =  Run Keyword If  '${BTS_NUMBER}'=='2'  Get Current Active Faultid Gnb2
#  Run Keyword If  '${BTS_NUMBER}'=='2'    Set Test variable    ${initial_act_alarm_list_bts2}

Check No New Active Faults
  Check No New Active Faultid Exist    ${initial_act_alarm_list}    ${FAULTS_EXCLUDED_CHECKING}
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Check No New Active Faultid Exist Gnb2
#  ...    ${initial_act_alarm_list_bts2}    ${FAULTS_EXCLUDED_CHECKING}

Get BTS2 testline ip address
  ${testline2_ip}  Execute Cmd On Pc Bts2  sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
  Set Suite Variable  ${testline2_ip}
  Log  TestLineIpAddress\=${testline2_ip}  console=True

Create Dcap Session
    [Arguments]      ${host}    ${alias}
    ${gnb_dcap_conn}=    rd.connect_to    host=${host}    port=9443
    ...    username=None   password=None    rd_version=dcapv3    secure=True    alias=${alias}

Dcap Start Trace
    [Arguments]      ${alias}=${DCAP_ALIAS}
    ${gnb_custom_profile}=    Create List    cp_5g
    ${index}    set variable if    'BTS2' in '${alias}'    1    0
    ${TRACE_ID}=    rd.start_trace    bts=${bts_info[${index}]}    gnb_custom_profile=${gnb_custom_profile}
    ...    connection=${alias}
    [return]    ${TRACE_ID}

Dcap Stop Trace
    [Arguments]    ${trace_id}=${GNB_TRACE_ID}   ${connection}=${DCAP_ALIAS}
    ${trace_id}    Evaluate    int(${trace_id})
    ${status}=    rd.stop_trace    trace_id=${trace_id}    connection=${connection}
    DCAP Get Results    result_id=${trace_id}    connection=${connection}
    Create EMIL log folder and save log    alias=${connection}

Create EMIL log folder and save log
    [Arguments]    ${alias}=${DCAP_ALIAS}
    Run Keyword If   'BTS2' not in '${alias}'   execute cmd on pc   mkdir -p ${SAVE LOG DIRECTORY}/BTS1_EMIL/
    Run Keyword If   'BTS2' not in '${alias}'   execute cmd on pc
    ...    mv /tmp/UTFLab*.zip ${SAVE LOG DIRECTORY}/BTS1_EMIL/
    Run Keyword If   'BTS2' in '${alias}'   execute cmd on pc   mkdir -p ${SAVE LOG DIRECTORY}/BTS2_EMIL/
    Run Keyword If   'BTS2' in '${alias}'   execute cmd on pc
    ...    mv /tmp/UTFLab*.zip ${SAVE LOG DIRECTORY}/BTS2_EMIL/

Dcap Get Results
    [Arguments]    ${result_id}    ${connection}=${DCAP_ALIAS}
    ${filepath}=    rd.get_results    result_id=${result_id}    connection=${connection}
    [Return]    ${filepath}

Wait until DCAP is active
    [Arguments]    ${host_ip}=${tl.test_pc[0].default_ssh_connection_details.addr}
    Wait until Keyword Succeeds    20x    3s   Create dcap session    ${host_ip}

Start DCAP Containers
    Start Process    DCAP_Basic_controller    start    alias=dcap_control
    ${result}=    Wait For Process    dcap_control
    Log to console    ${result.stdout}
    Should contain    ${result.stdout}    All DCAP Basic containers started successfully
    Wait Until Keyword Succeeds    60s    5s    Check DCAP status

Check DCAP status BTS1
    ${DCAP_STATUS}=    execute cmd on pc   DCAP_Basic_controller status
    should contain    ${DCAP_STATUS}    health check passed

Check DCAP status BTS2
    ${DCAP_STATUS}=    execute cmd on pc bts2   DCAP_Basic_controller status
    should contain    ${DCAP_STATUS}    health check passed

Dcap Setup for BTS1
    ${DCAP_VERSION}=    execute cmd on pc    DCAP_Basic_updates
    run keyword if    'FB2307' in '''${DCAP_VERSION}'''    log
    ...    the DCAP version less FB2309, capture EMIL will failure    level=WARN
    ${DCAP_STATUS}=    execute cmd on pc    DCAP_Basic_controller status
    Run keyword if    'health check passed' not in '''${DCAP_STATUS}'''
    ...    execute cmd on pc    DCAP_Basic_controller restart    120
    Wait Until Keyword Succeeds    100s    5s    Check DCAP status BTS1
    &{bts_dict}=    Create Dictionary    host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    port=443    username=Nemuadmin    password=nemuuser
    ${bts_info}=     Create List    ${bts_dict}
    Set Suite Variable    ${bts_info}

Dcap Setup for BTS2
    ${DCAP_VERSION}=    execute cmd on pc bts2   DCAP_Basic_updates
    run keyword if    'FB2307' in '''${DCAP_VERSION}'''    log
    ...    the DCAP version less FB2309, capture EMIL will failure    level=WARN
    ${DCAP_STATUS}=    execute cmd on pc bts2    DCAP_Basic_controller status
    Run keyword if    'health check passed' not in '''${DCAP_STATUS}'''
    ...    execute cmd on pc bts2    DCAP_Basic_controller restart    120
    Wait Until Keyword Succeeds    100s    5s    Check DCAP status BTS2
    &{bts2_dict}=    Create Dictionary    host=192.168.255.1    port=443    username=Nemuadmin    password=nemuuser
    append to List    ${bts_info}     ${bts2_dict}
    Set Suite Variable    ${bts_info}

_Conver some variables
   ${SOS_REPORT_FLAG_DIC}    _Update list parameters to DIC    ${SOS_REPORT_FLAG}
   ${SNAPSHOT_FLAG_DIC}    _Update list parameters to DIC    ${SNAPSHOT_FLAG}
   ${SOS_REPORT_STARTUP_1_FLAG_DIC}    _Update list parameters to DIC    ${SOS_REPORT_STARTUP_1_FLAG}
   Set suite variable    ${SOS_REPORT_FLAG_DIC}
   Set suite variable    ${SNAPSHOT_FLAG_DIC}
   Set suite variable    ${SOS_REPORT_STARTUP_1_FLAG_DIC}

_Update list parameters to DIC
    [Arguments]    ${params}
    ${param_dict}    Create Dictionary
    ${params_list}    set variable    ${params.split(',')}
    BuiltIn.Log    ${params_list[0]}
    FOR    ${index}    IN RANGE    0    len(${params_list})
           ${item_list}    set variable    ${params_list[${index}].split(':')}
           set to dictionary    ${param_dict}    ${item_list[0]}    ${item_list[1]}
    END
    [Return]    ${param_dict}

_Create Suite Log Directory
  ${timestamp}  Get Timestamp
  ${FILE_NAME} =  Replace String Using Regexp  ${SUITE_NAME[:50]}  \\s+$  ${EMPTY}
  ${SUITE_LOG_DIRECTORY} =  Catenate  SEPARATOR=${/}  ${OUTPUT_DIR}  ${FILE_NAME}_${timestamp}/
  ${SUITE_LOG_DIRECTORY}  Replace String  ${SUITE_LOG_DIRECTORY}  ${SPACE}  _
  Create Directory  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Log To Console  LOG_DIR=${SAVE LOG DIRECTORY}

_Create Test Log Directory
  ${tc_name}    Remove String Using Regexp    ${TEST_NAME}   \\[\\d+\\]
  ${TEST_LOG_DIR}  Catenate  SEPARATOR=  ${SUITE_LOG_DIRECTORY}  ${tc_name[:50]}/
  ${TEST_LOG_DIR}  Replace String  ${TEST_LOG_DIR}  ${SPACE}  _
  Create Directory  ${TEST_LOG_DIR}
  Set Suite Variable  ${TEST_LOG_DIR}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${TEST_LOG_DIR}

_get testline info
  #get testline info
  Log To Console  ===get testline info===
  ${testline_ip}  Execute Cmd On Pc  sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
  Set Suite Variable  ${testline_ip}
  Log  TestLineIpAddress\=${testline_ip}  console=True
  ${testline_hostname}  Execute Cmd On Pc  cat /etc/hostname
  Log    TestLineHostName\=${testline_hostname}    level=WARN
  Set Suite Variable    ${HOST_NAME}    ${testline_hostname}
  Run Keyword And Ignore Error  Execute Cmd On Pc  robot --version
  Run Keyword And Ignore Error  Execute Cmd On Pc  pip list
  Run Keyword And Ignore Error  Execute Cmd On Pc  timedatectl
  ${ute_version}  Execute Cmd On Pc  ute-setup -v
  Run Keyword And Ignore Error  Log  UTE_VERSION\=${ute_version.split()[-1]}  level=WARN
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute/MN/UTE/robotws;git log -n1;cd ~

_get gnb information
  Log To Console  \n===get enb info===
  #make sure ssh work
  Setup Enb Fsm Access  fallback_prompt=#  host=${FTM_IP}
  Wait For All Hosts  ${FTM_IP}  timeout=600
  ${bts_port}  ${use_ssl}  Define Admin Port
  admin.Setup Admin  bts_port=${bts_port}  use_ssl=${use_ssl}  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs
  ...  timeout=120  bts_host=${FTM_IP}    alias=${BTS1_ALIAS}
  Run Keyword And Ignore Error  admin.Disable Ethernet Port Security    connection=${BTS1_ALIAS}
  Run Keyword And Ignore Error  admin.Enable Ssh Access    connection=${BTS1_ALIAS}
  Wait For Host Ssh  ${FCT_IP}  timeout=60
  #get enb info
  ${GNB_SW_VERSION}  Get Gnb Sw Version
  Log  activeBuildVersion\=${GNB_SW_VERSION}  level=WARN
  Set Suite Variable  ${GNB_SW_VERSION}
  ${RELEASE}    Set Variable    ${GNB_SW_VERSION.split("_")[0]}
  Set Suite Variable  ${RELEASE}
  Log  release\=${RELEASE}  console=True
  Wait For Host Ssh  ${FCT_IP}  timeout=600
  ${PRODUCT_TYPE}  Get Product Type
  Log  product_type\=${PRODUCT_TYPE}  console=True
  Set Suite Variable  ${PRODUCT_TYPE}
  ${BBU_TYPE}  Get Bbu Type
  Log  bbu_type\=${BBU_TYPE}  console=True
  Set Suite Variable  ${BBU_TYPE}
  ${BBMOD_TYPE}  Get Bbmod Type
  Log  bbmod_type\=${BBMOD_TYPE}  console=True
  Set Suite Variable  ${BBMOD_TYPE}
  ${RACK_POSITION}  Get Rack Position
  Set Suite Variable  ${RACK_POSITION}
  Log  rack_position\=${RACK_POSITION}  console=True

_Get L1bypass Mode
    [Documentation]    This keyword is to check testline l1mode or not
    ${output}    Execute Aashell Cmd    tag -a
    ${result}=    Run Keyword And Return Status   should contain  ${output}   L1BypassMap
    ${L1_TYPE}=    Set Variable IF     "${result}" == "True"    L1b    FS
    Set Suite Variable    ${L1_TYPE}    ${L1_TYPE}
    Log  L1_TYPE\=${L1_TYPE}  console=True

_Analyze Failure Of eNB SSH Issue
  Return From Keyword If  '${KEYWORD STATUS}'=='PASS'
  Run Keyword If  'Unable to connect to port 22 on 192.168.255.1'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Blacklisted:failed to connect 192.168.255.1  WARN
  Run Keyword If  'Unable to connect to port 22 on 192.168.255.1'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure enb connection is reachable for local testline or reseved cloud testline.  WARN

Capture Gnb Ttitrace For A While
    [Arguments]  ${tag}  ${cell_id}  ${duration}=5  ${decode_flag}=True
    start to capture gnb ttitrace  ${tag}  ${cell_id}
    sleep  ${duration}
    ${ttitrace_log_path}    stop capture gnb ttitrace  ${tag}  decode_flag=${decode_flag}
    [Return]    ${ttitrace_log_path}

Capture Ttitrace And Check bler
    [Arguments]    ${cell_id}   ${max_dl_bler}=2%    ${max_ul_bler}=2%    ${duration}=5    ${tag}=${EMPTY}
    ${ttitrace_log_path}    Capture Gnb Ttitrace For A While    ${tag}
    ...                                                         ${cell_id}
    ...                                                         ${duration}
    ...                                                         decode_flag=True
    check_ibler_from_ttitrace    ${ttitrace_log_path}/ttiTrace_dl.csv
    ...                          ${cell_id}
    ...                          ${max_dl_bler}
    check_ibler_from_ttitrace    ${ttitrace_log_path}/ttiTrace_ul.csv
    ...                          ${cell_id}
    ...                          ${max_ul_bler}

Install BSR Package via WEBEM
    [Arguments]    ${bsr_name}
    # bsr_name like BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip, matched with RRU type
    ${bsr_path}    Set Variable    /home/ute/bsr_package
    Execute Cmd On Pc    rm -rf ${bsr_path}
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://wrgitlab.ext.net.nokia.com/y165zhan/bsr_package ${bsr_path}
    admin.update_software    sw_package=${bsr_path}/${bsr_name}    timeout=60    connection=${BTS1_ALIAS}
