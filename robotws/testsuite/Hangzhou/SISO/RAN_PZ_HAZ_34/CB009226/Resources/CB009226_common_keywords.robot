*** Settings ***
Documentation
...    author: zhenzhen.guo
...    contact:zhenzhen.guo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB008392
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/compare_alarm_list.py
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000829/libraries/snapshot_files.py

*** Variables ***
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${raw_alarm}    BTS${tl.gnbs[0].global_bts_id}_1011_RawAlarmHistory.txt
${btsid}    ${tl.gnbs[0].global_bts_id}


*** Keywords ***
Feature CB009226 Transceiver alarms and warnings
    log to console    \nFeature CB009226 Transceiver alarms and warnings using admin
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actTransceiverAlarmMonitoring
    ...    value=Transceiver alarms and warnings
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Feature CB009226 Transceiver alarms
    log to console    \nFeature CB009226 Transceiver alarms using admin
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actTransceiverAlarmMonitoring
    ...    value=Transceiver alarms
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Feature CB009226 Transceiver off
    log to console    \nFeature CB009226 Transceiver alarms using admin
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actTransceiverAlarmMonitoring
    ...    value=Off
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

PM counter update enabled
    log to console    \nPM counter update enabled
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtSBTSSfpRMOD
    ...    value=15min
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtSbtsSfpRmodLane
    ...    value=15min
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM



Check If there is new alarm
    Log To Console    Check If there is new alarm
    #Selenium Login And Disable Screen Lock    download_dir=/tmp    version=${version}
    @{alarm_info}=    Wait Until Keyword Succeeds    5min    10s    selenium_coam.get_active_alarm_info    timeout=100
    ${alarm_numbler}=        Get Length    ${alarm_info}
    run keyword and ignore error    should be true    ${alarm_numbler} == 4
    #sleep    5s
    #${alarm_info_history}=    coam.get_historic_alarms    timeout=60    connection=GNB_OAM
    ${is_4282_active}    Check If there is 4282
    #[Teardown]    Selenium Logout And Close Browser

Suite Teardown
    [Arguments]    ${gnb_index}=0
    log to console    \n***SISO Coam Suite Teardown***
