*** Settings ***
Documentation  Test Suite for TL10836
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.fdsw.rc    WITH NAME    fdsw
Library    Collections
Library   taf.selenium.sbts    WITH NAME    selenium_coam
Library     taf.sw.dcap.rd   WITH NAME   rd
Library     taf.transport.ssh    WITH NAME    csn

Resource    ../resources/ssh_utils.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/taf_coam.robot
Resource    ../resources/dcap.robot
Resource    ../resources/BTS_log_level.robot
Resource    ../test_line_specific/SBTS_10836_Honda/common/DCAP_HZ.robot
#Resource    /home/ute/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core

*** Variables ***
${STARTUP_TIMEOUT}  20
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${alias}     default
${LOG_PATH}             ${OUTPUT DIR}/Logs

${flag1}                     0x1A0020
${flag_with_desired_value1}  0x1A0020 = 1
${flag2}                     0x10040
${flag_with_desired_value2}  0x10040 = 1
${flag3}                     0x5A00A1
${flag_with_desired_value3}  0x5A00A1 = 0
${flag4}                     0x89008e
${flag_with_desired_value4}  0x89008e = 0

@{gnb_custom_type}    cp_5g   L2HiRlc_Component    L2HiPdcp_Component   L1stream
&{bts_classical}      alias=gnb_dcap    host=10.15.232.236    username=Nemuadmin    password=nemuuser
    ...     port=443   bts_id=1836
#${DCAP_HOST}   10.5.26.85
#${DCAP_host_bak}   10.5.26.85
${DCAP_HOST}   192.168.255.126
${DCAP_host_bak}   192.168.255.126
#${DCAP_port}    ${EMPTY}
${DCAP_port}    9443
#${dcapuser}  utfuser
#${dcappwd}    utfadmin!
${dcapuser}  ${EMPTY}
${dcappwd}    ${EMPTY}
@{l1_trace}    ID 40: EM trace: L1-L2 interface    ID 10: Syscom: management and control plane
${WEBUI_ADDR}       192.168.255.129
${WEBUI_USER}   Nemuadmin
${WEBUI_PASSWORD}   nemuuser
${oam_addr}     192.168.255.129
${ssh_username}     toor4nsn
${ssh_password}     oZPS0POrRieRtu
${oam_username}   toor4nsn
${oam_password}    oZPS0POrRieRtu
${asik_addr}    192.168.255.129
${asik_username}    toor4nsn
${asik_password}    oZPS0POrRieRtu
${command_cpue}   LD_LIBRARY_PATH=./opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 0 --port 30671
${cancel_cpue}  LD_LIBRARY_PATH=./opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 95 --port 30671
${loki}     192.168.253.17

*** Keywords ***
TC__LOGS_CB010969-CB007039_CRT_adapted
    [Documentation]
    ...  [CASE LINK]:
    ...  ******************
    ...  Author: Radu Turcu
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-10-27 - TC adapted. version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check:
    ...    CB010969-CB007039-A-L2hi-streaming-suspend-with-multiple-nodes
    ...    CB010969-CB007039-B-Cplane-trace-resume-with-OVL-reduced
    ...    CB010969-CB007039-C-NR-L1-streaming-trace-resume-with-NRT-core-OVL-reduced
    ...  *******************

    Preconditions
    CB010969-CB007039-A-L2hi-streaming-suspend-with-multiple-nodes
    CB010969-CB007039-B-Cplane-trace-resume-with-OVL-reduced
    CB010969-CB007039-C-NR-L1-streaming-trace-resume-with-NRT-core-OVL-reduced

Preconditions
    [Documentation]
    ...   in this step we are verifying if BTS is up and running
    Log    \nStep 0: Preconditions      console=${True}
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${btsid}
    Install Swconfig File for 7039
    Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
    sleep   1min

CB010969-CB007039-A-L2hi-streaming-suspend-with-multiple-nodes
    Syslog Capture Start
    Start Dcap Basic trace    BTS_custom_profile=${gnb_custom_type}   BTS_type=gnb   bts_classical=${bts_classical}
    ...    bts_mr_id=1836   username=${dcapuser}    password=${dcappwd}
    Activate OVLP through WebEM
    sleep   1min
    Deactivate OVLP through WebEM
    sleep   30s
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect
    Run Keyword And Continue On Failure    Validate msg in syslog    SuspendStreamingResp
    Run Keyword And Continue On Failure    Validate msg in syslog    handleTraceResumeResp
    [Teardown]    run keywords   Run Keyword And Ignore Error   WEBUI LOGOUT
    ...   AND    Run Keyword And Ignore Error    COAM Logout
    ...   AND    Delete BTS

