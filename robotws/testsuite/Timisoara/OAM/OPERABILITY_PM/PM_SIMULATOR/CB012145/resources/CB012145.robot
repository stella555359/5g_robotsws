*** Settings ***
Documentation
...    Author: Andreea-Oana Zaharia (iandreea-oana.zaharia@nokia.com)
...    Maintainer: Andreea-Oana Zaharia (iandreea-oana.zaharia@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_OPERABILITY_PM_GMS
...    References: doors
...    Feature Description: CB012145
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/CB012145/path.robot

Library        String
Library        Telnet
Library        BuiltIn
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn


Resource    ../../../../ET/BOAM_VERIF_ET2/resources/pretest_posttest.robot
Resource    ../../../../ET/BOAM_VERIF_ET2/resources/system.robot
Resource    ../../../../ET/BOAM_VERIF_ET2/resources/AirPhone/resources/ute/ute_wts_runner.robot

*** Variables ***
${dist_name}=                           MRBTS-1/NRBTS-1/NRCELL-1
${rtpm_enabled}=                        ${CURDIR}/rtpm_enabled.json
${rtpm_meas_first100}=                  ${CURDIR}/rtpm_meas_first100.json
${rtpm_meas_last}=                      ${CURDIR}/rtpm_meas_last.json
${rtpm_meas}=                           ${CURDIR}/rtpm_meas.json
${sl_cell}=                             ${CURDIR}/sl_cell.json
${actKpiAlarms_only}=                   ${CURDIR}/actKpiAlarms_only.json
${kpi}=                                 ${CURDIR}/kpi_enabled.json
${reportingInvervalPm_5min}=            ${CURDIR}/reportingIntervalPm_5min.json
${bts_log}                              /tmp/btslog2


*** Keywords ***
CB012145_PM_SIMULATOR_and_RTPM_enabled
    log to console    activate reportingIntervalPm to 5 min
    ADMIN Perform Delta Recommissioning                 delta_file=${reportingInvervalPm_5min}
    ...                                                 skip_parameter_relation_errors=True
    log to console    activate RTPM parameters
    ADMIN Perform Delta Recommissioning                 delta_file=${rtpm_enabled}
    ...                                                 skip_parameter_relation_errors=True
    log to console     sleep for 1 min
    sleep    60
    log to console    activate RTPM measurements
    ADMIN Perform Delta Recommissioning                 delta_file=${rtpm_meas_first100}
    ...                                                 skip_parameter_relation_errors=True
    log to console     sleep for 1 min
    sleep    60
    ADMIN Perform Delta Recommissioning                 delta_file=${rtpm_meas_last}
    ...                                                 skip_parameter_relation_errors=True
    log to console     sleep for 1 min
    sleep    60
    log to console    check in syslog if debug logs exists
    Check in syslog if debug logs exists
#   Check in syslog if measurement is activated to 5 min reporting interval
    Wait to nearest 15 min measurement period
    Sleep   30
    log to console    Collect PM files
    SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.raw.gz*.xml.gz
        ...    current_path=/tmp
        ...    current_name=
    Get XML PM File From BTS
##   Check in syslog if measurements are reported 1 min interval
    Check if counters are available in PM.BTS xml files

CB012145_PM_SIMULATOR_and_SLEEPING_CELL_enabled
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
    log to console    Activate reportingIntervalPm to 5 min
    ADMIN Perform Delta Recommissioning                 delta_file=${reportingInvervalPm_5min}
    ...                                                 skip_parameter_relation_errors=True
    log to console    Activate counter AoM parameter
#to be configured
    log to console    Activate sleeping_cell parameters
    ADMIN Perform Delta Recommissioning                 delta_file=${sl_cell}
    ...                                                 skip_parameter_relation_errors=True
    log to console     Sleep for 60s
    sleep    60
    log to console    Check in syslog if debug logs exists
    Check in syslog if debug logs exists
#    Check in syslog if measurement is activated to 5 min reporting interval
    Wait to nearest 15 min measurement period
    Sleep   30
    log to console    Collect PM files
    SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.raw.gz*.xml.gz
        ...    current_path=/tmp
        ...    current_name=
    Get XML PM File From BTS
##   Check in syslog if measurements are reported 1 min interval
    Check if counters are available in PM.BTS xml files

CB012145_PM_SIMULATOR_and_KPI_enabled
    log to console    activate reportingIntervalPm to 5 min
    ADMIN Perform Delta Recommissioning                 delta_file=${reportingInvervalPm_5min}
    ...                                                 skip_parameter_relation_errors=True
    log to console     activate KPI parameters
    ADMIN Perform Delta Recommissioning
    ...             delta_file=${kpi}
    ...             skip_parameter_relation_errors=True
    log to console    block cell
    ADMIN Lock Cell   ${dist_name}
    sleep  10
    log to console    wait for 49 and 4570 faults to be raised
    ADMIN Check If Alarm Is Active With Timeout  fault_id=49  timeout=15
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4570  timeout=500
    sleep  80
    log to console     unblock cell
    ADMIN Unlock Cell   ${dist_name}
    log to console     check that 49 and 4570 faults are cleared
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=49  timeout=15
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4570  timeout=15
    Wait Until Keyword Succeeds   600    10    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait to nearest 5 min measurement period
    Sleep   30
    log to console    Collect PM files
    SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.raw.gz*.xml.gz
        ...    current_path=/tmp
        ...    current_name=
    Get XML PM File From BTS
##   Check in syslog if measurements are reported 1 min interval
    Check if counters are available in PM.BTS xml files



Check in syslog if debug logs exists
    Run   cat /tmp/btslog2/SYSLOG* > /tmp/btslog2/SYSLOG_concatenate.log
     ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "DBG/PMStat"
    Should contain   ${syslog}   DBG/PMStat

Check in syslog if measurement is activated to 5 min reporting interval
    Run   cat /tmp/btslog2/SYSLOG* > /tmp/btslog2/SYSLOG_concatenate.log
    ${syslog}   OperatingSystem.Run
    ...    command=cat ${bts_log}/'SYSLOG_concatenate.log' | grep "[showMeasTypeMap] measType: 55306 interval: 5"
    Should contain   ${syslog}     [showMeasTypeMap] measType: 55306 interval: 5


Remove PM files from ENB RAM folder
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.xml.gz
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.raw.gz

Clear PM file from ENB TMP folder
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.xml.gz
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.raw.gz

Wait to nearest 5 min measurement period
	Log To Console  Wait to nearest 5 min measurement period
	Wait Until Keyword Succeeds  6 min  1 min  wait for right period of 5min

wait to nearest 15 min measurement period
	Log To Console  Wait to nearest 15 min measurement period
	Wait Until Keyword Succeeds  16 min  1 min  wait for right period of 15min

wait for right period of 5min
	${list}=    Create List  00  05  10  15  20  25  30  35  40  45  50  55
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpoch}= 	Convert Date	${date} ${actualHour}:${actualTime}:00.000	epoch
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}
	Set Global Variable    ${actualEpoch}

