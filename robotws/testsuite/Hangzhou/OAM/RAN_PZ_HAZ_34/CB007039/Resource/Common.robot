*** Settings ***
Documentation
...  author: Qu Jing   Li Xiaofei
...  contact: jing.qu@nokia-sbell.com   xiaofei.li@nokia-sbell.com


Library   String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Library    taf.sbts.oam.coam.admin    WITH NAME    sbts_coam
#Resource    ../../common/taf_coam.robot
Resource   ../../common/L3_Call.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Variables   ../../libraries/global_vars.py
Variables  ../libraries/dcap_server_1.py
#Library     Emil_processing_keywords.py
Library   taf.selenium.sbts    WITH NAME    selenium_coam
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Library     taf.sw.dcap.rd   WITH NAME   rd
Library    taf.analyzer.pcap   WITH NAME   wireshark


*** Variables ***
${BTSID}   ${tl.gnbs[0].instance_id}
${test_vm_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
${test_vm_user}   ${tl.test_pc.default_ssh_connection_details.username}
${test_vm_password}   ${tl.test_pc.default_ssh_connection_details.password}
${LOG_PATH}             ${OUTPUT DIR}/Logs
${DCAP_HOST}   ${tl.test_pcs[-1].default_ssh_connection_details.addr}
${DCAP_port}    ${EMPTY}
${dcapuser}    ${tl.test_pcs[-1].default_ssh_connection_details.username}
${dcappwd}   ${tl.test_pcs[-1].default_ssh_connection_details.password}
${DCAP_host_bak}   ${tl.test_pcs[-2].default_ssh_connection_details.addr}
${sourceProfile}                                        ${CURDIR}/SourceProfile.ini
${uplane_destination }   10.57.195.82:55900
@{gnb_custom_type}    cp_5g   L2HiRlc_Component    L2HiPdcp_Component   L1stream
@{enb_custom_type}    condor4gTti   cp_4g
${command_cpue}   LD_LIBRARY_PATH=./opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 0 --port 30671
${command_cpif}   LD_LIBRARY_PATH=./opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 0 --port 30667
${cancel_cpue}  LD_LIBRARY_PATH=./opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 95 --port 30671
${cancel_cpif}  LD_LIBRARY_PATH=./opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 95 --port 30667
&{bts_classical}      alias=gnb_dcap    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    username=Nemuadmin    password=nemuuser
    ...     port=443   bts_id=${tl.gnbs[0].global_bts_id}
${capture_tcpdump}   tcpdump -i any port 15300 -w /tmp/asix.pcap -v
${vendor_command}   s|<p name="ovlOccurencesOvlEarly">.*</p>|<p name="ovlOccurencesOvlEarly">
@{l1_trace}    ID 40: EM trace: L1-L2 interface    ID 10: Syscom: management and control plane
${loki}   ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].addr}
${cpue}   ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${ue_index}   0
${hostname}   ${tl.ues[0].ssh_connection_details.addr}

${DCAP_host_UTE}   ${tl.host[-1].default_ssh_connection_details.addr}
${dcapuser_UTE}    ${tl.host[-1].default_ssh_connection_details.username}
${dcappwd_UTE}   ${tl.host[-1].default_ssh_connection_details.password}
${DCAP_host_UTE_bak}   ${tl.host[-2].default_ssh_connection_details.addr}


*** Keyword ***
7039 Case Setup
    robot_common_operations.Common Case Setup
    COAM Login
#    COAM Backup SCF   file_name=TL${BTSID}.xml
#    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
#    ...   display=${false}   version=None
#    COAM WEBUI Whether Close Start Up View Window
    COAM Check All Cells Onair
    Run Keyword And Ignore Error   COAM Logout

Activate OVLP through WebEM
    [Arguments]  ${BTS_type}=gnb
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

