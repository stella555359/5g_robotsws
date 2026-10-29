*** Settings ***
Documentation    Author: liangliang.heng@nokia-sbell.com
Library     taf.collectors.core         WITH NAME    core
Library    taf.analyzer.pcap   WITH NAME   wireshark
Library     taf.transport.ssh    WITH NAME  ssh
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     OperatingSystem
Library     Collections
Library     DateTime
Library     ../libraries/asik_handler.py   WITH NAME      asik_handler
Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_env.robot
Resource    ../../common/L3_Call.robot
Resource    ../../common/gnb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Variables   ../../libraries/global_vars.py
Resource    tshark.robot
Resource    coam.robot
Resource    coam_admin.robot
Resource    5GC001804B_NetAct_Keywords.robot
Resource    ../../common/collect_log.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${remote_dir_path}           /tmp
${Log_directory}             ${OUTPUT_DIR}
${file_name5}                PCMD_5G.pcap
${ue_index}                  ${0}
${BTSID}                     MRBTS-${tl.gnbs[0].instance_id}
${INSID}                     ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
${ASIK_IP}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_ADDR_Targetgnb}      ${tl.gnbs[1].cu.oam_http_connection_details.addr}       #TL828gnb
${Tafip_Targetgnb}           ${tl.test_pcs[0].default_ssh_connection_details.addr}

*** Keywords ***
Delete BTS log in VM
    [Documentation]  Delete BTSlogs in VM
    run keyword and ignore error   core.stop_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; rm -rf SYSLOG_*


Case Teardown CIT
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation

Setup Count Calculation
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${cond1}=    Set Variable if    '${TEST STATUS}'=='PASS'    ${True}    ${False}
    ${cond2}=    Set Variable    ${commission_status}
    ${cond3}=    Set Variable    ${pcmd_recommision_status}
    ${cond4}=    Set Variable    ${L3CALL_status}
    ${condition}=    Evaluate   ${cond1} and ${cond2} and ${cond3} and ${cond4}
    Set Suite Variable    ${setup_condition}    ${condition}
    ${new_count}=    Run Keyword If    ${setup_condition}    set variable   ${setupfail_count}    ELSE    Evaluate    ${setupfail_count}+1
    Set Suite Variable    ${setupfail_count}    ${new_count}

Case Common Setup
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login
    Close Web Startup View Window
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir   connection=COAM
    log to console    BTS is on air
    run keyword and ignore error   Start Catch Relative Log   log_dir_name=${TEST NAME}
    Set Environment Variable              https_proxy                 ${empty}

Case Common Teardown
#    run keyword and ignore error   Remove PCMD Object
    run keyword and ignore error   asik_handler.close
#    run keyword if test failed  Collect Relative Log
#    Check Extra Reset From Blackbox
    run keyword if test passed   Delete BTS log in VM
    COAM WEBUI Logout
    COAM Logout
    CI_interface.Common Case Teardown

Prepare Power UE
    [Arguments]   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Start Save Tcpdump
    [Arguments]   ${ipadd}    ${tcpdumpfile}
    asik_handler.connect                i_ipAddr=${ipadd}
    log to console    start ${ipadd} tcpdump
    COAM Login   bts_host=${ipadd}   alias=SMOD
    ${SMOD_name}   Get SMOD Product Name   connection=SMOD
    COAM Logout   connection=SMOD
    Run Keyword   asik_handler.general_tcpdump_${SMOD_name}        ${remote_dir_path}      ${tcpdumpfile}

Stop Save Tcpdump
    [Arguments]   ${ipadd}   ${tcpdumpfile}
    asik_handler.connect                i_ipAddr=${ipadd}
    log to console    stop ${ipadd} tcpdump
    asik_handler.kill_tcpdump
    asik_handler.download_file_from_Asik	i_filename=${remote_dir_path}/${tcpdumpfile} 	 i_local_path=${Log_directory}/${tcpdumpfile}
    Run keyword and Ignore error  asik_handler.close