CB010969-CB007039-B-Cplane-trace-resume-with-OVL-reduced
    Log    \nCB010969-CB007039-B-Cplane-trace-resume-with-OVL-reduced
    Activate OVLP through WebEM
    Syslog Capture Start
    Start Dcap Basic trace  BTS_custom_profile=${gnb_custom_type}   BTS_type=gnb   bts_classical=${bts_classical}
    ...    bts_mr_id=1836   username=${dcapuser}    password=${dcappwd}
    Trigger NR L3 overload ASOG    cpue_id=0x151b
    Trigger NR L3 overload ASOG    cpue_id=0x151a
    sleep   20s
    Cancel NR Cplane OVL ASOG    cpue_id=0x151b
    Cancel NR Cplane OVL ASOG    cpue_id=0x151a
    sleep   6min
    Stop Dcap Basic trace
    sleep   20s
    Syslog Capture Stop and Collect
    Run Keyword And Continue On Failure    Validate msg in syslog    Message trace suspend
    Run Keyword And Continue On Failure    Validate msg in syslog    Message trace resumed
    Deactivate OVLP through WebEM
    [Teardown]   Delete BTS

CB010969-CB007039-C-NR-L1-streaming-trace-resume-with-NRT-core-OVL-reduced
    [Timeout]    60min
#    7039 Case Setup
#    sleep    5min
    Syslog Capture Start
    Activate OVLP through WebEM
    Start Dcap Basic trace     BTS_custom_profile=${gnb_custom_type}   BTS_type=gnb   bts_classical=${bts_classical}
    ...    bts_mr_id=1836   username=${dcapuser}    password=${dcappwd}
    Trigger NR L1 overload
#    sleep   1min
#    Cancel NR L1 overload
    sleep  6min
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect
    Collect journal log
    Run Keyword And Continue On Failure    Validate msg in syslog   Handle Suspend Streaming Request for L1 Node:
    Run Keyword And Continue On Failure    Validate msg in syslog   Handle resume streaming request for L1 instance:
#    Collect journal log
    Validate msg in journal log   filtering messages is started
    Validate msg in journal log   filtering messages is stopped
#    Log To Console     log to pass
     Deactivate OVLP through WebEM
     [Teardown]   Delete BTS

Delete BTS
    ${dcapbtsid}    Dcap get bts by id
    Dcap delete bts    bts_id=${dcapbtsid}

Validate msg in journal log
    [Arguments]    ${message_name}=overload status reached, filtering messages is started
    ${Reqmsg}   run    command=sudo cat ${OUTPUT_DIR}/bbmod_journal.log | grep -i "${message_name}" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Not Be Empty    ${Reqmsg}
    ${Respomsg}   Run Keyword if    ${Req}==${TRUE}   run
    ...    command=sudo cat ${OUTPUT_DIR}/bbmod_journal.log | grep -i "${message_name}" -m 1
    Should Not Be Empty    ${Respomsg}

Collect journal log
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${loki}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    journalctl -b > /ffs/run/logs/bbmod_journal.log\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    csn.Download File   remote_path=/ffs/run/logs/bbmod_journal.log
    ...   local_path=${OUTPUT_DIR}/bbmod_journal.log   connection=gnb
    Sleep    1 sec
    csn.execute    command=rm /ffs/run/logs/bbmod_journal.log   connection=gnb
    [Teardown]   csn.disconnect    connection=gnb

Trigger NR L1 overload
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${loki}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    csn.Upload File
    ...   local_path=${TC_HZ_Resource_PATH}
    ...    remote_path=/etc/usas/system_statistics.conf    connection=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    systemctl restart system-statistics\n
    Sleep    10 sec
    Call Method    ${channel}    recv    ${65535}
    csn.Execute    command=echo "log -a -z snap-FCT.zip" | nc 0 15007   connection=gnb
    Sleep    7 min
    [Teardown]   csn.disconnect    connection=gnb

Trigger NR L3 overload ASOG
    [Arguments]  ${cpue_id}=0x1512
