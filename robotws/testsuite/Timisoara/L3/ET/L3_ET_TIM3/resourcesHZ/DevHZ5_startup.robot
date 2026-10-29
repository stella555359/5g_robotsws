*** Setting ***
Documentation       resources for et env
Library    OperatingSystem
Library    String
Library    DevHZ5_lib/src/DevHZ5_lib.py
Library    Process
Library    XML  use_lxml=True
Library    Collections
Library    ute_fsmaccess
Library    taf.sbts.oam.coam.admin
Library    ute_syslog
Library    ute_admin_infomodel
Library    ta_a2a
Library    DateTime
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog

*** Variables ***
${DEBUG}  ${False}
@{PARAMS_IN_SCF}  ${EMPTY}
@{PARAMS_IN_VENDOR}  ${EMPTY}
@{PARAMS_IN_SWCONFIG}  ${EMPTY}
@{PARAMS_IN_ENV_SWCONFIG}    classical:::::SBTS22R3:0x450027=1
...    classical:::::SBTS22R2:0x45005A=1
...    classical:::::SBTS22R1:0x45005A=1
...    classical:::::SBTS21B:0x45005A=1
...    classical:::::SBTS22R4:0x450027=1
@{PARAMS_IN_CP_UE_RD}  ${EMPTY}
@{PARAMS_IN_CP_CL_RD}  ${EMPTY}
@{PARAMS_IN_CP_RUNTIME}  ${EMPTY}
@{PARAMS_IN_EMIL}  ${EMPTY}
@{PARAMS_IN_IPHY_XML}  ${EMPTY}
@{PARAMS_IN_APCONFIG_XML}  ${EMPTY}
@{PARAMS_IN_SWCONFIG_AP}  ${EMPTY}
@{PARAMS_IN_ENV_SWCONFIG_AP}  ${EMPTY}
@{PARAMS_IN_GNBMIRROR}  ${EMPTY}
@{PARAMS_IN_APMIRROR}    ${EMPTY}
${PM_COUNTER_INTERVAL}    5min
@{PARAMS_IN_SCF_GNB2}  ${EMPTY}
@{PARAMS_IN_VENDOR_GNB2}  ${EMPTY}
@{PARAMS_IN_SWCONFIG_GNB2}  ${EMPTY}
@{PARAMS_IN_CP_UE_RD_GNB2}  ${EMPTY}
@{PARAMS_IN_CP_CL_RD_GNB2}  ${EMPTY}
@{PARAMS_IN_CP_RUNTIME_GNB2}  ${EMPTY}
@{PARAMS_IN_EMIL_GNB2}  ${EMPTY}
@{FAULTS_EXCLUDED_CHECKING}  ${EMPTY}
${KEYWORD_MODIFY_CFG}  Modify Cfg
${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}  Perform Steps After Onair
#${SNAPSHOT_FLAG}  ${True}
${SNAPSHOT_FLAG}     pass:False,fail:True
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
${EMIL_FLAG}  ${True}
${SHERPA_FLAG}  ${False}
${IM_FLAG}  ${True}
${TRS_BACKHAUL_FLAG}  ${False}
${UTE_WIRESHARK_FLAG}  ${False}
${AP_BIP_FLAG}  ${False}
${GNB_BIP_FLAG}  ${False}
${AP_UDPLOG_FLAG}  ${True}
${AP_EXTRA_FLAG}  ${False}
${AP_TTITRACE_FLAG}  ${False}
${UTE_CPU_MEM_FLAG}  ${False}
${RESOURCES_LEAKAGE_FLAG}  ${True}
${SOS_REPORT_FLAG}    pass:False,fail:True
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
${ANTENNA_DUMP_FLAG}  ${False}
${ANTENNA_DUMP_OPTION}  ${EMPTY}
${DEBUG_LOG_LEVEL}  2
${AP_UDPLOG_LEVEL}  2
${AUTO_ANALYSIS_FLAG}  ${True}
${AUTO_FIX_VALIDATION_ERRORS}  ${False}
${RECREATE_WIRESHARK_FLAG}  ${True}
${MANUAL_AUTO_REPORT}  ${False}
${ONLY_REPORT_REP}  ${False}
${MEASID_INTRAF_RSC}  9
${MEASID_INTRAF_A3}  1
${MEASID_INTRAF_A5}  2
${MEASID_IF_A2}  7
${MEASID_IF_A3}  14
${MEASID_A4}  31
${MEASID_INTRAF_RCGI}  10
${MEASID_IF_RSC}  14
${MEASID_IF_RCGI}  10
${MEASID_INTERRAT_RSCFS}  32
${MEASID_INTERRAT_RSC}  32
${MEASID_INTERRAT_RCGI}  32
${MEASID_INTERRAT_A2}  6
${MEASID_1xRTT_A2}  13
${MEASID_1xRTT_RSCFS}  3
${MEASID_INTERRAT_REDIRECT}  4
${SCF_TEMPLATE_PATH}  ${CURDIR}${/}configuration_file
${WTS_DIR}  /opt/iphy/latest  # can not change because it is hardcode in TA lib
${IPHY_IP}  192.168.200.1
${FCT_IP}   192.168.255.1
${FTM_IP}   192.168.255.129
${REMOVE_LOGS}  off
${TCE_IP}   10.0.1.1
${TCE_PORT}  49150
${OMS_PORT}  49392
${GNB2_ALIAS}  gnb2
${GNB2_IP}  10.0.1.3
${SETUP_X2_BEFORE_NG}  ${False}
${INSTALL_IPHY_KNIFE}  ${False}
${IPHY_KNIFE_SUB_DIR}  knife_zy
&{IPHY_KNIFE_INFO}  server_ip=10.108.159.18  user=ute  password=ute  knife_root_dir=/opt/iphy/iphy_knives
...  knife_sub_dir=${IPHY_KNIFE_SUB_DIR}
${BTS_STARTUP_RETRY}  1
${AUTO_CFG}  ${WTS_DIR}/wts.cfg
@{GNB1_CONF}  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:syncInputList:syncInputType=1pps/ToD from external GNSS receiver
...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=EnabledWithoutBtsInputReference
${gnb_mirror_repository}  https://gitlabe2.ext.net.nokia.com/juhakang/tools.git
${AP_BIP_SCRIPT_PATH}    ${CURDIR}${/}DevHZ5_lib${/}src${/}tools${/}apMirroring
${GNB_BIP_SCRIPT_PATH}    ${CURDIR}${/}DevHZ5_lib${/}src${/}tools${/}gnbMirroring
#@{GNB2_CONF}  TNLSVC-1/TNL-1/IPAPP-1/BFD-1:bfdDestIpAddr=${TGT1_BTS_INFO.IP}
#...  TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr=${TGT1_BTS_INFO.IP}
#...  TNLSVC-1/TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway=10.0.1.3
#...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:syncInputList:syncInputType=1pps/ToD from Sync Hub Master
#...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=Disabled
#...  MNL-1/MNLENT-1/SYNC-1/CLOCK-1:totalDelayFromSHM=3

${EMIL_DOCKER_COMPOSE_FILE}    ${CURDIR}${/}DevHZ5_lib${/}src${/}tools${/}emil${/}docker-compose.yml
${EMIL_START_CMD}    ${CURDIR}${/}DevHZ5_lib${/}src${/}tools${/}emil${/}emil_start_cmd.txt
${mplane_ip}    10.0.1.2

*** Keywords ***
Setup Airphone Env
  [Arguments]  ${tl_type}=fdd_sansa_cmwv/FS/2cells  ${match_string}=${EMPTY}  ${cfg}=auto  ${ue_count}=30
  [Documentation]
  ...  This keyword is to setup airphone env.
  ...  | step1 | decide golden template location according to GNB and AP HW type and argument \${tl_type} |
  ...  | step2 | change vendor parameters according to \@{PARAMS_IN_VENDOR} |
  ...  | step3 | change swconfig in GNB according to \@{PARAMS_IN_SWCONFIG} |
  ...  | step4 | change swconfig in AP according to \@{PARAMS_IN_SWCONFIG_AP} |
  ...  | step5 | upgrade iphy.xml, change it according to \@{PARAMS_IN_IPHY_XML} and upload to AP |
  ...  | step6 | modify golden SCFC according to \@{PARAMS_IN_SCF} and full commission GNB with it |
  ...  | step7 | auto generate cfg file |
  ...  | step8 | start WTS and wait BTS onair |
  ...  | step9 | if BTS can't onair, retry several times specified in \${BTS_STARTUP_RETRY}. Default is one time |
  ...
  ...  | Arguments    | Man. | Default  | Description |
  ...  | tl_type      | No   | fdd_sansa_cmwv/FS/2cells | specify golden template sub-directory |
  ...  | match_string | No   | ${EMPTY} | the string in egate_console.log indicates case can start to run |
  ...  | cfg          | No   | auto     | if auto cfg function is not ready, give wts cfg file for workaround |
  ...  | ue_count     | No   | 30       | will be optimized |
  ...
  ...  Example
  ...  | Setup Airphone Env | tl_type=fddtdd_sansa_cmwv/L1B/4cells_2F2T |
  ...  | Setup Airphone Env | tl_type=fdd_sansa_cmwv/FS/1cell           | match_string=GNB-3: XnAP Link with GNB-2 |
  ...  | Setup Airphone Env | tl_type=fdd_sansa_cmwv/FS/1cell           | cfg=wts_zy.cfg | #as workaround

  Set Suite Variable  ${BTS_NUMBER}  1
  Set Suite Variable  ${MAX_UE_NUMBER_IN_WTS}  ${ue_count}
  ${BTS_STARTUP_RETRY}  Set Variable If  "6cells" in "${tl_type}"    2    ${BTS_STARTUP_RETRY}
  Set Suite Variable  ${BTS_STARTUP_RETRY}
  Run Keyword If  ${DEBUG}  Debug Enter Into Egate
  Return From Keyword If  ${DEBUG}
