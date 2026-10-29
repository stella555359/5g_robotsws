*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library       SSHLibrary
Library       ute_ue
Library       taf.sbts.oam.coam.admin    WITH NAME    admin
Library       taf.analyzer.pmcounter
Library       ../../resources/Emil.py
Library        taf.sw.dcap.rd
Library       testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager.DCAPManager  WITH NAME  dcap_manager
Library       DateTime
Resource      ../../resources/ca_IWK.robot


*** Variables ***
${LTE_CELL_ID1}                                              # ID of tested LTE cell
${DUAL_OR_SINGLE}                                            # Variable determining if test is for dual or single sector case.
# Possible values: 'Single Sector', 'Dual Sector'
${LTE_UE_CAPABILITY}                                         # Capability of LTE UE used in test
${MNC}                                                       # Value of MNC related with PLMN, e.g. 01
${MCC}                                                       # Value of MCC related with PLMN, e.g. 001
${MIN_ATTENUATION}                     10                    # Value of attenuation in dB for triggering return from TM9 to TM4
# Default value: 10
${MAX_ATTENUATION}                     70                    # Value of attenuation in dB  for triggering change from TM4 to TM9
# Default value: 70
${LTE_CELL_ID2}                        ${NONE}               # ID of LTE cell that needs to be blocked (for dual sector configuration).
# Default value: ${None}
${NB_IOT_GLOBAL_CELL_ID}               ${NONE}               # ID of NB-IoT cell that is paired with the LTE cell which needs to be blocked
# (for dual sector configuration). Default value: ${None}
${MAX_DCAP_LOGS_DELAY}                 120                   # Max time in seconds needed for change of DCAP logs collecting status
# Default value: 120
${COUNTER_PERIOD}                      15                     # Counter collecting interval in minutes. Default value: 15
${WINDOWS_SACK_PARENT_PATH}                                   # Absolute path for EMIL SACKs on Windows remote host,
# e.g. C:/Users/wimaxpi/AppData/Local/Emil/Sacks
${WINDOWS_PATH_TO_EMIL_EXE}     C:/Program Files/Emil/EMIL    # Absolute path to EMIL execution file on Windows remote host
# (no '.exe' needed). Default value: C:/Program Files/Emil/EMIL
${WINDOWS_TEMP_LOGS_DIR}        C:/temp/dcap_logs             # Absolute path to directory where logs will be kept for conversion to CSV
# (on Windows remote host). Default value: C:/temp/EMIL_logs
${APN}                                                        # Variable is used to set APN for keyword 'Start Data Transfer'

*** Keywords ***
TC__RRM__LTE_data_transfer_switching_TM4_TM9

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    OWNER-piotr.smolak@nokia.com
    ...         MAINTAINER-monika.ceglarek@nokia.com    PHASE-CRT   SW-SBTS23R1    FEATURE-LTE5151
    ...         FEATURE-LTE4529  FEATURE-CB007256  GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Start Collecting Control Plane Logs
    Step 2: Perform LTE DL Data Transfer
    Step 3: Waiting For New Counter Period To Begin
    Step 4: Increase Cell Attenuation
    Step 5: Decrease Cell Attenuation
    Step 6: Waiting For New Counter Period To Begin
    Step 7: Collect PM Counters
    Step 8: Stop LTE Data Transfer
    Step 9: Stop Collecting Control Plane Logs
    Step 10: Extract EMIL logs
    Step 11: Parse EMIL logs


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Test Variable  ${CELL_BLOCKED}  False
    Set Test Variable  ${DCAP_STARTED}  False

    Start Wireshark Log Collection For IWK Test  options=-i any host ${ENB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...                                          replace_enb=False  replace_gnb=False

    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_original

    ${lnbts_id} =  Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}  ${lnbts_id}

    ${counters_list} =  Create List  M8008C43  M8008C44  M8008C45  M8008C46
    Set Test Variable  ${COUNTERS_LIST}  ${counters_list}

    Check Element In SCF  ${parsed_scf}  LNCEL_FDD  LNCEL-${LTE_CELL_ID1}/  /p[@name='dlMimoMode']
    ...  <p name="dlMimoMode">Closed Loop MIMO (8x4)</p>
    Print Parameter Values From SCF  ${parsed_scf}

    Set Attenuation  TM4_TM9_LTE_CELL_1  ${MIN_ATTENUATION}dB
    Require UE  LTE_UE  ${LTE_UE_CAPABILITY}

    Run Keyword If  '${DUAL_OR_SINGLE}' == 'Dual Sector' and ${LTE_CELL_ID2}
    ...  Blocking LTE Cell For Dual Sector Configuration  ${parsed_scf}