# to know cpue_id
#ps -eaf | grep 5G*
#    ${cpue_id}   Set Variable If   '${position}'=='RightSide'   0x2734   0x1734
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    #csn.connect to    hostname=${cpue}
    #...               username=${asik_username}
    #...               password=${asik_password}
    #...               alias=abio
    #...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=gnb
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${cpue_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${command_cpue}\n
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb

Cancel NR Cplane OVL ASOG
    [Arguments]  ${cpue_id}=0x1512
#    ${cpue_id}   Set Variable If   '${position}'=='RightSide'   0x2734   0x1734
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    #csn.connect to    hostname=${cpue}
    #...               username=${asik_username}
    #...               password=${asik_password}
    #...               alias=abio
    #...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=gnb
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${cpue_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${cancel_cpue}\n
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb

Activate OVLP through WebEM
    [Arguments]  ${BTS_type}=gnb
#    WebEM Login
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ...   display=${false}
    Log To Console     Activate OVL through WebEM
    Run Keyword If   '${BTS_type}'=='gnb'
    ...  Wait Until Keyword Succeeds   3x   10s   selenium_coam.set_parameter_value    dist_name=MRBTS-${BTSID}/NRBTS-${BTSID}
	...  filter_param=Activate trace overload protection   new_value=true
#    ...   AND   Run Keyword And Ignore Error   selenium_coam.set_parameter_value    dist_name=MRBTS-${BTSID}/NRBTS-${BTSID}
#	...  filter_param=Activate C-plane overload protection   new_value=true
	...   ELSE   Run Keywords
    ...   Wait Until Keyword Succeeds   3x   10s   selenium_coam.set_parameter_value    dist_name=MRBTS-${BTSID}/LNBTS-${BTSID}
	...  filter_param=Activate trace overload protection   new_value=true
    ...   AND    Wait Until Keyword Succeeds   3x   10s   selenium_coam.set_parameter_value    dist_name=MRBTS-${BTSID}/LNBTS-${BTSID}
	...  filter_param=Activation of C-plane overload handling   new_value=true
    Run Keyword And Ignore Error   selenium_coam.set_parameter_value    dist_name=MRBTS-${BTSID}/MNL-1/MNLENT-1/TRBLCADM-1
	...  filter_param=Activate internal trace   new_value=true
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    [Teardown]  Run Keyword And Ignore Error   COAM WEBUI Logout

Deactivate OVLP through WebEM
    [Arguments]  ${BTS_type}=gnb
    Log To Console     Deactivate OVLP through WebEM
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ...   display=${false}
    Run Keyword If   '${BTS_type}'=='gnb'
    ...   Wait Until Keyword Succeeds   3x   10s   selenium_coam.set_parameter_value    dist_name=MRBTS-${BTSID}/NRBTS-${BTSID}
	...  filter_param=Activate trace overload protection   new_value=false
    ...   ELSE   Wait Until Keyword Succeeds   3x   10s    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTSID}/LNBTS-${BTSID}
	...  filter_param=Activate trace overload protection   new_value=false
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    [Teardown]  Run Keyword And Ignore Error   COAM WEBUI Logout

Validate msg in syslog
    [Arguments]    ${message_name}=SuspendStreamingReq
    ${Reqmsg}   run    command=cd ${LOG_PATH}/${TESTNAME};cat SYSLOG*.LOG | grep -E "${message_name}" -m 1
    Builtin.Log   ${Reqmsg}
    Should Not Be Empty    ${Reqmsg}
#    ${Respomsg}   Run Keyword if    ${Req}==${TRUE}   run
#    ...    command=sudo cat ${LOG_PATH}/${TESTNAME}/SYSLOG*.LOG| grep -E "${message_name}" -m 1
#    Should Not Be Empty    ${Respomsg}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Syslog Capture Start
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_start
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Syslog Capture Stop and Collect
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_stop
    run keyword and ignore error    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}

