*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Library  OperatingSystem
Library  String
Library  DevHZ5_lib/src/DevHZ5_lib.py
Library  Process
Library  XML  use_lxml=True
Library  Collections
Library  ute_reporting_portal
Library  taf.sbts.oam.coam.admin
Library  ute_syslog
Library  ute_admin_infomodel
Library  ta_a2a
Library  DateTime
Library  taf.collectors.core   WITH NAME   core
Library  taf.collectors.btslog  WITH NAME   btslog
Library  ta_uexgate
Library  ta_messaging
Library  taf.ul.ue.sim.env_setup
Library    taf.sw.scout    WITH NAME    scout

*** Variables ***
${DEBUG}  ${False}
@{PARAMS_IN_SCF}  ${EMPTY}
@{PARAMS_IN_VENDOR}  ${EMPTY}
@{PARAMS_IN_SWCONFIG}  ${EMPTY}
@{PARAMS_IN_EMIL}  ${EMPTY}
@{PARAMS_IN_SWCONFIG_CUS}  ${EMPTY}
#${PM_COUNTER_INTERVAL}    5min
@{PARAMS_IN_SCF_ENB2}  ${EMPTY}
@{PARAMS_IN_VENDOR_ENB2}  ${EMPTY}
@{PARAMS_IN_SWCONFIG_ENB2}  ${EMPTY}
@{PARAMS_IN_EMIL_ENB2}  ${EMPTY}
${SNAPSHOT_FLAG}   pass:True,fail:True
${BTSLOG_FLAG}  ${True}
${WIRESHARK_FLAG}  ${True}
${NSETAP_PLUGIN_VERSION}  ${EMPTY}  # for exampe: 1.7.2
${TTITRACE_FLAG}  ${False}
${EMIL_FLAG}  ${True}
${IM_FLAG}  ${True}
${ONLY_REPORT_REP}  ${False}
${UTE_WIRESHARK_FLAG}  ${True}
${UTE_CPU_MEM_FLAG}  ${False}
${SOS_REPORT_FLAG}  pass:False,fail:True
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
${DEBUG_LOG_LEVEL}  2    #0: DEBUG;  1: INFO;  2: CTRL_STAT_INFO;  3: WARNING;  4: ERROR;  5: FATAL;  6: OFF, for wts logs
${CUS_LOG_LEVEL}  INFO  # OFF|INFO|FAULT|ERROR|WARNING|LOG|DEBUG|ALL, for executor syslog, mapping to executor.log_level in config.ini
${CUS_SYSLOG_MODE}  INFO    # DEBUG|INFO|WARNING|ERROR|VIP|DISABLE, for cus syslog, mapping to executor.syslog_mode in config.ini
${CUS_PCAP_FLAG}  ${False}
${CUS_PCAP_OPTIONS}   -c 1 --l2 --sch --payload 1
${AUTO_ANALYSIS_FLAG}  ${True}
${AUTO_FIX_VALIDATION_ERRORS}  ${True}
${RECREATE_WIRESHARK_FLAG}  ${True}
#${MANUAL_AUTO_REPORT}  ${False}
#${ONLY_REPORT_REP}  ${False}
${SCF_TEMPLATE_PATH}  ${CURDIR}${/}configuration_file
${WTS_DIR}  /opt/iphy/latest  # can not change because it is hardcode in TA lib
@{ENB1_CONF}
...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:syncInputList:syncInputType=1pps/ToD from external GNSS receiver
...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=EnabledWithoutBtsInputReference
@{ENB2_CONF}
...  TNLSVC-1/TNL-1/IPAPP-1/BFD-1:bfdDestIpAddr=xxx
...  TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr=xxx
...  TNLSVC-1/TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=10.0.1.3
...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:syncInputList:syncInputType=1pps/ToD from Sync Hub Master
...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=Disabled
...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:totalDelayFromSHM=3
${Keyword_Modify_Yaml}  Modify Yaml
${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}  Perform Steps After Onair
${WAIT_SIBS_TIMEOUT}  1  # unit: minutes
${IPHY_IP}  192.168.200.1
${FCT_IP}   192.168.255.1
${FTM_IP}   192.168.255.129
${REMOVE_LOGS}  off
${TCE_IP}   10.0.1.1
${TCE_PORT}  49150
${OMS_PORT}  49392
${ENB2_ALIAS}  enb2
${ENB2_IP}  10.0.1.4

${CONFIG_WA}    ${True}
${ERR_WRN_STATISTICS}    False


*** Keywords ***
Setup CUS Env
  [Arguments]  ${tl_type}=3CELLs_FDD  ${ue_count}=30  ${cfg}=auto
  [Documentation]  This keyword is to setup CUS env.
  ...  | step1 | decide golden template location according to enb and cus HW type and argument ${tl_type} |
  ...  | step2 | change vendor parameters defined in @{PARAMS_IN_VENDOR} |
  ...  | step3 | change swconfig file defined in @{PARAMS_IN_SWCONFIG} |
  ...  | step4 | change swconfig file defined in @{PARAMS_IN_SWCONFIG_CUS} |
  ...  | step5 | modify cus.yaml and config it |
  ...  | step6 | full commissioning SCFC with @{PARAMS_IN_SCF} |
  ...  | step7 | start WTS and wait BTS onair |
  ...  | step8 | if BTS can't onair, retry again |
  ...
  ...  | Arguments  | Man. | Default  | Description |
  ...  | tl_type    | No   | 3CELLs_FDD | specify golden template sub-directory |
  ...  | ue_count   | No   | 30     | specify ue number |
  ...
  ...  Examples
  ...  | Setup Cus Env | tl_type=3CELLs_FDD |
  ...  | Setup Cus Env | tl_type=3CELLs_FDD | ue_count=100 |
  Set Suite Variable  ${BTS_NUMBER}  1
#  _Sync uesim-dump From CUS To ta_messaging
  _Get CUS Info
  Run Keyword If  ${DEBUG}  Enter Into Debug Mode
  Return From Keyword If  ${DEBUG}
#  _Set VM Ip
  _Decide Config Path For UTE Cloud
  _Start BTS  ${tl_type}  ${ue_count}  ${cfg}

_Sync uesim-dump From CUS To ta_messaging
  Execute Cmd On Pc    ls -l /opt/cus/bin/uesim-dump /opt/emssim/util/uesim-dump*
  Execute Cmd On Pc    sudo rm -f /opt/emssim/util/uesim-dump; sudo cp -f /opt/cus/bin/uesim-dump /opt/emssim/util/uesim-dump
  Execute Cmd On Pc    sudo chmod 777 /opt/emssim/util/uesim-dump

Collect Logs For Startup
  [Arguments]  ${tag}  ${onair_status}
  Log To Console With Time Prefix  collecting logs
  Run Keyword And Ignore Error  Make Sure eNB CUS SSH OK
  Run Keyword If  '${onair_status}'=='${False}' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot ENB1  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2' and '${onair_status}'=='${False}' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot ENB2  ${tag}
  Run Keyword If  '${onair_status}'=='${True}' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot ENB1  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2' and '${onair_status}'=='${True}' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot ENB2  ${tag}
  ${SOS_REPORT_FLAG_WORK}  Set Variable If  '${onair_status}'=='${False}'  ${SOS_REPORT_FLAG_DIC['fail']}  ${SOS_REPORT_FLAG_DIC['pass']}
  Set Suite Variable  ${SOS_REPORT_FLAG_WORK}
  Run Keyword And Ignore Error  Stop Capture Logs  ${tag}
  Run Keyword And Ignore Error  Execute Cmd On Pc  cp -rf ${OUTPUT_DIR}/taf.ul.ue.sim.env_setup*.log ${SAVE LOG DIRECTORY}/${tag}_logs
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir  ${tag}
  Run Keyword And Ignore Error  Collect SAS Logs  ${tag}
  Analyze Logs  ${tag}  ${onair_status}
  Compress Directory  ${SAVE LOG DIRECTORY}/${tag}_logs
  Run Keyword If  '${BTS_NUMBER}'=='2'  Compress Directory  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}/${tag}_logs

