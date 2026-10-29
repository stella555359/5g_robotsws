*** Settings ***
Documentation   TBD.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

Library     DateTime
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.transport.ssh  WITH NAME  tafssh
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu


*** Keywords ***
Black Box Common Preconditions
    [Arguments]  ${rmod_ids}  ${scfc_file_path}  ${logs_dir_path}
    [Documentation]
    ...  Description:
    ...  Common Preconditions for all blackbox tests.
    ...  Sets Topology, logs dir path, vdu pod name, cells counts.
    ...  Checks tested RU and sets it into rflist list
    ...  Gets Cloudserver ip for connection to RU on cloud.
    ...  Creates radio_values dictionary with informations that are needed in tests (can add more if needed)
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    vDU Rest Login
    ${mrbts_id}  vDU Get MRBTS Id    vdu_login=False
    Set Test Variable    ${MRBTS_ID}    ${mrbts_id}
    Set Test Variable    ${SCFC_FILE_PATH}    ${scfc_file_path}
    Set Test Variable  ${LOGS_DIR_PATH}  ${logs_dir_path}
    Set Test Variable  ${TOPOLOGY}  ${tl.tl_cloud_topology}
    ${vdu_pod_name}  Get Vdu Pod Name
    Set Test Variable  ${VDU_POD_NAME}  ${vdu_pod_name}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${CELLS_COUNT}  ${cells_count}
    ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${rmod_ids}
    ${rf_list}=  Run Keyword If  ${RF_status}  Split String  string=${rmod_ids}  separator=|
    Set Test Variable  ${RF_LIST}  ${rf_list}
    ${ru_list_length}  Get Length  ${rf_list}
    Run Keyword If  ${ru_list_length}==1  Set Test Variable  ${RU_SN}  ${rf_list[0]}
    ${vdu_k8s_connection_params}  Get vDU K8s Master Node Connection Parameters From Init File
    Set Test Variable  ${CLOUD_SERVER_IP}  ${vdu_k8s_connection_params['ip_addr']}
    ${rmod_status}=  vdu.Get Rmods Status
    ${rmod_info}=  Create Dictionary
    Set Test Variable  ${rmod_info}
    FOR  ${radio}  IN  @{rmod_status}
      Log    ${radio}
      ${radio_values}  Create Dictionary
      Set To Dictionary  ${radio_values}
      ...  dist_names=${radio}[dist_names]
      ...  product_code=${radio}[product_code]
      ...  product_name=${radio}[product_name]
      ...  id=${radio}[id]
      ...  hardware_release=${radio}[hardware_release]
      ...  active_sw_build=${radio}[active_sw_build]
      ...  active_sw_version=${radio}[active_sw_version]
      ...  serial_number=${radio}[serial_number]
      Set To Dictionary  ${rmod_info}
      ...  ${radio}[serial_number]=${radio_values}
    END
    Log    ${rmod_info}

