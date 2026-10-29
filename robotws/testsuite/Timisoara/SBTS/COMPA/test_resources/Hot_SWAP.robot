*** Settings ***
Documentation
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SW_PACKAGE_PATH}  /home/ute/btsauto/TARGET_SW  # Direct path to directory where desired sw package is stored, should be the same as passive
# SW before fallback
${SW_UPDATE_TIMEOUT}  1000  # Given in seconds; That is a timeout for SW download and activation (without reset)
${PING_LOSS_TIMEOUT}  240  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${RESTORE_TIMEOUT}  240  # Timeout for cells to go OnAir after last update
${WAIT_BEFORE_SW_UPDATE_ON_ESM-VIA_MSM}  800  # Timeout for cells to go OnAir after last update
${ESM_IP}  192.168.255.119  # ESM trs ip
${MSM_IP}  192.168.255.129  # MSM trs
${FAULT_4001_TIMEOUT}  3  # How long should KW wait for fault 4001 [in minutes]
${TARGET_SW_PATTERN}  SBTS  # Pattern for software which will be installed
${SW_DIRECTORY}  /home/ute/btsauto/CLEANINGS/FDSW  # Directory with software, which will be installed
${SWCONFIG_PATH}  /home/ute/btsauto/swconfigs/swconfig.txt  # Path to prepared swconfig.txt
${MAKE_ADDITIONAL_CHECKS}  ${FALSE}  # Set TRUE if additional check of BTS (cells, modules, alarms) should be taken
# at the end of TC
${ADDITIONAL_CHECKS_NUMBER}  5  # Number of checks which have to be perform to ensure that bts is onAir
${SLEEP_INTERVAL}  1 min  # Time interval between additional checks, if given in minutes,
# time unit must be added


*** Keywords ***
TC__Hot_SWAP_Slave_SBTS
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883
    ...
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  PHASE-COMPA  CA-SWM  OWNER-daniel.cozma@nokia.com  AUTHOR-daniel.cozma@nokia.com  SW-SBTS21A  SW-SBTS22R1

    TC Preconditions
    Step 0: Suite Configuration
    Step 1: Check Active And Passive Sw Version
    Step 2: Install Software On ESM Partition_1
#  step 3: Wait until BTS stabilizes
    Step 4: Install Software On ESM Partition_2
#  step 3: Wait until BTS stabilizes
    Step 5: Check Sw And Fault23
    Step 6: Find SW Name And Path
    Step 7: SW Update On ESM Via MSM
    Step 8: Fault 23 For RMOD Verification
    Step 9: RMODs SW Update For ESM
    Step 10: Check Active Alarms And Software Version
#  Step 11: Check alarms
    Step12: Check If All Cells OnAir
    Step13: Check Active Alarms


TC Preconditions
    Log Important Message  TC Preconditions
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH Connection And Enable If Necessary
    ssh.Connect To  ${PC_IP2}  ute  ute
    Check Available Ping Of ESM
    Log  ESM ping:${ESM_IP}  console=true
    Setup SSH Keys On Extension  ${ESM_IP}
    SW File Availability On Master VM
    SW File Availability On Extension VM
    Upload Swconfig To Extension


Step 0: Suite Configuration
    Log Step Header  Step 0: Suite configuration
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Set Global Variable  ${ACTIVE_SW_PATTERN}  SBTS\\d[^6]
    Set Global Variable  ${PASSIVE_SW_PATTERN}  SBTS\\d[^6]
    Verify SSH Connection And Enable If Necessary

    ${gsm_esm}  Run Keyword And Return Status
    ...  Checking If GSM On ESM
    Log  GSM cells on ESM: ${gsm_esm}  console=true
    ${wcdma_esm}  Run Keyword And Return Status
    ...  Checking If WCDMA On ESM
    Log  WCDMA cells on ESM: ${wcdma_esm}  console=true
    Set Test Variable  ${GSM_ESM}
    Set Test Variable  ${WCDMA_ESM}


