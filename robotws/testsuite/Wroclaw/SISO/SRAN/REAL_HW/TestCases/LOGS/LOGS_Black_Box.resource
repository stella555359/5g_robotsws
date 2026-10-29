*** Settings ***
Documentation  TODO
...  Author: szymon.przybylak@nokia.com
...  Maintainer: szymon.przybylak@nokia.com

Library    ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library    taf.transport.ssh  WITH NAME  tafssh

Library     taf.sbts.oam.coam.admin  WITH NAME  admin

*** Keywords ***
Collect Both BBox Files For Radio
    [Arguments]  ${destination_folder_name}   ${bts_id}  ${bbox_type}=${EMPTY}
    [Documentation]  KW collects BBOX5 and/or BBOX_startup_temperature and BBOX_temperature files from RU and from BTS snapshot and compares them
    ...  If files are identical, destination folder name is returned
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | destination_folder_name| yes  |  Destination folder to store files                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_id                 | yes  |   bts id                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbox_type              | no   |  default value downloads only BBOX5, if needed all, use 'all'              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    OperatingSystem.Create Directory  ${BBOX_dir}/${destination_folder_name}

    SSH Get File From Radio Module    ${RMOD_SERIAL_NUMBER}  /mnt/runtime/BBOX5  ${BBOX_dir}/${destination_folder_name}

    Collect Bbox from snapshot
    ...  ru_sn=${RMOD_SERIAL_NUMBER}
    ...  destination_folder_name=${destination_folder_name}
    ...  bts_id=${bts_id}
    ...  bbox_type=${bbox_type}
    ${rc}  ${output}=  Run And Return Rc And Output
    ...  diff -s /${BBOX_dir}/${destination_folder_name}/BBOX5_snap ${BBOX_dir}/${destination_folder_name}/BBOX5
    Should Contain  ${output}  are identical  msg=BBOX Files from RU and Snapshot are not identical!
    Logging With Timestamp
    ...  message=BBOX5 Files from RU and BTS Snapshot are identical!
    ...  style=INFO
#    Run  rm -r -d ${BBOX_dir}/${temp_folder_name}
    [Return]  ${destination_folder_name}

Collect Bbox from snapshot
    [Arguments]  ${ru_sn}  ${destination_folder_name}   ${bts_id}  ${bbox_type}
    [Documentation]  KW collects BBOX5 and/or BBOX_startup_temperature and BBOX_temperature files from BTS snapshot
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_sn                  | yes  |  RU serial number to identify correct BBOX file in snapshot                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | destination_folder_name| yes  |  Destination folder to store files                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_id                 | yes  |   bts id                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbox_type              | no   |  default value downloads only BBOX5, if needed all, use 'all'              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Collectiong BTS Snapshot file, please wait!
    ...  style=ONGOING
    admin.Collect Snapshot  target_file_name=${BBOX_dir}/BTS_Snapshot_${destination_folder_name}.zip  connection=${bts_id}  timeout=1200
    Logging With Timestamp
    ...  message=BTS Snapshot file collected !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Unzipping BBOX5 file from BTS snapshot file, please wait!
    ...  style=ONGOING

    ${archives_dictionary}=  Get Regex Match Nested Archives In Bts Snapshot
    ...  zip_path=${BBOX_dir}/BTS_Snapshot_${destination_folder_name}.zip
    ...  regex_pattern=.*${RMOD_SERIAL_NUMBER}.*BBOX5.*

    ${parent_zip_name}=  Get Dictionary Keys  ${archives_dictionary}
    ${bbox5_zip_name}=  Get From Dictionary  ${archives_dictionary}  ${parent_zip_name}[0]

    ${rc1}=  OperatingSystem.Run And Return RC
    ...  unzip -o ${BBOX_dir}/BTS_Snapshot_${destination_folder_name}.zip -d ${BBOX_dir}/${temp_folder_name}
    ${parent_unzip_status}=  Run And Return Rc  unzip -o ${BBOX_dir}/${temp_folder_name}/${parent_zip_name}[0] -d ${BBOX_dir}/${temp_folder_name}
    ${bbox5_unzip_status}=  Run And Return Rc  unzip -o ${BBOX_dir}/${temp_folder_name}/${bbox5_zip_name}[0] -d ${BBOX_dir}/${temp_folder_name}
    ${bbox5_moved_status}=  Run And Return Rc  mv ${BBOX_dir}/${temp_folder_name}/BBOX5 ${BBOX_dir}/${destination_folder_name}/BBOX5_snap

    IF  '${bbox_type}' != '${EMPTY}'
      FOR  ${i}  IN RANGE  1  7
      Run Keyword And Ignore Error
      ...  Run  mv ${BBOX_dir}/${temp_folder_name}/BBOX_temperature_${i} ${BBOX_dir}/${destination_folder_name}/BBOX_temperature_${i}
      Run Keyword And Ignore Error
      ...  Run  mv ${BBOX_dir}/${temp_folder_name}/BBOX_startup_temperature_${i} ${BBOX_dir}/${destination_folder_name}/BBOX_startup_temperature_${i}
      END
    END

    IF  '${rc1}'!='0' or '${parent_unzip_status}'!='0' or '${bbox5_unzip_status}'!='0' or '${bbox5_moved_status}'!='0'
        Fail  Unzipping BBOX5 file from BTS snapshot file failed !
    ELSE
        Logging With Timestamp
        ...  message=Unzipping BBOX5 file from BTS snapshot file done !
        ...  style=DONE
        Run  rm -r -d ${BBOX_dir}/${temp_folder_name}
    END