Print Parameter Values From SCF
    [Arguments]  ${parsed_scf}

    ${tm_4_to_9_cqi_th} =  Get Parameter Value From SCF  ${parsed_scf}  TMSWPR  LNBTS-${LNBTS_ID}/
    ...  /list[@name='tmSwitchThresholdMMimoDef']/item/p[@name='tm4to9CqiTh']
    ${tm_9_to_4_cqi_th} =  Get Parameter Value From SCF  ${parsed_scf}  TMSWPR  LNBTS-${LNBTS_ID}/
    ...  /list[@name='tmSwitchThresholdMMimoDef']/item/p[@name='tm9to4CqiTh']
    Log  Parameter values:\ntm4to9CqiTh=${tm_4_to_9_cqi_th}\ntm9to4CqiTh=${tm_9_to_4_cqi_th}  console=True

    ${tm_4_to_9_cqi_th_256_qam} =  Get Parameter Value From SCF  ${parsed_scf}  TMSWPR  LNBTS-${LNBTS_ID}/
    ...  /list[@name='tmSwitchThresholdMMimoDef256QAM']/item/p[@name='tm4to9CqiTh256QAM']
    ${tm_9_to_4_cqi_th_256_qam} =  Get Parameter Value From SCF  ${parsed_scf}  TMSWPR  LNBTS-${LNBTS_ID}/
    ...  /list[@name='tmSwitchThresholdMMimoDef256QAM']/item/p[@name='tm9to4CqiTh256QAM']
    Log  \ntm4to9CqiTh256QAM=${tm_4_to_9_cqi_th_256_qam}\ntm9to4CqiTh256QAM=${tm_9_to_4_cqi_th_256_qam}  console=True

    ${qrx_lev_min} =  Get Parameter Value From SCF  ${parsed_scf}  SIB  LNCEL-${LTE_CELL_ID1}/
    ...  /p[@name='qrxlevmin']
    Log  \nqrxlevmin=${qrx_lev_min}\n  console=True


Blocking LTE Cell For Dual Sector Configuration
    [Arguments]  ${parsed_scf}
    ${lncel_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  LNCEL  LNCEL-${LTE_CELL_ID2}  dist_name_substring=True
    Set Test Variable  ${LNCEL_DIST_NAME}  ${lncel_dist_name}
    Set Test Variable  ${CELL_BLOCKED}  True
    Block Cell  ${LNCEL_DIST_NAME}
    Log  Cell ${LNCEL_DIST_NAME} blocked.  console=True
    ${expected_alarm_lte} =  Set Variable  faultId=49, configObjectName=regex"^.*MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID2}"
    ${expected_alarm_nb_iot} =  Set Variable
    ...  faultId=49, configObjectName=regex"^.*MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${NB_IOT_GLOBAL_CELL_ID}"
    Set Test Variable  ${EXPECTED_ALARM_LTE}  ${expected_alarm_lte}
    Set Test Variable  ${EXPECTED_ALARM_NB_IOT}  ${expected_alarm_nb_iot}
    Wait Until Keyword Succeeds  2m  20s  _verify bts states after cell block helper


Step 1: Start Collecting Control Plane Logs
    Log  \n==== Step 1: Start Collecting Control Plane Logs ====  console=True

    ${lte_cell_list} =  Create List  ${LTE_CELL_ID1}

    ${lte_log_profile} =  Create List  cp_4g  pmFiles4g
    ${profiles_dictionary} =  Create Dictionary  enb_custom_profile=${lte_log_profile}

    _start dcap helper  ${lte_cell_list}  ${profiles_dictionary}

    Log  Waitnig for traces to change status to 'Running'  console=True
    Wait Until Keyword Succeeds  ${MAX_DCAP_LOGS_DELAY}  5s  Check Status Of Traces    running

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL' and ${DCAP_STARTED}
    ...  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}

