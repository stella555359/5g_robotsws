*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     OperatingSystem
Library     ArchiveLibrary
Library     taf.ul.alarms_watchdog
Library     taf.ul.bts_components.Smod    WITH NAME    bts_components
Library     taf.ul.bts_components.invoke_shell.InvokeShellHandler.InvokeSshHandler                  WITH NAME    invoke_shell
Library     taf.transport.ssh    WITH NAME    transport_ssh
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${SNAPSHOT_ALLOWED_FAULT_IDS}      # List of fault IDs allowed to appear during test on BTS, e.g. 4655  4654

*** Keywords ***
TC__Rjio_E2E_21_Snapshot_Content_Compare

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-marcel.behen@nokia.com
    ...         PHASE-CDRT   SW-SBTS24R1    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Looped Steps
    Step 8: Check BTS State


Looped Steps
    [Tags]  robot:continue-on-failure
    FOR  ${serial_number}  IN  @{RMOD_SERIAL_NUMBERS}
        Set Test Variable  ${SERIAL_NUMBER}  ${serial_number}
        Log  \n----- Performing operations for: ${SERIAL_NUMBER} -----  console=True
        Test Steps
        Log  \n----- END of operations for: ${SERIAL_NUMBER} -----\n  console=True
    END


Test Steps
    Step 1: Connect To SMOD And Get RMOD Data
    Step 2: Connect To RMOD Via FHNET Container
    Step 3: Get RFSW Log File List From RMOD
    Step 4: Collect Snapshot And Get RFSW File List
    Step 5: Verify If Every RFSW Log Exists In Snapshot
    Step 6: Check Startup Runtime And SOAP File In RMOD Logs
    [Teardown]  Step 7: Close Connection To RMOD


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Test Variable  ${CHECK_IN_TEARDOWN}  True

    ${rmod_serial_numbers} =  Get Serial Numbers Of RMODs
    Set Test Variable  ${RMOD_SERIAL_NUMBERS}  ${rmod_serial_numbers}

    ${rmods_amount} =  Get Length  ${rmod_serial_numbers}
    Set Test Variable  ${RMODS_AMOUNT}  ${rmods_amount}

    ${rmod_index_dictionary} =  Create Mapping For RMODs In Configuration File
    Set Test Variable  ${RMOD_INDEX_DICTIONARY}  ${rmod_index_dictionary}

    ${mrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${MRBTS_ID}  ${mrbts_id}

    Wait For 10 Min Before Starting Test


Get Serial Numbers Of RMODs
    ${hw_info} =  Get Detected HW Info  connection=gNB
    ${rmod_serial_numbers} =  Evaluate  [x['serialNumber'] for x in ${hw_info['radioModules']['rmod']}]
    [Return]  ${rmod_serial_numbers}


Create Mapping For RMODs In Configuration File
    ${rmod_index_dictionary} =  Create Dictionary
    FOR  ${index}  IN RANGE  0  ${rmods_amount}
        Set To Dictionary  ${rmod_index_dictionary}
        ...  ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[${index}].serial_number}=${index}
    END
    [Return]  ${rmod_index_dictionary}


Wait For 10 Min Before Starting Test
    ${current_time} =  Run  date
    Log  Waiting 600s (start: ${current_time})...  console=True
    Sleep  600  reason=Waiting for logs in snapshot in case of reset before test.


Step 1: Connect To SMOD And Get RMOD Data
    Log  \n==== Step 1: Connect To SMOD And Get RMOD Data ====  console=True

    Log  Getting RMOD data...  console=True
    ${rmod_ip}  ${rmod_type} =  Get RMOD Data
    Set Test Variable  ${RMOD_TYPE}  ${rmod_type}
    Set Test Variable  ${RMOD_IP}  ${rmod_ip}
    Log  Data for ${SERIAL_NUMBER}:\nIP: ${RMOD_IP}\nRadio type: ${RMOD_TYPE}\n  console=True

    Log  Connecting to SMOD (${tl.gnbs[0].cu.oam_ssh_connection_details.addr})...  console=True
    transport_ssh.Connect To  hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...  alias=smod_connection
    Log  Connected.  console=True

    ${container_id} =  Get FHNET Container ID
    Set Test Variable  ${CONTAINER_ID}  ${container_id}
    Log  Container ID: ${CONTAINER_ID}.  console=True
    ${stdout} =  transport_ssh.Execute  lxc-ls  connection=smod_connection
    Should Contain  ${stdout}  ${container_id}

    [Teardown]  transport_ssh.Disconnect  connection=smod_connection


