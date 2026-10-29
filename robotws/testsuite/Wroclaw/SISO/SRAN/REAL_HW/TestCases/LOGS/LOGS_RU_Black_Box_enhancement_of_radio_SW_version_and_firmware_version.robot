*** Settings ***
Documentation
  ...  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  ...  [CASE LINK]:
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  CB010655_G_1_enhancement_of_radio_SW_version_and_firmware_version
  ...
  ...  Tester needs to define RMOD_SERIAL_NUMBER variable before running the test.
  ...
  ...  Step 1: Preconditions
  ...  Checking if RMOD with given serial number is present in HW configuration, if not test fail.
  ...
  ...
  ...  Step 2: Upload Older Software Version
  ...  Upload older sw version with different rfsw version according to variable &{BBOX_UPGRADE_BUILD}
  ...  Collecting BBOX5 file from Radio Module to directory ${CFG.test_logs_path}/TestFiles/Reference_BBOX5_file
  ...
  ...  Step 3: Rollback to tested software version
  ...  Rollback to tested software version.
  ...  Collecting BTS Snapshot file, unzipping BBOX5 file from BTS snapshot file,
  ...  comparing BBOX5 file content from WebEM snapshot and after RU reset.
  ...  Snapshots are in ${CFG.test_logs_path}/TestFiles/Tested_software_BBOX5_file
  ...
  ...  Step 4: Check sw version and firmware
  ...  Checks if sw version and firmware are correct in bbox file.
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 14.11.2025 - Test case separated from robotlte legacy combo test case

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Library  ./../../Resources/Python/zip_helpers.py
Library  ./../../Resources/Python/blackbox_helpers.py
Library  DateTime

*** Variables ***
&{BBOX_UPGRADE_BUILD}=
...             SBTS24R3=SBTS24R3_ENB_0000_001030_000000
...             SBTS25R1=SBTS25R1_ENB_0000_000602_000000
...             SBTS25R2=SBTS00_ENB_9999_250130_000010
...             SBTS26R1=SBTS00_ENB_9999_251016_000018
...             SBTS26R2=SBTS00_ENB_9999_251104_000008
${CONFIGURATION_BTS_NOT_PINGABLE_TIMEOUT}  5min
${CONFIGURATION_BTS_PINGABLE_TIMEOUT}  5min
${CONFIGURATION_BTS_ONAIR_TIMEOUT}  15 minutes
${RMOD_SERIAL_NUMBER}

*** Keywords ***
TC__SiSo_LOGS_RU_Black_Box_enhancement_of_radio_SW_version_and_firmware_version
  Set Tags  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  Common Test Setup  #cells_check=False  scf_check=False
  step 1: Preconditions Black Box enhancement of radio SW version and firmware version
  step 2: Upload older version of software
  step 3: Rollback to tested sw version
  step 4: Check Sw version and firmware
  [Teardown]    Run Keywords
  ...  Cleanup Unnecessary Files For Test
  ...  AND  Common Test Teardown

step 1: Preconditions Black Box enhancement of radio SW version and firmware version
    [Documentation]  Checking if RMOD with given serial number is present in HW configuration, if not test fail.
    ...  Also setting BTS_ID and BBOX_dir variables for further use.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 1: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${RMOD_SERIAL_NUMBER}'=='${EMPTY}'
        Fail  Variable RMOD_SERIAL_NUMBER cannot be empty !
    END
    ${bts_id}  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SERIAL_NUMBER}']}  scf_btsid_primary
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Set Test Variable  ${BBOX_dir}  ${CFG.test_logs_path}/TestFiles

    ${rmods_info}=  admin.Get FRM  timeout=60  connection=${BTS_ID}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SERIAL_NUMBER}'
        ${rmod_distname_id}=  Set Variable  ${rmod['id']['internal']}
    END

    IF  '${rmod_distname_id}'=='${NONE}'
        Fail  Serial Number ${RMOD_SERIAL_NUMBER} not found in HW Configuration ! Test set to Fail !
    ELSE
        Logging With Timestamp  message=RMOD with SN ${RMOD_SERIAL_NUMBER} found in configuration!
    END
    Set Test Variable  ${RMOD_DISTNAME_ID}    ${rmod_distname_id}

    Logging With Timestamp
    ...  message=Performing Radio Unit Reset, please wait!
    ...  style=ONGOING
    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${BTS_ID}
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

