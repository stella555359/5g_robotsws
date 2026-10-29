*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource		  ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
#Library           hran_tools
Library             ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library           taf.sbts.oam.coam.admin


*** Variables ***
${TARGET_SW_NAME}       ${None}                         # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}        /home/ute/btsauto/TARGET_SW     # Directory for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}       3000                            # Timeout for Download and Activation [sec]
${PING_LOSS_TIMEOUT}    300                             # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600                             # Timeout for ping regain during reset
${STARTUP_TIMEOUT}      15                              # timeout for smod, rmod, cells state check after reset [min]


*** Keywords ***
TC__SWM__Local_SW_Update_Fallbackcause_removal
   [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-14738
    ...
    ...  ***********************************************************
    ...  2. Description
    ...  ***********************************************************
    ...  The purpose of this TC is to verify that BTS removes existing fallbackcause.txt file during update.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-14738 - initial creation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/TAT-SWM__Local_SW_Update_Fallbackcause_removal.png

    Set Tags    CA-SWM    PHASE-CRT    OWNER-kamil.osak@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS17  SW-SBTS18    SW-SBTS19    SW-SBTS20    FEATURE-RP000938
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    Delete_uboot_parameters
    Step1: Check if fallbackCause file is present
    Step2: SW download and activation
    Step3: Check if fallbackCause file is removed
    Add_uboot_parameters

Step1: Check if fallbackCause file is present
    [Documentation]    Short description.
    Log Step Header  Step1: Check if fallbackCause file is present
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Log  Will now check if fallbackCause.txt is present in /ffs/run/config folder  console=${TRUE}
    Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ${run_output}  Run Remote Linux Command  find /ffs/run/config/fallbackCause.txt && echo "fallbackCause_found" || echo "fallbackCause_not_found"
    ${fallbackCause_exist}  Run Keyword And Return Status  Should Contain  ${run_output}  fallbackCause_found
    Run keyword if  not ${fallbackCause_exist}  Run keywords  Log  fallbackCause.txt file not found.  console=${TRUE}
    ...  AND  Create fallbackCause file and reset BTS
    ...  ELSE  Log  fallbackCause.txt file found.  console=${TRUE}

Step2: SW download and activation
    [Documentation]    Short description.
    Log Step Header  Step2: SW download and activation
    ${target_sw_path}  Get sw package from directory  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Set test variable  ${TARGET_SW_PATH}  ${target_sw_path}
    Check if sw build already present on active partition  ${TARGET_SW_PATH}
    Log  TARGET SW is not present on active partition  console=${TRUE}
    Log  Will start SW update.  console=${TRUE}
    ${sw_update_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Update Software  sw_package=${TARGET_SW_PATH}
    ...    timeout=${UPDATE_TIMEOUT}
    Run keyword if  ${sw_update_status}  Log  SW update finished successfully.  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Log  Sw update failed.  console=${TRUE}
    ...  AND
    ...  Fail   Sw update failed.
    Log  Waiting for reset after update...  console=${TRUE}
    Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_LOSS_TIMEOUT}
    Log  Ping lost${\n}Waiting for BTS to be reachable...  console=${TRUE}
    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    Log  Ping regained${\n}Waiting for stable ping...  console=${TRUE}
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=900
    Log  Ping is stable  console=${TRUE}
    Log  Checking connection to ADMIN...  console=${TRUE}
    Admin and Infomodel connections reset
    Log  Checking if BTS OnAir...  console=${TRUE}
    Wait until keyword succeeds  30 min  30 s  Check SBTS SOAM cells and modules
    Log  Checking SOAM Active Alarms...  console=${TRUE}
    Check SOAM Active Alarms

Step3: Check if fallbackCause file is removed
    [Documentation]    Short description.
    Log Step Header  Step3: Check if fallbackCause file is removed
    Log  Will now check if fallbackCause.txt is not present in /ffs/run/config folder  console=${TRUE}
    Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ${run_output}  Run Remote Linux Command  find /ffs/run/config/fallbackCause.txt && echo "fallbackCause_found" || echo "fallbackCause_not_found"
    ${fallbackCause_exist}  Run Keyword And Return Status  Should Contain  ${run_output}  fallbackCause_found
    Run keyword if  ${fallbackCause_exist}  Run keywords
    ...  Log  Test failed. fallbackCause.txt file still present in /ffs/run/config folder  console=${TRUE}
    ...  AND  Fail   fallbackCause.txt file still present in /ffs/run/config folder
    ...  ELSE  Log  fallbackCause.txt file not found in /ffs/run/config folder  console=${TRUE}

Create fallbackCause file and reset BTS
    [Documentation]    Short description.
    ${gsm_states_condit}=    Catenate    SEPARATOR=${SPACE}
    ...    gsm_states=administrativeState=${_Unlocked}, operationalState=${_Enabled}, availabilityStatus=${_Degraded},
    ...    blockingState=Unblocked, usageState=Active
    Log  Will create fallbackCause.txt file in /ffs/run/config folder  console=${TRUE}
    ${run_output}  Run Remote Linux Command
    ...  echo 3 >/ffs/run/config/fallbackCause.txt && echo "fallbackCause_created" || echo "fallbackCause_not_created"
    ${fallbackCause_created}  Run Keyword And Return Status  Should Contain  ${run_output}  fallbackCause_created
    Run keyword if  ${fallbackCause_created}  Log  fallbackCause.txt file created. Will now reset BTS.  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Log  Can not create fallbackCause.txt file  console=${TRUE}
    ...  AND
    ...  Fail  Can not create fallbackCause.txt file
    taf.sbts.oam.coam.admin.Reset site  timeout=900
    Log  Check if target is stable after BTS reset...  console=${TRUE}
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=420  timeout=1200
    Log  Ping is stable  console=${TRUE}
    Log  Checking connection to ADMIN...  console=${TRUE}
    Admin and Infomodel connections reset
    Log  Checking if BTS OnAir...  console=${TRUE}
    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout} s  10 sec  Admin Check BTS Procedural and Blocking states  OnAir
    # Wait until keyword succeeds  ${STARTUP_TIMEOUT} min  30 s  Check SBTS SOAM cells and modules
    # ...  ${gsm_states_condit}
    # ...  wcdma_states=operationalState=${_Enabled}, availabilityStatus=${_Degraded}, blockingState=Unblocked, usageState=Active
    # ...  lte_states=administrativeState=${_Unlocked}, operationalState=${_Enabled}, availabilityStatus=${_Degraded}, blockingState=Unblocked
    Log  Checking SOAM Active Alarms...  console=${TRUE}
    Check SOAM Active Alarms  expected_fault=4082
    ${run_output}  Run Remote Linux Command  find /ffs/run/config/fallbackCause.txt && echo "fallbackCause_found" || echo "fallbackCause_not_found"
    ${fallbackCause_exist}  Run Keyword And Return Status  Should Contain  ${run_output}  fallbackCause_found
    Run keyword if  not ${fallbackCause_exist}  Run keywords  Log  fallbackCause.txt file not found.  console=${TRUE}
    ...  AND  Set test norun   fallbackCause.txt file not found.
    ...  ELSE  Log  fallbackCause.txt file found.  console=${TRUE}
