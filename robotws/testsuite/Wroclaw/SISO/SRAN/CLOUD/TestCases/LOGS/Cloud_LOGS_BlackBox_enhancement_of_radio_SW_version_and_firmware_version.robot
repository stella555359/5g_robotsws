*** Settings ***
Documentation   TBD.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

Library     DateTime
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.transport.ssh  WITH NAME  tafssh
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ./Cloud_LOGS_BlackBox_resource.resource
Resource    ../SWM/Cloud_SWM_vDU_Update.robot

*** Variables ***
&{UPDATE_BUILD_NAME}=
...             vDUCNF25R1=vDUCNF25R1_24.300.434
...             vDUCNF25R2=vDUCNF25R2_25.300.419
...             vDUCNF00=vDUCNF00_0.300.29874
${CCR_LOCATION}   # wg or wl
@{VDU_BLACK_BOX_ALLOWED_ALARMS}=  faultId=1937, severity=critical
@{VCU_BLACK_BOX_ALLOWED_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_LOGS_BlackBox_enhancement_of_radio_SW_version_and_firmware_version
    [Arguments]  ${scfc_file_path}  ${rmod_ids}=@{EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test for checking of enhancement of radio SW version and firmware version.
    ...  Tester has to set ${CCR_LOCATION} to wg/wl in testsuite.
    ...  For this TC/KW to work, tester has to prepare override files. The files (each named values-override.yaml) can be taken from
    ...  kuafu deployment, from corresponding folders for aic-vdu, aic-vdu-prerequisites, aic-vdu-cluster-preparations.
    ...  Files should be stored in e.g.
    ...  /home/ute/testline_configuration/10_16_UTESRANSISO705/values_override/vDU
    ...  Names of the files should be:
    ...  main.yaml (for aic-vdu), preparation.yaml (for aic-vdu-cluster-preparations), prerequisites.yaml (for aic-vdu-prerequisites).
    ...
    ...  Step 1: Preconditions
    ...  Step 2: Downgrade Software And Collect BBox From Webem and RU
    ...  Step 3: Software Update And Radio SW Version And Firmware Check
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_green}Test Case: BlackBox enhancement of radio SW version and firmware version  console=${log_to_console}
    ${logs_dir_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}
    Set Test Variable  ${LOGS_DIR_PATH}  ${logs_dir_path}
    Set Test Variable  ${IS_PASSED}  False
    Step 1: Black Box Radio Sw Version And Firmware Preconditions
    ...  rmod_ids=${rmod_ids}
    ...  scfc_file_path=${scfc_file_path}
    ...  logs_dir_path=${logs_dir_path}
    ${step_2_folder}  Step2: Downgrade Software And Collect BBox From Webem and RU
    Step3: Software Update And Radio SW Version And Firmware Check  dst_folder=${step_2_folder}
    Set Test Variable  ${IS_PASSED}  True
    Log  ${done_prefix_green}Test Case: BlackBox enhancement of radio SW version and firmware version finished  console=${log_to_console}
    [Teardown]  Run Keywords
    ...  Software Update Teardown
    ...  AND  Run Keyword And Ignore Error  vDU Rest Logout

Step 1: Black Box Radio Sw Version And Firmware Preconditions
    [Arguments]  ${rmod_ids}  ${scfc_file_path}  ${logs_dir_path}  ${log_to_console}=True  ${build_name}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Precondition keyword prepares variables for Automated_AIC_RU_BlackBox_enhancements_testing
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_ids               | Yes  | List of serial number of tested RU                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Log  ${start_prefix_green}Step 1: Black Box Radio Sw Version And Firmware Preconditions  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_BLACK_BOX_ALLOWED_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_BLACK_BOX_ALLOWED_ALARMS}
    Black Box Common Preconditions  rmod_ids=${rmod_ids}  scfc_file_path=${scfc_file_path}  logs_dir_path=${logs_dir_path}
    Software Update Preconditions  ${build_name}
    FOR  ${ru_sn}  IN  @{rf_list}
        RMOD Unit Reset  rmod_sn=${ru_sn}
    END
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${done_prefix_green}Step 1: Black Box Radio Sw Version And Firmware Preconditions  console=${log_to_console}

