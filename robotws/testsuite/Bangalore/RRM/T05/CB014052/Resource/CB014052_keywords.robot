*** Settings ***
Documentation     CB014052 keywords file

Library     ta5g_pm_counters
Library     taf.sbts.oam.coam.admin         WITH NAME    admin
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core    WITH NAME    core
Library      taf.collectors.tshark        WITH NAME    tshark

Resource        ../../resources/Keywords/gnb_Keywords.robot
Resource        ../../resources/Keywords/generic_kw.robot
Resource    	../../resources/Keywords/configuration_id.robot

*** Variables ***
${SYSLOG_FlAG1}=        0x1003F=2
${SYSLOG_FlAG2}=        0x10040=2
${SYSLOG_FlAG3}=        0x10041=5
@{swconfig_flags}    ${SYSLOG_FlAG1}   ${SYSLOG_FlAG2}    ${SYSLOG_FlAG3}
${EGATE_PORT}=          20000
${EDAEMON_PORT}=        10000
${GNB_PASSWORD}			oZPS0POrRieRtu
${GNB_USERNAME}			toor4nsn
${GNB_IP}				192.168.255.129

*** Keywords ***
Setup testline with yaml
	[Arguments]		${cus_yaml}		${scfc}
    Add RD Parameters Directly On GNB      ${SYSLOG_FlAG1}
    Add RD Parameters Directly On GNB      ${SYSLOG_FlAG2}
    Add RD Parameters Directly On GNB      ${SYSLOG_FlAG3}
	Add Simulator   sim_type=cus    config=${cus_yaml}
    Add Enb Configuration           scfc=${scfc}
    Configure environment

Stop Default Logging For CUS And Compress Test Logs
    Run UEx command    ue_detach  all

Prepare Testcase
	[Arguments]		${Testcase}
    Start Syslog     ${OUTPUT_DIR}/${Testcase}/btslog   SYSLOG_2.LOG
    Log to Console    \nSyslog started
    Monitor Alarm
    taf.ul.alarms_watchdog.get_active_alarms
	Create UE Alias    UE_1    ue_id=1    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
	#Wait For Next Raw Pm Interval
	Start pcap collection      name=${Testcase}

Start pcap collection
    [Documentation]    Start Pcap collection
    [Arguments]    ${name}=Tcpdump    ${options}=-i eth4
    tcpdump.Create Tcpdump Collector
    ...     name=${name}
    ...     options=${options}
    core.Setup Collectors    names=${name}
    core.Start Collectors    names=${name}
    tcpdump.Set test Alias    ${name}
    Log to Console    \nWireshark started

Stop pcap collection
    [Arguments]     ${name}   ${Testcase}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${OUTPUT_DIR}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable   ${OUTPUT_DIR}/${Testcase}/${name}.pcap
    Log to Console    \nWireshark stopped
	[Return]     ${pcap_file_path}

Site Reset For Gnb
    [Documentation]     This keyword is used to Site Reset
    Log to Console    \n site reset is started
    admin.Setup Admin
    admin.reset_site      reset_coverage=Site     wait_for_reconnection=True    graceful_cell_shutdown=True
    [Teardown]      admin.Teardown Admin

Teardown testcase
	[Arguments]		${Testcase}
    Log to Console    \n Teardown is started
	Stop pcap collection   ${Testcase}    ${Testcase}
    Run keyword and ignore error    syslog validation for error prints
    Collect Syslog Results                destination=${OUTPUT_DIR}/${Testcase}/btslog
    check_detected_alarms
    taf.ul.alarms_watchdog.get_active_alarms
    stop_watching_alarms
    Collect Snapshot    ${OUTPUT_DIR}/${Testcase}     Snapshot
	configuration_id.Link SCOUT SCF to Configuration ID for Reporting

Accepted_alarm_list
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled
    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled
    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled
    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443
    ${allowed_alarm_6}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4592
    ...                    fault_name=BTS Reset Cause
    ${allowed_alarm_7}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4681
    ...                    fault_name=Diagnostic Check Error
    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}
    ...                    ${allowed_alarm_6}
    ...                    ${allowed_alarm_7}
    [Return]    ${allowed_alarms}

Monitor Alarm
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms
    ${allowed_alarms}=      Accepted_alarm_list
    Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=oam

syslog validation for error prints
#    ${my_list}=    Create List    ERR/    Fatal
    Wait for message in syslog file       regexp=ERR/    timeout=1min 5s
    Message should exist in syslog file     regexp=ERR/
    ${result}   Count syslog messages       regexp=ERR/
    Should Be True    "${result}" == "0"

Add RD Parameters Directly On GNB
    [Arguments]    ${rd_parametrs}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
        Continue For Loop If    '${item}'=='${EMPTY}'
        ${cmd}    Set Variable    echo "${item}" >> /ffs/run/swconfig.txt
        Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} '${cmd}'
    END
    Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} 'crasign /ffs/run/swconfig.txt'
