*** Settings ***
Documentation
...    Author: Ioana Sandu (ioana.sandu-andrei@nokia.com)
...    Maintainer: Ioana Sandu (ioana.sandu-andrei@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002056-AZ_5GC000499
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/55GC002056-AZ_5GC000499/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn
#Library        Selenium2Library
Library        DateTime
#Library        system.robot
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    ssh


Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      developer
${CUSTOMER_PASSWORD}=                   $developer#
${WebEM IP}                             https://192.168.255.1:3600
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password


${TIMEOUT_STATUS_MESSAGES}       10
${TIMEOUT_COLLECTION_COMPLETED}  1000
${DIR_DOWNLOADS}                 /home/ute/Downloads
${DIR_RESULTS}                   /home/ute/results
${DIR_UNZIP}                     ${DIR_RESULTS}
${SNAPSHOT_FILE_NAME_BEGINNING}  Snapshot_MRBTS-1_
${SNAPSHOT_FILE_NAME}            ${SNAPSHOT_FILE_NAME_BEGINNING}*.zip
${METADATA_FILE_NAME}            BTS1_*_metadata.txt
${BTS_PART_DIRS}                 BTS*part*
${FileNumber}           		 15
${keyword}=                      5G
@{log_file_names}                FileList_SWDownload_Start.xz  FileList_SWDownload_End.xz

${delta_file_reportingIntervalPm_5min}=          ${CURDIR}/../resources/PM_interval_5min.json
${delta_file_reportingIntervalPm_15min}=         ${CURDIR}/../resources/PM_interval_15min.json
${delta_file_reportingIntervalPm_30min}=         ${CURDIR}/../resources/PM_interval_30min.json
${delta_file_reportingIntervalPm_60min}=         ${CURDIR}/../resources/PM_interval_60min.json
${delta_file_initial_config}=                    ${CURDIR}/../resources/initial_config.json


*** Keywords ***
Check if PM files are generated every 5 minutes
        log to console  verify PM counters reports for 5 minutes interval
        log to console  delta commissioning
        sleep  60
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
        Sleep   10
        Remove PM files from ENB
        Clear PM file from tmp
        log to console   sleep 13min
        Sleep   13min
        log to console   get PM files
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=
        Verify PM counters reports for 5 minutes interval

Verify if raw PM files are available for each measurement type
        log to console  verify PM counters reports for 5 minutes interval
        log to console  delta commissioning
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
        Log To Console   Remove PM files from ENB
        Remove PM files from ENB
        Clear PM file from tmp
        log to console   sleep 60
        Sleep  300
        Wait to nearest 5 min measurement period
        Sleep   30
        log to console   get PM files
       SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.raw.gz*.raw.gz
        ...    current_path=/tmp
        ...    current_name=
 #       Get Raw PM File From BTS
        Get xml and raw PM files 2
        Log To Console  verify PM counters reports for 15 minutes interval
        Log To Console   Remove PM files from ENB
        Clear PM file from tmp
        Remove PM files from ENB
        log to console   delta commissioning
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_15min}
        ...                                                 skip_parameter_relation_errors=True
        log to console   sleep 60
        Sleep   60
        wait to nearest 15 min measurement period
        Sleep   30
        log to console  get PM files
#        Get Raw PM File From BTS
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.raw.gz*.raw.gz
        ...    current_path=/tmp
        ...    current_name=
        Get xml and raw PM files 2
        Log To Console  verify PM counters reports for 30 minutes interval
        Log To Console   Remove PM files from ENB
#        Clear PM file from tmp
#        Remove PM files from ENB
        log to console   delta commissioning
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_30min}
        ...                                                 skip_parameter_relation_errors=True
        log to console   sleep 60
        Sleep   30
        wait to nearest 30 min measurement period
        Sleep   10
        log to console  get PM files
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.raw.gz*.raw.gz
        ...    current_path=/tmp
        ...    current_name=
        Get xml and raw PM files 2
        Log To Console  verify PM counters reports for 60 minutes interval
        Log To Console   Remove PM files from ENB
        Clear PM file from tmp
        Remove PM files from ENB
        log to console   delta commissioning
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_60min}
        ...                                                 skip_parameter_relation_errors=True
        log to console   sleep 60
        Sleep   30
        wait to nearest 60 min measurement period
        Sleep   10
        log to console  get PM files
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.raw.gz*.raw.gz
        ...    current_path=/tmp
        ...    current_name=
        Get xml and raw PM files 2
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_initial_config}
        ...                                                 skip_parameter_relation_errors=True

Remove PM files from ENB
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.xml.gz
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.raw.gz


Clear PM file from tmp
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.xml.gz
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.raw.gz

Wait next hourly report is done
   	Log To Console  Wait next hourly report is done
	Wait Until Keyword Succeeds	61 min	1 min  Wait to hour change
	sleep  60