Step2: Downgrade Software And Collect BBox From Webem and RU
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  KW downgrades vdu software to the one with different RFSW version. Then it collects BBox files from Webem and RU.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_green}Step2: Downgrade Software And Collect BBox From Webem and RU  console=${log_to_console}
    Perform vDU Update  build_name=${DOWNGRADE_BUILD}  downgrade=True
    Log  ${info_prefix}Reset Unit after software update  console=${log_to_console}
    RMOD Unit Reset  rmod_sn=${ru_sn}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    ${destination_folder_path}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step_2
    tafssh.Connect To  hostname=${cloud_server_ip}
    ...  username=core
    ...  password=system123
    ...  alias=${ssh_conn}
    tafssh.Send Command  rm -r /var/home/core/${tl.tl_cloud_topology}    connection=${ssh_conn}
    Log  ${done_prefix_green}Step2: Downgrade Software And Collect BBox From Webem and RU  console=${log_to_console}
    [Return]  ${destination_folder_path}

Step3: Software Update And Radio SW Version And Firmware Check
    [Arguments]  ${dst_folder}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  CB010655_G_1_enhancement_of_radio_SW_version_and_firmware_version
    ...  KW checks if the update is visible in BBOX file (firmware and software version)
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             |  Yes |  Path to the blackbox file.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_green}Step3: Software Update And Radio SW Version And Firmware Check  console=${log_to_console}
    ${sw_version_history_part}  Get Part Of Bbox List
    ...  file_path=${dst_folder}/BBOX5_snap
    ...  start_string=Item type: SW_version_history
    ...  end_string=---
    ${update_start_date}  Get Current Date  UTC
    Perform vDU Update  build_name=${BASE_BUILD}
    ${update_end_date}  Get Current Date  UTC
    Log  ${info_prefix}Reset Unit after software update  console=${log_to_console}
    RMOD Unit Reset  rmod_sn=${ru_sn}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    ${rmod_status_after_sw_update}=  vdu.Get Rmods Status
    ${rmod_info_after_sw_update}  Create Dictionary
    Set Test Variable  ${rmod_info_after_sw_update}
    FOR  ${radio}  IN  @{rmod_status_after_sw_update}
      Log    ${radio}
      ${radio_values}  Create Dictionary
      Set To Dictionary  ${radio_values}
      ...  product_code=${radio}[product_code]
      ...  product_name=${radio}[product_name]
      ...  id=${radio}[id]
      ...  hardware_release=${radio}[hardware_release]
      ...  active_sw_build=${radio}[active_sw_build]
      ...  active_sw_version=${radio}[active_sw_version]
      Set To Dictionary  ${rmod_info_after_sw_update}
      ...  ${radio}[serial_number]=${radio_values}
    END
    ${step4_folder}  Collect Both BBox Files For Radio
    ...  destination_folder_path=${logs_dir_path}/${ru_sn}/Step3: Software Update And Radio SW Version And Firmware Check
    Check SW Version History and Firmware  folder=${step4_folder}
    ${sw_version_history_after_part}  Get Part Of Bbox List
    ...  file_path=${step4_folder}/BBOX5_snap
    ...  start_string=Item type: SW_version_history
    ...  end_string=---
    Log  ${sw_version_history_part}
    ${sw_version_history_part_length}  Get Length  ${sw_version_history_part}
    ${sw_version_history_after_part_length}  Get Length  ${sw_version_history_after_part}
    ${same}  Evaluate  ${sw_version_history_part_length}==${sw_version_history_after_part_length}
    IF  ${same}
        ${diff}  Set Variable  3
    ELSE
        ${diff}  Set Variable  0
    END
    Log  ${sw_version_history_after_part}
    Log  ${info_prefix}Checking Software Version History  console=${log_to_console}
    FOR  ${index}  IN RANGE  ${sw_version_history_part_length}
        ${temp}  Fetch From Left  ${sw_version_history_part[${index}]}  :
        Exit For Loop If  ${index} == ${sw_version_history_part_length}-${diff}
        Continue For Loop If  ${index} <= 2
        Continue For Loop If  'ISTI time' in '${temp}'
        ${old_temp}  Fetch From Right  ${sw_version_history_part[${index}]}  :
        ${new_temp}  Fetch From Right  ${sw_version_history_after_part[${index+3}]}  :
        Should Match  ${old_temp}  ${new_temp}
    END
    Should Contain  ${sw_version_history_after_part[3]}  ${rmod_info_after_sw_update}[${ru_sn}][active_sw_build]
    Log  ${ok_prefix_green}Checking Software Version History  console=${log_to_console}
    Log  ${done_prefix_green}Step3: Software Update And Radio SW Version And Firmware Check  console=${log_to_console}

