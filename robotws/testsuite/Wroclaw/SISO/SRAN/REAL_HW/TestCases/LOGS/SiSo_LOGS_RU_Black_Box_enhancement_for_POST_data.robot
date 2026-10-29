*** Settings ***
Documentation
  ...  AUTHOR-mateusz-kawka@nokia.com  MAINTAINER-mateusz-kawka@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3690698/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1: Preconditions
  ...  Checking if RMOD with given serial number is present in HW configuration, if not test fail.
  ...  Collecting BBOX5 file from Radio Module to directory ${CFG.test_logs_path}/TestFiles/Reference_BBOX5_file
  ...
  ...  Step 2: Perform Radio Unit Reset
  ...  Performing Radio Unit Reset, waiting for all cells to be OnAir,
  ...  collecting BBOX5 file from Radio Module to directory ${CFG.test_logs_path}/TestFiles/After_RMOD_reset_BBOX5_file
  ...
  ...  Step 3: Collect Snapshot And Compare BBOX5 File
  ...  Collecting BTS Snapshot file, unzipping BBOX5 file from BTS snapshot file,
  ...  comparing BBOX5 file content from WebEM snapshot and after RU reset.
  ...
  ...  Step 4: Check BBOX5 File
  ...  Comparing BBOX5 file content before and after RU reset.
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 09.10.2024 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Library  ./../../Resources/Python/zip_helpers.py
Library  ./../../Resources/Python/blackbox_helpers.py

*** Variables ***

${RMOD_SERIAL_NUMBER}  BL2244D50Y4

*** Keywords ***
TC__SiSo_LOGS_RU_Black_Box_enhancement_for_POST_data
  Set Tags  AUTHOR-mateusz.kawka@nokia.com  MAINTAINER-mateusz.kawka@nokia.com
  Common Test Setup  #cells_check=False  scf_check=False
  ${bts}  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SERIAL_NUMBER}']}  scf_btsid_primary
  step 1: Preconditions  ${bts}
  step 2: Perform Radio Unit Reset  ${bts}
  step3: Collect Snapshot And Compare BBOX5 File  ${bts}
  step4: Check BBOX5 File
  [Teardown]    Run Keywords
  ...  Cleanup Unnecessary Files
  ...  AND  Common Test Teardown  #cells_check=False  scf_check=False

step 1: Preconditions
    [Arguments]    ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${RMOD_SERIAL_NUMBER}'=='${EMPTY}'
        Fail  Variable RMOD_SERIAL_NUMBER cannot be empty !
    END

        ${rmods_info}  admin.Get FRM  timeout=60  connection=${bts_id}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SERIAL_NUMBER}'
        ${rmod_distname_id}  Set Variable  ${rmod['id']['internal']}
    END

    Set Test Variable  ${RMOD_DISTNAME_ID}

    IF  '${rmod_distname_id}'=='${NONE}'
        Fail  Serial Number ${RMOD_SERIAL_NUMBER} not found in HW Configuration ! Test set to Fail !
    ELSE
        Logging With Timestamp  message=RMOD with SN ${RMOD_SERIAL_NUMBER} found in configuration!
    END

    Logging With Timestamp
    ...  message=Performing Radio Unit Reset, please wait!
    ...  style=ONGOING

    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${bts_id}

    Logging With Timestamp
    ...  message=Radio Unit Reset finished !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING

    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${bts_id}

    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Collecting Reference BBOX5 file from Radio Module to directory ${CFG.test_logs_path}/TestFiles/Reference_BBOX5_file
    ...  style=ONGOING
    OperatingSystem.Create Directory  ${CFG.test_logs_path}/TestFiles//Reference_BBOX5_file
    SSH Get File From Radio Module    ${RMOD_SERIAL_NUMBER}  /mnt/runtime/BBOX5  ${CFG.test_logs_path}/TestFiles/Reference_BBOX5_file

    Logging With Timestamp
    ...  message=File Reference_BBOX5_file collected !
    ...  style=DONE

    Set Test Variable  ${BBOX_dir}  ${CFG.test_logs_path}/TestFiles

step 2: Perform Radio Unit Reset
    [Arguments]    ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Perform Radio Unit Reset
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Performing Radio Unit Reset, please wait!
    ...  style=ONGOING

    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${bts_id}

    Logging With Timestamp
    ...  message=Radio Unit Reset finished !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Waiting up to 300s for all cells to be OnAir, please wait!
    ...  style=ONGOING

    Wait Until Keyword Succeeds  300s  10s  STATE Check If All Cells Are OnAir  bts_id=${bts_id}

    Logging With Timestamp
    ...  message=All cells are OnAir !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Collecting BBOX5 file from Radio Module to directory ${CFG.test_logs_path}/TestFiles/After_RMOD_reset_BBOX5_file
    ...  style=ONGOING
    OperatingSystem.Create Directory  ${CFG.test_logs_path}/TestFiles/After_RMOD_reset_BBOX5_file
    SSH Get File From Radio Module    ${RMOD_SERIAL_NUMBER}  /mnt/runtime/BBOX5  ${CFG.test_logs_path}/TestFiles/After_RMOD_reset_BBOX5_file

    Logging With Timestamp
    ...  message=File BBOX5 collected !
    ...  style=DONE

