*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library        SSHLibrary
Library        ute_ue
Library        taf.sw.dcap.rd
Library        taf.analyzer.pmcounter
Library        taf.collectors.core
Library        taf.ul.alarms_watchdog
Library        ../../resources/Emil.py
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager.DCAPManager  WITH NAME  dcap_manager
Resource       ../../resources/ca_IWK.robot


*** Variables ***
${NR_CALL_CELL_ID}                              # ID of NR cell for performing VoNR call
${UE_CAPABILITY}                                # Capability of UE used in test
${CELL_ALIAS}                                   # Alias set for tested cell in attenuator configuration file
${SETUP_ATTENUATOR}            False            # Boolean variable determining if attenuator should be setup or not.
${TA_ATTENUATOR_CONFIG}                         # Absolute path to YAML file with attenuator configuration
${PHONE_NUMBER}                0105             # Phone/Autoresponder number for VoNR call. Default value: 0105
${CALL_DURATION}               320              # Duration of VoNR call in seconds the duration needs to be 10s longer.
# Default value: 310
${ADDITIONAL_UE_CAPABILITY}                     # Additional capability of UE (mainly for differentiating between android and iphone).
${APN_CONTAINS}                n26wro           # Part of APN name that does not change. Default value: n26wro
${CONNECTION}                  gNB              # Alias used for ADMIN to check NR cell attach. Default value: gNB
${MAX_DCAP_LOGS_DELAY}         150s             # Max time in seconds needed for change of DCAP logs collecting status to 'running'
# Default value: 150
${COUNTER_PERIOD}              5                # Counter collecting interval in minutes. Default value: 5
${USER_SW_VERSION}             ${EMPTY}         # SW version defined by user.,
# e.g. SBTS00_ENB_9999_201020_000019. Optional parameter. Default value: ${EMPTY}
${WINDOWS_SACK_PARENT_PATH}                                   # Absolute path for EMIL SACKs on Windows remote host,
# e.g. C:/Users/wrodss/Documents/EmilSacks
${WINDOWS_PATH_TO_EMIL_EXE}     C:/Program Files/Emil/Emil    # Absolute path to EMIL execution file on Windows remote host
# (no '.exe' needed). Default value: C:/Program Files/Emil/Emil
${WINDOWS_TEMP_LOGS_DIR}        C:/TEMP/dcap_logs             # Absolute path to directory where logs will be kept for conversion to CSV
# (on Windows remote host). Default value: C:/TEMP/dcap_logs
${PERFORM_SIP_VERIFICATION}    False            # Boolean value determining if SIP verification should be performed in test.


*** Keywords ***
TC__Voice_over_NR

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-marcel.behen@nokia.com
    ...         PHASE-CDRT   SW-SBTS24R2    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Start Wireshark Logs
    Step 2: Start SIP Logs Collecting
    Step 3: Perform VoNR
    Step 4: Stop DCAP Traces and Download Logs
    Step 5: Stop Wireshark Logs
    Step 6: Check If VoNR Was Performed
    Step 7: Check If VoNR Was Finished Correctly
    Step 8: Counter Verification
    Step 9: Check BTS State
    Return From Keyword If  not ${PERFORM_SIP_VERIFICATION}
    Step 10: Extract EMIL logs
    Step 11: Parse EMIL logs
    Step 12: Check BTS State


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Test Variable  ${TCPDUMP_STARTED}  False
    Set Test Variable  ${ATTENUATOR_SET}  False
    Set Test Variable  ${DCAP_STARTED}  False
    Set Test Variable  ${CHECK_IN_TEARDOWN}  True

    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${global_nr_cell_id}

    _choose ue type helper
    ${ue_capabilities} =  Create List  ${UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    Require UE  NR_UE  ${ue_capabilities}
    Log UE Info  NR_UE  ALL

    Run Keyword If  ${SETUP_ATTENUATOR}  Attenuator Setup

    Wait For New Counter Period

    Run Keyword If  '${UE_TYPE}' == 'iphone'  Remove Baseband Logs  NR_UE


_choose ue type helper
    IF  '${ADDITIONAL_UE_CAPABILITY}' == 'REAL_IPHONE_UE'
        Set Test Variable  ${UE_TYPE}  iphone
    ELSE
        Set Test Variable  ${UE_TYPE}  android
    END


Wait For New Counter Period
    Log Variables   level=DEBUG
    ${waiting_time} =  Count Measurement Period  ${GNB_OAM_IP}  ${COUNTER_PERIOD}
    ...  user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Log  Wait ${waiting_time}s till new period of counter is started...    console=True
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.


Attenuator Setup
    Set Test Variable  ${ATTENUATOR_SET}  True
    Set Attenuation For All Cells  100%
    Set Attenuation  ${CELL_ALIAS}  ${0}


Step 1: Start Wireshark Logs
    Log  \n==== Step 1: Start Wireshark Logs ====  console=True

    Set Test Variable  ${TCPDUMP_STARTED}  True
    Start Wireshark Log Collection For IWK Test
    ...  options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...  replace_enb=False  replace_gnb=False


Step 2: Start SIP Logs Collecting
    Log  \n==== Step 2: Start SIP Logs Collecting ====  console=True
    ${nr_cell_list} =  Create List  ${NR_CELL_ID}

    ${nr_log_profile} =  Create List  cp_5g
    ${monitoring_profiles} =  Create List  5g-full-call-scenarios  sip-signalling-vonr
    ${profiles_dictionary} =  Create Dictionary  gnb_custom_profile=${nr_log_profile}
    ...  monitoring_profiles=5g-full-call-scenarios

    _start dcap helper  ${nr_cell_list}  ${profiles_dictionary}
    Log  Waiting for traces to change status to 'Running'  console=True
    Wait Until Keyword Succeeds  ${MAX_DCAP_LOGS_DELAY}  5s  Check If Traces Are Running

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL' and ${DCAP_STARTED}
    ...  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}