Collect Both BBox Files For Radio
    [Arguments]  ${destination_folder_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword that collects blackbox file for RU from snapshot and from RU itself. Checks if they are the same.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | destination_folder_path|  Yes |  Path to the folder where blackbox files will be collected.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com


    Log  ${info_prefix}Collect snapshot from Webem and BBox file from Radio  console=${log_to_console}
    Log  ${destination_folder_path}
      Create Directory  path=${destination_folder_path}
      BBox File Download From RU To Vm  ru_serial_number=${ru_sn}  destination_folder_name=${destination_folder_path}
      Collect Bbox from snapshot  ru_sn=${ru_sn}  dest_folder_name=${destination_folder_path}
      ${rc}  ${output}=  Run And Return Rc And Output  diff -s '${destination_folder_path}/BBOX5_snap' '${destination_folder_path}/BBOX5'
      Should Contain  ${output}  are identical  msg=BBOX Files from RU and Snapshot are not identical!
      Log  ${info_prefix}BBOX files on RU and from snapshot are identical.  console=${log_to_console}
    Run  rm -r -d '${destination_folder_path}/${temp_folder_name}'
    [Return]  ${destination_folder_path}

Collect Bbox from snapshot
    [Arguments]  ${ru_sn}  ${dest_folder_name}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword that collects blackbox file from snapshot for given radio.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_sn                  |  Yes |  Serial number of the radio.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dest_folder_name       |  Yes |  Path to the folder where blackbox files will be collected.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${info_prefix}vDU snapshot is collected now  console=${log_to_console}
    vDU Rest Login
    ${snapshot_download_status}  ${snapshot_path}=  Run Keyword And Ignore Error
    ...  vdu.Get Local Snapshot  directory=${dest_folder_name}
    ...  compressed_or_not=True
    Run Keyword If  '${snapshot_download_status}'=='FAIL'  Fail  msg=Snapshot was not collected from vdu
    Log  ${info_prefix}vDU snapshot has been collected  console=${log_to_console}
    Log  ${info_prefix}Unzipping BBOX file from snapshot from Webem  console=${log_to_console}
    Run  unzip "${snapshot_path}" -d "${dest_folder_name}/${temp_folder_name}"
    File Should Exist  path=${dest_folder_name}/${temp_folder_name}/snapshot_file_list.txt
    ...  msg=Could not find snapshot_file_list.txt
    ${snapshot_file_index}=  Get File  path=${dest_folder_name}/${temp_folder_name}/snapshot_file_list.txt
    ...  encoding=UTF-8
    ...  encoding_errors=strict
    ${radio_snapshot_file_name}=  Get Regexp Matches  ${snapshot_file_index}
    ...  (RU_\\d+)\\.zip:\\s*BTS${MRBTS_ID}_${ru_sn}  1
    ${bbox_file_name}=  Get Regexp Matches  string=${snapshot_file_index}
    ...  pattern=BTS${MRBTS_ID}_${ru_sn}_RMOD_.*_BBOX5_all\\.zip
    Run  unzip '${dest_folder_name}/${temp_folder_name}/${radio_snapshot_file_name}[0].zip' -d '${dest_folder_name}/${temp_folder_name}'
    Run  unzip '${dest_folder_name}/${temp_folder_name}/${bbox_file_name}[0]' -d '${dest_folder_name}/${temp_folder_name}'
    Run  mv '${dest_folder_name}/${temp_folder_name}/BBOX5' '/${dest_folder_name}/BBOX5_snap'

BBox File Download From RU To Vm
    [Arguments]    ${ru_serial_number}  ${destination_folder_name}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword that collects blackbox file from RU and copies it to given folder forr given radio.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_serial_number       |  Yes |  Serial number of the radio.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | destination_folder_name|  Yes |  Path to the folder where blackbox files will be collected.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${info_prefix}Open Connection To RM  console=${log_to_console}
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_serial_number}
    ...  cloud_server_ip=${cloud_server_ip}
    radio.Close SSH Connection
    Log  ${info_prefix}Copying BBOX from RM ${ru_serial_number} to SMOD  console=${log_to_console}
    Run  mkdir ${destination_folder_name}
    Wait Until Keyword Succeeds   60  5  radio.Send File Via SCP
    ...  ru_serial_number=${ru_serial_number}
    ...  direction=to_container
    ...  file_path=/mnt/runtime/BBOX5
    ...  destination_directory=/tmp
    ...  cloud_server_ip=${cloud_server_ip}
    Log  ${info_prefix}Downloading BBOX from SMOD to VM  console=${log_to_console}
    tafssh.Connect To  hostname=${cloud_server_ip}
    ...  username=core
    ...  password=system123
    ...  alias=primary
    tafssh.Send Command  kubectl cp -n cran1 ${VDU_POD_NAME}-oamfh-0:"/tmp/BBOX5" -c ctr-oamfh "/tmp/BBOX5"  connection=primary
    tafssh.Read Output  connection=primary
    tafssh.Download File  remote_path=/tmp/BBOX5
    ...  local_path=${destination_folder_name}/BBOX5
    ...  connection=primary
    tafssh.Send Command  rm /tmp/BBOX5  connection=primary
    radio.Close SSH Connection

Prepare Keys For Black Box Functions Check
    [Arguments]  ${dst_folder}  ${start_string}  ${rf_list}=${RF_LIST}
    [Documentation]
    ...  Description:
    ...  KW prepares 2 dictionaries from black box files for part of black box file, decided by ${start_string}. One dictionary
    ...  is only with keys (parts before : value in black box) and second has key/values pairs.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             |  Yes | Path to the folder with blackbox file.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | start_string           |  Yes  | Start line from black box file from which the dictionaries will be created|
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${keys_dict}  Create Dictionary
    FOR  ${ru_sn}  IN  @{rf_list}
        ${part_list}  Get Part Of Bbox List
        ...  file_path=${dst_folder}/BBOX5_snap
        ...  start_string=${start_string}
        ...  end_string=---
    END
    FOR  ${line}  IN  @{part_list}
        ${item_start}  Evaluate  'Item type' in '${line}'
        ${key}  Run Keyword If  ${item_start}  Set Variable  ${line}
        ...  ELSE  Fetch From Left  ${line}  :
        ${value}  Fetch From Right  ${line}  :
        Set To Dictionary  ${keys_dict}  ${key}  ${value}
    END
    ${only_keys_from_bbox}  Get Dictionary Keys  ${keys_dict}
    [Return]  ${only_keys_from_bbox}  ${keys_dict}