Step 1: Check Active And Passive Sw Version
    Log Step Header  Step 1: Check active and passive sw version
    ${active_sw_before_master}  ${passive_sw_before_master}  Infomodel Get SW Versions  module=MSM
    ${active_sw_before_ext}  ${passive_sw_before_ext}  Infomodel Get SW Versions  module=ESM
    Set Tags For Software  SW_BEFORE_FALLBACK_MASTER  ${active_sw_before_master}  ${passive_sw_before_master}
    Set Tags For Software  SW_BEFORE_FALLBACK_EXTENSION  ${active_sw_before_ext}  ${passive_sw_before_ext}
    # Check if software match software pattern  ${active_sw_before_master}  ${ACTIVE_SW_PATTERN}
    # Check if software match software pattern  ${passive_sw_before_master}  ${PASSIVE_SW_PATTERN}
    # Check if software match software pattern  ${active_sw_before_ext}  ${ACTIVE_SW_PATTERN}
    # Check if software match software pattern  ${passive_sw_before_ext}  ${PASSIVE_SW_PATTERN}
    Set Test Variable  ${ACTIVE_SW_BEFORE_MASTER}
    Set Test Variable  ${PASSIVE_SW_BEFORE_MASTER}
    Set Test Variable  ${ACTIVE_SW_BEFORE_EXT}
    Set Test Variable  ${PASSIVE_SW_BEFORE_EXT}


Step 2: Install Software On ESM Partition_1
    Log Step Header  step 2: Install Software On ESM Partition_1
    Check Available Ping Of ESM
    Execute Yaft On Extension 1
    Execute Reboot On ESM
    Sleep  60
    Check If ESM Is Reachable


Step 3: Wait Until BTS Stabilizes
    Log Step Header  step 3: Wait until BTS stabilizes
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=600  timeout=1800
    Run Keyword If  ${ping_status}
    ...  Log  BTS is stable after installing ${TARGET_SW_PATTERN}  console=true
    ...  ELSE
    ...  Set Test Failed  BTS is not stable after installing ${TARGET_SW_PATTERN}  fail_fast=${TRUE}


Step 4: Install Software On ESM Partition_2
    Log Step Header  step 4: Install Software On ESM Partition_2
    Check Available Ping Of ESM
    Execute Yaft On Extension 2
    Execute Reboot On ESM
    Sleep  60
    Check If ESM Is Reachable


Step 5: Check Sw And Fault23
    Log Step Header  Step 5: Check sw and Fault23
    ${active_sw_after_master}  ${passive_sw_after_master}  Infomodel Get SW Versions  module=MSM
    Set Test Variable  ${ACTIVE_SW_AFTER_MASTER}
    Set Tags For Software  SW_AFTER_FALLBACK_MASTER  ${ACTIVE_SW_AFTER_MASTER}  ${passive_sw_after_master}
#  Check if software match software pattern  ${active_sw_after_master}  ${passive_sw_before_master}
#  Check if software match software pattern  ${passive_sw_after_master}  ${active_sw_before_master}
#  Log  Active SW after fallback is correct on MSM console=true
    Log  Waiting for fault 23 on SBTS...  console=true
#  FOR  ${run}  IN RANGE  1  100
#  ${incom_sw_esm}  Check If Fault 23 present on ESM
#  END
#  Run keyword if  '${incom_sw_esm}'=='${False}'
#  ...  Fail  No fault 23 on ESM or Fault severity is not 'Critical'
#  ...  ELSE
#  ...  Log  Fault 23 present on ESM. Will now install SW on ESM  console=true

    FOR  ${run}  IN RANGE  1  50
        ${incom_sw_esm}  Check If Fault 23 Present On ESM
# nok  Run keyword if  '${incom_sw_esm}'=='${TRUE}'  Log  fault 23 present. Check attempt: ${run}  console=true
        Run Keyword If  '${incom_sw_esm}' == 'True'
        ...  Run Keywords
        ...  Log  Fault 23 present on ESM. Check attempt: ${run}  console=true
        ...  AND
        ...  Return From Keyword  ${incom_sw_esm}
    END
    Run Keyword If  '${incom_sw_esm}'=='${False}'
    ...  Fail  No fault 23 on ESM or Fault severity is not 'Critical'
    ...  ELSE
    ...  Log  Fault 23 present on ESM. Will now install SW on ESM  console=true

