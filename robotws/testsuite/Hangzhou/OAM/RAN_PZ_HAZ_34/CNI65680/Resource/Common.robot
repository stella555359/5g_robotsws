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
Resource    ../../common/taf_coam.robot
Resource   ../../common/L3_Call.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


Variables   ../../libraries/global_vars.py

*** Variables ***
${BTSID}   ${tl.gnbs[0].instance_id}
${LSS_IP}   ${tl.test_pc.default_ssh_connection_details.addr}

${LSS_Username}   coam
${LSS_Password}   zO&n1W*ktp7
${LSS_Port}   22022

${LSS_sudo_user}   ${tl.test_pc.default_ssh_connection_details.username}
${LSS_sudo_password}   ${tl.test_pc.default_ssh_connection_details.password}
${test_vm_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
${test_vm_user}   ${tl.test_pc.default_ssh_connection_details.username}
${test_vm_password}   ${tl.test_pc.default_ssh_connection_details.password}

&{executor_test_vm}   host=${test_vm_ip}   user=${test_vm_user}   password=${test_vm_password}

${cmd_antenna_script}    bsh 1:1 /usr/lib64/python/antenna_snapshot_config.py
${lte_l1_event}    ELtePhyEvent_PucchSnapshotVerification
${iq_parent_package}    BTS${BTSID}_123D_part_*
${iq_file_name}    BTS${BTSID}_124D_IqSnapshotBuffer.xz

${airmode_switch_on}    985 1483
${airmode_switch_off}    933 1535

${dist_name}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
${BBMOD_Runtime}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${meta_data_file}    *metadata.txt
${lte_cell_list}    ${1}
${ute_tmp_log_dir}    ${OUTPUT_DIR}/log

*** Keyword ***
Common Setup
    Log To Console   ${EMPTY}
    Remove LSS Snapshot
#    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    COAM Login
    # Set QC Instance ID Test Tag

Common Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

Set QC Instance ID Test Tag
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}/qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}

Check Fault 8101 Clear Status
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    FOR   ${active_alarm}   IN   @{active_alarms}
       Should Not Be Equal As Strings   ${active_alarm['faultId']}   8101
    END

Check Fault 8101 Raise Status
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    ${supplAlarmInfo}   Set Variable   NONE
    FOR   ${active_alarm}   IN   @{active_alarms}
       ${supplAlarmInfo}   Set Variable If
       ...   '${active_alarm['faultId']}'=='8101'   ${active_alarm['supplAlarmInfo']}
       ...   '${active_alarm['faultId']}'!='8101'   ${supplAlarmInfo}
       Exit For Loop If   '${active_alarm['faultId']}'=='8101'
    END
    Should Not Be Equal As Strings   ${supplAlarmInfo}   NONE

COAM Get Historic Alarms
    [Arguments]   ${connection}=COAM
    ${active_alarms}   coam.get_historic_alarms   connection=${connection}   timeout=10
    [Return]   ${active_alarms}

Check Fault 8101 Raise Status From History
    ${active_alarms}   COAM Get Historic Alarms
    ${supplAlarmInfo}   Set Variable   NONE
    FOR   ${active_alarm}   IN   @{active_alarms}
       ${supplAlarmInfo}   Set Variable If
       ...   '${active_alarm['faultId']}'=='8101'   ${active_alarm['supplAlarmInfo']}
       ...   '${active_alarm['faultId']}'!='8101'   ${supplAlarmInfo}
       Exit For Loop If   '${active_alarm['faultId']}'=='8101'
    END
    Should Not Be Equal As Strings   ${supplAlarmInfo}   NONE

Remove LSS Snapshot for Special Test Line
    csn.Connect To   hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
    ${snapshot-result}   csn.Execute   command=cd /home/coam/;ls -al | grep "Snapshot*"   connection=lss
    csn.Execute   command=cd /home/coam/;rm -rf Snapshot_MRBTS-${BTSID}_*   connection=lss
    [Teardown]   csn.Disconnect   connection=lss

Check Whether Snapshot Upload to LSS
    csn.Connect To    hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
    ${Snapshot_Output}   csn.Execute   command=cd /home/coam/;ls -al | grep Snapshot_MRBTS-${BTSID}_*   connection=lss
    Should Not Be Empty   ${Snapshot_Output}
    Set Suite Variable    ${Snapshot_Output}
    [Teardown]   csn.Disconnect   connection=lss

