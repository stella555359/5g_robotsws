*** Settings ***
Documentation    These are common keywords for CNI-112018 related cases,trigger 1981 and check alarms on WEB and R history logs
...              Please do not modify the file without notification to author
...              Contact: kaihui.fan@nokia-sbell.com
...              Squard: HZ SG4

Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library     random


*** Keywords ***
General_SiSo_Ecpri_RU_DFE_no_TX_Data_fault_activation
    [Arguments]    ${connection}=GNB_OAM    ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}    ${ue_num_each_call}=${1}
    ${made_dict}=    Create Dictionary   ip=192.168.101.2   alias=made1
    Log   Dictionary:${made_dict}
    ${made_ip}=    get from dictionary    ${made_dict}   ip
    ${made_alias}=    get from dictionary    ${made_dict}   alias
    ${ru_index_list}    Get RU index list    connection=${connection}
    Set Test Variable    ${ru_index_list}
    ${release}    coam.get_sw_release_name    connection=${connection}
    ${trigger_fault_id}    Set Variable If    '${release}'>='SBTS25R2'    1907    1981
    FOR    ${ru_index}    IN    @{ru_index_list}
        Trigger Fault 1904/1981 And Check On WEBEM   ru_index=${ru_index}   ip=${made_ip}   alias=${made_alias}
        ...       proxy=RU_${ru_index}   connection=${connection}   cmd=ls   CNI112018=${True}  alarmId=${trigger_fault_id}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}    with_peak=${with_peak}
        ...    duration=${duration}    ue_num_each_call=${ue_num_each_call}    connection=${connection}
        run keyword and ignore error   csn.disconnect    connection=RU_${ru_index}
    END
    [Teardown]    run keyword and ignore error    csn.Disconnect  connection=ASIK Master

General_SiSo_SFP_alarm_monitoring_activation
    [Arguments]    ${connection}=GNB_OAM
    ${ru_index_list}    Get RU index list    connection=${connection}
    Set Test Variable    ${ru_index_list}
    # Minor severity alarm 7115 will not be reported to NMS and WebEM due to CNI-127210. WESTLAKE-10633
    # Feature CB009226 NIDD Parameter   CB009226_value=Transceiver alarms and warnings   connection=${connection}
    # Trigger Fault and check fault    expected_fault=4698    warning_alarm=alarm    connection=${connection}
    # Trigger Fault and check fault    expected_fault=4699    warning_alarm=alarm    connection=${connection}
    # Trigger Fault and check fault    expected_fault=4700    warning_alarm=alarm    connection=${connection}
    # Trigger Fault and check fault    expected_fault=4701    warning_alarm=alarm    connection=${connection}
    # Trigger Fault and check fault    expected_fault=all    warning_alarm=warning    connection=${connection}
    Feature CB009226 NIDD Parameter   CB009226_value=Transceiver alarms    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Trigger Fault and check fault    ru_index=${ru_index}    expected_fault=4698    warning_alarm=alarm    connection=${connection}
        Trigger Fault and check fault    ru_index=${ru_index}    expected_fault=4699    warning_alarm=alarm    connection=${connection}
        Trigger Fault and check fault    ru_index=${ru_index}    expected_fault=4700    warning_alarm=alarm    connection=${connection}
        Trigger Fault and check fault    ru_index=${ru_index}    expected_fault=4701    warning_alarm=alarm    connection=${connection}
    END
    Feature CB009226 NIDD Parameter   CB009226_value=Off    connection=${connection}

