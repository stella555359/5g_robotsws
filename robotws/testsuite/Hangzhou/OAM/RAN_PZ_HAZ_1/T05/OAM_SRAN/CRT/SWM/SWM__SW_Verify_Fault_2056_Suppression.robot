*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Library    hran_tools

Library    taf.sbts.oam.coam.admin
Library    ute_async


*** Keywords ***
TC__SWM__SW_Verify_Fault_2056_Suppression
   [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-14735
    ...
    ...  ***********************************************************
    ...  2. Description
    ...  ***********************************************************
    ...  Main purpose of this test case is to verify that fault 2056 will be cleared from BTS
    ...  if elements with name argument name="FCT*" and targetPath="/rom/boot"
    ...  will be removed from /ffs/run/TargetBD*.xml file and site reset
    ...  After test all files should be brought back in recovery action in step 3
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14735 - initial creation
    ...  - 29.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17311 - ENHANCEMENT for supporting rel4 (AirScale)
    ...  - 20.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18104 - Remove $ignore_alarms from 'Check if 2056 present' used in step1
    ...  - 31.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-19179 - Fix regex to allow T1/T2 packages
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/blob/master/testsuite/SBTS/TAT-14735.png

    [Timeout]    60 minutes
    Set Tags    CA-SWM    PHASE-CRT    OWNER-kamil.osak@nokia.com    AUTHOR-wojciech.sikora@nokia.com
    ...    MAINTAINER-wojciech.sikora@nokia.com    SW-SBTS17    SW-SBTS18    SW-SBTS19    FEATURE-RP000912
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    Step0: Check and enable SSH if needed
    Step1: Trigger fault 2056
    Step2: Delete FCT entries from TargedBD
#    Step3: Recovery actions

Step0: Check and enable SSH if needed
    [Documentation]    Short description.
    Log Step Header  Step0: Check and enable SSH if needed
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}

Step1: Trigger fault 2056
    [Documentation]    Short description.
    [Teardown]  Stop async
    Log Step Header  Step1: Trigger fault 2056
    ${sm_variant}=  Get SM variant
    Set test variable  ${SM_VARIANT}  ${sm_variant[0]}
    Log  SM variant is ${SM_VARIANT}${\n}Files will now be deleted from SBTS based on SM variant...  console=${TRUE}
    ${files_del_success}  Run keyword if  '${SM_VARIANT}'=='FSMF'  Delete files on r3
    ...  ELSE  Delete files on r4
    Set test variable  ${FILES_DEL_SUCCESS}  ${files_del_success}
    Run keyword if  ${FILES_DEL_SUCCESS}  Log  Files deleted. Site reset will be now performed...  console=${TRUE}
    ...  ELSE
    ...  Fail  For some reason files couldn't be deleted. Check logs...
    Start async  taf.sbts.oam.coam.admin  Reset Site  600
    ${ping_check}  Run keyword and return status  Ping check after SWM operation
    Run keyword if    not ${ping_check}  Set test failed  Site reset was not performed correctly. Check logs...
    sleep    5min
    Log  Checking if Fault 2056 is present on BTS...  console=${TRUE}
    Wait until keyword succeeds  3 min  10 sec  Check if 2056 present
    Log  Fault 2056 is visible on BTS!  console=${TRUE}

Step2: Delete FCT entries from TargedBD
    [Documentation]    Short description.
    [Teardown]  Stop async
    Log step header  Step2: Delete FCT entries from TargedBD
    Log  Copying TargetBD*.xml to logs folder for later editing...  console=${TRUE}
    ${TargetBD_name}  Run remote Linux Command  cd /ffs/run && find TargetBD*.xml
    ${TargetBD_name}  Get Regexp Matches  ${TargetBD_name}  ^TargetBD_SBTS\\d{2,2}\\w[0-9]?_\\D{3,5}\\d{4}_\\d{6}_\\d{6}(T1|T2)?\\.xml
    Set test variable  ${TARGETBD_NAME}  ${TargetBD_name[0]}
    Run Local Linux Command  mkdir -p -m 777 ${TestFiles}/TargetBD_backup
    ${command_1}=   Catenate   sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/TargetBD*.xml'
    ...    '${TestFiles}/TargetBD_backup/TargetBD_backup.xml'
    Run Local Linux Command     ${command_1}
    Log  ...done  console=${TRUE}
    Log  Removing elements from TargetBD xml file..  console=${TRUE}
    Remove FCT elements from TargetBD  ${TestFiles}/TargetBD_backup/TargetBD_backup.xml  ${TestFiles}/TargetBD_backup/${TARGETBD_NAME}  ${SM_VARIANT}
    Log  ...done  console=${TRUE}
    Log  Copying changed TargetBD xml file to /ffs/run/ ...  console=${TRUE}
    ${command_2}=   Catenate   sshpass -p ${SMOD1['PASSWORD']} scp ${TestFiles}/TargetBD_backup/${TARGETBD_NAME}
    ...    ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/${TARGETBD_NAME}'
    Run Local Linux Command     ${command_2}
    Log  ...done  console=${TRUE}
    Start async  taf.sbts.oam.coam.admin  Reset Site  600
    ${ping_check}  Run keyword and return status  Ping check after SWM operation
    Run keyword if    not ${ping_check}  Set test restriction  Site reset was nor performed correctly. Check logs...
    Wait until keyword succeeds  3 min  10 sec  Check if 2056 cleared
    Log  Fault 2056 is cleared!  console=${TRUE}