#  configuration_reset_gnb_if_in_commissioned_state
  _Get Iphy Info
  _Set Iphy Ip
  _Decide Config Path For UTE Cloud
  _Get Duplex and Network mode    ${tl_type}
  #start bts for the first time
  ${onair_status_1}  _Start BTS For The First Time  ${tl_type}  ${ue_count}  ${cfg}
  #bts startup retry
  Run Keyword Unless  ${onair_status_1}  _Retry To Start BTS
  Egate Console Log Should Contain  ${WTS_DIR}${/}egate_console.log  ${match_string}
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2nrt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2rt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=ueproxy  sleep_time=1

Collect Logs For Startup
  [Arguments]  ${tag}  ${onair_status}
  Log To Console With Time Prefix  collecting logs
  Run Keyword If  '${onair_status}'=='${False}' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot GNB1  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2' and '${onair_status}'=='${False}' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot GNB2  ${tag}
  Run Keyword If  '${onair_status}'=='${True}' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot GNB1  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2' and '${onair_status}'=='${True}' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Run Keyword And Ignore Error  Collect Snapshot GNB2  ${tag}
  ${tmp_statup_sos}=  Run Keyword If  '${tag}'=='startup_1'  Set Variable  ${SOS_REPORT_STARTUP_1_FLAG_DIC}
  ...  ELSE IF  '${tag}'=='startup_${${BTS_STARTUP_RETRY}+1}'  Set Variable  ${SOS_REPORT_FLAG_DIC}
  ...  ELSE   Create Dictionary  pass=false  fail=false
  ${SOS_REPORT_FLAG_WORK}  Set Variable If  '${onair_status}'=='${False}'  ${tmp_statup_sos['fail']}  ${tmp_statup_sos['pass']}
  Set Suite Variable  ${SOS_REPORT_FLAG_WORK}
  Run Keyword And Ignore Error  Stop Capture Logs  ${tag}
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir  ${tag}
  run keyword and ignore error  _Copy Config Files To Log Dir GNB2  ${tag}
  Analyze Logs  ${tag}  ${onair_status}
  Compress Directory  ${SAVE LOG DIRECTORY}/${tag}_logs
  Run Keyword If  '${BTS_NUMBER}'=='2'  Compress Directory
  ...  ${SAVE LOG DIRECTORY}${/}${GNB2_ALIAS}/${tag}_logs

Collect Snapshot GNB1
  [Arguments]  ${tag}=${EMPTY}
  ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}
#  ${status}=  Run Keyword And Return Status  Collect Snapshot  ${snapshot_dir}/snapshot.zip
#  Run Keyword Unless  ${status}  Execute Aashell Cmd  log -c full -a -z snapshot.zip  timeout=180
#  Run Keyword Unless  ${status}  Get Enb File  /tmp/snapshot.zip  ${snapshot_dir}/snapshot.zip
  Wait Until Keyword Succeeds    5x    1min    Collect Snapshot  ${snapshot_dir}/snapshot.zip

Collect Snapshot GNB2
  [Arguments]  ${tag}=${EMPTY}
  ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${GNB2_ALIAS}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}/${GNB2_ALIAS}
#  ${status}=  Run Keyword And Return Status  Collect Snapshot  ${snapshot_dir}/snapshot.zip  connection=${GNB2_ALIAS}
#  Run Keyword Unless  ${status}  Execute Aashell Cmd GNB2  log -c full -a -z snapshot.zip  timeout=180
#  Run Keyword Unless  ${status}  Get Enb File  /tmp/snapshot.zip  ${snapshot_dir}/snapshot.zip  alias=${GNB2_ALIAS}
  Wait Until Keyword Succeeds    5x    1min    Collect Snapshot  ${snapshot_dir}/snapshot.zip  connection=${GNB2_ALIAS}

Common Suite Setup
  ${time}  Get Time
  Log To Console  current time is ${time}
  Log Variables
  Conver some variables
  Run Keyword And Ignore Error  Kill Useless Local Hosts
  Run Keyword And Ignore Error  Execute Cmd On Pc  df -h ${OUTPUT_DIR}
  _Create Suite Log Directory
  _get testline info
  _get gnb information
  Run Keyword And Ignore Error  Download Wireshark Plugin
  [Teardown]  _Analyze Failure Of eNB SSH Issue

Common Suite Setup And Setup Airphone Env
  [Arguments]  ${match_string}=${EMPTY}  ${cfg}=auto  ${ue_count}=30
  _Get TL TYPE File Path
  Common Suite Setup
  Setup Airphone Env  tl_type=${TL_TYPE_PATH}  match_string=${match_string}  cfg=${cfg}  ue_count=${ue_count}

Common Suite Teardown
  Run Keyword And Ignore Error  Teardown All Aliases For Admin
  Run Keyword And Ignore Error  Teardown All Aliases For Enb Fsmaccess
  Run Keyword And Ignore Error  Teardown All Aliases For Wts Fsmaccess
  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If All Tests Passed  Remove Directory
  ...  ${SUITE_LOG_DIRECTORY}  ${True}
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error  Execute Cmd On Pc Enb2
#  ...  rm -rf ${SUITE_LOG_DIRECTORY}  600
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep CM_EXECUTION_ID
  Run Keyword And Ignore Error  Execute Cmd On Pc  rm -rf /home/ute/scf_* /home/ute/gnb*/scf_*
  Run Keyword And Ignore Error  Suite Teardown Report Rep  ${OUTPUT FILE}  ${MANUAL_AUTO_REPORT}

Common Suite Teardown And Restore BTS Configuration Parameters
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Recover Vendor Parameters
  Run Keyword If  '${BTS_NUMBER}'=='2'  Recover Vendor Parameters GNB2
  Recover Enb Config Ini
  Run Keyword If  '${BTS_NUMBER}'=='2'  Recover Enb Config Ini GNB2
  Delete Cp Runtime Ini
  Run Keyword If  '${BTS_NUMBER}'=='2'  Delete Cp Runtime Ini GNB2
  Common Suite Teardown
  Run Keyword And Ignore Error  Execute Cmd On Pc  timedatectl
  Log To Console  LOG_DIR=${SUITE_LOG_DIRECTORY}

Common Test Setup
  _Create Test Log Directory

Common Test Setup And Start To Capture Logs
  Common Test Setup
  Run Keyword And Ignore Error  Run Keyword If  ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage
  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2' and ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage Gnb2
  Start To Capture Logs
  Get Initial Active Faults
  ${case_begin_time}  Get Current Bts Time
  Set Test Variable  \${case_begin_time}

Common Test Teardown
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'
  ...  Collect Snapshot GNB1
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If
  ...  '${BTS_NUMBER}'=='2' and '${SNAPSHOT_FLAG_DIC['fail']}'=='${True}'  Collect Snapshot GNB2
  run keyword if test passed  Run Keyword And Ignore Error  Run Keyword If  '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'
  ...  Collect Snapshot GNB1
  Run Keyword If Test passed  Run Keyword And Ignore Error  Run Keyword If
  ...  '${BTS_NUMBER}'=='2' and '${SNAPSHOT_FLAG_DIC['pass']}'=='${True}'  Collect Snapshot GNB2
  Run Keyword And Ignore Error  Get current scf file  ${SAVE LOG DIRECTORY}  scf_after_test.xml
  ...  export_type=configurationAndRuntimeObjects
  Run Keyword If Test Failed  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'  Get current scf file
  ...  ${SAVE LOG DIRECTORY}${/}${GNB2_ALIAS}  scf_after_test.xml
  ...  ${SAVE LOG DIRECTORY}${/}${GNB2_ALIAS}${/}scf_after_test.xml  export_type=configurationAndRuntimeObjects
  ...  connection=${GNB2_ALIAS}

Common Test Teardown And Stop Capture Logs
  # collect bip log immediately because it could be covered
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error
  ...    Stop To Capture GNB BIP Log  ${EMPTY}  combine_flag=False
  Run Keyword If    ${GNB_BIP_FLAG} is ${True} and '${BTS_NUMBER}'=='2'    Run Keyword And Ignore Error
  ...    Stop To Capture GNB BIP Log GNB2  ${EMPTY}  combine_flag=False
  # release UEs and do some checks
  Release Ues  ue_type=all
  Sleep  10s  # make sure UE release procedure finished
  Run Keyword If  ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage
  Run Keyword If  '${BTS_NUMBER}'=='2' and ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage Gnb2
  Check No New Active Faults
  # collect and analyze logs
  Run Keyword If Test Failed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['fail']}
  Run Keyword If Test Passed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['pass']}
  Stop Capture Logs
  Stop RRC Log
  Run Keyword And Ignore Error  _Copy Config Files To Log Dir
  run keyword and ignore error  _Copy Config Files To Log Dir GNB2
  Run Keyword If Test Failed  Set Test Variable  ${test_status}  FAIL
  Run Keyword If Test Passed  Set Test Variable  ${test_status}  PASS
  Analyze Logs  test_status=${test_status}
  Common Test Teardown
  Run Keyword And Ignore Error  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If Test Passed
  ...  Remove Directory  ${SAVE LOG DIRECTORY}  ${True}
  Run Keyword If  '${REMOVE_LOGS}'=='off'  Compress Directory  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'  Run Keyword And Ignore Error
  ...  Execute Cmd On Pc Gnb2  rm -rf ${SAVE LOG DIRECTORY}  600

Compress Directory
  [Arguments]  ${directory}
  ${directory}  Set Variable If  ${directory.endswith("/")}  ${directory[:-1]}  ${directory}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  cd ${directory}/../; zip -r ${directory}.zip ${directory.split("/")[-1]};cd ~  timeout=300
  ${zip_status}  run keyword and return status  file should exist  ${directory}.zip
  Run Keyword And Ignore Error  Run Keyword If  ${zip_status}  Remove Directory  ${directory}  ${True}

Debug Enter Into Egate
  Set Suite Variable  ${BTS_NUMBER}  1
  _Get Iphy Info
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2nrt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2rt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=ueproxy  sleep_time=1
  Execute Egate Command  debug_log level=${DEBUG_LOG_LEVEL}
  Execute Egate Command  debug_log  Max number
  run keyword and ignore error  Execute Egate Command  sim_trace protocol=rrc on uec=1
  run keyword and ignore error  Execute Egate Command  trace uec=1 protocol=nr_rrc on
  run keyword and ignore error  Execute Egate Command  sim_trace amf=1 protocol=ng on