Check Status Of Traces
    [Arguments]  ${state}
    ${trace_status} =  Get Trace Info By ID  trace_id=${TRACE_ID}  connection=dcap_collector
    Should Be Equal As Strings  ${trace_status['status']}  ${state}
    ...  msg=Trace status is ${trace_status['status']}. Should be: '${state}'.
    Log  Trace status ${trace_status['status']}  console=True

_start dcap helper
    [Arguments]  ${lte_cell_list}  ${profiles_dictionary}  ${user}=Nemuadmin  ${password}=nemuuser

    Log  Connecting to DCAP server IP=${DCAP_HOST['ip']} on port=${DCAP_HOST['port']}  console=True
    dcap_manager.Connect To  host=${DCAP_HOST['ip']}  port=${DCAP_HOST['port']}
    ...  user=${DCAP_HOST['login']}  passwd=${DCAP_HOST['password']}

    Log  Using profiles:\n${profiles_dictionary}.\nStarting new trace for IP ${ENB_OAM_IP}...  console=True
    Set Test Variable  ${DCAP_STARTED}  True
    ${trace_id} =  dcap_manager.Start New Trace  mplane=${ENB_OAM_IP}  user=${user}  passwd=${password}
    ...  port=443  lte_cells=${lte_cell_list}  log_profile=${profiles_dictionary}
    Set Test Variable  ${TRACE_ID}  ${trace_id}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  dcap_manager.Stop Trace  trace=${trace_id}
    ...  AND  dcap_manager.Teardown
    ...  AND  Set Test Variable  ${DCAP_STARTED}  False


Step 2: Perform LTE DL Data Transfer
    Log  \n==== Step 2: Perform LTE DL Data Transfer ====  console=True

    Check If Current Time Is Within Range And Wait  ${ENB_OAM_IP}
    Log  Preparing UE for DL data transfer...  console=True
    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID1}
    Log  Starting data transfer...  console=True
    Start Data Transfer  LTE_DL  LTE_UE  dl  throughput=350 Mbits/sec  duration=1800s
    ...  protocol=tcp  max_segment_size=1400  parallel_streams=4  buffer=32M    apn=${APN}


Check If Current Time Is Within Range And Wait
    [Arguments]  ${ip}
    ...          ${user}=${tl.enbs[0].system_module.common_units[0].lmp_connection.username}
    ...          ${password}=${tl.enbs[0].system_module.common_units[0].lmp_connection.password}

    ${current_time_on_sbts} =  Get Time From BTS  host_ip=${ip}
    ...                                           user=${user}
    ...                                           password=${password}
    ...                                           date_time_format=%M
    ${current_time_on_sbts} =  Convert To Integer  ${current_time_on_sbts}
    Log  Current minutes: ${current_time_on_sbts}  console=True
    ${time_is_in_range} =  Run Keyword And Return Status
    ...  Should Be True  0 <= ${current_time_on_sbts} < 15 or 30 <= ${current_time_on_sbts} < 45
    ...  msg=Time is not in range: 0 <= ${current_time_on_sbts} < 15 or 30 <= ${current_time_on_sbts} < 45.
    Return From Keyword If  ${time_is_in_range}

    IF  not ${time_is_in_range}
        ${waiting_time} =  Count Measurement Period  ${ip}  30
    END
    Log  Wait ${waiting_time}s till new period of EMIL logs is started...  console=True
    Sleep  ${waiting_time}s  reason=Wait till new period of EMIL logs is started.