Modify Swconfig File
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.Download File   remote_path=/ffs/run/swconfig.txt   local_path=${OUTPUT_DIR}/swconfig.txt   connection=gnb
    csn.execute    command=echo -e "\n0x1A0020=1 #Enabled SSH even with TRS" >> /rom/swconfig.txt   connection=gnb
    csn.execute    command=echo -e "\n0x10041=5 #ERadCcs_AaSysLogOutputModS" >> /rom/swconfig.txt   connection=gnb
    csn.execute    command=echo -e "\n0x10040=1 #ERadCcs_AaSysLogOutputLevelS" >> /rom/swconfig.txt   connection=gnb
    csn.execute    command=echo -e "\n0x1003F=1 #AaSysLogInputLevel" >> /rom/swconfig.txt   connection=gnb
    csn.execute    command=echo -e "\n0x5A00A1=0 #rdAvgL2HICPULoadThreshStream" >> /rom/swconfig.txt   connection=gnb
    csn.execute    command=echo -e "\n0x89008e=0 #rdPreventOverloadActivationBeforeUeTresholdIsReached" >> /rom/swconfig.txt   connection=gnb
    csn.execute    command=crasign /rom/swconfig.txt   connection=gnb
    csn.execute    command=craverify /rom/swconfig.txt   connection=gnb
    csn.execute    command=cat /rom/swconfig.txt   connection=gnb
    Site Reset From WebEM
    Wait Until Keyword Succeeds   15m   1min   COAM Login
    Wait Until Keyword Succeeds   15m   1min   COAM Check All Cells Onair
    [Teardown]   Run Keyword And Ignore Error   Run Keywords   csn.Disconnect     connection=gnb
    ...   AND   COAM Logout

Modify Swconfig File Parameters
    [Arguments]    ${path}    ${rd_parametrs}
    [Documentation]    This keyword is to append new RD parametes to the end of swconfig.txt or modify if RD already exists.
    ...    This keyword is excuted locally, not on gnb or airphone
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${path} | Yes | str, like: /home/ute/results/swconfig.txt |
    ...    | ${rd_parametrs} | Yes | str, like: 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ...    Examples:
    ...    | Modify Swconfig File Parameters | /home/ute/results/swconfig.txt | 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ${content}    OperatingSystem.Get File    ${path}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
         Continue For Loop If    '${item}'=='${EMPTY}'
         ${key}    ${val}    String.Split String    ${item}    =    1
         ${matches}    String.Get Regexp Matches    ${content}    (?m)^${key} ?= ?\\w+
         ${content}    Run Keyword If    len(${matches})>0    String.Replace String Using Regexp
    ...    ${content}    ${matches}[0]    ${key}=${val}    ELSE    Set Variable    ${content}\n${item}
    END
    OperatingSystem.Create File    ${path}    ${content}

#COAM Login
#    [Arguments]   ${bts_host}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
#    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${alias}=COAM
#    coam.connect_to
#    ...   bts_host=${bts_host}
#    ...   bts_port=${bts_port}
#    ...   username=${username}
#    ...   password=${password}
#    ...   use_ssl=${True}
#    ...   update_interval=${5000}
#    ...   admin_api_log_dir=${log_dir}
#    ...   name=${alias}
#    Run Keyword Unless   '${tl.gnbs[0].global_bts_id}'=='None'   coam.register_autoconnection
#    ...    site_id=${tl.gnbs[0].global_bts_id}   connection=${alias}   timeout=${30}
#    [Return]   ${alias}

#COAM Logout
#    [Arguments]   ${connection}=COAM
#    coam.teardown      connection=${connection}

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

Start Stream Trace Action
    [Arguments]   ${stream}=sherpa   ${level}=l2_hi   ${exec_type}=${EMPTY}   ${ip_mode}=ipv4   ${host}=${asik_addr}    ${trace_flag}=single
    ${cells_list}=${EMPTY}   stream=${stream}   level=${level}   exec_type=${exec_type}
    Run Keyword If   '${ip_mode}'=='ipv4'    Configure Logging Agent   uplane_destination=${uplane_destination}
    ...   ELSE IF   '${ip_mode}'=='ipv6'    Configure Logging Agent   uplane_destination=${uplane_ipv6}
    ...   source_ip=${host}
    run keyword if  '${trace_flag.lower()}'=='single'
    ...    Start Streaming WebEM  level=${level}  exec_type=${exec_type}  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   ELSE IF    '${trace_flag.lower()}'=='all'    run keywords
    ...    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_hi  exec_type=pdcp  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_hi  exec_type=rlc  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_lo  exec_type=${EMPTY}  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND    run keyword and continue on failure
    ...   Start Streaming WebEM  level=l2_ps  exec_type=${EMPTY}  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   ELSE IF    '${trace_flag.lower()}'=='l2_hi'    run keywords
    ...   Start Streaming WebEM  level=l2_hi  exec_type=pdcp  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}
    ...   AND
    ...   Start Streaming WebEM  level=l2_hi  exec_type=rlc  stream=${stream}  cells_list=${cells_list}
    ...   ip_mode=${ip_mode}   host=${host}

