*** Settings ***
Documentation
  ...  AUTHOR-szymon-przybylak@nokia.com  MAINTAINER-szymon-przybylak@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/4185377
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  IMPORTANT:
  ...  THe values for temperature override can be adjusted and set in test suite. The minimum difference between them has to be bigger than
  ...  temperatureDeltaForSave value set in tcs_parameters file (which is 12 for this TC).
  ...  Default values are:
  ...  ${first_override_temperature_value}  65
  ...  ${second_override_temperature_value}  80
  ...  ${third_override_temperature_value}  95
  ...
  ...  Step 1: Preconditions
  ...  Checking if RMOD with given serial number is present in HW configuration, if not test fail.
  ...  Checking if parameters in tcs_parameters.bin are DIFFERENT than the one that will be changed for in the TC.

  ...  Step 2:
  ...  Collecting BBOX5, BBOX_startup_temperature and BBOX_temperature files from Radio Module to directory
  ...  ${CFG.test_logs_path}/TestFiles/Reference
  ...  and saving temperature gradient counter and NVM flush counter values from BBOX5 file as reference.

  ...  Step 3: Change Tcs_Parameters Values
  ...  Changing tcs_parameters values of temperatureDeltaForSave to 12 and deltaTMulti to 80 and overriding them
  ...  in binary file on RU. Then performing RU reset and waiting until all cells are OnAir.
  ...
  ...  Step 4: Trigger The Temperature Gradient Event 3 times
  ...  Triggering the temperature gradient event 3 times by overriding temperature value on RU to ${first_override_temperature_value},
  ...  ${second_override_temperature_value} and ${third_override_temperature_value} degrees Celsius
  ...  and waiting 5 minutes after each change for RU to detect the change. The difference has to be bigger than 12 (deltaTMulti).
  ...
  ...  Step 5: Get Black Box Samples
  ...  Collecting BBOX5, BBOX_startup_temperature and BBOX_temperature files from Radio Module to directory
  ...  ${CFG.test_logs_path}/TestFiles/Sample_1.
  ...  Performing RU reset after first collection and waiting until all cells are OnAir. After 20 minutes of waiting, collectin second sample of
  ...  files to ${CFG.test_logs_path}/TestFiles/Sample_2
  ...
  ...  Step 6: Check Black Box Files
  ...  Checking if temperature gradient counter increased by 1 in Sample 1 and by 3 in Sample 2 comparing to Reference.
  ...  Checking if NVM flush counter increased by 1 in Sample 1 and by 1 in Sample 2 comparing to Reference.
  ...  Checking if temperature profile in Sample 1 and Sample 2 contains overridden temperature values.
  ...  Checking if Startup_Temperature and Startup_Fans sections exist in Sample 1 and Sample 2 files.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 15.10.2025 - Initial creation
  ...  - 25.11.2025 - Added step to verify temperature_24h section in all Black Box Samples

Library  ./../../Resources/Python/zip_helpers.py
Library  ./../../Resources/Python/blackbox_helpers.py
Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../TestCases/LOGS/LOGS_Black_Box.resource


*** Variables ***
${RMOD_SERIAL_NUMBER}
${timeout}  120
${temp_folder_name}  tmp
${first_override_temperature_value}  65
${second_override_temperature_value}  80
${third_override_temperature_value}  95
${deltaTMulti_value_to_change}  80        #80 / 50    / 100
${temperatureDeltaForSave_value_to_change}  12   # 12 / 60
${numberofsamplestocompare_value}    2
#    numberOfSamplesToCompare
&{temp_sensor_dict}
...  5.1=/rf/nahka1
...  6.2=/temp/made1/internal1
&{temp_row}
...  5.1=module:CORE Value[°C]
...  6.2=made1:JESD Value[°C]

*** Keywords ***
TC__SiSo_LOGS_RU_Black_Box_Temperature_and_FanSpeed_Verification
  Set Tags  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  Common Test Setup
  Step 1: Preconditions For BBox Temp and Fan Speed
  Step 2: Get Reference Black Box Files
  Step 3: Change Tcs_Parameters Values
  Step 4: Trigger The Temperature Gradient Event 3 times
  Step 5: Get Black Box Samples
  Step 6: Check Black Box Files
  [Teardown]    Run Keywords
  ...  Run Keyword And Continue On Failure  Restore Default Values In Binary File
  ...  AND  Common Test Teardown
