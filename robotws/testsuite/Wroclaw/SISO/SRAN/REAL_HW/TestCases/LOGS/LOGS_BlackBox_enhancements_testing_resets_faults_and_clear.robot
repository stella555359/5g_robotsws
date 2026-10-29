*** Settings ***
Documentation
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    szymon.przybylak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  RMOD serial number must be provided as a variable when executing the test case.
...
...  Step 1: Black Box Resets Faults and Clear Precondition
...  Prepares RMOD_L data, HW_dict with serial/product number of HW.
...
...  Step 2: Collect BBox From Webem and RU For Resets Faults And Clear
...  Downloads to VM BBOX files from snapshot and RU. Files are later used in other KWs that do
...  not require more actions before checking files.
...
...  Step 3: Check Reset Counters
...  Takes number of resets from already provided bbox files (both snapshot and RU) and compares it to values from BBOX
...  files after RU reset. Check is done if the reset counter value is bigger (+1), if the records moved correctly and if
...  the time of newly done site reset is noted properly.
...
...  Step 4: Check Record Number Of Occurences For Every Trigger
...  Checks if records update correctly. First it ovverrides value of timeBetweenSaveOnNVM in black_box_logger on RU and performs 2 resets.
...  After that checks if black box is updated in records for Periodical trigger occur times and Reset trigger occur times.
...
...  Step 5: Generate Fault And Check BBox
...  Generate Major fault FID:1938 on RMOD and check if black box file is updated with proper records.
...  After that recover the fault and check if black box file is updated with proper clear records.
...
...  Step 6: Check Clear Black Box Data
...  Perform frmonShellCLient commands to delete Black box file. After reset RMOD, file should be created.

Library     DateTime
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.transport.ssh  WITH NAME  tafssh
Resource  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/LOGS/LOGS_Black_Box.resource
Library  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/Python/zip_helpers.py
Resource  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/Robot/SSH.robot
*** Variables ***
${temp_folder_name}  temp
${RMOD_SERIAL_NUMBER}
&{timeBetweenSaveOnNVM}    timeBetweenSaveOnNVM=30
&{timeBetweenSaveOnNVM_blabla}    timeBetweenSaveOnNVM=86400
@{flush_counter_template}  Item type: NvmFlushCounter  Periodical trigger occur times  Temperature gradient trigger occur times
...                         Reset trigger occur times

*** Keywords ***
TC__SiSo_LOGS_RU_Black_Box_enhancements_testing_resets_faults_and_clear
    Set Tags
    ...    OWNER-szymon.przybylak@nokia.com
    ...    AUTHOR-szymon.przybylak@nokia.com
    ...    MAINTAINER-szymon.przybylak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=TC__SiSo_LOGS_RU_Black_Box_enhancements_testing_resets_faults_and_clear
    ...  style=ONGOING

    step 1:Black Box Resets Faults and Clear Precondition
    ${dst_folder}  step 2: Collect BBox From Webem and RU For Resets Faults And Clear
    step 3: Check Reset Counters  dst_folder=${dst_folder}
    step 4: Check Record Number Of Occurences For Every Trigger    dst_folder=${dst_folder}
    step 5: Generate Fault And Check BBox
    step 6: Check Clear Black Box Data
    [Teardown]    Common Test Teardown

