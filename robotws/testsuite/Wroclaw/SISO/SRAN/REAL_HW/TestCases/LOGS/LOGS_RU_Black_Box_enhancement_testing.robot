*** Settings ***
Documentation
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    szymon.przybylak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...
...  Purpose: Test case verifies RU Black Box enhancements implemented as part of CB010655.
...  Tester needs to define RMOD_SERIAL_NUMBER variable before running the test.
...
...  Step 1: Bbox Precondition
...  Checking and preparing preconditions for test execution.
...  Step 2: Collect BBox From Webem and RU
...  Downloads BBOX files from Webem snapshot and RU to VM.
...  Step 3: Check P/C and S/N
...  Checks if BBOX files have correct Product Code and Serial Number of RU.
...  Step 4: Check Histograms For Bbox From RU And Snapshot
...  Checks if BBOX files have correct histograms with enough records.
...  Step 5: Check black box functions
...  Checks if BBOX files have correct structure in parts related to new enhancements.
...  Step 6: Check Bts Id and SW
...  Checks if permanent.xml file on RU and black box have correct BTS ID and SW version.

  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 14.11.2025 - Test case separated from robotlte legacy combo test case

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ./LOGS_Black_Box.resource
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     ./../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.transport.ssh  WITH NAME  tafssh
Library     ../../Resources/Python/zip_helpers.py
Library     ../../Resources/Python/blackbox_helpers.py
*** Variables ***
${RMOD_SERIAL_NUMBER}

${temp_folder_name}  temp
@{sw_version_template}  Item type: SW_version  Last write  Last write ISTI  File [0] name  File [0] version  File[0] ISTI time  File [0] status
@{isti_template}  Item type: Isti  Last write  Value
@{reset_info_template}  Item type: resets  Reset Counter  Reset[0] Write  Reset[0] ISTI  Reset[0] Reset Reason  Reset[0] Reset Cause
...  Reset[0] Failed Service
@{soc_version_template}  Item type: soc_version  Value
@{memory_load_template}  Item type: memory_load  Item id  First write  Last write
...  First write ISTI  Last write ISTI  Min  Max  Average  Ranges [%]  Values
@{cpu_load_template}  Item type: cpu_load  Item id  First write  Last write
...  First write ISTI  Last write ISTI  Min  Max  Average  Ranges [%]  Values
@{temperature_template}  Item type: Temperature  Item id  First write  Last write
...  First write ISTI  Last write ISTI  Ranges [°C]  Values  Last days 90
@{voltage_template}  Item type: Voltage  Item id  First write  Last write
...  First write ISTI  Last write ISTI  Ranges [V]  Values  Last days 90
@{optical_lvl_template}  Item type: Optical_lvl_signal  Item id  First write  Last write
...  First write ISTI  Last write ISTI  Reference signal  Ranges [dB]  Values  Last days 90

*** Keywords ***
TC__SiSo_LOGS_RU_Black_Box_enhancements
    Set Tags
    ...    OWNER-szymon.przybylak@nokia.com
    ...    AUTHOR-szymon.przybylak@nokia.com
    ...    MAINTAINER-szymon.przybylak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=TC__SiSo_LOGS_RU_Black_Box_enhancements
    ...  style=ONGOING
    step 1: Bbox Precondition
    ${dst_folder}  step 2: Collect BBox From Webem and RU
    step 3: Check P/C and S/N  dst_folder=${dst_folder}
    step 4: Check Histograms For Bbox From RU And Snapshot  dst_folder=${dst_folder}
    step 5: Check black box functions  dst_folder=${dst_folder}
    step 6: Check Bts Id and SW
    [Teardown]  Common Test Teardown

