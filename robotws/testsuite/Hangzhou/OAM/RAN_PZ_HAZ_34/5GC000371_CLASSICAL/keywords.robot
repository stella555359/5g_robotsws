*** Settings ***
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

*** Variables ***
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog      none

*** Keywords ***
5GC000371_CLASSICAL Setup
  Run Keyword And Ignore Error    ssh.Disconnect  connection=RU_1
  Run Keyword And Ignore Error    ssh.Disconnect  connection=ASIK
  Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
  coam.connect_to  bts_host=${ASIK_IP_OAM}  bts_port=${COAM_ADMIN_PORT}
  ...  username=${COAM_ADMIN_username}  password=${COAM_ADMIN_password}  use_ssl=True  update_interval=5000  
  ...  name=coam_admin
  ${current_sw_version}  coam.get_sw_version  timeout=600s  connection=coam_admin
  Set Suite Variable  ${current_sw_version}
  ${result}    run keyword and return status    should contain any
  ...    ${current_sw_version}
  ...    21A    20B    22R1    22R2    21B
  ${release}    Set Variable If    ${result}    branch    trunk
  Set Suite Variable    ${release}
  Run keyword and continue on failure  coam.collect_scf  
  ...  target_file_name=${PATH_Storage}/SCF_${tl.gnbs[0].instance_id}.xml
  ...  export_type=configuration  connection=coam_admin
  Set Suite Variable  ${ORIGINAL_SCF_PATH}  ${PATH_Storage}/SCF_${tl.gnbs[0].instance_id}.xml
  ${scf_validation_results}  coam.validate_scf  scf_file=${ORIGINAL_SCF_PATH}  timeout=600s  connection=coam_admin
  Should Be Equal As Strings  ${scf_validation_results["pdlValidationResult"]["status"]}  OK 
  ${get_nrcell}  Run keyword and continue on failure  coam.get_managed_objects  NRCELL_A  timeout=600s  
  ...  connection=coam_admin
  Set Suite Variable  ${cellTechnology}  ${get_nrcell[0]["parameters"]["cellTechnology"]}
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}  password=${ASIK_password}	alias=ASIK
  ${HOSTNAME}  ssh.Execute  hostname  timeout=10  connection=ASIK
  Set Suite Variable  ${HOSTNAME}  ${HOSTNAME.split("\r\n")[0]}
  Set Suite Variable  ${BOARDID}  ${HOSTNAME.split("-")[1].split("a")[0]}
  ${OWNNID}  ssh.Execute  ownnid  timeout=10  connection=ASIK
  Set Suite Variable  ${OWNNID}  ${OWNNID.split("\r\n")[0]}
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK
  ${get_trblcadm}  coam.get_managed_objects  TRBLCADM_A  timeout=600s  connection=coam_admin
  Set Suite Variable  ${original_value}  ${get_trblcadm[0]["parameters"]["snapshotUploadDelayForFault6450"]}
  ${pre}  ${post}  Split String  ${get_trblcadm[0]["distName"]}  SCF  1
  ${pre}  ${post}  Split String  ${post}  /  1
  ${distName}  Remove String  ${post}  _A
  Set Suite Variable  ${distName}
  ${get_smod}  Run keyword and continue on failure  coam.get_managed_objects  SMOD_R  timeout=600s
  ...  connection=coam_admin
  Set Suite Variable  ${CONTROLLER_BOARD_TYPE}  ${get_smod[0]["parameters"]["productName"]}
  Run keyword and continue on failure  coam.perform_parameter_recommissioning  dist_name=${distName}
  ...  parameter=snapshotUploadDelayForFault6450  value=24  operation=update  skip_parameter_relation_errors=True
  ...  timeout=600s  connection=coam_admin
  ${get_trblcadm}  coam.get_managed_objects  TRBLCADM_A  timeout=600s  connection=coam_admin
  Should Be Equal As Strings  ${get_trblcadm[0]["parameters"]["snapshotUploadDelayForFault6450"]}  24
  Active Alarms List Should Be Empty
  ${hw_info}    coam.get_detected_hw_info    connection=coam_admin
  @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
  ${count_RUs}    Get length    ${list_RUs}
  Set Suite Variable    ${NUMBER_OF_RMOD}    ${count_RUs}
  ${bbmod_info}    coam.get_fbb_info     connection=coam_admin
  ${bbmod_nums}    get length    ${bbmod_info}
  Set Suite Variable    ${NUMBER_OF_BBMOD}    ${bbmod_nums}
  Check BTS status
  coam.teardown  connection=coam_admin
  Run  pkill -f btslog
  Run  rm /tmp/btslog2/*
  Run  pkill -f admin

5GC000371_CLASSICAL Teardown
  coam.connect_to  bts_host=${ASIK_IP_OAM}  bts_port=${COAM_ADMIN_PORT}
  ...  username=${COAM_ADMIN_username}  password=${COAM_ADMIN_password}  use_ssl=True  update_interval=5000
  ...  name=coam_admin
  Run keyword and continue on failure  Get Active Alarms
  Run keyword and continue on failure  coam.perform_parameter_recommissioning  dist_name=${distName}
  ...  parameter=snapshotUploadDelayForFault6450  value=${original_value}  operation=update
  ...  skip_parameter_relation_errors=True
  ...  timeout=600s  connection=coam_admin
  ${get_trblcadm}  coam.get_managed_objects  TRBLCADM_A  timeout=600s  connection=coam_admin
  Should Be Equal As Strings  ${get_trblcadm[0]["parameters"]["snapshotUploadDelayForFault6450"]}  ${original_value}
  coam.teardown  connection=coam_admin
  Run Keyword And Ignore Error    ssh.Disconnect  connection=RU_1
  Run Keyword And Ignore Error    ssh.Disconnect  connection=ASIK
  Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM

Active Alarms List Should Be Empty
  ${active_alarms_list}  Run Keyword And Continue On Failure  Get Active Alarms
  ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Remove Allowed Alarms From Active Alarm List
  ...  ${active_alarms_list}  ${ALLOWED_ALARMS}
  Run Keyword And Continue On Failure  Should Be Equal as Integers  ${not_allowed_alarms_number}  0

Get Active Alarms
  Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7319
  Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7300
  ${active_alarms_list}  Run Keyword And Continue On Failure   coam.get_active_alarms   connection=coam_admin
  ...   timeout=600s
  [Return]  ${active_alarms_list}

Wait For Fault with Alarm to disappear
  [Arguments]  ${FaultID}
  wait until keyword succeeds  1200      5    Fault Should Not Be Present   ${FaultID}

Fault Should Not Be Present
  [Arguments]    ${fault_id}
  ${active_alarms}    coam.get_active_alarms    timeout=600s    connection=coam_admin
  ${len}    Get Length    ${active_alarms}
  ${alarm_id_list}    Create List
  FOR    ${i}    IN RANGE    ${len}
      ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
      Append To List    ${alarm_id_list}    ${tmp_id}
  END
  ${list}     convert to string  ${alarm_id_list}
  Should Not Contain     ${list}    ${fault_id}

Remove Allowed Alarms From Active Alarm List
  [Arguments]  ${active_alarms_list}=none  ${allowed_alarms_list}=none
  ${active_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${active_alarms_list}
  ${not_allowed_alarms_list}  Run Keyword And Continue On Failure  Create List
  FOR  ${alarm_id}  IN RANGE  ${active_alarms_number}
      ${checked_alarm_faultId}  Run Keyword And Continue On Failure  Set Variable
      ...    ${active_alarms_list[${alarm_id}]["faultId"]}
      ${not_on_list}  Check If Alarm Allowed   allowed_alarms_list=${allowed_alarms_list}
      ...   checked_alarm=${checked_alarm_faultId}
      ${alarm}  Run Keyword And Continue On Failure   Get From List  ${active_alarms_list}   ${alarm_id}
      Run Keyword If  ${not_on_list}   Append To List  ${not_allowed_alarms_list}   ${alarm}
  END
  ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${not_allowed_alarms_list}
  [Return]  ${not_allowed_alarms_number}

Check If Alarm Allowed
  [Arguments]  ${allowed_alarms_list}=none  ${checked_alarm}=none
  ${allowed_alarms_number}  Get Length  ${allowed_alarms_list}
  FOR  ${allowed_alarms_id}  IN RANGE  ${allowed_alarms_number}
    ${status}  Run Keyword And Return Status  Should Not Be Equal as Strings  ${checked_alarm}
    ...   ${allowed_alarms_list[${allowed_alarms_id}]}
    Exit For Loop If  ${status}==${FALSE}
  END
  [Return]  ${status}

Check BTS status
  ${bts_status}=  coam.get_bts_statuses  connection=coam_admin
  Run keyword and continue on failure    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir 

Get RMOD IP from Info Model
  ${get_rmod_l}  Run keyword and continue on failure  coam.get_managed_objects  RMOD_L  timeout=600s
  ...  connection=coam_admin
  ${IP}  Set Variable  ${get_rmod_l[${select_rmod_randomly}]["parameters"]["ipAddress"]}
  should not be equal as strings    ${IP}    0.0.0.0
  Set Suite Variable  ${IP}

Check if RU is pingable
  [Arguments]  ${received_packet}
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}	alias=ASIK
  ${output}=         ssh.Execute       ping -c 1 -W 10 ${IP}     connection=ASIK
  Should contain      ${output}   1 packets transmitted, ${received_packet} received
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

Wait For Fault with Alarm to appear
  [Arguments]  ${FaultID}
  wait until keyword succeeds  1200      5    Fault Should Be Present   ${FaultID}

Fault Should Be Present
    [Arguments]    ${fault_id}
    ${active_alarms}    coam.get_active_alarms    timeout=600s    connection=coam_admin
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
       ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
       Append To List    ${alarm_id_list}    ${tmp_id}
    END
    ${list}     convert to string  ${alarm_id_list}
    Should Contain     ${list}    ${fault_id}

Crash RU
  Connect to gnb coam via ssl 
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to
  ...     hostname=${ASIK_IP_LMP}  username=${ASIK_username}
  ...  password=${ASIK_password}	alias=ASIK
  ${NODEID_FHNET}  ssh.Execute
  ...  ls -al /tmp/node* | grep FHNET | head -1 | awk -F '_' '{print $2}' | awk -F ' ' '{print $1}'  connection=ASIK
  ...  timeout=10
  ssh.Execute  
  ...  lxc-attach -n ${NODEID_FHNET.split("\r\n")[0]} -- /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes"
  ...  connection=ASIK  timeout=10
  sleep    1s
  coam_siso_common.Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK 
  ${ps_edf_output}  Run Keyword And Continue On Failure  ssh.Execute  ps  connection=RU_1  timeout=10
  Log  ${ps_edf_output}
  ${ps_cmd_RU}  ssh.Execute  ps | grep CCSDaemonExe | awk '{print $1}' | xargs -n1  connection=RU_1
  ${ps_Killcmd_RU}  ssh.Execute  ps | grep CCSDaemonExe | awk '{print $1}' | xargs kill -11 $1  connection=RU_1
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=RU_1
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK
  COAM Teardown gnb connections    connection=GNB_OAM

Check RU
  [Arguments]  ${STATE}
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_B_TC_4_FID_4527/${STATE}
  Connect to gnb coam via ssl
  Run Keyword And Continue On Failure    wait until keyword succeeds  20min  5s    coam_siso_common.RU Should Be Online
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to
  ...  hostname=${ASIK_IP_LMP}  username=${ASIK_username}  password=${ASIK_password}	alias=ASIK
  coam_siso_common.Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK
  ${ls_l_output}  Run Keyword And Continue On Failure  ssh.Execute  ls -lR /var/log/aasyslog/
  ...  connection=RU_1  timeout=10
  Log  ${ls_l_output}
  ${pm_1_exist}  ssh.File Exists  /var/log/aasyslog/pm_1_DEFAULT.log.xz  connection=RU_1
  Set Suite Variable  ${pm_1_exist}
  ${pm_2_exist}  ssh.File Exists  /var/log/aasyslog/pm_2_syslog.log.zip  connection=RU_1
  Set Suite Variable  ${pm_2_exist}
  ${runtime_exist}  ssh.File Exists  /var/log/aasyslog/runtime_DEFAULT.bin  connection=RU_1
  ${pm_1}  Run Keyword And Continue On Failure  ssh.Execute  md5sum /var/log/aasyslog/pm_1_DEFAULT.log.xz
  ...  connection=RU_1  timeout=10
  Set Suite Variable  ${pm_1}
  ${pm_2}  Run Keyword And Continue On Failure  ssh.Execute  md5sum /var/log/aasyslog/pm_2_syslog.zip
  ...  connection=RU_1  timeout=10
  Set Suite Variable  ${pm_2}
  ${runtime}  Run Keyword And Continue On Failure  ssh.Execute  md5sum /var/log/aasyslog/runtime_DEFAULT.bin
  ...  connection=RU_1  timeout=10
  Set Suite Variable  ${runtime}
  Run Keyword If  ${pm_1_exist} == ${TRUE}  ssh.Download File  /var/log/aasyslog/pm_1_DEFAULT.log.xz
  ...  ${PATH_Storage}/5GC000371_B_TC_4_FID_4527/${STATE}/pm_1_DEFAULT.log.xz  connection=RU_1    timeout=1200
  Run Keyword If  ${pm_2_exist} == ${TRUE}  ssh.Download File  /var/log/aasyslog/pm_2_syslog.zip
  ...  ${PATH_Storage}/5GC000371_B_TC_4_FID_4527/${STATE}/pm_2_syslog.zip  connection=RU_1    timeout=1200
  Run Keyword If  ${runtime_exist} == ${TRUE}  ssh.Download File  /var/log/aasyslog/runtime_DEFAULT.bin
  ...  ${PATH_Storage}/5GC000371_B_TC_4_FID_4527/${STATE}/runtime_DEFAULT.bin  connection=RU_1    timeout=1200
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=RU_1
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK
  COAM Teardown gnb connections    connection=GNB_OAM
   
Collect snapshot
  [Arguments]  ${TEST_ID}=none
  Run keyword and continue on failure  coam.get_snapshot
  ...  target_file_name=${PATH_Storage}/${TEST_ID}/snapshot_${TEST_ID}.zip
  ...  coverage=Full  timeout=1200  connection=coam_admin

Check dumps
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}  password=${ASIK_password}  alias=ASIK
  Run Keyword And Continue On Failure  Run keyword If
  ...  '${cellTechnology}' != 'FDD' or '${CONTROLLER_BOARD_TYPE}' == 'ASIB AirScale Common'  
  ...  Run Keyword And Continue On Failure  Set Suite Variable  ${dumps_directory}  dumps
  ...  ELSE  Run Keyword And Continue On Failure  Set Suite Variable  ${dumps_directory}  dumps_prev_cycle
  ${dumps_exist}  Run Keyword And Continue On Failure  ssh.File Exists  
  ...  /ffs/run/logs/${BOARDID}/A/${dumps_directory}/node_${OWNNID}/${OWNNID}_bt-coreinfo.txt  connection=ASIK
  ${ffs_run_logs}  Run Keyword And Continue On Failure  ssh.Execute  ls -lR /ffs/run/logs/  connection=ASIK  timeout=10
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK
  Run Keyword And Continue On Failure  Run keyword If  ${dumps_exist} == ${TRUE}  Run Keyword And Continue On Failure
  ...  Check dumps core

Check dumps core
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  Run keyword and continue on failure  ssh.Execute  ls -lR /ffs/run/logs/  connection=ASIK  timeout=180
  ${dumps_core}  Run Keyword And Continue On Failure  ssh.Execute  
  ...  ls /ffs/run/logs/ccsdumps/${BOARDID}/A/${dumps_directory}/node_${OWNNID}/*.core.*
  ...  connection=ASIK  timeout=10
  Run Keyword And Continue On Failure  Set Suite Variable  ${dumps_core}
  ${find_output}  Run Keyword And Continue On Failure  ssh.Execute
  ...  find /ffs/run/logs/ccsdumps/${BOARDID}/A/${dumps_directory}/node_${OWNNID}/*
  ...  connection=ASIK  timeout=10
  @{files_list}  Run Keyword And Continue On Failure  Split String  ${find_output}  \r\n  
  # Protection for Unix-Style check
  Run Keyword And Continue On Failure  Remove From List  ${files_list}  -1
  Run Keyword And Continue On Failure  ssh.Download File  ${files_list}  
  ...  ${PATH_Storage}/5GC000371_C_TC_5_RAU_LOGS_AVAILABILITY/${STATE}/
  ...  connection=ASIK
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

Check blackbox
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  
  ...  hostname=${ASIK_IP_LMP}  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  ${blackbox}  Run Keyword And Continue On Failure  ssh.Execute  
  ...  grep -B1 "SW VERSION: active" /ffs/run/config/lifedata/blackbox | head -1
  ...  connection=ASIK  timeout=10
  Run Keyword And Continue On Failure  Set Suite Variable  ${blackbox}
  Run Keyword And Continue On Failure  ssh.Download File  /ffs/run/config/lifedata/blackbox
  ...  ${PATH_Storage}/5GC000371_C_TC_5_RAU_LOGS_AVAILABILITY/${STATE}/blackbox  connection=ASIK
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

Check postmortem
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  
  ...  hostname=${ASIK_IP_LMP}  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  Run Keyword And Continue On Failure  Run keyword If  '${current_sw_version.split("_")[0]}' == '5G19A'
  ...  Run Keyword And Continue On Failure  Set Suite Variable  ${postmortem_directory}  ${OWNNID}
  ...  ELSE  Run Keyword And Continue On Failure  Set Suite Variable  ${postmortem_directory}  ${HOSTNAME}
  ${postmortem}  Run Keyword And Continue On Failure  ssh.Execute  
  ...  ls -rt /ffs/run/logs/${postmortem_directory}_aasyslog/AaSysLog* | tail -1
  ...  connection=ASIK  timeout=10
  Run Keyword And Continue On Failure  Set Suite Variable  ${postmortem}
  Run Keyword And Continue On Failure  ssh.Download File  ${postmortem.split("\r\n")[0]}
  ...  ${PATH_Storage}/5GC000371_C_TC_5_RAU_LOGS_AVAILABILITY/${postmortem.split("/")[5].split("\r\n")[0]}
  ...  connection=ASIK
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

Crash ASIK XEONA
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  ${ps_edf_output}  Run Keyword And Continue On Failure  ssh.Execute  ps -edf  connection=ASIK  timeout=10
  Log  ${ps_edf_output}
  Run Keyword And Continue On Failure  ssh.Execute
  ...  ps -edf | grep CCSDaemonExe | grep "\=nid\=${OWNNID}" | awk '{print $2}' | xargs kill -11 $1
  ...  connection=ASIK  timeout=10
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

Crash LONER
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect To  
  ...  hostname=${BBMOD${BBMOD_ID}_IP_LONER}
  ...  username=${ASIK_username}  password=${ASIK_password}  proxy=ASIK  alias=LONER
  ${ps_edf_output}  Run Keyword And Continue On Failure  ssh.Execute  ps -edf  connection=LONER  timeout=10
  Log  ${ps_edf_output}
  ${LONER_TYPE}  ssh.Execute  cat /etc/os-release | grep HIFIX_VERSION_ID | awk -F '-' '{print $2}'  connection=LONER
  ...  timeout=10
  Run Keyword And Ignore Error  ssh.Execute  ps -edf | grep sfpd | awk '{print $2}' | xargs kill -11 $1
  ...  connection=LONER  timeout=10
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=LONER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK
  [Return]  ${LONER_TYPE.split("\r\n")[0]}
  
Check loner dumps
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  ${NODEID_FHNET}   ssh.Execute  
  ...  ls -al /tmp/node* | grep FHNET | head -1 | awk -F '_' '{print $2}' | awk -F ' ' '{print $1}'  connection=ASIK
  ...  timeout=10
  ${FHNET}     Set Variable     ${NODEID_FHNET.split("\r\n")[0]}
  ${local}     Set Variable     ${NODEID_FHNET[2:3]}

  Run keyword If    'ABIO' in '${BBMOD}'     Set Suite Variable  ${local_2}  4
  ...    ELSE    Set Suite Variable  ${local_2}  5

  Run Keyword And Ignore Error  wait until keyword succeeds  5min  5s  ssh.Connect To
  ...  hostname=${BBMOD${BBMOD_ID}_IP_XEONA}
  ...  username=${ASIK_username}  password=${ASIK_password}  proxy=ASIK  alias=ABIL${BBMOD_ID}MASTER
  Run Keyword And Ignore Error  wait until keyword succeeds  5min  5s  ssh.Connect To
  ...  hostname=${BBMOD${BBMOD_ID}_IP_XEONA}
  ...  username=${ASIK_username}  proxy=ASIK  alias=ABIL${BBMOD_ID}MASTER
  ${var_log_loner}  Run Keyword And Continue On Failure  ssh.Execute
  ...  ls -lR /var/log/loner/  connection=ABIL${BBMOD_ID}MASTER  timeout=10
  # ${dumps_exist}  ssh.Execute  ls -trl /var/log/loner/dumps | wc -l  connection=ABIL${BBMOD_ID}MASTER 
  ${dumps_exist_1}  ssh.Execute
  ...  ls -trl /var/log/loner/crash_logs/coredumper/blackbox | wc -l  connection=ABIL${BBMOD_ID}MASTER 
  ${dumps_exist_2}  ssh.Execute
  ...  ls -trl /ffs/run/logs/L1_logs/${local}2${local_2}d/coredumper/blackbox | wc -l
  ...  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

  Connect to gnb coam via ssl
  ${sw_version}     coam.get_sw_version    connection=GNB_OAM
  ${result_21B}    run keyword and return status    should contain any
  ...    ${sw_version}
  ...    21B
  ${result_other}    Set Variable If    ${result_21B}    False    True
  COAM Teardown gnb connections

  Run Keyword And Continue On Failure  Run keyword If  ${result_21B}  Run Keyword If
  ...  '${dumps_exist_1.split("\r\n")[0]}'>'1'  Run Keyword And Continue On Failure  Check loner dumps blackbox
  ...  /var/log/loner/crash_logs/coredumper/blackbox
  ...  ${result_21B}
  Run Keyword And Continue On Failure  Run keyword If  ${result_other}  Run Keyword If
  ...  '${dumps_exist_2.split("\r\n")[0]}'>'1'  Run Keyword And Continue On Failure  Check loner dumps blackbox
  ...  /ffs/run/logs/L1_logs/${local}2${local_2}d/coredumper/blackbox
  ...  ${result_21B}
  
Check loner dumps blackbox
  [Arguments]  ${dumps_directory}   ${result_21B}
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect To
  ...  hostname=${BBMOD${BBMOD_ID}_IP_XEONA}
  ...  username=${ASIK_username}  password=${ASIK_password}
  ...  proxy=ASIK  alias=ABIL${BBMOD_ID}MASTER

  ${loner_dumps}  Run Keyword And Continue On Failure  Run keyword If  ${result_21B}
  ...  ssh.Execute  ls ${dumps_directory}/blackbox*.gz   connection=ABIL${BBMOD_ID}MASTER   timeout=10
  ...  ELSE   ssh.Execute  ls ${dumps_directory}/*coredumper*.tgz   connection=ABIL${BBMOD_ID}MASTER   timeout=10

  Run Keyword And Continue On Failure  Set Suite Variable  ${loner_dumps}
  ${find_output}  Run Keyword And Continue On Failure  ssh.Execute  find ${dumps_directory}/*
  ...  connection=ABIL${BBMOD_ID}MASTER  timeout=10
  @{files_list}  Run Keyword And Continue On Failure  Split String  ${find_output}  \r\n
  # Protection for Unix-Style check
  Run Keyword And Continue On Failure  Remove From List  ${files_list}  -1
  Run Keyword And Continue On Failure  ssh.Download File  ${files_list}
  ...  ${PATH_Storage}/5GC000371_C_TC_6_L1_LOGS_AVAILABILITY/${STATE}/
  ...  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

Check service_failures
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect To
  ...  hostname=${BBMOD${BBMOD_ID}_IP_XEONA}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  proxy=ASIK  alias=ABIL${BBMOD_ID}MASTER
  # ${dumps_exist}  ssh.Execute  ls -trl /var/log/loner/service_failures/ | wc -l  connection=ABIL${BBMOD_ID}MASTER
  ${dumps_exist_1}  ssh.Execute
  ...  ls -trl /var/log/loner/crash_logs/failurehandler/archives/ | wc -l  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK
  Run Keyword And Continue On Failure  Run keyword If  '${dumps_exist_1.split("\r\n")[0]}'>'1'
  ...  Run Keyword And Continue On Failure  Check service_failures targz
  ...  /var/log/loner/crash_logs/failurehandler/archives

Check service_failures targz
  [Arguments]  ${dumps_directory}
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect to  hostname=${ASIK_IP_LMP}
  ...  username=${ASIK_username}
  ...  password=${ASIK_password}  alias=ASIK
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  ssh.Connect To
  ...  hostname=${BBMOD${BBMOD_ID}_IP_XEONA}
  ...  username=${ASIK_username}  password=${ASIK_password}
  ...  proxy=ASIK  alias=ABIL${BBMOD_ID}MASTER
  ${service_failures}  Run Keyword And Continue On Failure  ssh.Execute  ls ${dumps_directory}/*gz
  ...  connection=ABIL${BBMOD_ID}MASTER  timeout=10
  Run Keyword And Continue On Failure  Set Suite Variable  ${service_failures}
  Run Keyword And Continue On Failure  ssh.Download File  ${service_failures.split("\r\n")[0]}
  ...  ${PATH_Storage}/5GC000371_C_TC_6_L1_LOGS_AVAILABILITY/${STATE}/service_failures.tar.gz
  ...  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ABIL${BBMOD_ID}MASTER
  Run Keyword And Continue On Failure  ssh.Disconnect  connection=ASIK

Check BBMOD status
    [Arguments]  ${AVAILABILITYSTATUS}  ${OPERATIONALSTATE}    ${bbmod_index}=${1}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    
    &{bbmod_status}    COAM get bbmod detial info by bbmod index     bbmod_index=${bbmod_index}
    ...   connection=${connection}
    ${AVAILABILITY}  Set Variable If  'Offline'=='${AVAILABILITYSTATUS}' and 'trunk'=='${release}'
    ...  off line  ${AVAILABILITYSTATUS}
    Should be equal as strings    ${bbmod_status['status']['operationalState']}    ${OPERATIONALSTATE}
    ...    ignore_case=${True}
    Run keyword if  'branch' in '${release}'    Log    
    ...    availabilityStatus INFO:${bbmod_status['status']['availabilityStatus']}.
    Log    operationalState INFO:${bbmod_status['status']['operationalState']}.
    Run keyword if  'branch' in '${release}'    Should be equal as strings
    ...             ${bbmod_status['status']['availabilityStatus']}    ${AVAILABILITYSTATUS}
    ...    ELSE IF  'Offline'=='${AVAILABILITYSTATUS}'
    ...             Should Be Equal As Strings  ${bbmod_status['status']['availabilityStatus']}  ${AVAILABILITY}
    ...    ELSE IF  'Degraded'=='${AVAILABILITYSTATUS}'
    ...             Should Be Equal As Strings  ${bbmod_status['status']['availabilityStatus']}
    ...             ${AVAILABILITYSTATUS}    ignore_case=${True}
    COAM Teardown gnb connections    connection=GNB_OAM 
  
Check RU restart indication is sent to OAM
  Start Btslog With Path Check  
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_B_TC_4_FID_4527
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  coam.connect_to  bts_host=${ASIK_IP_OAM}  
  ...  bts_port=${COAM_ADMIN_PORT}    username=${COAM_ADMIN_username}  password=${COAM_ADMIN_password}  use_ssl=True  
  ...  update_interval=5000  name=coam_admin
  ${NUMBER_OF_RMOD-1}  Evaluate  ${NUMBER_OF_RMOD} - 1
  ${select_rmod_randomly}  Evaluate  random.randint(0, ${NUMBER_OF_RMOD-1})  modules=random
  Set Suite Variable  ${select_rmod_randomly}
  Run Keyword And Continue On Failure  Get RMOD IP from Info Model
  Run Keyword And Continue On Failure  Check RU  BEFORE
  Run Keyword And Continue On Failure  Set Suite Variable  ${pm_1_before}  ${pm_1}
  Run Keyword And Continue On Failure  Set Suite Variable  ${pm_2_before}  ${pm_2}
  Run Keyword And Continue On Failure  Set Suite Variable  ${runtime_before}  ${runtime}
  Run Keyword And Continue On Failure  Crash RU
  Run Keyword And Continue On Failure  Wait until Keyword Succeeds  1200s  1s  Check if RU is pingable  0
  ${result1}    run keyword and return status    Should Contain Any
  ...    ${current_sw_version}
  ...    24R3  24R2
  Run Keyword If    ${result1}  Run Keyword And Continue On Failure  Wait For Fault with Alarm to appear
  ...  FaultID=4527
  Run Keyword And Continue On Failure  Get RMOD IP from Info Model
  Run Keyword And Continue On Failure  Wait until Keyword Succeeds  1200s  1s  Check RU  AFTER
  Run keyword and continue on failure  Wait until Keyword Succeeds  1200s  1s  Check BTS status
  Collect logs after test    ${PATH_Storage}/5GC000371_B_TC_4_FID_4527 
  
Check RU logs availibility_case auto reset

  sleep  600s
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_A_TC_1_RU_LOGS_AVAILABILITY
  Run Keyword And Continue On Failure  Collect snapshot  5GC000371_A_TC_1_RU_LOGS_AVAILABILITY
  Run Keyword And Continue On Failure  Get Active Alarms
  Run Keyword And Continue On Failure  coam.teardown  connection=coam_admin
  Run Keyword If  ${pm_1_exist} == ${TRUE}  Should Not Be Equal As Strings  ${pm_1_before.split(" ")[0]}  
  ...    ${pm_1.split(" ")[0]}
  Run Keyword If  ${pm_2_exist} == ${TRUE}  Should Not Be Equal As Strings  ${pm_2_before.split(" ")[0]}  
  ...    ${pm_2.split(" ")[0]}
  Should Not Be Equal As Strings  ${runtime_before.split(" ")[0]}  ${runtime.split(" ")[0]}
 
RAU collection of its own RAU logs
  Start Btslog With Path Check   
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  coam.connect_to  bts_host=${ASIK_IP_OAM}  
  ...    bts_port=${COAM_ADMIN_PORT}    username=${COAM_ADMIN_username}  password=${COAM_ADMIN_password}  use_ssl=True  
  ...    update_interval=5000  name=coam_admin
  Run Keyword And Continue On Failure  Set Suite Variable  ${STATE}  BEFORE
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_C_TC_5_RAU_LOGS_AVAILABILITY/${STATE}
  Run Keyword And Continue On Failure  Set Suite Variable  ${dumps_core}  ${EMPTY}
  Run Keyword And Continue On Failure  Check dumps
  Run Keyword And Continue On Failure  Set Suite Variable  ${dumps_core_before}  ${dumps_core}
  Run Keyword And Continue On Failure  Check blackbox
  Run Keyword And Continue On Failure  Set Suite Variable  ${blackbox_before}  ${blackbox}
  Run Keyword And Continue On Failure  Check postmortem
  Run Keyword And Continue On Failure  Set Suite Variable  ${postmortem_before}  ${postmortem}
  Run Keyword And Continue On Failure  Crash ASIK XEONA
  Run Keyword And Continue On Failure  Set Suite Variable  ${STATE}  AFTER
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_C_TC_5_RAU_LOGS_AVAILABILITY/${STATE}
  Run Keyword And Continue On Failure  Wait For Fault with Alarm to appear    FaultID=6450
  Run Keyword And Continue On Failure  Check dumps core
  Run Keyword And Continue On Failure  Check blackbox
  Run Keyword And Continue On Failure  Check postmortem
  Should Not Be Equal As Strings  ${dumps_core_before}  ${dumps_core}
  Should Not Be Equal As Strings  ${blackbox_before}  ${blackbox}
  Should Not Be Equal As Strings  ${postmortem_before}  ${postmortem}
  Run keyword and continue on failure  Wait until Keyword Succeeds  1200s  1s  Check BTS status
  Run Keyword And Continue On Failure  Collect snapshot  5GC000371_C_TC_5_RAU_LOGS_AVAILABILITY
  Run Keyword And Continue On Failure  Get Active Alarms
  Run Keyword And Continue On Failure  coam.teardown  connection=coam_admin
  Collect logs after test    ${PATH_Storage}/5GC000371_C_TC_5_RAU_LOGS_AVAILABILITY 

L1 crash Log collection by RAU
  Start Btslog With Path Check 
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_C_TC_6_L1_LOGS_AVAILABILITY
  Run Keyword And Continue On Failure  wait until keyword succeeds  5min  5s  coam.connect_to  bts_host=${ASIK_IP_OAM}  
  ...    bts_port=${COAM_ADMIN_PORT}  username=${COAM_ADMIN_username}  password=${COAM_ADMIN_password}  use_ssl=True  
  ...    update_interval=5000  name=coam_admin
  Run Keyword And Continue On Failure  Set Suite Variable  ${STATE}  BEFORE
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_C_TC_6_L1_LOGS_AVAILABILITY/${STATE}
  Run Keyword And Continue On Failure  Set Suite Variable  ${loner_dumps}  ${EMPTY}
  ${NUMBER_OF_BBMOD-1}  Evaluate  ${NUMBER_OF_BBMOD} - 1
  ${select_bbmod_randomly}  Evaluate  random.randint(0, ${NUMBER_OF_BBMOD-1})  modules=random
  ${get_bbmod}  coam.get_managed_objects  BBMOD_R  timeout=600s  connection=coam_admin
  ${BBMOD_ID}  Evaluate  ${get_bbmod[${select_bbmod_randomly}]["parameters"]["verticalPosition"]} - 2
  Set Suite Variable  ${BBMOD_ID}
  Set Suite Variable  ${BBMOD_DN}  ${get_bbmod[${select_bbmod_randomly}]["distName"]}
  Run Keyword And Continue On Failure  Check loner dumps
  Run Keyword And Continue On Failure  Set Suite Variable  ${loner_dumps_before}  ${loner_dumps}
  #Run keyword If    'ABIL' in '${BBMOD}'    Run Keyword And Continue On Failure  Set Suite Variable
  #...  ${service_failures}  ${EMPTY}
  #Run keyword If    'ABIL' in '${BBMOD}'    Run Keyword And Continue On Failure  Check service_failures
  #Run keyword If    'ABIL' in '${BBMOD}'    Run Keyword And Continue On Failure  Set Suite Variable
  #...  ${service_failures_before}  ${service_failures}
  ${LONER_TYPE}  Run Keyword And Continue On Failure  Crash LONER
  Run keyword If    'ABIL' in '${BBMOD}'    Run Keyword And Continue On Failure    Wait until Keyword Succeeds  1200s  
  ...  1s    Check BBMOD status  Offline  Disabled
  Run keyword If    'ABIL' in '${BBMOD}'    Run Keyword And Continue On Failure  Wait until Keyword Succeeds  1200s  
  ...  1s    Check BBMOD status  Online  Enabled
  Run keyword If    'ABIO' in '${BBMOD}'    Run Keyword And Continue On Failure  Wait until Keyword Succeeds  1200s
  ...  1s    Check BBMOD status  Degraded  Enabled
  Run Keyword And Continue On Failure  Set Suite Variable  ${STATE}  AFTER
  Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/5GC000371_C_TC_6_L1_LOGS_AVAILABILITY/${STATE}
  Sleep    180s 
  Run Keyword And Continue On Failure  Check loner dumps
  Should Not Be Equal As Strings  ${loner_dumps_before}  ${loner_dumps}
  #Run keyword If    'ABIL' in '${BBMOD}'    Run Keyword And Continue On Failure  Check service_failures
  #Run keyword If    'ABIL' in '${BBMOD}'    Should Not Be Equal As Strings  ${service_failures_before}
  #...  ${service_failures}
  Run keyword and continue on failure  Wait until Keyword Succeeds  1200s  1s  Check BTS status
  Run Keyword And Continue On Failure  Collect snapshot  5GC000371_C_TC_6_L1_LOGS_AVAILABILITY
  Run Keyword And Continue On Failure  Get Active Alarms
  Run Keyword And Continue On Failure  coam.teardown  connection=coam_admin
  Collect logs after test    ${PATH_Storage}/5GC000371_C_TC_6_L1_LOGS_AVAILABILITY
  
Collect logs after test
    [Arguments]    ${SAVE LOG DIRECTORY}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}

COAM get bbmod detial info by bbmod index
    [Documentation]  Description: Get bbmod detail info by bbmod index
    ...              ${bbmod_index} Should be start from 1, should match the value with BBMOD_R-*
    [Arguments]    ${bbmod_index}=1    ${connection}=GNB_OAM
    ${bbmod_index}    Convert to string    ${bbmod_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_BBMODs}    Set variable    ${hw_info['basebandModules']}
    ${count_BBMODs}    Get length    ${list_BBMODs}
    Should be true    ${count_BBMODs}>=1    msg=No BBMOD found
    &{dict_BBMODs_detail_info}   Create dictionary
    FOR    ${BBMOD}    IN    @{list_BBMODs}
        ${status}    Run Keyword And Return Status    Should Contain   '${BBMOD}'   BBMOD_R-${bbmod_index}
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_BBMODs_detail_info}    ${bbmod_index}
        ...              ${BBMOD}
    END
    [Return]  ${dict_BBMODs_detail_info['${bbmod_index}']}