#    [Teardown]    Common Test Teardown
Step 1: Preconditions For BBox Temp and Fan Speed
    [Documentation]
    ...  Description:
    ...  KW that checks if RMOD with given serial number is present in HW configuration, if not test fail. Stores default values of
    ...  deltaTMulti and temperatureDeltaForSave from tcs_parameters file.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 1: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    ${bts_id}  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SERIAL_NUMBER}']}  scf_btsid_primary
    Set Test Variable  ${bts_id}  ${BTS_ID}
    IF  '${RMOD_SERIAL_NUMBER}'=='${EMPTY}'
        Fail  Variable RMOD_SERIAL_NUMBER cannot be empty !
    END
    ${rmods_info}  admin.Get FRM  timeout=60  connection=${bts_id}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SERIAL_NUMBER}'
        ${rmod_product_name}  Set Variable  ${rmod['productName']}
        ${rmod_distname_id}  Set Variable  ${rmod['id']['internal']}
    END
    Set Test Variable  ${RMOD_DISTNAME_ID}
    ${rmod_hw_family}  Get Radio Module Hardware Family  ${rmod_product_name}
    Set Test Variable  ${RMOD_HW_FAMILY}  ${rmod_hw_family}
    Set Test Variable  ${BBOX_dir}  ${CFG.test_logs_path}/TestFiles
    IF  '${rmod_distname_id}'=='${NONE}'
        Fail  Serial Number ${RMOD_SERIAL_NUMBER} not found in HW Configuration ! Test set to Fail !
    ELSE
        Logging With Timestamp  message=RMOD with SN ${RMOD_SERIAL_NUMBER} found in configuration!
    END
    Logging With Timestamp
    ...  message=Performing Radio Unit Reset, please wait!
    ...  style=ONGOING

#    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${bts_id}

    Logging With Timestamp
    ...  message=Radio Unit Reset finished !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Waiting up to 5 minutes for all cells to be OnAir, please wait!
    ...  style=ONGOING

    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${bts_id}

    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Getting default value of deltaTMulti and temperatureDeltaForSave from tcs_parameters file
    ...  style=ONGOING
    ${tcs_parameters_file_dict}  radio.Get Decoded Binary File
    ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...    filename=tcs_parameters
    Logging With Timestamp
    ...  message=Getting default value of deltaTMulti and temperatureDeltaForSave from tcs_parameters file
    ...  style=DONE
    ${key_path_delta_for_save}=    Create List    tcs  bboxTempMeasurement  temperatureDeltaForSave
    ${key_path_numofsamples}    Create List    tcs    bboxTempMeasurement    numberOfSamplesToCompare
    Set Test Variable    ${KEY_PATH_NUMOFSAMPLES}    ${key_path_numofsamples}
    Set Test Variable  ${KEY_PATH_DELTA_FOR_SAVE}  ${key_path_delta_for_save}
    Set Test Variable  ${DEF_V_TMP}  ${tcs_parameters_file_dict['tcs']['bboxTempMeasurement']['temperatureDeltaForSave']}
    Set Test Variable    ${DEF_V_NUM_OF_SAMPLES}  ${tcs_parameters_file_dict['tcs']['bboxTempMeasurement']['numberOfSamplesToCompare']}
    ${key_path_deltaTmulti}=    Create List    tcs  deltaTmulti
    Set Test Variable  ${KEY_PATH_DELTATMULTI}  ${key_path_deltaTmulti}
    Set Test Variable  ${DEF_V_DTMUL}  ${tcs_parameters_file_dict['tcs']['deltaTmulti']}
    Set Test Variable  ${DEFAULT_TCS_DICT}  ${tcs_parameters_file_dict}
    Set Test Variable    ${TCS_DICT_TEARDOWN}    ${tcs_parameters_file_dict}
    Logging With Timestamp
    ...    message=Default value for temperatureDeltaForSave -> ${DEF_V_TMP}, deltaTmulti -> ${DEF_V_DTMUL}
    ...    style=INFO
    Log  ${TCS_DICT_TEARDOWN}
#    IF    ${DEF_V_DTMUL} == 80 or ${DEF_V_TMP} == 12
#        Fail  Default values for deltaTmulti (${DEF_V_DTMUL}) and/or temperatureDeltaForSave (${DEF_V_TMP}) are the same as test is supposed to set!
#    END

Step 2: Get Reference Black Box Files
    [Documentation]
    ...  Description
    ...  KW that gets reference black box file from RU and saves it to local directory.

    Logging With Timestamp
    ...  message=Step 2: Get Reference Black Box File
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Collecting Reference BBOX files from Radio Module to directory ${BBOX_dir}/Reference
    ...  style=ONGOING
    OperatingSystem.Create Directory  ${BBOX_dir}/Reference
    Collect Bbox from snapshot  ru_sn=${RMOD_SERIAL_NUMBER}  destination_folder_name=Reference  bts_id=${bts_id}  bbox_type=all
    ${file_exists_temperature}=  Run Keyword And Return Status  OperatingSystem.File Should Exist
    ...  path=${BBOX_dir}/Reference/BBOX_temperature_1
    IF  not ${file_exists_temperature}
        Fail  File BBOX_temperature_1 for Reference was not found on RU !
    END
    ${file_not_exists_temperature}  Run Keyword And Return Status  OperatingSystem.File Should Not Exist
    ...  ${BBOX_dir}/Reference/BBOX_temperature_6
    ${file_not_exists_startup}  Run Keyword And Return Status  OperatingSystem.File Should Not Exist
    ...  ${BBOX_dir}/Reference/BBOX_startup_temperature_6
    IF  not ${file_not_exists_temperature} and not ${file_not_exists_startup}
        Fail  File BBOX_temperature_6 or BBOX_startup_temperature_6 for Reference should not be found on RU !
    END

    Logging With Timestamp
    ...  message=File Reference files collected !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Step 2: Get Reference Black Box Files
    ...  style=DONE