Find RM Parent In Chain
  [Arguments]    ${rm_sn}
  [Documentation]    KW finds parent RM in SCF chain for given RM serial number. If no parent found, returns False.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | rm_sn                  | yes  |  RU serial number to identify correct BBOX file in snapshot                |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  FOR    ${rm_info}    IN    @{CFG.RF_INFO}
      Continue For Loop If    "${rm_sn}" not in ${CFG.RF_INFO["${rm_info}"]["scf_chain_fr_affected_list"]}
      Return From Keyword    ${rm_info}
  END
  Return From Keyword    ${False}

Find Master Of Chain For RM
  [Arguments]    ${rm_sn}
  [Documentation]    KW finds master RM in SCF chain for given RM serial number.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | rm_sn                  | yes  |  RU serial number to identify correct BBOX file in snapshot                |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  ${master_rm}=    Find RM Parent In Chain    ${rm_sn}
  ${more_master_rm}=    Run Keyword If    "${master_rm}"!="${False}"    Find RM Parent In Chain    ${master_rm}
  Return From Keyword If    "${more_master_rm}"=="${None}" or "${more_master_rm}"=="${False}"    ${master_rm}
  Return From Keyword    ${more_master_rm}

Get Part Of Bbox List
    [Arguments]  ${file_path}  ${start_string}  ${end_string}
    [Documentation]  KW takes path to BBOX file location and returns list of records for Item type: resets
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | file_path              | yes  |  Full path to BBOX file                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | start_string           | yes  |   String which indicates the beginning of part of BBOX file to be returned |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | end_string             | yes  |   String which indicates the end of part of BBOX file to be returned       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${bbox_ru_file}=  OperatingSystem.Get File  ${file_path}
    ${bbox_part_list}=  Create List
    ${check}=  Set Variable  ${False}
    ${counter_start}=  Set Variable  ${False}
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
    ${processed_list}=    Evaluate    [s[:-1] if s and s[-1] == ' ' else s for s in $bbox_part_list]
    [Return]  ${processed_list}

Find All Connections To BBMOD
    [Arguments]  ${rmod_disname}  ${sfp_links_info}
    [Documentation]  KW finds all BBMOD_R connections for given RMOD in SFP links info list.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_disname           | yes  |  RMOD disname to find connections for                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sfp_links_info         | yes  |   List of SFP links info dictionaries                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    # Get all links where RMOD above is as a source and save it to list
    ${rmod_sfp_connections_list}=  Evaluate  [link["destination"] for link in ${sfp_links_info} if "${rmod_disname}" in link["source"]]
    # Removing /SFP_R-X from links
    ${rmod_sfp_connections_list_splited}=  Evaluate  ['/'.join(link.split("/")[:-1]) for link in ${rmod_sfp_connections_list}]
    # For each link in list get its destination and check if it contains BBMOD_R
    ${bbmod_distname_list}=  Create List
    FOR  ${link}  IN  @{sfp_links_info}
      # Removing /SFP_R-X from link
      ${splited_link}=  Split String  ${link["destination"]}  /
      Remove From List  ${splited_link}  -1
      ${splited_link}=  Catenate  SEPARATOR=/  @{splited_link}
      # Skip if not this link
      Continue For Loop If  "${splited_link}" not in @{rmod_sfp_connections_list_splited}
      Run Keyword If  "BBMOD_R" in "${splited_link}"  Run Keywords
      ...  Append To List  ${bbmod_distname_list}  ${splited_link}
      ...  AND  Continue For Loop
    END
    [Return]  ${bbmod_distname_list}

Find SMOD By Given BBMOD
    [Arguments]  ${bbmod_sn}
    [Documentation]  KW finds SMOD serial number for given BBMOD serial number using AirScale BBMOD mapping.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bbmod_sn               | yes  |  BBMOD serial number to find SMOD for                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    ${sm_bbmod_dict}  radio.Get AirScale BBMOD Mapping
    FOR  ${smod}  ${bbmod_list}  IN ZIP  ${sm_bbmod_dict.keys()}  ${sm_bbmod_dict.values()}
      ${matching_value}=  Evaluate  [v for v in ${bbmod_list} if '${bbmod_sn}' in v]
      ${wanted_smod}=  Run Keyword If  ${matching_value}  Set Variable  ${smod}
      Exit For Loop If  ${matching_value}
    END
    ${smod_sn}=  Split String  ${wanted_smod}  ${SPACE}
    [Return]  ${smod_sn[1]}