Step 1: Bbox Precondition
    [Documentation]  Black Box preconditions. Prepares RMOD_L data, HW_dict with serial/product number of HW.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Black Box Enhancements Precondition
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${RMOD_SERIAL_NUMBER}'=='${EMPTY}'
        Fail  Variable RMOD_SERIAL_NUMBER cannot be empty !
    END
    ${bts_id}  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SERIAL_NUMBER}']}  scf_btsid_primary
    Set Test Variable    ${BTS_ID}    ${bts_id}
    ${rmods_info}=  admin.Get FRM  timeout=60  connection=${BTS_ID}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SERIAL_NUMBER}'
        ${rmod_distname_id}=  Set Variable  ${rmod['id']['internal']}
    END
    Set Test Variable  ${RMOD_DISTNAME_ID}    ${rmod_distname_id}
    IF  '${rmod_distname_id}'=='${NONE}'
        Fail  Serial Number ${RMOD_SERIAL_NUMBER} not found in HW Configuration ! Test set to Fail !
    ELSE
        Logging With Timestamp  message=RMOD with SN ${RMOD_SERIAL_NUMBER} found in configuration!
    END
    Set Test Variable  ${BBOX_dir}  ${CFG.test_logs_path}/TestFiles
    ${hw_dict}=  Create Dictionary
    Set Test Variable  ${HW_DICT}  ${hw_dict}
    Set Test Variable    ${scfc_file_path}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
    ${bts_info}=  Get BTS Info  connection=${BTS_ID}
    ${sfp_links_info}=  Get Sfp Links  action=getLinks  connection=${BTS_ID}
    ${rmod_disname}=  Evaluate
    ...  next(distname["id"]["internal"] for distname in ${bts_info["radioModules"]["rmod"]} if distname["serialNumber"] == "${RMOD_SERIAL_NUMBER}")
    Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod_disname}
    ${bbmod_distname_list}=  Find All Connections To BBMOD  ${rmod_disname}  ${sfp_links_info}
    ${bbmod_distname_list}=  Remove Duplicates  ${bbmod_distname_list}
    # TODO: Potential bug! Only first of all found BBMODs will be added to ${HW_DICT}
    ${eva_object_2}=  Set Variable    if bbmod["id"]["internal"] == "${bbmod_distname_list[0]}")
    ${bbmod_sn}  ${bbmod_pc}=  Evaluate
    ...  next((bbmod["serialNumber"], bbmod["productCode"]) for bbmod in ${bts_info["basebandModules"]} ${eva_object_2}
    Set To Dictionary  ${HW_DICT}  bbmod_productCode  ${bbmod_pc}
    Set To Dictionary  ${HW_DICT}  bbmod_serialNumber  ${bbmod_sn}

    ${smod_sn}  Find SMOD By Given BBMOD  ${bbmod_sn}
    Set To Dictionary  ${HW_DICT}  smod_serialNumber  ${smod_sn}
    FOR  ${value}  IN  @{bts_info['systemModules']}
        Continue For Loop If  '${smod_sn}' != '${value['serialNumber']}'
        Set To Dictionary  ${HW_DICT}  smod_productCode   ${value['productCode']}
    END
    Log  ${HW_DICT}
     Logging With Timestamp
    ...  message=Performing Radio Unit Reset, please wait!
    ...  style=ONGOING
    admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}
    Logging With Timestamp
    ...  message=Radio Unit Reset finished !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE
    Logging With Timestamp
    ...  message=Black Box Enhancements Precondition
    ...  style=DONE

step 2: Collect BBox From Webem and RU
    [Documentation]  Step 1 on test that downloads to VM BBOX files from snapshot and RU.
    ...  Files are later used in other KWs that do not require more actions before checking files.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=step 1: Collect BBox From Webem and RU
    ...  style=STEP
    ...  frame=${TRUE}
    ${destination_folder_name}=  Collect Both BBox Files For Radio
    ...  destination_folder_name=step_1_collect_bbox_files
    ...  bts_id=${BTS_ID}
    Logging With Timestamp
    ...  message=step 1: Collect BBox From Webem and RU
    ...  style=DONE
    [Return]  ${destination_folder_name}

step 3: Check P/C and S/N
    [Arguments]    ${dst_folder}
    [Documentation]    CB010655_K_1_support_radio_product_code_and_serial_number
    ...  KW checks if BBOX file located in ${dst_folder} has correct product code and serial number
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             | yes  |  Folder with black box files                                               |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=step 2: Check Product Code and Serial Number in BBox files
    ...  style=STEP
    ...  frame=${TRUE}

    ${ru_product_code}=  Get RU Product Code  ru_sn=${RMOD_SERIAL_NUMBER}
    Run Keyword And Continue On Failure  Check P/C And S/N in BBox
    ...  bbox_folder=${dst_folder}
    ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...  ru_product_code=${ru_product_code}

    Logging With Timestamp
    ...  message=step 2: Check Product Code and Serial Number in BBox files
    ...  style=DONE

step 4: Check Histograms For Bbox From RU And Snapshot
    [Arguments]  ${dst_folder}
    [Documentation]  CB010655_E_1_enhancement_of_temperature_voltage_input_current_consumption_history
    ...  KW that checks if there are histograms for correct types, and if there is enough records in them. Checks only 1 bbox file!
    ...  As in step 1 was that BBOX files are identical
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             | yes  |  Folder with black box files                                               |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=step 3: Check histograms for bbox
    ...  style=STEP
    ...  frame=${TRUE}

    Run Keyword and Continue on Failure  Check Histograms For Single File
    ...  dst_folder=${dst_folder}
    ...  file_name=BBOX5

    Logging With Timestamp
    ...  message=step 3: Check histograms for bbox
    ...  style=DONE

