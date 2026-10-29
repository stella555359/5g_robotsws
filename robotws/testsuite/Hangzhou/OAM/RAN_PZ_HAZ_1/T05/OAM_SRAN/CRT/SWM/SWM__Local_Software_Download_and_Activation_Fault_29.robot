*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library    taf.sbts.oam.coam.admin


*** Variables ***
${TARGET_SW_NAME}       ${None}
# SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}        /home/ute/btsauto/TARGET_SW
# Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}       2000
# Timeout for Download and Activation [sec]


*** Keywords ***
TC__SWM_Local_Software_Download_and_Activation_Fault_29
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-14664
    ...
    ...  ***********************************************************
    ...  2. Description
    ...  ***********************************************************
    ...  Main purpose of this test is to verify if SW Activation will fail with proper fault raised in ADMIN when flash file system is corrupted.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14664 - Initial creation
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 01.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17370 - Remove infomodel objects checking due to time windowof object life changes
    ...  - 27.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-16788 - Add recovery actions
    ...  - 03.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-19157 - Fix problem with fault 27 reported during SW update
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/SWM__Local_Software_Download_and_Activation_Fault_29.png

    [Timeout]    45 minutes
    Set Tags    CA-SWM    PHASE-CRT    OWNER-kamil.osak@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS17    SW-SBTS18    SW-SBTS19    SW-SBTS20    FEATURE-RP000938
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    Step1: Check path to SW package
    Step2: Get active and passive SW version
    Step3: Change active partition id number
    Step4: Start SW update with activation
    Step5: Faults verification
    Step6: Check if reset is not performed
    #Step7: Recover active partition id number

Step1: Check path to SW package
    [Documentation]    Short description.
    Log Step Header  Step1: Check path to SW package
    ${target_sw_path}  Get sw package from directory  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Set test variable  ${TARGET_SW_PATH}  ${target_sw_path}

Step2: Get active and passive SW version
    [Documentation]    Short description.
    Log Step Header  Step2: Get active and passive SW version
    Check if sw build already present on active partition  ${TARGET_SW_PATH}
    Log  SW not present on active partition  console=${TRUE}
    Check if sw build already present on passive partition  ${TARGET_SW_PATH}
    Log  SW not present on passive partition  console=${TRUE}

Step3: Change active partition id number
    [Documentation]    Short description.
    Log Step Header  Step3: Change active partition id number
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    Log  Check active partition id number  console=${TRUE}
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id_before_change}  Should Match Regexp  ${run_output}  \\d
    Set test variable  ${ACTIVE_PARTITION_ID_BEFORE_CHANGE}  ${active_partition_id_before_change}
    Log  ${\n}Active partition id = ${active_partition_id_before_change}  console=${TRUE}
    Log  Change active partition id  console=${TRUE}
    ${run_output}  Run Remote Linux Command  uboot_env set active_partition=5
    Should contain  ${run_output}  Added 1 variables  ${run_output} do not contain "Added 1 variables"
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id_after_change}  Should Match Regexp  ${run_output}  \\d
    Should not be equal  ${active_partition_id_before_change}  ${active_partition_id_after_change}  Active partition id not changed!
    Log  Active partition id after change = ${active_partition_id_after_change}  console=${TRUE}
    Set test variable  ${PARTITION_ID_CHANGED}  ${TRUE}

Step4: Start SW update with activation
    [Documentation]    Short description.
    Log Step Header  Step4: Start SW update with activation
    Log  Send SW download and activation request  console=${TRUE}
    ${main_update_thread}  taf.sbts.oam.coam.admin.Run keyword in background
    ...   Update Software  sw_package=${TARGET_SW_PATH}  should_activate=${TRUE}
    ...  timeout=${UPDATE_TIMEOUT}
    Log  Wait for SW activation  console=${TRUE}
    ${distName_pattern}  Set variable  /MRBTS-1/RAT-1/URI-*/SESSION-*/SW_UPDATE_IND-*
    ${object}  Query Infomodel  get object ${distName_pattern} is [actionType="Activation"]  timeout=30m
    Log  SW activation triggered.  console=${TRUE}
    ${main_update_result}  ${main_update_msg}  Run Keyword And Ignore Error
    ...    taf.sbts.oam.coam.admin.Collect keyword result  ${main_update_thread}
    ...  timeout=${UPDATE_TIMEOUT}
    Log  Main update result: ${main_update_result}, ${main_update_msg}  console=${TRUE}
    Log  SW activation failed.  console=${TRUE}
    Run Keyword If  '${main_update_result}'!='FAIL'  Fail  Test failed. SW activation done, but should fail.