Step ${index}: Waiting For New Counter Period To Begin
    Log  \n==== Step ${index}: Waiting For New Counter Period To Begin ====  console=True

    ${waiting_time} =  Count Measurement Period  ${ENB_OAM_IP}  ${COUNTER_PERIOD}
    Log  Wait ${waiting_time}s till new period of counter is started...    console=True
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.
    Check Data Transfer Is Alive  LTE_DL


Step 4: Increase Cell Attenuation
    Log  \n==== Step 4: Increase Cell Attenuation ====  console=True

    Set Attenuation  TM4_TM9_LTE_CELL_1  ${MAX_ATTENUATION}dB
    Check Data Transfer Is Alive  LTE_DL
    Sleep  10s  reason=Waiting for reconfigurations to complete and tput to stabilize.


Step 5: Decrease Cell Attenuation
    Log  \n==== Step 5: Decrease Cell Attenuation ====  console=True

    Set Attenuation  TM4_TM9_LTE_CELL_1  ${MIN_ATTENUATION}dB
    Check Data Transfer Is Alive  LTE_DL
    Sleep  10s  reason=Waiting for reconfigurations to complete and tput to stabilize.


Step 7: Collect PM Counters
    Log  \n==== Step 7: Collect PM Counters ====  console=True

    Sleep  30s  reason=Wait for counters to appear on BTS
    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${LOG_PATH}/pm_counters
    ...  xml_files_left=4  time_interval=15min  intervals=15
    ${counters_dict} =  Get Values Of Counters From List  ${LOG_PATH}/pm_counters
    ...                  ${COUNTERS_LIST}
    ...                  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID1}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}
    ...                  1
    Set Test Variable  ${COUNTERS_DICT}  ${counters_dict}


Step 8: Stop LTE Data Transfer
    Log  \n==== Step 8: Stop LTE Data Transfer ====  console=True

    Stop Data Transfer    LTE_DL
    Detach UE  LTE_UE


Step 9: Stop Collecting Control Plane Logs
    Log  \n==== Step 9: Stop Collecting Control Plane Logs ====  console=True

    Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}


Stop DCAP Traces and Download Logs
    [Arguments]  ${trace_id}

    Log  Stopping DCAP traces...  console=True
    dcap_manager.Stop Trace  trace=${trace_id}
    Wait Until Keyword Succeeds  ${MAX_DCAP_LOGS_DELAY}  5s  Check Status Of Traces    ready
    Set Test Variable  ${DCAP_STARTED}  False
    Log  Downloading logs...  console=True
    ${dcap_logs_path} =  dcap_manager.Download Logs  trace=${trace_id}  target_dir=${LOG_PATH}/dcap_logs
    Log  Logs downloaded to ${dcap_logs_path}.  console=True
    Set Test Variable  ${DCAP_LOGS_PATH}  ${dcap_logs_path}
    dcap_manager.Teardown


Step 10: Extract EMIL logs
    Log  \n==== Step 10: Extract EMIL logs ====  console=True

    Extract Logs  ${DCAP_LOGS_PATH}  extract_dir=${LOG_PATH}/dcap_logs/dcap_unzipped


Step 11: Parse EMIL logs
    Log  \n==== Step 11: Parse EMIL logs ====  console=True

    Convert Files To CSV On Remote Windows Host
    ${files} =  OperatingSystem.List Files In Directory  ${LOG_PATH}/dcap_logs/CSV
    ${file_paths} =  Create List
    FOR  ${file}  IN  @{files}
        ${file_path} =  OperatingSystem.Join Path  ${LOG_PATH}/dcap_logs/CSV/  ${file}
        Log  Created file path: ${file_path}  console=True
        Append To List  ${file_paths}  ${file_path}
    END
    ${tm4_to_tm9_change}  ${tm9_to_tm4_change} =  Counting Changes In RRC Messages  ${file_paths}  ${LOG_PATH}/pm_counters
    Compare Counter Values And Changes In RRC Messages  ${tm4_to_tm9_change}  ${tm9_to_tm4_change}