Get Part Of Bbox List
    [Arguments]  ${file_path}  ${start_string}  ${end_string}
    [Documentation]
    ...  Description:
    ...  Keyword returns part of black box file for given values start and end.
    ...  Arguments:
    ...  +===========================+======+=========================================================================+
    ...  | Argument                  | Man. | Description                                                             |
    ...  +===========================+======+=========================================================================+
    ...  | file_path                 |  Yes | Path to blackbox file                                                   |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | start_string              |  Yes | Start String fro which the values should be saved                       |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | end_string                |  Yes | End string from which the values should be no longer saved\             |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${bbox_ru_file}=  Get File  ${file_path}
    ${bbox_part_list}  Create List
    ${check}  Set Variable  ${False}
    ${counter_start}  Set Variable  ${False}
    @{lines}=  Split To Lines  ${bbox_ru_file}
    FOR  ${line}  IN  @{lines}
        Run Keyword If  '${line}' == '${start_string}'  Run Keywords
        ...  Append To List  ${bbox_part_list}  ${line}
        ...  AND  Set Test Variable  ${counter_start}  ${True}
        ...  ELSE IF  '${counter_start}' == 'True'
        ...  Run Keywords  Append To List  ${bbox_part_list}  ${line}
        ...  AND  Set Test Variable  ${check}  ${True}
        ${contains}=    Run Keyword And Return Status    Should Contain    ${line}    ---
        Run Keyword If  ${check} and '${line}'=='${end_string}'  Run Keywords
        ...  Set Test Variable  ${counter_start}  ${False}
        ...  AND  Exit For Loop
    END
    Log  ${bbox_part_list}
    Remove From List  ${bbox_part_list}  -1
    Remove From List  ${bbox_part_list}  -1
    [Return]  ${bbox_part_list}

Get Vdu Pod Name
    [Documentation]
    ...  Description:
    ...  Keyword for getting pod name (ute,po etc.). Returns the pod name.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Connect To vDU K8s Master Node With Tenant
    ${ns}=  Get vDU Namespace From Init File
    ${cmd_result}=  tafssh.Execute
    ...  command=kubectl get pod -n ${ns} | awk '{print $1}' | grep -v NAME
    ${vdu_pod_list}=  Split To Lines  string=${cmd_result}  start=1  end=-1
    FOR  ${vdu_pod}  IN  @{vdu_pod_list}
      Log  ${vdu_pod}  console=False
#      Continue For Loop If  '${ns}' not in '${vdu_pod}'
      ${words}    Split String    ${vdu_pod}    -
      Exit For Loop
    END
    [Return]    ${words[0]}

Check Histograms For Single File
    [Arguments]  ${dst_folder}  ${file_name}  ${number}=2161
    [Documentation]
    ...  Description:
    ...  KW checks if histogram value for given black box file has correct values
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             |  Yes | Path to the folder where blackbox files are located.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              |  Yes | Name of the black box file                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | number                 |  No  | Maximum value for histogram records                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${bbox_ru_file}=  Get File  ${dst_folder}/${file_name}
    ${histogram_list}  Create List
    ${item_type_start}  Set Variable  ${False}
    @{lines}=  Split To Lines  ${bbox_ru_file}
    FOR  ${line}  IN  @{lines}
        Run Keyword If  '${line}'=='Item type: Temperature' or '${line}' == 'Item type: Voltage'
        ...  Check Single Text Group  ${histogram_list}  ${line}
        ...  ELSE IF  '${item_type_start}' == 'True'  Check Single Text Group  ${histogram_list}  ${line}
        ${contains}=    Run Keyword And Return Status    Should Contain    ${line}    Last days 90:
        Run Keyword If  ${contains}  Run Keyword And Continue On Failure  Check Histogram Records Number  records_line=${line}  number=${number}
        Run Keyword If  ${contains}  Set Test Variable  ${item_type_start}  ${False}
    END

Check Single Text Group
    [Arguments]  ${histogram_list}  ${line}
    Append To List  ${histogram_list}  ${line}
    Set Test Variable  ${item_type_start}  ${True}

Check Histogram Records Number
    [Arguments]  ${records_line}  ${number}=2161
    [Documentation]
    ...  Description:
    ...  KW checks if histogram value in corresponding records is correct
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | records_line           |  Yes | Single line from black box file                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | number                 |  No  | Maximum value for histogram records                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${integer_values_list}  Create List
    ${fetched_line}  Fetch From Right  ${records_line}  :
    ${fetched_line_list}    Split String    ${fetched_line}    ${SPACE}
    ${cleared_list}=    Evaluate    [x for x in @{fetched_line_list} if x]
    Log    ${cleared_list}
    FOR  ${value}  IN  @{cleared_list}
        ${integer_value}    Convert To Integer    ${value}
        Append To List  ${integer_values_list}  ${integer_value}
    END
    ${sum_result}    Evaluate    sum([int(num) for num in ${integer_values_list}])
    Should Be True  ${sum_result}<${number}   #90days * 24hours records + 1
