*** Settings ***
Documentation   TBD.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

Library     DateTime
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.transport.ssh  WITH NAME  tafssh
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    ../../resources/python/black_box.py
Resource    Cloud_LOGS_BlackBox_resource.resource

*** Variables ***
@{sw_version_template}  Item type: SW_version  Last write  Last write ISTI   File [0] name
...                     File [0] version  File [0] status
@{isti_template}  Item type: Isti  Last write  Value
@{reset_info_template}  Item type: resets  Reset Counter  Reset[0] Write  Reset[0] ISTI  Reset[0] Reset Reason  Reset[0] Reset Cause
...  Reset[0] Failed Service
@{soc_version_template}  Item type: soc_version  Value
@{memory_load_template}  Item type: memory_load  Item id  First write  Last write  First write ISTI  Last write ISTI  Min  Max  Average
...  Ranges [%]  Values
@{cpu_load_template}  Item type: cpu_load  Item id  First write  Last write  First write ISTI  Last write ISTI  Min  Max  Average  Ranges [%]  Values
@{temperature_template}  Item type: Temperature  Item id  First write  Last write  First write ISTI  Last write ISTI  Ranges [°C]  Values
...  Last days 90
@{voltage_template}  Item type: Voltage  Item id  First write  Last write  First write ISTI  Last write ISTI  Ranges [V]  Values  Last days 90
@{optical_lvl_template}  Item type: Optical_lvl_signal  Item id  First write  Last write  First write ISTI  Last write ISTI  Reference signal
...  Ranges [dB]  Values  Last days 90
@{flush_counter_template}  Item type: NvmFlushCounter  Periodical trigger occur times  Temperature gradient trigger occur times
...                         Reset trigger occur times
${temp_folder_name}  temp