Convert Files To CSV On Remote Windows Host
    ${windows_sack_path} =  Get SACK Directory Path For Parent Directory  ${WINDOWS_SACK_PARENT_PATH}
    ${converted_files_dir} =  Join Path  ${WINDOWS_TEMP_LOGS_DIR}  converted
    ${ip}  ${login}  ${password}=  Get PC Data
    ${win_file_paths} =  Copy EMIL Logs To Windows  ${LOG_PATH}/dcap_logs/dcap_unzipped
    ...                                             ${WINDOWS_TEMP_LOGS_DIR}
    ...                                             ${ip}  ${login}  ${password}

    Log  File paths on Windows:\n${win_file_paths}  console=True

    SSHLibrary.Open Connection  ${ip}
    SSHLibrary.Login  ${login}  ${password}
    SSHLibrary.Directory Should Exist  ${windows_sack_path}
    FOR  ${index}  ${file_path}  IN ENUMERATE  @{win_file_paths}
        Log  \nFile path=${file_path}  console=True
        ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command
        ...  "${WINDOWS_PATH_TO_EMIL_EXE}" ${file_path} -ToCSV PerTrace -Destination ${converted_files_dir} -SackPath ${windows_sack_path} -AutoClose
        ...  return_stderr=True  return_rc=True  timeout=600s
        Log  stdout=${stdout}  console=True
        ${regexp_converted_files_dir} =  Replace String  ${converted_files_dir}  /  .{1,2}
        ${_}  ${file_name}=  Split String From Right  ${file_path}  separator=/  max_split=1
        ${file_name} =  Replace String  ${file_name}  .emil  .{1,4}csv
        Should Match Regexp  ${stdout}
        ...  .*${regexp_converted_files_dir}.{1,2}${file_name}(.|\\n|\\r\\n)*Conversion read(.*\\n.*Closed Emil due to UserClosing)|.*
        Log  Conversion of EMIL file to CSV file was successful.  console=True
        Move and Rename CSV Files  ${converted_files_dir}  ${index}
    END

    SSHLibrary.Get Directory  ${converted_files_dir}/converted  ${LOG_PATH}/dcap_logs/CSV
    ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command
    ...  rm -rf ${WINDOWS_TEMP_LOGS_DIR}  return_stderr=True  return_rc=True
    Log  stdout=${stdout}  console=True

    [Teardown]  SSHLibrary.Close All Connections


Get SACK Directory Path For Parent Directory
    [Arguments]  ${parent_dir}
    ${sw_version} =  Get SW Version  ${USER_SW_VERSION}
    ${branch}  ${version}=  Split String  ${sw_version}  separator=_  max_split=1
    ${version} =  Remove String  ${version}  ENB_
    ${path} =  Join Path  ${parent_dir}  ${branch}_IDA_${version}
    [Return]  ${path}


Get PC Data
    ${ue_pools_exists} =  Run Keyword And Return Status  Variable Should Exist  ${UE_POOLS}
    IF  not ${ue_pools_exists}
        Import Variables  ${ABSTRACT_LIB_CONFIG}
    END
    ${ue_name} =  Evaluate  list(${UE_POOLS['TafUeAndroidPool']['inline_config']}.keys())[0]
    ${conf} =     Set Variable  ${UE_POOLS['TafUeAndroidPool']['inline_config']['${ue_name}']['CONSTRUCTOR_PARAMETERS']['configuration']}
    [Return]  ${conf['ue_pc_address']}  ${conf['login']}  ${conf['password']}