Debug Enter Into Egate For 2GNB
  Set Suite Variable  ${BTS_NUMBER}  2
  _Setup GNB2
  _Get Iphy Info
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2nrt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2rt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=ueproxy  sleep_time=1
  Execute Egate Command  debug_log level=${DEBUG_LOG_LEVEL}
  Execute Egate Command  debug_log  Max number
  Execute Egate Command  sim_trace protocol=rrc on uec=1
  Execute Egate Command  trace uec=1 protocol=nr_rrc on
  run keyword and ignore error  Execute Egate Command  sim_trace amf=1 protocol=ng on

#Install Iphy Knife
#  Kill Edaemon And Egate
#  _Download Iphy Knife
#  _Install Iphy Puttibatti
#  _Link Latest To Esimmode

Make Sure GNB AP SSH OK
  Comment  ${status}  Is Host Ping Ok  ${FCT_IP}  2
  Comment  Run Keyword Unless  ${status}  Wait For All Hosts  ${FTM_IP}  timeout=300
  Comment  Run Keyword Unless  ${status}  Disable Ethernet Port Security
  Comment  Run Keyword Unless  ${status}  Wait For All Hosts  ${FCT_IP}  timeout=300
  Wait For All Hosts  ${FTM_IP}  ${FCT_IP}  timeout=300
  Run Keyword And Ignore Error  Wait For Host Ssh  ${FCT_IP}  timeout=180
  Run Keyword And Ignore Error  Wait For Host Ssh  ${IPHY_IP}  timeout=180

Make Sure GNB SSH OK GNB2
  Wait For All Hosts  ${FTM_IP}  ${FCT_IP}  timeout=300  remote_host=${GNB2_PC_IP}
  Run Keyword And Ignore Error  Wait For Host Ssh  ${FCT_IP}  timeout=180  remote_host=${GNB2_PC_IP}

Restart GNB And AP Until SSH OK
  Comment  Run Keyword And Ignore Error  Execute Command On Enb  rm -rf /ffs/run/config/hwf.bin.gz
  Restart Gnb And Airphone
  Log To Console With Time Prefix  step: wait GNB and Airphone SSH connected
  sleep  2 minutes
  Run Keyword And Ignore Error  Make Sure GNB AP SSH OK


Restart 2GNB And AP Until SSH OK
  Comment  Run Keyword And Ignore Error  Execute Command On Enb  rm -rf /ffs/run/config/hwf.bin.gz
  Restart Gnb And Airphone  gnb_num=2
  Log To Console With Time Prefix  step: wait GNB1 GNB2 and Airphone SSH connected
  sleep  2 minutes
  Run Keyword And Ignore Error  Make Sure GNB AP SSH OK
  run keyword and ignore error  make sure gnb ssh ok gnb2

