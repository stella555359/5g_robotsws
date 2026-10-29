*** Settings ***
Documentation
...    Copyright 2017 Nokia Solutions and Networks. All rights reserved.
...    Author: Zhao Liping (liping.zhao@nokia-sbell.com)
...    FT in charge: Dev BJ2 FT11

Library        OperatingSystem

*** Keywords ***
Pre test actions for core dump process
    Setup admin    bts_host=192.168.255.129
	...            bts_port=443
	...            use_ssl=True
	#admin_infomodel_meta.Setup and connect to infomodel
    #OAM_Common.Start syslog for 'enb_syslog' and 'iphy_syslog'
    Disable flag "Autonomous reset disabled" in swconfig
    Run Keyword If    '${flag_present}'!='0'    Perform eNB reboot and wait for commissioned state

Perform eNB reboot and wait for commissioned state
	Reboot enb
    Sleep  60
    Wait until eNB reaches commissioned state

Post test actions for core dump process
	Sleep    60s
#	Save Snapshot to result folder
	Teardown admin
#    Teardown Enb Fsm Access
	#admin_infomodel_meta.Stop infomodel
	#OAM_Common.Stop syslog for 'enb_syslog' and 'iphy_syslog'
#    Stop infomodel and syslogs (enb 'enb_syslog', iphy 'iphy_syslog')
#    Setup Btssm  log_path=${OUTPUT DIR}/${SUITE NAME}/
    Run  sudo chmod -R 777 /tmp/
    run keyword and ignore error  OperatingSystem.Move file  /tmp/Snapshot*  ${OUTPUT_DIR}/${SUITE_NAME}
#    Teardown Btssm

Check in SiteConf if BTS has correct states regarding to recovery process
    Get Siteconf File From eNB  /tmp/SiteConf_recovery.xml
    Check if '_operationalState' of all cells is 'disabled'
    Check if operational status of the BTS is 'Commissioned|Configured|IntegratedToRAN'

Kill process '${process_name}' on FCT
    #setup enb fsm access
    ${process_pid}=   execute command on enb    ps -ef | grep -i "${process_name}" | egrep -v "grep|bash" | awk '{print $2}'
    execute command on enb   kill -11 ${process_pid}
    #teardown enb fsm access

Kill process '${process_name}' on CCS
    ${process_pids}=   execute command on enb    ps -ef | grep -i "${process_name}" | egrep -v "grep|bash" | awk '{print $2}'
    ${split}=    Split string        ${process_pids}    separator=\
    ${process_pid}=   Get from list         ${split}     0
    execute command on enb   kill -9 ${process_pid}

Check condition before kill process
  #  ute_admin_infomodel.Query infomodel  query=count
  #..  /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-*/SMOD_L-1/CCU_L-1/STORAGE_L-*/FILE_SYSTEM_L-*/CORE_DUMP_L-* is = 0  timeout=120

Check the process after collect snapshot
    #ute_admin_infomodel.Query infomodel  query=count /MRBTS-1/RAT-1/FRI-1/ALARM-* is [faultId=4527] = 0  timeout=600

Check the reset type '${reset_type}'
    ${line_-7_to_check}=   Evaluate     int(-7)
    Set Test Variable   ${line_-7_to_check}
    ${status}=   Run Keyword and Return Status   verify type of reset   /tmp/blackbox   ${reset_type}
    Run Keyword If  '${status}'=='True'   Evaluate   True
    Run Keyword If  '${status}'=='False'   verify type of reset   /tmp/blackbox   ${reset_type}     ${line_-7_to_check}

Start collecting BTS ping logs
    Run    ping 192.168.255.1 >> /tmp/ping_BTS.txt &

Check collected BTS ping logs and kill ping process
    ${check_host_unreachable}=      Grep File   /tmp/ping_BTS.txt   Destination Host Unreachable
    Run Keyword and Continue on Failure     Should Not Contain      ${check_host_unreachable}   Destination Host Unreachable
    Run    kill -9 ${ping_pid}
    Run    rm -f /tmp/ping_BTS.txt

Disable flag "Autonomous reset disabled" in swconfig
    Setup Enb Fsm Access
	${flag_present}=    Set Variable    0
    Set Test Variable    ${flag_present}
    Check if flag is present in swconfig

    Run Keyword If    '${status_swconfig_310001}'!=''    Hash flag in swconfig and check the change 0x310001
	Run Keyword If    '${status_swconfig_10077}'!=''    Hash flag in swconfig and check the change 0x10077
	Run Keyword If    '${status_swconfig_10079}'!=''    Hash flag in swconfig and check the change 0x10079
	Run Keyword If    '${status_swconfig_500001}'!=''    Hash flag in swconfig and check the change 0x500001
	Run Keyword If    '${status_swconfig_500002}'!=''    Hash flag in swconfig and check the change 0x500002

	Run    cat /tmp/swconfig.txt
    [Teardown]  Teardown Enb Fsm Access

Check if flag is present in swconfig
    Get Enb Swconfig File   /tmp/swconfig.txt
    ${status_swconfig_310001}=    Run    cat /tmp/swconfig.txt | grep -i '^0x310001'
	${status_swconfig_10077}=    Run    cat /tmp/swconfig.txt | grep -i '^0x10077'
	${status_swconfig_10079}=    Run    cat /tmp/swconfig.txt | grep -i '^0x10079'
	${status_swconfig_500001}=    Run    cat /tmp/swconfig.txt | grep -i '^0x500001'
	${status_swconfig_500002}=    Run    cat /tmp/swconfig.txt | grep -i '^0x500002'

    Set Test Variable    ${status_swconfig_310001}
	Set Test Variable    ${status_swconfig_10077}
	Set Test Variable    ${status_swconfig_10079}
	Set Test Variable    ${status_swconfig_500001}
	Set Test Variable    ${status_swconfig_500002}

Hash flag in swconfig and check the change ${flag}
    Get Enb Swconfig File   /tmp/swconfig.txt
    Run    sed -i 's/^${flag}/#${flag}/' /tmp/swconfig.txt
    Put Enb Swconfig File   /tmp/swconfig.txt

	Sleep  5
    Get Enb Swconfig File   /tmp/swconfig_2nd.txt
	${check_if_hashed}=    Run    cat /tmp/swconfig_2nd.txt | grep -i '^#${flag}'
	${flag_present}=    Evaluate    int(${flag_present} + 1)