Move and Rename CSV Files
    [Arguments]  ${converted_files_dir}  ${index}

        ${files} =  SSHLibrary.List Files In Directory  ${converted_files_dir}
        Log  Files in ${converted_files_dir}: ${files}  console=True

        ${temp_dir_exists} =  Run Keyword And Return Status
        ...  SSHLibrary.Directory Should Exist  ${converted_files_dir}/converted/
        IF  not ${temp_dir_exists}
            ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command
            ...  mkdir ${converted_files_dir}/converted/  return_stdout=True  return_stderr=True  return_rc=True

            Should Be True  ${rc} == 0 and '${stderr}' == ''
            ...  msg=RC is not equal to 0. RC=${rc}. Error: ${stderr}
        END

        FOR  ${file}  IN  @{files}
            ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command
            ...  mv ${converted_files_dir}/${file} ${converted_files_dir}/converted/${index}_${file}
            ...  return_stdout=True  return_stderr=True  return_rc=True
            Should Be True  ${rc} == 0 and '${stderr}' == ''
            ...  msg=RC is not equal to 0. RC=${rc}. Error: ${stderr}
        END
        ${files} =  SSHLibrary.List Files In Directory  ${converted_files_dir}/converted
        Log  Files in ${converted_files_dir}/converted: ${files}  console=True


Counting Changes In RRC Messages
    [Arguments]  ${file_paths}  ${pm_counters_file_path}

    ${start_date_time} =  Get Date For Last PM File  ${COUNTERS_LIST}  ${pm_counters_file_path}
    Log  Start time: ${start_date_time}  console=True
    ${end_date_time} =  DateTime.Add Time To Date  ${start_date_time}  ${COUNTER_PERIOD}:00
    Log  End time: ${end_date_time}  console=True
    ${tm4_to_tm9_change}  ${tm9_to_tm4_change}  ${ue_release_inside_range} =  Search And Count Transmission Mode Changes
    ...  ${file_paths}  ${LOG_PATH}/misc_logs/merged.csv  ${start_date_time}  ${end_date_time}
    Log  \n-------------------------------------------RESULTS-------------------------------------------
    ...  console=True
    Log  \nNumber of changes from TM4 to TM9: ${tm4_to_tm9_change}\nNumber of changes form TM9 to TM4: ${tm9_to_tm4_change}
    ...  console=True
    Log  UEContextReleaseComplete inside time range defined by user: ${ue_release_inside_range}
    ...  console=True
    Should Not Be True  ${ue_release_inside_range}
    ...  msg=UEContextReleaseComplete was found inside time range defined by user.

    [Return]  ${tm4_to_tm9_change}  ${tm9_to_tm4_change}



Compare Counter Values And Changes In RRC Messages
    [Arguments]  ${tm4_to_tm9_change}  ${tm9_to_tm4_change}

    ${m8008c43} =  Set Variable  ${COUNTERS_DICT['M8008C43'][-1]}
    ${m8008c44} =  Set Variable  ${COUNTERS_DICT['M8008C44'][-1]}
    ${m8008c45} =  Set Variable  ${COUNTERS_DICT['M8008C45'][-1]}
    ${m8008c46} =  Set Variable  ${COUNTERS_DICT['M8008C46'][-1]}
    ${msg} =  Catenate  Number of changes from TM4 to TM9 for counter and RRC messages is not equal,
    ...  number of attemts is different from number of successes or counter is equal to 0.

    Run Keyword And Continue On Failure
    ...  Should Be True  ${m8008c43} == ${tm4_to_tm9_change} and ${m8008c43} > 0
    ...  msg=Number of changes from TM4 to TM9 for counter and RRC messages is not equal or is equal to 0.

    Run Keyword And Continue On Failure
    ...  Should Be True  ${m8008c44} == ${tm4_to_tm9_change} and ${m8008c44} == ${m8008c43} and ${m8008c44} > 0
    ...  msg=${msg}

    Run Keyword And Continue On Failure
    ...  Should Be True  ${m8008c45} == ${tm9_to_tm4_change} and ${m8008c45} > 0
    ...  msg=Number of changes from TM9 to TM4 for counter and RRC messages is not equal or is equal to 0.

    Run Keyword And Continue On Failure
    ...  Should Be True  ${m8008c46} == ${tm9_to_tm4_change} and ${m8008c46} == ${m8008c45} and ${m8008c46} > 0
    ...  msg=${msg}