#    run keyword and ignore error    Feature CB009226 Transceiver alarms
#    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ...    connection=${connection}    gnb_index=${gnb_index}
	#Check If there is new alarm
	#Selenium Logout And Close Browser
	run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
	csn.execute    command=rm -rf /tmp/*.log    connection=ute
	csn.execute    command=rm -rf /tmp/*.html    connection=ute
	#csn.execute    command=rm -rf /tmp/*    connection=ute
    csn.Disconnect     connection=ute

Suite Setup
    Connect to gnb coam via ssl
#    ${version}=    coam.get_sw_version    connection=GNB_OAM
#	Set Suite Variable    ${version}
#    Selenium Login And Disable Screen Lock
#    ${stream}    get stream from version    ${version}
#    Set Suite Variable    ${stream}
#    @{SBTS_release}    string.split string    ${stream}    separator=SBTS
#    ${release_id}    set variable    @{SBTS_release}[1]
#    Set Suite Variable    ${release_id}
#    ${8T8R_scf_name}    Run keyword if   '${stream}'=='SBTS00'     set variable   SCF_8T8R_SBTS00.xml
#    ...   ELSE    set variable    SCF_8T8R_SBTS${release_id}.xml
#    Set Suite Variable    ${8T8R_scf_name}


Check active alarms
    [Tags]      WIP
    ${active_alarms}    coam.get_active_alarms    connection=GNB_OAM    timeout=60
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Check history alarms
    [Tags]      WIP
    ${history_alarms}=    coam.get_historic_alarms    timeout=60    connection=GNB_OAM
    ${alarm_id_list}    Create List
    ${len}    get length    ${history_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${history_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Check if alarm exist
    [Arguments]    ${alarm_list}    ${alarm_id}
    set suite variable    ${is_alarm_visible}    False
    FOR    ${element}    IN    @{alarm_list}
        run keyword if    '${element}'=='${alarm_id}'    set suite variable   ${is_alarm_visible}     True
    END
    run keyword if     '${is_alarm_visible}'=='False'    FAIL


Trigger Fault 4698 and check fault
    [Arguments]  ${connection}=GNB_OAM    ${asik_connection}=ASIK Master
    log to console    \nTrigger Fault 4698 and check fault
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    log to console    \nLogin radio
    Connect to RU With Allocated IP    ru_index=1   ru_alias=RU_1
    ...    asik_alias=${asik_connection}   connection=${connection}
    Login frmon and create agent
    ${output_tmp}    Read SFP info
    Send trigger 4698 command
    ${output}    Read SFP info
    run keyword and ignore error    Wait Until Keyword Succeeds    3min    10s
	...    Check If there is expected fault    faultid=4698
    Cancel SFP oeveride memory
    Terminate agent
    log to console    \nTrigger Fault 4698 with another way
    Login frmon and create agent
    ${output_tmp}    Read SFP info
    Send trigger 4698 command2
    ${output}    Read SFP info
    run keyword and ignore error    Wait Until Keyword Succeeds    3min    10s
	...    Check If there is expected fault    faultid=4698
    Terminate agent
    #[Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_1
    #...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_connection}



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

Send trigger 4698 alarm command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4698 alarm command
    ${cmd_trigger_4698}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x80"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4698}    connection=${connection}

Send trigger 4698 warning command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4698 warning command
    ${cmd_trigger_4698}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x74 DATA 0x80"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4698}    connection=${connection}



Cancel SFP oeveride memory
    [Arguments]    ${connection}=RU_1
    log to console    \nCancel SFP oeveride
    ${cmd_cancel}    Set Variable  echo "/SfpInfo action cancel_sfp_override_memory 1"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_cancel}    connection=${connection}

Cancel SFP oeveride gpio
    [Arguments]    ${connection}=RU_1
    log to console    \nCancel SFP oeveride	 gpio
    ${cmd_cancel}    Set Variable  echo "/SfpInfo action cancel_sfp_override_gpio 1"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_cancel}    connection=${connection}


Terminate agent
    [Arguments]    ${connection}=RU_1
    log to console    \nTerminate agent
    ${cmd_terminate}    Set Variable  echo "/SfpInfo action terminate"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_terminate}    connection=${connection}

Check If there is expected fault
    [Arguments]    ${faultid}=4698
    Log To Console    Check If there is expected fault ${faultid}
	run keyword if     '${faultid}'=='sync_lost'    Set test variable    ${faultid}    4298
    Connect to gnb coam via ssl
    ${alarm_list_actual}=    Check active alarms
    ${is_expected_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    ${faultid}
    Set Suite Variable    ${is_alarm_visible}
	Log To Console    \n does expected fault report:${is_alarm_visible}
    ####${alarm_list_history}=    Check history alarms
	#${is_expected_history}=    run keyword and return status    Check if alarm exist    ${alarm_list_history}    ${faultid}
    run keyword if     '${is_alarm_visible}'=='False'     FAIL
    [return]    ${is_alarm_visible}

Recovery temperature
    [Arguments]    ${connection}=RU_1    ${asik_connection}=ASIK Master
    Log To Console    Recovery temperature
    Login frmon and create agent
	Cancel SFP oeveride memory
	Read SFP info
	Terminate agent
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_1
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_connection}

Trigger Fault 2929 and check fault
    [Arguments]  ${connection}=GNB_OAM    ${asik_connection}=ASIK Master
    log to console    \nTrigger Fault 2929 and check fault
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    log to console    \nLogin radio
    Connect to RU With Allocated IP    ru_index=1   ru_alias=RU_1
    ...    asik_alias=${asik_connection}   connection=${connection}
    Login frmon and create agent
    ${output_tmp}    Read SFP info
    Send trigger 2929 command
    ${output}    Read SFP info
	sleep 1s
    Check If there is expected fault    faultid=2929
    Terminate agent
    #[Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_1
    #...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_connection}

Send trigger 2929 command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 2929 command
    ${cmd_trigger_2929}    Set Variable  echo "/SfpInfo action sfp_override_gpio 1 SIGNAL_LOSS true"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_2929}    connection=${connection}

Recovery RX LOS
    [Arguments]    ${connection}=RU_1    ${asik_connection}=ASIK Master
    Log To Console    Recovery RX LOS
    Login frmon and create agent
	Cancel SFP oeveride gpio
	Read SFP info
	Terminate agent
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_1
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_connection}


Trigger Fault and check fault
    [Arguments]    ${expected_fault}=4698    ${warning_alarm}=none   ${connection}=GNB_OAM    ${asik_connection}=ASIK Master
    log to console    \nTrigger Fault ${expected_fault} and check fault
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    log to console    \nLogin radio
    Connect to RU With Allocated IP    ru_index=1   ru_alias=RU_1
    ...    asik_alias=${asik_connection}   connection=${connection}
    Login frmon and create agent
    ${output_tmp}    Read SFP info
    Send trigger expected command    faultid=${expected_fault}    warning_alarm=${warning_alarm}
    ${output}    Read SFP info
	${fault}    Set Variable    ${expected_fault}
	Run keyword if   '${fault}'=='4699' or '${fault}'=='4700' or '${fault}'=='4701'    sleep    45s
	...   ELSE    sleep    15s
    Collect raw fault in radio history
    Run keyword if   '${fault}'=='4698'    Set test variable    ${source}    MRBTS-${btsid}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1
	...   ELSE    Set test variable    ${source}    MRBTS-${btsid}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1/LANE_R-1
    Run keyword if   '${warning_alarm}'=='warning'    Set severity and alarmid for warnig
	Run keyword if   '${warning_alarm}'=='alarm'    Set severity and alarmid for alarm
    Run keyword if   '${fault}'=='4698' or '${fault}'=='4699' or '${fault}'=='4700' or '${fault}'=='4701'
    ...    CB009226_common_keywords.Expect Fault Should Present    id=${fault}    source=${source}    severity=${severity}    alarmId=${alarmId}
    Run keyword if   '${fault}'=='sync_lost'    Check If there is expected fault    faultid=${expected_fault}
    Run keyword if   '${fault}'=='2928' or '${fault}'=='2929' or '${fault}'=='2930'
	...    Check if these is R&D fault    faultid=${expected_fault}
    [Teardown]    Run Keyword And Ignore Error    Recovery and check    expected_fault=${expected_fault}


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
    Run keyword if   '${faultid}'=='2928'    Send trigger 2928 command
    Run keyword if   '${faultid}'=='2929'    Send trigger 2929 command
    Run keyword if   '${faultid}'=='2930'    Send trigger 2930 command
	Run keyword if   '${faultid}'=='sync_lost'    Send trigger sync_lost command

Send trigger 4699 command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4699 command
    ${cmd_trigger_4699}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x04"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4699}    connection=${connection}


Recovery fault
    [Arguments]    ${cancel_fault}
    Log To Console    Recovery fault
    Run keyword if   '${cancel_fault}'=='4698' or '${cancel_fault}'=='4699' or '${cancel_fault}'=='4700' or '${cancel_fault}'=='4701'
    ...    Cancel SFP oeveride memory
    Run keyword if   '${cancel_fault}'=='2928' or '${cancel_fault}'=='2929'    Cancel SFP oeveride gpio
    Run keyword if   '${cancel_fault}'=='2930'    Cancel 2930
    Run keyword if   '${cancel_fault}'=='sync_lost'    Cancel SYNC LOST
    Wait until keyword succeeds    3min    5s    Verify all cells should be onair    connection=GNB_OAM

Send trigger 4699 alarm command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4699 alarm command
    ${cmd_trigger_4699}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x04"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4699}    connection=${connection}

Send trigger 4699 warning command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4699 warning command
    ${cmd_trigger_4699}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x74 DATA 0x04"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4699}    connection=${connection}


Send trigger 4700 alarm command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4700 alarm command
    ${cmd_trigger_4700}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x01"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4700}    connection=${connection}

Send trigger 4700 warning command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4700 warning command
    ${cmd_trigger_4700}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x74 DATA 0x01"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4700}    connection=${connection}

Send trigger 4701 alarm command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4701 alarm command
    ${cmd_trigger_4701}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x71 DATA 0x40"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_4701}    connection=${connection}

Send trigger 4701 warning command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 4701 warning command
    ${cmd_trigger_4701}    Set Variable  echo "/SfpInfo action sfp_override_memory 1 PAGE PAGE_1 0x75 DATA 0x40"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_4701}    connection=${connection}

Send trigger 2928 command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 2928 warning command
    ${cmd_trigger_2928}    Set Variable  echo "/SfpInfo action sfp_override_gpio 1 TX_FAULT true"|frmonShellClient 127.0.0.1 2000
    csn.execute    command=${cmd_trigger_2928}    connection=${connection}


Send trigger 2929 alarm command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 2929 alarm command
    ${cmd_trigger_2929}    Set Variable  echo "/SfpInfo action sfp_override_gpio 1 SIGNAL_LOSS true"|frmonShellClient 127.0.0.1 2000
	csn.execute    command=${cmd_trigger_2929}    connection=${connection}

Collect raw fault in radio history
    [Arguments]    ${connection}=RU_1
    log to console    \nCollect raw fault in radio history
    ${cmd_collect}    Set Variable  cat /ram/fault_history_log_temp.txt
    ${raw_fault_output}  csn.execute  command=${cmd_collect}    connection=${connection}
    [Return]    ${raw_fault_output}


Send trigger 2930 command
    [Arguments]    ${connection}=RU_1
    log to console    \nSend trigger 2930 command
    ${cmd_trigger_2930}    Set Variable  sudo ifconfig arb0p0 down
	csn.execute    command=${cmd_trigger_2930}    connection=${connection}
	[teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=RU_1

Send trigger sync_lost command
    log to console    \nSend trigger synclost alarm command
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    parameter=topDomainNumber
    ...    value=43
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Cancel SYNC LOST
    log to console    \nCancel SYNC LOST
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    parameter=topDomainNumber
    ...    value=24
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Cancel 2930
    [Arguments]    ${connection}=RU_1
    log to console    \nCancel 2930
    ${cmd_trigger_2930}    Set Variable  sudo ifconfig arb0p0 up
	csn.execute    command=${cmd_trigger_2930}    connection=${connection}

Wait time after triggering fault
    [Arguments]    ${faultid}
    log to console    \nWait time after triggering fault
    Run keyword if   '${faultid}'=='4699' or '${faultid}'=='4700' or '${faultid}'=='4701'    sleep    30s
    else if   '${faultid}'=='4699' or '${faultid}'=='4700' or '${faultid}'=='4701'    sleep    30s

Case teardown
    log to console    \nCase teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    Run Keyword And Ignore Error    csn.disconnect    connection=GNB_OAM
    Run Keyword And Ignore Error    csn.disconnect    connection=RU_1

Recovery and check
    [Arguments]    ${expected_fault}
    log to console    \nRecovery and check
    Run Keyword And Ignore Error    Recovery fault    cancel_fault=${expected_fault}
    ${fault_output}    Collect raw fault in radio history
    Set test variable    ${fault_output}
    Run Keyword And Ignore Error    Terminate agent
	Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
	Run Keyword And Ignore Error    csn.disconnect    connection=RU_1
    Run Keyword And Ignore Error    csn.disconnect    connection=GNB_OAM

Check fault
    [Arguments]    ${faultid}
    log to console    \nCheck fault
    Run keyword if   '${faultid}'=='4698' or '${faultid}'=='4699' or '${faultid}'=='4700' or '${faultid}'=='4701' or '${faultid}'=='sync_lost'
	...    Check If there is expected fault    faultid=${faultid}
    Run keyword if   '${faultid}'=='2928' or '${faultid}'=='2929' or '${faultid}'=='2930'
	...    Check if these is R&D fault    faultid=${faultid}

Check if these is R&D fault
    [Arguments]    ${faultid}=4698
    Log To Console    Check if these is R&D fault
	set test variable    ${is_alarm_visible}    False
    Connect to gnb coam via ssl
	CB009226_common_keywords.Catch Snapshot COAM    faultid=${faultid}
	Get snapshot and check R&D fault    faultid=${faultid}
    run keyword if     '${is_alarm_visible}'=='False'     FAIL

Collect snapshot log
    log to console     collect snapshot log
    ${local_file_path}    Catch Snapshot COAM    connection=GNB_OAM
    Set Suite Variable    ${local_file_path}

Catch Snapshot COAM
    [Timeout]   30m
    [Arguments]   ${faultid}=2928    ${local_file_path}=None   ${filename}=${EMPTY}    ${connection}=GNB_OAM
    log to console    Catch Snapshot COAM
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${local_file_path}   Set Variable If
    ...   '${local_file_path}'=='None'   ${OUTPUT_DIR}/snapshot_coam_fault${faultid}_${filename}_${curr_data}.zip
    ...   ${true}   ${local_file_path}
    Run Keyword And Ignore Error   coam.get_snapshot   target_file_name=${local_file_path}   timeout=${2100}   connection=${connection}
    Set Suite Variable    ${local_file_path}
    [Return]   ${local_file_path}

Get snapshot and check R&D fault
    [Arguments]   ${faultid}=2928
    log to console    Get snapshot and check R&D fault
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_fault}    ${unzipped}
    csn.connect_to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.execute    command=unzip -o ${local_file_path} -d ${unzipped}    connection=ute
    ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    file_folder=/home/ute/Downloads/s${time}/
	${raw_alarm_folder}    ${key_Raw_alarm}    snapshot_files.get_file_from_snapshot_by_key
    ...    key_name=${raw_alarm}    snapshot_structure=${FILE_STRUCT}
    OperatingSystem.Run    cd /home/ute/Downloads/s${time}/;unzip -d bts_${faultid} ${raw_alarm_folder}
	OperatingSystem.Run    mkdir /home/ute/Downloads/fault
    OperatingSystem.Run    cd /home/ute/Downloads/s${time}/bts_${faultid}/;cp ${key_Raw_alarm} /home/ute/Downloads/fault
    OperatingSystem.Run    cd /home/ute/Downloads/fault/;xz -d ${key_Raw_alarm}
	OperatingSystem.Run    cd /home/ute/Downloads/fault/;cp ${raw_alarm} ${faultid}_${raw_alarm}
    OperatingSystem.Run    cd /home/ute/Downloads/fault/;rm -rf ${raw_alarm}
    ${fault_dict}    get_faults_list    fault_file_path=/home/ute/Downloads/fault/${faultid}_${raw_alarm}
    ${result}    Get From Dictionary    dictionary=${fault_dict}    key=Active faults
	OperatingSystem.Run    rm -rf /home/ute/Downloads/fault/
	OperatingSystem.Run    rm -rf /home/ute/Downloads/*
    should contain    container=${result}   item=${faultid}
    set test variable    ${is_alarm_visible}    True

Delete snapshot
    [Arguments]    ${local_file_path}=${local_file_path}   ${unzipped}=${unzipped}
    log to console    Delete snapshot
    #run  rm -rf ${local_file_path}
    run  rm -rf ${local_file_path}
    run  rm -rf ${unzipped}
    #run  rm -rf ${unzipped}/${raw_alarm}

Set severity and alarmid for warnig
	Set test variable    ${severity}    Minor
	Set test variable    ${alarmid}    7115

Set severity and alarmid for alarm
	Set test variable    ${severity}    Major
	Set test variable    ${alarmid}    7100

Expect Fault Should Present
    [Arguments]    ${id}=4699    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    log to console    \nExpect ${id} Should Present
    ${faultId}    Convert To Integer    ${id}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        Exit For Loop If    ${alarm_num}==${0}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...                  Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
        ...                  Run Keyword If    '${source}'!='${None}'
        ...                  Should Contain    ${alarm['notifier']}    ${source}    case_insensitive=True    AND
        ...                  Run Keyword If    '${severity}'!='${None}'
        ...                  Should Contain    ${alarm['severity']}    ${severity}    case_insensitive=True    AND
        ...                  Run Keyword If    '${alarmId}'!='${None}'
        ...                  Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}
        Exit For Loop If    ${present_status}
    END
	Run Keyword If    ${present_status}==${False}    CB009226_common_keywords.Catch Snapshot COAM    faultid=${id}
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.