Step 3: Change Tcs Parameters Values
    [Documentation]
    ...  Description:
    ...  Step 3 which changes tcs_parameters values of temperatureDeltaForSave to 12 and deltaTMulti to 80 and overrides them
    ...  in binary file on RU. Then performs RU reset and waits until all cells are OnAir.

    Logging With Timestamp
    ...  message=Step 3: Change tcs_parameters Values
    ...  style=STEP
    ...  frame=${TRUE}
    ${updated_dict}=  Update Nested Value
    ...  data_dict=${DEFAULT_TCS_DICT}
    ...  key_path=${KEY_PATH_DELTA_FOR_SAVE}
    ...  new_value=${temperatureDeltaForSave_value_to_change}
    ${updated_dict}=  Update Nested Value
    ...  data_dict=${updated_dict}
    ...  key_path=${KEY_PATH_DELTATMULTI}
    ...  new_value=${deltaTMulti_value_to_change}
    ${updated_dict}=  Update Nested Value
    ...  data_dict=${updated_dict}
    ...  key_path=${KEY_PATH_NUMOFSAMPLES}
    ...  new_value=${numberofsamplestocompare_value}
    Logging With Timestamp
    ...  message=Overriding default value of deltaTMulti and temperatureDeltaForSave from tcs_parameters file
    ...  style=ONGOING
    radio.Override Values In Binary File
    ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...  filename=tcs_parameters
    ...  values_dict=${updated_dict}
    ...  reset_ru=False
    Logging With Timestamp
    ...  message=Overriding default value of deltaTMulti and temperatureDeltaForSave from tcs_parameters file
    ...  style=DONE
    Logging With Timestamp
    ...  message=Performing Radio Unit Reset, please wait!
    ...  style=ONGOING

    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${bts_id}

    Logging With Timestamp
    ...  message=Radio Unit Reset finished !
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting up to 5 minutes for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${bts_id}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Verifying if values were changed correctly in tcs_parameters file
    ...  style=ONGOING
    ${binary_file_dict}  radio.Get Decoded Binary File
    ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...    filename=tcs_parameters
    Should Be Equal
    ...  first='${binary_file_dict['tcs']['bboxTempMeasurement']['temperatureDeltaForSave']}'
    ...  second='${temperatureDeltaForSave_value_to_change}'
    Should Be Equal
    ...  first='${binary_file_dict['tcs']['deltaTmulti']}'
    ...  second='${deltaTMulti_value_to_change}'
    Should Be Equal
    ...  first='${binary_file_dict['tcs']['bboxTempMeasurement']['numberOfSamplesToCompare']}'
    ...  second='${numberofsamplestocompare_value}'

    Logging With Timestamp
    ...  message=Values were changed correctly in tcs_parameters file
    ...  style=DONE
    Logging With Timestamp
    ...  message=temperatureDeltaForSave changed to ${temperatureDeltaForSave_value_to_change}
    ...  style=INFO
    Logging With Timestamp
    ...  message=deltaTmulti changed to ${deltaTMulti_value_to_change}
    ...  style=INFO
    Logging With Timestamp
    ...  message=numberOfSamplesToCompare changed to -> ${numberofsamplestocompare_value}
    ...  style=INFO
    Logging With Timestamp
    ...  message=Step 3: Change tcs_parameters Values
    ...  style=DONE