@{VDU_BLACK_BOX_ALLOWED_HIST_ALARMS}=  faultId=1937, severity=critical
@{VCU_BLACK_BOX_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_LOGS_BlackBox_enhancements_testing
    [Arguments]  ${scfc_file_path}  ${rmod_ids}=@{EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword black box .
    ...
    ...  Step 1: Collect blackbox files from RU and snapshot to VM and check if there are the same.
    ...  Step 2: Check if product code and serial number in blackbox matches values from webem and RU unit.
    ...  Step 3: Check if histograms in blackbox have correct values.
    ...  Step 4: Check black box functions and their structure in blackbox file.
    ...  Step 5: Check bts id and software version in permanent.xml file on RU.
    ...
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

    Log  ${start_prefix_green}Test Case: Black Box Combo  console=${log_to_console}
    ${logs_dir_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}
    Set Test Variable  ${LOGS_DIR_PATH}  ${logs_dir_path}
    Bbox Precondition  rmod_ids=${rmod_ids}  scfc_file_path=${scfc_file_path}  logs_dir_path=${logs_dir_path}
    ${step_1st_folder}  step1: Collect BBox From Webem and RU
    step2: Check P/C and S/N  dst_folder=${step_1st_folder}
    step3: Check Histograms For Bbox From RU And Snapshot  dst_folder=${step_1st_folder}
    step4: Check black box functions  dst_folder=${step_1st_folder}
    step5: Check Bts Id and SW
    radio.Close SSH Connection
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

Bbox Precondition
    [Arguments]  ${rmod_ids}  ${scfc_file_path}  ${logs_dir_path}  ${log_to_console}=True
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
    Log  ${dots_prefix_green}Black Box Precondition Start  console=
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_BLACK_BOX_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_BLACK_BOX_ALLOWED_HIST_ALARMS}
    Black Box Common Preconditions  rmod_ids=${rmod_ids}  scfc_file_path=${scfc_file_path}  logs_dir_path=${logs_dir_path}
    FOR  ${ru_sn}  IN  @{rf_list}
        RMOD Unit Reset  rmod_sn=${ru_sn}
    END
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  timeout=600
    Log  ${ok_prefix_green}Black Box Precondition Finished  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

step1: Collect BBox From Webem and RU
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Step 1 in Automated_AIC_RU_BlackBox_enhancements_testing test that downloads black box files to VM from snapshot and RU
    ...  and checks if there are identical.
    ...  Files are later used in next steps that do not require more actions before checking files.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step 1: Collect BBox From Webem and RU started  console=${log_to_console}
    ${destination_folder_path}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step_1
    Log  ${ok_prefix_green}step 1: Collect BBox From Webem and RU started finised  console=${log_to_console}
    [Return]  ${destination_folder_path}

step2: Check P/C and S/N
    [Arguments]  ${dst_folder}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Step 2 in Automated_AIC_RU_BlackBox_enhancements_testing - CB010655_K_1_support_radio_product_code_and_serial_number
    ...  KW checks if values in blackbox file located in ${dst_folder} has correct value for
    ...  product code and serial number.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             |  Yes  |  Path to the blackbox file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    ...

    Log  ${dots_prefix_green}step2: Check Product Code and Serial Number in BBox files  console=${log_to_console}
    FOR   ${ru_sn}    IN    @{rf_list}
        Check P/C And S/N in BBox  destination_folder=${dst_folder}  ru_serial_number=${ru_sn}
    END
    Log  ${ok_prefix_green}step2: Check Product Code and Serial Number in BBox files finished  console=${log_to_console}

step3: Check Histograms For Bbox From RU And Snapshot
    [Arguments]  ${dst_folder}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  KW that checks if there are histograms for correct types, and if there is enough records in them.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             |  Yes  |  Path to the blackbox file.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step 3: Check histograms for bbox  console=${log_to_console}
    FOR  ${ru_sn}  IN  @{rf_list}
        Check Histograms For Single File  dst_folder=${dst_folder}  file_name=BBOX5_snap
    END
    Log  ${ok_prefix_green}step3: Check histograms for bbox finished  console=${log_to_console}

step4: Check black box functions
    [Arguments]    ${dst_folder}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  CB010655_A_1_parity_legacy_black_box_5_function_of_CB006622_CB007833
    ...  Step 4 of test that checks if structure of corresponding parts of black box are correct.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             |  Yes  |  Path to the blackbox file.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step 4: Check Black Box functions  console=${log_to_console}
    FOR  ${ru_sn}  IN  @{rf_list}
        Check black box functions for RU  dst_folder=${dst_folder}
    END
    Log  ${ok_prefix_green}step 4: Check Black Box functions finished  console=${log_to_console}

step5: Check Bts Id and SW
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  KW checks if file permanent.xml on RU has correct values for SW and BTS ID
    ...   In case of cloud BTS, "BTS ID" is configured btsName, P/C and S/N of the RNICMOD.
    ...   e.g. "5gvDU11068_1748A.X03_PCN2311C00165";
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step 5: Check BTS ID and SW  console=${log_to_console}
    ${bts_name}=  Evaluate Xpath  ${scfc_file_path}  string(.//managedObject[@class= "com.nokia.vdu.5g:MRBTS"]/p[@name="btsName"]/text())
    FOR  ${ru_sn}  IN  @{rf_list}
        Log To Console    Copying permanent.xml from RM ${ru_sn} to SMOD
        Wait Until Keyword Succeeds   60  5  radio.Send File Via SCP
        ...  ru_serial_number=${ru_sn}
        ...  direction=to_container
        ...  file_path=/mnt/runtime/rfsw/uoam/permanent.xml
        ...  destination_directory=/tmp
        ...  cloud_server_ip=${cloud_server_ip}
        radio.Close SSH Connection
        Log  ${info_prefix}Downloading permanent.xml from SMOD to VM  console=${log_to_console}
        tafssh.Connect To  hostname=${cloud_server_ip}
        ...  username=core
        ...  password=system123
        ...  alias=primary
        tafssh.Send Command  kubectl cp -n cran1 ${VDU_POD_NAME}-oamfh-0:"/tmp/permanent.xml" -c ctr-oamfh "/tmp/permanent.xml"
        ...    connection=primary
        tafssh.Read Output  connection=primary
        tafssh.Download File  remote_path=/tmp/permanent.xml
        ...  local_path=${logs_dir_path}/${ru_sn}/permanent.xml
        ...  connection=primary
        tafssh.Send Command  rm /tmp/permanent.xml  connection=primary
        radio.Close SSH Connection
    END
    ${xml}=    Parse Xml    ${logs_dir_path}/${ru_sn}/permanent.xml
    ${encoded_str_all}=    Get Element Text  ${logs_dir_path}/${ru_sn}/permanent.xml
    Log  ${xml}
    ${encoded_str}  Fetch From Right  ${encoded_str_all}  BtsId
    ${encoded_str}  Fetch From Left  ${encoded_str}  BtsVersion
    ${decoded_bts_string}=    Evaluate    base64.b64decode('${encoded_str}').decode('utf-8')  modules=base64
    ${mrbts_id}  vDU Get MRBTS Id  vdu_login=False
    ${rnic_info}  Get Rnic Info From Plan  mrbts_id=${mrbts_id}
    ${vdu_software_version}  vDU Get Running Software Version
#    ${is_rnic_b}  Run Keyword If  'AF1791' in '${rnic_info[0]}[product_code]'
#    ...  Set Variable  True
#    ...  ELSE  Set Variable  False
    ${rnic_pc}  Set Variable  ${rnic_info[0]}[product_code]
#    ${rnic_pc}  Run Keyword If  ${is_rnic_b}==True  Replace String	${rnic_pc}  AF1791  1791B
#    ...  ELSE    Set Variable  ${rnic_pc}
    Log  ${rnic_pc}
    Run Keyword And Continue On Failure  Should Contain  '${encoded_str_all}'  ${vdu_software_version}
    Run Keyword And Continue On Failure  Should Contain  '${decoded_bts_string}'  ${bts_name}_${rnic_pc}_${rnic_info[0]}[serial_number]
    Log  ${ok_prefix_green}step 5: Check BTS ID and SW  console=${log_to_console}

Check P/C And S/N in BBox
    [Arguments]  ${destination_folder}  ${ru_serial_number}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  CB010655_K_1_support_radio_product_code_and_serial_number
    ...  Keyword that checks if Product Code and Serial Number for given radio are correct in black box file.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_serial_number       |  Yes |  Serial number of the radio.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | destination_folder     |  Yes |  Path to the folder where blackbox files are located.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${ru_product_code}  Set Variable  ${rmod_info}[${ru_serial_number}][product_code]
    ${ru_product_code_check}=  Set Variable  ${False}
    ${tmp_rm_serial_number_check}=  Set Variable  ${False}
    ${rm_serial_number_check}=  Set Variable  ${False}
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    radio.Send Command  cat /mnt/factory/configs/unit/module_product_code.txt
    ${ru_pc_from_ru_files}  radio.Read Until Prompt  prompt=$|#  timeout=15
    radio.Send Command  cat /mnt/factory/configs/unit/module_serial_number.txt
    ${ru_sn_from_ru_files}  radio.Read Until Prompt  prompt=$|#  timeout=15
    radio.Close SSH Connection
    ${bbox_hwpart_list}  Get Part Of Bbox List  file_path=${destination_folder}/BBOX5  start_string=Item type: HW_information  end_string=---
    Should Contain  ${ru_pc_from_ru_files}  ${ru_product_code}
    Log  ${info_prefix}RU Product Code ${ru_product_code} is visible in /mnt/factory/configs/unit/module_product_code.txt  console=${log_to_console}
    Should Contain  ${ru_sn_from_ru_files}  ${ru_serial_number}
    Log  ${info_prefix}RU SN ${ru_serial_number} is visible in /mnt/factory/configs/unit/module_serial_number.txt  console=${log_to_console}
    Should Contain  ${bbox_hwpart_list}  radio serial number: ${ru_serial_number}  msg=BBOX File does not contain RU SN ${ru_serial_number}
    Log  ${info_prefix}BBOX file contains RU serial number ${ru_serial_number}  console=${log_to_console}
    Should Contain  ${bbox_hwpart_list}  radio product code: ${ru_product_code}  msg=BBOX FILE does not contain RU product code ${ru_product_code}
    Log  ${info_prefix}BBOX file contains RU product code ${ru_product_code}  console=${log_to_console}

Check black box functions for RU
    [Arguments]    ${dst_folder}
    [Documentation]
    ...  Description:
    ...  Keyword that checks if there are correct "structures" for corresponding parts in blackbox file.
    ...  Arguments:
    ...  +===========================+======+=========================================================================+
    ...  | Argument                  | Man. | Description                                                             |
    ...  +===========================+======+=========================================================================+
    ...  | dst_folder                 |  Yes | Path to folder where blackbox file is located                          |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${hw_release_bool}  Run Keyword And Return Status
    ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${rmod_info}[${ru_sn}][hardware_release]').group(0)  re
    ${hw_release}=  Run Keyword If  ${hw_release_bool}==True
    ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${rmod_info}[${ru_sn}][hardware_release]').group(0)  re

    ${sw_version_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}
    ...  start_string=Item type: SW_version
    ${isti_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: Isti
    ${reset_info_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: resets
    ${soc_version_keys}  ${part_bbox_keys}  Run Keyword If  ${hw_release}==5.1 or ${hw_release}==7.1
    ...    Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: soc_version
    ...    ELSE    Evaluate    list(), list()
    ${memory_load_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: memory_load
    ${cpu_load_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: cpu_load
    ${temperature_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: Temperature
    ${voltage_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: Voltage
    ${optical_lvl_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: Optical_lvl_signal
    Log  ${sw_version_keys}
    Log  ${sw_version_template}
#    FOR  ${item}  IN  @{sw_version_keys}
#        Log  ${item}
#        Should Contain  ${sw_version_template}  ${item}
#    END
    ${match}  Check Structure Match  ${sw_version_keys}  ${sw_version_template}
    Run Keyword and Continue on Failure  Should Be True  ${match}==${True}
    FOR  ${item}  IN  @{isti_keys}
        Should Contain  ${isti_template}  ${item}
    END
    ${match}  Check Structure Match  ${reset_info_keys}  ${reset_info_template}
    Run Keyword and Continue on Failure  Should Be True  ${match}==${True}
    FOR  ${item}  IN  @{soc_version_keys}
        Should Contain  ${soc_version_template}  ${item}
    END
    FOR  ${item}  IN  @{memory_load_keys}
        Should Contain  ${memory_load_template}  ${item}
    END
    FOR  ${item}  IN  @{cpu_load_keys}
        Should Contain  ${cpu_load_template}  ${item}
    END
    FOR  ${item}  IN  @{temperature_keys}
        Should Contain  ${temperature_template}  ${item}
    END
    FOR  ${item}  IN  @{voltage_keys}
        Should Contain  ${voltage_template}  ${item}
    END
    FOR  ${item}  IN  @{optical_lvl_keys}
        Should Contain  ${optical_lvl_template}  ${item}
    END