#Step3: Recovery actions
    #[Teardown]  Stop async
    #Log step header  Step3: Recovery actions
    #Log  Will now continue with recovery to remove changes from previous steps  console=${TRUE}
    #${fault_2056_recovery}  Run keyword if  ${FILES_DEL_SUCCESS}  Run keyword and return status  Fault2056 Recovery action
    #Run keyword if    not ${fault_2056_recovery}  Set test restriction  Recovery (Fault 2056 deletion) was not successfull
    #Start async  taf.sbts.oam.coam.admin  Reset Site  600
    #${ping_check}  Run keyword and return status  Ping check after SWM operation
    #Run keyword if    not ${ping_check}  Set test restriction  Site reset was nor performed correctly. Check logs...
    #Wait until keyword succeeds  10 min  10 sec  Check SBTS SOAM cells and modules
    #Wait until keyword succeeds  3 min  10 sec  Check SOAM Active Alarms
    #Log  Fault 2056 is cleared  console=${TRUE}

Step3: Recovery actions
    [Documentation]    Short description.
    Log  Step3: Software rollback to remove fault  console=${True}
    ${rollback_status}=  Run keyword and return status  taf.sbts.oam.coam.admin.Rollback software
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.
    Log  Software rollback ended successfully.  console=${True}
	sleep    300s
	Check components states
    Log Step Header  Check path to SW package
    ${target_sw_path}  Get sw package from directory  ${Target SW dir}  ${TARGET_SW_NAME}
    Set test variable  ${TARGET_SW_PATH}  ${target_sw_path}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.Update Software  sw_package=${TARGET_SW_PATH}  should_activate=${TRUE}
    ...  timeout=2000s
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software activation failed: ${sw_update_msg}
    sleep    300s
	Check components states

Check components states
    [Documentation]    Short description.
    Log Step Header  Step11: Check components states
    ${components_operational}  Run Keyword And Return Status  Wait until keyword succeeds  15 min  30 sec  Check SBTS SOAM cells and modules
    Run keyword if    not ${components_operational}  Set Test Failed  Components states check after BTS reset failed
    Check SOAM Active Alarms

Check if 2056 present
    [Documentation]    Short description.
    Log  =============================================================${\n}Checking if fault 2056 with severity Critical is present... console=${TRUE}
    ${expected_alarms}=     Create Dictionary  faultId=2056  severity=Critical
    ${expected_patterns}=   Create List        ${expected_alarms}
    ${critical_alarms}=     Create Dictionary  severity=Major|Critical
    ${critical_patterns}=   Create List        ${critical_alarms}

    ${alarms_status}  ${alarms_return}=  Run Keyword And Ignore Error  Admin Check Active Alarms
    ...  expected_patterns=${expected_patterns}  critical_patterns=${critical_patterns}
    Run keyword if   '${alarms_status}'=='FAIL'  Fail
    ...  Failed at expected alarms:${expected_alarms} critical alarms: ${critical_alarms}
    Run keyword if    ${alarms_return}           Set Test Restriction  Minor alarm found.

Delete files on r3
    [Documentation]    Short description.
    ${find_stdout}  Run remote Linux Command  find /ffs/run/boot/FCT* && echo "Files found" || echo "Files not found"
    ${are_files_in_directory}  Run keyword and return status  Should contain  ${find_stdout}  Files found
    Run keyword if  ${are_files_in_directory}  Run keywords
    ...  Log  FCT* Files are present in /ffs/run/boot and will now be removed...  console=${TRUE}
    ...  AND
    ...  Copy files before deletion r3
    ...  AND
    ...  Run remote Linux Command  rm /ffs/run/boot/FCT*
    ${find_stdout}  Run remote Linux Command  find /ffs/run/boot/FCT* && echo "Files found" || echo "Files not found"
    ${are_files_in_directory}  Run keyword and return status  Should contain  ${find_stdout}  Files not found
    Return From Keyword If  ${are_files_in_directory}  ${TRUE}