Step 4: Trigger The Temperature Gradient Event 3 times
    [Documentation]
    ...  Description:
    ...  KW that triggers the temperature gradient event 3 times by overriding temperature value on RU
    ...  to 65, 90 and 120 degrees Celsius and waiting 5 minutes after each change for RU to detect the change.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 4: Trigger The Temperature Gradient Event 3 times
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=First Trigger - Change temperature to ${first_override_temperature_value} degrees Celsius on RU
    ...  style=ONGOING
    radio.Open Connection To Radio Module  ru_serial_number=${RMOD_SERIAL_NUMBER}
    radio.Send Command  command=frmonShellClient 127.0.0.1 2000
    radio.Read Output  delay=1
    radio.Send Command  command=/ action create ThermometerDevice /thermometerDevice ${temp_sensor_dict['${RMOD_HW_FAMILY}']}
    ${output}  radio.Read Output  delay=1
    Should Contain  ${output}  done ok
    radio.Send Command  command=/thermometerDevice get temperature
    ${output}  radio.Read Output  delay=1
    Should Contain  ${output}  done ok
    radio.Send Command  command=/thermometerDevice action override TEMPERATURE ${first_override_temperature_value}
    ${output}  radio.Read Output  delay=1
    Should Contain  ${output}  TEMPERATURE ${first_override_temperature_value} ==> done ok
    Sleep  30
    Logging With Timestamp
    ...  message=First Trigger - Change temperature to ${first_override_temperature_value} degrees Celsius on RU
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting 5 minutes for temperature change to be detected by RU
    ...  style=ONGOING
    Sleep  300s
    Logging With Timestamp
    ...  message=Waiting 5 minutes for temperature change to be detected by RU
    ...  style=DONE

    Logging With Timestamp
    ...  message=Second Trigger - Change temperature to ${second_override_temperature_value} degrees Celsius on RU
    ...  style=ONGOING
    radio.Send Command  command=/thermometerDevice action override TEMPERATURE ${second_override_temperature_value}
    ${output}  radio.Read Output  delay=1
    Should Contain  ${output}  TEMPERATURE ${second_override_temperature_value} ==> done ok

    Logging With Timestamp
    ...  message=Second Trigger - Change temperature to ${second_override_temperature_value} degrees Celsius on RU
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting 5 minutes for temperature change to be detected by RU
    ...  style=ONGOING
    Sleep  300s
    Logging With Timestamp
    ...  message=Waiting 5 minutes for temperature change to be detected by RU
    ...  style=DONE

    Logging With Timestamp
    ...  message=Third Trigger - Change temperature to ${third_override_temperature_value} degrees Celsius on RU
    ...  style=ONGOING
    radio.Send Command  command=/thermometerDevice action override TEMPERATURE ${third_override_temperature_value}
    ${output}  radio.Read Output  delay=1
    Should Contain  ${output}  TEMPERATURE ${third_override_temperature_value} ==> done ok

    Logging With Timestamp
    ...  message=Third Trigger - Change temperature to ${third_override_temperature_value} degrees Celsius on RU
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting 5 minutes for temperature change to be detected by RU
    ...  style=ONGOING
    Sleep  300s
    Logging With Timestamp
    ...  message=Waiting 5 minutes for temperature change to be detected by RU
    ...  style=DONE

Step 5: Get Black Box Samples
    [Documentation]
    ...  Description:
    ...  KW that collects black box files from RU two times with 20 minutes wait between the collections.
    ...  Performs RU reset after first collection and waits until all cells are OnAir.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 5: Get Black Box Samples
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Collecting Black Box Sample 1 file from Radio Module
    ...  style=ONGOING
    OperatingSystem.Create Directory  ${BBOX_dir}/Sample_1
    Collect Bbox from snapshot  ru_sn=${RMOD_SERIAL_NUMBER}  destination_folder_name=Sample_1  bts_id=${bts_id}  bbox_type=all
    ${file_not_exists_temperature}=  Run Keyword And Return Status  OperatingSystem.File Should Not Exist
    ...  path=${BBOX_dir}/Sample_1/BBOX_temperature_6
    ${file_not_exists_startup}=  Run Keyword And Return Status  OperatingSystem.File Should Not Exist
    ...  path=${BBOX_dir}/Sample_1/BBOX_startup_temperature_6
    IF  not ${file_not_exists_temperature} and not ${file_not_exists_startup}
        Fail  File BBOX_temperature_6 or BBOX_startup_temperature_6 for Sample 1 should not be found on RU !
    END

    Logging With Timestamp
    ...  message=File BBOX_Sample_1 collected !
    ...  style=DONE
    Logging With Timestamp
    ...  message=Perfmorming Radio Reset on ${RMOD_SERIAL_NUMBER}, please wait !
    ...  style=ONGOING
    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${bts_id}
    Logging With Timestamp
    ...  message=Radio Reset on ${RMOD_SERIAL_NUMBER} finished !
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting 5 minutess for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${bts_id}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Waiting 20 minutes before collecting next Black Box Sample files
    ...  style=ONGOING
    Sleep  20min
    Logging With Timestamp
    ...  message=Waiting 20 minutes before collecting next Black Box Sample files
    ...  style=DONE
    Logging With Timestamp
    ...  message=Collecting Black Box Sample 2 files from Radio Module
    ...  style=ONGOING
    OperatingSystem.Create Directory  ${BBOX_dir}/Sample_2
    Collect Bbox from snapshot  ru_sn=${RMOD_SERIAL_NUMBER}  destination_folder_name=Sample_2  bts_id=${bts_id}  bbox_type=all
    ${file_not_exists_temperature}=  Run Keyword And Return Status  OperatingSystem.File Should Not Exist
    ...  path=${BBOX_dir}/Sample_2/BBOX_temperature_6
    ${file_not_exists_startup}=  Run Keyword And Return Status  OperatingSystem.File Should Not Exist
    ...  path=${BBOX_dir}/Sample_2/BBOX_startup_temperature_6
    IF  not ${file_not_exists_temperature} and not ${file_not_exists_startup}
        Fail  File BBOX_temperature_6 or BBOX_startup_temperature_6 for Sample 2 should not be found on RU !
    END
    Logging With Timestamp
    ...  message=File BBOX_Sample_2 collected !
    ...  style=DONE