step 2: Upload older version of software
    [Documentation]  Upload older sw version with different rfsw version according to variable &{BBOX_UPGRADE_BUILD}
    ...  Collecting BBOX5 file from Radio Module to directory ${CFG.test_logs_path}/TestFiles/Reference_BBOX5_file
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 2: Upload older version of software
    ...  style=STEP
    ...  frame=${TRUE}

    ${should_execute_rollback}=  Set Variable  False

    Logging With Timestamp
    ...  message= Update software to older version started
    ...  style=ONGOING
    Set Test Variable    ${bbox_sw_folder}    /home/ute/bbox_sw
#  ${active_branch}=    Get From Dictionary    ${cfg.NODES['${bts}']}     active_release
    ${active_branch}=  SWM Get SW Build Release  partition=Active  bts_id=${BTS_ID}
    ${is_passive}=  Run Keyword And Return Status  Should Contain
    ...  ${BBOX_UPGRADE_BUILD['${active_branch}']}  ${cfg.NODES['${BTS_ID}']['software_passive']}
    ${T1_passive}=  Run Keyword If  ${is_passive}  Run Keyword And Return Status  Should Contain  ${cfg.NODES['${BTS_ID}']['software_passive']}  T1
    ${T2_passive}=  Run Keyword If  ${is_passive}  Run Keyword And Return Status  Should Contain  ${cfg.NODES['${BTS_ID}']['software_passive']}  T2
    ${bbox_older_software}=    Run Keyword If  ${is_passive} and ${T1_passive}  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}
    ...  ELSE IF  ${is_passive} and ${T2_passive}  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}
    ...  ELSE IF  ${is_passive}  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}T1
    ...  ELSE  Set Variable  ${BBOX_UPGRADE_BUILD['${active_branch}']}
    ${bbox_software_package_path}=  SWM Check Main Software Package Availability  ${bbox_older_software}  ${BTS_ID}
    ${update_start_date}=  Get Current Date  UTC
    Run Keyword And Ignore Error  admin.Wait Sw Update Possible
    ...  bts_ready=True
    ...  readiness_timeout=800
    ...  timeout=800
    ...  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=Update started
    ...  style=ONGOING
    admin.Update Software
    ...  sw_package=${bbox_software_package_path}
    ...  timeout=4200
    ...  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=SW Update done
    ...  style=DONE
    Logging With Timestamp
    ...  message=Waiting for BTS to reboot and became onAir
    ...  style=ONGOING
    Run Keyword And Ignore Error  STATE BTS Address Is NOT Pingable
    ...  host_ip_addr=192.168.255.1
    ...  timeout=${CONFIGURATION_BTS_NOT_PINGABLE_TIMEOUT}
    ...  bts_id=${BTS_ID}
    Run Keyword And Ignore Error  STATE BTS Address Is Pingable
    ...  host_ip_addr=192.168.255.1
    ...  timeout=${CONFIGURATION_BTS_PINGABLE_TIMEOUT}
    ...  bts_id=${BTS_ID}
    WHILE  ${True}  limit=${CONFIGURATION_BTS_ONAIR_TIMEOUT}
        ${status}  ${bts_state}=  Run Keyword And Ignore Error  admin.Get Mrbts State
        ...  connection=${BTS_ID}
        IF  "${status}"=="PASS"
            IF  "${bts_state}"=="OnAir"  BREAK
        END
        Sleep  30 seconds
    END

    ${should_execute_rollback}=    Set Variable    True
    ${update_end_date}=  Get Current Date  UTC
    Logging With Timestamp
    ...  message= Update software to older version finished
    ...  style=DONE

  Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING
  Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
  Logging With Timestamp
  ...  message=All cells are OnAir !
  ...  style=DONE

  Logging With Timestamp
    ...  message=Reset Unit after software update to gather new black box file. Please wait.
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
  OperatingSystem.Create Directory  ${CFG.test_logs_path}/TestFiles/Reference_BBOX5_file
  ${destination_folder_name}=  Collect Both BBox Files For Radio
  ...  destination_folder_name=Reference_BBOX5_file
  ...  bts_id=${BTS_ID}