Collect Snapshot Enb1
  [Arguments]  ${tag}=${EMPTY}
  ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
#  ${status}=  Run Keyword And Return Status  Collect Snapshot  ${snapshot_dir}/snapshot.zip
#  Run Keyword If    not ${status}  Execute Aashell Cmd  log -c full -a -z snapshot.zip  timeout=180
#  Run Keyword If    not ${status}  Get Enb File  /tmp/snapshot.zip  ${snapshot_dir}/snapshot.zip
  Wait Until Keyword Succeeds  5x  1min  Collect Snapshot  ${snapshot_dir}/snapshot.zip

Collect Snapshot Enb2
  [Arguments]  ${tag}=${EMPTY}
  ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}/${tag}_logs  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}
#  ${status}=  Run Keyword And Return Status  Collect Snapshot  ${snapshot_dir}/snapshot.zip  alias=${ENB2_ALIAS}
#  Run Keyword If    not ${status}  Execute Aashell Cmd Enb2  log -c full -a -z snapshot.zip  timeout=180
#  Run Keyword If    not ${status}  Get Enb File  /tmp/snapshot.zip  ${snapshot_dir}/snapshot.zip  alias=${ENB2_ALIAS}
  Wait Until Keyword Succeeds  5x  1min  Collect Snapshot  ${snapshot_dir}/snapshot.zip  connection=${ENB2_ALIAS}

Common Suite Setup
  ${time}  Get Time
  Log To Console  current time is ${time}
  Log Variables
  Conver some variables
  ${robot_version}  Execute Cmd On Pc  robot --version
  Run Keyword If  'Python 2.' in '${robot_version}'  fail  python2 not supported in cus
  # WA for https://jiradc.ext.net.nokia.com/browse/WSLTE-1212
  Execute Cmd On Pc  sudo chown root:root /usr/bin/dumpcap
  Execute Cmd On Pc  sudo chmod u=rwx,go=rx /usr/bin/dumpcap
  Execute Cmd On Pc  sudo /sbin/setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
  Run Keyword And Ignore Error  Kill Useless Local Hosts
  Run Keyword And Ignore Error  Execute Cmd On Pc  df -h ${OUTPUT_DIR}
  _Create Suite Log Directory
  _get testline info
  _get enb information
  Run Keyword And Ignore Error  Download Wireshark Plugin
  [Teardown]  _Analyze Failure Of eNB SSH Issue

Common Suite Teardown
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep node
  Run Keyword And Ignore Error  Teardown All Aliases For Admin
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep node
  Run Keyword And Ignore Error  Execute Cmd On Pc  netstat -ano | grep 3600
  Run Keyword And Ignore Error  Execute Cmd On Pc  who
  Run Keyword And Ignore Error  Teardown All Aliases For Infomodel
  Run Keyword And Ignore Error  Teardown All Aliases For Enb Fsmaccess
  Run Keyword And Ignore Error  Teardown All Aliases For Wts Fsmaccess
  #Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If All Tests Passed  Remove Directory  ${SUITE_LOG_DIRECTORY}  ${True}
  Comment  Run Keyword If  '${REMOVE_LOGS}'=='off'  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  cd ${SUITE_LOG_DIRECTORY}../; zip -r ${SUITE_LOG_DIRECTORY[:-1]}.zip ${SUITE_LOG_DIRECTORY.split("/")[-2]}  timeout=300
  Comment  Run Keyword If  '${REMOVE_LOGS}'=='off'  Run Keyword And Ignore Error  Remove Directory  ${SUITE_LOG_DIRECTORY}  ${True}
  Comment  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error  Execute Cmd On Pc Enb2  rm -rf ${SUITE_LOG_DIRECTORY}  600
#  Run Keyword And Ignore Error  Suite Teardown Report Rep  ${OUTPUT FILE}  ${MANUAL_AUTO_REPORT}



Common Suite Teardown And Restore BTS Configuration Parameters
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Collect SAS Logs
  Run Keyword And Ignore Error  Copy File  /opt/iphy/latest/egate_console.log  ${SUITE_LOG_DIRECTORY}
  Common Suite Teardown
  Run Keyword And Ignore Error  Execute Cmd On Pc  timedatectl
  Log To Console  LOG_DIR=${SUITE_LOG_DIRECTORY}

Common Test Setup
  _Create Test Log Directory

Common Test Setup And Start To Capture Logs
  Common Test Setup
  Start To Capture Logs
  ${case_begin_time}  Get Current Bts Time
  Set Test Variable  \${case_begin_time}

Ask scout to analyze scf
  [Arguments]    ${remove_postfix}=${True}
  # ask scout to analyze scf
  ${hostname1}    Execute Cmd On Pc    cat /etc/hostname | sed 's/-/_/g'
  ${hostname2}    Evaluate    re.sub("_1$", "", re.sub("_2$", "", "${host_name1}"))    re
  ${hostname}    set variable if    ${remove_postfix}    ${hostname2}    ${hostname1}
  scout.setup_scout    scout_testline_name=${hostname}
  scout.request_scf

Common Test Teardown
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Collect Snapshot ENB1
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If
  ...  '${BTS_NUMBER}'=='2' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'  Collect Snapshot ENB2
  Run Keyword If test passed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Collect Snapshot ENB1
  Run Keyword If Test passed  Run Keyword And Ignore Error  Run Keyword If
  ...  '${BTS_NUMBER}'=='2' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'  Collect Snapshot ENB2
  ${status}    run keyword and return status    Ask scout to analyze scf    remove_postfix=${False}
  Run Keyword If    not ${status}    run keyword and ignore error    Ask scout to analyze scf    remove_postfix=${True}

_print pystack for python hung issue
  execute cmd on pc  pip install pystack
  ${robot_path}  ${robot_name}  split path  ${SUITE_SOURCE}
  ${robot_pid}  get linux process id  robot  ${robot_name}
  ${pystack_path}  execute cmd on pc  which pystack
  execute cmd on pc  sudo -E ${pystack_path} remote ${robot_pid[0]} > ${SAVE LOG DIRECTORY}/pystack.log  timeout=600

Common Test Teardown And Stop Capture Logs
  Run Keyword And Ignore Error  run keyword if  'MessageObserverTimeout' in '${TEST_MESSAGE}'  _print pystack for python hung issue
  Run Keyword And Ignore Error  Release All UEs
  Sleep  10s  # make sure UE release procedure finished
  # collect and analyze logs
  Run Keyword If Test Failed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['fail']}
  Run Keyword If Test Passed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['pass']}
  Stop Capture Logs
  _Stop Case Specific Egate Console Log
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir
  Run Keyword If Test Failed  Set Test Variable  ${test_status}  FAIL
  Run Keyword If Test Passed  Set Test Variable  ${test_status}  PASS
  Analyze Logs  test_status=${test_status}
  Run Keyword And Ignore Error  Stop Rtpm Counter
  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error  Stop Rtpm Counter Enb2
  Common Test Teardown
  Run Keyword And Ignore Error  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If Test Passed
  ...  Remove Directory  ${SAVE LOG DIRECTORY}  ${True}
  Run Keyword If  '${REMOVE_LOGS}'=='off'  Compress Directory  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error  Execute Cmd On Pc Enb2
  ...  rm -rf ${SAVE LOG DIRECTORY}  600

