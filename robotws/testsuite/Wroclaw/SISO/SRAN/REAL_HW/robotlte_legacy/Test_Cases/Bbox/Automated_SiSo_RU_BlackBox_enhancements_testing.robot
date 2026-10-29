*** Settings ***
Documentation   TBD.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak


Library     DateTime
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     ../../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.transport.ssh  WITH NAME  tafssh


*** Variables ***
${temp_folder_name}  temp
${TESTED_RU_SN}
${SKIP_SW_VERSION_CHECK_STEP}  False
@{sw_version_template}  Item type: SW_version  Last write   File [0] name  File [0] version  File [0] status  File [1] name  File [1] version
...  File [1] status
@{isti_template}  Item type: Isti  Last write  Value
@{reset_info_template}  Item type: resets  Reset Counter  Reset[0] Write  Reset[0] Reset Reason  Reset[0] Reset Cause  Reset[0] Failed Service
...  Reset[1] Write  Reset[1] Reset Reason  Reset[1] Reset Cause  Reset[1] Failed Service
...  Reset[2] Write  Reset[2] Reset Reason  Reset[2] Reset Cause  Reset[2] Failed Service
...  Reset[3] Write  Reset[3] Reset Reason  Reset[3] Reset Cause  Reset[3] Failed Service
...  Reset[4] Write  Reset[4] Reset Reason  Reset[4] Reset Cause  Reset[4] Failed Service
@{soc_version_template}  Item type: soc_version  Value
@{memory_load_template}  Item type: memory_load  Item id  First write  Last write  Min  Max  Average  Ranges [%]  Values
@{cpu_load_template}  Item type: cpu_load  Item id  First write  Last write  Min  Max  Average  Ranges [%]  Values
@{temperature_template}  Item type: Temperature  Item id  First write  Last write  Ranges [°C]  Values  Last days 90
@{voltage_template}  Item type: Voltage  Item id  First write  Last write  Ranges [V]  Values  Last days 90
@{optical_lvl_template}  Item type: Optical_lvl_signal  Item id  First write  Last write  Reference signal  Ranges [dB]  Values
@{flush_counter_template}  Item type: NvmFlushCounter  Periodical trigger occur times  Temperature gradient trigger occur times
...                         Reset trigger occur times

&{timeBetweenSaveOnNVM}    timeBetweenSaveOnNVM=30
&{timeBetweenSaveOnNVM_blabla}    timeBetweenSaveOnNVM=86400

&{BBOX_UPGRADE_BUILD}=
...             SBTS24R3=SBTS24R3_ENB_0000_001030_000000
...             SBTS25R1=SBTS25R1_ENB_0000_000602_000000
...             SBTS25R2=SBTS25R2_ENB_0000_000001_000000
...             SBTS25R3=SBTS00_ENB_9999_250228_000001
${SW_BUILDS_DIR_PATH}

*** Keywords ***
Bbox combo
    [Documentation]
    ...  Description:
    ...
    ...  Step 1: Collect blackbox files from RU and snapshot to VM and check if there are the same.
    ...  Step 2: Check if product code and serial number in blackbox matches values from webem and RU unit.
    ...  Step 3: Check if histograms in blackbox have correct values.
    ...  Step 4: Check black box functions and their structure in blackbox file.
    ...  Step 5: Check bts id and software version in permanent.xml file on RU.
    ...  Step 6: Reset RU and check if blackbox file has increased value for reset counter part.
    ...  Step 7: Check record number of occurences for different triggers
    ...  Step 8: Generate and recover faults and check if blackbox has updated records for them.
    ...  Step 9: Update vDU to software with different RFSW version. Check if blackbox has correct values for the updated software.
    ...  Step 10: Clear blackbox file.

    Set Tags
    ...    OWNER-szymon.przybylak@nokia.com
    ...    AUTHOR-szymon.przybylak@nokia.com
    ...    MAINTAINER-szymon.przybylak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Bbox combo
    ...  style=ONGOING
    FOR  ${rm_sn}  IN  @{CUSTOM_RADIO_UNIT_LIST}
        Set Test Variable  ${TESTED_RU_SN}  ${rm_sn}
        ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${TESTED_RU_SN}
        Bbox combo All Steps
    END
    [Teardown]    Common Test Teardown

Bbox combo All Steps
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Log  ${cfg}
        Bbox Precondition  node=${node}

    END
    FOR  ${node}  IN  @{cfg.active_bts_list}
        ${dst_folder}  step1: Collect BBox From Webem and RU  node=${node}
        step2: Check P/C and S/N  dst_folder=${dst_folder}  node=${node}
        step3: Check Histograms For Bbox From RU And Snapshot  dst_folder=${dst_folder}
        step4: Check black box functions  dst_folder=${dst_folder}
        step5: Check Bts Id and SW    node=${node}
        step6: Check Reset Counters  dst_folder=${dst_folder}  node=${node}
        step7: Check Record Number Of Occurences For Every Trigger    dst_folder=${dst_folder}   node=${node}
        step8: Generate Fault And Check BBox  node=${node}
        step9: Radio SW Version And Firmware Check  node=${node}  dst_folder=${dst_folder}
        step10: Check Clear Black Box Data  node=${node}
    END
    [Teardown]    radio.Close SSH Connection

Bbox Precondition
    [Arguments]  ${node}
    [Documentation]  Black Box preconditions. Prepares RMOD_L data, HW_dict with serial/product number of HW.
    Log To Console  === Black Box Precondition Start ===  console=True
    radio.Close SSH Connection
    Set Test Variable  ${BTS_ID}  ${node}
    ${hw_dict}  Create Dictionary
    Set Test Variable  ${HW_DICT}  ${hw_dict}
    ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
    Set Test Variable  ${RF_LIST}  ${rf_list}
    Set Test Variable    ${scfc_file_path}   ${CFG['NODES']['${node}']['scf_file_path']}
    ${bts_info}=  Get BTS Info  connection=${node}
    ${sfp_links_info}  Get Sfp Links  action=getLinks  connection=${node}
    ${rmod_disname}=  Evaluate
    ...  next(distname["id"]["internal"] for distname in ${bts_info["radioModules"]["rmod"]} if distname["serialNumber"] == "${TESTED_RU_SN}")
    Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod_disname}
    ${bbmod_distname_list}=  Find All Connections To BBMOD  ${rmod_disname}  ${sfp_links_info}
    ${bbmod_distname_list}=  Remove Duplicates  ${bbmod_distname_list}
    # TODO: Potential bug! Only first of all found BBMODs will be added to ${HW_DICT}
    ${eva_object_2}=  Set Variable    if bbmod["id"]["internal"] == "${bbmod_distname_list[0]}")
    ${bbmod_sn}  ${bbmod_pc}=  Evaluate
    ...  next((bbmod["serialNumber"], bbmod["productCode"]) for bbmod in ${bts_info["basebandModules"]} ${eva_object_2}
    Set To Dictionary  ${HW_DICT}  bbmod_productCode  ${bbmod_pc}
    Set To Dictionary  ${HW_DICT}  bbmod_serialNumber  ${bbmod_sn}
    #taking default value for timeBetweenSaveOnNVM
#    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${TESTED_RU_SN}
     ${binary_file_dict}  radio.Get Decoded Binary File
    ...    ru_serial_number=${TESTED_RU_SN}
    ...    filename=black_box_logger
    Set Test Variable    ${BINARY}    ${binary_file_dict}
    ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}  Create Dictionary
    Set Test Variable  ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
    Set To Dictionary  ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}  timeBetweenSaveOnNVM  ${BINARY['timeBetweenSaveOnNVM']}
    Run Keyword If  '${BINARY['timeBetweenSaveOnNVM']}'=='30'  Fail
    ...  msg=Value of timeBetweenSaveOnNVM is not the default value! Override it manualy to 86400 and retest.
    ${smod_sn}  Find SMOD By Given BBMOD  ${bbmod_sn}
    Set To Dictionary  ${HW_DICT}  smod_serialNumber  ${smod_sn}
    FOR  ${value}  IN  @{bts_info['systemModules']}
        Continue For Loop If  '${smod_sn}' != '${value['serialNumber']}'
        Set To Dictionary  ${HW_DICT}  smod_productCode   ${value['productCode']}
    END
    Log  ${HW_DICT}
    Log To Console  Resetting RMOD before test.  console=True
    admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${node}
    Verify All Cells OnAir    ${node}
    Log To Console  Black Box Precondition Finished  console=True