Step5: Faults verification
    [Documentation]    Short description.
    Log Step Header  Step5: Faults verification
    Log  Check if fault 29 appeared  console=${TRUE}
#    Check SOAM Active Alarms  expected_fault=29  ignored_fault=214
    Check SOAM Active Alarms  expected_fault=29  ignored_fault=215
    Log Important Message  Fault 29 is present.
    Set test variable  ${EXPECTED_FAULTS_ACTIVE}  ${TRUE}

Step6: Check if reset is not performed
    [Documentation]    Short description.
    Log Step Header  Step6: Check if reset is not performed
    Log  Check if BTS is stable for 5 min  console=${TRUE}
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=0  timeout=301
    Log  Reset nor performed. BTS is stable for 5 min.  console=${TRUE}

Step7: Recover active partition id number
    [Documentation]    Short description.
    Log Step Header  Step7: Recover active partition id number
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    Log  Recover active partition id number  console=${TRUE}
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id_after_change}  Should Match Regexp  ${run_output}  \\d
    Set test variable  ${ACTIVE_PARTITION_ID_AFTER_CHANGE}  ${active_partition_id_after_change}
    Log  ${\n}Active partition id = ${active_partition_id_after_change}  console=${TRUE}
    Log  Change active partition id  console=${TRUE}
    ${run_output}  Run Remote Linux Command  uboot_env set active_partition=${active_partition_id_before_change}
    Should contain  ${run_output}  Added 1 variables  ${run_output} do not contain "Added 1 variables"
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id_after_recover}  Should Match Regexp  ${run_output}  \\d
    should be equal  ${active_partition_id_after_recover}  ${active_partition_id_before_change}
    Log  Active partition id after recover = ${active_partition_id_after_recover}  console=${TRUE}
    Set test variable  ${PARTITION_ID_CHANGED}  ${TRUE}

Restore active partition id
    [Documentation]    Short description.
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id_before_restore}  Should Match Regexp  ${run_output}  \\d
    Log  ${\n}Active partition id = ${active_partition_id_before_restore}  console=${TRUE}
    Log  Change active partition id  console=${TRUE}
    ${run_output}  Run Remote Linux Command  uboot_env set active_partition=${ACTIVE_PARTITION_ID_BEFORE_CHANGE}
    Should contain  ${run_output}  Added 1 variables  ${run_output} do not contain "Added 1 variables"
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id_after_restore}  Should Match Regexp  ${run_output}  \\d
    Should not be equal  ${active_partition_id_before_restore}  ${active_partition_id_after_restore}  Active partition id not changed!
    Should be equal  ${ACTIVE_PARTITION_ID_BEFORE_CHANGE}  ${active_partition_id_after_restore}  Active partition id not restored!
    Log  Active partition id restored successfully.${\n}Active partition id after restore = ${active_partition_id_after_restore}  console=${TRUE}
    Set test variable  ${PARTITION_ID_CHANGED}  ${FALSE}

Clear faults
    [Documentation]    Short description.
    Log  Will clear active faults  console=${TRUE}
    Log  Sw update started  console=${TRUE}
    taf.sbts.oam.coam.admin.Update Software  sw_package=${TARGET_SW_PATH}  should_activate=${TRUE}  timeout=${UPDATE_TIMEOUT}
    ${ping_check}  Run keyword and return status  Ping check after SWM operation
    Run keyword if    not ${ping_check}  Set test restriction  Site reset was nor performed correctly. Check logs...
    Wait until keyword succeeds  10 min  10 sec  Check SBTS SOAM cells and modules
    Wait until keyword succeeds  3 min  10 sec  Check SOAM Active Alarms
    Log Important Message  Faults are cleared
    Set test variable  ${EXPECTED_FAULTS_ACTIVE}  ${FALSE}

Custom Test Teardown
    [Documentation]    Short description.
    Run keyword if  ${PARTITION_ID_CHANGED}  Restore active partition id
    Run keyword if  ${EXPECTED_FAULTS_ACTIVE}  Clear faults
    Common Test Teardown