Check If Traces Are Running
    ${trace_status} =  Get Trace Info By ID  trace_id=${TRACE_ID}  connection=dcap_collector
    Should Be Equal As Strings  ${trace_status['status']}  running
    ...  msg=Trace status is ${trace_status['status']}. Should be: 'running'.
    Log  Trace status ${trace_status['status']}  console=True


Stop DCAP Traces and Download Logs
    [Timeout]  30 min
    [Arguments]  ${trace_id}

    Log  Stopping DCAP traces...  console=True
    dcap_manager.Stop Trace  trace=${trace_id}
    Set Test Variable  ${DCAP_STARTED}  False
    Log  Downloading logs...  console=True
    ${dcap_logs_path} =  dcap_manager.Download Logs  trace=${trace_id}  target_dir=${LOG_PATH}/dcap_logs
    Log  Logs downloaded to ${dcap_logs_path}.  console=True
    Set Test Variable  ${DCAP_LOGS_PATH}  ${dcap_logs_path}
    dcap_manager.Teardown


_start dcap helper
    [Arguments]  ${nr_cell_list}  ${profiles_dictionary}  ${user}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}

    Log  Connecting to DCAP server IP=${DCAP_HOST['ip']} on port=${DCAP_HOST['port']}  console=True
    dcap_manager.Connect To  host=${DCAP_HOST['ip']}  port=${DCAP_HOST['port']}
    ...  user=${DCAP_HOST['login']}  passwd=${DCAP_HOST['password']}

    Log  Using profiles:\n${profiles_dictionary}.\nStarting new trace for IP ${GNB_OAM_IP}...  console=True
    Set Test Variable  ${DCAP_STARTED}  True
    ${trace_id} =  dcap_manager.Start New Trace  mplane=${GNB_OAM_IP}  user=${user}  passwd=${password}
    ...  port=443  nr_cells=${nr_cell_list}  log_profile=${profiles_dictionary}
    Set Test Variable  ${TRACE_ID}  ${trace_id}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  dcap_manager.Stop Trace  trace=${trace_id}
    ...  AND  dcap_manager.Teardown
    ...  AND  Set Test Variable  ${DCAP_STARTED}  False