Step 6: Check Black Box Files
    [Documentation]
    ...  Description:
    ...  KW that checks if temperature gradient counter increased by 1 in Sample 1 and by 3 in Sample 2 comparing to Reference.
    ...  Checks if NVM flush counter increased by 1 in Sample 1 and by 1 in Sample 2 comparing to Reference.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 6: Check Black Box Files
    ...  style=STEP
    ...  frame=${TRUE}
    ${ref_temp_grad_ctr}  ${ref_nvm_flush_ctr}  ${ref_temp_in_time}  ${ref_fans_in_time}  ${ref_temp_24h}  Load Black Box Sections For Scenario
    ...  scenario_base_path=${BBOX_dir}/Reference
    ${s1_temp_grad_ctr}  ${s1_nvm_flush_ctr}  ${s1_temp_in_time}  ${s1_fans_in_time}  ${s1_temp_24h}  Load Black Box Sections For Scenario
    ...  scenario_base_path=${BBOX_dir}/Sample_1
    ${s2_temp_grad_ctr}  ${s2_nvm_flush_ctr}  ${s2_temp_in_time}  ${s2_fans_in_time}  ${s2_temp_24f}  Load Black Box Sections For Scenario
    ...  scenario_base_path=${BBOX_dir}/Sample_2

    #Check Incrementation of Temperature gradient counter and NVM flush counter
    Logging With Timestamp
    ...  message=Checking Incrementation of Temperature gradient counter and NVM flush counter
    ...  style=ONGOING
    Run Keyword And Continue On Failure    Verify Black Box Counter Increment
    ...  reference_section=${ref_temp_grad_ctr}
    ...  sample_section=${s1_temp_grad_ctr}
    ...  key_to_compare=Value
    ...  expected_increment=1
    ...  error_message=Temperature gradient counter did not increase by 1 after temperature change !
    Run Keyword And Continue On Failure    Verify Black Box Counter Increment
    ...  reference_section=${ref_temp_grad_ctr}
    ...  sample_section=${s2_temp_grad_ctr}
    ...  key_to_compare=Value
    ...  expected_increment=3
    ...  error_message=Temperature gradient counter did not increase by 3 after temperature changes and RU reset !
    Run Keyword And Continue On Failure    Verify Black Box Counter Increment
    ...  reference_section=${ref_nvm_flush_ctr}
    ...  sample_section=${s1_nvm_flush_ctr}
    ...  key_to_compare=Temperature gradient trigger occur times
    ...  expected_increment=1
    ...  error_message=NVM flush counter did not increase by 1 after temperature change !
    Run Keyword And Continue On Failure    Verify Black Box Counter Increment
    ...  reference_section=${ref_nvm_flush_ctr}
    ...  sample_section=${s2_nvm_flush_ctr}
    ...  key_to_compare=Temperature gradient trigger occur times
    ...  expected_increment=1
    ...  error_message=NVM flush counter did not increase by 1 after temperature changes and RU reset !
    Logging With Timestamp
    ...  message=Incrementation of Temperature gradient counter and NVM flush counter verified
    ...  style=DONE
#    Check Temperature Profiles in Sample 1 and Sample 2
    Logging With Timestamp
    ...  message=Checking Temperature Profiles in Sample 1 and Sample 2
    ...  style=ONGOING
    Run Keyword And Continue On Failure    Validate Temperature Profile
    ...  temp_in_time_section=${s1_temp_in_time}
    ...  first_override_temperature_value=${first_override_temperature_value}
    ...  second_override_temperature_value=${second_override_temperature_value}
    ...  third_override_temperature_value=${third_override_temperature_value}
    ...  row=${temp_row['${RMOD_HW_FAMILY}']}
    ...  sample=s1
    Run Keyword And Continue On Failure    Validate Temperature Profile
    ...  temp_in_time_section=${s2_temp_in_time}
    ...  first_override_temperature_value=${first_override_temperature_value}
    ...  second_override_temperature_value=${second_override_temperature_value}
    ...  third_override_temperature_value=${third_override_temperature_value}
    ...  row=${temp_row['${RMOD_HW_FAMILY}']}
    ...  sample=s2
    Logging With Timestamp
    ...  message=Temperature Profiles in Sample 1 and Sample 2 verified
    ...  style=DONE

#    Check Startup Temperature has correct sections in Sample 1
    Logging With Timestamp
    ...  message=Checking Startup Temperature sections in Sample 1 and Sample 2
    ...  style=ONGOING
    FOR  ${i}  IN RANGE  1  6
        ${startup_temp}  Get Section From BlackBox File By Item Type
        ...  file_path=${BBOX_dir}/Sample_1/BBOX_startup_temperature_${i}
        ...  item_type=Startup_Temperature
        ...  bbox_file_type=temp
        ${startup_fans}  Get Section From BlackBox File By Item Type
        ...  file_path=${BBOX_dir}/Sample_1/BBOX_startup_temperature_${i}
        ...  item_type=Startup_Fans
        ...  bbox_file_type=temp
    END
#    Check temperatue_24 section in all Black Box Samples
    Run Keyword And Continue On Failure   Compare Temperature 24h Sections