Get Date For Last PM File
    [Arguments]  ${counters}  ${files_path}

    ${pi_dict} =  Get PI Value
    ...  pi_list=${counters}
    ...  pi_dir=${files_path}
    ...  pi_file_pattern=PM*
    ${date} =  Evaluate  list(${pi_dict}[-1].keys())[0]
    Log  Time of last PM file: ${date}  console=True
    ${converted_date} =  Remove Delta From Date  ${date}
    Log  Converted time: ${converted_date}  console=True

    [Return]  ${converted_date}


Remove Delta From Date
    [Arguments]  ${date}

    ${time_delta} =  Get Regexp Matches  ${date}  [+-]\\d\\d:\\d\\d$
    Log  Time delta: ${time_delta}  console=True
    Should Not Be Empty  ${time_delta}  msg=Unexpected time format. Should be ending with +HH:MM or -HH:MM.
    ${time_delta} =  Set Variable  ${time_delta[0]}
    ${date} =  Remove String  ${date}  ${time_delta}
    ${converted_time} =  Run Keyword If  '+' in '${time_delta}'
    ...  DateTime.Subtract Time From Date  ${date}  ${time_delta[1:]}:00
    ...  ELSE IF  '-' in '${time_delta}'  DateTime.Add Time To Date  ${date}  ${time_delta[1:]}:00
    ...  ELSE  Fail  msg=No time delta available.

    [Return]  ${converted_time}


