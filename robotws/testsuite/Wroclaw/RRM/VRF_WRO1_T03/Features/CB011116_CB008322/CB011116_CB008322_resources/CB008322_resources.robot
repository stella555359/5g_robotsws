*** Settings ***
Documentation
...     Set of keywords using in CB008322 feature test cases

Library    Collections
Library    SSHLibrary
Library    taf.transport.ssh
Resource    ../../../Resources/cm_operations/cm_operations.robot
Resource    ../../../Resources/logs_collecting/logs_collecting.robot
Resource    ../../../Resources/phase_shifter/phase_shifter.robot
Resource    ../../../Resources/pm_counters/pm_counters.robot
Resource    ../../../Resources/ue_keywords/ue_keywords.robot
Library    ../../../Resources/tti/TtiAnalysing.py

*** Variables ***
&{ONE_UE_CAPABILITY}    REAL_UE_1=NR_UE1
&{TWO_UES_CAPABILITY}    REAL_UE_1=NR_UE1    REAL_UE_2=NR_UE2
${ITERATIONS_NUMBER}    5

*** Keywords ***
CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SRS_POWER Test Case Scenario
    Prepare Environment CB008322_G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SRS_POWER With &{ONE_UE_CAPABILITY}
    CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SRS_POWER
    [Teardown]    Run Keywords    Stop Syslog    AND    Collect Snapshot    ${LOG_PATH}/CB008322_SRS_POWER_snapshot

CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SCHED_PRB Test Case Scenario
    Prepare Environment CB008322_G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SCHED_PRB With &{TWO_UES_CAPABILITY}
    CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SCHED_PRB Scenario
    [Teardown]    Run Keywords    Stop Syslog    AND    Collect Snapshot    ${LOG_PATH}/CB008322_SCHED_PRB_snapshot

CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_RANK Test Case Scenario
    Prepare Environment CB008322_G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_RANK With &{ONE_UE_CAPABILITY}
    CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_RANK Scenario
    [Teardown]    Run Keywords    Stop Syslog    AND    Collect Snapshot    ${LOG_PATH}/CB008322_REL_RANK_snapshot

Prepare Environment ${test_case} With ${ue_capability}
    ${timestamp}  OperatingSystem.Run    date +%F_%H-%M-%S
    ${LOG_PATH}   OperatingSystem.Join Path    ${OUTPUT DIR}    ${timestamp}_${TEST NAME}
    Create Directory     ${LOG_PATH}
    Create Directory     ${LOG_PATH}/PM
    Create Directory     ${LOG_PATH}/BIP
    Set Test Variable    ${LOG_PATH}
    Setup PS    ${CURDIR}../../../Pmax/pmax_resources/pmax_ps_settings.csv
    Initial Config Upload    ${CURDIR}/${test_case}.py
    ${UE_PREPARED}=    Prepare UEs    ${ue_capability}     expected_cell_id=828375041
    Set Test Variable    ${UE_PREPARED}    ${UE_PREPARED}
    Start Syslog    ${LOG_PATH}/CB011116

CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SRS_POWER
    Activate Tti Collecting
    Start Tput    ue=NR_UE1    dt_name=NR_DL1    tput_dl=1500    direction=dl    apn=5gwrowpt1
    sleep    5s
    ${loop_start_time}  Get Time
    Set Test Variable    ${LOOP_START_TIME}    ${loop_start_time}
    FOR  ${iteration}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
        Set Test Variable  ${ITERATION}  ${iteration}
        Log  \n=== Checking SB_BF_CONF_REL_SRS_POWER iteration: ${ITERATION} ===  console=True
        Check If Srs Power Is Above Target
        Rapid Check Status    numOfLayers    RANK4    dlFdSchedData    log_name=RCS_before_reduction_${iteration}
        Set Specified Channels To Specified Att    att_value=70    csv_settings=${CURDIR}../../../Pmax/pmax_resources/pmax_ps_settings.csv
        Check If Srs Power Is Below Target
        Sleep    10s
#        Collect BIP    CB008322_G2_SRS_POWER_BELOW_TARGET_STEP_${ITERATION}    ${LOG_PATH}/BIP
        Setup PS    ${CURDIR}../../../Pmax/pmax_resources/pmax_ps_settings.csv
        Check If Srs Power Is Above Target
#        Collect BIP    CB008322_G2_SRS_POWER_ABOVE_TARGET_STEP_${ITERATION}    ${LOG_PATH}/BIP
    END
    Collect And Analyze RD Counter SB_BF_CONF_REL_SRS_POWER
    [Teardown]    Stop Data Transfer For All Ues

CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SCHED_PRB Scenario
    Start Tput    ue=NR_UE1    dt_name=NR_DL1    tput_dl=1500    direction=dl    apn=5gwrowpt1
    ${loop_start_time}  Get Time
    Set Test Variable    ${LOOP_START_TIME}    ${loop_start_time}
    FOR  ${iteration}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
        Set Test Variable  ${ITERATION}  ${iteration}
        Log  \n=== Checking SB_BF_CONF_REL_SCHED_PRB iteration: ${ITERATION} ===  console=True
        Start Tput    ue=NR_UE2    dt_name=NR_DL2    tput_dl=300    direction=dl    apn=5gwrowpt1
        Sleep    10s
        Stop Specific Data Transfer    NR_DL1_dl
#        Collect BIP    CB008322_SB_BF_CONF_REL_SCHED_PRB_LOW_TPUT_STEP_${ITERATION}    ${LOG_PATH}/BIP
        Start Tput    ue=NR_UE1    dt_name=NR_DL1    tput_dl=1500    direction=dl    apn=5gwrowpt1
        Sleep    10s
        Stop Specific Data Transfer    NR_DL2_dl
#        Collect BIP    CB008322_SB_BF_CONF_REL_SCHED_PRB_HIGH_TPUT_STEP_${ITERATION}    ${LOG_PATH}/BIP
    END
    Collect And Analyze RD Counter SB_BF_CONF_REL_SCHED_PRB
    [Teardown]    Stop Data Transfer For All Ues

CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_RANK Scenario
    Activate Tti Collecting
    Start Tput    ue=NR_UE1    dt_name=NR_DL1    tput_dl=1500    direction=dl    apn=5gwrowpt1
    ${loop_start_time}  Get Time
    Set Test Variable    ${LOOP_START_TIME}    ${loop_start_time}
    FOR  ${iteration}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
        Set Test Variable  ${ITERATION}  ${iteration}
        Rapid Check Status    numOfLayers    RANK4    dlFdSchedData    log_name=RCS_before_reduction_${iteration}
        Set Specified Channels To Specified Att    att_value=90    csv_settings=${CURDIR}../../../Pmax/pmax_resources/pmax_ps_settings.csv
        sleep    7s
        Rapid Check Status    numOfLayers    RANK2    dlFdSchedData    log_name=RCS_after_reduction_${iteration}
#        Collect BIP    CB008322_SB_BF_CONF_REL_RANK2_${ITERATION}    ${LOG_PATH}/BIP
        Setup PS    ${CURDIR}../../../Pmax/pmax_resources/pmax_ps_settings.csv
        sleep    7s
        Rapid Check Status    numOfLayers    RANK4    dlFdSchedData    log_name=RCS_loop_finished_${iteration}
#        Collect BIP    CB008322_SB_BF_CONF_REL_RANK4_${ITERATION}    ${LOG_PATH}/BIP
    END
    Collect And Analyze RD Counter SB_BF_CONF_REL_RANK
    [Teardown]    Stop Data Transfer For All Ues

Initial Config Upload
    [Arguments]    ${initial_config}
    ${content}=    Import Variables    ${initial_config}
    admin.Create Delta    delta_id=nr_power
    admin.Append Complex Item To Delta  MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1  srsForBeamMgmt    delta_id=nr_power
    ...  &{srsforbeammgmt}
    admin.Append Complex Item To Delta  MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1  srsForSubbandBm   delta_id=nr_power
    ...  &{srsforsubbandbm}
    admin.Append Complex Item To Delta  MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1  wbSbSrsSwitch     delta_id=nr_power
    ...  &{wbsbsrsswitch}
    ${nr_power_delta}   admin.Get Delta   delta_id=nr_power
    Log  Delta contents:\n${nr_power_delta}  console=True
    admin.Perform Delta Recommissioning  ${nr_power_delta}  timeout=600    #alias=gNB
    Wait For Cell To Be OnAir
    Log    === Initial Config Set Successful ===    console=True

Check If Srs Power Is ${level} Target
    Log  === Check If Srs Power Is ${level} Target ===  console=True
    ${srs_status}  Run Keyword And Return Status  Check Srs Power In Syslog  ${level}
    Run Keyword If  not ${srs_status}
    ...  Log  === No Prints In Syslog Indicating Expected Level Of Srs Power ===  level=WARN  console=True