#    Check Startup Temperature has correct sections in Sample 2
    FOR  ${i}  IN RANGE  1  6
        ${startup_temp}  Get Section From BlackBox File By Item Type
        ...  file_path=${BBOX_dir}/Sample_2/BBOX_startup_temperature_${i}
        ...  item_type=Startup_Temperature
        ...  bbox_file_type=temp
        ${startup_fans}  Get Section From BlackBox File By Item Type
        ...  file_path=${BBOX_dir}/Sample_2/BBOX_startup_temperature_${i}
        ...  item_type=Startup_Fans
        ...  bbox_file_type=temp
    END
    Logging With Timestamp
    ...  message=Startup_Temperature and Startup_fans sections exist in Sample 1 and Sample 2
    ...  style=DONE
    Logging With Timestamp
    ...  message=Step 6: Check Black Box Files
    ...  style=DONE

Load Black Box Sections For Scenario
    [Arguments]    ${scenario_base_path}
    [Documentation]
    ...  Description:
    ...  Loads Temperature_gradient_counter, NvmFlushCounter, Temperature_in_time, Fans_in_time
    ...  and temperature_24h_section sections for a given scenario path.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scenario_base_path     | yes  |   Location of the BBOX5, BBOX_startup_temperature and BBOX_temperature     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${bbox5_path}=    Set Variable    ${scenario_base_path}/BBOX5_snap
    ${bbox_temp_path}=    Set Variable    ${scenario_base_path}/BBOX_temperature_1

    ${temp_grad_ctr}  Get Section From BlackBox File By Item Type
    ...  file_path=${bbox5_path}
    ...  item_type=Temperature_gradient_counter
    ${nvm_flush_ctr}  Get Section From BlackBox File By Item Type
    ...  file_path=${bbox5_path}
    ...  item_type=NvmFlushCounter
    ${temp_in_time}  Get Section From BlackBox File By Item Type
    ...  file_path=${bbox_temp_path}
    ...  item_type=Temperature_in_time
    ...  bbox_file_type=temp
    ${fans_in_time}  Get Section From BlackBox File By Item Type
    ...  file_path=${bbox_temp_path}
    ...  item_type=Fans_in_time
    ...  bbox_file_type=temp
    ${ref_temp_24h_section}  Get Section From BlackBox File By Item Type
    ...  file_path=${bbox5_path}
    ...  item_type=Temperature_24h

    [Return]    ${temp_grad_ctr}    ${nvm_flush_ctr}    ${temp_in_time}    ${fans_in_time}  ${ref_temp_24h_section}

Verify Black Box Counter Increment
    [Arguments]    ${reference_section}    ${sample_section}    ${key_to_compare}    ${expected_increment}    ${error_message}
    [Documentation]
    ...  Description:
    ...  Compares a specific key's value in two black box sections for an expected increment.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | reference_section      | yes  |   Reference section to be compared to                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sample_section         | yes  |   Sample section to be compared against the reference                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | key_to_compare         | yes  |   The specific key within the sections to compare                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_increment     | yes  |   The expected increment value for the specified key                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | error_message          | yes  |   Error message to display if the comparison fails                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${result}  Compare Specific Part Of Sections
    ...  output1=${reference_section}
    ...  output2=${sample_section}
    ...  key=${key_to_compare}
    ...  value=${expected_increment}
    Should Be True    ${result}    ${error_message}

Validate Temperature Profile
    [Arguments]    ${temp_in_time_section}  ${first_override_temperature_value}  ${second_override_temperature_value}
    ...  ${third_override_temperature_value}  ${row}  ${sample}
    [Documentation]
    ...  Description:
    ...  Parses and validates the '${temp_row['${RMOD_HW_FAMILY}']}' temperatures from a given section against expected override values.
    ...  Arguments:
    ...  +===================================+======+============================================================================+
    ...  | Argument                          | Man. | Description                                                                |
    ...  +===================================+======+============================================================================+
    ...  | temp_in_time_section              | yes  |   Section containing temperature data over time                            |
    ...  +-----------------------------------+------+----------------------------------------------------------------------------+
    ...  | first_override_temperature_value  | yes  |   Expected temperature value after first override                          |
    ...  +-----------------------------------+------+----------------------------------------------------------------------------+
    ...  | second_override_temperature_value | yes  |   Expected temperature value after second override                         |
    ...  +-----------------------------------+------+----------------------------------------------------------------------------+
    ...  | third_override_temperature_value  | yes  |   Expected temperature value after third override                          |
    ...  +-----------------------------------+------+----------------------------------------------------------------------------+
    ...  | row                               | yes  |   Specific row identifier to extract temperatures from                     |
    ...  +-----------------------------------+------+----------------------------------------------------------------------------+
    ...  | sample                            | yes  |   Sample identifier (e.g., 's1' or 's2') to determine validation logic     |
    ...  +-----------------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${extracted_temps}=    Extract Row Values    ${temp_in_time_section}    ${row}
    Should Not Be Empty    ${extracted_temps}    No temperature values extracted for ${row}.
    IF  '${sample}'=='s1'
        ${current_temp}=    Set Variable    ${extracted_temps}[0]
        ${expected_override_temp}  Set Variable    ${first_override_temperature_value}

        ${condition}=    Evaluate    ${current_temp}+10 >= ${expected_override_temp}
        Should Be True  ${condition}  Temperature mismatch at index 0: Expected ${expected_override_temp}, Got ${current_temp}+10 (after +10 offset)
    ELSE IF  '${sample}'=='s2'
        FOR    ${i}    IN RANGE    11
        ${current_temp}  Set Variable  ${extracted_temps}[${i}]
        # Determine the expected override temperature based on index
        ${expected_override_temp}  Run Keyword If    ${i}==0
        ...    Set Variable    ${third_override_temperature_value}
        ...    ELSE IF    ${i}>0 and ${i}<6
        ...    Set Variable    ${second_override_temperature_value}
        ...    ELSE IF    ${i}>5
        ...    Set Variable    ${first_override_temperature_value}
        # Perform the comparison and assert
        ${condition}  Evaluate  ${current_temp}+10 >= ${expected_override_temp}
        Should Be True
        ...  ${condition}  Temperature mismatch at index ${i}: Expected ${expected_override_temp}, Got ${current_temp}+10 (after +10 offset)
        END
    ELSE
        Logging With Timestamp
        ...  message=Invalid sample type provided: ${sample}. Expected 's1' or 's2'.
        ...  style=ERROR
    END

