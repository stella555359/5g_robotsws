*** Settings ***
Documentation
...    Author: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Maintainer: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_OPERABILITY_PM_GMS
...    References: doors
...    Feature Description: CB012803
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/CB012803/path.robot

Library        String
Library        Telnet
Library        BuiltIn
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn

Library      ta5g_testline_management
#Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta
Library      ta_pcmd



Resource    ../../../../ET/BOAM_VERIF_ET2/resources/pretest_posttest.robot
Resource    ../../../../ET/BOAM_VERIF_ET2/resources/system.robot
Resource    ../../../../ET/BOAM_VERIF_ET2/resources/AirPhone/resources/ute/ute_wts_runner.robot
Resource    ../../resources/keywords.robot

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
${meas1}=                               ${CURDIR}/meas55332.json
${meas2}=                               ${CURDIR}/meas55316.json
${meas3}=                               ${CURDIR}/meas55112.json
${meas1_disabled}=                      ${CURDIR}/meas55332_disabled.json
${meas2_disabled}=                      ${CURDIR}/meas55316_disabled.json
${meas3_disabled}=                      ${CURDIR}/meas55112_disabled.json
${meas1_15min}=                         ${CURDIR}/meas55332_15min.json
${bts_log}                              /tmp/btslog2
${scf_default}=                        ${CURDIR}/scf_AZQJ.xml


*** Keywords ***
# TEST 1 ---------------------------------------------------------------------------------------------------------------
CB012803_Check_number_of_CONFIG_REQ
#activate RTPM and modify reportingint
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
#wait for next 5 min interval
    Wait to nearest 5 min measurement period
#disable AOM params
    log to console    disable AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1_disabled}
    ...                                                 skip_parameter_relation_errors=True
    log to console    disable AOM param: miNrCaDu(55316)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas2_disabled}
    ...                                                 skip_parameter_relation_errors=True
    log to console    disable AOM param: miNrX2CC(55112)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas3_disabled}
    ...                                                 skip_parameter_relation_errors=True
    log to console    sleep for 5 min
    sleep     300
#wait for next 5 min interval
    Wait to nearest 5 min measurement period
#check if measurement is disabled
    Check in syslog if measurements are disabled to 0 min reporting interval
#activate AOM params --> set to 5 min
    log to console    activate AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1}
    ...                                                 skip_parameter_relation_errors=True
    log to console    activate AOM param: miNrCaDu(55316)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas2}
    ...                                                 skip_parameter_relation_errors=True
    log to console    activate AOM param: miNrX2CC(55112)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas3}
    ...                                                 skip_parameter_relation_errors=True
    log to console    sleep for 5 min
    sleep     300
#wait for next 5 min interval
    Wait to nearest 5 min measurement period
    log to console     sleep for 1 min
    sleep    60
#check for 55332 meas in SYSLOG
    Check in syslog if measurements are activated to 5 min reporting interval


# TEST 2 ---------------------------------------------------------------------------------------------------------------
CB012803_Check_PM.BTS_for_measurement
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
#activate RTPM and modify reportingint
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
#disable AOM param 55332
    log to console    disable AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1_disabled}
    ...                                                 skip_parameter_relation_errors=True
#wait for next 5 min interval
    Wait to nearest 5 min measurement period

#activate measurement 55332 on 15 min
    log to console    activate AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1_15min}
    ...                                                 skip_parameter_relation_errors=True
#wait for PM.BTS
    Wait to nearest 15 min measurement period
#check for measurement
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
    Check if counters are available in PM.BTS xml files
#disable measurement to 0 min
    log to console    disable AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1_disabled}
    ...                                                 skip_parameter_relation_errors=True
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
#wait for PM.BTS
    Wait to nearest 15 min measurement period
#check for measurement
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
    Check if counters are not available in PM.BTS XML file

# TEST 3 ---------------------------------------------------------------------------------------------------------------
CB012803_Interval_small_to_big

#activate RTPM and modify reportingint
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
#remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
#ensureable measurement on 5 min
    log to console    activate AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1}
    ...                                                 skip_parameter_relation_errors=True
#wait 5 min
    Wait to nearest 5 min measurement period
#check PM.BTS for measurement
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
    Check if counters are available in PM.BTS xml files
#remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
#change measurement reporting int from 5 to 15 min
    log to console    activate AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1_15min}
    ...                                                 skip_parameter_relation_errors=True
#wait 5 min
    Wait to nearest 5 min measurement period
#ensure that measurement is only reported for 15 min interval
    #check PM.BTS for measurement
    Sleep     60
    Log to console     delete first PM file which may contain meas
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 360s
    Sleep   360
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
    Check if counters are not available in PM.BTS XML file
    #remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
    Wait to nearest 5 min measurement period
    #check PM.BTS for measurement
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
    Check if counters are not available in PM.BTS XML file
    #remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
    Wait to nearest 5 min measurement period
    #check PM.BTS for measurement
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
    Check if counters are available in PM.BTS xml files