Step 1: Black Box Resets Faults and Clear Precondition
    [Documentation]  Black Box preconditions. Prepares RMOD_L data, HW_dict with serial/product number of HW.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Black Box Resets Faults and Clear Precondition
    ...  style=STEP
    ...  frame=${TRUE}
    ${bts_id}=  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SERIAL_NUMBER}']}  scf_btsid_primary
    Set Test Variable    ${BTS_ID}    ${bts_id}
    ${hw_dict}=  Create Dictionary
    Set Test Variable  ${HW_DICT}  ${hw_dict}

    Set Test Variable  ${BBOX_dir}  ${CFG.test_logs_path}/TestFiles
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
    #taking default value for timeBetweenSaveOnNVM
    ${binary_file_dict}=  radio.Get Decoded Binary File
    ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...    filename=black_box_logger
    Set Test Variable    ${BINARY}    ${binary_file_dict}
    ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}=  Create Dictionary
    Set Test Variable  ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
    Set To Dictionary  ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}  timeBetweenSaveOnNVM  ${BINARY['timeBetweenSaveOnNVM']}
    Run Keyword If  '${BINARY['timeBetweenSaveOnNVM']}'=='30'  Fail
    ...  msg=Value of timeBetweenSaveOnNVM is not the default value! Override it manualy to 86400 and retest.
    ${smod_sn}=  Find SMOD By Given BBMOD  ${bbmod_sn}
    Set To Dictionary  ${HW_DICT}  smod_serialNumber  ${smod_sn}
    FOR  ${value}  IN  @{bts_info['systemModules']}
        Continue For Loop If  '${smod_sn}' != '${value['serialNumber']}'
        Set To Dictionary  ${HW_DICT}  smod_productCode   ${value['productCode']}
    END
    Log  ${HW_DICT}
    Logging With Timestamp
    ...  message=Performing Reset of RMOD ${RMOD_SERIAL_NUMBER} before test
    ...  style=ONGOING
    admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}
    Logging With Timestamp
    ...  message=Performing Reset of RMOD ${RMOD_SERIAL_NUMBER} before test
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Black Box Resets Faults and Clear Precondition
    ...  style=DONE

Step 2: Collect BBox From Webem and RU For Resets Faults And Clear
    [Documentation]  Step 1 on test that downloads to VM BBOX files from snapshot and RU.
    ...  Files are later used in other KWs that do not require more actions before checking files.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${cfg}
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

Step 3: Check Reset Counters
  [Arguments]  ${dst_folder}
  [Documentation]  CB010655_I_1_enhancement_of_reset_counter
  ...  KW Takes number of resets from already provided bbox files (both snapshot and RU) and compares it to values from BBOX
  ...  files after RU reset. Check is done if the reset counter value is bigger (+1), if the records moved correctly and if
  ...  the time of newly done site reset is noted properly.
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  Logging With Timestamp
  ...  message=step 2: Check Reset Counters
  ...  style=STEP
  ...  frame=${TRUE}
  ${first_value_list}=  Create List
  ${reset_counter_ru}=  Get Part Of Bbox List
  ...  file_path=${BBOX_dir}/${dst_folder}/BBOX5
  ...  start_string=Item type: resets
  ...  end_string=---
  ${reset_counter_value_before_reset}  ${write_value_before_reset}=  Get Reset Counter Value And Write Value From Bbox
  ...  reset_counter_values_list=${reset_counter_ru}  index=0
  Logging With Timestamp
  ...  message=Performing Reset of RMOD ${RMOD_SERIAL_NUMBER}
  ...  style=ONGOING
  ${reset_start_date}=  Get Current Date  UTC
  ${status}=  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}  detailed_output=True
  Logging With Timestamp
  ...  message=Performing Reset of RMOD ${RMOD_SERIAL_NUMBER}
  ...  style=DONE
  ${reset_end_date}=  Get Current Date  UTC
  Logging With Timestamp
  ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
  ...  style=ONGOING
  Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
  Logging With Timestamp
  ...  message=All cells are OnAir !
  ...  style=DONE
  Log  ${status}

  Sleep  20  #wait to increase time between time after reset for bbox file to be updated
  ${reset_counter_folder}=  Collect Both BBox Files For Radio  destination_folder_name=${RMOD_SERIAL_NUMBER}/step_2_reset_counter  bts_id=${BTS_ID}
  ${after_reset_counter_ru_list}=  Get Part Of Bbox List
  ...  file_path=${BBOX_dir}/${reset_counter_folder}/BBOX5
  ...  start_string=Item type: resets
  ...  end_string=---
  ${reset_counter_value_after_reset}  ${write_value_after_reset}=  Get Reset Counter Value And Write Value From Bbox
  ...  reset_counter_values_list=${after_reset_counter_ru_list}  index=1
  ${alarm_check}=  Evaluate  '${write_value_after_reset}'=='${write_value_before_reset}'
  ${result}=    Evaluate    ${reset_counter_value_before_reset}+1 == ${reset_counter_value_after_reset}
  Should Be True  '${alarm_check}'=='True' and '${result}'=='True'
  ${bbox_reset_time_raw}=  Set Variable  ${after_reset_counter_ru_list[2]}
  ${bbox_reset_time_fetched}=  Fetch From Right  ${bbox_reset_time_raw}  Write:
  ${bbox_reset_time}=  Evaluate  '${bbox_reset_time_fetched}'.replace(' ','')
  ${bbox_reset_time}=  Evaluate  '${bbox_reset_time}'.replace('T',' ')
  ${diff}=  DateTime.Subtract Date From Date  ${bbox_reset_time}  ${reset_start_date}
  Should Be True  ${diff}<15
  Check Reset Tree  reset_part_list=${after_reset_counter_ru_list}
  Logging With Timestamp
  ...  message=step 2: Check Reset Counters
  ...  style=DONE