_verify bts states after cell block helper
    [Arguments]  ${alias}=default
    Log  Checking BTS state after cell block.  console=True
    ${gncels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  gsm      connection=${alias}
    ${wncels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  wcdma    connection=${alias}
    ${nrcels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  nr       connection=${alias}

    ${smod_onair_states}=  Catenate  SEPARATOR=   operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"
    ${rmod_onair_states}=  Catenate  SEPARATOR=   operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"
    ${gln_cell_onair_states}=  Catenate  SEPARATOR=  operationalState=regex"[Ee]nabled",
    ...                                              administrativeState=regex"[Uu]nlocked",
    ...                                              blockingState=regex"[Uu]nblocked"
    ${w_cell_onair_states}=  Catenate  SEPARATOR=  operationalState=regex"[Ee]nabled",
    ...                                            blockingState=regex"[Uu]nblocked"

    ${smods_onair}=
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  SMOD  ${smod_onair_states}  connection=${alias}
    ${rmods_onair}=
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  RMOD  ${rmod_onair_states}  connection=${alias}
    ${nrcells_onair}=  Run Keyword If  ${nrcels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  NRCEL  ${gln_cell_onair_states}  connection=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${wncells_onair}=  Run Keyword If  ${wncels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  WNCEL  ${w_cell_onair_states}  connection=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${gncells_onair}=  Run Keyword If  ${gncels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  GNCEL  ${gln_cell_onair_states}  connection=${alias}
    ...  ELSE  Set Variable  ${TRUE}

    ${lncels_correct_states} =  Run Keyword And Return Status  Check LTE Cells After Cell Block  ${gln_cell_onair_states}

    Add Allowed Alarm  ${EXPECTED_ALARM_LTE}  connection=${alias}
    Add Allowed Alarm  ${EXPECTED_ALARM_NB_IOT}  connection=${alias}

    ${alarms_status} =  Run Keyword And Return Status  Assert No Unexpected Active Alarms  connection=${alias}
    ${alarm_49_lte_status} =  Run Keyword And Return Status  Assert Alarm Active  ${EXPECTED_ALARM_LTE}  connection=${alias}
    ${alarm_49_nb_iot_status} =  Run Keyword And Return Status  Assert Alarm Active  ${EXPECTED_ALARM_NB_IOT}  connection=${alias}

    Clear Allowed Alarms List  connection=${alias}
    Add Standard Allowed Alarms  ${alias}

    ${statuses_dictionary}=  Create Dictionary
    ...  smods_onair=${smods_onair}  rmods_onair=${rmods_onair}
    ...  gncells_onair=${gncells_onair}  wncels_onair=${wncells_onair}
    ...  lncels_correct_states=${lncels_correct_states}  nrcells_onair=${nrcells_onair}  alarms_status=${alarms_status}
    ...  alarm_49_lte_status=${alarm_49_lte_status}  alarm_49_nb_iot_status=${alarm_49_nb_iot_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    ${modules_statuses} =  Evaluate  ${smods_onair} and ${rmods_onair}
    ${cell_statuses} =  Evaluate   ${gncells_onair} and ${wncells_onair} and ${lncels_correct_states} and ${nrcells_onair}
    Should Be True  ${modules_statuses} and ${cell_statuses} and ${alarms_status} and ${alarm_49_lte_status} and ${alarm_49_nb_iot_status}
    ...  msg=BTS verification failed. Details:\n${pretty_statuses}
    Log  BTS state checked.  console=True


Check LTE Cells After Cell Block
    [Arguments]  ${l_cell_onair_states}  ${alias}=default
    ${l_cell_blocked_states} =  Catenate  SEPARATOR=  availabilityStatus=regex"[Oo]ff line",
    ...                                               operationalState=regex"[Dd]isabled",
    ...                                               administrativeState=regex"[Uu]nlocked",
    ...                                               blockingState=regex"[Bb]locked"
    ${all_runtime_lncels} =  Get IDs For All  LNCEL
    ${lte_cell_runtime_distname} =  Get Runtime Dist Name For LTE Cell  ${LTE_CELL_ID2}  connection=${alias}
    ${nb_iot_cell_runtime_distname} =  Get Runtime Dist Name For LTE Cell  ${NB_IOT_GLOBAL_CELL_ID}  connection=${alias}
    Remove Values From List  ${all_runtime_lncels}  ${lte_cell_runtime_distname}  ${nb_iot_cell_runtime_distname}
    FOR  ${cell}  IN  @{all_runtime_lncels}
        _check cell state helper  LNCEL  ${cell}  ${l_cell_onair_states}
        ...  timeout=15s  connection=${alias}
    END
    _check cell state helper  LNCEL  ${lte_cell_runtime_distname}  ${l_cell_blocked_states}
    ...  timeout=15s  connection=${alias}
    _check cell state helper  LNCEL  ${nb_iot_cell_runtime_distname}  ${l_cell_blocked_states}
    ...  timeout=15s  connection=${alias}


Unblocking LTE Cell For Dual Sector Configuration
    Unblock Cell  ${LNCEL_DIST_NAME}
    Log  Cell ${LNCEL_DIST_NAME} unblocked.  console=True
    Wait Until Keyword Succeeds  30s  5s  _verify bts states for iwk test helper
    Log  BTS state checked.  console=True


TC Setup
    IWK Test Setup   single_bts=True
    Create Directory  ${LOG_PATH}/dcap_logs


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True
    Set Attenuation For All Cells  100%
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  LTE_UE

    Run Keyword If  ${CELL_BLOCKED}  Unblocking LTE Cell For Dual Sector Configuration
    Run Keyword If  ${DCAP_STARTED}  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}

    Stop Wireshark Log Collection For IWK Test
    IWK Test Teardown  single_bts=True