# Check if modules states ok after sw updates
#  Log  Will now check if modules states are correct, for maximum of 60 times with 10s interval...  console=True
#  FOR  ${run}  IN RANGE  1  60
#  ${modules_status}  Verify modules  RMOD  scf_check=${FALSE}
#  run keyword if  '${modules_status}' == 'True'  Run Keywords  Log  Modules states are correct. Check attempt: ${run}  console=true
#  ...  AND  Return from keyword  ${modules_status}
#  Sleep  10
#  END
#  Set Test Failed  Modules states not correct within timeout


Step 6: Find SW Name And Path
    Log Step Header  Step 6: Find SW name and path
    Log  Checking if chosen SW is the same as active SW on MSM...  console=true
    ${active_sw_pattern_from_path}  Get Regexp Matches  ${ACTIVE_SW_AFTER_MASTER}  \\S+_(\\S+_\\S+_\\S+_\\S+)  1
    ${package_name}  OperatingSystem.List Files In Directory  ${SW_PACKAGE_PATH}  *${active_sw_pattern_from_path[0]}*
    Should Not Be Empty  ${package_name}  Required package not present in ${SW_PACKAGE_PATH}
    ${sw_path}  Join Path  ${SW_PACKAGE_PATH}  ${package_name[0]}
    OperatingSystem.File Should Exist  ${sw_path}
    Set Global Variable  ${SW_PATH}
    Log  SW package found at: ${SW_PATH}  console=True

# - orig
# Step 7: SW update on ESM via MSM
#  Log step header  Step 7: SW update on ESM via MSM
#  Log  Will now perform software update on ESM  console=true
#  ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
#  ...  coam.Update Software  ${SW path}  True  ${SW Update Timeout}
#  Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
#  Run keyword if  ${GSM_esm} or ${WCDMA_esm}  Post update ping check with 2G or 3G cells on ESM
#  ...  ELSE  Post update ping check without 2G or 3G cells on ESM
#  Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available
#  Log  ${\n}${\n}Checking if fault23 is cleared from ESM...  console=true
#  Wait Until Keyword Succeeds  5 min  10 sec  Check If Fault 23 cleared on SMOD


Step 7: SW Update On ESM Via MSM
    Log Step Header  Step 7: SW update on ESM via MSM
    Sleep  ${WAIT_BEFORE_SW_UPDATE_ON_ESM-via_MSM}
    Log  Will now perform software update on ESM  console=true
#  Wait Until Keyword Succeeds  30 min  30 sec  ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
#  ...  coam.Update Software  ${SW path}  True  ${SW Update Timeout}
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Wait Until Keyword Succeeds  20 min  60 sec
    ...  coam.Update Software  ${SW_PATH}  True  ${SW_UPDATE_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Set Test Failed  Software update failed: ${sw_update_msg}
    Run Keyword If  ${GSM_ESM} or ${WCDMA_ESM}
    ...  Post Update Ping Check With 2G Or 3G Cells On ESM
    ...  ELSE
    ...  Post Update Ping Check Without 2G Or 3G Cells On ESM
    Wait Until Keyword Succeeds  3 min  10 sec
    ...  Fail If Connection With Admin Is Not Available
    Log  ${\n}${\n}Checking if fault23 is cleared from ESM...  console=true
    Wait Until Keyword Succeeds  3 min  10 sec
    ...  Check If Fault 23 Cleared On SMOD


Step 8: Fault 23 For RMOD Verification
    Log Step Header  Step 8: Fault 23 for RMOD verification
    Log  Waiting for fault 23 on RMODs...  console=true
    FOR  ${run}  IN RANGE  1  10
        ${is_fault_active_rmod}  Check If Fault 23 Present
    END
    Set Test Variable  ${IS_FAULT_ACTIVE_RMOD}
    Log  Fault 23 For RMOD active: ${IS_FAULT_ACTIVE_RMOD}  console=true


Step 9: RMODs SW Update For ESM
    Log Step Header  Step 9: RMODs SW update for ESM
    Run Keyword If  ${IS_FAULT_ACTIVE_RMOD}==${FALSE}
    ...  Log  SW update for RMODs not needed (No faults 23 detected on ESM)  console=true
    ...  ELSE
    ...  SW Update For RMODs
    Wait Until Keyword Succeeds  1min  10sec
    ...  Check If Fault 23 Present After Update
    Log  Fault 23 on RMODs cleared  console=true
#  Log  Check if BTS is resetting due to fault 4001  console=true
#  ${reset_due_to_4001}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
#  ${4001_is_active}  Run keyword if  not ${reset_due_to_4001}  Run keyword and return status  Wait until keyword succeeds  10 min  15 s
#  ...  Check Fault 4001 after update
#  Run keyword if  ${4001_is_active}  Reset after 4001


Step 10: Check Active Alarms And Software Version
    Log Step Header  step 10: Check active alarms and software version
    # Start admin
    # Start infomodel
    ${active_sw}  Infomodel Get Active SW Version
    Log  Active SW: ${active_sw}  console=true
    Admin Check Active Alarms TAF
    @{active_alarms}  coam.Get Active Alarms
    Log  ${\n}Active alarms on BTS:  console=true
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=true
        ${notifier_is_smod}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.notifier}  SMOD_R
    END