Step 4: Check Record Number Of Occurences For Every Trigger
  [Arguments]    ${dst_folder}
  [Documentation]    CB010655_D_1_support_to_record_number_of_occurrences_for_every_trigger
  ...    Checks if records update correctly. First it ovverrides value of timeBetweenSaveOnNVM in black_box_logger on RU and performs 2 resets.
  ...    After that checks if black box is updated in records for Periodical trigger occur times and Reset trigger occur times.
  ...    ${dst_folder} = folder which have already downloaded bbox files (from step 1)
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  Logging With Timestamp
  ...  message=step3: Check Record Number Of Occurences For Every Trigger
  ...  style=STEP
  ...  frame=${TRUE}

  ${should_execute_recovery}=    Set Variable    True
  ${nvm_flushcounter_only_keys}  ${nvm_flushcounter_dict}=  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${dst_folder}  start_string=Item type: NvmFlushCounter
  FOR  ${item}  IN  @{flush_counter_template}
      Run Keyword and Continue on Failure  Should Contain  ${nvm_flushcounter_only_keys}  ${item}
  END
  Logging With Timestamp
  ...  message=Getting and Overriding timeBetweenSaveOnNVM to ${timeBetweenSaveOnNVM['timeBetweenSaveOnNVM']}
  ...  style=ONGOING
  radio.Override Values In Binary File
  ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
  ...  filename=black_box_logger
  ...  values_dict=${timeBetweenSaveOnNVM}
  ...  reset_ru=False
  #86400
  Logging With Timestamp
  ...  message=Getting and Overriding timeBetweenSaveOnNVM to ${timeBetweenSaveOnNVM['timeBetweenSaveOnNVM']}
  ...  style=DONE
  Logging With Timestamp
  ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
  ...  style=ONGOING
  Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
  Logging With Timestamp
  ...  message=All cells are OnAir !
  ...  style=DONE

  Logging With Timestamp
  ...  message=Performing first RMOD ${RMOD_SERIAL_NUMBER} reset
  ...  style=ONGOING
  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}
  Logging With Timestamp
  ...  message=Performing first RMOD ${RMOD_SERIAL_NUMBER} reset
  ...  style=DONE
  Logging With Timestamp
  ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
  ...  style=ONGOING
  Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
  Logging With Timestamp
  ...  message=All cells are OnAir !
  ...  style=DONE

  Logging With Timestamp
  ...  message=Performing second RMOD ${RMOD_SERIAL_NUMBER} reset
  ...  style=ONGOING
  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}
  Logging With Timestamp
  ...  message=Performing second RMOD ${RMOD_SERIAL_NUMBER} reset
  ...  style=DONE
  Logging With Timestamp
  ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
  ...  style=ONGOING
  Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
  Logging With Timestamp
  ...  message=All cells are OnAir !
  ...  style=DONE

  ${stepz_folder_name}=  Collect Both BBox Files For Radio
  ...  destination_folder_name=${RMOD_SERIAL_NUMBER}/step_8_check_records_of_occurences
  ...  bts_id=${BTS_ID}
  ${nvm_flushcounter_after_reset_only_keys}  ${nvm_flushcounter_after_reset_dict}=  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${stepz_folder_name}  start_string=Item type: NvmFlushCounter
  FOR  ${item}  IN  @{flush_counter_template}
      Run Keyword and Continue on Failure  Should Contain  ${nvm_flushcounter_after_reset_only_keys}  ${item}
  END
  Logging With Timestamp
  ...  message=Restoring defaut value ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']} to timeBetweenSaveOnNVM
  ...  style=ONGOING
  radio.Override Values In Binary File
  ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
  ...  filename=black_box_logger
  ...  values_dict=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
  ...  reset_ru=False
  Logging With Timestamp
  ...  message=Performing second RMOD ${RMOD_SERIAL_NUMBER} reset
  ...  style=ONGOING
  admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}
  Logging With Timestamp
  ...  message=Performing second RMOD ${RMOD_SERIAL_NUMBER} reset
  ...  style=DONE
  ${should_execute_recovery}=    Set Variable    False
  Logging With Timestamp
  ...  message=Restoring defaut value ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']} to timeBetweenSaveOnNVM
  ...  style=DONE
  Logging With Timestamp
  ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
  ...  style=ONGOING
  Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
  Logging With Timestamp
  ...  message=All cells are OnAir !
  ...  style=DONE

  ${periodical_increment}=  Evaluate
  ...  int(${nvm_flushcounter_dict['Periodical trigger occur times']}) < int(${nvm_flushcounter_after_reset_dict['Periodical trigger occur times']})
  ${reset_increment}=  Evaluate
  ...  int(${nvm_flushcounter_dict['Reset trigger occur times']})+3 == int(${nvm_flushcounter_after_reset_dict['Reset trigger occur times']})
  Should Be True  '${periodical_increment}' == 'True' and '${reset_increment}' == 'True'
  Logging With Timestamp
  ...  message=step3: Check Record Number Of Occurences For Every Trigger
  ...  style=DONE
  [Teardown]  Run Keyword If  ${should_execute_recovery}  Wait Until Keyword Succeeds  3min  10sec    Restore Binary File