Check LSS IP Tables
    csn.Connect To   hostname=${LSS_IP}   username=${LSS_sudo_user}   password=${LSS_sudo_password}   alias=sudo
    ${iptables}   csn.Execute   command=sudo iptables -L | grep 22022 | grep -i ACCEPT   connection=sudo
    ${not_exit}   Run Keyword And Return Status   Should Be Empty   ${iptables}
    Run Keyword If   ${not_exit}   csn.Execute   command=sudo iptables -I INPUT -p tcp --dport 22022 -j ACCEPT   connection=sudo
    [Teardown]   csn.Disconnect   connection=sudo

L3CALL Precondition
    [Arguments]   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Attach UE Only
    [Arguments]   ${ue_index}=${ue_index}   ${ue_type}=huawei
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#    power_ue.UE Attach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    Preparation and execution for Commercial UE Attach    ue_index=${ue_index}    UE_type=${ue_type}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    Run Keyword If   '${mode_status}'!='0'   Sleep   10s
    ...   ELSE    UE Forced Reboot   ue_index=${ue_index}   detach_request=${false}

#Attach UE and Detach
#    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
#    Run Keyword Unless   '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#    power_ue.UE Attach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
#    Run Keyword If   '${mode_status}'!='0'   Sleep   10s
#    ...   ELSE    UE Forced Reboot   ue_index=${ue_index}   detach_request=${false}
#    [Teardown]   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Trigger L1 or L2 Event
    [Arguments]   ${subcell_id}=1   ${event_name}=EPhyEvent_PuschSnapshotVerification   ${loki_select}=2   ${cell_num}=2
    ${release}   Get gnb release   host=${WEBUI_ADDR}
    taf_coam.COAM WEBUI LOGIN   version=${release}