Compress Directory
  [Arguments]  ${directory}
  ${directory}  Set Variable If  ${directory.endswith("/")}  ${directory[:-1]}  ${directory}
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd ${directory}/../; zip -r ${directory}.zip ${directory.split("/")[-1]};cd ~  timeout=300
  ${zip_status}  run keyword and return status  file should exist  ${directory}.zip
  Run Keyword And Ignore Error  Run Keyword If  ${zip_status}  Remove Directory  ${directory}  ${True}

Enter Into Debug Mode
  Execute Egate Command  trace_sim on mme=1 protocol=s1
  Execute UEx Command  sib_status

Make Sure eNB CUS SSH OK
  Comment  ${status}  Is Host Ping Ok  ${FCT_IP}  2
  Comment  Run Keyword If    not ${status}  Wait For All Hosts  ${FTM_IP}  timeout=300
  Comment  Run Keyword If    not ${status}  Disable Ethernet Port Security
  Comment  Run Keyword If    not ${status}  Wait For All Hosts  ${FCT_IP}  timeout=300
  Wait For All Hosts  ${FTM_IP}  ${FCT_IP}  timeout=300
  Run Keyword And Ignore Error  Wait For Host Ssh  ${FCT_IP}  timeout=180
  Run Keyword And Ignore Error  Wait For Host Ssh  ${IPHY_IP}  timeout=180

_Analyze Failure Of eNB SSH Issue
  Return From Keyword If  '${KEYWORD STATUS}'=='PASS'
  Run Keyword If  'Unable to connect to port 22 on 192.168.255.1' in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Blacklisted:failed to connect 192.168.255.1  WARN
#  Run Keyword If  'Unable to connect to port 22 on 192.168.255.1' in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
#  ...  Log To Console With Time Prefix  METIS=https://jiradc.ext.net.nokia.com/browse/WESTLAKE-8922  WARN
  Run Keyword If  'Unable to connect to port 22 on 192.168.255.1' in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure enb connection is reachable for local testline or reseved cloud testline.  WARN

_Start Case Specific Egate Console Log
  [Arguments]  ${tag}=${EMPTY}
  ${rrc_name}=  Set Variable If  ${tag.__len__()}==0  rrc.log  rrc_${tag}.log
  Run Keyword And Ignore Error  Execute Egate Command  set_log flush
  ${status}  ${TAIL_PID}  Run Keyword And Ignore Error  Tail Log  ${WTS_DIR}/egate_console.log
  ...  ${WTS_DIR}/${rrc_name}
  Set Suite Variable  ${TAIL_PID}
  Sleep  2s  #avoid missing the previous logs of the egate command immediated being executed

Start To Capture BTS Logs
  [Arguments]  ${tag}=${empty}
  [Documentation]  capture bts udplog and wireshark log, and so on
  ...  | 2016.6.24 | Zhang Yin |wireshart need to support both r3 and r4 | decide eth3 or br1 according to ${SW_RELEASE} |
  #Execute Cmd On Pc  netstat -na | grep 1500
  Start To Capture BTS UdpLogs  ${tag}
  #Execute Cmd On Pc  netstat -na | grep 1500
  Start To Capture Infomodel Log
  Run Keyword If    not 'startup' in '${tag}'  Start To Capture Wireshark Log  ${tag}  #start to capture after ssh succeeds for bts startup
  #Execute Cmd On Pc  netstat -na | grep 1500
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Start To Capture Emil Log  ${PARAMS_IN_EMIL}
#  ...  start to capture after ssh succeeds for bts startup
  #Execute Cmd On Pc  netstat -na | grep 1500
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Start To Capture Enb Ttitrace  ${tag}  #not capture during bts startup
  #Execute Cmd On Pc  netstat -na | grep 1500

Start To Capture BTS UdpLogs
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  Run Keyword And Ignore Error  collect_syslog_results  alias=enb1
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  start_syslog  ${btslog_dir}  ${btslog_name}  192.168.255.126  alias=enb1

Start To Capture Logs
  [Arguments]  ${tag}=${EMPTY}
  Start To Capture BTS Logs  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2'  Start To Capture BTS Logs eNB2  ${tag}
  Run Keyword And Ignore Error  Execute Cmd On Pc  rm -rf ${WTS_DIR}/rrc*.log
  Run Keyword If    not 'startup' in '${tag}'  _Start Case Specific Egate Console Log  ${tag}
  _Start To Capture UTE Wireshark  ${tag}
  Run Keyword If  'startup' not in '${tag}'  Start To Capture CUS PCAP

Stop Capture Logs
  [Arguments]  ${tag}=${EMPTY}
  _Stop Capture UTE Wireshark
  Stop Capture BTS Logs  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2'  Stop Capture BTS Logs eNB2  ${tag}
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep -e sim -e egate -e edaemon
  Run Keyword And Ignore Error  collect_wts_logs  ${tag}
  Run Keyword And Ignore Error  collect_uex_logs  ${tag}
  Run Keyword If  'startup' not in '${tag}'  Stop Capture Cus Pcap
  # When in BTS startup, copy case robot file to log path
  Run Keyword If  '${tag}'!='${EMPTY}'  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  cp -r ${SUITE SOURCE.rsplit("/", 1)[0]} ${SAVE LOG DIRECTORY.rsplit("/", 1)[0]}
  _Capture SosReport  ${tag}

_Stop Case Specific Egate Console Log
  Run Keyword And Ignore Error  Execute Egate Command  set_log flush
  Run Keyword And Ignore Error  Kill Linux Process  ${TAIL_PID}

Stop Capture BTS Logs
  [Arguments]  ${tag}=${empty}
  Stop Capture Wireshark Log  ${tag}
  Stop To Capture Infomodel Log  ${tag}
  Stop Capture BTS UdpLogs  ${tag}
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Stop Capture Emil Log
  Run Keyword If  'startup' in '${tag}' and '${EMIL_FLAG}' == '${True}'  Run Keyword And Ignore Error  Move Directory
  ...  ${SAVE LOG DIRECTORY}/cli_aatrace_log  ${SAVE LOG DIRECTORY}/${tag}_logs
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Stop Capture Enb TTITrace  ${tag}

Stop Capture BTS UdpLogs
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  collect_syslog_results  alias=enb1
  Run Keyword And Ignore Error  Execute Cmd On Pc  grep -i -e "reported alarm" -e "Please contact the owner" ${btslog_dir}/${btslog_name}
  ...  timeout=60  #move to keyword analylze_logs

Start To Capture Infomodel Log
  Return From Keyword If  ${IM_FLAG} is not ${True}
  ${bts_port}  ${use_ssl}  Define Admin Port
  Run Keyword And Ignore Error  Teardown Infomodel
  Run Keyword And Ignore Error  Setup Infomodel  port=${bts_port}  use_ssl=${use_ssl}
  ...  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs  address=${FTM_IP}
  Run Keyword And Ignore Error  Connect Infomodel