Get RMOD Data
    bts_components.Connect To
    ...  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...  ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    alias=rmod_data
    ${ru_ip} =  Get RMOD IP  ${SERIAL_NUMBER}
    ${ru_type} =  Get RMOD Type  ${ru_ip}
    [Teardown]  bts_components.Close Connection
    [Return]  ${ru_ip}  ${ru_type}


Get RMOD IP
    [Arguments]  ${ru_serial}
    ${rus_ips_and_serials} =  bts_components.Get RUs IPs And Serial Numbers
    ${ru_ip} =  Evaluate  [x for x in @{rus_ips_and_serials} if '${ru_serial}' in x[1]]
    [Return]  ${ru_ip[0][0]}


Get RMOD Type
    [Arguments]  ${ru_ip}
    ${rus_ips_and_types} =  bts_components.Get RUs IPs And RU Type
    ${ru_type} =  Evaluate  [x for x in @{rus_ips_and_types} if '${ru_ip}' in x[0]]
    [Return]  ${ru_type[0][1]}


Get FHNET Container ID
    [Documentation]
    ...  This KW gets ID of FHNET container.
    ...
    ...  | **Author:** stella.lin@nokia-sbell.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get FHNET Container ID

    ${hostname} =  transport_ssh.Execute  command=hostname  connection=smod_connection
    ${container_id} =  Set Variable If
    ...  'fct-0a' in '''${hostname}''' or 'asc-0a' in '''${hostname}'''    0x1018
    ...  'fct-4a' in '''${hostname}'''                                     0x2018
    ...  None
    [Return]   ${container_id}


Step 2: Connect To RMOD Via FHNET Container
    Log  \n==== Step 2: Connect To RMOD Via FHNET Container ====  console=True

    Connect To RU Via FHNET Container  ${RMOD_IP}  ${SERIAL_NUMBER}  container_id=${CONTAINER_ID}


Step 3: Get RFSW Log File List From RMOD
    Log  \n==== Step 3: Get RFSW Log File List From RMOD ====  console=True

    ${rmod_logs_list}  ${rfsw_log_path_on_vm} =  Get RFSW Log File List From RMOD
    Set Test Variable  ${RMOD_LOGS_LIST}  ${rmod_logs_list}
    Set Test Variable  ${RFSW_LOG_PATH}  ${rfsw_log_path_on_vm}


Step 4: Collect Snapshot And Get RFSW File List
    Log  \n==== Step 4: Collect Snapshot And Get RFSW File List ====  console=True

    ${logs_on_snapshot} =  Collect Snapshot And Get RFSW File List  ${SERIAL_NUMBER}
    Set Test Variable  ${LOGS_ON_SNAPSHOT}  ${logs_on_snapshot}


Step 5: Verify If Every RFSW Log Exists In Snapshot
    Log  \n==== Step 5: Verify If Every RFSW Log Exists In Snapshot ====  console=True

    ${missing_logs_list} =  Create List
    FOR  ${rmod_log}  IN  @{RMOD_LOGS_LIST}
       ${rmod_log_name} =  Fetch From Left  ${rmod_log}  marker=.
       ${log_exists} =  Run Keyword And Return Status  Should Contain Match  ${LOGS_ON_SNAPSHOT}  regexp=.*${rmod_log_name}.*
       Run Keyword If  not ${log_exists}  Append to List  ${missing_logs_list}  ${rmod_log_name}
    END
    Should Be Empty  ${missing_logs_list}  msg=Names of logs that were not found in snapshot logs list: ${missing_logs_list}