Wait to nearest 5 min measurement period
	Log To Console  Wait to nearest measurement period
	Wait Until Keyword Succeeds  6 min  1 min  wait for right period of 5min
wait to nearest 15 min measurement period
	Log To Console  Wait to nearest measurement period
	Wait Until Keyword Succeeds  16 min  1 min  wait for right period of 15min

wait to nearest 30 min measurement period
	Log To Console  Wait to nearest measurement period
	Wait Until Keyword Succeeds  31 min  1 min  wait for right period of 30min

wait to nearest 60 min measurement period
	Log To Console  Wait to nearest measurement period
	Wait Until Keyword Succeeds  61 min  1 min  Wait to hour change
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

wait for right period of 30min
	${list}=    Create List  00  30
	${actualTimefor30min}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHourfor30min}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpochfor30min}= 	Convert Date	${date} ${actualHourfor30min}:${actualTimefor30min}:00.000	epoch
	List Should Contain Value	${list}  ${actualTimefor30min}
	Log  ${actualTimefor30min}
	Set Global Variable    ${actualTimefor30min}
	Set Global Variable    ${actualHourfor30min}
	Set Global Variable    ${actualEpochfor30min}


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

Get xml and raw PM files 2
    #OperatingSystem.Get File       /ram/PM.BTS-1.*.*.*.xml.gz      /tmp/
    #OperatingSystem.Get File      /ram/PM.BTS-1.*.*.*.raw.gz      /tmp/
    ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=eNB
    ${raw_counters_list}=    ssh.execute    ls /tmp/ | grep PM\.BTS.*\.raw\.gz | sort -r    connection=eNB
    ${xml_counters_list}=    ssh.execute    ls /tmp/ | grep PM\.BTS.*\.xml\.gz | sort -r    connection=eNB
    ${last_raw_counter}=    String.Get Line    ${raw_counters_list}    0
    ssh.Download File   /ram/${last_raw_counter}    /tmp/${last_raw_counter}    connection=eNB
    ${last_xml_counter}=    String.Get Line    ${xml_counters_list}    0
    ssh.Download File   /ram/${last_xml_counter}    /tmp/${last_xml_counter}    connection=eNB
    run keyword and ignore error    ssh.disconnect    connection=eNB
    ${raw_file}=   Run  ls /tmp/PM.BTS-1.*.*.*.raw.gz
    log to console   ${raw_file}
    ${split_raw}=   Split string    ${raw_file}    separator=\.
    ${time_raw}=  Get From List  ${split_raw}  3
    ${int_time_raw}=   convert to integer  ${time_raw}


    ${xml_file}=   Run  ls /tmp/PM.BTS-1.*.${time_raw}.*.xml.gz
    log to console    ${xml_file}
    ${split_xml}=   Split string    ${xml_file}    separator=\.
    ${time_xml}=  Get From List  ${split_xml}  3
    ${int_time_xml}=   convert to integer    ${time_xml}

    ${delta_files_2}=   Evaluate    ${int_time_raw}-${int_time_xml}
    Should Be True  '${delta_files_2}' == '0'
    ...  msg=wrong value for PM interval.

Verify PM counters reports for 5 minutes interval
#    Log To Console  verify PM counters reports for 5 minutes interval
#    Log To Console   Remove PM files from ENB
#    Execute Command On Enb  cmd=rm /ram/PM.BTS-10191.*.*.*.xml.gz
#    Execute Command On Enb  cmd=rm /ram/PM.BTS-10191.*.*.*.raw.gz
#    log to console   sleep 13min
#    Sleep   13min
##    log to console   get PM files
##    Get Enb File       /ram/PM.BTS-10191.*.*.*.xml.gz      /tmp/
#    ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=eNB
    #ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=eNB
    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.*
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${second_PM_file}=  Get From List  ${list_of_PM_files}  1
    ${time_first_PM_file}=   Get Substring    ${first_PM_file}    25    27
    ${time_second_PM_file}=   Get Substring    ${second_PM_file}    25    27
    ${delta_files}=   Evaluate    ${time_second_PM_file}-${time_first_PM_file}
    Should Be True  '${delta_files}' == '5'
    ...  msg=wrong value for PM interval.

Get Raw PM File From BTS
    ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=eNB
    ${raw_counters_list}=    ssh.execute    ls /tmp/ | grep PM\.BTS.*\.raw\.gz | sort -r    connection=eNB
    ${last_raw_counter}=    String.Get Line    ${raw_counters_list}    0
    ssh.Download File   /ram/${last_raw_counter}    /tmp/${last_raw_counter}    connection=eNB
    run keyword and ignore error    ssh.disconnect    connection=eNB
    Run    gzip -d /tmp/${last_raw_counter}
    ${raw_counter_unzipped}=    String.Fetch From Left    ${last_raw_counter}    .gz
    [Return]    /tmp/${raw_counter_unzipped}

Wait to hour change
    [Documentation]
    ...   Author: Tomasz Pietruszkiewicz
	${list} =	Create List	00
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}