Feature CB009226 NIDD Parameter
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Open CB009226 NIDD paramter
    ...    actTransceiverAlarmMonitoring set value alarms and warnings or alarms or off
    ...    Author: kaihui.fan@nokia-sbell.com
    ...    *****************
    [Arguments]    ${connection}=GNB_OAM   ${CB009226_value}=Transceiver alarms and warnings
    log to console    \nFeature CB009226 Transceiver alarms and warnings using admin
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actTransceiverAlarmMonitoring
    ...    value=${CB009226_value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${True}
    ...    connection=${connection}

Trigger Fault and check fault
    [Arguments]    ${expected_fault}=4698    ${warning_alarm}=none   ${connection}=GNB_OAM    ${asik_connection}=ASIK Master
    ...    ${ru_index}=${1}   ${ru_alias}=RU_${ru_index}
    log to console    \nTrigger Fault ${expected_fault} and check fault
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    log to console    \nLogin radio
    Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=${ru_alias}
    ...    asik_alias=${asik_connection}   connection=${connection}
    log to console    \nLogin Thor and trigger all warnings
    Connect to made With Command    ru_index=${ru_index}    ip=192.168.101.17    cmd=pwd     alias=Thor    proxy=${ru_alias}
    Login frmon and create agent   connection=Thor
    ${output_tmp}    Read SFP info  connection=Thor
	${fault}    Set Variable    ${expected_fault}
    Run keyword if   '${fault}'=='4698' or '${fault}'=='4699' or '${fault}'=='4700' or '${fault}'=='4701'
    ...   Send trigger expected command   faultid=${expected_fault}   warning_alarm=${warning_alarm}
    ...   ELSE   Send trigger all warnings command   connection=Thor
    ${output}    Read SFP info  connection=Thor
	Run keyword if   '${fault}'=='4698'   sleep    15s
	...   ELSE    sleep    45s
    Collect raw fault in radio history  connection=${ru_alias}
    Run keyword if   '${fault}'=='4698'    Set test variable    ${source}    MRBTS-${NRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/SFP_R-1
	...   ELSE    Set test variable    ${source}    MRBTS-${NRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/SFP_R-1/LANE_R-1
    Run keyword if   '${warning_alarm}'=='warning'    Set severity and alarmid for warnig
	Run keyword if   '${warning_alarm}'=='alarm'    Set severity and alarmid for alarm
    Run keyword if   '${fault}'=='4698' or '${fault}'=='4699' or '${fault}'=='4700' or '${fault}'=='4701'
    ...    Expect Fault Should Present    faultId=${fault}    source=${source}
    ...    severity=${severity}    alarmId=${alarmId}
    ...   ELSE   Check All Warnings And Alarms  severity=${severity}    alarmId=${alarmId}    ru_index=${ru_index}
    [Teardown]    Run Keyword And Ignore Error    Recovery and check    ru_index=${ru_index}

Recovery and check
    [Arguments]    ${ru_index}=${1}   ${ru_alias}=RU_${ru_index}
    log to console    \nRecovery and check
    Run Keyword And Ignore Error    Cancel SFP oeveride memory   connection=Thor
    ${fault_output}    Collect raw fault in radio history  connection=${ru_alias}
    Set test variable    ${fault_output}
    Run Keyword And Ignore Error    Terminate agent   connection=Thor
	Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
	Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=GNB_OAM

Terminate agent
    [Arguments]    ${connection}=Thor
    log to console    \nTerminate agent
    ${cmd_terminate}    Set Variable  echo "/SfpInfo action terminate"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_terminate}    connection=${connection}

Cancel SFP oeveride memory
    [Arguments]    ${connection}=Thor
    log to console    \nCancel SFP oeveride
    ${cmd_cancel}    Set Variable  echo "/SfpInfo action cancel_sfp_override_memory 1"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_cancel}    connection=${connection}

Check All Warnings And Alarms
    [Arguments]  ${severity}=${None}    ${alarmId}=${None}    ${ru_index}=${1}
    log to console    \nCheck All Warnings or Alarms
    ${sfp_dist_name}    Set Variable    MRBTS-${NRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/SFP_R-1
    ${lane_dist_name}    Set Variable    ${sfp_dist_name}/LANE_R-1
    Expect Fault Should Present    faultId=4698    source=${sfp_dist_name}
    ...    severity=${severity}    alarmId=${alarmId}
    Expect Fault Should Present    faultId=4699    source=${lane_dist_name}
    ...   severity=${severity}    alarmId=${alarmId}
    Expect Fault Should Present    faultId=4700    source=${lane_dist_name}
    ...   severity=${severity}    alarmId=${alarmId}
    Expect Fault Should Present    faultId=4701    source=${lane_dist_name}
    ...   severity=${severity}    alarmId=${alarmId}

Login frmon and create agent
    [Arguments]    ${connection}=RU_1
    log to console    \nLogin Frmon and create agent
    ${cmd_create}    Set Variable  echo "/ action create SfpInfo /SfpInfo"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_create}    connection=${connection}

Read SFP info
    [Arguments]    ${connection}=RU_1
    log to console    \nRead SFP info
    ${cmd_read_sfp1}    Set Variable  echo "/SfpInfo action read_info 1"|frmonShellClient 127.0.0.1 2000
	${output_sfp1}    csn.execute    command=${cmd_read_sfp1}    connection=${connection}
	[Return]    ${output_sfp1}

Send trigger expected command
    [Arguments]    ${faultid}    ${warning_alarm}=alarm
    log to console    \nSend trigger expected command
    Run keyword if   '${faultid}'=='4698' and '${warning_alarm}'=='alarm'    Send trigger 4698 alarm command
    Run keyword if   '${faultid}'=='4698' and '${warning_alarm}'=='warning'    Send trigger 4698 warning command
    Run keyword if   '${faultid}'=='4699' and '${warning_alarm}'=='alarm'    Send trigger 4699 alarm command
    Run keyword if   '${faultid}'=='4699' and '${warning_alarm}'=='warning'    Send trigger 4699 warning command
    Run keyword if   '${faultid}'=='4700' and '${warning_alarm}'=='alarm'    Send trigger 4700 alarm command
    Run keyword if   '${faultid}'=='4700' and '${warning_alarm}'=='warning'    Send trigger 4700 warning command
    Run keyword if   '${faultid}'=='4701' and '${warning_alarm}'=='alarm'    Send trigger 4701 alarm command
    Run keyword if   '${faultid}'=='4701' and '${warning_alarm}'=='warning'    Send trigger 4701 warning command

Collect raw fault in radio history
    [Arguments]    ${connection}=RU_1
    log to console    \nCollect raw fault in radio history
    ${cmd_collect}    Set Variable  cat /ram/fault_history_log_temp.txt
    ${raw_fault_output}  csn.execute  command=${cmd_collect}    connection=${connection}
    [Return]    ${raw_fault_output}

Set severity and alarmid for warnig
	Set test variable    ${severity}    Minor
	Set test variable    ${alarmid}    7115

Set severity and alarmid for alarm
	Set test variable    ${severity}    Major
	Set test variable    ${alarmid}    7100

Send trigger all warnings command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger all warnings command
    ${cmd_trigger_all}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x74 DATA 0x85 0x40"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_all}    connection=${connection}

Send trigger 4698 alarm command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4698 alarm command
    ${cmd_trigger_4698}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x80"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4698}    connection=${connection}

Send trigger 4698 warning command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4698 warning command
    ${cmd_trigger_4698}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x74 DATA 0x80"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4698}    connection=${connection}


Send trigger 4699 alarm command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4699 alarm command
    ${cmd_trigger_4699}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x04"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4699}    connection=${connection}
    Sleep    180s

Send trigger 4699 warning command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4699 warning command
    ${cmd_trigger_4699}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x74 DATA 0x04"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4699}    connection=${connection}


Send trigger 4700 alarm command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4700 alarm command
    ${cmd_trigger_4700}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x01"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4700}    connection=${connection}
    Sleep    180s

Send trigger 4700 warning command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4700 warning command
    ${cmd_trigger_4700}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x74 DATA 0x01"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4700}    connection=${connection}

Send trigger 4701 alarm command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4701 alarm command
    ${cmd_trigger_4701}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x71 DATA 0x40"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4701}    connection=${connection}
    Sleep    180s

Send trigger 4701 warning command
    [Arguments]    ${connection}=Thor
    log to console    \nSend trigger 4701 warning command
    ${cmd_trigger_4701}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x75 DATA 0x40"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4701}    connection=${connection}