Step 6: Check Startup Runtime And SOAP File In RMOD Logs
    Log  \n==== Step 6: Check Startup Runtime And SOAP File In RMOD Logs ====  console=True

    Check Startup Runtime And SOAP File In RMOD Logs  ${RFSW_LOG_PATH}  ${RMOD_TYPE}
    ${unzipped_rfsw_path}  ${_} =  Split Extension  ${RFSW_LOG_PATH}
    OperatingSystem.Run  rm -rf ${unzipped_rfsw_path}


Step 7: Close Connection To RMOD
    Log  \n==== Step 7: Close Connection To RMOD ====  console=True

    Run Keyword And Ignore Error  invoke_shell.Close Connection
    Log  Connection closed.  console=True


Step 8: Check BTS State
    Log  \n==== Step 8: Check BTS State ====  console=True

    _verify bts states for iwk test helper  ignored_alarms=${IGNORED_ALARMS}  alias=gNB
    Set Test Variable  ${CHECK_IN_TEARDOWN}  False
    taf.ul.alarms_watchdog.Check Detected Alarms


Connect To RU Via FHNET Container
    [Documentation]
    ...  This KW connects with RMOD via FHNET container.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW connects with RMOD via FHNET container. It gets credential from __init__.py file.
    ...
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter               | Man. | Description                                                             |
    ...  +=========================+======+=========================================================================+
    ...  | ru_ip_addr              | Yes  | RMOD IP address.                                                        |
    ...  +-------------------------+------+-------------------------------------------------------------------------+
    ...  | serial_number           | Yes  | RMOD serial number.                                                     |
    ...  +-------------------------+------+-------------------------------------------------------------------------+
    ...  | container_id            | No   | ID of FHNET container. Default value: 0x1018.                           |
    ...  +-------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Connect To RU Via FHNET Container  72.22.0.10  1M123456789

    [Arguments]  ${ru_ip_addr}  ${serial_number}  ${container_id}=0x1018
    ${ru_username}  ${ru_password} =  Get Credentials From Init File  ${serial_number}

    invoke_shell.Connect To RMOD                    ip=${ru_ip_addr}
    ...                                             username=${ru_username}
    ...                                             password=${ru_password}
    ...                                             container=${container_id}


Get Credentials From Init File
    [Arguments]  ${serial_number}
    ${index} =  Get From Dictionary  ${RMOD_INDEX_DICTIONARY}  ${serial_number}
    [Return]  ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[${index}].default_ssh_connection_details.username}
    ...  ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[${index}].default_ssh_connection_details.password}


Get RFSW Log File List From RMOD
    [Documentation]
    ...  This KW gets RFSW file list from RMOD.
    ...
    ...  | **Author:** stella.lin@nokia-sbell.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW gets RFSW file list from RMOD. It uses 'AaSysComUserDeregister succeed!' string to verify
    ...  if logs collection was finished. It requires 'invoke_shell.Connect To RMOD' to be run before it.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | download_dir        | No   | Absolute path to directory where file will be saved.                    |
    ...  |                     |      | Default value: ${LOG_PATH}/misc_logs.                                   |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | timeout             | No   | Timeout in seconds for collecting logs on RMOD. Default value: 300.     |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get RFSW Log File List From RMOD

    [Arguments]  ${download_dir}=${LOG_PATH}/misc_logs  ${timeout}=300

    ${timestamp} =  Run  date +%H-%M-%S
    Log  Capturing RFSW log on RMOD...  console=True
    ${timeout} =  Convert To Integer  ${timeout}
    invoke_shell.Send Command And Return Output
    ...  command=cd /usr/bin;ccsShell.sh log -a -z /ram/rfsw_log_${timestamp}.zip
    ...  timeout=${timeout}  repetition_interval=${5}  expected_phrase=AaSysComUserDeregister succeed!
    Sleep  10 s

    Log  Downloading RFSW logs to VM...  console=True
    ${rfsw_log_path_on_vm} =  Download RMOD File To VM  ru_file_path=/ram/rfsw_log_${timestamp}.zip
    ...  download_dir=${download_dir}

    Log  Getting RFSW Log File List...  console=True
    ${unzip_result} =  Run  unzip -l ${rfsw_log_path_on_vm} |tail -n +2
    ${vaild_lines} =  Get Lines Matching Regexp  ${unzip_result}  \\d+11_.*  partial_match=true
    ${rfsw_log_names} =  Get Regexp Matches  ${vaild_lines}  ([2-9]011)?_.*
    [Return]   ${rfsw_log_names}  ${rfsw_log_path_on_vm}