# TEST 4 ---------------------------------------------------------------------------------------------------------------
CB012803_Interval_big_to_small

#activate RTPM and modify reportingint
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
#remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
#change measurement reporting int to 15 min
    log to console    activate AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1_15min}
    ...                                                 skip_parameter_relation_errors=True
    Sleep    600
#wait 5 min
    Wait to nearest 5 min measurement period
#ensure that measurement is only reported for 15 min interval
    #check PM.BTS for measurement
    Sleep   90
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
    Check if counters are not available in PM.BTS XML file
    #remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
    Wait to nearest 5 min measurement period
    #check PM.BTS for measurement
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
    Check if counters are not available in PM.BTS XML file
    #remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
    Wait to nearest 5 min measurement period
    #check PM.BTS for measurement
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
    Check if counters are available in PM.BTS xml files
#remove PM.BTS files
    Log To Console   Remove existing PM files from ENB
    Remove PM files from ENB RAM folder
    Clear PM file from ENB TMP folder
    log to console     PM files deleted - sleep 60s
    sleep    60
#change measurement from 15 min to 5 min
    log to console    activate AOM param: miNrEnDssPerCell(55332)
    ADMIN Perform Delta Recommissioning                 delta_file=${meas1}
    ...                                                 skip_parameter_relation_errors=True
#wait 5 min
    Wait to nearest 5 min measurement period
#check PM.BTS for measurement
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
    Check if counters are available in PM.BTS xml files


# TEST 5 ---------------------------------------------------------------------------------------------------------------
CB012803_Full_plan_commissioning
    FOR    ${i}    IN RANGE    3
        Log To Console    Iteration ${i}+1
    #disable AOM params
        log to console    disable AOM param: miNrEnDssPerCell(55332)
        ADMIN Perform Delta Recommissioning                 delta_file=${meas1_disabled}
        ...                                                 skip_parameter_relation_errors=True
        log to console    disable AOM param: miNrCaDu(55316)
        ADMIN Perform Delta Recommissioning                 delta_file=${meas2_disabled}
        ...                                                 skip_parameter_relation_errors=True
        log to console    disable AOM param: miNrX2CC(55112)
        ADMIN Perform Delta Recommissioning                 delta_file=${meas3_disabled}
        ...                                                 skip_parameter_relation_errors=True
        log to console    sleep for 5 min
        sleep     300
    #wait for next 5 min interval
        Wait to nearest 5 min measurement period
        Log To Console    Perform commissioning on BTS
            ADMIN Perform Commissioning
            ...     scf_file=${scf_default}
            ...     skip_parameter_relation_errors=True
            Sleep    10
            Wait Until Keyword Succeeds    900    30    admin_infomodel.ADMIN INFOMODEL Check If BTS Is Configured
            Start counter simulator
            Sleep    300
    #wait for next 5 min interval
        Wait to nearest 5 min measurement period
        log to console     sleep for 1 min
        sleep    60
    #check for 55332 meas in SYSLOG
        Check in syslog if measurements are activated to 5 min reporting interval
    END


*** Keywords ***
ADMIN INFOMODEL Check Parameter Value
    [Arguments]
    ...    ${dist_name}
    ...    ${dict_param}
    ...    ${value}
    ${dict_value}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name}
    ...    dict_param=${dict_param}
    ${dict_value}    Convert To String    ${dict_value}
    Should Match Regexp
    ...    string=${dict_value}
    ...    pattern=${value}

Wait to nearest 5 min measurement period
	Log To Console  Wait to nearest 5 min measurement period
	Wait Until Keyword Succeeds  6 min  1 min  wait for right period of 5min

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

Check in syslog if measurements are activated to 5 min reporting interval
    log to console    check syslog for measurements
    # Concatenate log files into one file
    Run Process    bash    -c    cat ${bts_log}/SYSLOG* > ${bts_log}/SYSLOG_concatenate.log
    # Run grep command to search for the specific measurement type
    ${syslog1}=    OperatingSystem.Run
    ...    command=grep -F "[showMeasTypeMap] measType: 55332 interval: 5" ${bts_log}/SYSLOG_concatenate.log
    # Validate that the output contains the expected string
    Should Contain    ${syslog1}    [showMeasTypeMap] measType: 55332 interval: 5
    ${syslog2}=    OperatingSystem.Run
    ...    command=grep -F "[showMeasTypeMap] measType: 55316 interval: 5" ${bts_log}/SYSLOG_concatenate.log
    # Validate that the output contains the expected string
    Should Contain    ${syslog2}    [showMeasTypeMap] measType: 55316 interval: 5
    ${syslog3}=    OperatingSystem.Run
    ...    command=grep -F "[showMeasTypeMap] measType: 55112 interval: 5" ${bts_log}/SYSLOG_concatenate.log
    # Validate that the output contains the expected string
    Should Contain    ${syslog3}    [showMeasTypeMap] measType: 55112 interval: 5