Find SMOD By Given BBMOD
    [Arguments]  ${bbmod_sn}
    ${sm_bbmod_dict}  radio.Get AirScale BBMOD Mapping
    FOR  ${smod}  ${bbmod_list}  IN ZIP  ${sm_bbmod_dict.keys()}  ${sm_bbmod_dict.values()}
      ${matching_value}  Evaluate  [v for v in ${bbmod_list} if '${bbmod_sn}' in v]
      ${wanted_smod}  Run Keyword If  ${matching_value}  Set Variable  ${smod}
      Exit For Loop If  ${matching_value}
    END
    ${smod_sn}  Split String  ${wanted_smod}  ${SPACE}
    [Return]  ${smod_sn[1]}

Find All Connections To BBMOD
    [Arguments]  ${rmod_disname}  ${sfp_links_info}
    # Get all links where RMOD above is as a source and save it to list
    ${rmod_sfp_connections_list}=  Evaluate  [link["destination"] for link in ${sfp_links_info} if "${rmod_disname}" in link["source"]]
    # Removing /SFP_R-X from links
    ${rmod_sfp_connections_list_splited}  Evaluate  ['/'.join(link.split("/")[:-1]) for link in ${rmod_sfp_connections_list}]
    # For each link in list get its destination and check if it contains BBMOD_R
    ${bbmod_distname_list}  Create List
    FOR  ${link}  IN  @{sfp_links_info}
      # Removing /SFP_R-X from link
      ${splited_link}  Split String  ${link["destination"]}  /
      Remove From List  ${splited_link}  -1
      ${splited_link}  Catenate  SEPARATOR=/  @{splited_link}
      # Skip if not this link
      Continue For Loop If  "${splited_link}" not in @{rmod_sfp_connections_list_splited}
      Run Keyword If  "BBMOD_R" in "${splited_link}"  Run Keywords
      ...  Append To List  ${bbmod_distname_list}  ${splited_link}
      ...  AND  Continue For Loop
#      ${bbmod_distname}=  Find All Connections To BBMOD  ${splited_link}  ${sfp_links_info}
#      Append To List  ${bbmod_distname_list}  @{bbmod_distname}
    END
    [Return]  ${bbmod_distname_list}

step1: Collect BBox From Webem and RU
    [Arguments]  ${node}
    [Documentation]  Step 1 on test that downloads to VM BBOX files from snapshot and RU.
    ...  Files are later used in other KWs that do not require more actions before checking files.
    Log  ${cfg}
    Log To Console  === step 1: Collect BBox From Webem and RU started ===  console=True
    ${destination_folder_name}  Collect Both BBox Files For Radio  destination_folder_name=${TESTED_RU_SN}/step_1_collect_bbox_files  node=${node}
    [Return]  ${destination_folder_name}

step2: Check P/C and S/N
    [Documentation]    CB010655_K_1_support_radio_product_code_and_serial_number
    ...  KW checks if BBOX file located in ${dst_folder} has correct product code and serial number
    [Arguments]  ${dst_folder}  ${node}
    Log To Console  === step2: Check Product Code and Serial Number in BBox files ===  console=True
    FOR   ${ru_sn}    IN    @{rf_list}
        Continue For Loop If  '${ru_sn}'!='${TESTED_RU_SN}'
        ${ru_product_code}  Get RU Product Code  ru_sn=${ru_sn}  node=${node}
        Check P/C And S/N in BBox  bbox_folder=${dst_folder}  ru_serial_number=${ru_sn}  ru_product_code=${ru_product_code}  node=${node}
        Exit For Loop
    END
step3: Check Histograms For Bbox From RU And Snapshot
    [Documentation]  CB010655_E_1_enhancement_of_temperature_voltage_input_current_consumption_history
    ...  KW that checks if there are histograms for correct types, and if there is enough records in them. Checks only 1 bbox file!
    ...  As in step 1 was that BBOX files are identical
    [Arguments]  ${dst_folder}
    Log To Console  === step 3: Check histograms for bbox  console=True
    FOR  ${ru_sn}  IN  @{rf_list}
        Check Histograms For Single File  dst_folder=${dst_folder}  file_name=BBOX5
    END
    Log To Console    Histograms checked - OK    console=True