Download RMOD File To VM
    [Documentation]
    ...  This KW downloads RFSW logs from RMOD to VM.
    ...
    ...  | **Author:** stella.lin@nokia-sbell.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  **Full Description:**
    ...
    ...  This KW downloads RFSW logs from RMOD to VM. The file is first sent from RMOD to /ram directory of SMOD
    ...  and then from SMOD to ${download_dir} on VM. File is removed from RMOD at the end of this KW.
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | ru_file_path        | Yes  | Absolute path to RFSW logs ZIP file on RMOD.                            |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | download_dir        | No   | Absolute path to directory where file will be saved.                    |
    ...  |                     |      | Default value: ${LOG_PATH}/misc_logs.                                   |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Download RMOD File To VM  /ram/rfsw_log_10-55-10.zip

    [Arguments]  ${ru_file_path}  ${download_dir}=${LOG_PATH}/misc_logs

    ${ru_username}  ${ru_password} =  Get Credentials From Init File  ${serial_number}
    ${ru_file_name} =  Set Variable  ${ru_file_path.split('/')}[-1]

    Log  Downloading RMOD file to VM...  console=True
    invoke_shell.Get File From RMOD To SMOD  filename=${ru_file_name}  smod_path=/ram  rmod_path=/ram
    ...  rmod_ip=${RMOD_IP}  username=${ru_username}  password=${ru_password}
    invoke_shell.Download File From SMOD To VM  filename=${ru_file_name}  smod_path=/ram  local_path=${download_dir}
    invoke_shell.Send Command And Return Output  command=rm -rf ${ru_file_path}

    _remove file from smod helper  ${ru_file_name}

    ${local_file_path} =  Join Path  ${download_dir}  ${ru_file_name}

    [Return]   ${local_file_path}


_remove file from smod helper
    [Arguments]  ${ru_file_name}
    Log  Connecting to SMOD (${tl.gnbs[0].cu.oam_ssh_connection_details.addr})...  console=True
    transport_ssh.Connect To  hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...  alias=smod_connection
    Log  Connected.  console=True
    ${stdout} =  transport_ssh.Execute  rm -rf /ram/${ru_file_name}  connection=smod_connection
    [Teardown]  transport_ssh.Disconnect  connection=smod_connection


Collect Snapshot And Get RFSW File List
    [Arguments]  ${ru_serial_number}  ${snapshot_zip_file_path}=${LOG_PATH}/snapshots/snapshot
    ...  ${snapshot_unzip_file_path}=${LOG_PATH}/snapshots/unzipped

    ${timestamp} =  Run  date +%H-%M-%S
    Log  Collecting snapshot...  console=True
    Collect Snapshot  ${snapshot_zip_file_path}_${timestamp}  timeout=1h  connection=gNB
    Log  DONE\nExtracting snapshot...  console=True
    ArchiveLibrary.Extract ZIP File  ${snapshot_zip_file_path}_${timestamp}  ${snapshot_unzip_file_path}_${timestamp}
    Log  DONE\nGetting RFSW file list...  console=True
    ${stdout} =  OperatingSystem.Get File  ${snapshot_unzip_file_path}_${timestamp}/snapshot_file_list.txt
    ${is_new}=  Evaluate  '${RELEASE_LOCAL}' >= 'SBTS25R2'
    ${rfsw_log_names} =  Run Keyword If  '${is_new}' == 'True'
    ...  Get Regexp Matches  ${stdout}  BTS${MRBTS_ID}\\_${ru_serial_number}\\_.*
    ...  ELSE
    ...  Get Regexp Matches  ${stdout}  BTS\\_${ru_serial_number}\\_.*
    Log  DONE  console=True
    [Return]  ${rfsw_log_names}
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'PASS'
    ...  OperatingSystem.Run  rm -rf ${snapshot_unzip_file_path}_${timestamp}