Create Btslog log collection on remote machine for PCMD
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...             ${btslog_launcher_path}=/opt/btslog/btslog_launcher          ${log_dir}=/tmp/
    ...             ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...             ${user}=${tl.test_pc.default_ssh_connection_details.username}
    ...             ${password}=${tl.test_pc.default_ssh_connection_details.password}
    [Documentation]    create btslog log collector on testvm.
    ...                name: name of the collector. Ex: btslog
    ...                btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...                btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...                executable default value:”/opt/btslog/btslog_launcher”
    ...                log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    run keyword and ignore error   Clean BTSlog on Remote Machine   host=${host}   user=${user}   password=${password}
    &{executor}=    create dictionary    host=${host}
    ...                                  user=${user}
    ...                                  password=${password}
    btslog.create_btslog_collector       name=${name}          btslog_path=${btslog_path}
    ...                                  btslog_launcher_path=${btslog_launcher_path}
    ...                                  executor=${executor}    log_dir=${log_dir}
    btslog.Set Suite Alias               alias=${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

Clean BTSlog on Remote Machine
    [Arguments]  ${host}   ${user}   ${password}
    ${cmd_prefix}   Set Variable If   '${user}'=='root'   ${EMPTY}   sudo${SPACE}
    csn.Connect to   hostname=${host}   username=${user}   password=${password}  alias=testpc
    csn.Execute   command=${cmd_prefix}pkill -9 -f -x '/opt/btslog/btslog -NOGUI'   connection=testpc
    csn.Execute   command=${cmd_prefix}rm -rf /tmp/BTSLogCommandsLocalServer    connection=testpc
    [Teardown]   csn.Disconnect   connection=testpc

Stop And Download And Remove BTS LOG Collection
    [Arguments]    ${dir}   ${name}=btslog   ${host}=${tl.test_pc.default_ssh_connection_details.addr}   ${user}=ute   ${password}=ute
    log to console    Stop And Download And Remove BTS LOG Collection On Gnb And Rus
    ${collect_status}   run keyword and return status   Collect_logs    names=${name}
    run keyword if  not ${collect_status}   Log   Collect logs failed on ${host}   WARN
    ${download_status}   run keyword and return status   Download Btslog To Log Path    dir=${dir}    TAF_ADDR=${host}
    ...   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    run keyword if  not ${download_status}   Log   Download logs failed on ${host}   WARN
    ${remove_status}   run keyword and return status   Remove Btslog From Temp Folder    TAF_ADDR=${host}
    ...   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    run keyword if  not ${remove_status}   Log   Remove logs failed on ${host}  WARN

Stop And Remove BTS LOG Collection
    [Arguments]   ${dir}   ${name}=btslog   ${host}=${tl.test_pc.default_ssh_connection_details.addr}   ${user}=ute   ${password}=ute
    LOG    ${dir}
    log to console    Stop And Download And Remove BTS LOG Collection On Gnb And Rus
    log to console   ${dir}
    ${collect_status}   run keyword and return status   Collect_logs    names=${name}
    run keyword if  not ${collect_status}   Log   Collect logs failed on ${host}   WARN
    ${remove_status}   run keyword and return status   Remove Btslog From Temp Folder    TAF_ADDR=${host}
    ...   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    run keyword if  not ${remove_status}   Log   Remove logs failed on ${host}  WARN

Download Btslog To Log Path
    [Arguments]   ${dir}   ${TAF_ADDR}   ${TAF_USERNAME}    ${TAF_PASSWORD}
    ${connection_asik}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    run keyword and ignore error   csn.Execute    command=cd /tmp/btslog2;tar -cvf btslog_${TAF_ADDR}.tar SYSLOG*   connection=taf
    run keyword and ignore error   csn.Download File    remote_path=/tmp/btslog2/btslog_${TAF_ADDR}.tar
    ...    local_path=${dir}/btslog_${TAF_ADDR}.tar   connection=taf
    sleep   3s
    csn.disconnect    connection=taf

Remove Btslog From Temp Folder
    [Arguments]   ${TAF_ADDR}   ${TAF_USERNAME}    ${TAF_PASSWORD}
    ${connection_asik}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    run keyword and ignore error   csn.Execute    command=rm -rf /tmp/btslog2/btslog_${TAF_ADDR}.tar   connection=taf
    run keyword and ignore error   csn.Execute    command=ll /tmp/btslog2/;rm -rf /tmp/btslog2/SYSLOG*   connection=taf
    run keyword and ignore error   csn.Execute    command=rm -rf /tmp/btslog2/BTSLOG_TRACE*   connection=taf
    csn.disconnect    connection=taf

Save Logs for Intergnb HO
    Stop And Download And Remove BTS LOG Collection     ${Log_directory}   name=btslog_source
    Stop And Download And Remove BTS LOG Collection     ${Log_directory}   name=btslog_target   host=${Tafip_Targetgnb}
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    ${HO_Targetgnb}   Wait Until Keyword Succeeds   3 times   2m   COAM Login   ${WEBUI_ADDR_Targetgnb}
    run keyword and ignore error   Catch Snapshot COAM   local_file_path=${Log_directory}/snapshot_sourcegnb.zip    connection=COAM
    run keyword and ignore error   Catch Snapshot COAM   local_file_path=${Log_directory}/snapshot_targetgnb.zip    connection=${HO_Targetgnb}
    run keyword and ignore error   COAM Logout   connection=COAM
    run keyword and ignore error   COAM Logout   connection=${HO_Targetgnb}

Case Common Setup for Intergnb HO
    [Arguments]   ${enb_HO}=${False}
    ${set_PCMD_range}   Set Variable If   ${enb_HO}   ${1}   ${2}
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir   connection=COAM
    log to console    BTS is on air
    Run Keyword And Ignore Error    Create Btslog log collection on remote machine for PCMD
    ...   name=btslog_target   host=${Tafip_Targetgnb}   user=ute   password=ute
    Run Keyword And Ignore Error    Create Btslog log collection on remote machine for PCMD   name=btslog_source   user=ute   password=ute
    Set Environment Variable              https_proxy                 ${empty}
	Run Keyword And Ignore Error   UE soft reboot   ue_index=${ue_index}   detach_request=${false}
    log to console    Rebuild PCMD Object
    FOR   ${index}    IN RANGE    ${set_PCMD_range}
        Set MRBTS Variables   gnb_index=${index}
        Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login   url=https://${tl.gnbs[${index}].cu.oam_http_connection_details.addr}
        Close Web Startup View Window
        run keyword and ignore error   Remove PCMD Object
        ${drx}   selenium_coam.get_parameter_value    dist_name=${INSID}/NRCELL-1   filter_param=Activate connected DRX
        Set Suite Variable   ${drx_${index}}   ${drx[0].upper()}${drx[1:]}
        Add PCMD Object
        COAM WEBUI Logout
    END
    COAM WEBUI Login
    Set MRBTS Variables   gnb_index=${0}
    Set Environment Variable              https_proxy                 ${empty}
    asik_handler.connect                i_ipAddr=${ASIK_IP}
    [Teardown]


Case Common Teardown for Intergnb HO
    CI_interface.Common Case Teardown
    run keyword if test failed  Save Logs for Intergnb HO
    run keyword if test passed   run keywords   Stop And Remove BTS LOG Collection   dir=${Log_directory}   name=btslog_source
    ...   AND   Stop And Remove BTS LOG Collection   dir=${Log_directory}   name=btslog_target   host=${Tafip_Targetgnb}
    Run Keyword and Ignore Error   COAM Logout
    Run Keyword and Ignore Error   COAM WEBUI Logout

Check ueCtxSetupRecord
     ${filtered_PCMDRecord_packets}    Load Pcap File with Filter
     ...                        pcap_file=${Log_directory}/${tcpdumpfile_sourcegnb}
     ...                        record_type=Du
     ...                        input_type=1
     ...                        filter=tcp.dstport==49148
    ${xpath_head_ ueCtxSetupRecord}   set variable   .//nsetapx.ueCtxSetupRecord/nsetapx.data_element/nsetapx.
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_PCMDRecord_packets}
    ...   xpath=${xpath_head_ ueCtxSetupRecord}ueCtxSetupReqRcvTime_element   attribute_name=showname
    should be equal     ${PCMDRecord_Fields_list}[0]   ueCtxSetupReqRcvTime
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_PCMDRecord_packets}
    ...   xpath=${xpath_head_ ueCtxSetupRecord}result   attribute_name=showname
    should be equal     ${PCMDRecord_Fields_list}[0]   result: success (0)