Step 5: Generate Fault And Check BBox
  [Documentation]    CB010655_F_1_support_interface_generate_fault_and_check_black_box_data
  ...  Generate Major fault FID:1938 on RMOD and check if black box file is updated with proper records.
  ...  After that recover the fault and check if black box file is updated with proper clear records.
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  Logging With Timestamp
  ...  message=step4: Generate Fault And Check BBox
  ...  style=STEP
  ...  frame=${TRUE}
    ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${RMOD_SERIAL_NUMBER}
    Wait Until Keyword Succeeds  10min  10sec  radio.Generate Fault  fault_id=1938  ru_serial_number=${RMOD_SERIAL_NUMBER}  severity=Major
    Logging With Timestamp
    ...  message=Generate FID:1938 on ${RMOD_SERIAL_NUMBER}
    ...  style=INFO
    Logging With Timestamp
    ...  message=Waiting for FID:1938 to appear on ${RMOD_SERIAL_NUMBER}
    ...  style=ONGOING
    FM Await For Fault
    ...  fault_attr=faultId=1927, severity=Major, alarmingObjectIds[0].internal=regex".*${ru_dist_name}.*"
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_1927}
    ...  timeout=480
    FM Await For Fault
    ...  fault_attr=faultId=1938, severity=Major, alarmingObjectIds[0].internal=regex".*${ru_dist_name}.*"
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_1938}
    ...  timeout=480
    FM Await For Fault
    ...  fault_attr=faultId=1938, severity=Critical, alarmingObjectIds[0].internal=regex"${ru_dist_name}.*"
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_1938}
    ...  timeout=600
    Logging With Timestamp
    ...  message=Waiting for FID:1938 to appear on ${RMOD_SERIAL_NUMBER}
    ...  style=DONE
    Logging With Timestamp
    ...  message=Recover FID:1938 on ${RMOD_SERIAL_NUMBER}
    ...  style=ONGOING
    Wait Until Keyword Succeeds  10min  10sec  radio.Recover Fault  ru_serial_number=${RMOD_SERIAL_NUMBER}  fault_id=1938
    FM Await For Fault Cleared
    ...  fault_attr=faultId=1938, severity=Critical, alarmingObjectIds[0].internal=regex".*${ru_dist_name}.*"
    ...  node_id=${BTS_ID}
    ...  timeout=480
    Logging With Timestamp
    ...  message=PerformingRMOD ${RMOD_SERIAL_NUMBER} reset
    ...  style=ONGOING
    admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}
    Logging With Timestamp
    ...  message=Performing RMOD ${RMOD_SERIAL_NUMBER} reset
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE
    Sleep  10
    ${generate_fault_folder}=  Collect Both BBox Files For Radio
    ...  destination_folder_name=${RMOD_SERIAL_NUMBER}/step_4_generate_fault
    ...  bts_id=${BTS_ID}
    ${bbox_btsalarm_history}=  Get Part Of Bbox List
    ...  file_path=${BBOX_dir}/${generate_fault_folder}/BBOX5
    ...  start_string=Item type: BtsAlarmHistory
    ...  end_string=---
    Log  ${bbox_btsalarm_history}
    Check Alarms  ${bbox_btsalarm_history}
    Logging With Timestamp
    ...  message=step4: Generate Fault And Check BBox
    ...  style=DONE

    [Teardown]    radio.Recover Fault  ru_serial_number=${RMOD_SERIAL_NUMBER}  fault_id=1938