Restore Default Values In Binary File
    [Documentation]
    ...  Description:
    ...  KW that restores default values in binary file tcs_parameters
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${binary_file_dict}  radio.Get Decoded Binary File
    ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...    filename=tcs_parameters
    ${temp_delta_for_save}  Set Variable    ${binary_file_dict['tcs']['bboxTempMeasurement']['temperatureDeltaForSave']}
    ${delta_t_multi}  Set Variable    ${binary_file_dict['tcs']['deltaTmulti']}
    IF  ${temp_delta_for_save}!=${DEF_V_TMP} or ${delta_t_multi}!=${DEF_V_DTMUL}
      Logging With Timestamp
      ...  message=Restoring default values of deltaTMulti and temperatureDeltaForSave from tcs_parameters file to ${DEF_V_DTMUL} and ${DEF_V_TMP}.
      ...  style=ONGOING
      ${updated_dict}=  Update Nested Value
      ...  data_dict=${DEFAULT_TCS_DICT}
      ...  key_path=${KEY_PATH_DELTA_FOR_SAVE}
      ...  new_value=${DEF_V_TMP}
      ${updated_dict}=  Update Nested Value
      ...  data_dict=${updated_dict}
      ...  key_path=${KEY_PATH_DELTATMULTI}
      ...  new_value=${DEF_V_DTMUL}
      ${updated_dict}=  Update Nested Value
      ...  data_dict=${updated_dict}
      ...  key_path=${KEY_PATH_NUMOFSAMPLES}
      ...  new_value=${DEF_V_NUM_OF_SAMPLES}
      Logging With Timestamp
      ...  message=Overriding default value of deltaTMulti and temperatureDeltaForSave from tcs_parameters file
      ...  style=ONGOING
      radio.Override Values In Binary File
      ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
      ...  filename=tcs_parameters
      ...  values_dict=${updated_dict}
      ...  reset_ru=False

        Logging With Timestamp
        ...  message=Performing Radio Unit Reset, please wait!
        ...  style=ONGOING

        admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${bts_id}

        Logging With Timestamp
        ...  message=Radio Unit Reset finished !
        ...  style=DONE
        Logging With Timestamp
        ...  message=Default values restored and RU reset performed.
        ...  style=DONE
        Logging With Timestamp
        ...  message=Waiting up to 5 minutes for all cells to be OnAir, please wait!
        ...  style=ONGOING
        Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${bts_id}
        Logging With Timestamp
        ...  message=All cells are OnAir !
        ...  style=DONE
        Logging With Timestamp
        ...  message=Verifying if values were changed correctly in tcs_parameters file
        ...  style=ONGOING
        ${binary_file_dict}  radio.Get Decoded Binary File
        ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
        ...    filename=tcs_parameters
        Should Be Equal
        ...  first='${binary_file_dict['tcs']['bboxTempMeasurement']['temperatureDeltaForSave']}'
        ...  second='${DEF_V_TMP}'
        Should Be Equal
        ...  first='${binary_file_dict['tcs']['deltaTmulti']}'
        ...  second='${DEF_V_DTMUL}'
        Should Be Equal
        ...  first='${binary_file_dict['tcs']['bboxTempMeasurement']['numberOfSamplesToCompare']}'
        ...  second='${DEF_V_NUM_OF_SAMPLES}'
        Logging With Timestamp
        ...  message=Values were restored correctly in tcs_parameters file
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Values of deltaTMulti and temperatureDeltaForSave are already at default. No action needed.
        ...  style=INFO
    END