Step 3: Perform VoNR
    Log  \n==== Step 3: Perform VoNR ====  console=True

    Log  Performing attach to ${NR_CALL_CELL_ID}...  console=True
    Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}  connection=${CONNECTION}  apn=${APN_CONTAINS}  ue_type=${UE_TYPE}
    ...  lte_cell=False
    ${all_ue_data} =  Get UE Info  NR_UE  ALL
    Start Voice Call  vc_alias=VOICE_CALL  ue_alias=NR_UE  to=${PHONE_NUMBER}  duration=${CALL_DURATION}s
    Log  Voice call running...  console=True
    ${ue_info_check} =  Evaluate  ${CALL_DURATION} - 30
    Sleep  ${ue_info_check}s
    ${all_ue_data} =  Get UE Info  NR_UE  ALL
    #TODO use 'Await Voice Call Finish  VOICE_CALL' after UTETAF-6375 is done
    [Teardown]  Run Keywords
    ...  Run Keyword And Continue On Failure  Stop Voice Call  VOICE_CALL
    ...  AND  Detach_Ue  NR_UE
    ...  AND  Log  Wait for UE to detach.  console=True
    ...  AND  Sleep  30s  reason=Wait in case detach does not happen immedietly after KW so it is caught in logs.


Step 4: Stop DCAP Traces and Download Logs
    Log  \n==== Step 4: Stop DCAP Traces and Download Logs ====  console=True
    ${waiting_time} =  Count Measurement Period  ${GNB_OAM_IP}  ${COUNTER_PERIOD}  delta=30
    ...  user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Set Test Variable  ${WAITING_TIME_NEEDED}  ${waiting_time}
    ${start_time} =  BuiltIn.Get Time  epoch
    Set Test Variable  ${START_TIME}  ${start_time}
    Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}


Step 5: Stop Wireshark Logs
    Log  \n==== Step 5: Stop Wireshark Logs ====  console=True

    ${tcpdump_path} =  Stop Wireshark Log Collection For IWK Test
    Set Test Variable  ${TCPDUMP_PATH}  ${tcpdump_path}
    Set Test Variable  ${TCPDUMP_STARTED}  False


Step 6: Check If VoNR Was Performed
    Log  \n==== Step 6: Check If VoNR Was Performed ====  console=True

    ${display_filter} =  Set Variable  ngap && ngap.qosFlowIdentifier == 1 && ngap.NGAP_PDU == 1
    ${result} =  Run Process
    ...  command=tshark -r ${TCPDUMP_PATH} -Y "${display_filter}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${TCPDUMP_PATH} -Y "${display_filter}" |wc -l.\nError message: ${result.stderr}
    Run Keyword And Continue On Failure  Should Be True  ${result.stdout} == 1
    ...  msg=Number of packets indicationg succesfully started VoNR call (display filter: ${display_filter}) is !=1. Please verify tcpdump logs.
    Log  Messages found in pcap logs with display filter: ${display_filter}.  console=True


Step 7: Check If VoNR Was Finished Correctly
    Log  \n==== Step 7: Check If VoNR Was Finished Correctly ====  console=True

    ${display_filter} =  Set Variable  ngap.pDUSessionID != 1 && ngap.nas == 0 && ngap.id == 137 && ngap.procedureCode == 26
    ${result} =  Run Process
    ...  command=tshark -r ${TCPDUMP_PATH} -Y "${display_filter}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${TCPDUMP_PATH} -Y "${display_filter}" |wc -l.\nError message: ${result.stderr}
    Run Keyword And Continue On Failure  Should Be True  ${result.stdout} > 0
    ...  msg=Number of packets indicationg succesfully finished VoNR call (display filter: ${display_filter}) is <=0. Please verify tcpdump logs.
    Log  Message PDUSessionResourceRelease with nas: normal-release (0) was found in pcap logs (display filter: ${display_filter}).  console=True

    ${display_filter} =  Set Variable  ngap.nas == 2
    ${result} =  Run Process
    ...  command=tshark -r ${TCPDUMP_PATH} -Y "${display_filter}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${TCPDUMP_PATH} -Y "${display_filter}" |wc -l.\nError message: ${result.stderr}
    Run Keyword And Continue On Failure  Should Be True  ${result.stdout} > 0
    ...  msg=Number of packets indicationg succesfully finished VoNR call (display filter: ${display_filter}) is <=0. Please verify tcpdump logs.
    Log  Message UEContextRelease with nas: deregister (2) found in pcap logs (display filter: ${display_filter}).  console=True