Check Alarms
  [Arguments]  ${bbox_bts_history}
  [Documentation]    KW that checks if FID1938 alarm and clear entries are present in black box alarm history with proper severity and time.
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  ${alarm_history}=  Get Alarm History  connection=${BTS_ID}
  FOR  ${alarm}  IN  @{alarm_history['requestMessage']}
    Log  ${alarm}
    Run Keyword If  '${alarm['faultId']}'=='1938' and '${alarm['severity']}'=='Critical'  Run Keywords
    ...  Set Test Variable  ${FID1938_start_time}  ${alarm['btsObservationTime']}
    ...  AND  Set Test Variable  ${FID1938_clear_time}  ${alarm['clearedTime']}
    ...  AND  Set Test Variable  ${FID1938_severity}  ${alarm['severity']}
  END
  ${eva_object_2}=  Set Variable    "%Y%m%d%H%M%S.%f%z").astimezone(__import__("datetime").timezone.utc).timestamp()
  # Konwertuje te czasy z WebEM'a na timestampa
  ${FID1938_start_time}=  Evaluate  __import__("datetime").datetime.strptime("${FID1938_start_time}", ${eva_object_2}
  ${FID1938_clear_time}=  Evaluate  __import__("datetime").datetime.strptime("${FID1938_clear_time}", ${eva_object_2}

  ${1938_start_found}=  Set Variable  False
  ${1938_clear_found}=  Set Variable  False
  Remove From List  ${bbox_bts_history}  0
  FOR  ${line}  IN  @{bbox_bts_history}
    ${splitted_line}=  Split String  ${line}  ,
    IF  '1938' not in ${splitted_line}
        Continue For Loop
    END
    Remove From List  ${splitted_line}  -1
    ${date_string}=  Set Variable  ${splitted_line[4]}
    ${processed_date_string}=  Evaluate
    ...  "${date_string}"[1:-1] if "${date_string}".startswith("<") and "${date_string}".endswith(">") else "${date_string}"
    Log To Console    Processed string: ${processed_date_string}
    ${eva_object_2}=  Set Variable  "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=__import__("datetime").timezone.utc).timestamp()
    ${eva_object_3}=  Set Variable  "%Y-%m-%dT%H:%M:%S.%fZ" if "." in "${processed_date_string}" else "%
    ${eva_object_4}=  Set Variable  Y-%m-%dT%H:%M:%SZ").replace(tzinfo=__import__("datetime").timezone.utc).timestamp()
    ${bbox_time_converted}=  Evaluate  __import__("datetime").datetime.strptime("${processed_date_string}", ${eva_object_3}${eva_object_4}
#    ${bbox_time_converted}  Evaluate
#__import__("datetime").datetime.strptime("${processed_date_string}", "%Y-%m-%dT%H:%M:%S.%fZ" if "." in "${processed_date_string}" else
 #"%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=__import__("datetime").timezone.utc).timestamp()
    IF  not ${1938_start_found} or not ${1938_clear_found}
        Logging With Timestamp
        ...  message=Checking FID1938 in line: ${splitted_line}
        ...  style=INFO
      IF  '1' in ${splitted_line}
        Logging With Timestamp
        ...  message=Checking start entry for FID1938
        ...  style=INFO
        IF  '${FID1938_severity.lower()}' in ${splitted_line}
            Logging With Timestamp
            ...  message=Severity matches for FID1938
            ...  style=INFO
            Log  abs(${FID1938_start_time}-${bbox_time_converted})<80
            IF  abs(${FID1938_start_time}-${bbox_time_converted})<80
                Logging With Timestamp
                ...  message=Time matches for FID1938 start entry
                ...  style=INFO
                Set Test Variable  ${1938_start_found}  True
                Continue For Loop
            ELSE
                Logging With Timestamp
                ...  message=Time does not match for FID1938 start entry
                ...  style=INFO
            END
        ELSE
            Logging With Timestamp
            ...  message=Severity does not match for FID1938
            ...  style=INFO
        END
      ELSE IF  '0' in ${splitted_line}
        Logging With Timestamp
        ...  message=Checking clear entry for FID1938
        ...  style=INFO
        IF  '${FID1938_severity.lower()}' in ${splitted_line}
            Logging With Timestamp
            ...  message=Severity matches for FID1938
            ...  style=INFO
            Log   abs(${FID1938_clear_time}-${bbox_time_converted})<80
            IF  abs(${FID1938_clear_time}-${bbox_time_converted})<80
                Logging With Timestamp
                ...  message=Time matches for FID1938 clear entry
                ...  style=INFO
                Set Test Variable  ${1938_clear_found}  True
                IF  ${1938_start_found} and ${1938_clear_found}
                    Logging With Timestamp
                    ...  message=Both start and clear entries for FID1938 found in BBOX
                    ...  style=INFO
                    Exit For Loop
                ELSE
                    Continue For Loop
                END
            ELSE
                Logging With Timestamp
                ...  message=Time does not match for FID1938 clear entry
                ...  style=INFO
            END
        ELSE
            Logging With Timestamp
            ...  message=Severity does not match for FID1938
            ...  style=INFO
        END
      END
    END
  END
  Run Keyword And Continue On Failure  Should Be True  ${1938_start_found}
  Run Keyword And Continue On Failure  Should Be True  ${1938_clear_found}


Step 6: Check Clear Black Box Data
    [Arguments]  ${step_folder}=step_5_clear_black_box_data
    [Documentation]    CB010655_J_1_support_interface_clear_black_box_data
    ...  Perform frmonShellCLient commands to delete Black box file. After reset RMOD, file should be created.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | step_folder            | yes  |  Name of the folder created in this step                                   |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=step5: Clear Black Box Data
    ...  style=STEP
    ...  frame=${TRUE}
    Run  mkdir ${BBOX_dir}/${RMOD_SERIAL_NUMBER}/${step_folder}
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${RMOD_SERIAL_NUMBER}
    Logging With Timestamp
    ...  message=Deleting Black Box file from RMOD ${RMOD_SERIAL_NUMBER}
    ...  style=ONGOING
    radio.Send Command  frmonShellClient localhost 2000  delay=1
    radio.Send Command  / action create BlackBox /bb /module  delay=1
    radio.Send Command  /bb action stop_and_clear  delay=1
    radio.Close SSH Connection
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${RMOD_SERIAL_NUMBER}
    radio.Send Command  [ -f /mnt/runtime/BBOX5 ]; echo $?  delay=1
    ${bbox_not_present}=  radio.Read Output  delay=1
    Should Contain  ${bbox_not_present}  1
    Logging With Timestamp
    ...  message=BBox file deleted from RMOD ${RMOD_SERIAL_NUMBER}
    ...  style=DONE
    Logging With Timestamp
    ...  message=Performing Reset of RMOD ${RMOD_SERIAL_NUMBER} to create new BBOX file
    ...  style=ONGOING
    admin.Reset Unit  dist_name=${RMOD_DISTNAME_ID}  timeout=540  alias=${BTS_ID}
    Logging With Timestamp
    ...  message=Performing Reset of RMOD ${RMOD_SERIAL_NUMBER} to create new BBOX file
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${RMOD_SERIAL_NUMBER}
    radio.Send Command  [ -f /mnt/runtime/BBOX5 ]; echo $?  delay=1
    ${bbox_present}=  radio.Read Output  delay=1
    Should Contain  ${bbox_present}  0
    Logging With Timestamp
    ...  message=BBox File was created after radio reset
    ...  style=DONE
    radio.Close SSH Connection
    ${clear_bbox_folder}=  Collect Both BBox Files For Radio  destination_folder_name=${RMOD_SERIAL_NUMBER}/${step_folder}  bts_id=${BTS_ID}
    Check Histograms For Single File  dst_folder=${clear_bbox_folder}  file_name=BBOX5  number=2
    ${bts_alarm_history}=  Get Part Of Bbox List
    ...  file_path=${BBOX_dir}/${clear_bbox_folder}/BBOX5
    ...  start_string=Item type: BtsAlarmHistory
    ...  end_string=---
    Length Should Be  ${bts_alarm_history}  1  msg=Check Bbox file if alarm history was cleared
    [Teardown]    Run Keyword    radio.Close SSH Connection

Restore Binary File
    [Documentation]  KW that restores default binary value of 'timeBetweenSaveOnNVM' in black_box_logger file on tested RU.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${binary_file_dict}=  radio.Get Decoded Binary File
    ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...    filename=black_box_logger
    Set Test Variable    ${BINARY}    ${binary_file_dict}
    Run Keyword If  ${BINARY['timeBetweenSaveOnNVM']}!=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
    ...  radio.Override Values In Binary File
    ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...  filename=black_box_logger
    ...  values_dict=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']}
    ...  reset_ru=True
    Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE
    #86400

Get RMOD Build Product Number
    [Documentation]  KW takes RMOD build number.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

        ${asirmod_status}=  Run Keyword And Return Status  Assert Any
        ...    class_name=ASIRMOD
        ...    parameters=buildVersion!=empty, serialNumber=${RMOD_SERIAL_NUMBER}
        ...    timeout=60
        ...    alias=${BTS_ID}
        Run Keyword If  not ${asirmod_status}  Assert Any
        ...    class_name=RMOD
        ...    parameters=buildVersion!=empty, serialNumber=${RMOD_SERIAL_NUMBER}
        ...    timeout=10
        ...    alias=${BTS_ID}
        ${class}=  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
        ${fr_distname}=     Admin Get Rmod Distname For Rmod Serial Number     ${RMOD_SERIAL_NUMBER}     alias=${BTS_ID}
        ${hw_admin_list}=    Get Parameters For      ${class}    ${fr_distname}    alias=${BTS_ID}
        ${hw_key_build}=    Get From Dictionary    ${hw_admin_list}    buildVersion

    [Return]  ${hw_key_build}

Check Reset Tree
    [Arguments]  ${reset_part_list}
    [Documentation]    Keyword for check if structure for Reset Counter part in bbox is correct. Checks if each reset contains
    ...  Reset[x] Write:, Reset[x] Reset Reason:,  [x] Reset Cause: and Reset[x] Failed Service:
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | reset_part_list        | yes  | List containing part of BBOX file related to Reset Counter records         |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Remove From List  ${reset_part_list}  0
    Remove From List  ${reset_part_list}  0
    Log  ${reset_part_list}
    ${elements_in_list}=  Get Length  ${reset_part_list}
    FOR  ${index}  IN RANGE  ${elements_in_list}
        ${i}=  Evaluate  int(${index}/5)
        Run Keyword If  ${index}%5==0  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Write:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==1  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] ISTI:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==2  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Reset Reason:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==3  Run Keywords
        ...    Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Reset Cause:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==4  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Failed Service:
        ...  AND  Continue For Loop
    END

Get Reset Counter Value And Write Value From Bbox
    [Arguments]  ${reset_counter_values_list}  ${index}
    [Documentation]  KW takes values for Reset Counter (number) and for the time of the reset from ${index} position in BBOX file
    ...  Arguments:
    ...  +===========================+======+============================================================================+
    ...  | Argument                  | Man. | Description                                                                |
    ...  +========================+======+===============================================================================+
    ...  | reset_counter_values_list | yes  | List containing part of BBOX file related to Reset Counter records         |
    ...  +---------------------------+------+----------------------------------------------------------------------------+
    ...  | index                     | yes  | Index of reset to take values from (0 - last reset, 1 - before last reset) |
    ...  +===========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    FOR  ${value}  IN  @{reset_counter_values_list}
        ${contains}=  Evaluate  "Reset Counter:" in "${value}"
        Continue For Loop If  '${contains}'=='False'
        ${reset_counter_value}=  Fetch From Right  ${value}  ${SPACE}
        ${reset_counter_value}=  Evaluate  int(${reset_counter_value})
        Exit For Loop
    END
    FOR  ${value}  IN  @{reset_counter_values_list}
        ${contains}=  Evaluate  "Reset[${index}] Write" in "${value}"
        Continue For Loop If  '${contains}'=='False'
        ${write_value}=  Fetch From Right  ${value}  Write:
        ${write_value}=  Evaluate    '${write_value}'.replace(' ','')
        Exit For Loop
    END
    [Return]  ${reset_counter_value}  ${write_value}