#  SSH Get File From Radio Module    ${RMOD_SERIAL_NUMBER}  /mnt/runtime/BBOX5  ${CFG.test_logs_path}/TestFiles/Reference_BBOX5_file
  Logging With Timestamp
  ...  message=Reference File BBOX5 collected !
  ...  style=DONE

step 3: Rollback to tested sw version
    [Documentation]  Rollback to tested software version.
    ...  Collecting BTS Snapshot file, unzipping BBOX5 file from BTS snapshot file,
    ...  comparing BBOX5 file content from WebEM snapshot and after RU reset.
    ...  Snapshots are in ${CFG.test_logs_path}/TestFiles/Tested_software_BBOX5_file
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  messageStep 3: Rollback to tested sw version
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message= Rollback to tested software version started
    ...  style=ONGOING
    admin.Rollback Software  connection=${BTS_ID}  timeout=3000
    Logging With Timestamp
    ...  message=Software rollback is being made. Please wait...
    ${reset_state}=  Run Keyword And Continue On Failure
    ...  LOGS_RU_Black_Box_enhancement_of_radio_SW_version_and_firmware_version.BTS Is Resetting  timeout=240 sec
    Logging With Timestamp
    ...  message=Waiting for BTS to reboot and became onAir
    ...  style=ONGOING
    Run Keyword And Ignore Error  STATE BTS Address Is NOT Pingable
    ...  host_ip_addr=192.168.255.1
    ...  timeout=${CONFIGURATION_BTS_NOT_PINGABLE_TIMEOUT}
    ...  bts_id=${BTS_ID}
    Run Keyword And Ignore Error  STATE BTS Address Is Pingable
    ...  host_ip_addr=192.168.255.1
    ...  timeout=${CONFIGURATION_BTS_PINGABLE_TIMEOUT}
    ...  bts_id=${BTS_ID}
    WHILE  ${True}  limit=${CONFIGURATION_BTS_ONAIR_TIMEOUT}
        ${status}  ${bts_state}=  Run Keyword And Ignore Error  admin.Get Mrbts State
        ...  connection=${BTS_ID}
        IF  "${status}"=="PASS"
            IF  "${bts_state}"=="OnAir"  BREAK
        END
        Sleep  30 seconds
    END
    Logging With Timestamp
    ...  message=Waiting up to 5 minutes for all cells to be OnAir, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}
    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE
      Logging With Timestamp
    ...  message=Reset Unit after software update to gather new black box file. Please wait.
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

step 4: Check Sw version and firmware
    [Documentation]  Checks if sw version and firmware are correct in bbox file.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 4: Check Sw version and firmware
    ...  style=STEP
    ...  frame=${TRUE}
    OperatingSystem.Create Directory  ${BBOX_dir}/Tested_software_BBOX5_file
    ${destination_folder_name}=  Collect Both BBox Files For Radio
    ...  destination_folder_name=Tested_software_BBOX5_file
    ...  bts_id=${BTS_ID}

    Logging With Timestamp
    ...  message=Tested Software BBOX5 collected !
    ...  style=DONE

    Check SW Version History and Firmware