#    COAM Login
#    ${physCellId}   sbts_coam.get_parameter_value   dist_name=MRBTS-${BTSID}/NRBTS-${BTSID}/NRCELL-${cell_num}
#    ...   filter_param=Physical cell identifier
    ${physCellId}  COAM Get Parameter Value   dist_name=MRBTS-${BTSID}/NRBTS-${BTSID}/NRCELL-${cell_num}  parameter=physCellId
    ${ul}=    Run Keyword If   '${release}'<='SBTS22R4'   Create List    [PCI: ${physCellId}]NRCELL_R-${cell_num}: Subcell ${subcell_id}
    ...   ELSE IF   '${release}'=='SBTS23R1'   Create List   [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
    ...   ELSE   Create List    [BBMOD_R-1(ABIO)] [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
    ${dl}=    Run Keyword If   '${release}'<='SBTS22R4'   Create List    [PCI: ${physCellId}]NRCELL_R-${cell_num}: Subcell ${subcell_id}
    ...   ELSE IF   '${release}'=='SBTS23R1'   Create List   [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
    ...   ELSE   Create List    [BBMOD_R-1(ABIO)] [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
     Run Keyword And Ignore Error   Run Keyword And Ignore Error   Run Keyword If   '${release}'<='SBTS23R1'
     ...   selenium_coam.configure_iq_capture  bbmod=${BBMOD}   ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}
     ...   enable_capture_on_event=${True}
     ...   ELSE   selenium_coam.configure_iq_capture  ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}   enable_capture_on_event=${True}
#    sbts_coam.configure_uplane_l1_iq_data    module_dn=${BBMOD}
#    ...                                      dl_nr_subcell_list=${dl}
#    ...                                      ul_nr_subcell_list=${ul}
#    ...                                      capture_on_event=${True}
#    ...                                      connection=COAM
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${L1_event_query_ori}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query   connection=gnb
    ${group_ori}   Get Regexp Matches   ${L1_event_query_ori}   till now, (.+?) LTE Events & (.+?) NR Events
    log to console   ${group_ori}
    ${snapshot_trigger}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser write CommonPhy enableAutoSnapshot${SPACE}${SPACE}1
    ...   connection=gnb
    ${snapshot_trigger_check}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser read CommonPhy enableAutoSnapshot
    ...   connection=gnb
    ${mine_trigger}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser write CommonPhy minutesToTrigAutoBTSSnapshot${SPACE}${SPACE}5
    ...   connection=gnb
    ${mine_trigger_check}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser read CommonPhy minutesToTrigAutoBTSSnapshot
    ...   connection=gnb
    ${modify_event_number}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser write CommonPhy nbOfEventsToTrigAutoBTSSnapshot${SPACE}1
    ...   connection=gnb
    ${event_number_check}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser read CommonPhy nbOfEventsToTrigAutoBTSSnapshot
    ...   connection=gnb
#    ${L1_event_subcell_id}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --subcellid ${subcell_id}
#    ...   connection=gnb
    ${L1_event_trigger}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --nrevent ${event_name}
    ...   connection=gnb
    ${L1_event_query}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query    connection=gnb
    ${group}   Get Regexp Matches   ${L1_event_query}   till now, (.+?) LTE Events & (.+?) NR Events
    log to console   ${group}
    [Teardown]   Run Keywords   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
    ...   AND   Run Keyword And Ignore Error  COAM WEBUI Logout

Pause L1 or L2 Event
    [Arguments]   ${loki_select}=2
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --pause
    ...   connection=gnb
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb

Start BTS Syslog Collection
    Remove Syslog From TestVM
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2

    btslog.Set Global Alias   btslog
    core.setup_collectors   names=btslog
    core.start_collectors   names=btslog

Stop BTS Syslog Collection
    core.stop_collectors      names=btslog
    ${curr_date}   DateTime.Get Current Date
    ${datetime}   DateTime.Convert Date   ${curr_date}   datetime
    Set Suite Variable   ${date_str}   ${datetime.year}${datetime.month}${datetime.day}_${datetime.hour}${datetime.minute}
    csn.Connect To   hostname=${test_vm_ip}   username=${test_vm_user}   password=${test_vm_password}   alias=TestVM
    csn.Execute   command=cd /tmp/btslog2 ; ls -al; cat SYSLOG_*.LOG > SYSLOG_combine_${date_str}.LOG   connection=TestVM
    csn.Download File
    ...   remote_path=/tmp/btslog2/SYSLOG_combine_${date_str}.LOG
    ...   local_path=${OUTPUT_DIR}/SYSLOG_combine_${date_str}.LOG
    ...   connection=TestVM
    csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*   connection=TestVM
    [Return]   ${date_str}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=TestVM

Remove Syslog From TestVM
    csn.Connect To   hostname=${test_vm_ip}   username=${test_vm_user}   password=${test_vm_password}   alias=TestVM
    csn.Execute   command=mkdir /tmp/btslog2   connection=TestVM
    csn.Execute   command=cd /tmp/btslog2;rm -rf BTSLOG_TRACE_*.bin;rm -rf SYSLOG_*.LOG   connection=TestVM
    csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer   connection=TestVM
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=TestVM

Config LTE L1 Event Via Antenna Tool
    [Arguments]   ${lncellid}=2   ${event_name}=${lte_l1_event}    ${connection}=gnb
    ...    ${cmd_antenna_script}=${cmd_antenna_script}
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=${connection}
    ${L1_event_lncellid}   csn.execute   command=${cmd_antenna_script} --lncellid ${lncellid}
    ...   connection=gnb
    Log To Console    ${L1_event_lncellid}
    ${L1_event_trigger}   csn.execute   command=${cmd_antenna_script} --lteevent ${event_name}
    ...   connection=gnb
    Log To Console    ${L1_event_trigger}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

Config LTE L1 UL Event Via Confmgmtbrowser
    [Arguments]   ${lncellid}=2   ${event_name}=${lte_l1_event}    ${connection}=gnb
    Connect To gNB    alias=${connection}
    ${result}    csn.execute   command=bsh 1:1 confmgmtbrowser write CommonPhy enableAutoSnapshot 1
    ...   connection=${connection}
    ${result}    csn.execute   command=bsh 1:1 confmgmtbrowser write CommonPhy nbOfEventsToTrigAutoBTSSnapshot 1
    ...   connection=${connection}
    ${result}    csn.execute   command=bsh 1:1 confmgmtbrowser write LteUlPhy phyEventEnableExt 2147483648
    ...   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


Query Event Triggered
    [Arguments]  ${connection}=gnb
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=${connection}
    ${L1_event_query}   csn.execute   command=${cmd_antenna_script} --query    connection=gnb
    ${nr_event_num}    ${lte_event_num}    Return Event Number    ${L1_event_query}
    [Return]  ${nr_event_num}    ${lte_event_num}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

Return Event Number
    [arguments]    ${output}
    ${match}    Get Regexp Matches    ${output}    (.) LTE Events & (.) NR Events    1    2
    ${lte_event}    Set Variable    ${match}[-1][0]
    ${nr_event}    Set Variable    ${match}[-1][1]
    Log To Console    event triggerd>NR:${nr_event}-LTE:${lte_event}
    [Return]  ${nr_event}    ${lte_event}

Check snapshot file list
	[Arguments]    ${local_file_path}=${local_file_path}    ${iq_parent_package}=${iq_parent_package}
	...    ${iq_file_name}=${iq_file_name}   ${iq_file_content}=_IqSnapshotBuffer
	csn.Connect To    hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
#    ${file_path}   Find Newest Snapshot File
#    ${local_file_path}   Set Variable   /home/coam/${file_path}
    ${unzip_result}    csn.execute    command=cd ${local_file_path}; unzip -v "${iq_parent_package}" | grep "${iq_file_content}"
    ...    connection=lss
    ${file_size}    Get Regexp Matches     ${unzip_result}     Stored \+(\\d*) \+0%    1
	Should Be True     ${file_size}[0] > ${1024}
	${unzip_result}    split string    ${unzip_result}    \r\n
    ${unzip_result}    convert to string    ${unzip_result}
	${checked_snapshot}    Run Keyword And Continue On Failure
    ...    Should Match Regexp    ${unzip_result}    ${iq_file_name}
	Run Keyword And Continue On Failure    should not be empty    ${checked_snapshot}
	[Return]      ${checked_snapshot}
	[Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=lss

Check snapshot file list For 4G
	[Arguments]    ${local_file_path}=/home/coam/    ${iq_parent_package}=${iq_parent_package}
	...    ${iq_file_name}=${iq_file_name}   ${iq_file_content}=_IqSnapshotBuffer
	csn.Connect To    hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
    ${file_path}   Find Newest Snapshot File
    ${local_file_path}   Set Variable   /home/coam/${file_path}
    ${unzip_result}    csn.execute    command=cd ${local_file_path}; unzip -v "${iq_parent_package}" | grep "${iq_file_content}"
    ...    connection=lss
    ${file_size}    Get Regexp Matches     ${unzip_result}     Stored \+(\\d*) \+0%    1
	Should Be True     ${file_size}[0] > ${1024}
	${unzip_result}    split string    ${unzip_result}    \r\n
    ${unzip_result}    convert to string    ${unzip_result}
	${checked_snapshot}    Run Keyword And Continue On Failure
    ...    Should Match Regexp    ${unzip_result}    ${iq_file_name}
	Run Keyword And Continue On Failure    should not be empty    ${checked_snapshot}
	[Return]      ${checked_snapshot}
	[Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=lss

Find Newest Snapshot File
    ${Newest_Snapshot_file}   csn.Execute   command=ls -t /home/coam   connection=lss
    Set Suite Variable  ${Newest_Snapshot_file_path}  ${Newest_Snapshot_file.split("\r\n")[0]}
    csn.Execute   command=cd /home/coam;tar -cvf ${Newest_Snapshot_file_path}.tar ${Newest_Snapshot_file_path}  connection=lss
    csn.Download File
    ...   remote_path=/home/coam/${Newest_Snapshot_file_path}.tar
    ...   local_path=${OUTPUT_DIR}/${Newest_Snapshot_file_path}.tar
    ...   connection=lss
    [Return]   ${Newest_Snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error   csn.Execute   command=cd /home/coam/;rm -rf *.tar   connection=lss

Find Target Snapshot
     [Arguments]    ${Snapshot_Output}
     ${Snapshot_Output}  Remove String   ${Snapshot_Output}  \r\n
     ${Snapshot_Output}  Fetch From Right  ${Snapshot_Output}   Snapshot_
     ${target_snapshot}   Set Variable  Snapshot_${Snapshot_Output}
     csn.Execute   command=cd /home/coam;tar -cvf ${target_snapshot}.tar ${target_snapshot}  connection=lss
     csn.Download File
    ...   remote_path=/home/coam/${target_snapshot}.tar
    ...   local_path=${OUTPUT_DIR}/${target_snapshot}.tar
    ...   connection=lss
    [Return]  ${target_snapshot}
    [Teardown]    Run Keyword And Ignore Error   csn.Execute   command=cd /home/coam/;rm -rf *.tar   connection=lss

Check IQ File In Snapshot
	[Arguments]    ${local_file_path}=/home/coam/Snapshot*/    ${iq_parent_package}=${iq_parent_package}
	...    ${iq_file_name}=${iq_file_name}
	csn.Connect To    hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
    ${unzip_result}    csn.execute    command=cd ${local_file_path}; unzip ${iq_parent_package}    connection=lss
    File Should Exist    path=${local_file_path}\/${iq_parent_package}\/${iq_file_name}
    ${iq_file_size}    Get File Size    path=${local_file_path}${iq_parent_package}${iq_file_name}
    Should Be True    ${iq_file_size}>${0}
	[Return]    ${iq_file_size}
	[Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=lss

Attach Loop For Check Event
    [Arguments]    ${lte_event_num_bofore}    ${attach_loop_time}=${3}
    FOR    ${index}    IN RANGE    ${attach_loop_time}
         Run Keyword And Ignore Error    LG_v50 UE Attach And Verify
         sleep    5s
         ${nr_event_num_after}    ${lte_event_num_after}    Query Event Triggered
         ${event_trigged}    Evaluate    ${lte_event_num_after}-${lte_event_num_bofore}
         Run Keyword If    ${event_trigged} > 0    Exit For Loop
         Run Keyword And Ignore Error    LG_v50 UE Detach
    END
    Log To Console    trigger_times:${event_trigged}
    Should Not Be Equal As Numbers    ${event_trigged}    0
    [Return]   ${event_trigged}
    [Timeout]  20min

Attach And Verify Event Trigger
    [Arguments]    ${lte_event_num_bofore}    ${attach_loop_time}=${1}
    FOR    ${index}    IN RANGE    ${attach_loop_time}
         Run Keyword And Ignore Error    Attach UE Only
         sleep    5s
         ${nr_event_num_after}    ${lte_event_num_after}    Query Event Triggered
         ${event_trigged}    Evaluate    ${lte_event_num_after}-${lte_event_num_bofore}
         Run Keyword If    ${event_trigged} > 0    Exit For Loop
         Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${tl.ues[${ue_index}].capabilities[1]}
    END
    Log To Console    trigger_times:${event_trigged}
    Should Not Be Equal As Numbers    ${event_trigged}    0
    [Return]   ${event_trigged}
    [Timeout]  30min
    [Teardown]  Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${tl.ues[${ue_index}].capabilities[1]}

Prepare For UE
    [Arguments]    ${ue_index}=${0}    ${is_need_to_kill_vysor}=${True}    ${ui_version}=default    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ...  :param  is_need_to_kill_vysor: flag to decide whether or not to kill vysor process
    Run keyword if    ${is_need_to_kill_vysor}    Kill vysor process    ue_index=${ue_index}
    Get product brand    ue_index=${ue_index}
    Set LG New Version Tap Position Variable
    LG_v50 UE Detach

Check UE State
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    Log To Console    AirmodeState:${mode_status}(1:Airmode-ON,0:Airmode-OFF)
    [Return]  ${mode_status}

Set LG New Version Tap Position Variable
    Set Suite Variable    ${home}    KEYCODE_HOME
    Set Suite Variable    ${airmode_top_icon}    97 354
    Set Suite Variable    ${swip_airmode_console}    500 0 500 1000 500
    Set Suite Variable    ${airmode_switch_off}    985 1483
    Set Suite Variable    ${airmode_switch_on}    933 1535
    Set Suite Variable    ${airmode_switch_on_comfirm}    761 2072
    Set Suite Variable    ${close_task}    700 2450
    Set Suite Variable    ${Home_button}    KEYCODE_HOME
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1200 360
    Set Suite Variable    ${iperf_space}    800 650

Airmode Switch For LG_V50 New GUI
    [Documentation]    click AIRPLANE switch once
    ...    :param  swipe: Swipe the phone screen up
    ...    :param  Home_button: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${close_task}=${close_task}
    ...    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${airmode_switch_on}=${airmode_switch_on}
    ...    ${airmode_switch_off}=${airmode_switch_off}    ${mode_status}=
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
    sleep   2s
    ${output}   csn.read_output    connection=cygwin
    #####Tap the airplane mode switch to enable airplane mode#####
    Run Keyword if    ${mode_status}==1
    ...    LG Airmode Turn Off
    ...    ELSE IF    ${mode_status}==0
    ...    LG Airmode Turn On
#    Run Keyword if    ${mode_status}==1
#    ...    csn.send_command    command=adb -s ${serial_number} shell input tap ${airmode_switch_on}    connection=cygwin
#    ...    ELSE IF    ${mode_status}==0
#    ...    LG Airmode Turn On Adb Command
    sleep   2s
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

LG Airmode Turn On Adb Command
    [Documentation]    Open Airmode icon on UE network view, and click comfirm when jump out noticfication
    [arguments]    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${airmode_switch_on}=${airmode_switch_on}
    ...    ${airmode_switch_on_comfirm}=${airmode_switch_on_comfirm}
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airmode_switch_on}    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airmode_switch_on_comfirm}    connection=cygwin

LG Airmode Turn On
    [Arguments]      ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${current_time}  Get Current Date    result_format=%Y_%m_%d_%H_%M_%S
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} exec-out screencap -p > /cygdrive/d/${current_time}.png    connection=cygwin
    sleep   5s
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swip_airmode_console}    connection=cygwin
    sleep   5s
    ${current_time}  Get Current Date    result_format=%Y_%m_%d_%H_%M_%S
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} exec-out screencap -p > /cygdrive/d/${current_time}.png    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airmode_top_icon}    connection=cygwin
    sleep   5s
    ${current_time}  Get Current Date    result_format=%Y_%m_%d_%H_%M_%S
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} exec-out screencap -p > /cygdrive/d/${current_time}.png    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airmode_switch_on_comfirm}    connection=cygwin
    sleep   5s
    ${current_time}  Get Current Date    result_format=%Y_%m_%d_%H_%M_%S
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} exec-out screencap -p > /cygdrive/d/${current_time}.png    connection=cygwin
    sleep   5s