Check Srs Power In Syslog
    [Arguments]    ${expected_value}
    Log  === Check Srs Power In Syslog ===  console=True
    ${operator}  Set Variable If  '${expected_value}'=='Below'  <  >
    ${start_time}  Get Time From BTS
    Sleep  10s  reason=To ensure expected prints in syslog file
    ${matching_prints}  Wait For Message In Syslog File
    ...  regexp=PortPower report: rnti: [0-9]+, (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+)  timeout=10s  alias=syslog
    ${syslog_list}  Split To Lines  ${matching_prints}
    ${all_prints}  Get Length  ${syslog_list}
    Should Be True  ${all_prints} > 0  msg=There were no prints found in syslog.

    ${current_line_time}  Get Regexp Matches  ${syslog_list[-1]}
    ...  ^\\d+:([0-9]{2}\\.[0-9]{2}\\s[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9]{6})  1
    ${current_time}  Convert Date  ${current_line_time[0]}  date_format=%d.%m %H:%M:%S.%f  result_format=%d.%m %H:%M:%S
    ${difference}  Subtract Date From Date  ${current_time}  ${start_time}
    ...  date1_format=%d.%m %H:%M:%S  date2_format=%d.%m %H:%M:%S
    Should Be True  ${difference} > 0  msg=Timestamp is not older than start time.

    ${srs_power_tuples}  Get Regexp Matches  ${syslog_list[-1]}
    ...  PortPower report: rnti: [0-9]+, (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+)
    ...  1  2  3  4
    ${srs_power_list}  Evaluate  [float(value) for tup in ${srs_power_tuples} for value in tup]
    FOR  ${value}  IN  @{srs_power_list}
        Should Be True  ${value} ${operator} -110.0  msg=SRS power exceeds target
    END
    Log  === Each Mesured Sample Of Srs Power Meets Target ===  console=True

Collect And Analyze RD Counter ${rd_counter}
    Log    === Wait Required Period And Collect RD Counters ===    console=True
    ${loop_end_time}  Get Time
    ${duration}  Subtract Date From Date  ${loop_end_time}  ${loop_start_time}
    ...  date1_format=%Y-%m-%d %H:%M:%S  date2_format=%Y-%m-%d %H:%M:%S
    ${number_of_periods}  Evaluate  int(${duration}//300 +1)
    Adjust Time To New Pm Interval    True
    Collect RD Counters From BTS  ${number_of_periods}
    ${sb_bf_conf_rel_list}  Create List  ${rd_counter}
    ${sb_bf_conf_rel_dict}  Get Values Of Counters From List  ${LOG_PATH}/RD_counters  ${sb_bf_conf_rel_list}
    ...  MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
    Set Test Variable  ${SB_BF_CONF_REL_DICT}  ${sb_bf_conf_rel_dict}
    Analyze ${rd_counter} Counter

Collect RD Counters From BTS
    [Documentation]
    ...  Collects RD counters using local connection.
    ...
    ...  **Full description:**
    ...
    ...  Connects to 192.168.255.129 using lmp_connection credentials provided in __init__.py.
    ...  Filters and downloads the number of recent RD files according to ${files_number}.
    ...  Unzips RD files and renames them to PM_${file_no}.xml.
    ...  Removes from PM files attributes 'interval' others than ${interval_to_save}.
    ...  Requires ${LOG_PATH} with path where logs will be collected.
    ...  Stores original and unziped files under the path ${LOG_PATH}/RD_counters.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | files_number          | Yes  | Number of recent files to be collected                              |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | interval_to_save      | No   | Interval value to be not removed. Default value: 5                  |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Collect RD Counters From BTS  3

    [Arguments]  ${files_number}  ${interval_to_save}=5

    Create Directory  ${LOG_PATH}/RD_counters

    taf.transport.ssh.Connect To  192.168.255.129  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}  alias=gNB2
    ${rd_filename}  taf.transport.ssh.Execute  ls -t /tmp | grep ^RD | head -n ${files_number}  connection=gNB2
    Log   \n${rd_filename}  console=True
    ${rd_list}  Split String  ${rd_filename}
    Should Not Be Empty  ${rd_list}  msg=There is no R&D counters file available
    FOR  ${file_no}  ${rd_file}  IN ENUMERATE  @{rd_list}
        taf.transport.ssh.Download File  /tmp/${rd_file}  ${LOG_PATH}/RD_counters/${rd_file}  connection=gNB2
        ${rc_gzip}  Run And Return Rc  gzip -cd ${LOG_PATH}/RD_counters/${rd_file} > ${LOG_PATH}/RD_counters/PM_${file_no}.xml
        Should Be Equal As Integers  ${rc_gzip}  0  msg=gzip command ended with an error
        Remove Unnecessary Interval From Pmfile  PM_${file_no}.xml  ${interval_to_save}
    END
    Log  === RD counters collected, unziped and converted to PM.xml format ===  console=true
    [Teardown]  taf.transport.ssh.Disconnect  connection=gNB2