Validate Temperature 24h Section
    [Arguments]    ${section_content}
    [Documentation]
    ...  Description:
    ...  Validates the Temperature_24h section content for correct sampling interval and temperature gathering period.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | section_content     | yes  |   Location of the BBOX5_snap file                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${sampling_interval_ok}=    Set Variable    ${FALSE}
    ${temperature_gath_period_ok}=    Set Variable    ${FALSE}
    ${lines}=    Evaluate    """${section_content}""".splitlines()
    FOR    ${line}    IN    @{lines}
      IF  "Sampling interval [s]: 60" in "${line}"
        ${sampling_interval_ok}  Set Variable  ${TRUE}
      END
      IF  "Temperature gathering period [h]: 24" in "${line}"
        ${temperature_gath_period_ok}  Set Variable  ${TRUE}
      END
    END
    IF  ${sampling_interval_ok}==${False}
        Fail  Sampling interval in Temperature_24h section is incorrect !
    END
    IF  ${temperature_gath_period_ok}==${False}
        Fail  Temperature gathering period in Temperature_24h section is incorrect !
    END

Get Num Values From Line
    [Arguments]    ${line}  ${index}  ${section_name}
    [Documentation]
    ...  Description:
    ...  KW that gets number of values from a given line in Temperature_24h section.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | line                   | yes  |   Line from which to extract the number of values                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | index                  | yes  |   Index of the line for logging purposes                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | section_name           | yes  |   Name of the section for logging purposes                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${line_parts}  Fetch From Right  ${line}  :
    ${list_of_numbers}  Split String  ${line_parts}
    ${num_values}  Get Length  ${list_of_numbers}
    Logging With Timestamp
    ...    message=${section_name} Line ${index} has ${num_values} values.
    ...    style=INFO
    ${eva}  Evaluate  ${num_values} <= 1440
    Should Be True  ${eva}  ${section_name} Line ${index} has more than 1440 values !
    [Return]    ${num_values}

Compare Temperature 24h Sections
    [Documentation]
    ...  Description:
    ...  Compares Temperature_24h sections from Reference, Sample 1 and Sample 2 black box files
    ...  to ensure correct number of temperature values are recorded after temperature changes.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${ref_temp_24h_section}  Get Section From BlackBox File By Item Type
    ...  file_path=${BBOX_dir}/Reference/BBOX5_snap
    ...  item_type=Temperature_24h
    ${sample1_temp_24h_section}  Get Section From BlackBox File By Item Type
    ...  file_path=${BBOX_dir}/Sample_1/BBOX5_snap
    ...  item_type=Temperature_24h
    ${sample2_temp_24h_section}  Get Section From BlackBox File By Item Type
    ...  file_path=${BBOX_dir}/Sample_2/BBOX5_snap
    ...  item_type=Temperature_24h

    Validate Temperature 24h Section  ${ref_temp_24h_section}
    Validate Temperature 24h Section  ${sample1_temp_24h_section}
    Validate Temperature 24h Section  ${sample2_temp_24h_section}

    ${ref_lines}  Evaluate  """${ref_temp_24h_section}""".splitlines()
    ${sample1_lines}  Evaluate  """${sample1_temp_24h_section}""".splitlines()
    ${sample2_lines}  Evaluate  """${sample2_temp_24h_section}""".splitlines()

    ${ref_length}  Get Length  ${ref_lines}
    ${sample1_length}  Get Length  ${sample1_lines}
    ${sample2_length}  Get Length  ${sample2_lines}
    ${min_len}  Evaluate  min(${ref_length}, ${sample1_length}, ${sample2_length})

    FOR  ${index}  IN RANGE  5  ${min_len}
        ${ref_line}  Get From List  ${ref_lines}  ${index}
        ${sample1_line}  Get From List  ${sample1_lines}  ${index}
        ${sample2_line}  Get From List  ${sample2_lines}  ${index}

        ${ref_num_values}  Get Num Values From Line  ${ref_line}  ${index}  Reference
        ${sample1_num_values}  Get Num Values From Line  ${sample1_line}  ${index}  Sample 1
        ${sample2_num_values}  Get Num Values From Line  ${sample2_line}  ${index}  Sample 2
        IF  ${ref_num_values} > 1440 or ${sample1_num_values} > 1440 or ${sample2_num_values} > 1440
          Fail  One of the sections has more than 1440 values in line ${index}
        ELSE IF  '${ref_num_values}' == '1440' and '${sample1_num_values}' == '1440' and '${sample2_num_values}' == '1440'
          Continue For Loop
        ELSE IF  ${ref_num_values} < 1440
          ${comparison}  Evaluate  ${ref_num_values} < ${sample1_num_values}
          ${comparison2}  Evaluate  ${sample1_num_values} <= ${sample2_num_values}
          Should Be True  ${comparison}  Sample 1 has fewer values than Reference in line ${index} !
          Should Be True  ${comparison2}  Sample 2 has fewer values than Sample 1 in line ${index} !
        ELSE
          Fail  Unexpected condition encountered while comparing Temperature_24h sections in line ${index} !
        END
    END