LG Airmode Turn Off
    [Arguments]      ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swip_airmode_console}    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airmode_top_icon}    connection=cygwin
    sleep   5s


Check Metadata File Content
	[Arguments]    ${meta_data_file}=${meta_data_file}    ${trigger_type_match}=8101 - On fault detection
	csn.Connect To    hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
	${file_path}   Find Newest Snapshot File
    ${local_file_path}   Set Variable   /home/coam/${file_path}
    ${meta_date_file_content}    csn.execute    command=cat ${local_file_path}/${meta_data_file}    connection=lss
	${result}    Run Keyword And Continue On Failure
    ...    Should Match Regexp    ${meta_date_file_content}    ${trigger_type_match}
	Run Keyword And Continue On Failure    should not be empty    ${result}
	[Return]    ${result}
	[Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=lss

Remove COAM Directory Snapshot
    csn.Connect To    hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
    csn.execute    command=rm -rf /home/coam/${Newest_Snapshot_file_path}    connection=lss
    [Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=lss

Check Metadata File
	[Arguments]    ${meta_data_file}=${meta_data_file}    ${trigger_type_match}=8101 - On fault detection
	csn.Connect To    hostname=${LSS_IP}   username=${LSS_Username}   password=${LSS_Password}   alias=lss
	${target_snapshot}   Find Target Snapshot   Snapshot_Output=${Snapshot_Output}
    ${local_file_path}   Set Variable   /home/coam/${target_snapshot}
    Set Suite Variable   ${local_file_path}
    ${meta_date_file_content}    csn.execute    command=cat ${local_file_path}/${meta_data_file}    connection=lss
    Should Contain    ${meta_date_file_content}    ${trigger_type_match}
	[Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=lss

Config IQ Capture 4G Via WebEM
    sbts_coam.connect_to    bts_host=${oam_addr}   name=coam
    Log To Console    Get LNCELL ID
    ${lte_cell_list}   Create List    ${1}
    Run Keyword And Ignore Error    Configure Uplane L1 Iq Data For 4G
    ...                             module_dn=${BBMOD_Runtime}
    ...                             ulLteCellList=${lte_cell_list}
    ...                             dlLteCellList=${lte_cell_list}
    [Teardown]    sbts_coam.teardown    connection=coam


Configure Uplane L1 Iq Data For 4G
    [Documentation]  Parameter module_dn must be a Runtime DN of BBMOD or SMOD DN that support embeded BBMOD
    ...              one of dlNrSubcellList|ulNrSubcellList| dlLteCellList|ulLteCellList must be configured, maxItems is 2
    ...    Example request:     "moduleDN":"/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1",
    ...                         "dlNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-1","subcellId":1}],
    ...                         "ulNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-2","subcellId":2}],
    ...                         "dlLteCellList": [1],
    ...                         "ulLteCellList": [1],
    ...                         "captureOnEvent": true
    [Arguments]  ${module_dn}=${BBMOD_Runtime}    ${dlLteCellList}=${dl_lte_cell_list}   ${ulLteCellList}=${ul_lte_cell_list}
    ...    ${captureOnEvent}=${true}    ${connection}=coam
    sbts_coam.configure_uplane_l1_iq_data    module_dn=${module_dn}
    ...                                      dl_lte_subcell_list=${dlLteCellList}
    ...                                      ul_lte_subcell_list=${ulLteCellList}