step3: Collect Snapshot And Compare BBOX5 File
    [Arguments]    ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Collect Snapshot And Compare BBOX5 File
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Collectiong BTS Snapshot file, please wait!
    ...  style=ONGOING

    admin.Collect Snapshot  target_file_name=${BBOX_dir}/BTS_Snapshot/BTS_Snapshot_HealthCheck.zip  coverage=HealthCheck
    ...  connection=${bts_id}  timeout=300

    Logging With Timestamp
    ...  message=Snapshot file collected !
    ...  style=DONE

    Logging With Timestamp
    ...  message=Unzipping BBOX5 file from BTS snapshot file, please wait!
    ...  style=ONGOING

    ${archives_dictionary}  Get Regex Match Nested Archives In Bts Snapshot
     ...  zip_path=${BBOX_dir}/BTS_Snapshot/BTS_Snapshot_HealthCheck.zip
     ...  regex_pattern=.*${RMOD_SERIAL_NUMBER}.*BBOX5.*

    ${parent_zip_name}  Get Dictionary Keys  ${archives_dictionary}
    ${bbox5_zip_name}  Get From Dictionary  ${archives_dictionary}  ${parent_zip_name}[0]

    ${rc1}  OperatingSystem.Run And Return RC
    ...  unzip ${BBOX_dir}/BTS_Snapshot/BTS_Snapshot_HealthCheck.zip -d ${BBOX_dir}/BTS_Snapshot/BTS_Snapshot_unzipped
    ${rc2}  OperatingSystem.Run And Return RC
    ...  unzip ${BBOX_dir}/BTS_Snapshot/BTS_Snapshot_unzipped/${parent_zip_name}[0] -d ${BBOX_dir}/BTS_Snapshot_bbox_part
    ${rc3}  OperatingSystem.Run And Return RC
    ...  unzip ${BBOX_dir}/BTS_Snapshot_bbox_part/${bbox5_zip_name}[0] -d ${BBOX_dir}/BTS_Snapshot_BBOX5_file

    IF  '${rc1}'!='0' or '${rc2}'!='0' or '${rc3}'!='0'
        Fail  Unzipping BBOX5 file from BTS snapshot file failed !
    ELSE
        Logging With Timestamp
        ...  message=Unzipping BBOX5 file from BTS snapshot file done !
        ...  style=DONE
    END

    ${rc}  ${output}=  Run And Return Rc And Output
    ...  diff -s ${BBOX_dir}/BTS_Snapshot_BBOX5_file/BBOX5 ${BBOX_dir}/After_RMOD_reset_BBOX5_file/BBOX5

    Should Contain  ${output}  are identical  msg=BBOX Files from RU and Snapshot are not identical!

    Logging With Timestamp
    ...  message=BBOX5 Files from RU and BTS Snapshot are identical!


step4: Check BBOX5 File
    Logging With Timestamp
    ...  message=Step 4: Check BBOX5 File
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Comparing BBOX5 file content before and after RU reset, please wait!
    ...  style=ONGOING

    ${post_item_reference}  Get Section From Blackbox File By Item Type
    ...  file_path=${BBOX_dir}/Reference_BBOX5_file/BBOX5
    ...  item_type=POST_results
    Logging With Timestamp
    ...  message=Reference BBOX5 file POST results:\n${post_item_reference}

    ${post_item_after_reset}  Get Section From Blackbox File By Item Id
    ...  file_path=${BBOX_dir}/After_RMOD_reset_BBOX5_file/BBOX5
    ...  item_id=POST_results
    Logging With Timestamp
    ...  message=BBOX5 file after RU reset POST results:\n${post_item_after_reset}

    ${shift_status}  Verify Shift For Blackbox Post Result    ${post_item_reference}    ${post_item_after_reset}  from_index=0  to_index=1
    ${shift2_status}  Verify Shift For Blackbox Post Result    ${post_item_reference}    ${post_item_after_reset}  from_index=1  to_index=2
    ${last_write_ref_status}  Verify Last Write For Blackbox Post Result    ${post_item_reference}
    ${last_write_after_reset_status}  Verify Last Write For Blackbox Post Result    ${post_item_after_reset}

    IF  ${shift_status} and ${shift2_status}
        Logging With Timestamp
        ...  message=Shift status for BBOX5 file POST results is correct!
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Shift status for BBOX5 file POST results is incorrect!
        ...  style=ERROR
        Run Keyword And Continue On Failure  Fail  Shift status for BBOX5 file POST results is incorrect!
    END

    IF  ${last_write_ref_status} and ${last_write_after_reset_status}
        Logging With Timestamp
        ...  message=Last write status for BBOX5 file POST results is correct!
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Last write status for BBOX5 file POST results is incorrect!
        ...  style=ERROR
        Run Keyword And Continue On Failure  Fail  Last write status for BBOX5 file POST results is incorrect!
    END

Cleanup Unnecessary Files
    Logging With Timestamp
    ...  message=Cleaning up unzipped files
    ...  style=ONGOING

     ${rc1}  OperatingSystem.Run And Return RC  rm -rf ${BBOX_dir}/BTS_Snapshot/BTS_Snapshot_unzipped
     ${rc2}  OperatingSystem.Run And Return RC  rm -rf ${BBOX_dir}/BTS_Snapshot_bbox_part

    IF  '${rc1}'!='0' or '${rc2}'!='0'
        Logging With Timestamp
        ...  message=Cleaning up unzipped files failed !
        ...  style=WARNING
    ELSE
        Logging With Timestamp
        ...  message=Cleaning up unzipped files done !
        ...  style=DONE
    END