#    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_PCMDRecord_packets}
#    ...   xpath=${xpath_head_ ueCtxSetupRecord}result   attribute_name=showname      #UE Context Setup Response send time??
##    should be equal     @{PCMDRecord_Fields_list}[0]   result: success (0)
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_PCMDRecord_packets}
    ...   xpath=${xpath_head_ ueCtxSetupRecord}gnb_cu_ue_f1ap_Id
    Should Be True     0 < ${PCMDRecord_Fields_list}[0] < 4294967296 or ${PCMDRecord_Fields_list}[0]==0              #2^32-1

Check ueCtxReleaseRecord
     ${filtered_PCMDRecord_packets}    Load Pcap File with Filter
     ...                        pcap_file=${Log_directory}/${tcpdumpfile_sourcegnb}
     ...                        record_type=Du
     ...                        input_type=2
     ...                        filter=tcp.dstport==49148
    ${xpath_head_ ueCtxReleaseRecord}   set variable   .//nsetapx.ueCtxReleaseRecord/nsetapx.data_element/nsetapx.
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_PCMDRecord_packets}
    ...   xpath=${xpath_head_ ueCtxReleaseRecord}ueCtxReleaseReason   attribute_name=showname
    should be equal     ${PCMDRecord_Fields_list}[0]   ueCtxReleaseReason: normal (0)

Get hexadecimal PLMNIdentity
    ${PLMNIdentity_dec}     Get PLMNIdentity from WebUI
    ${PLMNIdentity_end}     Catenate    SEPARATOR=     ${PLMNIdentity_dec}         0
    ${first_three}      Get Substring     ${PLMNIdentity_end}   start=0    end=3
    ${PLMNIdentity_rest}     Fetch From Right  ${PLMNIdentity_end}   ${first_three}
    @{first_three}        convert to list      ${first_three}
    ${two_first_f}           Catenate     SEPARATOR=   ${first_three}[1]     ${first_three}[0]       f
    ${PLMNIdentity}        Catenate    SEPARATOR=     ${two_first_f}      ${PLMNIdentity_rest}
    [Return]    ${PLMNIdentity}

Get hexadecimal traceId
    ${traceId_hex}     Evaluate       hex(${tl.gnbs[0].instance_id})
    ${traceId_pure_num}     Remove String    ${traceId_hex}       0x
    ${traceId_length}   Get Length    ${traceId_pure_num}
    ${traceId_0_num}    Evaluate      6-${traceId_length}
    FOR   ${idx}    IN RANGE    0    ${traceId_0_num}
        ${traceId_pure_num}     Catenate   SEPARATOR=     0    ${traceId_pure_num}
    END
    [Return]    ${traceId_pure_num}