#    ...                                      dl_nr_subcell_list=${dlNrSubcellList}
#    ...                                      ul_nr_subcell_list=${ulNrSubcellList}
    ...                                      capture_on_event=${captureOnEvent}
    ...                                      connection=${connection}

Configure Uplane L1 Iq Data For 5G
    [Documentation]  Parameter module_dn must be a Runtime DN of BBMOD or SMOD DN that support embeded BBMOD
    ...              one of dlNrSubcellList|ulNrSubcellList| dlLteCellList|ulLteCellList must be configured, maxItems is 2
    ...    Example request:     "moduleDN":"/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1",
    ...                         "dlNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-1","subcellId":1}],
    ...                         "ulNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-2","subcellId":2}],
    ...                         "dlLteCellList": [1],
    ...                         "ulLteCellList": [1],
    ...                         "captureOnEvent": true
    [Arguments]  ${module_dn}=${BBMOD_Runtime}    ${dlNrSubcellList}=${dl_nr_subcell_list}   ${ul_nr_subcell_list}=${ul_lte_cell_list}
    ...    ${captureOnEvent}=${true}    ${connection}=coam
    sbts_coam.configure_uplane_l1_iq_data    module_dn=${module_dn}
#    ...                                      dl_lte_subcell_list=${dlLteCellList}
#    ...                                      ul_lte_subcell_list=${ulLteCellList}
    ...                                      dl_nr_subcell_list=${dlNrSubcellList}
    ...                                      ul_nr_subcell_list=${ulNrSubcellList}
    ...                                      capture_on_event=${captureOnEvent}
    ...                                      connection=${connection}