Prepare Keys For Black Box Functions Check
    [Arguments]  ${dst_folder}  ${start_string}
    [Documentation]  KW prepares 2 dictionaries from black box files for part of black box file, decided by ${start_string}. One dictionary
    ...  is only with keys (parts before : value in black box) and second has key/values pairs.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             | yes  |  Destination folder where black box files are stored                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | start_string           | yes  |   String which indicates the beginning of part of BBOX file to be processed|
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${keys_dict}=  Create Dictionary
    ${part_list}=  Get Part Of Bbox List
    ...  file_path=${BBOX_dir}/${dst_folder}/BBOX5
    ...  start_string=${start_string}
    ...  end_string=---
    FOR  ${line}  IN  @{part_list}
        ${item_start}=  Evaluate  'Item type' in '${line}'
        ${key}=  Run Keyword If  ${item_start}  Set Variable  ${line}
        ...  ELSE  Fetch From Left  ${line}  :
        ${value}=  Fetch From Right  ${line}  :
        Set To Dictionary  ${keys_dict}  ${key}  ${value}
    END
    ${only_keys_from_bbox}=  Get Dictionary Keys  ${keys_dict}
    [Return]  ${only_keys_from_bbox}  ${keys_dict}

Check Histograms For Single File
    [Arguments]  ${dst_folder}  ${file_name}  ${number}=129600
    [Documentation]  KW checks histogram records number for single BBOX file located in dst_folder with file_name.
    ...  Arguments:
    ...  +========================+======+=============================================================================+
    ...  | Argument               | Man. | Description                                                                 |
    ...  +========================+======+=============================================================================+
    ...  | dst_folder             | yes  |  Destination folder where black box files are stored                        |
    ...  +------------------------+------+-----------------------------------------------------------------------------+
    ...  | file_name              | yes  |   File name of BBOX file to be processed                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------------+
    ...  | number                 | no   |  Number of maximum records allowed in histogram (default 129600 for 90 days)|
    ...  +------------------------+------+-----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${bbox_ru_file}=  OperatingSystem.Get File  ${BBOX_dir}/${dst_folder}/${file_name}
    ${histogram_list}=  Create List
    ${item_type_start}=  Set Variable  ${False}
    @{lines}=  Split To Lines  ${bbox_ru_file}
    FOR  ${line}  IN  @{lines}
      Run Keyword If  '${line}' == 'Item type: Temperature' or '${line}' == 'Item type: Voltage'  Check Single Text Group  ${histogram_list}  ${line}
      ...  ELSE IF  '${item_type_start}' == 'True'  Check Single Text Group  ${histogram_list}  ${line}
      ${contains}=    Run Keyword And Return Status    Should Contain    ${line}    Last days 90:
      Run Keyword And Continue On Failure  Run Keyword If  ${contains}  Check Histogram Records Number  records_line=${line}  number=${number}
      Run Keyword If  ${contains}  Set Test Variable  ${item_type_start}  ${False}
    END

Check Histogram Records Number
    [Arguments]  ${records_line}  ${number}=129600
    [Documentation]  KW checks histogram records number for single histogram line.
    ...  Arguments:
    ...  +========================+======+=============================================================================+
    ...  | Argument               | Man. | Description                                                                 |
    ...  +========================+======+=============================================================================+
    ...  | records_line           | yes  |  Line from BBOX file containing histogram records                           |
    ...  +------------------------+------+-----------------------------------------------------------------------------+
    ...  | number                 | no   |  Number of maximum records allowed in histogram (default 129600 for 90 days)|
    ...  +------------------------+------+-----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${integer_values_list}=  Create List
    ${fetched_line}=  Fetch From Right  ${records_line}  :
    ${fetched_line_list}=    Split String    ${fetched_line}    ${SPACE}
    ${cleared_list}=    Evaluate    [x for x in @{fetched_line_list} if x]
    Log    ${cleared_list}
    FOR  ${value}  IN  @{cleared_list}
        ${integer_value}=    Convert To Integer    ${value}
        Append To List  ${integer_values_list}  ${integer_value}
    END
    ${sum_result}=    Evaluate    sum([int(num) for num in ${integer_values_list}])
    Should Be True  ${sum_result}<${number}   #90days * 24hours records * 60 samples+ 1


Check Single Text Group
    [Arguments]  ${histogram_list}  ${line}
    Append To List  ${histogram_list}  ${line}
    Set Test Variable  ${item_type_start}  ${True}