BTS Is Resetting
  [Arguments]  ${timeout}=120
  [Documentation]  Keyword waits until BTS is resetting.
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | timeout                | No   | Time to wait until BTS is resetting. Default is 120 seconds.               |
    ...  +========================+======+============================================================================+
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  Run Keyword And Continue On Failure  admin.Assert No
  ...  BTS
  ...  proceduralState=OnAir
  ...  alias=${BTS_ID}
  ...  timeout=${timeout}

Check SW Version History and Firmware
    [Documentation]  CB010655_G_1_enhancement_of_radio_SW_version_and_firmware_version
    ...  KW compares values of firmware and product build on RU and those in BBOX and checks if there are the same.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Checking SW Version History and Firmware, please wait!
    ...  style=ONGOING
    ${rmods_parameters}=  admin.Get Parameters For All  class_name=RMOD  connection=${BTS_ID}
    FOR  ${parameter}  IN  @{rmods_parameters}
      Continue For Loop If  '${parameter['serialNumber']}'!='${RMOD_SERIAL_NUMBER}'
      Set Test Variable  ${RMOD_SW_VERSION}  ${parameter['buildVersion']}
      Exit For Loop
    END
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module   ru_serial_number=${RMOD_SERIAL_NUMBER}
    radio.Send Command   SWmanShellCommand -i
    ${radio_sw_txt}=  radio.Read Output  delay=1
    radio.Close SSH Connection
    ${active_Build_Name}=  Fetch From Right  ${radio_sw_txt}  activeBuildName:
    ${active_Build_Name}=  Fetch From Left  ${active_Build_Name}  activeBuildVersion
    ${file0}=  Fetch From Right  ${radio_sw_txt}  File[0]:
    ${file0}=  Fetch From Left  ${file0}  File[1]:
    ${file0_firmware}=  Fetch From Right  ${file0}  name:
    ${file0_firmware}=  Fetch From Left  ${file0_firmware}  version:
    ${file1}=  Fetch From Right  ${radio_sw_txt}  File[1]:
    ${file1}=  Fetch From Left  ${file1}  File[2]:
    ${file1_firmware}=  Fetch From Right  ${file1}  name:
    ${file1_firmware}=  Fetch From Left  ${file1_firmware}  version:
    ${file2}=  Fetch From Right  ${radio_sw_txt}  File[2]:
    ${file2_firmware}=  Fetch From Right  ${file2}  name:
    ${file2_firmware}=  Fetch From Left  ${file2_firmware}  version:
    ${is_active_sw_in_file0}=  Run Keyword And Return Status  Should Contain  ${file0}  active
    ${is_active_sw_in_file1}=  Run Keyword And Return Status  Should Contain  ${file1}  active
    ${is_active_sw_in_file2}=  Run Keyword And Return Status  Should Contain  ${file2}  active
    ${check_active_sw}=  Run Keyword And Return status  Should Match Regexp  ${active_Build_Name}  ${RMOD_SW_VERSION}
    IF  not ${check_active_sw}  Fail  msg=Active software not correct in RU.
    ${sw_version_list}=  Create List
    ${item_type_start}=  Set Variable  ${False}
    @{lines}=  Split To Lines  ${radio_sw_txt}
    ${sw_version_bbox_string}=  Get Section From Blackbox File By Item Type
    ...  file_path=${BBOX_dir}/Tested_software_BBOX5_file/BBOX5
    ...  item_type=SW_version
    ${sw_version_bbox_part}=   Split To Lines  string=${sw_version_bbox_string}
    FOR  ${item}  IN  @{sw_version_bbox_part}
        ${name_line0}=  Run Keyword And Return Status  Should Contain  ${item}  [0] name:
        ${name_line1}=  Run Keyword And Return Status  Should Contain  ${item}  [1] name:
        ${name_line2}=  Run Keyword And Return Status  Should Contain  ${item}  [2] name:
        Run Keyword If  '${name_line0}'=='True' and '${is_active_sw_in_file0}'=='True'  Run Keywords
        ...  Should Contain  ${item}  ${file0_firmware.strip()}
        ...  AND  Set Test Variable  ${firmware_ok}  True
        ...  AND  Exit For Loop
        Run Keyword If  '${name_line1}'=='True' and '${is_active_sw_in_file1}'=='True'  Run Keywords
        ...  Should Contain  ${item}  ${file1_firmware.strip()}
        ...  AND  Set Test Variable  ${firmware_ok}  True
        ...  AND  Exit For Loop
        Run Keyword If  '${name_line2}'=='True' and '${is_active_sw_in_file2}'=='True'  Run Keywords
        ...  Should Contain  ${item}  ${file2_firmware.strip()}
        ...  AND  Set Test Variable  ${firmware_ok}  True
        ...  AND  Exit For Loop
    END
    Should Contain  ${firmware_ok}  True  msg=Active software not correct in bbox file
    Logging With Timestamp
    ...  message=Active firmware in bbox file is correct - ${RMOD_SW_VERSION}
    ...  style=INFO

    ${sw_version_history_after_update}=  Get Section From Blackbox File By Item Type
    ...  file_path=${BBOX_dir}/Tested_software_BBOX5_file/BBOX5
    ...  item_type=SW_version_history
    ${sw_version_history_after_update}=   Split To Lines  string=${sw_version_history_after_update}

    ${sw_version_history_reference}=  Get Section From Blackbox File By Item Type
    ...  file_path=${BBOX_dir}/Reference_BBOX5_file/BBOX5
    ...  item_type=SW_version_history
    ${sw_version_history_reference}=   Split To Lines  string=${sw_version_history_reference}
    Log  ${sw_version_history_reference}
    Log  ${sw_version_history_after_update}
    Logging With Timestamp
    ...  message=Checking Software Version History, please wait!
    ...  style=ONGOING
    ${reference_length}=  Get Length  ${sw_version_history_reference}
    FOR  ${index}  IN RANGE  ${reference_length-3}
      Continue For Loop If  ${index} <= 2
      IF  ${index} == 3
        ${new_temp}=  Fetch From Right  ${sw_version_history_after_update[${index}]}  :
        ${new_temp}=  Fetch From Left  ${new_temp}  jenkins
        ${contains}=   Run Keyword And Return status  Evaluate  '${active_Build_Name.strip()}' == '${new_temp.strip()}'
        IF  not ${contains}
            Fail  msg=Active software not correct in bbox file sw_version_history. In RMOD: ${active_Build_Name} in black box file: ${new_temp}
        END
      END
      ${old_temp}=  Fetch From Right  ${sw_version_history_reference[${index}]}  :
      ${new_temp}=  Fetch From Right  ${sw_version_history_after_update[${index+3}]}  :
      Should Match  ${old_temp}  ${new_temp}
    END
    Logging With Timestamp
    ...  message=Checking Software Version History - all OK.
    ...  style=DONE
    [Teardown]    Run Keyword    radio.Close SSH Connection

Cleanup Unnecessary Files For Test
    [Documentation]  Cleans up unzipped files after test execution.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Cleaning up unzipped files
    ...  style=ONGOING

     ${rc1}=  OperatingSystem.Run And Return RC  rm -rf ${BBOX_dir}/BTS_Snapshot/BTS_Snapshot_unzipped
     ${rc2}=  OperatingSystem.Run And Return RC  rm -rf ${BBOX_dir}/BTS_Snapshot_bbox_part

    IF  '${rc1}'!='0' or '${rc2}'!='0'
        Logging With Timestamp
        ...  message=Cleaning up unzipped files failed !
        ...  style=WARNING
    ELSE
        Logging With Timestamp
        ...  message=Cleaning up unzipped files done !
        ...  style=DONE
    END