Check Startup Runtime And SOAP File In RMOD Logs
    [Documentation]
    ...  This KW checks if startup, runtime and SOAP files are found in RFSW logs.
    ...
    ...  | **Author:** tingting.zhong@nokia-sbell.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if startup, runtime and SOAP files are found in RFSW logs. Number for each RMOD
    ...  depends on number of Made units, e.g. for AQQJ, it should be 8, because its HW family is cMAAr6.2_32T32R.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | rfsw_log_path       | Yes  | Absolute path to RFSW logs ZIP file.                                    |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | rmod_type           | Yes  | Type of RMOD, e.g. AHPJ                                                 |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check Startup Runtime And SOAP File In RMOD Logs  /home/ute/logs/rfsw_log_10-55-10.zip  AQQJ

    [Arguments]    ${rfsw_log_path}  ${rmod_type}
    ${ru_unit_num}    Set Variable If
    ...     '${rmod_type}'=='AQQA'       8
    ...     '${rmod_type}'=='AQQY'       8
    ...     '${rmod_type}'=='AQQC'       8
    ...     '${rmod_type}'=='AQQN'       8
    ...     '${rmod_type}'=='AQQL'       8
    ...     '${rmod_type}'=='AQQQ'       8
    ...     '${rmod_type}'=='AQQS'       8
    ...     '${rmod_type}'=='AQQK'       8
    ...     '${rmod_type}'=='AQQJ'       8
    ...     '${rmod_type}'=='AQHB'       8
    ...     '${rmod_type}'=='AZNA'       0
    ...     '${rmod_type}'=='AZHA'       0
    ...     '${rmod_type}'=='AHPB'       0
    ...     '${rmod_type}'=='AZQF'       0
    ...     '${rmod_type}'=='AZQD'       0
    ...     '${rmod_type}'=='AZQO'       0
    ...     '${rmod_type}'=='AZQJ'       0
    ...     '${rmod_type}'=='AHLOA'      0
    ...     '${rmod_type}'=='AWHKB'      0
    ...     '${rmod_type}'=='AWHQX'      0
    ...     '${rmod_type}'=='AWHQN'      0
    ...     '${rmod_type}'=='AWHQ2'      0
    ...     '${rmod_type}'=='AWHHD'      0
    ...     '${rmod_type}'=='AWHHF'      0
    ...     '${rmod_type}'=='AHPF'       0
    ...     '${rmod_type}'=='AHPH'       0
    ...     '${rmod_type}'=='AHPJ'       0
    ...     '${rmod_type}'=='AWHQU'      0
    ...     4
    ${ru_log_path} =  Get Substring  ${rfsw_log_path}  0  -4
    Log  Extracting RFSW logs...  console=True
    Extract Zip File  ${ru_log_path}.zip  ${ru_log_path}
    Log  DONE\n Checking startup, runtime and SOAP logs...  console=True
    ${soap_info} =  Run  command=ls '${ru_log_path}' | grep "1011_UnitOAM_SOAP_Log.zip"
    ${startup_info} =  Run  command=ls '${ru_log_path}' | grep "1*startup\."
    ${runtime_info} =  Run  command=ls '${ru_log_path}' | grep "1*runtime\."
    Should Contain  ${soap_info}  1011_UnitOAM_SOAP_Log
    FOR  ${index}  IN RANGE  ${ru_unit_num}+1
        Should Contain  ${startup_info}  1${index}11
        Should Contain  ${startup_info}  startup
        Should Contain  ${runtime_info}  1${index}11
        Should Contain  ${runtime_info}  runtime
    END
    Log  DONE  console=True


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  gnb_ignored_alarms=${IGNORED_ALARMS}
    Alarm Watchdog Setup  ${SNAPSHOT_ALLOWED_FAULT_IDS}


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True

    Alarm Watchdog Teardown  ${CHECK_IN_TEARDOWN}
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True