Config Base Fault ID And LSS Snapshot Trigger Parameter
    sbts_coam.connect_to    bts_host=${oam_addr}   name=coam
    Internal Trace Activate
    Snapshot Destination Configuration
    Local symptoms server configuration    lssIPaddress=${test_vm_ip}    lssPortNo=22
    Fault Snapshot Triggers configuration    faultNumber=8101    triggerType=onFaultDetection
    [Teardown]  sbts_coam.teardown    connection=coam

Change Diagnostic Snapshot destinationS
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    sbts_coam.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=coam

Local symptoms server configuration
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${list_param_to_change}=    Create Dictionary    lssIPaddress    1.0.0.0
    Set To Dictionary    ${list_param_to_change}    lssIPaddress=${lssIPaddress}
    ...                                             lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    sbts_coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip
    ...                                            connection=coam

Fault Snapshot Triggers configuration
    [Arguments]    ${faultNumber}
	...            ${triggerType}
    ${list_param_to_change}    Create Dictionary    faultNumber=${faultNumber}
    ...                                             triggerType=${triggerType}
    @{list}=    create list    ${list_param_to_change}
    sbts_coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=faultSnapshotTriggers
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip
    ...                                            connection=coam

Snapshot Destination Configuration
    [Arguments]    ${snapshot_destination}=lss
    sbts_coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=diagSnapDestination
    ...                                            operation=update
    ...                                            value=${snapshot_destination}
    ...                                            skip_parameter_relation_errors=skip
    ...                                            connection=coam