Stop To Capture Infomodel Log
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${IM_FLAG} is not ${True}
  ${im_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  infomodel_log.ims2  infomodel_log_${tag}.ims2
  ${im_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Save Infomodel Log  ${im_dir}${/}${im_name}
  Run Keyword And Ignore Error  Disconnect Infomodel
  Run Keyword And Ignore Error  Teardown Infomodel

_Capture SosReport
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${SOS_REPORT_FLAG_WORK} is not ${True}
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Execute Cmd On Pc  chmod +x /opt/cus/bin/cus-util.sh
  Execute Cmd On Pc  cd /opt/cus/bin;./cus-util.sh sosreport -c1 -s -p;cd ~  timeout=900
  Execute Cmd On Pc  mv /opt/iphy/latest/SosReport*.tgz ${log_dir}

_Copy Config Files To Log Dir
  [Arguments]  ${tag}=${EMPTY}
  ${target_dir}  set variable if  'startup' in '${tag}'   ${SAVE LOG DIRECTORY}/${tag}_logs/config
  ...  ${SAVE LOG DIRECTORY}/config
  Execute Cmd On Pc  mkdir -p ${target_dir}
  Run Keyword If  'startup' in '${tag}'  Copy File  ${SUITE_LOG_DIRECTORY}/scfc_logs/scf_for_startup.xml
  ...  ${target_dir}
  Run Keyword If  'startup' in '${tag}' and '${BTS_NUMBER}'=='2'
  ...  Copy File  ${SUITE_LOG_DIRECTORY}/${ENB2_ALIAS}/scfc_logs/scf_for_startup_enb2.xml  ${target_dir}
  Get Current Scf File  local_dir_path=${target_dir}  file_name=scf_after_test.xml  export_type=configurationAndRuntimeObjects
  Run Keyword If  '${BTS_NUMBER}'=='2'
  ...  Get Current Scf File  local_dir_path=${target_dir}  file_name=scf_after_test_enb2.xml  export_type=configurationAndRuntimeObjects
  ...  connection=${ENB2_ALIAS}
  Execute Cmd On Pc  cp -f /tmp/cus.yaml ${target_dir}
  Execute Cmd On Pc  cp -f /tmp/config.cfg /tmp/config.ini /tmp/UEDB.db /home/cus/test/ue_capabilities/* ${target_dir}
  Execute Cmd On Pc  cp -f ${SUITE_LOG_DIRECTORY}/swconfig_modified.txt ${target_dir}/enb_swconfig.txt
  Execute Cmd On Pc  cp -f ${SUITE_LOG_DIRECTORY}/swconfig_cus_modified.txt ${target_dir}/cus_swconfig.txt
  Run Keyword If  @{PARAMS_IN_VENDOR} != ['']  Execute Cmd On Pc  cp -f ${OUTPUT_DIR}/MODIFIED_vendor.xml ${target_dir}/vendor.xml

_Create Suite Log Directory
  ${timestamp}  Get Timestamp
  ${FILE_NAME} =  Replace String Using Regexp  ${SUITE_NAME[:50]}  \\s+$  ${EMPTY}
  ${SUITE_LOG_DIRECTORY} =  Catenate  SEPARATOR=${/}  ${OUTPUT_DIR}  ev_logs  ${FILE_NAME}_${timestamp}
  ${SUITE_LOG_DIRECTORY}  Replace String  ${SUITE_LOG_DIRECTORY}/  ${SPACE}  _
  Create Directory  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Log To Console  LOG_DIR=${SAVE LOG DIRECTORY}

_Create Test Log Directory
  ${TEST_LOG_DIR}  Catenate  SEPARATOR=${/}  ${SUITE_LOG_DIRECTORY}  ${TEST_NAME[:50]}
  ${TEST_LOG_DIR}  Replace String  ${TEST_LOG_DIR}/  ${SPACE}  _
  Create Directory  ${TEST_LOG_DIR}
  Set Suite Variable  ${TEST_LOG_DIR}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${TEST_LOG_DIR}

_Decide Config Path For UTE Cloud
  ${CONFIG_PATH}  Decide Configurate Files Path
  Set Suite Variable  \${CONFIG_PATH}

_Get CUS Info
  Setup Wts Fsm Access  fallback_prompt=#
  ${wts_hw_version}  Get Wts Hw Version
  log  cus_hw_version=${wts_hw_version}  console=True
  ${wts_sw_version}  Get Wts Sw Version
  log  cus_sw_version=CUS${wts_sw_version.split("CUS")[-1]}  level=WARN

_Set VM Ip
  Log To Console  10.0.1.31~10.0.1.40 for simulated eNB
  Execute Cmd On Pc  sudo ifconfig eth3:sgw 10.0.1.21/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB1 10.0.1.31/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB2 10.0.1.32/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB3 10.0.1.33/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB4 10.0.1.34/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB5 10.0.1.35/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB6 10.0.1.36/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB7 10.0.1.37/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB8 10.0.1.38/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB9 10.0.1.39/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB10 10.0.1.40/24 up
  Log To Console  10.0.1.41~10.0.1.50 for simulated GNB
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB1 10.0.1.41/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB2 10.0.1.42/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB3 10.0.1.43/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB4 10.0.1.44/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB5 10.0.1.45/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB6 10.0.1.46/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB7 10.0.1.47/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB8 10.0.1.48/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB9 10.0.1.49/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB10 10.0.1.50/24 up
  Log  10.0.1.3~10.0.1.12 will be deprecated  level=WARN
  Execute Cmd On Pc  sudo ifconfig eth3:enb42 10.0.1.3/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb43 10.0.1.4/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb44 10.0.1.5/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb45 10.0.1.6/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb46 10.0.1.7/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb47 10.0.1.8/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb48 10.0.1.9/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb49 10.0.1.10/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb50 10.0.1.11/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:enb51 10.0.1.12/24 up

_Set VM Ip For 2CUS Testline
#  Execute Cmd On Pc  sudo ifconfig eth3:enb42 down
#  Execute Cmd On Pc  sudo ifconfig eth3:enb43 down  #10.0.1.4 conflict with iphy enb2
#  Execute Cmd On Pc  sudo ifconfig eth3:enb44 down
#  Execute Cmd On Pc  sudo ifconfig eth3:sgw 10.0.1.21/24 up
  Execute Cmd On Pc  ip a s | grep 10.0.1 | grep -v 10.0.1.1
  Execute Cmd On Pc  ip a s | grep 10.0.1 | grep -v 10.0.1.1 | awk '{print $8}' | xargs -I {} sudo ifconfig {} down
  Execute Cmd On Pc  ip a s | grep 10.0.1 | grep -v 10.0.1.1 | awk '{print $5}' | xargs -I {} sudo ifconfig {} down
  Execute Cmd On Pc  ip a s | grep 10.0.1 | grep -v 10.0.1.1
  Log To Console  10.0.1.31~10.0.1.40 for simulated eNB
  Execute Cmd On Pc  sudo ifconfig eth3:sgw 10.0.1.21/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB1 10.0.1.31/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB2 10.0.1.32/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB3 10.0.1.33/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB4 10.0.1.34/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB5 10.0.1.35/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB6 10.0.1.36/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB7 10.0.1.37/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB8 10.0.1.38/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB9 10.0.1.39/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simeNB10 10.0.1.40/24 up
  Log To Console  10.0.1.41~10.0.1.50 for simulated GNB
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB1 10.0.1.41/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB2 10.0.1.42/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB3 10.0.1.43/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB4 10.0.1.44/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB5 10.0.1.45/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB6 10.0.1.46/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB7 10.0.1.47/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB8 10.0.1.48/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB9 10.0.1.49/24 up
  Execute Cmd On Pc  sudo ifconfig eth3:simGNB10 10.0.1.50/24 up

_Start To Monitor CPU Mem
  [Arguments]  ${tag}
  Return From Keyword If  ${UTE_CPU_MEM_FLAG} is not ${True}
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Comment  Run Keyword And Ignore Error  Execute Egate Command  cp /system_stats/get_testline_info.sh /home/ute  Copied
  Comment  Run Keyword And Ignore Error  Execute Egate Command  cp /system_stats/cpu_stats.sh /home/ute  Copied
  Comment  Run Keyword And Ignore Error  Execute Egate Command  cp /system_stats/system_stats.sh /home/ute  Copied
  Run Keyword And Ignore Error  Execute Cmd On Pc  cp ${CURDIR}/tools/*.sh /home/ute
  Run Keyword And Ignore Error  Execute Cmd On Pc  chmod +x /home/ute/*.sh
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute;./get_testline_info.sh > ${log_dir}/tl_info.log
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute;./cpu_stats.sh ${log_dir}/cpu_stats.log >& ${log_dir}/cpu_error.txt&
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  cd /home/ute;./system_stats.sh > ${log_dir}/system_stats.log 2>${log_dir}/system_stats_error.log&

_Stop To Monitor CPU Mem
  Return From Keyword If  ${UTE_CPU_MEM_FLAG} is not ${True}
  ${status}  @{pids_sys}  Run Keyword And Ignore Error  Get Linux Process Id  cpu_stats
  FOR  ${pid}  IN  @{pids_sys}
    Run Keyword And Ignore Error  Kill Linux Process  ${pid}
  END
  @{pids_sys}  Get Linux Process Id  system_stats
  FOR  ${pid}  IN  @{pids_sys}
    Run Keyword And Ignore Error  Kill Linux Process  ${pid}
  END
  Run Keyword And Ignore Error  Execute Cmd On Pc  pwd

_get enb information
  Log To Console  ===get enb info===
  #make sure ssh work
  Setup Enb Fsm Access  fallback_prompt=#  host=${FTM_IP}
  Wait For All Hosts  ${FTM_IP}  timeout=600
  ${bts_port}  ${use_ssl}  Define Admin Port
  Setup Admin  bts_port=${bts_port}  use_ssl=${use_ssl}
  ...  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs  timeout=120  bts_host=${FTM_IP}
#  Run Keyword And Ignore Error  Disable Ethernet Port Security
#  Run Keyword And Ignore Error  Enable Ssh Access
#  Wait For Host Ssh  ${FCT_IP}  timeout=60
  #get enb info
  ${ENB_SW_VERSION}  Get Enb Sw Version
  Log  activeBuildVersion\=${ENB_SW_VERSION}  level=WARN
  Set Suite Variable  ${ENB_SW_VERSION}
  ${ENB_HW_VERSION}  Get Enb Hw Version
  Log  enb_hw_version\=${ENB_HW_VERSION}  console=True
  Set Suite Variable  ${ENB_HW_VERSION}
  ${BBU_TYPE}  Get Bbu Type
  Log  bbu_type\=${BBU_TYPE}  console=True
  Set Suite Variable  ${BBU_TYPE}
  ${BBMOD_TYPE}  Get Bbmod Type
  Log  bbmod_type\=${BBMOD_TYPE}  console=True
  Set Suite Variable  ${BBMOD_TYPE}
  ${RACK_POSITION}  Get Rack Position
  Set Suite Variable  ${RACK_POSITION}
  Log  rack_position\=${RACK_POSITION}  console=True

_Update CUS Yaml
  [Arguments]  ${input_yaml}  ${ue_count}  ${scf_params}
  Setup Yaml  ${input_yaml}  ${ue_count}  ${scf_params}
  ${status}  Run Keyword And Return Status  Keyword Should Exist  ${Keyword_Modify_Yaml}
  Run Keyword If  ${status}  ${Keyword_Modify_Yaml}
  Teardown Yaml  /tmp/cus.yaml
  ${out}    Execute CUS Cmd    config update /tmp/cus.yaml
  Run Keyword If  "ERROR: EGATE startup failed" in '''${out}''' and "Ambiguous" in '''${out}'''  Log  egate startup failed
  ...  ELSE IF  "ERROR: Cannot align to the required Esim version" in '''${out}'''  log  check esim version failed
  ...  ELSE IF  "ERROR:" in '''${out}'''  Fail  cus.yaml is wrong, please check the result of config update /tmp/cus.yaml in the prevous step
  ...  ELSE  Log  pass
  [Return]  /tmp/cus.yaml

_Update 2CUS Yaml
  [Arguments]  ${input_yaml_enb1}  ${scf_params_enb1}  ${input_yaml_enb2}  ${scf_params_enb2}  ${ue_count}
  Setup Yaml 2CUS  ${input_yaml_enb1}  ${scf_params_enb1}  ${input_yaml_enb2}  ${scf_params_enb2}  ${ue_count}
  ${status}  Run Keyword And Return Status  Keyword Should Exist  ${Keyword_Modify_Yaml}
  Run Keyword If  ${status}  ${Keyword_Modify_Yaml}
  Teardown Yaml  /tmp/cus.yaml
  ${out}    Execute CUS Cmd    config update /tmp/cus.yaml
  Run Keyword If  "ERROR: EGATE startup failed" in '''${out}''' and "Ambiguous" in '''${out}'''  Log  egate startup failed
  ...  ELSE IF  "ERROR:" in '''${out}'''  Fail  cus.yaml is wrong, please check the result of config update /tmp/cus.yaml in the prevous step
  ...  ELSE  Log  pass
  [Return]  /tmp/cus.yaml

_Restart Edaemon Egate
  _kill edaemon and egate
  Execute Cmd On Pc  cd /opt/iphy/latest
  Execute Cmd On Pc  sudo ./edaemon --port 10000
  Execute Cmd On Pc  ./egate --port 20000

_Start BTS
  [Arguments]  ${tl_type}  ${ue_count}  ${cfg}
  ${onair_status}  set variable  ${True}
  _Restart Edaemon Egate
  run keyword and ignore error  Execute Cmd On Pc  rm -rf ${OUTPUT_DIR}/taf.ul.ue.sim.env_setup*.log
  Start To Capture Logs  startup
  Run Keyword And Ignore Error    Execute uex command  sib_status  # in order to start uexgate to start uex logs
  Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/enb_swconfig.txt
  # use ${CONFIG_PATH}/cus_swconfig.txt if exist, otherwise get it from 192.168.200.1
  Change Swconfig File Of CUS    ${PARAMS_IN_SWCONFIG_CUS}    ${CONFIG_PATH}/cus_swconfig.txt
  ${cus_yaml}  Run Keyword If  '${cfg}' == 'auto'  _Update CUS Yaml  ${CONFIG_PATH}/${tl_type}/cus.yaml  ${ue_count}  ${PARAMS_IN_SCF}
  ...  ELSE  set variable    ${CONFIG_PATH}/${tl_type}/${cfg}
  ${scf_for_startup}  Modify Golden SCF  ${CONFIG_PATH}/${tl_type}/SCFC_1.xml  ${PARAMS_IN_SCF}
  ${vendor_params}  format_vendor_params  ${PARAMS_IN_VENDOR}
  #Add Simulator  cus   ${cus_yaml}  warning_lookup=True
  Add Simulator  cus   ${cus_yaml}  warning_lookup=False
  Add Enb Configuration  ${scf_for_startup}  vendor_params=${vendor_params}
  ${onair_status}  set variable  ${False}
  Configure Environment
  ${onair_status}  set variable  ${True}
  ${status}  Run Keyword And Return Status  Keyword Should Exist  ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  Run Keyword If  ${status}  ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  [Teardown]  Collect Logs For Startup  startup  ${onair_status}

_Adapt SCFC For Enb1
  [Arguments]  ${scfc}
  ${scf_after_adapt}  Set Variable  ${scfc.rpartition("/")[0]}/SCFC_1_enb1.xml
  Copy File  ${scfc}  ${scf_after_adapt}
  ${enb1_conf}  Create List
  ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr=10.0.1.2
  ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=10.0.1.1
#  @{cell_instances}  get_all_cells_instance  ${scf_after_adapt}
#  FOR  ${index}  IN RANGE  ${cell_instances.__len__()}
#    Execute Cmd On Pc  sed -i "s:LCELL-${${index}+1}\\b:LCELL-${11+${index}}:g" ${scf_after_adapt}
#    Append To List  ${enb1_conf}  @{cell_instances}[${index}]:lcrId=${11+${index}}
#    Append To List  ${enb1_conf}  @{cell_instances}[${index}]:phyCellId=${11+${index}}
#  END
  ${xpath}  Match To Xpath  ${enb1_conf}
  Modify Xml  ${scf_after_adapt}  ${scf_after_adapt}  ${xpath}
  [Return]  ${scf_after_adapt}

_Adapt SCFC For Enb2
  [Arguments]  ${scfc}
  ${scf_after_adapt}  Set Variable  ${scfc.rpartition("/")[0]}/SCFC_1_enb2.xml
  Copy File  ${scfc}  ${scf_after_adapt}
  Execute Cmd On Pc  sed -i "s:MRBTS-1:MRBTS-2:g" ${scf_after_adapt}
  Execute Cmd On Pc  sed -i "s:LNBTS-1:LNBTS-2:g" ${scf_after_adapt}
  ${enb2_conf}  Create List
  ...  MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr=${ENB2_IP}
  ...  MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=10.0.1.3
  @{cell_instances}  get_all_cells_instance  ${scf_after_adapt}
  FOR  ${index}  IN RANGE  ${cell_instances.__len__()}
    Execute Cmd On Pc  sed -i "s:LCELL-${${index}+1}\\b:LCELL-${51+${index}}:g" ${scf_after_adapt}
    Append To List  ${enb2_conf}  ${cell_instances}[${index}]:lcrId=${51+${index}}
    Append To List  ${enb2_conf}  ${cell_instances}[${index}]:phyCellId=${51+${index}}
  END
  Add Xml Element  ${scf_after_adapt}  ${scf_after_adapt}  <p name="totalDelayFromSHM">3</p>|//managedObject[matches(@distName, '.*CLOCK-1$')]
  ${xpath}  Match To Xpath  ${enb2_conf}
  Modify Xml  ${scf_after_adapt}  ${scf_after_adapt}  ${xpath}
  [Return]  ${scf_after_adapt}

_Start 2BTS
  [Arguments]  ${tl_type}  ${tl_type_enb2}  ${ue_count}
  ${onair_status}  set variable  ${True}
  _Restart Edaemon Egate
  run keyword and ignore error  Execute Cmd On Pc  rm -rf ${OUTPUT_DIR}/taf.ul.ue.sim.env_setup*.log
  Start To Capture Logs  startup
  execute uex command  sib_status  # in order to start uexgate to start uex logs
  Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/enb_swconfig.txt
  Change Swconfig File Of ENB2  ${PARAMS_IN_SWCONFIG_ENB2}  ${CONFIG_PATH}${/}enb_swconfig.txt
  Change Swconfig File Of CUS    ${PARAMS_IN_SWCONFIG_CUS}    ${CONFIG_PATH}/cus_swconfig.txt
  ${cus_yaml}  _Update 2CUS Yaml  ${CONFIG_PATH}/${tl_type}/cus.yaml  ${PARAMS_IN_SCF}
  ...    ${CONFIG_PATH}/${tl_type_enb2}/cus.yaml  ${PARAMS_IN_SCF_ENB2}
  ...    ${ue_count}
  ${scfc_base_enb1}  _Adapt SCFC For Enb1  ${CONFIG_PATH}${/}${tl_type}${/}SCFC_1.xml
  ${scf_for_startup_enb1}  Modify Golden SCF  ${scfc_base_enb1}  ${PARAMS_IN_SCF}
  ${scfc_base_enb2}  _Adapt SCFC For ENB2  ${CONFIG_PATH}${/}${tl_type_enb2}${/}SCFC_1.xml
  ${scf_for_startup_enb2}  Modify Golden SCF eNB2  ${scfc_base_enb2}  ${PARAMS_IN_SCF_ENB2}
  ${vendor_params_enb1}  format_vendor_params  ${PARAMS_IN_VENDOR}
  ${vendor_params_enb2}  format_vendor_params  ${PARAMS_IN_VENDOR_ENB2}
#  Add Simulator  cus   ${cus_yaml}  warning_lookup=True
  Add Simulator  cus   ${cus_yaml}  warning_lookup=False
  Add Enb Configuration  ${scf_for_startup_enb1}  vendor_params=${vendor_params_enb1}  host_id=1
  Add Enb Configuration  ${scf_for_startup_enb2}  vendor_params=${vendor_params_enb2}  host_id=2
  ${onair_status}  set variable  ${False}
  Configure Environment
  ${onair_status}  set variable  ${True}
  ${status}  Run Keyword And Return Status  Keyword Should Exist  ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  Run Keyword If  ${status}  ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  [Teardown]  Collect Logs For Startup  startup  ${onair_status}

_Start To Capture UTE Wireshark
  [Arguments]  ${tag}
  Return From Keyword If  ${UTE_WIRESHARK_FLAG} is not ${True} and 'startup' not in '${tag}'
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  tshark -i eth3 -i eth4 -w ${log_dir}/ute_wireshark.pcap>& tmp.txt&
  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  120  10  File Should Exist  ${log_dir}/ute_wireshark.pcap

_Stop Capture UTE Wireshark
  ${tshark_pid}  get_linux_process_id  tshark  ute_wireshark
  kill_linux_process  ${tshark_pid}

Start Rtpm Counter
  [Arguments]  ${tag}=${EMPTY}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to start rtpm counter
  ...  \ \ \ \ \ \ | 1) | set rtpm parameters to activate rtpm function |
  ...  \ \ \ \ \ | 2) | start rtpm receiver: execute nc -l -p 49525 -s 10.0.1.1 > rtpm_10.0.1.1_49525.bin |
  ...  \ \ \ \ | 3) | wait until rtpm receiver connected to eNB |
  ${rtpm_params}  Create List  LNBTS:actRtPerfMonitoring=All_PM_Counters  PMCADM-1:rTPmCollEntity:rTPmCollEntityHost=10.0.1.1
  ...  PMCADM-1:rTPmCollEntity:rTPmCollEntityPortNum=49525  PMCADM-1:rTPmCollEntity:rTPmCollInterval=60s
  Delta Commission Parameters  ${rtpm_params}
  Sleep  10s
  Start Rtpm Receiver  ${tag}

Start Rtpm Counter enb2
  [Arguments]  ${tag}=${EMPTY}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to start rtpm counter
  ...  \ \ \ \ \ \ | 1) | set rtpm parameters to activate rtpm function |
  ...  \ \ \ \ \ | 2) | start rtpm receiver: execute nc -l -p 49526 -s 10.0.1.1 > rtpm_10.0.1.1_49525.bin |
  ...  \ \ \ \ | 3) | wait until rtpm receiver connected to eNB |
  ${rtpm_params}  Create List  LNBTS:actRtPerfMonitoring=All_PM_Counters  PMCADM-1:rTPmCollEntity:rTPmCollEntityHost=10.0.1.1
  ...  PMCADM-1:rTPmCollEntity:rTPmCollEntityPortNum=49526  PMCADM-1:rTPmCollEntity:rTPmCollInterval=60s
  Delta Commission Parameters Enb2  ${rtpm_params}
  Sleep  10s
  Start Rtpm Receiver Enb2  ${tag}

_Kill Edaemon And Egate
  Run Keyword And Ignore Error  Execute Cmd On Pc  sudo pkill edaemon
  Run Keyword And Ignore Error  Execute Cmd On Pc  sudo pkill egate
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep -e edaemon -e egate
  Run Keyword And Ignore Error  Execute Cmd On Pc  sudo rm -rf ${WTS_DIR}/*.log*
  Run Keyword And Ignore Error  Execute Cmd On Pc  lsmod | grep sctp
  Run Keyword And Ignore Error  Execute Cmd On Pc  sudo modinfo sctp

_Start Iphy DL Antenna Dump
  Return From Keyword If  ${ANTENNA_DUMP_FLAG} is not ${True}
  Execute Command On Wts  rm -rf /ram/antennaDump*
  Run Keyword If  '${ANTENNA_DUMP_OPTION.__len__()}'!='0'  execute_iphy_dump_dl  ${ANTENNA_DUMP_OPTION}

_Stop Iphy DL Antenna Dump
  Return From Keyword If  ${ANTENNA_DUMP_FLAG} is not ${True}
  Run Keyword If  '${ANTENNA_DUMP_OPTION.__len__()}'=='0'  execute_iphy_dump_dl
  Execute Command On Wts  ls -ltr /ram/ | grep -i antenna
  Execute Command On Wts  mkdir -p /ram/antennaDump
  Execute Command On Wts  mv /ram/antennaDump_*.dat /ram/antennaDump
  Execute Cmd On Pc  rm -rf /home/ute/ram
  Sftp Download  ${IPHY_IP}  22  toor4nsn  oZPS0POrRieRtu  /ram/antennaDump/  /home/ute
  Execute Cmd On Pc  mv /home/ute/ram/antennaDump/ ${SAVE LOG DIRECTORY}

_check SIB1 And SIB2
  [Arguments]  ${cell_id}=all
  @{cells_to_check}  Run Keyword If  '${cell_id}'=='all'  Get All Cells ID
  ...  ELSE  Create List  ${cell_id}
  FOR  ${cell}  IN  @{cells_to_check}
    ${instance_id}  Set Variable If  '${cell_id}'=='all'  ${cell[0]}  ${cell_id}
    ${lcr_id}  Set Variable If  '${cell_id}'=='all'  ${cell[1]}  ${cell_id}
    ${cellTechnology}=  Get SCF Parameter Value  LNCEL-${instance_id}:cellTechnology
    # check sibs for nb-iot cells (only sibs, no mib)
    Run Keyword If  "nb-iot" in "${cellTechnology.lower()}"  Execute UEx Command  wait_for_ovhd cell=${lcr_id} timeout=${WAIT_SIBS_TIMEOUT}
    Continue For Loop If  "nb-iot" in "${cellTechnology.lower()}"
    # no SIB for LAA cell
    ${earfcn}  Run Keyword If  "fdd" in "${cellTechnology.lower()}"  Get SCF Parameter Value  LNCEL-${instance_id}/LNCEL_FDD-0:earfcnDL
    ...  ELSE  Get SCF Parameter Value  LNCEL-${instance_id}/LNCEL_TDD-0:earfcn
    Continue For Loop If  47088<${earfcn}<53543
    # check sibs for other cells
    Execute UEx Command  wait_for_ovhd cell=${lcr_id} timeout=${WAIT_SIBS_TIMEOUT}
  END

_check SIB1 And SIB2 eNB2
  [Arguments]  ${cell_id}=all
  @{cells_to_check}  Run Keyword If  '${cell_id}'=='all'  Get All Cells ID eNB2
  ...  ELSE  Create List  ${cell_id}
  FOR  ${cell}  IN  @{cells_to_check}
    ${instance_id}  Set Variable If  '${cell_id}'=='all'  ${cell[0]}  ${cell_id}
    ${lcr_id}  Set Variable If  '${cell_id}'=='all'  ${cell[1]}  ${cell_id}
    ${cellTechnology}=  Get SCF Parameter Value eNB2  LNCEL-${instance_id}:cellTechnology
    # check sibs for nb-iot cells (only sibs, no mib)
    Run Keyword If  "nb-iot" in "${cellTechnology.lower()}"  Execute UEx Command  wait_for_ovhd cell=${lcr_id} timeout=${WAIT_SIBS_TIMEOUT}
    Continue For Loop If  "nb-iot" in "${cellTechnology.lower()}"
    # no SIB for LAA cell
    ${earfcn}  Run Keyword If  "fdd" in "${cellTechnology.lower()}"  Get SCF Parameter Value eNB2  LNCEL-${instance_id}/LNCEL_FDD-0:earfcnDL
    ...  ELSE  Get SCF Parameter Value eNB2  LNCEL-${instance_id}/LNCEL_TDD-0:earfcn
    Continue For Loop If  47088<${earfcn}<53543
    # check sibs for other cells
    Execute UEx Command  wait_for_ovhd cell=${lcr_id} timeout=${WAIT_SIBS_TIMEOUT}
  END

_Analyze Failure Of Iphy SSH Issue
  Return From Keyword If  '${KEYWORD STATUS}'=='PASS'
  Run Keyword If  'Unable to connect to port 22 on 192.168.200.1' or 'SSHClientException' in '${KEYWORD MESSAGE}'  Log To Console With Time Prefix
  ...  Auto Blacklisted:failed to connect 192.168.200.1  WARN
  Run Keyword If  'Unable to connect to port 22 on 192.168.200.1' or 'SSHClientException' in '${KEYWORD MESSAGE}'  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure iphy connection is reachable for local testline or reseved cloud testline.  WARN

Cells Should Be OnAir
  [Arguments]  ${cell_id}=all  ${timeout}=360
  # timeout is extended from 3min to 6min, because chbw online change will cause other cells graceful shutdown
  Run Keyword If  '${cell_id}'=='all'  Query Infomodel  every //CELL_M-* is [stateInfo.proceduralState=OnAirDone]  timeout=${timeout}
  Run Keyword If  '${cell_id}'!='all'  Query Infomodel  //CELL_M-${cell_id} is [stateInfo.proceduralState=OnAirDone]  timeout=${timeout}
  _check SIB1 And SIB2  ${cell_id}

Cells Should Be OnAir eNB2
  [Arguments]  ${cell_id}=all  ${timeout}=360
  # timeout is extended from 3min to 6min, because chbw online change will cause other cells graceful shutdown
  Run Keyword If  '${cell_id}'=='all'  Query Infomodel  every //CELL_M-* is [stateInfo.proceduralState=OnAirDone]  timeout=${timeout}
  ...  alias=${ENB2_ALIAS}
  Run Keyword If  '${cell_id}'!='all'  Query Infomodel  //CELL_M-${cell_id} is [stateInfo.proceduralState=OnAirDone]  timeout=${timeout}
  ...  alias=${ENB2_ALIAS}
  _check SIB1 And SIB2 eNB2  ${cell_id}

_get testline info
  #get testline info
  Log To Console  ===get testline info===
  ${testline_ip}  Execute Cmd On Pc  sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
  Set Suite Variable  ${testline_ip}
  Log  TestLineIpAddress\=${testline_ip}  console=True
  ${testline_hostname}  Execute Cmd On Pc  hostname
  Log  TestLineHostName\=${testline_hostname}  level=WARN
  Run Keyword And Ignore Error  Execute Cmd On Pc  robot --version
  Run Keyword And Ignore Error  Execute Cmd On Pc  svn info "${CURDIR}"
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  pip list | grep -e ute -e kiss -e ta-a2a -e ta-ssh -e ta-xml -e taf.collectors -e taf.sbts.oam.coam.admin
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  pip list | grep -e ta-uexgate -e ta-messaging -e taf.ul.ue.sim.env-setup -e plugin
  ${ute_version}  Execute Cmd On Pc  ute-setup -v
  Run Keyword And Ignore Error  Log  UTE_VERSION\=${ute_version.split()[-1]}  level=WARN
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute/MN/UTE/robotlte;git log -n1;cd ~

_Setup enb2
  set suite variable  ${ENB2_PC_IP}  ${tl.test_pcs[1].default_ssh_connection_details.addr}
  log to console  ENB2_PC_IP=${ENB2_PC_IP}
  Setup Enb Fsm Access  remote_host=${ENB2_PC_IP}  alias=${ENB2_ALIAS}
  ${RACK_POSITION_ENB2}  Get Rack Position Enb2
  Set Suite Variable  ${RACK_POSITION_ENB2}
  Log  rack_position\=${RACK_POSITION_ENB2} in eNB2  console=True

Start To Capture BTS Logs eNB2
  [Arguments]  ${tag}=${empty}
  Start To Capture BTS UdpLogs eNB2  ${tag}
  Start To Capture Wireshark Log eNB2  ${tag}
  Start To Capture Infomodel Log eNB2
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Start To Capture Emil Log Enb2  ${PARAMS_IN_EMIL_ENB2}
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Start To Capture Enb Ttitrace Enb2  ${tag}

File Should Not Be Empty In VM2
  [Arguments]    ${file}
  ${out}    Execute Cmd On Pc Enb2    head -5 ${file}
  Should Not Be Empty    ${out}
  Should Not Contain    ${out}    No such file or directory

Start To Capture BTS UdpLogs eNB2
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  Execute Cmd On Pc Enb2    pkill cli_syslog.py
  Execute Cmd On Pc Enb2    rm -rf /home/ute/btslog.LOG
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}/${tag}_logs  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}
#  Run Keyword And Ignore Error  Start Collect Btslog With Taf  ${ENB2_ALIAS}
  ${btslog_cmd}  Catenate  nohup cli_syslog.py -d /home/ute/ -l "${btslog_name}" -i "192.168.255.126" -s 0 -p 51000 51001 51003 50011
  ...    > /tmp/nohup_u1.out 2>&1 &
  Execute Cmd On Pc Enb2    ${btslog_cmd}
  Run Keyword And Ignore Error    Wait Until Keyword Succeeds    120    10    File Should Not Be Empty In VM2    /home/ute/${btslog_name}

Start Collect Btslog With Taf
  [Arguments]    ${btslog_name}=btslog
  run keyword and ignore error   core.teardown_collectors    names=${btslog_name}
  btslog.create_btslog_collector   name=${btslog_name}
  btslog.set suite Alias        ${btslog_name}
  core.setup_collectors    names=${btslog_name}
  core.start_collectors    names=${btslog_name}

Start To Capture Infomodel Log eNB2
  Return From Keyword If  ${IM_FLAG} is not ${True}
  ${bts_port}  ${use_ssl}  Define Admin Port
  Run Keyword And Ignore Error  Setup Infomodel  port=${bts_port}  use_ssl=${use_ssl}  alias=${ENB2_ALIAS}  address=${ENB2_IP}
  ...  admin_api_log_dir=${SAVE LOG DIRECTORY}/${ENB2_ALIAS}/admin_logs
  Run Keyword And Ignore Error  Connect Infomodel  alias=${ENB2_ALIAS}

Stop To Capture Infomodel Log eNB2
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${IM_FLAG} is not ${True}
  ${im_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  infomodel_log.ims2  infomodel_log_${tag}.ims2
  ${im_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}/${tag}_logs  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}
  Run Keyword And Ignore Error  Save Infomodel Log  ${im_dir}/${im_name}  alias=${ENB2_ALIAS}
  Run Keyword And Ignore Error  Disconnect Infomodel  alias=${ENB2_ALIAS}
  Run Keyword And Ignore Error  Teardown Infomodel  alias=${ENB2_ALIAS}

Stop Capture BTS Logs eNB2
  [Arguments]  ${tag}=${empty}
  Stop Capture Wireshark Log eNB2  ${tag}
  Stop To Capture Infomodel Log eNB2  ${tag}
  Stop Capture BTS UdpLogs eNB2  ${tag}
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Stop Capture Emil Log Enb2
  Run Keyword If    not 'startup' in '${tag}'  Run Keyword And Ignore Error  Stop Capture Enb Ttitrace Enb2  ${tag}

Stop Capture BTS UdpLogs eNB2
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}/${tag}_logs  ${SAVE LOG DIRECTORY}/${ENB2_ALIAS}
  Comment  Run Keyword And Ignore Error  collect_syslog_results  alias=${ENB2_ALIAS}
#  Run Keyword And Ignore Error  Stop Collect Btslog With Taf  ${ENB2_ALIAS}
  Execute Cmd On Pc Enb2    pkill cli_syslog.py
  Execute Cmd On Pc    scp -r ${ENB2_PC_IP}:/home/ute/${btslog_name} ${btslog_dir}
  Execute Cmd On Pc Enb2    rm -rf /home/ute/${btslog_name}

Stop Collect Btslog With Taf
  [Arguments]    ${btslog_name}=btslog1  ${target_dir}=${SAVE LOG DIRECTORY}
  core.stop_collectors    names=${btslog_name}
  core.collect_collectors    names=${btslog_name}   target_dir=${target_dir}
  [Teardown]    run keyword and ignore error   core.teardown_collectors    names=${btslog_name}

Conver some variables
   ${SOS_REPORT_FLAG_DIC}  Update list parameters to DIC  ${SOS_REPORT_FLAG}
   ${SNAPSHOT_FLAG_DIC}  Update list parameters to DIC  ${SNAPSHOT_FLAG}
   ${SOS_REPORT_STARTUP_1_FLAG_DIC}  Update list parameters to DIC  ${SOS_REPORT_STARTUP_1_FLAG}
   Set suite variable  ${SOS_REPORT_FLAG_DIC}
   Set suite variable  ${SNAPSHOT_FLAG_DIC}
   Set suite variable  ${SOS_REPORT_STARTUP_1_FLAG_DIC}

Update list parameters to DIC
  [Arguments]  ${params}
  ${param_dict}  Create Dictionary
  ${params_list}  set variable  ${params.split(',')}
  BuiltIn.Log  ${params_list[0]}
  FOR  ${index}  IN RANGE  0  len(${params_list})
       ${item_list}  set variable  ${params_list[${index}].split(':')}
       set to dictionary  ${param_dict}  ${item_list[0]}  ${item_list[1]}
  END
  [Return]  ${param_dict}

Setup 2CUS Env
  [Arguments]  ${tl_type}=3CELLs_FDD  ${tl_type_enb2}=3CELLs_FDD  ${ue_count}=30
  [Documentation]  This keyword is to setup 2CUS env.
  ...  | step1 | decide golden template location according to enb and cus HW type and argument ${tl_type}, ${tl_type_enb2} |
  ...  | step2 | change vendor parameters defined in @{PARAMS_IN_VENDOR} for enb1, and @{PARAMS_IN_VENDOR_ENB2} for enb2 |
  ...  | step3 | change swconfig file defined in @{PARAMS_IN_SWCONFIG} for enb1, and @{PARAMS_IN_SWCONFIG_ENB2} for enb2 |
  ...  | step4 | change swconfig file defined in @{PARAMS_IN_SWCONFIG_CUS} for enb1 and enb2 |
  ...  | step5 | modify cus.yaml and config it |
  ...  | step6 | full commissioning SCFC with @{PARAMS_IN_SCF} for enb1, and @{PARAMS_IN_SCF_ENB2} for enb2 |
  ...  | step7 | start WTS and wait BTS onair |
  ...  | step8 | if BTS can't onair, retry again |
  ...
  ...  | Arguments  | Man. | Default  | Description |
  ...  | tl_type    | No   | 3CELLs_FDD | specify golden template sub-directory |
  ...  | ue_count   | No   | 30     | specify ue number |
  ...
  ...  Examples
  ...  | Setup 2Cus Env | tl_type=3CELLs_FDD | tl_type_enb2=3CELLs_FDD
  ...  | Setup 2Cus Env | tl_type=3CELLs_FDD | tl_type_enb2=3CELLs_FDD | ue_count=100 |
  Set Suite Variable  ${BTS_NUMBER}  2
  _Setup enb2
#  _Sync uesim-dump From CUS To ta_messaging
  _Get CUS Info
#  _Set VM Ip For 2CUS Testline
  Run Keyword If  ${DEBUG}  Enter Into Debug Mode
  Return From Keyword If  ${DEBUG}
  _Decide Config Path For UTE Cloud
  _Start 2BTS  ${tl_type}  ${tl_type_enb2}  ${ue_count}