Step 11: Check Alarms
    Log Step Header  Step 11: Check alarms
    ${active_sw_after_ext}  ${passive_sw_after_ext}  Infomodel Get SW Versions  module=ESM
    ${active_sw_master}  ${passive_sw_master}  Infomodel Get SW Versions  module=MSM
    Log  MASTER Active SW: ${active_sw_master}  console=true
    Log  MASTER Passive SW: ${passive_sw_master}  console=true
    Log  Slave Active SW: ${active_sw_after_ext}  console=true
    Log  Slave Passive SW: ${passive_sw_after_ext}  console=true
    Set Tags For Software  SW_AFTER_FALLBACK_EXTENSION  ${active_sw_after_ext}  ${passive_sw_after_ext}
#  Check if software match software pattern  ${active_sw_after_ext}  ${passive_sw_before_ext}
#  Check if software match software pattern  ${passive_sw_after_ext}  ${active_sw_before_ext}
    ${is_commissioned}  Run Keyword And Return Status
    ...  Query Infomodel  every //SCF-* is [stateInfo.proceduralState=validated]
    Set Test Variable  ${IS_COMMISSIONED}  ${is_commissioned}
    Run Keyword If  ${IS_COMMISSIONED}
    ...  Log  Active sw is commissioned  console=true
    ...  ELSE
    ...  Fail  Active sw is not commissioned  console=true
    ${modules_status}  Check If Modules States Ok After Sw Updates
    ${cells_status}  Run Keyword If  ${IS_COMMISSIONED}
    ...  Verify Cells States
    Run Keyword If  ${modules_status} and ${cells_status}
    ...  Log  BTS is operational  console=true
    ...  ELSE
    ...  Fail  Not all modules are in the expected state. Check logs (modules_status=${modules_status}, cells_status=${cells_status})


Check If Modules States Ok After Sw Updates
    Log  Will now check if modules states are correct, for maximum of 60 times with 10s interval...  console=True
    FOR  ${run}  IN RANGE  1  60
        ${modules_status}  Verify Modules  RMOD  scf_check=${FALSE}
        Run Keyword If  '${modules_status}' == 'True'
        ...  Run Keywords
        ...  Log  Modules states are correct. Check attempt: ${run}  console=true
        ...  AND
        ...  Return From Keyword  ${modules_status}
        Sleep  10
    END
    Set Test Failed  Modules states not correct within timeout


Verify Cells States
    ${cells_state}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Fail If Not All Cells Are On Air

    [Return]  ${cells_state}


Fail If Not All Cells Are On Air
    ${cells_gsm_onair}  Verify Cells  GSM
    ...  expected_states=administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked}
    ${cells_wcdma_onair}  Verify Cells  WCDMA  expected_states=operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked}
    ${cells_lte_onair}  Verify Cells  LTE
    ...  expected_states=administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked}
    Run Keyword If  ${cells_gsm_onair} and ${cells_wcdma_onair} and ${cells_lte_onair}
    ...  Log  GSM, WCDMA and LTE cells are onAir!  console=true
    ...  ELSE
    ...  Fail  GSM:${cells_gsm_onair} WCDMA:${cells_wcdma_onair} LTE:${cells_lte_onair}