Check SW Version History and Firmware
    [Arguments]  ${folder}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  CB010655_G_1_enhancement_of_radio_SW_version_and_firmware_version
    ...  KW compares values of firmware and product build on RU and those in BBOX and checks if there are the same.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | folder                 |  Yes | Path to the blackbox file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${info_prefix}Check SW Version and Firmware  console=${log_to_console}
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module   ru_serial_number=${ru_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    radio.Send Command   SWmanShellCommand -i
    ${radio_sw_txt}  radio.Read Output  delay=1
    radio.Close SSH Connection
    ${active_Build_Name}  Fetch From Right  ${radio_sw_txt}  activeBuildName:
    ${active_Build_Name}  Fetch From Left  ${active_Build_Name}   activeBuildVersion:
    ${sw_version_history_part}  Get Part Of Bbox List
    ...  file_path=${folder}/BBOX5_snap
    ...  start_string=Item type: SW_version_history
    ...  end_string=---
    Should Contain  ${sw_version_history_part[3]}  ${active_Build_name.strip()}

    ${file0}  Fetch From Right  ${radio_sw_txt}  File[0]:
    ${file0}  Fetch From Left  ${file0}  File[1]:
    ${file0_firmware}  Fetch From Right  ${file0}  name:
    ${file0_firmware}  Fetch From Left  ${file0_firmware}  version:
    ${file0_version}  Fetch From Right  ${file0}  version:
    ${file0_version}  Fetch From Left  ${file0_version}  integrity:
    ${file1}  Fetch From Right  ${radio_sw_txt}  File[1]:
    ${file1_firmware}  Fetch From Right  ${file1}  name:
    ${file1_firmware}  Fetch From Left  ${file1_firmware}  version:
    ${file1_version}  Fetch From Right  ${file1}  version:
    ${file1_version}  Fetch From Left  ${file1_version}  integrity:
    ${is_active_sw_in_file0}  Run Keyword And Return Status  Should Contain  ${file0}  active
    ${is_active_sw_in_file1}  Run Keyword If  '${is_active_sw_in_file0}'!='True'  Run Keyword And Return Status  Should Contain  ${file1}  active
    ${sw_version_list}  Create List
    ${item_type_start}  Set Variable  ${False}
    @{lines}=  Split To Lines  ${radio_sw_txt}
    ${sw_version_bbox_part}  Get Part Of Bbox List
    ...  file_path=${folder}/BBOX5_snap
    ...  start_string=Item type: SW_version
    ...  end_string=---
    Remove From List  ${sw_version_bbox_part}  -1
    FOR  ${item}  IN  @{sw_version_bbox_part}
        ${name_line0}  Run Keyword And Return Status  Should Contain  ${item}  [0] name:
        ${version_line0}  Run Keyword And Return Status  Should Contain  ${item}  [0] version:
        ${name_line1}  Run Keyword And Return Status  Should Contain  ${item}  [1] name:
        ${version_line1}  Run Keyword And Return Status  Should Contain  ${item}  [1] version:
        Run Keyword If  '${name_line0}'=='True'    Run Keywords
        ...  Should Contain  ${item}  ${file0_firmware.strip()}
        ...  AND  Set Test Variable  ${firmware_1_ok}  True
        ...  AND  Continue For Loop
        Run Keyword If  '${name_line1}'=='True'  Run Keywords
        ...  Should Contain  ${item}  ${file1_firmware.strip()}
        ...  AND  Set Test Variable  ${firmware_2_ok}  True
        ...  AND  Continue For Loop
        Run Keyword If  '${version_line0}'=='True'    Run Keywords
        ...  Should Contain  ${item}  ${file0_version.strip()}
        ...  AND  Set Test Variable  ${firmware_version_1_ok}  True
        ...  AND  Continue For Loop
        Run Keyword If  '${version_line1}'=='True'    Run Keywords
        ...  Should Contain  ${item}  ${file1_version.strip()}
        ...  AND  Set Test Variable  ${firmware_version_2_ok}  True
        ...  AND  Continue For Loop
    END
    Should Contain  ${firmware_1_ok}  True  msg=software 1 not correct in bbox file
    Should Contain  ${firmware_version_1_ok}  True  msg=software 2 not correct in bbox file
    Should Contain  ${firmware_version_2_ok}  True  msg=software 2 not correct in bbox file
    Should Contain  ${firmware_2_ok}  True  msg=software 2 not correct in bbox file