Start Wts And Wait Until Gnb Onair
  [Arguments]  ${WTS_FILE_PATH}  ${DEBUG_LOG_LEVEL}  ${rru_startup_time}=600  ${tag}=${empty}
  ${configured_status}  Set Variable  ${False}
  ${configured_status}    wait gnb configured state  ${rru_startup_time}
  Return From Keyword If    '${configured_status}'=='${False}'    ${configured_status}
  configure and start wts    ${WTS_FILE_PATH}  ${DEBUG_LOG_LEVEL}
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture GNB BIP Log    ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Start To Capture Trs Traffic On Backhaul
  Run Keyword If    ${AP_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture AP BIP Log    ${tag}
  Run Keyword If    ${AP_TTITRACE_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture Ap Ttitrace Log    ${tag}
  ${onair_status}  Set Variable  ${False}
  ${onair_status}    wait for gnb onair  ${WTS_FILE_PATH}
  Return From Keyword    ${onair_status}

Start Wts And Wait Until 2Gnb Onair
  [Arguments]  ${WTS_FILE_PATH}  ${DEBUG_LOG_LEVEL}  ${rru_startup_time}=600  ${tag}=${empty}
  log to console with time prefix  step: === Monitoring in GNB1 ===
  ${configured_status}  Set Variable  ${False}
  ${configured_status}    wait gnb configured state  ${rru_startup_time}
  log to console with time prefix  step: === Monitoring in GNB2 ===
  ${configured_status2}  Set Variable  ${False}
  ${configured_status2}    wait gnb configured state gnb2  ${rru_startup_time}
  Return From Keyword If    '${configured_status}'=='${False}' or '${configured_status2}'=='${False}'   ${False}
  configure and start wts    ${WTS_FILE_PATH}  ${DEBUG_LOG_LEVEL}
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}   Run Keyword And Ignore Error    Start To Capture GNB BIP Log    ${tag}
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}   Run Keyword And Ignore Error    Start To Capture GNB BIP Log GNB2    ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Start To Capture Trs Traffic On Backhaul
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Start To Capture Trs Traffic On Backhaul GNB2
  Run Keyword If    ${AP_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture AP BIP Log    ${tag}
  Run Keyword If    ${AP_TTITRACE_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture Ap Ttitrace Log    ${tag}
  ${onair_status_gnb1}  Set Variable  ${False}
  ${onair_status_gnb2}  Set Variable  ${False}
  log to console with time prefix  step: === Monitoring in GNB1 ===
  ${onair_status_gnb1}    wait for gnb onair  ${WTS_FILE_PATH}
  log to console with time prefix  step: === Monitoring in GNB2 ===
  ${onair_status_gnb2}    wait for gnb onair gnb2  ${WTS_FILE_PATH}
  ${onair_status}    set variable if    '${onair_status_gnb1}'=='${True}' and '${onair_status_gnb2}'=='${True}'
  ...    ${True}    ${False}
  Return From Keyword    ${onair_status}

Start RRC Log
  [Arguments]  ${tag}=${EMPTY}
  Run Keyword And Ignore Error  Execute Egate Command  sim_trace uec=1 protocol=rrc on
  #detailed ue capability information will not print if no this command
  Run Keyword And Ignore Error  Execute Egate Command  tracefilter_sim protocol=rrc clear
  ${rrc_name}=  Set Variable If  ${tag.__len__()}==0  rrc.log  rrc_${tag}.log
  Run Keyword And Ignore Error  Execute Egate Command  set_log flush
  ${status}  ${TAIL_PID}  Run Keyword And Ignore Error  Tail Log  ${WTS_DIR}/egate_console.log
  ...  ${WTS_DIR}/${rrc_name}
  Set Suite Variable  ${TAIL_PID}
  Sleep  2s  #avoid missing the previous logs of the egate command immediated being executed

Start To Capture BTS Logs
  [Arguments]  ${tag}=${empty}
  Execute Cmd On Pc  netstat -na | grep 1500
  Start To Capture BTS UdpLogs  ${tag}
  Run Keyword And Ignore Error    Start To Capture Infomodel Log
  Run Keyword Unless  'startup' in '${tag}' or ${WIRESHARK_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...    Start To Capture Wireshark Log  ${tag}
  Run Keyword Unless  'startup' in '${tag}' or ${XPSYSCOM_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Start To Capture xpsyscom Log  ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${SHERPA_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Sherpa    ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${TTITRACE_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Ttitrace    ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${GNB_BIP_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...    Start To Capture GNB BIP Log    ${tag}
  Run Keyword if     ${EMIL_FLAG} is ${True} and 'startup' not in '${tag}'    Run Keyword And Ignore Error
  ...     start_to_capture_emil_log    ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True} and 'startup' not in '${tag}'    Start To Capture Trs Traffic On Backhaul

Start To Capture BTS Logs GNB2
  [Arguments]  ${tag}=${empty}
  Start To Capture BTS UdpLogs GNB2  ${tag}
  Start To Capture Infomodel Log GNB2
  Run Keyword Unless  'startup' in '${tag}' or ${WIRESHARK_FLAG} is not ${True}  Start To Capture Wireshark Log GNB2  ${tag}
  Run Keyword Unless  'startup' in '${tag}' or ${XPSYSCOM_FLAG} is not ${True}
  ...  Start To Capture xpsyscom Log GNB2  ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${SHERPA_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Sherpa GNB2    ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${TTITRACE_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Start To Capture Gnb Ttitrace GNB2    ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${GNB_BIP_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...    Start To Capture GNB BIP Log GNB2   ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${EMIL_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...    start_to_capture_emil_log_GNB2    ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True} and 'startup' not in '${tag}'    Start To Capture Trs Traffic On Backhaul GNB2

Start To Capture BTS UdpLogs
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  Run Keyword And Ignore Error  collect_syslog_results  alias=enb1
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  start_syslog  ${btslog_dir}  ${btslog_name}  192.168.255.126  alias=enb1

Start To Capture BTS UdpLogs GNB2
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  Run Keyword And Ignore Error  collect_syslog_results  alias=${GNB2_ALIAS}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${GNB2_ALIAS}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}/${GNB2_ALIAS}
  Comment  Run Keyword And Ignore Error  start_syslog  ${btslog_dir}  ${btslog_name}  192.168.255.126  alias=${GNB2_ALIAS}
  ...  host_ip=${GNB2_PC_IP}
  Run Keyword And Ignore Error    Start Collect Btslog With Taf    btslog_name=${GNB2_ALIAS}    host_ip=${GNB2_PC_IP}

Start Collect Btslog With Taf
  [Arguments]      ${btslog_name}=btslog     ${host_ip}=${GNB2_PC_IP}
  run keyword and ignore error    core.teardown_collectors    names=${btslog_name}
  ${executor_test_vm}=  Create Dictionary  host=${host_ip}  user=ute  password=ute
  btslog.create_btslog_collector     name=${btslog_name}    executor=${executor_test_vm}  log_dir=/tmp/btslog2
  btslog.set suite Alias    ${btslog_name}    # keep btslog tool is alive
  core.setup_collectors      names=${btslog_name}
  core.start_collectors      names=${btslog_name}

Start To Capture Iphy Udplog
  [Arguments]  ${tag}
  Return From Keyword If  ${AP_UDPLOG_FLAG} is not ${True}
  ${iphylog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  ap_udplog.LOG
  ...  ap_udplog_${tag}.LOG
  ${iphylog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs
  ...  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Start Syslog  ${iphylog_dir}  ${iphylog_name}  192.168.200.126  alias=iphy1

Start To Capture Logs
  [Arguments]  ${tag}=${EMPTY}
  Run Keyword If  'startup' in '${tag}'  Kill Edaemon And Egate
  Wait For Host Ssh  ${FCT_IP}  timeout=600
  Wait For Host Ssh  ${IPHY_IP}  timeout=600
  Start To Capture BTS Logs  ${tag}
  Start To Capture Iphy Udplog  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2'  Start To Capture BTS Logs GNB2  ${tag}
  Run Keyword And Ignore Error  Execute Cmd On Pc  rm -rf ${WTS_DIR}/rrc*.log
  Run Keyword Unless  'startup' in '${tag}'  Start RRC Log  ${tag}
  _Start To Capture UTE Wireshark  ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${AP_BIP_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...    Start To Capture AP BIP Log    ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${AP_TTITRACE_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...    Start To Capture Ap Ttitrace Log    ${tag}
  Comment  _Start To Capture Extra Iphy Logs  ${tag}

Get Initial Active Faults
  ${initial_act_alarm_list}    Get Current Active Faultid
  Set Test variable    ${initial_act_alarm_list}
  ${initial_act_alarm_list_gnb2} =  Run Keyword If  '${BTS_NUMBER}'=='2'  Get Current Active Faultid Gnb2
  Run Keyword If  '${BTS_NUMBER}'=='2'    Set Test variable    ${initial_act_alarm_list_gnb2}

Check No New Active Faults
  Check No New Active Faultid Exist    ${initial_act_alarm_list}    ${FAULTS_EXCLUDED_CHECKING}
  Run Keyword If  '${BTS_NUMBER}'=='2'  Check No New Active Faultid Exist Gnb2
  ...    ${initial_act_alarm_list_gnb2}    ${FAULTS_EXCLUDED_CHECKING}

Stop Capture BTS Logs
  [Arguments]  ${tag}=${empty}
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log  ${tag}  combine_flag=False
  Run Keyword Unless    'startup' in '${tag}' or ${SHERPA_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Stop Capture Gnb Sherpa    ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${TTITRACE_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Stop Capture Gnb Ttitrace    ${tag}
  run keyword if    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    Stop Capture Wireshark Log  ${tag}
  run keyword if    ${XPSYSCOM_FLAG} is ${True}    Run Keyword And Ignore Error    Stop Capture xpsyscom Log  ${tag}
  Run Keyword And Ignore Error    Stop To Capture Infomodel Log  ${tag}
  Run Keyword If    ${EMIL_FLAG} is ${True} and 'startup' not in '${tag}'    Run Keyword And Ignore Error
  ...    Stop to Capture Emil Log
  Stop Capture BTS UdpLogs  ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Stop To Capture Trs Traffic On Backhaul    ${tag}

Stop Capture BTS Logs GNB2
  [Arguments]  ${tag}=${empty}
  Run Keyword If    ${GNB_BIP_FLAG} is ${True}    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log GNB2  ${tag}  combine_flag=False
  Run Keyword Unless    'startup' in '${tag}' or ${SHERPA_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Stop Capture Gnb Sherpa GNB2    ${tag}
  Run Keyword Unless    'startup' in '${tag}' or ${TTITRACE_FLAG} is not ${True}    Run Keyword And Ignore Error
  ...  Stop Capture Gnb Ttitrace GNB2    ${tag}
  run keyword if    ${WIRESHARK_FLAG} is ${True}    Stop Capture Wireshark Log GNB2  ${tag}
  run keyword if    ${xpsyscom_FLAG} is ${True}    Stop Capture xpsyscom Log GNB2  ${tag}
  Stop To Capture Infomodel Log GNB2  ${tag}
  Run Keyword If    ${EMIL_FLAG} is ${True} and 'startup' not in '${tag}'    Run Keyword And Ignore Error
  ...    stop to capture emil log GNB2
  Stop Capture BTS UdpLogs GNB2  ${tag}
  Run Keyword If    ${TRS_BACKHAUL_FLAG} is ${True}    Stop To Capture Trs Traffic On Backhaul GNB2    ${tag}

Stop Capture BTS UdpLogs
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  collect_syslog_results  alias=enb1

Stop Capture BTS UdpLogs GNB2
  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${BTSLOG_FLAG} is not ${True}
  ${btslog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0  btslog.LOG  btslog_${tag}.LOG
  ${btslog_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Comment  Run Keyword And Ignore Error  collect_syslog_results  alias=${GNB2_ALIAS}
  Run Keyword And Ignore Error  Stop Collect Btslog With Taf    ${GNB2_ALIAS}

Stop Collect Btslog With Taf
  [Arguments]      ${btslog_name}=btslog1    ${target_dir}=${SAVE LOG DIRECTORY}
  core.stop_collectors      names=${btslog_name}
  core.collect_collectors      names=${btslog_name}     target_dir=${target_dir}
  [Teardown]      run keyword and ignore error     core.teardown_collectors      names=${btslog_name}

Stop Capture Iphy Udplog
  Return From Keyword If  ${AP_UDPLOG_FLAG} is not ${True}
  Run Keyword And Ignore Error  collect_syslog_results  alias=iphy1

Stop Capture Logs
  [Arguments]  ${tag}=${EMPTY}
  _Stop Capture UTE Wireshark
  Stop Capture BTS Logs  ${tag}
  Run Keyword If  '${BTS_NUMBER}'=='2'  Stop Capture BTS Logs GNB2  ${tag}
  Stop Capture Iphy Udplog
  Run Keyword And Ignore Error  Execute Cmd On Pc  ps -ef | grep -e sim -e egate -e edaemon
  ${status}  ${wts_log_dir}  Run Keyword And Ignore Error  collect_wts_logs  ${tag}
  # Copy robot/ini/pdm to case run log path
  ${case_files}    Set Variable
  ...  ${SAVE LOG DIRECTORY.rsplit("/", 1)[0]}/${SUITE SOURCE.rsplit("/", 1)[0].rsplit("/", 1)[1]}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  mkdir -p ${case_files} && cp -r ${SUITE SOURCE.rsplit("/", 1)[0]}/*.robot ${case_files}
  Run Keyword And Ignore Error  Execute Cmd On Pc  cp -r ${SUITE SOURCE.rsplit("/", 1)[0]}/*a2a* ${case_files}
  Run Keyword And Ignore Error  _Stop Capture Extra Iphy Logs  ${tag}

Stop RRC Log
  Run Keyword And Ignore Error  Execute Egate Command  set_log flush
  Run Keyword And Ignore Error  Kill Linux Process  ${TAIL_PID}

_Analyze Failure Of Iphy SSH Issue
  Return From Keyword If  '${KEYWORD STATUS}'=='PASS'
  Run Keyword If  'Unable to connect to port 22 on 192.168.200.1' in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Excluded:failed to connect 192.168.200.1  WARN
  Run Keyword If  'Unable to connect to port 22 on 192.168.200.1' in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure iphy connection is reachable for local testline or reseved cloud testline.
  ...  WARN

_Analyze Failure Of eNB SSH Issue
  Return From Keyword If  '${KEYWORD STATUS}'=='PASS'
  Run Keyword If  'Unable to connect to port 22 on 192.168.255.1'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix  Auto Excluded:failed to connect 192.168.255.1  WARN
  Run Keyword If  'Unable to connect to port 22 on 192.168.255.1'in '${KEYWORD MESSAGE}' or 'SSHClientException' in '${KEYWORD MESSAGE}'
  ...  Log To Console With Time Prefix
  ...  Rerun case for single run execution, make sure enb connection is reachable for local testline or reseved cloud testline.  WARN

_Auto Generate Cfg BTS1
  [Arguments]  ${ue_count}  ${scf_for_startup}  ${source_wts_cfg}
  ${cutype}  get_scf_parameter_value  gNbCuType  ${scf_for_startup}
  Generate Default Cfg1  ${ue_count}  ${WTS_DIR}  ${AUTO_CFG}  ${source_wts_cfg}  ${scf_for_startup}  AirphoneConfig.xml
  ...  ${cutype}
  ${status}  Run Keyword And Return Status  Keyword Should Exist  ${KEYWORD_MODIFY_CFG}
  Run Keyword If  ${status}  ${KEYWORD_MODIFY_CFG}
  Teardown Cfg

_Auto Generate Cfg BTS2
  [Arguments]  ${ue_count}  ${scf_for_startup1}  ${scf_for_startup2}  ${source_wts_cfg}
  ${cutype}  get_scf_parameter_value  gNbCuType  ${scf_for_startup1}
  Generate Default Cfg2  ${ue_count}  ${WTS_DIR}  ${AUTO_CFG}  ${source_wts_cfg}  ${scf_for_startup1}  ${scf_for_startup2}  AirphoneConfig.xml
  ...  ${cutype}
  ${status}  Run Keyword And Return Status  Keyword Should Exist  ${KEYWORD_MODIFY_CFG}
  Run Keyword If  ${status}  ${KEYWORD_MODIFY_CFG}
  Teardown Cfg

#_Auto Generate Cfg New
#  [Arguments]  ${scf_for_startup}
#  ${cutype}  get_scf_parameter_value  gNbCuType  ${scf_for_startup}
#  Generate Default Cfg New  scf_for_startup=${scf_for_startup}  cfg_store_path=${AUTO_CFG}  mode=${cutype}  ue_info=${CFG_UE_INFO}
#  ${status}  Run Keyword And Return Status  Keyword Should Exist  ${KEYWORD_MODIFY_CFG}
#  Run Keyword If  ${status}  ${KEYWORD_MODIFY_CFG}
#  Teardown Cfg New

_Capture SosReport
  [Arguments]  ${tag}=${EMPTY}    ${timeout}=900
  Return From Keyword If  ${SOS_REPORT_FLAG_WORK} is not ${True}
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Execute Cmd On Pc  chmod +x /opt/iphy/latest/sosReport_ASIK_ASIL.sh
  ${output}    Execute Cmd On Pc    cd /opt/iphy/latest;./sosReport_ASIK_ASIL.sh -s -nr;cd ~    timeout=${timeout}
  ${result}    Run Keyword And Return Status   Should Not Match Regexp    ${output}    Snapshot Failed !
  Run Keyword Unless    ${result}    Log   Airphone Snapshot collection Failure    level=WARN
  Execute Cmd On Pc  mv /opt/iphy/latest/SosReport*.tgz ${log_dir}

_Copy Config Files To Log Dir
  [Arguments]  ${tag}=${EMPTY}
  ${target_dir}  set variable if  'startup' in '${tag}'   ${SAVE LOG DIRECTORY}/${tag}_logs/config
  ...  ${SAVE LOG DIRECTORY}/config
  Execute Cmd On PC  mkdir -p ${target_dir}
  Run Keyword If  'startup' in '${tag}'  Copy File  ${SUITE_LOG_DIRECTORY}/scfc_logs/scf_for_startup.xml
  ...  ${target_dir}
  Get Current Scf File  local_dir_path=${target_dir}  file_name=scf_after_test.xml  export_type=configurationAndRuntimeObjects
  Execute Cmd On PC  cp -f /opt/iphy/latest/egate_console.log ${SUITE_LOG_DIRECTORY}
  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/iphy.xml ${target_dir}
  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/swconfig_modified.txt ${target_dir}/gnb_swconfig.txt
  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/swconfig_ap_modified.txt ${target_dir}/ap_swconfig.txt
  Run Keyword If  @{PARAMS_IN_VENDOR} != ['']  Execute Cmd On PC  cp -f ${SUITE_LOG_DIRECTORY}/vendor_modified.xml ${target_dir}/vendor.xml
  Execute Cmd On PC  cp -rf ${WTS_DIR}/*.cfg ${target_dir}
  Execute Cmd On PC  cp -rf ${WTS_DIR}/*.xml ${target_dir}
  Execute Cmd On PC  rm -rf ${target_dir}/sosReport.cfg

_Copy Config Files To Log Dir GNB2
  [Arguments]  ${tag}=${EMPTY}
  ${target_dir}  set variable if  'startup' in '${tag}'   ${SAVE LOG DIRECTORY}/${tag}_logs/config/${GNB2_ALIAS}
  ...  ${SAVE LOG DIRECTORY}/config/${GNB2_ALIAS}
  execute cmd on pc   mkdir -p ${target_dir}
  Run Keyword If  'startup' in '${tag}'  Copy File  ${SUITE_LOG_DIRECTORY}/${GNB2_ALIAS}/scfc_logs/scf_for_startup.xml
  ...  ${target_dir}
  Run Keyword Unless  'startup' in '${tag}'  Get Current Scf File  local_dir_path=${target_dir}
  ...    file_name=scf_after_test.xml    connection=${GNB2_ALIAS}
  Copy File  ${SUITE_LOG_DIRECTORY}/${GNB2_ALIAS}/swconfig_modified.txt  ${target_dir}/gnb_swconfig.txt
  Copy File  ${SUITE_LOG_DIRECTORY}/${GNB2_ALIAS}/swconfig_ap_modified.txt    ${target_dir}/ap_swconfig.txt
  run keyword and ignore error  Copy File  ${SUITE_LOG_DIRECTORY}/${GNB2_ALIAS}/vendor_modified.xml
  ...  ${target_dir}/vendor.xml

_Create Suite Log Directory
  ${timestamp}  Get Timestamp
  ${FILE_NAME} =  Replace String Using Regexp  ${SUITE_NAME[:50]}  \\s+$  ${EMPTY}
  ${SUITE_LOG_DIRECTORY} =  Catenate  SEPARATOR=${/}  ${OUTPUT_DIR}  ev_logs  ${FILE_NAME}_${timestamp}/
  ${SUITE_LOG_DIRECTORY}  Replace String  ${SUITE_LOG_DIRECTORY}  ${SPACE}  _
  ${SUITE_LOG_DIRECTORY}  Replace String  ${SUITE_LOG_DIRECTORY}  -  _
  Create Directory  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SUITE_LOG_DIRECTORY}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${SUITE_LOG_DIRECTORY}
  Log To Console  LOG_DIR=${SAVE LOG DIRECTORY}

_Create Test Log Directory
  ${TEST_LOG_DIR}  Catenate  SEPARATOR=  ${SUITE_LOG_DIRECTORY}  ${TEST_NAME[:50]}/
  ${TEST_LOG_DIR}  Replace String  ${TEST_LOG_DIR}  ${SPACE}  _
  ${TEST_LOG_DIR}  Replace String  ${TEST_LOG_DIR}  -  _
  Create Directory  ${TEST_LOG_DIR}
  Set Suite Variable  ${TEST_LOG_DIR}
  Set Suite Variable  ${SAVE LOG DIRECTORY}  ${TEST_LOG_DIR}

_Decide Config Path For UTE Cloud
  ${CONFIG_PATH}  Decide Configurate Files Path
  Set Suite Variable  \${CONFIG_PATH}

_Decide Config Path For UTE Cloud 2GNB
  ${CONFIG_PATH}  Decide Configurate Files Path 2GNB
  Set Suite Variable  \${CONFIG_PATH}

#_Download Iphy Knife
#  Log  Downloading IPhy knife from ${IPHY_KNIFE_INFO.server_ip}:${IPHY_KNIFE_INFO.knife_root_dir}/${IPHY_KNIFE_INFO.knife_sub_dir}/
#  ...  console=${True}
#  Remove Directory  /home/ute/${IPHY_KNIFE_INFO.knife_root_dir.split("/")[1]}  recursive=${True}
#  Sftp Download  host=${IPHY_KNIFE_INFO.server_ip}  port=22  usr=${IPHY_KNIFE_INFO.user}
#  ...  pwd=${IPHY_KNIFE_INFO.password}  remote=${IPHY_KNIFE_INFO.knife_root_dir}/${IPHY_KNIFE_INFO.knife_sub_dir}/
#  ...  local=/home/ute/
#  Set Suite Variable  ${knife_dir}  /home/ute/${IPHY_KNIFE_INFO.knife_root_dir}/${IPHY_KNIFE_INFO.knife_sub_dir}/

_Get Iphy Info
  Log To Console  \n===get airphone info ===
  Setup Wts Fsm Access  fallback_prompt=#
  ${wts_sw_version}  Get Wts Sw Version
  ${AP_SW_VERSION}    Set Variable If    "${wts_sw_version.split("_")[-2].lstrip("0")}" is not "${EMPTY}"
  ...    ${wts_sw_version.split("_")[-3].lstrip("0")}.${wts_sw_version.split("_")[-2].lstrip("0")}.${wts_sw_version.split("_")[-1].lstrip("0")}
  ...    ${wts_sw_version.split("_")[-3].lstrip("0")}.0.${wts_sw_version.split("_")[-1].lstrip("0")}
  log  activeIphyVersion=${AP_SW_VERSION}    level=WARN
  Set Suite Variable  ${AP_SW_VERSION}
  ${AP_BBU_TYPE}  Get Ap Bbu Type
  log  ap_bbu_type=${AP_BBU_TYPE}  console=True
  Set Suite Variable  ${AP_BBU_TYPE}
  ${ap_bbmod_types}  Get Ap Fsp Types
  Set Suite Variable  ${AP_BBMOD_TYPE}  ${ap_bbmod_types[0]}
  log  ap_bbmod_type=${AP_BBMOD_TYPE}  console=True


#_Install Iphy Puttibatti
#  ${files}  List Files In Directory  ${knife_dir}
#  Log  uncompress ${knife_dir}/${files[0]} and install  console=${True}
#  Unzip File  ${knife_dir}/*.zip
#  ${cmd}  catenate
#  ...  cd ${knife_dir}/*_puttibatti; python fsmf_sw_update.py
#  ...  --force -i 192.168.200.1 --save_iphy_xml --set_ge_ips 10.0.2.2 10.0.2.1 --password oZPS0POrRieRtu;cd ~
#  Execute Cmd On Pc   ${cmd}  timeout=300
#  Iphy Cold Reset
#  Make Sure GNB AP SSH OK
#
#_Link Latest To Esimmode
#  ${files}  List Files In Directory  ${knife_dir}
#  Log  uncompress ${knife_dir}/${files[1]} and linked to latest  console=${True}
#  Unzip File  ${knife_dir}/*.tar.bz2
#  Unzip File  ${knife_dir}/*.tar/*.tar
#  Execute Cmd On Pc  rm -rf ${WTS_DIR}
#  Execute Cmd On Pc  ln -s ${knife_dir}/*.tar/*core2 ${WTS_DIR}
#  Execute Cmd On Pc  chmod +x ${WTS_DIR}/*

_Retry To Start BTS
  ${onair_status}  Set Variable  ${False}
  log to console with time prefix  \${BTS_STARTUP_RETRY}=${BTS_STARTUP_RETRY}
  FOR  ${retry}  IN RANGE  ${BTS_STARTUP_RETRY}
    BuiltIn.Log To Console  ===start bts for ${${retry}+2}nd time===
    ${onair_status}  Set Variable  ${False}
    Start To Capture Logs  startup_${${retry}+2}
    Restart GNB And AP Until SSH OK
    run keyword if    ${WIRESHARK_FLAG} is ${True}    Start To Capture Wireshark Log  startup_${${retry}+2}
    ${onair_status}  Start Wts And Wait Until Gnb Onair  ${WTS_DIR}/wts.cfg  ${DEBUG_LOG_LEVEL}
    ...  tag=startup_${${retry}+2}
    ${status}    Run Keyword And Return Status    Keyword Should Exist    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
    Run Keyword If    ${status} and ${onair_status}    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
    Collect Logs For Startup  startup_${${retry}+2}  ${onair_status}
    Exit For Loop If  ${onair_status}
  END
  Run Keyword Unless  ${onair_status}  Fail  BTS fail to startup

_Retry To Start 2GNB
  ${onair_status}  Set Variable  ${False}
  FOR  ${retry}  IN RANGE  ${BTS_STARTUP_RETRY}
    BuiltIn.Log To Console  ===start bts for ${${retry}+2}nd time===
    kill edaemon and egate
    Start To Capture Logs  startup_${${retry}+2}
    Restart 2GNB And AP Until SSH OK
    run keyword if    ${WIRESHARK_FLAG} is ${True}    Start To Capture Wireshark Log  startup_${${retry}+2}
    run keyword if    ${WIRESHARK_FLAG} is ${True}    start to capture wireshark log gnb2  startup_${${retry}+2}
    ${onair_status}=  Start Wts And Wait Until 2Gnb Onair  ${WTS_DIR}/wts.cfg  ${DEBUG_LOG_LEVEL}
    ...  tag=startup_${${retry}+2}
    ${status}    Run Keyword And Return Status    Keyword Should Exist    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
    Run Keyword If    ${status} and ${onair_status}    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
    Collect Logs For Startup  startup_${${retry}+2}  ${onair_status}
    Exit For Loop If  ${onair_status}
  END
  Run Keyword If  ${onair_status} is ${False}  Fail  BTS fail to startup

_Set Iphy Ip
  Log To Console  \n===configure IPs on PC ===
  Execute Cmd On Pc  sudo ip addr add 10.0.2.1/24 dev eth4
  Log  10.0.1.121~155 is configured for your use  console=yes
#  https://confluence.ext.net.nokia.com/display/LTECPHZ/5G+Library+Structure
  FOR  ${number}  IN RANGE  121  156
    Execute Cmd On Pc  sudo ip addr add 10.0.1.${number}/24 dev eth3
  END
  Log  proxy server ip is 10.0.2.80  console=yes
  Log  10.0.2.90~100 is configured for more proxy servers  console=yes
  FOR  ${number}  IN RANGE  90  101
    Execute Cmd On Pc  sudo ip addr add 10.0.2.${number}/24 dev eth4
  END
  Log  AMF ip is 10.0.1.1  console=yes
  Log  10.0.1.9~15 10.0.1.100~10.0.1.109 is configured for you to set more AMFs  console=yes
  FOR  ${number}  IN RANGE  9  16
    Execute Cmd On Pc  sudo ip addr add 10.0.1.${number}/24 dev eth3
  END
  FOR  ${number}  IN RANGE  100  110
    Execute Cmd On Pc  sudo ip addr add 10.0.1.${number}/24 dev eth3
  END
  Execute Cmd On Pc  ip addr show eth3
  Execute Cmd On Pc  ip addr show eth4

_Setup GNB2
  set suite variable  ${GNB2_PC_IP}  ${tl.test_pcs[1].default_ssh_connection_details.addr}
  log to console  GNB2_PC_IP=${GNB2_PC_IP}
  Setup Enb Fsm Access  remote_host=${GNB2_PC_IP}  alias=${GNB2_ALIAS}
  ${RACK_POSITION_GNB2}  Get Rack Position GNB2
  Set Suite Variable  ${RACK_POSITION_GNB2}
  Log  rack_position\=${RACK_POSITION_GNB2} in GNB2  console=True
  Config IP on UTE2

Config IP on UTE2
  Log  Delete 10.0.1.1 and add 10.0.1.200 on ute2  console=yes
  Execute Cmd On Pc Gnb2  sudo ip a del 10.0.1.1/24 dev eth3
  Execute Cmd On Pc Gnb2  sudo ifconfig eth3:enb_emil 10.0.1.200/24 up

Change Rd Parameters
  Change Enb Conf Ini    node_type=CPUE    params=${PARAMS_IN_CP_UE_RD}
  Change Enb Conf Ini    node_type=CPCL    params=${PARAMS_IN_CP_CL_RD}
  Create Cp Runtime ini    params=${PARAMS_IN_CP_RUNTIME}

_Start BTS For The First Time
  [Arguments]  ${tl_type}  ${ue_count}  ${cfg}
  ${onair_status}    Set Variable    ${False}
  Start To Capture Logs    startup_1
  Log To Console  \n===start bts for 1st time===
  ${sw_updated}    Judge Sw Updated
  ${rru_types_in_iphy_before_startup}    Get Rrus From Iphy Xml    target_file_name=old_iphy
  Change Vendor Parameters    ${PARAMS_IN_VENDOR}
  Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/${tl_type}/gnb_swconfig.txt
  Change Rd Parameters
  Change Swconfig File Of Airphone    ${PARAMS_IN_SWCONFIG_AP}    ${CONFIG_PATH}/${tl_type}/ap_swconfig.txt
  Modify And Upload Iphy Xml    ${PARAMS_IN_IPHY_XML}    ${CONFIG_PATH}${/}${tl_type}${/}iphy.xml    ${PARAMS_IN_SCF}
  ${rru_updated}=    Judge Rru Updated    ${rru_types_in_iphy_before_startup}
  ${scf_for_startup}    Modify Scf And Perform Full Commission    ${CONFIG_PATH}/${tl_type}/SCFC_1.xml    ${PARAMS_IN_SCF}
  Add NetConf Account If RRU is ORAN
  Run Keyword If    ${sw_updated} is ${True} or ${rru_updated} is ${True}    Restart Gnb And Airphone
  _handle cfg bts1    ${scf_for_startup}    ${ue_count}    ${tl_type}    ${cfg}
  Log To Console With Time Prefix    step: wait GNB and Airphone SSH connected
  Make Sure GNB AP SSH OK
  run keyword if    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    Start To Capture Wireshark Log    startup_1
  ${rru_startup_time}    Set Variable If    ${sw_updated} or ${rru_updated}    900  300
  ${onair_status}    Start Wts And Wait Until Gnb Onair    ${WTS_DIR}/wts.cfg    ${DEBUG_LOG_LEVEL}    ${rru_startup_time}
  ...    tag=startup_1
  ${status}    Run Keyword And Return Status    Keyword Should Exist    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  Run Keyword If    ${status} and ${onair_status}    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  [Teardown]    Collect Logs For Startup    startup_1    ${onair_status}
  [Return]    ${onair_status}

_Start Iphy DL Antenna Dump
#  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${ANTENNA_DUMP_FLAG} is not ${True}
  Execute Command On Wts  rm -rf /ram/antennaDump*
  Run keyword If  '${ANTENNA_DUMP_OPTION.__len__()}'!='0'  execute_iphy_dump_dl  ${ANTENNA_DUMP_OPTION}

_Start To Capture Extra Iphy Logs
  [Arguments]  ${tag}=${EMPTY}
  Run Keyword If  ${AP_EXTRA_FLAG}  Set Suite Variable  ${AP_TTITRACE_FLAG}  ${True}
  Run Keyword If  ${AP_EXTRA_FLAG}  Set Suite Variable  ${UTE_CPU_MEM_FLAG}  ${True}
  Run Keyword If  ${AP_EXTRA_FLAG}  Set Suite Variable  ${SOS_REPORT_FLAG_DIC['fail']}  ${True}
  Run Keyword If  ${AP_EXTRA_FLAG}  Set Suite Variable  ${ANTENNA_DUMP_FLAG}  ${True}
  Run Keyword If  ${AP_EXTRA_FLAG}  Set Suite Variable  ${DEBUG_LOG_LEVEL}  0
  Run Keyword Unless  'startup' in '${tag}'  _Start To Capture Iphy Ttitrace
  _Start To Monitor CPU Mem  ${tag}
  Run Keyword Unless  'startup' in '${tag}'  Run Keyword And Ignore Error  _Start Iphy DL Antenna Dump

_Start To Capture Iphy Ttitrace
  Return From Keyword If  ${AP_TTITRACE_FLAG} is not ${True}
  ${trace_cmd}  catenate
  ...  sim_tti_trace DLL1L2CONTROL=on ULHARQTX=on PRACHTX=on DCCH=on MACRX=on MACTX=on ULSCHTX=on
  ...  ULTRAUL=on DLHARQRX=on ULSCHTB=on CQIREPORTING=on
  Run Keyword And Ignore Error  Execute Egate Command  ${trace_cmd}
  Comment  Run Keyword And Ignore Error  Iphy Setup Tti Stream  log_path=${SAVE LOG DIRECTORY}/ap_ttitrace/
  Comment  Run Keyword And Ignore Error  Iphy Start Tti Stream  trace_dir=${SAVE LOG DIRECTORY}/ap_ttitrace/

_Start To Capture UTE Wireshark
  [Arguments]  ${tag}
  Return From Keyword If  ${UTE_WIRESHARK_FLAG} is not ${True} and 'startup' not in '${tag}'
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  sudo tcpdump -i eth3 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth3.pcap>& tmp_3.txt&
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  sudo tcpdump -i eth4 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth4.pcap>& tmp_4.txt&
#  Run Keyword And Ignore Error  Run Keyword If  '${BTS_NUMBER}'=='2'
#  ...  Execute Cmd On Pc  sudo tcpdump -i eth5 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth5.pca>& tmp5.txt&

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

_Stop Capture Extra Iphy Logs
  [Arguments]  ${tag}=${EMPTY}
  Run Keyword Unless  'startup' in '${tag}'  _Stop Capture Iphy Ttitrace
  _Stop To Monitor CPU Mem
  Run Keyword If    ${AP_BIP_FLAG} is ${True}    Stop To Capture AP BIP Log  ${tag}
  Run Keyword If    ${AP_TTITRACE_FLAG} is ${True}    Stop To Capture Ap Ttitrace Log    ${tag}
  _Capture SosReport  ${tag}
  Run Keyword Unless  'startup' in '${tag}'  Run Keyword And Ignore Error  _Stop Iphy DL Antenna Dump

_Stop Capture Iphy Ttitrace
  Return From Keyword If  ${AP_TTITRACE_FLAG} is not ${True}
  Comment  ${status}  ${dats}  Run Keyword And Ignore Error  Iphy Stop Tti Stream
  Comment  Run Keyword And Ignore Error  Iphy Convert Dat To Csv  ${dats}  ${SAVE LOG DIRECTORY}/ap_ttitrace/
  Comment  Run Keyword And Ignore Error  Iphy Teardown Tti Stream

_Stop Capture UTE Wireshark
    ${status}  ${pids_sys}    Run Keyword And Ignore Error    Get Linux Process Id    tcpdump    ute_wireshark
    Run Keyword And Ignore Error    Kill Linux Process  ${pids_sys}
    ${pid_check_result}=    Run Keyword And Ignore Error    Execute Cmd On Pc  ps aux | grep ute_wireshark | grep -v -w grep
    ${status}    Run Keyword And Return Status    Should Not Contain    ${pid_check_result}[1]    ute_wireshark
    Run Keyword Unless  ${status}  Log   Kill Ute Wireshark Process Failure    level=WARN

_Stop Iphy DL Antenna Dump
#  [Arguments]  ${tag}=${EMPTY}
  Return From Keyword If  ${ANTENNA_DUMP_FLAG} is not ${True}
  Run keyword If  '${ANTENNA_DUMP_OPTION.__len__()}'=='0'  execute_iphy_dump_dl
  ${dat_files}  Execute Command On Wts  ls /ram/antennaDump_*.dat
  execute cmd on pc  mkdir -p ${SAVE LOG DIRECTORY}/antennaDump
  FOR  ${file}  IN  @{dat_files.split()}
       get wts file  ${file}  ${SAVE LOG DIRECTORY}/antennaDump
  END

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

_get gnb information
  Log To Console  \n===get enb info===
  #make sure ssh work
  Setup Enb Fsm Access  fallback_prompt=#  host=${FTM_IP}
  Wait For All Hosts  ${FTM_IP}  timeout=600
  ${bts_port}  ${use_ssl}  Define Admin Port
  Setup Admin  bts_port=${bts_port}  use_ssl=${use_ssl}  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs
  ...  timeout=120  bts_host=${FTM_IP}
  Run Keyword And Ignore Error  Disable Ethernet Port Security
  Run Keyword And Ignore Error  Enable Ssh Access
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
  Get L1bypass Mode

_get testline info
  #get testline info
  Log To Console  ===get testline info===
  ${testline_ip}  Execute Cmd On Pc  sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
  Set Suite Variable  ${testline_ip}
  Log  TestLineIpAddress\=${testline_ip}  console=True
  ${testline_hostname}  Execute Cmd On Pc  hostname
  Log    TestLineHostName\=${testline_hostname}    level=WARN
  Run Keyword And Ignore Error  Execute Cmd On Pc  robot --version
  Run Keyword And Ignore Error  Execute Cmd On Pc  pip list | grep -e ute -e ta-a2a -e taf
  Run Keyword And Ignore Error  Execute Cmd On Pc  pip install ta-a2a -U
  Run Keyword And Ignore Error  Execute Cmd On Pc  pip list | grep ta-a2a
  Run Keyword And Ignore Error  Execute Cmd On Pc  timedatectl
  ${ute_version}  Execute Cmd On Pc  ute-setup -v
  Run Keyword And Ignore Error  Log  UTE_VERSION\=${ute_version.split()[-1]}  level=WARN
  Run Keyword And Ignore Error  Execute Cmd On Pc  cd /home/ute/MN/UTE/robotws;git log -n1;cd ~

_handle cfg bts1
  [Arguments]  ${scf_for_startup}  ${ue_count}  ${tl_type}  ${cfg}
  Execute Cmd On Pc  ls ${WTS_DIR}/*.cfg | grep -v sosReport.cfg | xargs rm -rf
  Execute Cmd On Pc  rm -rf ${WTS_DIR}/*.xml
  Run Keyword If  '${cfg}'!='auto'  Execute Cmd On Pc  cp -f ${CONFIG_PATH}/${tl_type}/${cfg} ${WTS_DIR}/wts.cfg
  Run Keyword If  '${cfg}'=='auto'  _Auto Generate Cfg BTS1  ${ue_count}  ${scf_for_startup}
  ...  ${CONFIG_PATH}/${tl_type}/wts.cfg
  #Run Keyword If  '${cfg}'=='auto_new'  _Auto Generate Cfg New  ${scf_for_startup}
  ${apConfigIsExist}=    evaluate    os.path.exists("${CONFIG_PATH}/${tl_type}/AirphoneConfig.xml")    modules=os
  Run Keyword If    ${apConfigIsExist}
  ...    Modify Apoamconfig    ${PARAMS_IN_APCONFIG_XML}    ${CONFIG_PATH}/${tl_type}/AirphoneConfig.xml

_handle cfg bts2
  [Arguments]  ${scf_for_startup1}  ${scf_for_startup2}  ${ue_count}  ${tl_type}  ${cfg}
  Execute Cmd On Pc  ls ${WTS_DIR}/*.cfg | grep -v sosReport.cfg | xargs rm -rf
  Execute Cmd On Pc  rm -rf ${WTS_DIR}/*.xml
  Run Keyword If  '${cfg}'!='auto'  Execute Cmd On Pc  cp -f ${CONFIG_PATH}/${tl_type}/${cfg} ${WTS_DIR}/wts.cfg
  Run Keyword If  '${cfg}'=='auto'  _Auto Generate Cfg BTS2  ${ue_count}  ${scf_for_startup1}  ${scf_for_startup2}
  ...  ${CONFIG_PATH}/${tl_type}/wts.cfg
  ${apConfigIsExist}=    evaluate    os.path.exists("${CONFIG_PATH}/${tl_type}/AirphoneConfig.xml")    modules=os
  Run Keyword If    ${apConfigIsExist}
  ...    Modify Apoamconfig    ${PARAMS_IN_APCONFIG_XML}    ${CONFIG_PATH}/${tl_type}/AirphoneConfig.xml

Check Cell Setup Complete In Apl3
    [Arguments]  ${cell_id}=all
    @{cells_to_check}  Run Keyword If  '${cell_id}'=='all'  Get All Cells ID
    ...  ELSE  Create List  ${cell_id}
    FOR  ${cell}  IN  @{cells_to_check}
        ${instance_id}  Set Variable If  '${cell_id}'=='all'  ${cell[0]}  ${cell_id}
        ${lcr_id}  Set Variable If  '${cell_id}'=='all'  ${cell[1]}  ${cell_id}
        Wait Until Keyword Succeeds    180sec    15sec    Apl3 Should Contain    Cell Setup completed for [CELL_ID:\\${lcr_id}\\]
    END

Apl3 Should Contain
    [Arguments]  ${exepect_string}
    Run Keyword And Ignore Error    Setup Wts Fsm Access  fallback_prompt=#
    ${rc}=     Execute Command On Wts    grep -i "${exepect_string}" /tmp/APL3.log    return_rc=True
    Should be Equal as Integers     ${rc}[1]      0

_Get Duplex and Network mode
  [Arguments]  ${tl_type}
  Log To Console  \n===get configuration info===
  ${DUPLEX}    Get Duplex    ${CONFIG_PATH}/${tl_type}/SCFC_1.xml    ${PARAMS_IN_SCF}
  Set Suite Variable  ${DUPLEX}
  log  DUPLEX=${DUPLEX}  console=True
  ${NETWORK_MODE}    Get Network Mode    ${CONFIG_PATH}/${tl_type}/SCFC_1.xml    ${PARAMS_IN_SCF}
  Set Suite Variable  ${NETWORK_MODE}
  log  NETWORK_MODE=${NETWORK_MODE}  console=True
  ${PARAMS_IN_SWCONFIG}=    _Gen Extra Gnb Flag    ${PARAMS_IN_SWCONFIG}
  Set Suite Variable  ${PARAMS_IN_SWCONFIG}
  ${PARAMS_IN_SWCONFIG_AP}=    _Gen Extra Ap Flag    ${PARAMS_IN_SWCONFIG_AP}
  Set Suite Variable  ${PARAMS_IN_SWCONFIG_AP}

_Gen Extra Gnb Flag
  [Arguments]  ${params}
  ${new_params}=    Generate Extra Swconfig Flag Based On Condition    ${params}    ${PARAMS_IN_ENV_SWCONFIG}
  [Return]  ${new_params}

_Gen Extra Ap Flag
  [Arguments]  ${params}
  ${new_params}=    Generate Extra Swconfig Flag Based On Condition    ${params}    ${PARAMS_IN_ENV_SWCONFIG_AP}
  [Return]  ${new_params}

_Get TL TYPE File Path
  ${TL_TYPE_PATH}  get variable value  ${TL_TYPE_PATH}
  Set Suite Variable  ${TL_TYPE_PATH}
  Run Keyword If  '${TL_TYPE_PATH}'=='None'  Log To Console With Time Prefix  '\${TL_TYPE_PATH} not define'  WARN
  Run Keyword If  '${TL_TYPE_PATH}'=='None'  Fail

Get L1bypass Mode
    [Documentation]    This keyword is to check testline l1mode or not
    ${output}    Execute Aashell Cmd    tag -a
    ${result}=    Run Keyword And Return Status   should contain  ${output}   L1BypassMap
    ${L1_TYPE}=    Set Variable IF     "${result}" == "True"    L1b    FS
    Set Suite Variable    ${L1_TYPE}    ${L1_TYPE}
    Log  L1_TYPE\=${L1_TYPE}  console=True

Judge Rru Updated
    [Arguments]    ${rrus_in_iphy_xml_before_startup}
    [Documentation]    This keyword is to check if simulated rru types are changed after imporing new iphy.xml
    ${rrus_in_iphy_xml_after_startup}=    Get Rrus From Iphy Xml
    Set Suite Variable  ${RRUS_IN_IPHY_XML}    ${rrus_in_iphy_xml_after_startup}
    Sort List    ${rrus_in_iphy_xml_before_startup}
    Sort List    ${rrus_in_iphy_xml_after_startup}
    ${rru_updated}    Run Keyword And Return Status
    ...    Should Not Be Equal      ${rrus_in_iphy_xml_before_startup}    ${rrus_in_iphy_xml_after_startup}
    [Return]  ${rru_updated}

Start to Capture GNB and AP Bip Log
    [Arguments]    ${tag}=${empty}
    Run Keyword And Ignore Error    Start To Capture GNB BIP Log    ${tag}
    Run Keyword And Ignore Error    Run Keyword If    '${BTS_NUMBER}'=='2'    Start To Capture GNB BIP Log GNB2    ${tag}
    Run Keyword And Ignore Error    Start To Capture AP BIP Log    ${tag}

Stop to Capture GNB and AP Bip Log
    [Arguments]    ${tag}=${empty}    ${sleep_timer}=30s    ${combine_flag}=True
    Sleep    ${sleep_timer}    # wireshark log may have delay
    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log    ${tag}    ${combine_flag}
    Run Keyword And Ignore Error    Run Keyword If    '${BTS_NUMBER}'=='2'    Stop To Capture GNB BIP Log GNB2    ${tag}    ${combine_flag}
    Run Keyword And Ignore Error    Stop To Capture AP BIP Log    ${tag}

Setup 2Airphone Env
  [Arguments]  ${tl_type}=fddtdd_sansa_cmwv/L1B/6cells_gnb1_2T2F_gnb2_2T  ${match_string}=${EMPTY}  ${cfg}=auto  ${ue_count}=30
  [Documentation]
  ...  This keyword is to setup airphone env.
  ...  | step1 | decide golden template location according to GNB and AP HW type and argument \${tl_type} |
  ...  | step2 | change vendor parameters according to \@{PARAMS_IN_VENDOR} |
  ...  | step3 | change swconfig in GNB according to \@{PARAMS_IN_SWCONFIG} |
  ...  | step4 | change swconfig in AP according to \@{PARAMS_IN_SWCONFIG_AP} |
  ...  | step5 | upgrade iphy.xml, change it according to \@{PARAMS_IN_IPHY_XML} and upload to AP |
  ...  | step6 | modify golden SCFC according to \@{PARAMS_IN_SCF} and full commission GNB with it |
  ...  | step7 | auto generate cfg file |
  ...  | step8 | start WTS and wait BTS onair |
  ...  | step9 | if BTS can't onair, retry several times specified in \${BTS_STARTUP_RETRY}. Default is one time |
  ...
  ...  | Arguments    | Man. | Default  | Description |
  ...  | tl_type      | No   | fdd_sansa_cmwv/FS/2cells | specify golden template sub-directory |
  ...  | match_string | No   | ${EMPTY} | the string in egate_console.log indicates case can start to run |
  ...  | cfg          | No   | auto     | if auto cfg function is not ready, give wts cfg file for workaround |
  ...  | ue_count     | No   | 30       | will be optimized |
  ...
  ...  Example
  ...  | Setup 2Airphone Env | tl_type=fddtdd_sansa_cmwv/L1B/4cells_2F2T |
  ...  | Setup 2Airphone Env | tl_type=fdd_sansa_cmwv/FS/1cell           | match_string=GNB-3: XnAP Link with GNB-2 |
  ...  | Setup 2Airphone Env | tl_type=fdd_sansa_cmwv/FS/1cell           | cfg=wts_zy.cfg | #as workaround

  Set Suite Variable  ${BTS_NUMBER}  2
  Set Suite Variable  ${MAX_UE_NUMBER_IN_WTS}  ${ue_count}
  Run Keyword If  ${DEBUG}  Debug Enter Into Egate For 2GNB
  Return From Keyword If  ${DEBUG}
#  configuration_reset_gnb_if_in_commissioned_state
  _Get Iphy Info
  _Set Iphy Ip
  _Decide Config Path For UTE Cloud 2GNB
  _Setup GNB2
#  _Get Duplex and Network mode    ${tl_type}
  #start bts for the first time
  ${onair_status}  _Start 2BTS For The First Time  ${tl_type}  ${ue_count}  ${cfg}
  #bts startup retry
  Run Keyword If  ${onair_status} is ${False}  _Retry To Start 2GNB
  Egate Console Log Should Contain  ${WTS_DIR}${/}egate_console.log  ${match_string}
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2nrt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=l2rt  sleep_time=1
  Execute Egate Command  sim_debug_log level=${AP_UDPLOG_LEVEL} app_type=ueproxy  sleep_time=1

Change Rd Parameters 2GNB
  Change Enb Conf Ini    node_type=CPUE    params=${PARAMS_IN_CP_UE_RD}
  Change Enb Conf Ini    node_type=CPCL    params=${PARAMS_IN_CP_CL_RD}
  Change Enb Conf Ini GNB2    node_type=CPUE    params=${PARAMS_IN_CP_UE_RD_GNB2}
  Change Enb Conf Ini GNB2    node_type=CPCL    params=${PARAMS_IN_CP_CL_RD_GNB2}
  Create Cp Runtime ini    params=${PARAMS_IN_CP_RUNTIME}
  Create Cp Runtime ini GNB2    params=${PARAMS_IN_CP_RUNTIME_GNB2}

_Start 2BTS For The First Time
  [Arguments]  ${tl_type}  ${ue_count}  ${cfg}
  ${onair_status}  Set Variable  ${False}
  Start To Capture Logs    startup_1
  Log To Console  \n===start 2bts for 1st time===
  ${sw_updated}    Judge Sw Updated
  ${rru_types_in_iphy_before_startup}    Get Rrus From Iphy Xml    target_file_name=old_iphy
  Change Vendor Parameters    ${PARAMS_IN_VENDOR}
  change vendor parameters gnb2    ${PARAMS_IN_VENDOR_GNB2}
  Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/${tl_type}/gnb_swconfig.txt
  change swconfig file gnb2    ${PARAMS_IN_SWCONFIG_GNB2}    ${CONFIG_PATH}/${tl_type}/gnb_swconfig.txt
  Change Rd Parameters 2GNB
  Change Swconfig File Of Airphone    ${PARAMS_IN_SWCONFIG_AP}    ${CONFIG_PATH}/${tl_type}/ap_swconfig.txt
  Modify And Upload Iphy Xml  ${PARAMS_IN_IPHY_XML}  ${CONFIG_PATH}${/}${tl_type}${/}iphy.xml  ${PARAMS_IN_SCF}  ${PARAMS_IN_SCF_GNB2}
  ${rru_updated}=    Judge Rru Updated    ${rru_types_in_iphy_before_startup}
  ${scf_for_startup1}    Modify Scf And Perform Full Commission    ${CONFIG_PATH}/${tl_type}/SCFC_1.xml    ${PARAMS_IN_SCF}
  ${scf_for_startup2}    Modify Scf And Perform Full Commission GNB2    ${CONFIG_PATH}/${tl_type}/SCFC_2.xml    ${PARAMS_IN_SCF_GNB2}
  Run Keyword If    ${sw_updated} is ${True} or ${rru_updated} is ${True}    Restart Gnb And Airphone    2
  _handle cfg bts2   ${scf_for_startup1}    ${scf_for_startup2}    ${ue_count}    ${tl_type}    ${cfg}
  Log To Console With Time Prefix    step: wait 2GNB and Airphone SSH connected
  Make Sure GNB AP SSH OK
  Make Sure GNB SSH OK GNB2
  run keyword if    ${WIRESHARK_FLAG} is ${True}    Start To Capture Wireshark Log    startup_1
  run keyword if    ${WIRESHARK_FLAG} is ${True}    start to capture wireshark log gnb2    startup_1
  ${rru_startup_time}    Set Variable If    ${sw_updated} or ${rru_updated}    900  300
  ${onair_status}  Start Wts And Wait Until 2Gnb Onair  ${WTS_DIR}/wts.cfg  ${DEBUG_LOG_LEVEL}  ${rru_startup_time}
  ...  tag=startup_1
  ${status}    Run Keyword And Return Status    Keyword Should Exist    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  Run Keyword If    ${status} and ${onair_status}    ${KEYWORD_PERFORM_STEPS_AFTER_ONAIR}
  [Teardown]    Collect Logs For Startup    startup_1    ${onair_status}
  [Return]    ${onair_status}

Add NetConf Account If RRU is ORAN
    @{rrus_in_iphy_xml}    get rrus from iphy xml
    ${rrus_in_iphy_xml}    catenate  @{rrus_in_iphy_xml}
    run keyword if    "ORAN" in "${rrus_in_iphy_xml}"    Make Sure GNB AP SSH OK
    run keyword if    "ORAN" in "${rrus_in_iphy_xml}"    Configure Netconf radio management
    ...    authentication_method=NoAuthentication
    ...    id=1
    ...    name=xranuser
    ...    password=xran-password
    ...    unsecure_ciphering=False
    ...    dist_name=
    ...    format=
    ...    value=

Conver some variables
   ${SOS_REPORT_FLAG_DIC}    Update list parameters to DIC    ${SOS_REPORT_FLAG}
   ${SNAPSHOT_FLAG_DIC}    Update list parameters to DIC    ${SNAPSHOT_FLAG}
   ${SOS_REPORT_STARTUP_1_FLAG_DIC}    Update list parameters to DIC    ${SOS_REPORT_STARTUP_1_FLAG}
   Set suite variable    ${SOS_REPORT_FLAG_DIC}
   Set suite variable    ${SNAPSHOT_FLAG_DIC}
   Set suite variable    ${SOS_REPORT_STARTUP_1_FLAG_DIC}

Update list parameters to DIC
    [Arguments]    ${params}
    ${param_dict}    Create Dictionary
    ${params_list}    set variable    ${params.split(',')}
    BuiltIn.Log    ${params_list[0]}
    FOR    ${index}    IN RANGE    0    len(${params_list})
           ${item_list}    set variable    ${params_list[${index}].split(':')}
           set to dictionary    ${param_dict}    ${item_list[0]}    ${item_list[1]}
    END
    [Return]    ${param_dict}