Fail If Connection With Admin Is Not Available
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    Run Keyword If  ${status}
    ...  Return From Keyword  ${True}
    ${admin_reset_status}  Run Keyword And Return Status
    ...  coam.Reset Admin
    ${infomodel_reset_status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    Run Keyword If  ${status}
    ...  Return From Keyword  ${True}
    Fail  ${admin_reset_status}/${infomodel_reset_status}


Check If Fault 23 Present On ESM
    [Documentation]  If active alarm exist and is Major return True otherwise return False

    Sleep  30
    @{active_alarms}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=true
        ${notifier_is_smod}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.notifier}  SMOD_R
        Run Keyword If  '${alarm.faultId}'=='${FAULT_23}[fault_id]' and '${alarm.severity}'=='Critical' and ${notifier_is_smod}
        ...  Return From Keyword  ${TRUE}
    END
    Log  Out of loop false  console=true

    [Return]  ${FALSE}


Check If Fault 23 Cleared On SMOD
    [Documentation]  If fault 23 on SMOD is not cleared return FALSE

    @{active_alarms}  coam.Get Active Alarms
    Log  ${\n}Active alarms on BTS:  console=true
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=true
        ${notifier_is_smod}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.notifier}  SMOD_R
        Run Keyword If  '${alarm.faultId}'=='${FAULT_23}[fault_id]' and ${notifier_is_smod}
        ...  Fail  Alarm with fault 23 on ESM active
    END
    Log  ${\n}Fault23 cleared on ESM  console=true


Check If Fault 23 Present
    [Documentation]  If active alarm exist and is Major return True otherwise return False

    @{active_alarms}  coam.Get Active Alarms
    Sleep  2
    FOR  ${alarm}  IN  @{active_alarms}
        ${notifier_is_rmod}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.notifier}  RMOD_R
        Run Keyword If  '${alarm.faultId}'=='${FAULT_23}[fault_id]' and ${notifier_is_rmod}
        ...  Return From Keyword  ${TRUE}
    END

    [Return]  ${FALSE}


Check If Fault 23 Present After Update
    Check If Modules States Ok After Sw Updates
#  ${EXPECTED_ALARM1}  Create Dictionary  faultId=4082
#  ${EXPECTED}  Create List  ${EXPECTED_ALARM1}
    ${critical_alarm1}  Create Dictionary  faultId=${FAULT_23}[fault_id]
    ${critical}  Create List  ${critical_alarm1}
#  Admin Check Active Alarms TAF  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    Admin Check Active Alarms TAF  critical_patterns=${critical}