Step 8: Counter Verification
    Log  \n==== Step 8: Counter Verification ====  console=True

    ${stop_time} =  Get Time  epoch
    ${waiting_time_left} =  Evaluate  ${WAITING_TIME_NEEDED} - (${stop_time} - ${START_TIME})
    Run Keyword If  ${waiting_time_left} > 0  Run Keywords
    ...  Log  Wait ${waiting_time_left}s till new period of counter is started...  console=True
    ...  AND  Sleep  ${waiting_time_left}s  reason=Wait till new period of counter is started.
    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${LOG_PATH}/pm_counters
    ...  xml_files_left=3  time_interval=15min  intervals=5
    ${counters_list} =  Create List  M55125C09515  M55125C09505  M55113C00003  M55125C09514
    Set Test Variable  ${COUNTERS_LIST}  ${counters_list}
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    ${counters_dict} =  Get Values Of Counters From List  ${LOG_PATH}/pm_counters
    ...                 ${COUNTERS_LIST}
    ...                 MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...                 2

    ${m55125C09515_sum} =  Evaluate  sum([int(i) for i in ${counters_dict['M55125C09515']}])
    ${m55125C09505_sum} =  Evaluate  sum([int(i) for i in ${counters_dict['M55125C09505']}])
    ${m55113C00003_sum} =  Evaluate  sum([int(i) for i in ${counters_dict['M55113C00003']}])
    ${m55125C09514_sum} =  Evaluate  sum([int(i) for i in ${counters_dict['M55125C09514']}])

    Run Keyword And Continue On Failure  Should Be True  ${m55125C09515_sum} == 0
    ...  msg=Counter M55125C09515 in one or more period is different from 0. Please check if Voice call was performed correctly.
    Run Keyword And Continue On Failure  Should Be True  ${m55125C09505_sum} == 0
    ...  msg=Counter M55125C09505 in one or more period is different from 0. Please check if Voice call was performed correctly.
    Run Keyword And Continue On Failure  Should Be True  ${m55113C00003_sum} == 0
    ...  msg=Counter M55113C00003 in one or more period is different from 0. Please check if Voice call was performed correctly.
    Run Keyword And Continue On Failure  Should Be True  ${m55125C09514_sum} == 1
    ...  msg=Sum for counter M55125C09514 is different from 1. Please check if Voice call was performed correctly.


Step ${index}: Check BTS State
    Log  \n==== Step ${index}: Check BTS State ====  console=True

    _verify bts states for iwk test helper  ignored_alarms=${IGNORED_ALARMS}  alias=gNB
    Set Test Variable  ${CHECK_IN_TEARDOWN}  False
    taf.ul.alarms_watchdog.Check Detected Alarms


Step 10: Extract EMIL logs
    Log  \n==== Step 10: Extract EMIL logs ====  console=True

    Set Test Variable  ${CHECK_IN_TEARDOWN}  True
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

    ${all_messages_appeared} =  Check SIP Messages  ${file_paths}  ${LOG_PATH}/misc_logs/merged.csv
    Should Be True  ${all_messages_appeared}  msg=Not all messages were found in DCAP logs.


Convert Files To CSV On Remote Windows Host
    ${windows_sack_path_for_5G} =  Copy SACK To EMIL Host

    ${converted_files_dir} =  Join Path  ${WINDOWS_TEMP_LOGS_DIR}  converted
    ${win_file_paths} =  Copy EMIL Logs To Windows  ${LOG_PATH}/dcap_logs/dcap_unzipped
    ...                                             ${WINDOWS_TEMP_LOGS_DIR}
    ...                                             ${EMIL_HOST['ip']}  ${EMIL_HOST['login']}  ${EMIL_HOST['password']}
    Log  File paths on Windows:\n${win_file_paths}  console=True

    SSHLibrary.Open Connection  ${EMIL_HOST['ip']}
    SSHLibrary.Login  ${EMIL_HOST['login']}  ${EMIL_HOST['password']}
    SSHLibrary.Directory Should Exist  ${windows_sack_path_for_5G}
    FOR  ${index}  ${file_path}  IN ENUMERATE  @{win_file_paths}
        Log  \nFile path=${file_path}  console=True
        ${command} =  Catenate
        ...  "${WINDOWS_PATH_TO_EMIL_EXE}" ${file_path} -tocsvrnd PerTrace
        ...  -Destination ${converted_files_dir} -SackPath ${windows_sack_path_for_5G} -AutoClose
        Log  command=${command}  console=True
        ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command
        ...  ${command}  return_stderr=True  return_rc=True  timeout=600s
        Log  stdout=${stdout}  console=True
        ${regexp_converted_files_dir} =  Replace String  ${converted_files_dir}  /  .{1,2}
        ${_}  ${file_name}=  Split String From Right  ${file_path}  separator=/  max_split=1
        ${file_name} =  Replace String  ${file_name}  .5gm  .{1,4}csv
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