Internal Trace Activate
    sbts_coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=actInternalTrace
    ...                                            operation=update
    ...                                            value=${True}
    ...                                            skip_parameter_relation_errors=skip
    ...                                            connection=coam

Internal Trace Deactivate
    sbts_coam.connect_to    bts_host=${oam_addr}   name=coam
    sbts_coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=actInternalTrace
    ...                                            operation=update
    ...                                            value=${False}
    ...                                            skip_parameter_relation_errors=skip
    ...                                            connection=coam
    [Teardown]  sbts_coam.teardown    connection=coam

LG_v50 UE Attach And Verify
    ${mode_status_before}    Check UE State
    Run Keyword If     ${mode_status_before}==0    Repeat Keyword    2x    LG_v50 New Version Airmode Switch
    ...    ELSE    LG_v50 New Version Airmode Switch
    sleep    10s
    ${mode_status_after}    Check UE State
    Should Be True    ${mode_status_after}==0
    Verify 4G Attach by ADB Command

LG_v50 UE Detach
    ${mode_status}    Check UE State
    Run Keyword If    ${mode_status}==0    LG_v50 New Version Airmode Switch
    ...    ELSE    Log To Console    The UE has detached
    ${mode_status}    Check UE State
    Should Be True    ${mode_status}==1

LG_v50 New Version Airmode Switch
    Set LG New Version Tap Position Variable
    Connect to control pc via cygwin
    ${mode_status_before}    Check UE State
    Connect to control pc via cygwin
    Airmode Switch For LG_V50 New GUI    mode_status=${mode_status_before}
    Sleep    10s
    ${mode_status_after}    Check UE State
    Should Not Be True    ${mode_status_before}==${mode_status_after}