# Check in syslog if measurements are disabled to 0 min reporting interval
# log to console    check syslog for measurements
# # Concatenate log files into one file
# Run Process    bash    -c    cat ${bts_log}/SYSLOG* > ${bts_log}/SYSLOG_concatenate.log
# # Run grep command to search for the specific measurement type
# ${syslog1}=    OperatingSystem.Run
# ...    command=grep -Pzo
# ...    "\[showMeasTypeMap\] measType: 55332 interval: 0.*\n.*\[getMeasIntervalBigToSmallMap\] Meas type: 55332 interval big to small 5=>0" \
# ...    ${bts_log}/SYSLOG_concatenate.log
# # Validate that the output contains the expected string
# Should Contain    ${syslog1}    [showMeasTypeMap] measType: 55316 interval: 0
# ${syslog2}=    OperatingSystem.Run
# ...    command=grep -Pzo
# ...    "\[showMeasTypeMap\] measType: 55316 interval: 0.*\n.*\[getMeasIntervalBigToSmallMap\] Meas type: 55316 interval big to small 5=>0" \
# ...    ${bts_log}/SYSLOG_concatenate.log
# # Validate that the output contains the expected string
# Should Contain    ${syslog2}    [showMeasTypeMap] measType: 55112 interval: 0
# ${syslog3}=    OperatingSystem.Run
# ...    command=grep -Pzo
# ...    "\[showMeasTypeMap\] measType: 55112 interval: 0.*\n.*\[getMeasIntervalBigToSmallMap\] Meas type: 55112 interval big to small 5=>0" \
# ...    ${bts_log}/SYSLOG_concatenate.log
# # Validate that the output contains the expected string
# Should Contain    ${syslog3}    [showMeasTypeMap] measType: 55112 interval: 0


Check in syslog if measurements are disabled to 0 min reporting interval
    log to console    Checking syslog for disabled measurements and saving subsequent lines to a file
    # Concatenate log files into one file
    Run Process    bash    -c    cat ${bts_log}/SYSLOG* > ${bts_log}/SYSLOG_concatenate.log
    # Extract all lines starting from the pattern
    Run Process    bash    -c
    ...    awk '/\[showMeasTypeMap\] measType: 55332 interval: 0/,0' ${bts_log}/SYSLOG_concatenate.log > ${bts_log}/filtered_lines.log
    # Verify that the file does not contain "Have sent config request"
    ${grep_output}=    Run Process    bash    -c
    ...    grep -q "Have sent config request" ${bts_log}/filtered_lines.log; echo $?
    # Check the exit code of the grep command
    Should Be Equal As Integers    ${grep_output.stdout.strip()}    1
    log to console    Verification completed successfully: All subsequent lines saved, and no "Have sent config request" found.


Check if counters are available in PM.BTS xml files
    log to console    check for a specific counter in PM.BTS XML file
     ${present_counter}    OperatingSystem.Run
    ...    command=cat /tmp/${xml_counter_unzipped} | grep M55332
    Should contain   ${present_counter}   M55332
    log to console    Get total number of measurements from PM.BTS XML file
    ${total_counters}   OperatingSystem.Run
    ...    command=grep -e "<M" ${xml_counter_unzipped} | grep -iv "MO dim"| wc -l
    [Return]     ${total_counters}



wait to nearest 15 min measurement period
	Log To Console  Wait to nearest 15 min measurement period
	Wait Until Keyword Succeeds  16 min  1 min  wait for right period of 15min

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


Check if counters are not available in PM.BTS XML file
    log to console    Check that counter M55332 is not present in PM.BTS XML file

    # Check if the counter M55332 exists
    ${present_counter}=    OperatingSystem.Run
    ...    command=grep -q "M55332" /tmp/${xml_counter_unzipped}; echo $?

    # Verify that the counter is not present
    Should Be Equal As Integers    ${present_counter}    1

    log to console    Get total number of measurements from PM.BTS XML file

    # Count all measurement entries in the XML file
    ${total_counters}=    OperatingSystem.Run
    ...    command=grep -e "<M" /tmp/${xml_counter_unzipped} | grep -iv "MO dim" | wc -l

    [Return]    ${total_counters}


Remove PM files from ENB RAM folder
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.xml.gz
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.raw.gz

Clear PM file from ENB TMP folder
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.xml.gz
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.raw.gz

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