Copy SACK To EMIL Host
    ${windows_sack_path} =  Get SACK Directory Path For Parent Directory  ${WINDOWS_SACK_PARENT_PATH}
    ${unzipped_sack_path} =  Extract SACKS From DCAP  ${LOG_PATH}/dcap_logs/dcap_unzipped
    ...  ${windows_sack_path}  dir_search_str=sacks

    ${disc}  ${path} =  Split String  ${windows_sack_path}  separator=/  max_split=1
    ${disc} =  Evaluate  '${disc}'.replace(':','').lower()
    ${cygdrive_sack_path} =  Join Path  /cygdrive  ${disc}  ${path}

    SSHLibrary.Open Connection  ${EMIL_HOST['ip']}
    SSHLibrary.Login  ${EMIL_HOST['login']}  ${EMIL_HOST['password']}
    Log  Copying SACK from ${unzipped_sack_path} to ${cygdrive_sack_path}...  console=True
    SSHLibrary.Put Directory  ${unzipped_sack_path}  ${cygdrive_sack_path}    recursive=True
    Log  Sack was successfully copied to Windows PC.  console=True

    ${windows_sack_path_for_5G} =  Join Path  ${windows_sack_path}  5G
    Log  Sack path for 5G: ${windows_sack_path_for_5G}  console=True

    [Teardown]  SSHLibrary.Close All Connections
    [Return]  ${windows_sack_path_for_5G}


Get SACK Directory Path For Parent Directory
    [Arguments]  ${parent_dir}
    ${sw_version} =  Get SW Version  ${USER_SW_VERSION}  alias=${CONNECTION}
    ${branch}  ${version}=  Split String  ${sw_version}  separator=_  max_split=1
    ${version} =  Remove String  ${version}  ENB_
    ${path} =  Join Path  ${parent_dir}  ${branch}_IDA_${version}
    [Return]  ${path}


Move and Rename CSV Files
    [Arguments]  ${converted_files_dir}  ${index}

        ${files} =  SSHLibrary.List Files In Directory  ${converted_files_dir}
        Log  Files in ${converted_files_dir}: ${files}  console=True

        ${temp_dir_exists} =  Run Keyword And Return Status
        ...  SSHLibrary.Directory Should Exist  ${converted_files_dir}/converted/
        ${stdout}  ${stderr}  ${rc} =  Run Keyword If  not ${temp_dir_exists}  SSHLibrary.Execute Command
        ...  mkdir ${converted_files_dir}/converted/  return_stdout=True  return_stderr=True  return_rc=True
        Run Keyword If  not ${temp_dir_exists}  Should Be True  ${rc} == 0 and '${stderr}' == ''
        ...  msg=RC is not equal to 0. RC=${rc}. Error: ${stderr}

        FOR  ${file}  IN  @{files}
            ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command
            ...  mv ${converted_files_dir}/${file} ${converted_files_dir}/converted/${index}_${file}
            ...  return_stdout=True  return_stderr=True  return_rc=True
            Should Be True  ${rc} == 0 and '${stderr}' == ''
            ...  msg=RC is not equal to 0. RC=${rc}. Error: ${stderr}
        END
        ${files} =  SSHLibrary.List Files In Directory  ${converted_files_dir}/converted
        Log  Files in ${converted_files_dir}/converted: ${files}  console=True


TC Setup
    IWK Test Setup  start_wireshark=False  local_enb_connection=False  single_bts=True
    ...  gnb_ignored_alarms=${IGNORED_ALARMS}
    Alarm Watchdog Setup  ${VONR_ALLOWED_FAULT_IDS}


TC Teardown
    Run Keyword If  ${DCAP_STARTED}  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}
    Run Keyword If  ${ATTENUATOR_SET}  Set Attenuation For All Cells  100%
    Run Keyword If  '${UE_TYPE}' == 'iphone'  Collect And Save Baseband Logs For Iphone  NR_UE
    Run Keyword If  ${TCPDUMP_STARTED}  Stop Wireshark Log Collection For IWK Test
    Alarm Watchdog Teardown  ${CHECK_IN_TEARDOWN}
    IWK Test Teardown  stop_wireshark=False  delta_exists=False  local_enb_connection=False  single_bts=True