Prepare Loki Journal Log Setup
    log to console    \n *** Start capture the journal log on gNB
    Start Collect Journal Logs For Coam
    sleep   5s

Start Collect Journal Logs For Coam
    [Arguments]   ${loki_index}=1   ${journal_command}=journalctl
    Connect To gNB
    csn.send command     command=bsh 1:${loki_index} ${journal_command} -f > /tmp/journal.log &    connection=gNB
    Run Keyword And Ignore Error  csn.disconnect    connection=gNB

Loki Journal Log Teardown
    log to console    \n *** Stop the journal log
    Stop Collect Journal Logs For Coam

Stop Collect Journal Logs For Coam
    [Arguments]   ${journal_command}=journalctl
    Connect To gNB
    Run Keyword And Ignore Error    csn.execute     command=ps -ef|grep ssh |grep ${journal_command}|grep -v grep|awk '{print $2}'|xargs kill -15
    ...    connection=gNB
    Run Keyword And Ignore Error    csn.execute     command=chmod 777 /tmp/journal.log    connection=gNB
    ${curr_date}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M     exclude_millis=True
    csn.download_file   remote_path=/tmp/journal.log    local_path=${OUTPUT_DIR}/journal_${curr_date}.log
    ...    connection=gNB
    sleep   30s
    Run Keyword And Ignore Error    csn.execute     command=rm /tmp/journal.log    connection=gNB
    [Return]   ${curr_date}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=gNB

Connect To gNB
    [Arguments]    ${alias}=gNB     ${loki_numb}=1
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

Analyze SYSLOG for Event Trigger
    [Arguments]   ${date_str}=1
    csn.Connect To   hostname=${test_vm_ip}   username=${test_vm_user}   password=${test_vm_password}   alias=TestVM
    ${timeMaker}   csn.Execute
    ...   command=cd ${OUTPUT_DIR};cat SYSLOG_combine_${date_str}.LOG | grep "Event Trigger to freeze TTI and TimeMarker"
    ...   connection=TestVM
    log to console   ${timeMaker}
    Should Not Be Empty   ${timeMaker}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=TestVM