Remove Unnecessary Interval From Pmfile
    [Documentation]
    ...  KW used to remove unnecessary interval from pmfile.
    ...
    ...  **Full description:**
    ...
    ...  Removes from PM files elements with attribute 'interval' other than ${interval_to_save}.
    ...  Overwrites the modified file.
    ...  Requires ${LOG_PATH} with path where logs are collected.
    ...  Requires absolute path to pmfile to be: ${LOG_PATH}/RD_counters/${file_name}.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | file_name             | Yes  | Name of file to modify                                              |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | interval_to_save      | No   | Interval value to be not removed. Default value: 5                  |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Remove Unnecessary Interval From Pmfile  PM_1.xml  15

    [Arguments]  ${file_name}  ${interval_to_save}=5

    ${parsed_xml}  Parse XML  ${LOG_PATH}/RD_counters/${file_name}  strip_namespaces=True
    ${elements}  Get Elements  ${parsed_xml}  .//PMSetup
    FOR  ${element}  IN  @{elements}
        ${interval}  Get Element Attribute  ${element}  interval
        Run Keyword If  '${interval}'!='${interval_to_save}'  Remove Elements  ${parsed_xml}  .//PMSetup[@interval="${interval}"]
    END
    Save Xml  ${parsed_xml}  ${LOG_PATH}/RD_counters/${file_name}

Get Values Of Counters From List
    [Documentation]
    ...  This KW returns dictionary of counters (keys) and list of their values (value).
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW returns dictionary of counters (keys) and list of their values (value).
    ...  All counters must be under the same managed object (the same value in 'dist_name' argument).
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | files_path          | Yes  | Path to saved PM files.                                                 |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counter_list        | Yes  | List of counter's IDs.                                                  |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | dist_name           | Yes  | Dist name under which counters from 'counter_list' can be found.        |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counters_amount     | No   | Number of last periods for which counter values should                  |
    ...  |                     |      | be comparised. Default value 'all' means all values of specified        |
    ...  |                     |      | counter will be verified.                                               |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${counter_list} =  Create List  M8029C217  M8029C225  M8029C238  M8029C210
    ...     Get Values Of Counters From List  ${LOG_PATH}/pm_counters  ${counter_list}
    ...     ...  MRBTS-12345/LNBTS-12345/LNCEL-111222  5

    [Arguments]  ${files_path}  ${counter_list}  ${dist_name}  ${counters_amount}=all
    Log  Getting values for counters: ${counter_list}  console=True

    ${counters_dict} =  Create Dictionary
    FOR  ${counter}  IN  @{counter_list}
        ${counter_in_list} =  Create List  ${counter}
        ${pi_dict} =  Get PI Value
        ...  pi_list=${counter_in_list}
        ...  pi_dir=${files_path}
        ...  pi_file_pattern=PM*

        ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
        ...                             ${pi_dict}
        ...                             ${pi_dict[-${counters_amount}:]}
        ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
        Log  Getting values for counter: ${counter}  console=True
        ${counter_values} =  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
        Counter Check Helper  counters_amount=${counters_amount}  counter_values=${counter_values}
        Set To Dictionary  ${counters_dict}  ${counter}=${counter_values}
        Log  Values: ${counter_values}  console=True
    END
    [Return]  ${counters_dict}

Counter Check Helper
    [Arguments]  ${counters_amount}  ${counter_values}
    ${list_length} =  Get Length  ${counter_values}
    Run Keyword If  '${counters_amount}' == 'all'  Run Keyword And Continue On Failure
    ...  Should Be True  ${list_length} > 0  msg=Counter list is empty. Check if there are any counters.
    ...  ELSE  Run Keyword And Continue On Failure  Should Be True  ${list_length} == ${counters_amount}
    ...  msg=List length (${list_length}) is different from requested counters amount (${counters_amount}).

Analyze ${rd_counter} Counter
    Log    === Step: Analyze ${rd_counter} Counter ===    console=True
    ${sb_bf_conf_rel_int_list}      Evaluate  [int(x) for x in ${SB_BF_CONF_REL_DICT['${rd_counter}']}]
    ${sum_sb_bf_conf_rel_values}    Evaluate    sum(${sb_bf_conf_rel_int_list})
    Should Be True  ${sum_sb_bf_conf_rel_values} == ${ITERATION}
    ...  msg=${rd_counter} = ${sum_sb_bf_conf_rel_values} has value different than ${ITERATION}!
    Log    === Counter Values For ${rd_counter} Are Correct ===    console=True

Get Time From BTS
    [Arguments]  ${host_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}  ${user}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  ${date_time_format}=%d.%m %H:%M:%S
    SSHLibrary.Open Connection  ${host_ip}
    SSHLibrary.Login  ${user}  ${password}
    ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command  date +\"${date_time_format}\"  return_stderr=True  return_rc=True
    Should Be Equal As Integers  ${rc}  0    msg=RC is not equal to 0.
    Should Be Empty  ${stderr}  msg=${stderr}
    [Return]  ${stdout}
    [Teardown]  SSHLibrary.Close Connection