Delete files on r4
    [Documentation]    Short description.
    ${find_dir1_stdout}  Run remote Linux Command  find /ffs/run/devicecfg/boot/FCT* && echo "Files found" || echo "Files not found"
    ${find_dir2_stdout}  Run remote Linux Command  find /ffs/run/swpool/LFS/boot/FCT* && echo "Files found" || echo "Files not found"
    ${are_files_in_directory1}  Run keyword and return status  Should contain  ${find_dir1_stdout}  Files found
    ${are_files_in_directory2}  Run keyword and return status  Should contain  ${find_dir2_stdout}  Files found
    Run keyword if  ${are_files_in_directory1} and ${are_files_in_directory2}  Run keywords
    ...  Log  FCT* Files are present in /ffs/run/devicecfg/boot and /ffs/run/swpool/LFS/boot and will now be removed...  console=${TRUE}
    ...  AND
    ...  Copy files before deletion r4
    ...  AND
    ...  Run remote Linux Command  rm /ffs/run/swpool/LFS/boot/FCT*
    ...  AND
    ...  Run remote Linux Command  rm /ffs/run/devicecfg/boot/FCT*
    ${find_dir1_stdout}  Run remote Linux Command  find /ffs/run/devicecfg/boot/FCT* && echo "Files found" || echo "Files not found"
    ${find_dir2_stdout}  Run remote Linux Command  find /ffs/run/swpool/LFS/boot/FCT* && echo "Files found" || echo "Files not found"
    ${are_files_in_directory1}  Run keyword and return status  Should contain  ${find_dir1_stdout}  Files not found
    ${are_files_in_directory2}  Run keyword and return status  Should contain  ${find_dir2_stdout}  Files not found
    Return From Keyword If  ${are_files_in_directory1} and ${are_files_in_directory2}  ${TRUE}

Fault2056 Recovery action
    [Documentation]    Short description.
    Run keyword if  '${SM_VARIANT}'=='FSMF'  Copy files after deletion r3
    ...  ELSE  Copy files after deletion r4
    Log  Files copied to BTS. Site reset will be performed...  console=${TRUE}

Copy files before deletion r3
    [Documentation]    Short description.
    Run Local Linux Command  mkdir -p -m 777 ${TestFiles}/r3_boot
    Run Local Linux Command  sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/boot/FCT*' '${TestFiles}/r3_boot'

Copy files before deletion r4
    [Documentation]    Short description.
    Run Local Linux Command  mkdir -p -m 777 ${TestFiles}/r4_boot_LFS
    Run Local Linux Command  mkdir -p -m 777 ${TestFiles}/r4_boot_devicecfg
    Run Local Linux Command
    ...  sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/swpool/LFS/boot/FCT*' '${TestFiles}/r4_boot_LFS'
    Run Local Linux Command
    ...  sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/devicecfg/boot/FCT*' '${TestFiles}/r4_boot_devicecfg'

Copy files after deletion r3
    [Documentation]    Short description.
    Run Local Linux Command
    ...  sshpass -p ${SMOD1['PASSWORD']} scp ${TestFiles}/r3_boot/* ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:"/ffs/run/boot"
    ${command}=   Catenate    sshpass -p ${SMOD1['PASSWORD']} scp ${TestFiles}/TargetBD_backup/TargetBD_backup.xml
    ...    ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/${TARGETBD_NAME}'
    Run Local Linux Command
    ...  ${command}

Copy files after deletion r4
    [Documentation]    Short description.
    Run Local Linux Command
    ...  sshpass -p ${SMOD1['PASSWORD']} scp ${TestFiles}/r4_boot_LFS/* ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/swpool/LFS/boot'
    Run Local Linux Command
    ...  sshpass -p ${SMOD1['PASSWORD']} scp ${TestFiles}/r4_boot_devicecfg/* ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/devicecfg/boot'
    ${command}=   Catenate    sshpass -p ${SMOD1['PASSWORD']} scp ${TestFiles}/TargetBD_backup/TargetBD_backup.xml
    ...    ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ffs/run/${TARGETBD_NAME}'
    Run Local Linux Command      ${command}

Check if 2056 cleared
    [Documentation]    Short description.
    Log  =============================================================${\n}Checking if fault 2056 with severity Critical is cleared... console=${TRUE}
    ${critical_alarms}=     Create Dictionary  faultId=2056  severity=Major|Critical
    ${critical_patterns}=   Create List        ${critical_alarms}
    ${ignored_alarms}=      Create Dictionary  faultId=4145
    ${ignored_patterns}=    Create List        ${ignored_alarms}

    ${alarms_status}  ${alarms_return}=  Run Keyword And Ignore Error  Admin Check Active Alarms
    ...  critical_patterns=${critical_patterns}  ignored_patterns=${ignored_patterns}
    Run keyword if   '${alarms_status}'=='FAIL'  Fail
    ...  Failed at critical alarms: ${critical_alarms} ignored alarms:${ignored_alarms}
    Run keyword if    ${alarms_return}           Set Test Restriction  Minor alarm found.