step4: Check black box functions
  [Arguments]    ${dst_folder}
  [Documentation]  CB010655_A_1_parity_legacy_black_box_5_function_of_CB006622_CB007833
  ...  Step 4 of test that checks if structure of corresponding parts of black box are correct.
  Log To Console  === step 4: Check Black Box functions
  FOR   ${ru_sn}    IN    @{rf_list}
      Continue For Loop If  '${ru_sn}'!='${TESTED_RU_SN}'
      ${hw_release_bool}  Run Keyword And Return Status
      ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${TESTED_RU_SN}']['scf_release_code']}').group(0)  re
      ${hw_release}=    Run Keyword If    ${hw_release_bool}==True
      ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${TESTED_RU_SN}']['scf_release_code']}').group(0)  re
      Exit For Loop
  END
  ${sw_version_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: SW_version
  ${isti_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: Isti
  ${reset_info_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: resets
  ${soc_version_keys}  ${part_bbox_keys}  Run Keyword If  ${hw_release}==5.1 or ${hw_release}==7.1
  ...    Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: soc_version
  ...    ELSE    Evaluate    list(), list()
  ${memory_load_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: memory_load
  ${cpu_load_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: cpu_load
  ${temperature_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: Temperature
  ${voltage_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check  dst_folder=${dst_folder}  start_string=Item type: Voltage
  ${optical_lvl_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
  ...  dst_folder=${dst_folder}  start_string=Item type: Optical_lvl_signal
  Log  ${sw_version_keys}
  Log  ${sw_version_template}
  FOR  ${item}  IN  @{sw_version_keys}
      Log  ${item}
      Run Keyword and Continue on Failure  Should Contain  ${sw_version_template}  ${item}
  END
  FOR  ${item}  IN  @{isti_keys}
      Run Keyword and Continue on Failure  Should Contain  ${isti_template}  ${item}
  END
  FOR  ${item}  IN  @{reset_info_keys}
      Run Keyword and Continue on Failure  Should Contain  ${reset_info_template}  ${item}
  END
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
  Log To Console    Black Box Functions checked    console=True

step5: Check Bts Id and SW
  [Arguments]  ${node}
  [Documentation]  KW checks if file permanent.xml on RU has correct values for SW and BTS ID
  ...  In case of classical BTS, "BTS ID" is configured btsName, P/C and S/N of the SMOD, and P/C and S/N of the BBMOD.
  Log To Console  === step 5: Check BTS ID and SW ===  console=True
  ${bts_name}=  Evaluate Xpath  ${scfc_file_path}  string(.//managedObject[@class= "com.nokia.srbts:MRBTS"]/p[@name="btsName"]/text())
  # Find master of chain if chain detected
  ${master_rm}=    Find RM Parent In Chain    ${TESTED_RU_SN}
  FOR  ${ru_sn}  IN  @{CFG.RF_INFO}
      Continue For Loop If  '${ru_sn}'!='${TESTED_RU_SN}'
      Log To Console  Open Connection To RM  console=True
#        Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
      Log To Console    Copying permanent.xml from RM ${ru_sn} to SMOD
      Wait Until Keyword Succeeds   60  5  radio.Send File Via SCP
      ...  ru_serial_number=${ru_sn}
      ...  direction=to_smod
      ...  file_path=/mnt/runtime/rfsw/uoam/permanent.xml
      ...  destination_directory=/ffs
#        radio.Close SSH Connection
      Log To Console    Downloading BBOX from SMOD to VM  console=True

      ${smod}  Get SMOD IP For Connected RMOD  ${ru_sn}
      ${node_number}=  Select SMOD For RU  ${ru_sn}
#      ${node_number}=    Set Variable    ${CFG.RF_INFO["${ru_sn}"]["scf_chain_position"][0][0]}
      Create Directory  ${cfg.test_logs_path}/${ru_sn}_permanent
      Run Keyword If    ${node_number} == 1    Run Keywords
      ...    tafssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
      ...    AND    tafssh.Download File  /ffs/permanent.xml  ${cfg.test_logs_path}/${ru_sn}_permanent/permanent.xml  connection=primary
      ...    AND    tafssh.Send Command  rm /ffs/permanent.xml  connection=primary
      ...    ELSE   Run Keywords    tafssh.Connect To  ${CFG.NODES['${BTS_ID}']['secondary_sm_vm_ip_LMP_address']}  ute  alias=vm${node_number}
      ...    AND    tafssh.Connect To  192.168.255.119  toor4nsn  oZPS0POrRieRtu  proxy=vm${node_number}  alias=secondary
      ...    AND    tafssh.Download File  /ffs/permanent.xml  ${cfg.test_logs_path}/${ru_sn}_permanent/permanent.xml  connection=secondary
      ...    AND    tafssh.Send Command  rm /ffs/permanent.xml  connection=secondary
      ${xml}=    Parse Xml    ${cfg.test_logs_path}/${ru_sn}_permanent/permanent.xml
      ${encoded_str_all}=    Get Element Text  ${cfg.test_logs_path}/${ru_sn}_permanent/permanent.xml
  END
  Log  ${xml}
  ${encoded_str}  Fetch From Right  ${encoded_str_all}  BtsId
  ${encoded_str}  Fetch From Left  ${encoded_str}  BtsVersion
  ${decoded_bts_string}=    Evaluate    base64.b64decode('${encoded_str}').decode('utf-8')  modules=base64
  ${software_info}  Get Software Info  connection=${node}
  Run Keyword and Continue on Failure  Should Contain
  ...  '${decoded_bts_string}'
  ...  ${bts_name}_${HW_DICT['smod_productCode']}_${HW_DICT['smod_serialNumber']}_${HW_DICT['bbmod_productCode']}_${HW_DICT['bbmod_serialNumber']}
  Run Keyword and Continue on Failure  Should Contain  '${encoded_str_all}'  ${software_info['Active SW version']}
  Log To Console    BTS ID and sw version checked - OK    console=True

Find RM Parent In Chain
  [Arguments]    ${rm_sn}
  FOR    ${rm_info}    IN    @{CFG.RF_INFO}
      Continue For Loop If    "${rm_sn}" not in ${CFG.RF_INFO["${rm_info}"]["scf_chain_fr_affected_list"]}
      Return From Keyword    ${rm_info}
  END
  Return From Keyword    ${False}

Find Master Of Chain For RM
  [Arguments]    ${rm_sn}
  ${master_rm}=    Find RM Parent In Chain    ${rm_sn}
  ${more_master_rm}=    Run Keyword If    "${master_rm}"!="${False}"    Find RM Parent In Chain    ${master_rm}
  Return From Keyword If    "${more_master_rm}"=="${None}" or "${more_master_rm}"=="${False}"    ${master_rm}
  Return From Keyword    ${more_master_rm}

step6: Check Reset Counters
  [Documentation]  CB010655_I_1_enhancement_of_reset_counter
  ...  KW Takes number of resets from already provided bbox files (both snapshot and RU) and compares it to values from BBOX
  ...  files after RU reset. Check is done if the reset counter value is bigger (+1), if the records moved correctly and if
  ...  the time of newly done site reset is noted properly.
  [Arguments]  ${dst_folder}  ${node}
  Log To Console  === step 6: Check Reset Counters ===  console=True
  ${first_value_list}  Create List
  ${reset_counter_ru}  Get Part Of Bbox List
  ...  file_path=${cfg.test_logs_path}/${dst_folder}/BBOX5
  ...  start_string=Item type: resets
  ...  end_string=---
  ${reset_counter_value_before_reset}  ${write_value_before_reset}  Get Reset Counter Value And Write Value From Bbox
  ...  reset_counter_values_list=${reset_counter_ru}  index=0
  FOR   ${ru_sn}    IN    @{rf_list}
      Continue For Loop If  '${ru_sn}'!='${TESTED_RU_SN}'
      Log To Console  Performing Reset of RMOD ${ru_sn}  console=True
      ${reset_start_date}  Get Current Date  UTC
      ${status}  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${node}  detailed_output=True
      ${reset_end_date}  Get Current Date  UTC
      Verify All Cells OnAir    ${node}
      Log  ${status}
      Exit For Loop If  '${ru_sn}'=='${TESTED_RU_SN}'
  END
  Sleep  20  #wait to increase time between time after reset for bbox file to be updated
  ${reset_counter_folder}  Collect Both BBox Files For Radio  destination_folder_name=${TESTED_RU_SN}/step_6_reset_counter  node=${node}
  ${after_reset_counter_ru_list}  Get Part Of Bbox List
  ...  file_path=${cfg.test_logs_path}/${reset_counter_folder}/BBOX5
  ...  start_string=Item type: resets
  ...  end_string=---
  ${reset_counter_value_after_reset}  ${write_value_after_reset}  Get Reset Counter Value And Write Value From Bbox
  ...  reset_counter_values_list=${after_reset_counter_ru_list}  index=1
  ${alarm_check}  Evaluate  '${write_value_after_reset}'=='${write_value_before_reset}'
  ${result}    Evaluate    ${reset_counter_value_before_reset}+1 == ${reset_counter_value_after_reset}
  Should Be True  '${alarm_check}'=='True' and '${result}'=='True'
  ${bbox_reset_time_raw}  Set Variable  ${after_reset_counter_ru_list[2]}
  ${bbox_reset_time_fetched}  Fetch From Right  ${bbox_reset_time_raw}  Write:
  ${bbox_reset_time}  Evaluate  '${bbox_reset_time_fetched}'.replace(' ','')
  ${bbox_reset_time}  Evaluate  '${bbox_reset_time}'.replace('T',' ')
  ${diff}  DateTime.Subtract Date From Date  ${bbox_reset_time}  ${reset_start_date}
  Should Be True  ${diff}<15
  Check Reset Tree  reset_part_list=${after_reset_counter_ru_list}
  Log To Console    Reset Counters checked - OK    console=True

step9: Radio SW Version And Firmware Check
  [Arguments]  ${node}  ${dst_folder}
  [Documentation]    CB010655_G_1_enhancement_of_radio_SW_version_and_firmware_version
  ...  KW Updates BTS to older version of software with different RFSW. Then checks if the update is visible in BBOX file
  ...  (firmware and software version)
  Log To Console  ==== step 9: Radio SW Version and firmware check =====  console=True
  ${should_execute_rollback}  Set Variable  False
  IF  ${SKIP_SW_VERSION_CHECK_STEP}
    Log To Console  ==== step 9: Skipped as variable SKIP_SW_VERSION_CHECK_STEP set to True =====  console=True
    Return From Keyword
  END
  ${sw_version_history_part}  Get Part Of Bbox List
  ...  file_path=${cfg.test_logs_path}/${dst_folder}/BBOX5
  ...  start_string=Item type: SW_version_history
  ...  end_string=---
  Log To Console  Update Software To Older Version Started  console=True
  Set Test Variable    ${bbox_sw_folder}    /home/ute/bbox_sw
  ${active_branch}=    Get From Dictionary    ${cfg.NODES['${bts_id}']}     active_release
  ${is_passive}  Run Keyword And Return Status  Should Contain
  ...  ${BBOX_UPGRADE_BUILD['${active_branch}']}  ${cfg.NODES['${node}']['software_passive']}
  ${T1_passive}  Run Keyword If  ${is_passive}  Run Keyword And Return Status  Should Contain  ${cfg.NODES['${node}']['software_passive']}  T1
  ${T2_passive}  Run Keyword If  ${is_passive}  Run Keyword And Return Status  Should Contain  ${cfg.NODES['${node}']['software_passive']}  T2
  ${bbox_older_software}=    Run Keyword If  ${is_passive} and ${T1_passive}  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}
  ...  ELSE IF  ${is_passive} and ${T2_passive}  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}
  ...  ELSE IF  ${is_passive}  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}T1
  ...  ELSE  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}
  ${bbox_software_package_path}  Check Main Software Package Availability  ${bbox_older_software}  ${BTS_ID}
  ${update_start_date}  Get Current Date  UTC
  Automated_SiSo_RU_BlackBox_enhancements_testing.Update SW If Needed  ${node}  ${bbox_software_package_path}
  ${should_execute_rollback}=    Set Variable    True
  ${update_end_date}  Get Current Date  UTC
  Verify BTS State    ${node}    ${CONFIGURATION_STARTUP_TIMEOUT}
  Verify Alarms    alias=${node}
  Log To Console  Reset Unit after software update  console=True
  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${node}
  Verify All Cells OnAir    ${node}

  ${rmods_parameters}  admin.Get Parameters For All  class_name=RMOD  connection=${node}
  FOR  ${parameter}  IN  @{rmods_parameters}
      Continue For Loop If  '${parameter['serialNumber']}'!='${TESTED_RU_SN}'
      Set Test Variable  ${RMOD_SW_VERSION}  ${parameter['buildVersion']}
      Exit For Loop
  END
  ${ru_bts_id}=    Get From Dictionary    ${cfg.RF_INFO['${TESTED_RU_SN}']}   scf_btsid_primary
  ${ru_dist_name}=    Get From Dictionary    ${cfg.RF_INFO['${TESTED_RU_SN}']}    scf_dist_name_primary
  ${bts_info}=    Admin Get BTS Info Into Dictionary    ${ru_bts_id}
  ${asirmod_status}  Run Keyword And Return Status  Should Match Regexp  ${ru_dist_name}  ASIRMOD
  ${class}  Set Variable If  ${asirmod_status}    asirmod  rmod
  ${ru_info}=    Get From Dictionary   ${bts_info['radioModules']}    ${class}
  ${step9_after_update_dst_folder}  Collect Both BBox Files For Radio  destination_folder_name=${TESTED_RU_SN}/step_9_after_update  node=${node}
  Check SW Version History and Firmware  folder=${step9_after_update_dst_folder}
  ${sw_version_history_after_part}  Get Part Of Bbox List
  ...  file_path=${cfg.test_logs_path}/${step9_after_update_dst_folder}/BBOX5
  ...  start_string=Item type: SW_version_history
  ...  end_string=---
  Log  ${sw_version_history_part}
  Log  ${sw_version_history_after_part}
  Log To Console  Checking Software Verstion History  console=True
  FOR  ${index}  IN RANGE  10
      Continue For Loop If  ${index} <= 1
      ${old_temp}  Fetch From Right  ${sw_version_history_part[${index}]}  :
      ${new_temp}  Fetch From Right  ${sw_version_history_after_part[${index+2}]}  :
      Should Match  ${old_temp}  ${new_temp}
  END
  Log To Console  Checking Software Version History - finished. All Ok  console=True
  ${rmod_build_number}  Get RMOD Build Product Number
  Should Contain  ${sw_version_history_after_part[2]}  ${rmod_build_number}
  Perform SW Rollback    ${node}
  ${should_execute_rollback}=    Set Variable    False
  Run Keyword And Ignore Error    CM BTS Admin Not Available    ${node}    120
  Wait Until Keyword Succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  20 sec  admin.Reset Admin  connection=${node}
  Verify BTS state    ${node}    ${CONFIGURATION_SWUPDATE_TIMEOUT}
  Verify Alarms    alias=${node}
  Log To Console    Software Update checked - OK    console=True
  [Teardown]  Run Keyword If  ${should_execute_rollback}    Perform SW Rollback    ${node}

step7: Check Record Number Of Occurences For Every Trigger
  [Arguments]    ${dst_folder}    ${node}
  [Documentation]    CB010655_D_1_support_to_record_number_of_occurrences_for_every_trigger
  ...    Checks if records update correctly. First it ovverrides value of timeBetweenSaveOnNVM in black_box_logger on RU and performs 2 resets.
  ...    After that checks if black box is updated in records for Periodical trigger occur times and Reset trigger occur times.
  ...    ${dst_folder} = folder which have already downloaded bbox files (from step 1)
  Log To Console  === Step 7: Check Record Number Of Occurences For Every Trigger ===  console=True
  ${should_execute_recovery}=    Set Variable    True
  ${nvm_flushcounter_only_keys}  ${nvm_flushcounter_dict}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: NvmFlushCounter
  FOR  ${item}  IN  @{flush_counter_template}
      Run Keyword and Continue on Failure  Should Contain  ${nvm_flushcounter_only_keys}  ${item}
  END
  Log To Console  Getting and Overriding timeBetweenSaveOnNVM to ${timeBetweenSaveOnNVM['timeBetweenSaveOnNVM']}  console=True
#    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${TESTED_RU_SN}
  radio.Override Values In Binary File
  ...  ru_serial_number=${TESTED_RU_SN}
  ...  filename=black_box_logger
  ...  values_dict=${timeBetweenSaveOnNVM}
  ...  reset_ru=False
  #86400
  #Log To Console  Waiting for FID 10  console=True
  #${alarm_info_assert}=     Run Keyword And Continue On Failure    Assert Alarm Active     faultId=10, severity=Critical
  #...       timeout=600
  #...       connection=${node}
  Verify All Cells OnAir    ${node}
#    radio.Close SSH Connection
  Log To Console  Performing first RMOD ${TESTED_RU_SN} reset  console=True
  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${node}
  Verify All Cells OnAir    ${node}
  Log To Console  Performing second RMOD ${TESTED_RU_SN} reset  console=True
  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${node}
  Verify All Cells OnAir    ${node}
  ${stepz_folder_name}  Collect Both BBox Files For Radio  destination_folder_name=${TESTED_RU_SN}/step_8_check_records_of_occurences  node=${node}
  ${nvm_flushcounter_after_reset_only_keys}  ${nvm_flushcounter_after_reset_dict}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${stepz_folder_name}  start_string=Item type: NvmFlushCounter
  FOR  ${item}  IN  @{flush_counter_template}
      Run Keyword and Continue on Failure  Should Contain  ${nvm_flushcounter_after_reset_only_keys}  ${item}
  END
  Log To Console  Restoring defaut value ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']} to timeBetweenSaveOnNVM  console=True
#    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${TESTED_RU_SN}
  radio.Override Values In Binary File
  ...  ru_serial_number=${TESTED_RU_SN}
  ...  filename=black_box_logger
  ...  values_dict=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
  ...  reset_ru=True
  ${periodical_increment}  Evaluate
  ...  int(${nvm_flushcounter_dict['Periodical trigger occur times']}) < int(${nvm_flushcounter_after_reset_dict['Periodical trigger occur times']})
  ${reset_increment}  Evaluate
  ...  int(${nvm_flushcounter_dict['Reset trigger occur times']})+3 == int(${nvm_flushcounter_after_reset_dict['Reset trigger occur times']})
  Should Be True  '${periodical_increment}' == 'True' and '${reset_increment}' == 'True'
  Log To Console  Waiting for FID 10  console=True
#    radio.Close SSH Connection
  ${alarm_info_assert}=     Run Keyword And Continue On Failure    Assert Alarm Active     faultId=10, severity=Critical
  ...       timeout=600
  ...       connection=${node}
  Verify All Cells OnAir    ${node}
  ${should_execute_recovery}=    Set Variable    False
  [Teardown]  Run Keyword If  ${should_execute_recovery}  Wait Until Keyword Succeeds  3min  10sec    Restore Binary File

step8: Generate Fault And Check BBox
  [Arguments]  ${node}
  Log To Console  ==== Step 8: Generate Faults started ====  console=True
  FOR  ${ru_sn}  IN  @{rf_list}
    Continue For Loop If  '${ru_sn}'!= '${TESTED_RU_SN}'
    ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${ru_sn}
    Run Keyword If  "${cfg.RF_INFO['${TESTED_RU_SN}']['scf_variant']}" == "AHFIB"
    ...  Run Keywords
    ...  Set Test Variable  ${first_alarm}  1927
    ...  AND  Log  \nGenerate FID:1927 on ${ru_sn}  console=True
    ...  AND  Wait Until Keyword Succeeds  10min  10sec  radio.Generate Fault  fault_id=1927  severity=Major  ru_serial_number=${ru_sn}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${first_alarm}  1937
    ...  AND  Log  \nGenerate FID:1937 on ${ru_sn}  console=True
    ...  AND  Wait Until Keyword Succeeds  10min  10sec  radio.Generate Fault  fault_id=1937  severity=Critical  ru_serial_number=${ru_sn}
    Log  \nWaiting for FID:${first_alarm} to appear on ${ru_sn}  console=True
    IF  "${cfg.RF_INFO['${TESTED_RU_SN}']['scf_variant']}" == "AHFIB"
        FM Await For Fault
        ...  fault_attr=faultId=${first_alarm}, severity=Major, alarmingObjectIds[0].internal=${ru_dist_name}
        ...  node_id=${node}
        ...  alarm_resource=${FAULT_1927}
        ...  timeout=120
    ELSE
        FM Await For Fault
        ...  fault_attr=faultId=${first_alarm}, severity=Critical, alarmingObjectIds[0].internal=${ru_dist_name}
        ...  node_id=${node}
        ...  alarm_resource=${FAULT_1937}
        ...  timeout=120
    END
    Log  \Recover FID:${first_alarm} on ${ru_sn}  console=True
    Wait Until Keyword Succeeds  10min  10sec  radio.Recover Fault  ru_serial_number=${TESTED_RU_SN}  fault_id=${first_alarm}
    IF  "${cfg.RF_INFO['${TESTED_RU_SN}']['scf_variant']}" == "AHFIB"
        FM Await For Fault Cleared
        ...  fault_attr=faultId=${first_alarm}, severity=Major, alarmingObjectIds[0].internal=regex"${ru_dist_name}.*"
        ...  node_id=${node}
        ...  timeout=480
    ELSE
        FM Await For Fault Cleared
        ...  fault_attr=faultId=${first_alarm}, severity=Critical, alarmingObjectIds[0].internal=regex"${ru_dist_name}.*"
        ...  node_id=${node}
        ...  timeout=480
    END
    Wait Until Keyword Succeeds  10min  10sec  radio.Generate Fault  fault_id=1938  ru_serial_number=${ru_sn}  severity=Major
    Log  \nGenerate FID:1938 on ${ru_sn}  console=True
    Log  \nWaiting for FID:1938 to appear on ${ru_sn}  console=True
    FM Await For Fault
    ...  fault_attr=faultId=1927, severity=Major, alarmingObjectIds[0].internal=regex".*${ru_dist_name}.*"
    ...  node_id=${node}
    ...  alarm_resource=${FAULT_1927}
    ...  timeout=480
    FM Await For Fault
    ...  fault_attr=faultId=1938, severity=Major, alarmingObjectIds[0].internal=regex".*${ru_dist_name}.*"
    ...  node_id=${node}
    ...  alarm_resource=${FAULT_1938}
    ...  timeout=480
    FM Await For Fault
    ...  fault_attr=faultId=1938, severity=Critical, alarmingObjectIds[0].internal=regex"${ru_dist_name}.*"
    ...  node_id=${node}
    ...  alarm_resource=${FAULT_1938}
    ...  timeout=600
    Log  \Recover FID:1938 on ${ru_sn}  console=True
    Wait Until Keyword Succeeds  10min  10sec  radio.Recover Fault  ru_serial_number=${TESTED_RU_SN}  fault_id=1938
    FM Await For Fault Cleared
    ...  fault_attr=faultId=1938, severity=Critical, alarmingObjectIds[0].internal=regex".*${ru_dist_name}.*"
    ...  node_id=${node}
    ...  timeout=480
    Log  Reseting RMOD ${ru_sn}  console=True
    admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${node}
    Verify All Cells OnAir    ${node}    timeout=600
    Sleep  10
    ${generate_fault_folder}  Collect Both BBox Files For Radio  destination_folder_name=${TESTED_RU_SN}/step_9_generate_fault  node=${node}
    ${bbox_btsalarm_history}  Get Part Of Bbox List
    ...  file_path=${cfg.test_logs_path}/${generate_fault_folder}/BBOX5
    ...  start_string=Item type: BtsAlarmHistory
    ...  end_string=---
    Log  ${bbox_btsalarm_history}
    Check Alarms  ${node}  ${bbox_btsalarm_history}
    Exit For Loop
  END
  [Teardown]  Run Keywords  radio.Recover Fault  ru_serial_number=${TESTED_RU_SN}  fault_id=${first_alarm}
  ...  AND  radio.Recover Fault  ru_serial_number=${TESTED_RU_SN}  fault_id=1938

Check Alarms
  [Arguments]  ${node}  ${bbox_bts_history}
  ${alarm_history}  Get Alarm History  connection=${node}
  FOR  ${alarm}  IN  @{alarm_history['requestMessage']}
    Log  ${alarm}
    Run Keyword If  '${alarm['faultId']}'=='1927' and '${alarm['faultId']}'=='${first_alarm}' and '${alarm['severity']}'=='Major'  Run Keywords
    ...  Set Test Variable  ${FIDfirst_start_time}  ${alarm['btsObservationTime']}
    ...  AND  Set Test Variable  ${FIDfirst_clear_time}  ${alarm['clearedTime']}
    ...  AND  Set Test Variable  ${FIDfirst_severity}  ${alarm['severity']}
    Run Keyword If  '${alarm['faultId']}'=='1937' and '${alarm['faultId']}'=='${first_alarm}' and '${alarm['severity']}'=='Critical'  Run Keywords
    ...  Set Test Variable  ${FIDfirst_start_time}  ${alarm['btsObservationTime']}
    ...  AND  Set Test Variable  ${FIDfirst_clear_time}  ${alarm['clearedTime']}
    ...  AND  Set Test Variable  ${FIDfirst_severity}  ${alarm['severity']}
    Run Keyword If  '${alarm['faultId']}'=='1938' and '${alarm['severity']}'=='Major'  Run Keywords
    ...  Set Test Variable  ${FID1938_start_time}  ${alarm['btsObservationTime']}
    ...  AND  Set Test Variable  ${FID1938_clear_time}  ${alarm['clearedTime']}
    ...  AND  Set Test Variable  ${FID1938_severity}  ${alarm['severity']}
  END
  ${eva_object_2}=  Set Variable    "%Y%m%d%H%M%S.%f%z").astimezone(__import__("datetime").timezone.utc).timestamp()
  # Konwertuje te czasy z WebEM'a na timestampa
  ${FIDfirst_start_time}=  Evaluate  __import__("datetime").datetime.strptime("${FIDfirst_start_time}", ${eva_object_2}
  ${FIDfirst_clear_time}=  Evaluate  __import__("datetime").datetime.strptime("${FIDfirst_clear_time}", ${eva_object_2}
  ${FID1938_start_time}=  Evaluate  __import__("datetime").datetime.strptime("${FID1938_start_time}", ${eva_object_2}
  ${FID1938_clear_time}=  Evaluate  __import__("datetime").datetime.strptime("${FID1938_clear_time}", ${eva_object_2}

  ${FIDfirst_start_found}  Set Variable  False
  ${FIDfirst_clear_found}  Set Variable  False
  ${1938_start_found}  Set Variable  False
  ${1938_clear_found}  Set Variable  False
  Remove From List  ${bbox_bts_history}  0
  FOR  ${line}  IN  @{bbox_bts_history}
    ${splitted_line}  Split String  ${line}  ,
    Remove From List  ${splitted_line}  -1
    ${eva_object_2}=  Set Variable    "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=__import__("datetime").timezone.utc).timestamp()
    ${bbox_time_converted}=  Evaluate  __import__("datetime").datetime.strptime("${splitted_line[4]}", ${eva_object_2}
    ${fir_1}  Set Variable  '${first_alarm}' in ${splitted_line} and '1' in ${splitted_line} and '${FIDfirst_severity.lower()}' in ${splitted_line}
    ${fir_1_total}  Set Variable  ${fir_1} and not ${FIDfirst_start_found} and abs(${FIDfirst_start_time}-${bbox_time_converted})
    Run Keyword If  ${fir_1_total}<40
    ...  Run Keywords  Set Test Variable  ${FIDfirst_start_found}  True
    ...  AND  Continue For Loop
    ${fir_0}  Set Variable  '${first_alarm}' in ${splitted_line} and '0' in ${splitted_line} and '${FIDfirst_severity.lower()}' in ${splitted_line}
    ${fir_0_total}  Set Variable  ${fir_0} and not ${FIDfirst_clear_found} and abs(${FIDfirst_clear_time}-${bbox_time_converted})
    Run Keyword If  ${fir_0_total}<40
    ...  Run Keywords  Set Test Variable  ${FIDfirst_clear_found}  True
    ...  AND  Continue For Loop
    ${1938_1}  Set Variable  '1938' in ${splitted_line} and '1' in ${splitted_line} and '${FID1938_severity.lower()}' in ${splitted_line} and not
    ${1938_1_total}  Set Variable  ${1938_1} ${1938_start_found} and abs(${FID1938_start_time}-${bbox_time_converted})
    Run Keyword If  ${1938_1_total}<40
    ...  Run Keywords  Set Test Variable  ${1938_start_found}  True
    ...  AND  Continue For Loop
    ${1938_0}  Set Variable  '1938' in ${splitted_line} and '0' in ${splitted_line} and '${FID1938_severity.lower()}' in ${splitted_line} and not
    ${1938_0_total}  Set Variable  ${1938_0} ${1938_clear_found} and abs(${FID1938_clear_time}-${bbox_time_converted})
    Run Keyword If  ${1938_0_total}<40
    ...  Run Keywords  Set Test Variable  ${1938_clear_found}  True
    ...  AND  Continue For Loop
  END
  Run Keyword And Continue On Failure  Should Be True  ${FIDfirst_start_found}
  Run Keyword And Continue On Failure  Should Be True  ${FIDfirst_clear_found}
  Run Keyword And Continue On Failure  Should Be True  ${1938_start_found}
  Run Keyword And Continue On Failure  Should Be True  ${1938_clear_found}


step10: Check Clear Black Box Data
    [Documentation]    CB010655_J_1_support_interface_clear_black_box_data
    ...  Perform frmonShellCLient commands to delete Black box file. After reset RMOD, file should be created.
    [Arguments]  ${node}
    Log To console  === step 10: Clear Black Box Data ===  console=True
    FOR  ${ru_sn}  IN  @{rf_list}
      Continue For Loop If  '${ru_sn}'!='${TESTED_RU_SN}'
      Run  mkdir ${cfg.test_logs_path}/step_10_clear_black_box_data
      Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
      Log To Console  Deleting Black Box file from RMOD  console=True
      radio.Send Command  frmonShellClient localhost 2000  delay=1
      radio.Send Command  / action create BlackBox /bb /module  delay=1
      radio.Send Command  /bb action stop_and_clear  delay=1
      radio.Close SSH Connection
      Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
      radio.Send Command  [ -f /mnt/runtime/BBOX5 ]; echo $?  delay=1
      ${bbox_not_present}  radio.Read Output  delay=1
      Should Contain  ${bbox_not_present}  1
      Log To Console  BBox File deleted  console=True
      Log To Console  Performing RMOD ${ru_sn} reset  console=True
      radio.Close SSH Connection
      admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${node}
      Verify All Cells OnAir    ${node}
      Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
      radio.Send Command  [ -f /mnt/runtime/BBOX5 ]; echo $?  delay=1
      ${bbox_present}  radio.Read Output  delay=1
      Should Contain  ${bbox_present}  0
      Log To Console  BBox File was created after radio reset
      radio.Close SSH Connection
      ${generate_fault_folder}  Collect Both BBox Files For Radio  destination_folder_name=${TESTED_RU_SN}/step_10_clear_black_box_data  node=${node}
      Check Histograms For Single File  dst_folder=${generate_fault_folder}  file_name=BBOX5  number=1
      ${bts_alarm_history}  Get Part Of Bbox List
      ...  file_path=${cfg.test_logs_path}/${generate_fault_folder}/BBOX5
      ...  start_string=Item type: BtsAlarmHistory
      ...  end_string=---
      Length Should Be  ${bts_alarm_history}  1  msg=Check Bbox file if alarm history was cleared
      Exit For Loop
    END
    [Teardown]    Run Keyword    radio.Close SSH Connection

Update SW If Needed
    [Arguments]    ${bts_id}  ${bbox_software_package_path}  ${timeout}=${CONFIGURATION_STARTUP_TIMEOUT}
    Run Keywords
            ...    Log To Console   \nRF Software mismatch - running software update procedure  console=True
            ...    AND   Wait Sw Update Possible
            ...    bts_ready=True
            ...    readiness_timeout=800
            ...    timeout=${timeout}
            ...    connection=${bts_id}
            ...    AND    Update Software    sw_package=${bbox_software_package_path}    timeout=2000    alias=${bts_id}
    ${bts_reset_needed}=    Run Keyword And Return Status    Assert Alarm Active    faultId=4001       timeout=240 sec     alias=${bts_id}
    Run Keyword If    ${bts_reset_needed}    Run Keywords
    ...    Check Is BTS Is Ready For API   ${bts_id}  60 sec
    ...    AND    Execute Power Reset On Node    ${cfg.test_logs_path}  ${bts_id}

Download Proper Software From Source
    [Arguments]    ${bts_id}
    Set Test Variable    ${uuf_sw_folder}    /home/ute/sw_uuf
    ${bts_host_ip}=    Get From Dictionary    ${cfg.NODES['${bts_id}']}     host_ip
    ${active_branch}=    Get From Dictionary    ${cfg.NODES['${bts_id}']}     active_release
    ${tested_node_previous_branch}=    Get From Dictionary    ${BBOX_UPGRADE_BUILD}    ${active_branch}
    ${sw_elements}=  Split String  ${cfg.NODES['${bts_id}']['software_active']}  _
    ${SW_PLATFORM}=  Set Variable If  '${sw_elements[1]}'=='ENB'  ${EMPTY}  _${sw_elements[1]}
    Set Test Variable  ${SW_PLATFORM}
    ${software_package_path}=    Check Main Software Package Availability    ${tested_node_previous_branch}    ${bts_id}    ${uuf_sw_folder}
    Create Directory    ${uuf_sw_folder}
    Set Test Variable   ${TESTED_NODE_PREVIOUS_BRANCH}   ${tested_node_previous_branch}
    Move File     ${software_package_path}     ${uuf_sw_folder}/${tested_node_previous_branch}.zip

Restore Binary File
    [Documentation]  KW that restores default binary value of 'timeBetweenSaveOnNVM' in black_box_logger file on tested RU.
    #Setting default value for teardown for json common_setup.Download Commissioning File
#    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${TESTED_RU_SN}
     ${binary_file_dict}  radio.Get Decoded Binary File
    ...    ru_serial_number=${TESTED_RU_SN}
    ...    filename=black_box_logger
    Set Test Variable    ${BINARY}    ${binary_file_dict}
    Run Keyword If  ${BINARY['timeBetweenSaveOnNVM']}!=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
    ...      radio.Override Values In Binary File
    ...  ru_serial_number=${TESTED_RU_SN}
    ...  filename=black_box_logger
    ...  values_dict=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']}
    ...  reset_ru=True
    Sleep  20
    Verify All Cells OnAir    ${BTS_ID}
    #86400
#    radio.Close SSH Connection


Check SW Version History and Firmware
    [Arguments]  ${folder}
    [Documentation]  CB010655_G_1_enhancement_of_radio_SW_version_and_firmware_version
    ...  KW compares values of firmware and product build on RU and those in BBOX and checks if there are the same.
    Log To Console  Check SW Version and Firmware  console=True
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module   ru_serial_number=${TESTED_RU_SN}
    radio.Send Command   SWmanShellCommand -i
    ${radio_sw_txt}  radio.Read Output  delay=1
    radio.Close SSH Connection
    ${active_Build_Name}  Fetch From Right  ${radio_sw_txt}  activeBuildName:
    ${active_Build_Name}  Fetch From Left  ${radio_sw_txt}  File[0]:
    ${file0}  Fetch From Right  ${radio_sw_txt}  File[0]:
    ${file0}  Fetch From Left  ${file0}  File[1]:
    ${file0_firmware}  Fetch From Right  ${file0}  name:
    ${file0_firmware}  Fetch From Left  ${file0_firmware}  version:
    ${file1}  Fetch From Right  ${radio_sw_txt}  File[1]:
    ${file1_firmware}  Fetch From Right  ${file1}  name:
    ${file1_firmware}  Fetch From Left  ${file1_firmware}  version:
    ${is_active_sw_in_file0}  Run Keyword And Return Status  Should Contain  ${file0}  active
    ${is_active_sw_in_file1}  Run Keyword If  '${is_active_sw_in_file0}'!='True'  Run Keyword And Return Status  Should Contain  ${file1}  active
    ${check_active_sw}  Run Keyword And Return Status
    ...  Run Keyword If  '${is_active_sw_in_file0}'=='True'  Should Contain  ${file0}  ${RMOD_SW_VERSION}
    ...  ELSE  Should Contain  ${file1}  ${RMOD_SW_VERSION}
    ${sw_version_list}  Create List
    ${item_type_start}  Set Variable  ${False}
    @{lines}=  Split To Lines  ${radio_sw_txt}
    ${sw_version_bbox_part}  Get Part Of Bbox List
    ...  file_path=${cfg.test_logs_path}/${folder}/BBOX5
    ...  start_string=Item type: SW_version
    ...  end_string=---
    FOR  ${item}  IN  @{sw_version_bbox_part}
        ${name_line0}  Run Keyword And Return Status  Should Contain  ${item}  [0] name:
        ${name_line1}  Run Keyword And Return Status  Should Contain  ${item}  [1] name:
        Run Keyword If  '${name_line0}'=='True' and '${is_active_sw_in_file0}'=='True'  Run Keywords
        ...  Should Contain  ${item}  ${file0_firmware.strip()}
        ...  AND  Set Test Variable  ${firmware_ok}  True
        ...  AND  Exit For Loop
        Run Keyword If  '${name_line1}'=='True' and '${is_active_sw_in_file1}'=='True'  Run Keywords
        ...  Should Contain  ${item}  ${file1_firmware.strip()}
        ...  AND  Set Test Variable  ${firmware_ok}  True
        ...  AND  Exit For Loop
    END
    Should Contain  ${firmware_ok}  True  msg=Active software not correct in bbox file
    Log To Console  Active software in bbox file is correct - ${RMOD_SW_VERSION}
    [Teardown]    Run Keyword    radio.Close SSH Connection

Get RMOD Build Product Number
    [Documentation]  KW takes RMOD build number.
    FOR    ${ru_sn}    IN  @{rf_list}
        Continue For Loop If  '${ru_sn}'!='${TESTED_RU_SN}'
        ${asirmod_status}  Run Keyword And Return Status  Assert Any
        ...    class_name=ASIRMOD
        ...    parameters=buildVersion!=empty, serialNumber=${ru_sn}
        ...    timeout=60
        ...    alias=${bts_id}
        Run Keyword If  not ${asirmod_status}  Assert Any
        ...    class_name=RMOD
        ...    parameters=buildVersion!=empty, serialNumber=${ru_sn}
        ...    timeout=10
        ...    alias=${bts_id}
        ${class}  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
        ${fr_distname}=     Admin Get Rmod Distname For Rmod Serial Number     ${ru_sn}     alias=${bts_id}
        ${hw_admin_list}=    Get Parameters For      ${class}    ${fr_distname}    alias=${bts_id}
        ${hw_key_build}=    Get From Dictionary    ${hw_admin_list}    buildVersion
        Exit For Loop
    END
    [Return]  ${hw_key_build}

Prepare Keys For Black Box Functions Check
    [Arguments]  ${dst_folder}  ${start_string}
    [Documentation]  KW prepares 2 dictionaries from black box files for part of black box file, decided by ${start_string}. One dictionary
    ...  is only with keys (parts before : value in black box) and second has key/values pairs.
    ${keys_dict}  Create Dictionary
    ${part_list}  Get Part Of Bbox List
    ...  file_path=${cfg.test_logs_path}/${dst_folder}/BBOX5
    ...  start_string=${start_string}
    ...  end_string=---
    FOR  ${line}  IN  @{part_list}
        ${item_start}  Evaluate  'Item type' in '${line}'
        ${key}  Run Keyword If  ${item_start}  Set Variable  ${line}
        ...  ELSE  Fetch From Left  ${line}  :
        ${value}  Fetch From Right  ${line}  :
        Set To Dictionary  ${keys_dict}  ${key}  ${value}
    END
    ${only_keys_from_bbox}  Get Dictionary Keys  ${keys_dict}
    [Return]  ${only_keys_from_bbox}  ${keys_dict}

Check Reset Tree
    [Documentation]    Keyword for check if structure for Reset Counter part in bbox is correct. Checks if each reset contains
    ...  Reset[x] Write:, Reset[x] Reset Reason:,  [x] Reset Cause: and Reset[x] Failed Service:
    [Arguments]  ${reset_part_list}
    Remove From List  ${reset_part_list}  0
    Remove From List  ${reset_part_list}  0
    Log  ${reset_part_list}
    ${elements_in_list}  Get Length  ${reset_part_list}
    Should Be True  ${elements_in_list}  20
    FOR  ${index}  IN RANGE  20
        ${i}  Evaluate  int(${index}/4)
        Run Keyword If  ${index}%4==0  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Write:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%4==1  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Reset Reason:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%4==2  Run Keywords
        ...    Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Reset Cause:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%4==3  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Failed Service:
        ...  AND  Continue For Loop
    END

Collect Both BBox Files For Radio
    [Arguments]  ${destination_folder_name}   ${node}
    Log To console  Collect snapshot from Webem and BBox file from Radio  console=True
    FOR   ${ru_sn}    IN    @{rf_list}
        Continue For Loop If  '${ru_sn}'!='${TESTED_RU_SN}'
        ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${ru_sn}
        Run  mkdir -p ${cfg.test_logs_path}/${destination_folder_name}
        BBox File Download From RU To Vm  ru_serial_number=${ru_sn}  folder_name=${destination_folder_name}
        Collect Bbox from snapshot  ru_sn=${ru_sn}  destination_folder_name=${destination_folder_name}  node=${node}
        ${rc}  ${output}=  Run And Return Rc And Output
          ...  diff -s /${cfg.test_logs_path}/${destination_folder_name}/BBOX5_snap ${cfg.test_logs_path}/${destination_folder_name}/BBOX5
        Should Contain  ${output}  are identical  msg=BBOX Files from RU and Snapshot are not identical!
        Log To Console  BBOX files on RU and from snapshot are identical.  console=True
        Exit For Loop
    END
    Run  rm -r -d ${cfg.test_logs_path}/${temp_folder_name}
    [Return]  ${destination_folder_name}

Collect Bbox from snapshot
    [Arguments]  ${ru_sn}  ${destination_folder_name}   ${node}
    Log To Console    Collecting snapshot    console=True
    admin.Collect Snapshot  target_file_name=${cfg.test_logs_path}/Snapshot_${destination_folder_name}.zip  connection=${node}
    Log To console  Unzipping BBOX file from snapshot from Webem  console=True
    ${rc1}=  Run And Return Rc  unzip ${cfg.test_logs_path}/Snapshot_${destination_folder_name}.zip -d ${cfg.test_logs_path}/${temp_folder_name}
    ${rc2}=  Run And Return Rc  unzip ${cfg.test_logs_path}/${temp_folder_name}/BTS_part1.zip -d ${cfg.test_logs_path}/${temp_folder_name}
    FOR  ${index}  IN RANGE  20
        Continue For Loop If  ${index} < 2
        Run Keyword And Ignore Error
        ...  Run  unzip ${cfg.test_logs_path}/${temp_folder_name}/BTS_part${index}.zip -d ${cfg.test_logs_path}/${temp_folder_name}
    END
    ${object_1}=  Set Variable  find ${cfg.test_logs_path}/${temp_folder_name} -name "*${ru_sn}_RMOD_L*_BBOX5_all.zip" -exec
    ${object_2}=  Set Variable  unzip '{}' -d ${cfg.test_logs_path}/${temp_folder_name} ';' 2>&1
    ${sum_object}=  Set Variable  ${object_1} ${object_2}
    ${rc3}=  Run And Return Rc  ${sum_object}
    ${rc4}=  Run And Return Rc  mv ${cfg.test_logs_path}/${temp_folder_name}/BBOX5 ${cfg.test_logs_path}/${destination_folder_name}/BBOX5_snap
    Should Be True  not ${rc1} and not ${rc2} and not ${rc3} and not ${rc4}  msg=Failed to unzip BBox file

BBox File Download From RU To Vm
    [Arguments]    ${ru_serial_number}  ${folder_name}
    Log To Console  Open Connection To RM  console=True
#    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_serial_number}
    Log To Console    Copying BBOX from RM ${ru_serial_number} to SMOD
    Wait Until Keyword Succeeds   60  5  radio.Send File Via SCP
    ...  ru_serial_number=${ru_serial_number}
    ...  direction=to_smod
    ...  file_path=/mnt/runtime/BBOX5
    ...  destination_directory=/ffs
    Log To Console    Downloading BBOX from SMOD to VM  console=True
    ${node_number}=  Select SMOD For RU  ${ru_serial_number}
#    ${node_number}=    Set Variable    ${CFG.RF_INFO["${ru_serial_number}"]["scf_chain_position"][0][0]}
    Run Keyword If    ${node_number} == 1    Run Keywords
    ...    tafssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
    ...    AND    tafssh.Download File  /ffs/BBOX5  ${cfg.test_logs_path}/${folder_name}/BBOX5  connection=primary
    ...    AND    tafssh.Send Command  rm /ffs/BBOX5  connection=primary
    ...    ELSE   Run Keywords    tafssh.Connect To  ${CFG["TL_Host_Remote"][${node_number}-2]}  ute  alias=vm${node_number}
    ...    AND    tafssh.Connect To  192.168.255.119  toor4nsn  oZPS0POrRieRtu  proxy=vm${node_number}  alias=secondary
    ...    AND    tafssh.Download File  /ffs/BBOX5  ${cfg.test_logs_path}/${folder_name}/BBOX5  connection=secondary
    ...    AND    tafssh.Send Command  rm /ffs/BBOX5  connection=secondary
#    radio.Close SSH Connection

Check P/C And S/N in BBox
  [Documentation]  CB010655_K_1_support_radio_product_code_and_serial_number
  [Arguments]  ${bbox_folder}  ${ru_serial_number}  ${ru_product_code}  ${node}
  ${ru_product_code}  Get RU Product Code  ru_sn=${ru_serial_number}  node=${node}
  ${ru_product_code_check}=  Set Variable  ${False}
  ${tmp_rm_serial_number_check}=  Set Variable  ${False}
  ${rm_serial_number_check}=  Set Variable  ${False}
  Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_serial_number}
  radio.Send Command  cat /mnt/factory/configs/unit/module_product_code.txt
  ${ru_pc_from_ru_files}  radio.Read Until Prompt  prompt=$|#
  radio.Send Command  cat /mnt/factory/configs/unit/module_serial_number.txt
  ${ru_sn_from_ru_files}  radio.Read Until Prompt  prompt=$|#
  radio.Close SSH Connection
  ${bbox_hwpart_list}  Get Part Of Bbox List
  ...  file_path=${cfg.test_logs_path}/${bbox_folder}/BBOX5  start_string=Item type: HW_information  end_string=---
  Should Contain  ${ru_pc_from_ru_files}  ${ru_product_code}
  Log To Console  RU Product Code ${ru_product_code} is visible in /mnt/factory/configs/unit/module_product_code.txt
  Should Contain  ${ru_sn_from_ru_files}  ${ru_serial_number}
  Log To Console  RU Serial Number ${ru_serial_number} is visible in  /mnt/factory/configs/unit/module_serial_number.txt
  Should Contain  ${bbox_hwpart_list}  radio serial number: ${ru_serial_number}  msg=BBOX File does not contain RU serial number ${ru_serial_number}
  Log To Console  \nBBOX file contains RU serial number ${ru_serial_number}  console=True
  Should Contain  ${bbox_hwpart_list}  radio product code: ${ru_product_code}  msg=BBOX FILE does not contain RU product code ${ru_product_code}
  Log To Console  \nBBOX file contains RU product code ${ru_product_code}  console=True

Get RU Product Code
    [Arguments]   ${ru_sn}  ${node}
    ${bts_info}=    Get Bts Info    alias=${node}
    Set Test Variable    ${BTS_INFO}    ${bts_info}
    ${ru_info}=    Get From Dictionary   ${bts_info['radioModules']}    rmod
    FOR   ${ru}    IN    @{ru_info}
        ${ru_product_code}=    Set Variable If  "${ru['serialNumber']}" == "${ru_sn}"    ${ru['productCode']}
        Exit For Loop If   "${ru['serialNumber']}" == "${ru_sn}"
    END
    [Return]    ${ru_product_code}

Check Histograms For Single File
    [Arguments]  ${dst_folder}  ${file_name}  ${number}=2161
    ${bbox_ru_file}=  OperatingSystem.Get File  ${cfg.test_logs_path}/${dst_folder}/${file_name}
    ${histogram_list}  Create List
    ${item_type_start}  Set Variable  ${False}
    @{lines}=  Split To Lines  ${bbox_ru_file}
    FOR  ${line}  IN  @{lines}
      Run Keyword If  '${line}' == 'Item type: Temperature' or '${line}' == 'Item type: Voltage'  Check Single Text Group  ${histogram_list}  ${line}
      ...  ELSE IF  '${item_type_start}' == 'True'  Check Single Text Group  ${histogram_list}  ${line}
      ${contains}=    Run Keyword And Return Status    Should Contain    ${line}    Last days 90:
      Run Keyword If  ${contains}  Check Histogram Records Number  records_line=${line}  number=${number}
      Run Keyword If  ${contains}  Set Test Variable  ${item_type_start}  ${False}
    END

Check Single Text Group
    [Arguments]  ${histogram_list}  ${line}
    Append To List  ${histogram_list}  ${line}
    Set Test Variable  ${item_type_start}  ${True}

Check Histogram Records Number
    [Arguments]  ${records_line}  ${number}=2161
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

Get Reset Counter Value And Write Value From Bbox
    [Documentation]  KW takes values for Reset Counter (number) and for the time of the reset from ${index} position in BBOX file
    [Arguments]  ${reset_counter_values_list}  ${index}
    FOR  ${value}  IN  @{reset_counter_values_list}
        ${contains}=  Evaluate  "Reset Counter:" in "${value}"
        Continue For Loop If  '${contains}'=='False'
        ${reset_counter_value}  Fetch From Right  ${value}  ${SPACE}
        ${reset_counter_value}  Evaluate  int(${reset_counter_value})
        Exit For Loop
    END
    FOR  ${value}  IN  @{reset_counter_values_list}
        ${contains}=  Evaluate  "Reset[${index}] Write" in "${value}"
        Continue For Loop If  '${contains}'=='False'
        ${write_value}  Fetch From Right  ${value}  Write:
        ${write_value}  Evaluate    '${write_value}'.replace(' ','')
        Exit For Loop
    END
    [Return]  ${reset_counter_value}  ${write_value}

Get Part Of Bbox List
    [Documentation]  KW takes path to BBOX file location and returns list of records for Item type: resets
    [Arguments]  ${file_path}  ${start_string}  ${end_string}
    ${bbox_ru_file}=  OperatingSystem.Get File  ${file_path}
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

  ${all_ips}  radio.Get IP For All Radio Modules  print_table=False

  FOR  ${smod}  ${ips}  IN ZIP  ${all_ips.keys()}  ${all_ips.values()}
      ${nested_dict}  Get From Dictionary  ${all_ips}  ${smod}
      ${is_rmod_sn}  Run Keyword And Return Status  Dictionary Should Contain Key  ${nested_dict}  ${rmod_sn}
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