wait for right period of 15min
	${list}=    Create List  00  15  30  45
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpoch}= 	Convert Date	${date} ${actualHour}:${actualTime}:00.000	epoch
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}
	Set Global Variable    ${actualEpoch}

Get XML PM File From BTS
    log to console     Get XML PM File From BTS
    ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=eNB
    ${xml_counters_list}=    ssh.execute    ls /tmp/ | grep PM\.BTS.*\.xml\.gz | sort -r    connection=eNB
    ${last_xml_counter}=    String.Get Line    ${xml_counters_list}    0
    ssh.Download File   /ram/${last_xml_counter}    /tmp/${last_xml_counter}    connection=eNB
    run keyword and ignore error    ssh.disconnect    connection=eNB
    Run    gzip -d /tmp/${last_xml_counter}
    ${xml_counter_unzipped}=    String.Fetch From Left    ${last_xml_counter}    .gz
    [Return]     ${xml_counter_unzipped}
    set test variable    ${xml_counter_unzipped}


Check if counters are available in PM.BTS xml files
    log to console    check for a specific counter in PM.BTS XML file
     ${present_counter}    OperatingSystem.Run
    ...    command=cat /tmp/${xml_counter_unzipped} | grep M55306
    Should contain   ${present_counter}   M55306
    log to console    Get total number of measurements from PM.BTS XML file
    ${total_counters}   OperatingSystem.Run
    ...    command=grep -e "<M" ${xml_counter_unzipped} | grep -iv "MO dim"| wc -l
    [Return]     ${total_counters}