Stop Stream Trace Action
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${trace_flag}=single
    run keyword if  '${trace_flag.lower()}'=='single'
    ...    Wait Until Keyword Succeeds   1min    5s   Run Keyword   selenium_coam.stop_${stream}_trace
    ...   uplane_${stream}_name=${level.replace('_', '-').upper()}   source=${exec_type.upper()}
    ...   ELSE IF    '${trace_flag.lower()}'=='all'    run keywords
    ...    run keyword and continue on failure  selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=PDCP
    ...   AND    run keyword and continue on failure    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=RLC
     ...   AND    run keyword and continue on failure   selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-PS   source=${EMPTY}
     ...   AND    run keyword and continue on failure    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-LO   source=${EMPTY}
    ...   ELSE IF    '${trace_flag.lower()}'=='l2_hi'    run keywords
    ...    Wait Until Keyword Succeeds   1min    5s    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=PDCP
    ...   AND    Wait Until Keyword Succeeds   1min    5s    selenium_coam.stop_sherpa_trace
    ...   uplane_sherpa_name=L2-HI   source=RLC

_Get Request Cell List
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${alias}=${None}
    log to console  stream='${stream}'
#    Return From Keyword If   '${stream.lower()}'=='sherpa'   ${EMPTY}
    Return From Keyword If   '${level.lower()}'=='l2_hi' and '${exec_type.lower()}'=='pdcp'   ${EMPTY}
    ${cells_list}   Get Cells Runtime List   alias=${alias}
    [Return]   ${cells_list}

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
    Run   if [ ! -d ${LOG_PATH}/${TESTNAME} ]; then mkdir ${LOG_PATH}/${TESTNAME}; else rm ${LOG_PATH}/${TESTNAME}/*; fi
#    Run   cat ${bts_logs_dir}/*.LOG > ${bts_logs_dir}/SYSLOG.LOG
    Run   cp ${bts_logs_dir}/SYSLOG*.LOG ${LOG_PATH}/${TESTNAME}/
    Run   rm -rf ${OUTPUTDIR}/5GC*

Validate msg in syslog
    [Arguments]    ${message_name}=SuspendStreamingReq
    ${Reqmsg}   run    command=cd ${LOG_PATH}/${TESTNAME};cat SYSLOG*.LOG | grep -E "${message_name}" -m 1
    Builtin.Log   ${Reqmsg}
    Should Not Be Empty    ${Reqmsg}
#    ${Respomsg}   Run Keyword if    ${Req}==${TRUE}   run
#    ...    command=sudo cat ${LOG_PATH}/${TESTNAME}/SYSLOG*.LOG| grep -E "${message_name}" -m 1
#    Should Not Be Empty    ${Respomsg}

Print BTSlog
    [Arguments]    ${message_name}=BbPoolingRacAlgorithmCommon.cpp    ${bts_logs_dir}=/tmp/btslog2
    log to console    check btslog
    ${message} =    OperatingSystem.Grep File    ${bts_logs_dir}/SYSLOG.LOG    ${message_name}
    log to console   ${message}
    [Return]      ${message}

Check L2Hi streaming suspend in syslog
    ${Reqmsg}   run    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamActivationReq" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Not Be Empty    ${Reqmsg}
    ${Respomsg}   Run Keyword if    ${Req}==${TRUE}   run
    ...    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamActivationResp" -m 1
    Should Not Be Empty    ${Respomsg}


Install Swconfig File
    [Arguments]    ${swconfig_path}=${OUTPUT_DIR}/swconfig.txt
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.Upload File    local_path=${swconfig_path}    remote_path=/rom/swconfig.txt    connection=gnb
    csn.execute    crasign /rom/swconfig.txt    connection=gnb
    log to console    Install Swconfig File finished!
#    csn.execute    command=reboot   connection=gnb
    Site Reset From WebEM
    Wait Until Keyword Succeeds   15m   1min   COAM Login
    Wait Until Keyword Succeeds   15m   1min   COAM Check All Cells Onair
    [Teardown]   Run Keyword And Ignore Error   Run Keywords   csn.Disconnect     connection=gnb
    ...   AND   COAM Logout

Install Swconfig File for 7039
    [Arguments]    ${swconfig_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/swconfig.txt
    Wait Until Keyword Succeeds   15m   1m
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=gnb
    csn.Upload File   local_path=${swconfig_path}   remote_path=/rom/swconfig.txt    connection=gnb
    csn.execute    crasign /rom/swconfig.txt    connection=gnb
    log to console   Install Swconfig File for 7039 finished!
    Site Reset From WebEM
    Wait Until Keyword Succeeds   5m   30s   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    [Teardown]   Run Keyword And Ignore Error   Run Keywords   csn.Disconnect    connection=gnb
    ...   AND   COAM Logout

Start Dcap Basic trace
    [Arguments]    ${BTS_custom_profile}=${gnb_custom_type}   ${BTS_type}=gnb   ${bts_classical}=${bts_classical}
    ...   ${bts_mr_id}=${tl.gnbs[0].instance_id}   ${username}=${dcapuser}    ${password}=${dcappwd}
    log  username='${username}' password='${password}'
    Create Bts On DCAP    DCAP_host=${DCAP_host}   DCAP_host_bak=${DCAP_host_bak}
    ...   DCAP_port=${DCAP_port}   bts_mr_id=${bts_mr_id}    bts=${bts_classical}
    ...   username=${dcapuser}    password=${dcappwd}
    Start DCAP Log for BTS    bts=${bts_classical}    BTS_custom_profile=${BTS_custom_profile}   BTS_type=${BTS_type}

Start Dcap Basic trace for UTE
    [Arguments]    ${BTS_custom_profile}=${gnb_custom_type}   ${BTS_type}=gnb   ${bts_classical}=${bts_classical}
    ...   ${bts_mr_id}=${tl.gnbs[0].instance_id}   ${username}=${dcapuser_UTE}    ${password}=${dcappwd_UTE}
    log  username='${username}' password='${password}'
    Create Bts On DCAP    DCAP_host=${DCAP_host_UTE}   DCAP_host_bak=${DCAP_host_UTE_bak}
    ...   DCAP_port=${DCAP_port}   bts_mr_id=${bts_mr_id}    bts=${bts_classical}
    ...   username=${dcapuser_UTE}    password=${dcappwd_UTE}
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


Delete Emil script and logs on sherpa
    log to console    \n  Delete Emil script and logs
    wait until keyword succeeds  10min   30s    Csn.Connect to   hostname=${sherpa_server_ip}
    ...   username=${sherpa_server_username}    password=${sherpa_server_password}    alias=sherpa_vm
    csn.Execute    command=rm -rf /cygdrive/c/temp/emil_logs     connection=sherpa_vm
    [Teardown]    csn.Disconnect    connection=sherpa_vm


Gnb Operation During Flowtracer Trace
    [Arguments]    ${operation}=call    ${call_mode}=single
    run keyword if  '${operation}'=='call'    _call_operation    call_mode=${call_mode}
    ...   ELSE IF    '${operation}'=='SCF'    _scf_operation
    ...   ELSE IF    '${operation}'=='onair'    _cell_onair_operation
    ...   ELSE IF    '${operation}'=='resetrat'    _reset_rat_operation
    ...   ELSE   sleep   30s

Trigger Cplane OVL
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${L1_event_query}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query    connection=gnb
    [Teardown]    csn.Disconnect    connection=sherpa_vm

Get Cells Runtime List
    [Arguments]   ${alias}=${coam_alias}  ${tmpdir}=/tmp
    log to console  tmpdir='${tmpdir}'
    ${index_list}   Get Cells Index List   alias=${alias}
    ${runtime_list}   Create List
    ${PCI_list}   Create List
    ${Cell_Name_list}   Create List
    ${MRBTS_ID}   selenium_coam.get_bts_id
#    ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ...   filter_param=Physical cell identifier
    FOR   ${index}   IN   @{index_list}
        ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
        ...   filter_param=Physical cell identifier
        Append To List   ${PCI_list}   ${PCI_ID}
    END
    FOR   ${index}   IN   @{index_list}
        ${Cell_Name}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
       ...   filter_param=Cell name
          Append To List   ${Cell_Name_list}   ${Cell_Name}
    END
    FOR   ${index}   IN   @{index_list}
       Append To List   ${runtime_list}   [PCI: ${PCI_list[${index-1}]}][${Cell_Name_list[${index-1}]}]NRCELL_R-${index}
    END
    [Return]   ${runtime_list}

Cancel Cplane OVL

Start Streaming WebEM
    [Arguments]   ${level}   ${exec_type}   ${stream}=sherpa   ${cells_list}=${EMPTY}   ${ip_mode}=ipv4   ${host}=${asik_addr}
    log to console  ip_mode='${ip_mode}' host='${host}'
    ui_operation.Verify Input Start Trace   level=${level}   exec_type=${exec_type}
#    ${gnb_release}   Get gnb release
#    ${input}   Run Keyword If   '${gnb_release}'=='5G21A' and '${exec_type}' == 'PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21A' and '${exec_type}' == 'pdcp'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'pdcp'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='pdcp'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='RLC'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G21B' and '${exec_type}'=='rlc'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}'=='PDCP'   Create Dictionary
#    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}'=='pdcp'   Create Dictionary
#    ...   ELSE   Create Dictionary   cells_list=${cells_list}
    ${input}   Run Keyword If   '${exec_type}' == 'PDCP'   Create Dictionary
    ...   ELSE IF   '${exec_type}' == 'pdcp'   Create Dictionary
    ...   ELSE   Create Dictionary   cells_list=${cells_list}
    ${status}   Run Keyword and Ignore Error
    ...   selenium_coam.start_${level}_${exec_type}_${stream}_trace_and_return_result
    Should Be Equal   ${status[0]}   PASS
    Should Contain   ${status[1]}   ucce
    [Return]   ${status[1]}

Get Cells with groups info
    [Arguments]   ${alias}=COAM
    ${bts_info}   COAM Get BTS Info   ${alias}
    ${cells_info}   Create List
    FOR   ${group}   IN   @{bts_info['cellsGroup']}
       ${cell_info_one_group}   _Get Cells in Cell Group   group_info=${group}
       Append To List   ${cells_info}   @{cell_info_one_group}
    END
    [Return]   ${cells_info}

_Get Cells in Cell Group
    [Arguments]   ${group_info}
    ${cells_info}   Create List
    FOR   ${cell}   IN   @{group_info['nrCellList']}
       ${cell_info}   Create Dictionary
       Set To Dictionary   ${cell_info}   group=${group_info['name']}   name=${cell}
       Append To List   ${cells_info}   ${cell_info}
    END
    [Return]   ${cells_info}

Get Cells Index List
    [Arguments]   ${alias}=${coam_alias}
    ${cells}   Get Cells with groups info   ${alias}
    ${cells_index}   Create List
    FOR   ${cell}   IN   @{cells}
       Append To List   ${cells_index}   ${${cell['name'].split('-')[1]}}
    END
    Sort List   ${cells_index}
    [Return]   ${cells_index}

Configure Logging Agent
    [Arguments]   ${uplane_destination}   ${source_ip}=${WEBUI_ADDR}
    Run Keyword and Ignore Error   selenium_coam.deactivate_internal_trace
    selenium_coam.configure_logging_agent    source_ip=${source_ip}   vlan=${EMPTY}   dscp=0
    ...   cplane_destination=${EMPTY}   uplane_destination=${uplane_destination}
    Run Keyword and Ignore Error   selenium_coam.activate_internal_trace
    Log To Console   Logging Agent: ${source_ip}, DSCP: ${dscp}, Service: ${uplane_destination}

Trigger NR L3 overload
    [Arguments]  ${cpue_id}=0x1734
#    ${cpue_id}   Set Variable If   '${position}'=='RightSide'   0x2734   0x1734
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${cpue}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${cpue_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${command}\n
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb

Trigger NR L3 overload ASOG
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
    Call Method    ${channel}    send    ${command_cpue}\n
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb

Cancel NR Cplane OVL
    [Arguments]  ${cpue_id}=0x1734
#    ${cpue_id}   Set Variable If   '${position}'=='RightSide'   0x2734   0x1734
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${cpue}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${cpue_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${cancel_cpue}\n
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

Start Dcap L1stream trace
    Start Dcap Basic trace   cp_5g

Trigger NR L1 overload
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${loki}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    csn.Upload File
    ...   local_path=${CURDIR}/system_statistics.conf
    ...    remote_path=/etc/usas/system_statistics.conf    connection=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    systemctl restart system-statistics\n
    Sleep    10 sec
    Call Method    ${channel}    recv    ${65535}
    csn.Execute    command=echo "log -a -z snap-FCT.zip" | nc 0 15007   connection=gnb
    Sleep    7 min
    [Teardown]   csn.disconnect    connection=gnb

Cancel NR L1 overload
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${loki}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    csn.Upload File    local_path=/home/ute/Downloads/system_statistics1.conf
    ...    remote_path=/etc/usas/system_statistics.conf    connection=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    systemctl restart system-statistics\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb


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

Validate msg in journal log
    [Arguments]    ${message_name}=overload status reached, filtering messages is started
    ${Reqmsg}   run    command=sudo cat ${OUTPUT_DIR}/bbmod_journal.log | grep -i "${message_name}" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Not Be Empty    ${Reqmsg}
    ${Respomsg}   Run Keyword if    ${Req}==${TRUE}   run
    ...    command=sudo cat ${OUTPUT_DIR}/bbmod_journal.log | grep -i "${message_name}" -m 1
    Should Not Be Empty    ${Respomsg}

Modify Venfor file
     [Arguments]    ${ovlOccurencesOvlEarly}=1   ${ovlOccurrences}=1   ${ovlThrOvl1}=1   ${ovlThrOvl2}=2
     ...   ${ovlThrOvlEarly}=1   ${ovlTimer}=10   ${file_path}=${OUTPUT_DIR}/TL${BTSID}.xml
     log to console    Modify_Vendor
     ${VEN_PATH}   set variable   ${LOG_PATH}/${TESTNAME}
     ${vendor_0}   set variable
     ...  cd ${VEN_PATH};sudo sed -i '${vendor_command}${ovlOccurencesOvlEarly}</p>|g' vendor_7039.xml
     ${vendor_1}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="ovlOccurrences">.*</p>|<p name="ovlOccurrences">${ovlOccurrences}</p>|g' vendor_7039.xml
     ${vendor_2}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="ovlThrOvl1">.*</p>|<p name="ovlThrOvl1">${ovlThrOvl1}</p>|g' vendor_7039.xml
     ${vendor_3}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="ovlThrOvl2">.*</p>|<p name="ovlThrOvl2">${ovlThrOvl2}</p>|g' vendor_7039.xml
     ${vendor_4}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="ovlThrOvlEarly">.*</p>|<p name="ovlThrOvlEarly">${ovlThrOvlEarly}</p>|g' vendor_7039.xml
     ${vendor_5}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="ovlTimer">.*</p>|<p name="ovlTimer">${ovlTimer}</p>|g' vendor_7039.xml
     coam.connect to    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
     ...   password=${tl.gnbs[0].cu.oam_http_connection_details.password}    name=coam_admin
     coam.download_vendor_file    target_file_name=${LOG_PATH}/${TESTNAME}/vendor_7039.xml    connection=coam_admin
     sleep    3s
     Connect to TestPc   alias=TestPc
     csn.execute    ls ${VEN_PATH}    connection=TestPc
     FOR   ${index}    IN RANGE    6
         csn.execute    command=${vendor_${index}}   connection=TestPc
     END
     COAM WEBUI Login
     ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${LOG_PATH}/${TESTNAME}/vendor_7039.xml
     Run keyword if   '${result}'=='Validation failed!'
     ...   selenium_coam.load_vendor_file_and_validate    file_path=${LOG_PATH}/${TESTNAME}/vendor_7039.xml
     sleep   5s
     COAM WEBUI Whether Close Start Up View Window
#     selenium_coam.load_commissioning_file_and_check_load_status   file_path=${CURDIR}/TL860_${cellnum}CELL.xml   timeout=${120}
     selenium_coam.load_commissioning_file_and_check_load_status
     ...   file_path=${file_path}   timeout=${120}
     selenium_coam.validate_plan
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
     Wait Until Keyword Succeeds   10m   30s   gNB not Connected
     Wait Until Keyword Succeeds   5m   30s   Try Connect gNB
     Wait Until Keyword Succeeds   15m   1min   COAM Login
     Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
     [Teardown]    run keywords   COAM WEBUI Whether Close Start Up View Window
     ...   AND   run keyword and ignore error   COAM WEBUI Logout
     ...   AND   run keyword and ignore error   coam.teardown   connection=coam_admin
     ...   AND   run keyword and ignore error   COAM Logout

Check tcpdump result in sbts
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${connection}    csn.get_connection_by_alias    alias=gnb
    csn.Send Command   command=${capture_tcpdump}   connection=gnb
    sleep   30s
    csn.Send Command   command=ps -ef | grep /tmp/asix.pcap | grep -v grep | awk '{print $2}' | xargs kill -9   connection=gnb
    ${file_info}   csn.Execute   command=ls -la /tmp/asix.pcap   connection=gnb
    [Return]   ${file_info.split()[4]}
    [Teardown]   csn.disconnect    connection=gnb

Should not contain port 15300
    [Arguments]   ${result}=0
    ${file_size}   Check tcpdump result in sbts
    should be equal   ${file_size}   ${result}

Should contain port 15300
    [Arguments]   ${result}=0
    ${file_size}   Check tcpdump result in sbts
    should not be equal   ${file_size}   ${result}

Make massive attachs
    [Arguments]   ${times}=${5}   ${ue_index}=${ue_index}   ${UE_IP_net}=127.0.0
    Log to console   Make massive attachs
    L3CALL Precondition   ue_index=${ue_index}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    Get Commercial UE IP    ue_index=${ue_index}
    log to console    \n before attach ip of ue_${ue_index}:${UE_IP}
    Should Contain    ${UE_IP}    ${UE_IP_net}
#    FOR   ${index}    IN RANGE    ${retry}
        Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
#        Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
#        ...    close_task=${close_task}
#        Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.
#        Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
#        Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
#        ...   close_task=${close_task}
#        Log to console    INFO:click AIRPLANE once for ${UE_type} UE detach.
        Commercial UE click AIRPLANE Massive Times   Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}   times=${times}
#    END
    [Teardown]    csn.disconnect      connection=cygwin

L3CALL Precondition
    [Arguments]   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Commercial UE click AIRPLANE Massive Times
    [Documentation]    click AIRPLANE switch twice
    ...    :param  swipe: Swipe the phone screen up
    ...    :param  Home_button: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${times}=${1}
    sleep   4s
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
    sleep   2s
    ${output}   csn.read_output    connection=cygwin
    FOR   ${index}    IN RANGE    ${times}
         Click Airplane to Switch to Mode   serial_number=${serial_number}   airplane=${airplane}   brand=${brand}   FocusedWindow=${output}
    END
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
#    [Teardown]    csn.disconnect      connection=cygwin

Click Airplane to Switch to Mode
    [Arguments]  ${serial_number}   ${airplane}   ${brand}   ${FocusedWindow}
    #####Tap the airplane mode switch to disable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    sleep   1s
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${FocusedWindow}    connection=cygwin
    sleep   1s
    #####Tap the airplane mode switch to enable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    sleep   1s
    run keyword if    '${brand}'=='Xiaomi'   Run Keyword and Ignore Error
    ...   csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   1s
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${FocusedWindow}    connection=cygwin

Check and Add Flag in Swconfig File
    [Arguments]  ${flag1}=0x1A0020=1  ${flag2}=0x10040=1  ${flag3}=0x5A00A1=0  ${flag4}=0x89008e=0
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#    ${check_command}   Set Variable   cat /rom/swconfig.txt | grep ${flag}
    ${orig_gnb_swconfig}   Set Variable   ${OUTPUT_DIR}/swconfig_origin.txt
    csn.Download File   remote_path=/rom/swconfig.txt   local_path=${orig_gnb_swconfig}   connection=gnb
    ${target_flags}  Create List   ${flag1}   ${flag2}   ${flag3}   ${flag4}
    ${status_list} =  Create List
    FOR   ${index}   IN RANGE   len(${target_flags})
        ${cur_flag}   csn.execute    command=cat /rom/swconfig.txt | grep ${target_flags[${index}]}   connection=gnb
        ${status_check}   Run Keyword And Return Status   Should Contain   ${cur_flag}   ${target_flags[${index}]}
        Append To List   ${status_list}   ${status_check}
        Run Keyword If   '${status_check}'=='False'   csn.execute
        ...   command=echo -e "\n${target_flags[${index}]}" >> /rom/swconfig.txt   connection=gnb
    END
    ${current_status}   Run Keyword And Return Status   Should Not Contain   ${status_list}  'False'
    Run Keyword If   '${current_status}'=='False'   Run Keywords    Log To Console   "Effect 7039 flags with Site Reset From WebEM"
    ...   AND   Site Reset From WebEM
    Set Suite Variable   ${FLAG_STATUS}   ${current_status}
#    csn.Download File   remote_path=/ffs/run/swconfig.txt   local_path=${OUTPUT_DIR}/swconfig.txt   connection=gnb
#    csn.execute    command=echo -e "${flag}" >> /rom/swconfig.txt   connection=gnb
#    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
#    ...   display=${false}
#    selenium_coam.reset_site
#    sleep   5s
#    COAM WEBUI Logout
    Wait Until Keyword Succeeds   15m   1min   COAM Login
    Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
    [Return]  ${current_status}   ${orig_gnb_swconfig}
    [Teardown]   Run Keyword And Ignore Error   Run Keywords   csn.Disconnect     connection=gnb
    ...   AND   COAM Logout

Upload Swconfig File to gNB
    [Arguments]  ${swconfig_path}
    Wait Until Keyword Succeeds    15m   1min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.Upload File    local_path=${swconfig_path}    remote_path=/rom/swconfig.txt    connection=gnb
    csn.execute    crasign /rom/swconfig.txt    connection=gnb
    log to console    Install Swconfig File finished!
#    csn.execute    command=reboot   connection=gnb
    Site Reset From WebEM
    Wait Until Keyword Succeeds   15m   1min   COAM Login
    Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
    [Teardown]   Run Keyword And Ignore Error   Run Keywords   csn.Disconnect     connection=gnb
    ...   AND   COAM Logout

Site Reset From WebEM
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ...   display=${false}
    Wait Until Keyword Succeeds   3x  10s   selenium_coam.reset_site
    sleep  5m
    [Teardown]   Run Keyword And Ignore Error   COAM WEBUI Logout

Trigger NR L3 overload via bsh
    [Arguments]  ${cpue_id}=0x1734  ${bsh_id}=bsh 1:0
    log   cpue_id='${cpue_id}' bsh_id='${bsh_id}'
#    ${cpue_id}   Set Variable If   '${position}'=='RightSide'   0x2734   0x1734
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${cpue}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${cpue_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${command}\n
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb

Cancel NR Cplane OVL via bsh
    [Arguments]  ${cpue_id}=0x1734
#    ${cpue_id}   Set Variable If   '${position}'=='RightSide'   0x2734   0x1734
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${cpue}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${cpue_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${cancel_command}\n
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb


Trigger NR L1 overload via bsh
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${loki}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    csn.Upload File
    ...   local_path=${CURDIR}/system_statistics.conf
    ...    remote_path=/etc/usas/system_statistics.conf    connection=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    systemctl restart system-statistics\n
    Sleep    10 sec
    Call Method    ${channel}    recv    ${65535}
    csn.Execute    command=echo "log -a -z snap-FCT.zip" | nc 0 15007   connection=gnb
    Sleep    7 min
    [Teardown]   csn.disconnect    connection=gnb

Cancel NR L1 overload via bsh
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.connect to    hostname=${loki}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=abio
    ...               proxy=gnb
    ${connection}    csn.get_connection_by_alias    alias=abio
    csn.Upload File    local_path=/home/ute/Downloads/system_statistics1.conf
    ...    remote_path=/etc/usas/system_statistics.conf    connection=abio
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    systemctl restart system-statistics\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    [Teardown]   csn.disconnect    connection=gnb

Collect journal log via bsh
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