__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
    Run  rm -rf ${OUTPUTDIR}/5GC*

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run   mkdir ${LOG_PATH}
    Run   if [ ! -d ${LOG_PATH}/${TESTNAME} ]; then mkdir ${LOG_PATH}/${TESTNAME}; else rm ${LOG_PATH}/${TESTNAME}/*; fi
#    Run   cat ${bts_logs_dir}/*.LOG > ${bts_logs_dir}/SYSLOG.LOG
    Run   cp ${bts_logs_dir}/SYSLOG*.LOG ${LOG_PATH}/${TESTNAME}/
    Run   rm -rf ${OUTPUTDIR}/5GC*

Start Dcap Basic trace
    [Arguments]    ${BTS_custom_profile}=${gnb_custom_type}   ${BTS_type}=gnb   ${bts_classical}=${bts_classical}
    ...   ${bts_mr_id}=${tl.gnbs[0].instance_id}   ${username}=${dcapuser}    ${password}=${dcappwd}
    log  username='${username}' password='${password}'
    Create Bts On DCAP    DCAP_host=${DCAP_host}   DCAP_host_bak=${DCAP_host_bak}
    ...   DCAP_port=${DCAP_port}   bts_mr_id=${bts_mr_id}    bts=${bts_classical}
    ...   username=${dcapuser}    password=${dcappwd}
    Start DCAP Log for BTS    bts=${bts_classical}    BTS_custom_profile=${BTS_custom_profile}   BTS_type=${BTS_type}
Start DCAP Log for BTS
    [Arguments]    ${bts}    ${BTS_custom_profile}   ${BTS_type}=gnb
#	${gnb_custom_profile}=    Create List    cp_5g
	${output}    Run Keyword If   '${BTS_type}'=='gnb'   rd.start_trace     bts=${bts}    gnb_custom_profile=${BTS_custom_profile}
	...      l1_trace=${l1_trace}    wait_for_activation=${True}
	...   ELSE   rd.start_trace     bts=${bts}    enb_custom_profile=${BTS_custom_profile}
	...    wait_for_activation=${True}   control_plane_interface=${True}
	Log    ${output}[tracer_id]
    ${result_id}      Convert To Integer      ${output}[tracer_id]
    set suite variable    ${result_id}
    set suite variable    ${result_id}

Stop Dcap Basic trace
	Stop DCAP log

Prepare SWconfig
    [Arguments]  ${flag}    ${flag_with_desired_value}
    [Documentation]
    ...  This KW is checking if ${flag} exist in SWconfig on  MSM . If yes, it is changed to ${flag_with_desired_value} value.
    ...  If ${flag} doesn't exist in SWconfig, it is being added.

    SSH Connection
    ###Prepare SWconfig file for MSM
    ${swconfig_MSM}=  ssh.Execute  grep ${flag} /ffs/run/swconfig.txt  connection=${alias}
    ${swconfig_MSM}=  Strip String  ${swconfig_MSM}
    ${flag_exist}=  Evaluate  "${flag}" in """${swconfig_MSM}"""
    Run Keyword If  ${flag_exist}  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}
    ...  AND  Change Flag  ${alias}    ${flag}    ${flag_with_desired_value}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}  ""
    ...  AND  Add Flag  ${alias}    ${flag_with_desired_value}

Install Swconfig File for 7039
    Log   \nInstall Swconfig File for 7039
    Prepare SWconfig    ${flag1}    ${flag_with_desired_value1}
    Prepare SWconfig    ${flag2}    ${flag_with_desired_value2}
    Prepare SWconfig    ${flag3}    ${flag_with_desired_value3}
    Prepare SWconfig    ${flag4}    ${flag_with_desired_value4}
    log  \nReset ongoing in order to apply changes made in SWconfig  console=${True}
    Run Keyword And Ignore Error   coam.Reset Site  720
    Wait Until Keyword Succeeds  15m  1m  Check All Modules And All Cells Working States

Add Flag
    [Documentation]
    ...  This KW is adding ${flag_with_desired_value} to SWconfig file
    [Arguments]  ${SMOD_Connection}    ${flag_with_desired_value}
    ssh.Execute  command=echo ${flag_with_desired_value} >> /ffs/run/swconfig.txt  connection=${SMOD_Connection}

Change Flag
    [Documentation]
    ...  This KW is checking on which line is ${flag} in SWconfig and replaces that line with ${flag_with_desired_value}
    [Arguments]  ${SMOD_Connection}    ${flag}    ${flag_with_desired_value}
    ${flag_line_nr}=  ssh.Execute  grep -n '${flag}' /ffs/run/swconfig.txt | awk -F: '{print $1}'  connection=${SMOD_Connection}
    ${flag_line_nr}=  Strip String  ${flag_line_nr}
    ssh.Execute  command=sed -i '${flag_line_nr}s/.*/${flag_with_desired_value}/' /ffs/run/swconfig.txt  connection=${SMOD_Connection}

TC Setup
    Common Test Setup   syslog_launch=${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