step 5: Check black box functions
  [Arguments]    ${dst_folder}
  [Documentation]  CB010655_A_1_parity_legacy_black_box_5_function_of_CB006622_CB007833
  ...  Step 4 of test that checks if structure of corresponding parts of black box are correct.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | dst_folder             | yes  |  Folder with black box files                                               |
  ...  +========================+======+============================================================================+
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  Logging With Timestamp
  ...  message=step 4: Check Black Box functions
  ...  style=STEP
  ...  frame=${TRUE}

  ${hw_release_bool}=  Run Keyword And Return Status
  ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${RMOD_SERIAL_NUMBER}']['scf_release_code']}').group(0)  re
  ${hw_release}=    Run Keyword If    ${hw_release_bool}==True
  ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${RMOD_SERIAL_NUMBER}']['scf_release_code']}').group(0)  re
  Logging With Timestamp
    ...  message=Prepare Keys For Black Box Functions Check
    ...  style=ONGOING
  ${sw_version_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: SW_version
  ${isti_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: Isti
  ${reset_info_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: resets
  ${soc_version_keys}  ${part_bbox_keys}=  Run Keyword If  ${hw_release}==5.1 or ${hw_release}==7.1
  ...    Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: soc_version
  ...    ELSE    Evaluate    list(), list()
  ${memory_load_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: memory_load
  ${cpu_load_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: cpu_load
  ${temperature_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: Temperature
  ${voltage_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: Voltage
  ${optical_lvl_keys}  ${part_bbox_keys}=  Prepare Keys For Black Box Functions Check
  ...  dst_folder=${dst_folder}  start_string=Item type: Optical_lvl_signal
  Logging With Timestamp
  ...  message=Prepare Keys For Black Box Functions Check
  ...  style=DONE
  Log  ${sw_version_keys}
  Log  ${sw_version_template}
  Logging With Timestamp
  ...  message=Checking SW Version, ISTI, Resets, SoC Version, Memory Load, CPU Load, Temperature, Voltage, Optical Level parts
  ...  style=ONGOING
  ${match}=  Check Bbox Structure Match  ${sw_version_keys}  ${sw_version_template}
  Run Keyword and Continue on Failure  Should Be True  ${match}==${True}
  FOR  ${item}  IN  @{isti_keys}
      Run Keyword and Continue on Failure  Should Contain  ${isti_template}  ${item}
  END
  ${match}=  Check Bbox Structure Match  ${reset_info_keys}  ${reset_info_template}
  Run Keyword and Continue on Failure  Should Be True  ${match}==${True}
  FOR  ${item}  IN  @{soc_version_keys}
      Run Keyword and Continue on Failure  Should Contain  ${soc_version_template}  ${item}
  END
  FOR  ${item}  IN  @{memory_load_keys}
      Run Keyword and Continue on Failure  Should Contain  ${memory_load_template}  ${item}
  END
  FOR  ${item}  IN  @{cpu_load_keys}
      Run Keyword and Continue on Failure  Should Contain  ${cpu_load_template}  ${item}
  END
  FOR  ${item}  IN  @{temperature_keys}
      Run Keyword and Continue on Failure  Should Contain  ${temperature_template}  ${item}
  END
  FOR  ${item}  IN  @{voltage_keys}
      Run Keyword and Continue on Failure  Should Contain  ${voltage_template}  ${item}
  END
  FOR  ${item}  IN  @{optical_lvl_keys}
      Run Keyword and Continue on Failure  Should Contain  ${optical_lvl_template}  ${item}
  END
  Logging With Timestamp
    ...  message=Checking SW Version, ISTI, Resets, SoC Version, Memory Load, CPU Load, Temperature, Voltage, Optical Level parts
    ...  style=DONE
  Logging With Timestamp
  ...  message=step 4: Check Black Box functions
  ...  style=DONE

step 6: Check Bts Id and SW
  [Documentation]  KW checks if file permanent.xml on RU has correct values for SW and BTS ID
  ...  In case of classical BTS, "BTS ID" is configured btsName, P/C and S/N of the SMOD, and P/C and S/N of the BBMOD.
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  Logging With Timestamp
  ...  message=step 5: Check BTS ID and SW
  ...  style=STEP
  ...  frame=${TRUE}

  ${bts_name}=  Evaluate Xpath  ${scfc_file_path}  string(.//managedObject[@class= "com.nokia.srbts:MRBTS"]/p[@name="btsName"]/text())
  # Find master of chain if chain detected
  ${master_rm}=    Find RM Parent In Chain    ${RMOD_SERIAL_NUMBER}
  Logging With Timestamp
  ...  message=Copying permanent.xml from RM ${RMOD_SERIAL_NUMBER} to SMOD
  ...  style=ONGOING
  Wait Until Keyword Succeeds   60  5  radio.Send File Via SCP
  ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
  ...  direction=to_smod
  ...  file_path=/mnt/runtime/rfsw/uoam/permanent.xml
  ...  destination_directory=/ffs
  Logging With Timestamp
  ...  message=Copying permanent.xml from RM ${RMOD_SERIAL_NUMBER} to SMOD
  ...  style=DONE

  Logging With Timestamp
  ...  message=Downloading BBOX from SMOD to VM
  ...  style=ONGOING
  ${smod}=  Get SMOD IP For Connected RMOD  ${RMOD_SERIAL_NUMBER}
  ${node_number}=  Select SMOD For RU  ${RMOD_SERIAL_NUMBER}
  Create Directory  ${BBOX_dir}/${RMOD_SERIAL_NUMBER}_permanent
  Run Keyword If    ${node_number} == 1    Run Keywords
  ...    tafssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
  ...    AND    tafssh.Download File  /ffs/permanent.xml  ${BBOX_dir}/${RMOD_SERIAL_NUMBER}_permanent/permanent.xml  connection=primary
  ...    AND    tafssh.Send Command  rm /ffs/permanent.xml  connection=primary
  ...    ELSE   Run Keywords    tafssh.Connect To  ${CFG.NODES['${BTS_ID}']['secondary_sm_vm_ip_LMP_address']}  ute  alias=vm${node_number}
  ...    AND    tafssh.Connect To  192.168.255.119  toor4nsn  oZPS0POrRieRtu  proxy=vm${node_number}  alias=secondary
  ...    AND    tafssh.Download File  /ffs/permanent.xml  ${BBOX_dir}/${RMOD_SERIAL_NUMBER}_permanent/permanent.xml  connection=secondary
  ...    AND    tafssh.Send Command  rm /ffs/permanent.xml  connection=secondary
  Logging With Timestamp
  ...  message=Downloading BBOX from SMOD to VM
  ...  style=DONE
  ${xml}=    Parse Xml    ${BBOX_dir}/${RMOD_SERIAL_NUMBER}_permanent/permanent.xml
  ${encoded_str_all}=    Get Element Text  ${BBOX_dir}/${RMOD_SERIAL_NUMBER}_permanent/permanent.xml
  Log  ${xml}
  ${encoded_str}=  Fetch From Right  ${encoded_str_all}  BtsId
  ${encoded_str}=  Fetch From Left  ${encoded_str}  BtsVersion
  ${decoded_bts_string}=    Evaluate    base64.b64decode('${encoded_str}').decode('utf-8')  modules=base64
  ${software_info}=  Get Software Info  connection=${BTS_ID}
  Run Keyword and Continue on Failure  Should Contain
  ...  '${decoded_bts_string}'
  ...  ${bts_name}_${HW_DICT['smod_productCode']}_${HW_DICT['smod_serialNumber']}_${HW_DICT['bbmod_productCode']}_${HW_DICT['bbmod_serialNumber']}
  Run Keyword and Continue on Failure  Should Contain  '${encoded_str_all}'  ${software_info['Active SW version']}
  Logging With Timestamp
  ...  message=step 5: Check BTS ID and SW
  ...  style=DONE

Check P/C And S/N in BBox
  [Arguments]  ${bbox_folder}  ${ru_serial_number}  ${ru_product_code}
  [Documentation]  CB010655_K_1_support_radio_product_code_and_serial_number
  ...  KW checks if BBOX file located in ${bbox_folder} has correct product code and serial number
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bbox_folder            | yes  |  Folder with black box files                                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | ru_serial_number       | yes  |  RU serial number to check                                                 |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | ru_product_code        | yes  |  RU product code to check                                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+

  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  ${ru_product_code}=  Get RU Product Code  ru_sn=${ru_serial_number}
  ${ru_product_code_check}=  Set Variable  ${False}
  ${tmp_rm_serial_number_check}=  Set Variable  ${False}
  ${rm_serial_number_check}=  Set Variable  ${False}
  Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_serial_number}
  radio.Send Command  cat /mnt/factory/configs/unit/module_product_code.txt
  ${ru_pc_from_ru_files}=  radio.Read Until Prompt  prompt=$|#
  radio.Send Command  cat /mnt/factory/configs/unit/module_serial_number.txt
  ${ru_sn_from_ru_files}=  radio.Read Until Prompt  prompt=$|#
  radio.Close SSH Connection
  ${bbox_hwpart_list}=  Get Part Of Bbox List
  ...  file_path=${BBOX_dir}/${bbox_folder}/BBOX5  start_string=Item type: HW_information  end_string=---
  Should Contain  ${ru_pc_from_ru_files}  ${ru_product_code}
  Logging With Timestamp
  ...  message=RU Product Code ${ru_product_code} is visible in /mnt/factory/configs/unit/module_product_code.txt
  ...  style=DONE
  Should Contain  ${ru_sn_from_ru_files}  ${ru_serial_number}
  Logging With Timestamp
  ...  message=RU Serial Number ${ru_serial_number} is visible in /mnt/factory/configs/unit/module_serial_number.txt
  ...  style=DONE
  Should Contain  ${bbox_hwpart_list}  unit serial number: ${ru_serial_number}  msg=BBOX File does not contain RU serial number ${ru_serial_number}
  Logging With Timestamp
  ...  message=BBOX file contains RU serial number ${ru_serial_number}
  ...  style=DONE
  Should Contain  ${bbox_hwpart_list}  unit product code: ${ru_product_code}  msg=BBOX FILE does not contain RU product code ${ru_product_code}
  Logging With Timestamp
  ...  message=BBOX file contains RU product code ${ru_product_code}
  ...  style=DONE

Get RU Product Code
    [Arguments]   ${ru_sn}
    [Documentation]
    ...  KW returns RU product code according to RU serial number passed by argument.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_sn                  | yes  |  RU serial number                                                          |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    ${bts_info}=    Get Bts Info    alias=${BTS_ID}
    Set Test Variable    ${BTS_INFO}    ${bts_info}
    ${ru_info}=    Get From Dictionary   ${bts_info['radioModules']}    rmod
    FOR   ${ru}    IN    @{ru_info}
        ${ru_product_code}=    Set Variable If  "${ru['serialNumber']}" == "${ru_sn}"    ${ru['productCode']}
        Exit For Loop If   "${ru['serialNumber']}" == "${ru_sn}"
    END
    [Return]    ${ru_product_code}

Get SMOD IP For Connected RMOD
  [Documentation]
  ...  KW returns SMOD IP for the RMOD connected to it.
  ...
  ...  | **Author:** mateusz.kawka@nokia.com
  ...
  ...  | **Full description:**
  ...  KW returns SMOD IP for the RMOD connected to it
  ...  according to the RU serial number passed by argument.
  ...  Keyword Get RU IPs is used inside.
  ...
  ...  **Input Parameters:**
  ...
  ...  +------------------+------+-----------------------------------------------------+
  ...  | Parameter        | Man. | Description                                         |
  ...  +==================+======+=====================================================+
  ...  | rmod_sn          | Yes  | RMOD serial number                                  |
  ...  +------------------+------+-----------------------------------------------------+

  [Arguments]  ${rmod_sn}

  ${all_ips}=  radio.Get IP For All Radio Modules  print_table=False

  FOR  ${smod}  ${ips}  IN ZIP  ${all_ips.keys()}  ${all_ips.values()}
      ${nested_dict}=  Get From Dictionary  ${all_ips}  ${smod}
      ${is_rmod_sn}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${nested_dict}  ${rmod_sn}
      Continue For Loop If  '${is_rmod_sn}'=='False'
      Return From Keyword  ${smod}
  END

Select SMOD For RU
  [Arguments]  ${ru_sn}
  [Documentation]
  ...  KW returns smod index for RU. Index 1 means primary smod
  ...
  ...
  ...  +------------------+------+-----------------------------------------------------+
  ...  | Parameter        | Man. | Description                                         |
  ...  +==================+======+=====================================================+
  ...  | ru_sn            | Yes  | RMOD serial number                                  |
  ...  +------------------+------+-----------------------------------------------------+
  ...
  ...  +---------------------------+-------------------------------------------------------------------------------+
  ...  | Return Value              | Description                                                                   |
  ...  +===========================+===============================================================================+
  ...  | node_number               | Index 1 means primary smod                                                    |
  ...  +---------------------------+-------------------------------------------------------------------------------+
  ...
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: Author

  tafssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=temporary
  ${output}=  tafssh.Execute  cat /rom/config/FRIps.txt  connection=temporary
  ${is_primary}=  Run Keyword And Return Status  Should Contain  ${output}  ${ru_sn}
  ${node_number}=  Set Variable If  ${is_primary}  ${1}  ${2}
  [Return]  ${node_number}
  [Teardown]  tafssh.Disconnect  connection=temporary