SW Update For RMODs
    Log  Will now perform SW update on RMODs  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  coam.Update Software  ${SW_PATH}  True  ${SW_UPDATE_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Set Test Failed  SW update failed. Reason: ${sw_update_msg}
    Log  Wait until rmods operationalState Enabled  console=true
    Wait Until Keyword Succeeds  10 min  30 sec
    ...  coam.Assert Every  RMOD  operationalState=Enabled


Check Ping On ESM After SW Update To ESM
    ${ping_loss_status_esm_after_esm_up}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${ESM_IP}  timeout=${PING_LOSS_TIMEOUT}  remote_host=${PC_IP2}
    Run Keyword If  ${ping_loss_status_esm_after_esm_up}==${False}
    ...  Fail  Ping has not been lost within timeout
    Log  ESM lost ping after update  console=true
    ${ping_regain_status_esm_after_esm_up}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${ESM_IP}  timeout=${PING_REGAIN_TIMEOUT}  remote_host=${PC_IP2}
    Set Test Variable  ${PING_REGAIN_STATUS_ESM_AFTER_ESM_UP}
    Run Keyword If  ${PING_REGAIN_STATUS_ESM_AFTER_ESM_UP}==${False}
    ...  Fail  Ping has not been regained within timeout
    Log  ESM regained ping after reset  console=true


Checking If GSM On ESM
    ${object_parameter}  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
        ${list}  Get From List  ${object_parameter}  ${index}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${list[0]}  /BTS_L-4/
        Run Keyword If  '${status}'=='True'
        ...  Return From Keyword  ${TRUE}
    END


Checking If WCDMA On ESM
    ${object_parameter}  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
        ${list}  Get From List  ${object_parameter}  ${index}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${list[0]}  /BTS_L-4/
        Run Keyword If  '${status}'=='True'
        ...  Return From Keyword  ${TRUE}
    END


Post Update Ping Check Without 2G Or 3G Cells On ESM
    Check Ping On ESM After SW Update To ESM
    ${ping_status_msm_after_esm_up}  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=240  max_downtime=0  timeout=250
    Log  ${\n}Was MSM ping stable after update on ESM: ${ping_status_msm_after_esm_up}  console=true
    Run Keyword If  ${ping_status_msm_after_esm_up}
    ...  Log  MSM is stable after update on ESM.  console=true
    ...  ELSE
    ...  Fail  MSM is not stable after update on ESM.


Post Update Ping Check With 2G Or 3G Cells On ESM
    Check Ping On ESM After SW Update To ESM
    Log  Waiting ${FAULT_4001_TIMEOUT}min for fault 4001  console=true
    ${fault_4001_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FAULT_4001_TIMEOUT} min  5 sec
    ...  Check Fault 4001 After Update
    Run Keyword If  ${fault_4001_status}
    ...  Run Keywords
    ...  Log Important Message  Alarm with Fault 4001 active on BTS
    ...  AND
    ...  Reset After 4001
    ...  ELSE
    ...  Log Important Message  Fault 4001 DID NOT APPEAR  level=WARN


Check Fault 4001 After Update
    ${expected_alarm1}  Create Dictionary  faultId=${FAULT_4001_BTS_RST_REQ}[fault_id]
    ${expected}  Create List  ${expected_alarm1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  print_alarms=${FALSE}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail


Reset After 4001
    Log  Waiting for BTS reset...  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=180
    Run Keyword If  '${status}'=='False'
    ...  coam.Reset Site  600
    Log  Waiting for target to be reachable  console=true
    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=180
    Log  Waiting for target to be stable  console=true
    Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=240  max_downtime=100  timeout=400


Check Available Ping Of ESM
    Log  Check available ping on ESM  console=true
    ${esm_ping_119}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=5  remote_host=${PC_IP2}
    ${esm_ping_129}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=5  remote_host=${PC_IP2}
    Run Keyword If  ${esm_ping_129}
    ...  Set Test Variable  ${ESM_IP}  192.168.255.129
    ...  ELSE IF  ${esm_ping_119}
    ...  Set Test Variable  ${ESM_IP}  192.168.255.119
    ...  ELSE
    ...  Fail  ESM is not reachable
    # Log ==ESM_IP== ${ESM_ip}  console=true


SW File Availability On Master VM
    Log  Get newest sw file from ${SW_DIRECTORY}  console=true
    ${package_master_path}  hran_file_operations.Get Newest File From Directory  ${SW_DIRECTORY}  *.zip
    Log  SW file path:${package_master_path}  console=true
    ${path}  ${package_master}  Split Path  ${package_master_path}
    Log  SW file:${package_master}  console=true
    Run Keyword If  '${package_master}'== ${None}
    ...  Fail  No proper SW file found in ${SW_DIRECTORY}
    Set Test Variable  ${PACKAGE_MASTER}


SW File Availability On Extension VM
    Log  Check if SW file already exists in directory:${SW_DIRECTORY} on extension VM: ${PC_IP2}  console=true
    ${status}  ${package_extension}  Run Keyword And Ignore Error
    ...  ssh.Execute  ls ${SW_DIRECTORY} | grep .zip$
    Log  Files in directory: ${package_extension}  console=true
    ${package_extension}  Strip String  ${package_extension}
    ${package_present}  Run Keyword And Return Status
    ...  Should Match  ${package_extension}  ${PACKAGE_MASTER}
    Run Keyword If  ${package_present} != ${TRUE}
    ...  Upload SW File To Extension
    Log  Remove old yaft logs on extension VM  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  rm -r /tmp/yaft_logs/
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true


Upload Swconfig To Extension
    Log  Check if swconfig exists in: ${SWCONFIG_PATH}  console=true
    OperatingSystem.File Should Exist  ${SWCONFIG_PATH}
    Log  Swich swconfig in /opt/yaft/lib/  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  sudo rm /opt/yaft/lib/swconfig.txt
    ${status}  ${msg_upload}  Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  scp ${SWCONFIG_PATH} ute@${PC_IP2}:/tmp/swconfig.txt
    Log  Return code:${msg_upload[0]}  console=true
    ${status}  ${msg_upload}  Run Keyword And Ignore Error
    ...  ssh.Execute  sudo mv /tmp/swconfig.txt /opt/yaft/lib/swconfig.txt
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true


Upload SW File To Extension
    Log  Upload SW File To Extension${\n}Remove ${SW_DIRECTORY} on extension VM  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  sudo rm -r ${SW_DIRECTORY}
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true
    Log  Create ${SW_DIRECTORY} on extension VM  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  mkdir -p ${SW_DIRECTORY}
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true
    Log  Upload SW file to extension VM  console=true
    ${status}  ${msg_upload}  Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  scp ${SW_DIRECTORY}/*.zip ute@${PC_IP2}:${SW_DIRECTORY}
    Log  Status: ${status}  console=true
    ${status_ls}  ${msg_ls}  Run Keyword And Ignore Error
    ...  ssh.Execute  ls -l ${SW_DIRECTORY}
    Run Keyword If  '${msg_upload[0]}'=='1'
    ...  Fail  msg: ${msg_upload}


Execute Yaft On Extension 1
    Log  Execute yaft on extension  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  python /opt/yaft/yaft.py -i ${ESM_IP} -z ${SW_DIRECTORY}/${PACKAGE_MASTER} -l /tmp/yaft_logs -R
    Download Yaft Log From Extension
    ssh.Assert Exit Status  0
    Log  Yaft on extension performed successfully  console=true


Execute Yaft On Extension 2
    Log  === Execute yaft on extension ===  console=true
#  sleep  100
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  python /opt/yaft/yaft.py -i ${ESM_IP} -z ${SW_DIRECTORY}/${PACKAGE_MASTER} -l /tmp/yaft_logs -R
    Download Yaft Log From Extension
    ssh.Assert Exit Status  0
    Log  Yaft on extension performed successfully  console=true


Check If ESM Is Reachable
    Log  === Check if ESM is reachable ===  console=true
    FOR  ${run}  IN RANGE  1  30
        Log  Try:${run} -> Check ping status for 192.168.255.119 and 192.168.255.129  console=true
        ${esm_ping_regain_119}  Run Keyword And Return Status
        ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=5  remote_host=${PC_IP2}
        ${esm_ping_regain_129}  Run Keyword And Return Status
        ...  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=5  remote_host=${PC_IP2}
        Return From Keyword If  ${esm_ping_regain_119} or ${esm_ping_regain_129}
    END
    Fail  ESM didn't regain ping in timeout


Execute Reboot On ESM
    Log  === Execute reboot on ESM ===  console=true
    ${vm_conn_proxy}  ssh.Connect To  ${PC_IP2}  ute  ute
    ssh.Connect To  ${ESM_IP}  toor4nsn  oZPS0POrRieRtu  proxy=${vm_conn_proxy}
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  reboot
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true
    Log  Check if ESM is not reachable  console=true
    ${esm_ping_lost}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${ESM_IP}  timeout=60  remote_host=${PC_IP2}
    Return From Keyword If  ${esm_ping_lost}
    Fail  ESM didn't lose ping


Download Yaft Log From Extension
    Log  Download yaft log from extension  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  scp ute@${PC_IP2}:/tmp/yaft_logs/*.log ${TEST_FILES}
    Log  Return code: ${msg[1]}  console=true


Check If MSM Is Reachable
    Log  Check if MSM is reachable  console=true
    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=120
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=120  timeout=700


Step12: Check If All Cells OnAir
    Log Step Header  step12: Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds.  level=INFO  console=true
#  FOR  ${run}  IN RANGE  1  300
    FOR  ${run}  IN RANGE  1  3
        ${all_cell_status}  Infomodel Check If All Objects From Path Are Online  ${DIST_CELLS}
        Run Keyword If  ${all_cell_status} == ${True}
        ...  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=true
        ...  AND
        ...  Exit For Loop
        Sleep  10
    END
    ${all_cells_onair}  Get Current Date
    Run Keyword If  ${MAKE_ADDITIONAL_CHECKS}
    ...  Ensure That BTS Remains OnAir
    Set Test Variable  ${ALL_CELLS_ONAIR}
    ${mplane_ip}  Admin Get MPLANE IP
    ${status}  Run Keyword And Return Status
    ...  Admin Check Mplane Connection  ${mplane_ip}
    Run Keyword If  ${status} != ${TRUE}
    ...  Set Test Restriction  Check mplane connection to admin failed!
    Run Keyword If  '${all_cell_status}'=='False'
    ...  Step13: Check Active Alarms
    Run Keyword If  '${all_cell_status}'=='False'
    ...  Fail  Not all cells are OnAIR.


Step13: Check Active Alarms
    Log Step Header  step13: Check active alarms
    ${critical_alarms1}  Create Dictionary  severity=Major
    ${critical_alarms2}  Create Dictionary  severity=Critical
    ${critical_patterns}  Create List  ${critical_alarms1}  ${critical_alarms2}
    ${alarms_status}  ${alarms_return}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  Major/Critical alarm found.
    Run Keyword If  ${alarms_return}
    ...  Set Test Restriction  Minor alarm found.


Check If Any Cell Is OnAir
    ${lte}  Run Keyword And Return Status
    ...  Assert Any  LNCEL  ${CELLS_LTE_EXPECTED_STATES}
    Run Keyword If  ${lte}
    ...  Return From Keyword
    ${wcdma}  Run Keyword And Return Status
    ...  Assert Any  WNCEL  ${CELLS_WCDMA_EXPECTED_STATES}
    Run Keyword If  ${wcdma}
    ...  Return From Keyword
    ${gsm}  Run Keyword And Return Status
    ...  Assert Any  GNCEL  ${CELLS_GSM_EXPECTED_STATES}
    Run Keyword If  ${gsm}
    ...  Return From Keyword
    Fail  Any cell is onAir


Ensure That BTS Remains OnAir
    Log  BTS will be checked ${ADDITIONAL_CHECKS_NUMBER} times with interval ${SLEEP_INTERVAL} if it remains onAir  console=true
    FOR  ${i}  IN RANGE  ${ADDITIONAL_CHECKS_NUMBER}
        ${is_on_air}  Verify States
        Log  BTS is onAir  console=true
        Sleep  ${SLEEP_INTERVAL}
    END


Verify States
    ${status}  ${system_modules_working}  Run Keyword And Ignore Error
    ...  Verify System Modules States
    ${status}  ${radio_modules_working}  Run Keyword And Ignore Error
    ...  Verify Radio Modules States
    Run Keyword If  ${system_modules_working} and ${radio_modules_working}
    ...  Log  Modules has the expected state!  console=true
    ...  ELSE
    ...  Fail  msg=At least one module has state other than expected

    ${status}  ${cells_gsm_onair}  Run Keyword And Ignore Error
    ...  Verify GSM Cells States
    ${status}  ${cells_wcdma_onair}  Run Keyword And Ignore Error
    ...  Verify WCDMA Cells States
    ${status}  ${cells_lte_onair}  Run Keyword And Ignore Error
    ...  Verify LTE Cells States
    Run Keyword If  ${cells_gsm_onair} and ${cells_wcdma_onair} and ${cells_lte_onair}
    ...  Log  GSM, WCDMA and LTE cells are onAir!  console=true
    ...  ELSE
    ...  Fail  msg=At least one cell has state other than expected

    ${ignored_alarms}  Create Dictionary  severity=Minor
    ${critical_alarms1}  Create Dictionary  severity=Major
    ${critical_alarms2}  Create Dictionary  severity=Critical
    ${ignored_patterns}  Create List  ${ignored_alarms}
    ${critical_patterns}  Create List  ${critical_alarms1}  ${critical_alarms2}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  ignored_patterns=${ignored_patterns}  critical_patterns=${critical_patterns}
    Run Keyword If  '${alarms_status}'!='PASS'
    ...  Fail  msg=Major alarm found.


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  tc_name=Hot_SWAP_Slave_SBTS
    # Common Test Setup  admin_launch=${FALSE}  syslog_launch=${TRUE}  infomodel_launch=${FALSE}  modules_check=${FALSE}
    # ...  cells_check=${FALSE}  alarms_check=${FALSE}  btssm_launch=${FALSE}


TC Teardown
    Common Test Teardown  collect_snapshot=never
