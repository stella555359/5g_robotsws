*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library    taf.sbts.oam.coam.admin
Library    String
Library    DateTime
Library    OperatingSystem
Library    ute_async


*** Variables ***
${TARGET_SW_NAME}    ${None}    # Target SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}     /home/ute/btsauto/TARGET_SW
#...    # Directory in which TC should look for TARGET sw package.
#...    If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}    1500
#...    # Given in seconds; That is a timeout for SW download and activation (without reset)
${BASE_SW_NAME}    ${None}
#...    # BASE SW package name. If not given, TC will choose newest package in a directory.
${BASE_SW_DIR}    /home/ute/btsauto/BASE_SW
#...    # Directory in which TC should look for BASE sw package. If not given, '/home/ute/btsauto/BASE_SW' shall be used
${FAULT_4001_TIMEOUT}    900    # How long should KW wait for reset due to fault 4001 [in seconds]
${STARTUP_TIMEOUT}    15    # timeout for smod, rmod, cells state check after fallback [min]
#${PC_IP2}    ${tl.test_pcs[1].default_ssh_connection_details.addr}   # Secondy PC IP
${restore_timeout}    4    # Timeout for cells to go OnAir after last update
${ping_loss_timeout}    480    # Timeout for ping loss during reset
${ping_regain_timeout}    240    # Timeout for ping regain during reset


*** Keywords ***
TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14850
    ...
    ...  *****************
    ...  Basic information
    ...  ********************
    ...  **Request ID:** TAT-14531
    ...  *****************
    ...  The purpose of this TC is check if SW fallback is triggered if corrupted ims file is detected
    ...  during SW activation after upgrade from previous SBTS releases.
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-14850 - TC file created, implementation started
    ...  - 30.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19488 - Fix problem with deleting cm_data.ims2
    ...  - 11.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19546 -
    ...  Change path to meta*.zip file in target package
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS
    ...    /SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.png

    Set Tags    PHASE-CRT    CA-SWM    OWNER-tomasz.zadworny@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS20    GROUP_IN_CHARGE-WRO_7_Vrf    FEATURE-CNI-24657

    Step 0: Suite configuration
    Step 1: Check active and passive SW version
    Step 2: Check BTS is onair
    Step 3: Get SW package for SW update and get META and BM
    Step 5: Start SW update and trigger fallback
    Step 6: Wait for SW fallback
    Step 7: Verify Update REQ object presence
    #Step 8: Check if LTE and NR cells are onair with cell degraded
    Step 9: SW update for ESM
    Step 10: Check SW versions after update
    #Step 11: Site reset due to fault 4001 if needed
    #Step 12: SW update for RMODs
    Step 13: Fault verification
    Step 14: Check if BTS is onair with cell degraded
    Step 15: Recover the env by upgrade different package

Step 0: Suite configuration
    [Documentation]    Short description.
    Log Step Header  Step 0: Suite configuration
    Setup hran compa  ssh_user=toor4nsn  ssh_password=oZPS0POrRieRtu
    Verify SSH connection and enable if necessary
    Remove and send new SSH key
    Check if cm_data is present and delete
    Change parameter to disconnect netact with BTS
    @{crt_alarms}    create list    4083  23  1815
    set test variable    ${crt_alarms}
    Add CRT Alarms And Initial WatchAlarm    ${crt_alarms}

Step 1: Check active and passive SW version
    [Documentation]    Short description.
    Log step header  Step 1: Check active and passive SW version
    ${ACTIVE_SW_BEFORE_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}  Infomodel Get SW Versions  module=MSM
    ${ACTIVE_SW_BEFORE_EXT}  ${PASSIVE_SW_BEFORE_EXT}  Infomodel Get SW Versions  module=ESM
    Set tags for software  SW_BEFORE_FALLBACK_MASTER  ${ACTIVE_SW_BEFORE_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}
    Set tags for software  SW_BEFORE_FALLBACK_EXTENSION  ${ACTIVE_SW_BEFORE_EXT}  ${PASSIVE_SW_BEFORE_EXT}
    Set test variable  ${ACTIVE_SW_BEFORE_MASTER}
    Set test variable  ${ACTIVE_SW_BEFORE_EXT}
    @{sw_temp}    split string    ${ACTIVE_SW_BEFORE_MASTER}    _
    ${SW_Status}    Run Keyword And Return Status    should contain    ${ACTIVE_SW_BEFORE_MASTER}    9999
    ${release}    run keyword if    ${SW_Status}==False
    ...  set variable     ${sw_temp[0]}   ELSE    set variable    SBTS00
    Set test variable  ${release}
    Set test variable  ${PASSIVE_SW_BEFORE_MASTER}

Step 2: Check BTS is onair
    [Documentation]    Short description.
    Verify BTS states

Step 3: Get SW package for SW update and get META and BM
    [Documentation]    Short description.
    Log Step Header  Step 3: Get SW package for SW update and get META and BM
    ${BASE_SW_PATH}    _Download_Specify_Build_By_Aria  ${ACTIVE_SW_BEFORE_MASTER}  Basic  ${BASE_SW_DIR}${/}
    ${sw_list}    get_enb    ${release}
    ${swbuild}    Choose Target SW build version from list for DC    ${sw_list}
    ${Target_SW_path}    _Download_Specify_Build_By_Aria  ${swbuild}  Basic  ${BASE_SW_DIR}${/}
    Run Keyword If  '${Target_SW_path}'== ${None}   Fail   msg=No SW package found!
    Set test variable  ${TARGET_SW_PATH}  ${Target_SW_path}
    Log  Chosen software package is: ${Target_SW_path}  console=${TRUE}

Step 4: Compare META and BM versions
    [Documentation]    Short description.
    Log Step Header  Step 4: Compare META and BM versions
    Log  ${\n}Will now check METAs and BMs versions in target SW package and in SW builds on active partition
    ...  console=${TRUE}
    ${meta_check}  Set variable if
    ...  '${META_ACTIVE}'=='${META_TARGET}' and '${META_RELEASE_ACTIVE}'=='${META_RELEASE_TARGET}'  ${TRUE}  ${FALSE}
    Set test variable  ${META_CHECK}  ${meta_check}
    ${is_bm_active_empty}  Run keyword and return status
    ...  Should not be empty  ${BM_ACTIVE}  'release=' in ~/bm/meta.xml is empty on active partition - please check logs
    ${is_bm_target_empty}  Run keyword and return status
    ...  Should not be empty  ${BM_TARGET}  'release=' in ~/bm/meta.xml is empty in target package - please check logs
    Run keyword if    not ${is_bm_active_empty} and ${is_bm_target_empty}  BM unavailable
    ${bm_check}  Set variable if  '${BM_ACTIVE}'=='${BM_TARGET}'  ${TRUE}  ${FALSE}
    Set test variable  ${BM_CHECK}  ${bm_check}
    BM available

Step 5: Start SW update and trigger fallback
    [Documentation]    Short description.
    Log Step Header  Step 5: Start SW update and trigger fallback
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id}  Should Match Regexp  ${run_output}  \\d
    ${passive_partition_id}  Set variable if  '${active_partition_id}'=='1'  2  1
    taf.sbts.oam.coam.admin.Run keyword in background
    ...  Update Software  sw_package=${TARGET_SW_PATH}  should_activate=True  timeout=${SW_UPDATE_TIMEOUT}
    ${distName_pattern}  Set variable  /MRBTS-1/RAT-1/URI-*/SESSION-*/SW_UPDATE_IND-*
    ${object}  Query Infomodel  get object ${distName_pattern} is [actionType="Download"]  timeout=5m
    Log  SW download started.  console=${TRUE}
    ${result}  Query Infomodel
    ...  get object ${object['dist_name']}/SW_UPDATE_RESULT-* is [result="Successful"]  timeout=30m
    Log  SW download finished.  console=${TRUE}
    Log  Wait for cm_data.ims2 file to be copied to /ffs/stb/config  console=${TRUE}
    Set Connection Parameters  192.168.255.1  user=toor4nsn  password=oZPS0POrRieRtu
    ${cm_data_path}  Wait Until Keyword Succeeds  10min  1sec
    ...  Run Remote Linux Command  find /ffs/fs${passive_partition_id}/config/cm_data.ims2
    Log  Corrupting cm_data.ims2 file  console=${TRUE}
    #Run Remote Linux Command  mount -o rw,remount /ffs/fs${passive_partition_id}
    set test variable    ${cm_data_path}
    Wait until keyword Succeeds    5s    1s   Mount And Corrupt
    Log  File cm_data.ims2 corrupted successfully  console=${TRUE}

Mount And Corrupt
    [Documentation]    Short description.
    Run Remote Linux Command  mount /ffs/fs${passive_partition_id} -o rw,remount
    Run Remote Linux Command  sed --in-place '1i CORRUPTED' ${cm_data_path}

Step 6: Wait for SW fallback
    [Documentation]    Short description.
    Log Step Header  Step 6: Wait for SW fallback
    Log  Waiting for activation reset  console=${TRUE}
    ${ping_loss}  Run keyword and return status
    ...  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status
    ...  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for ping loss  console=${TRUE}
    ${ping_loss}  Run keyword and return status
    ...  Wait for target to be not reachable  hostname=192.168.255.129  timeout=1500
    Run keyword if    not ${ping_loss}  Fail  Fallback reset was not performed.
    Log  Waiting for ping regain  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for fallback reset  console=${TRUE}
    ${ping_loss}  Run keyword and return status
    ...  Wait for target to be not reachable  hostname=192.168.255.129  timeout=900
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status
    ...  Wait for target to be reachable  hostname=192.168.255.129  timeout=360
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=240  max_downtime=600  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after fallback.
    Log  BTS is stable after fallback.  console=${TRUE}
    ${admin_working_state}  Run keyword and return status
    ...  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/of infomodel failure after reset. Interface reset did not help.
    Log  Check active and passive SW version
    ${ACTIVE_SW_AFTER_MASTER}  ${PASSIVE_SW_AFTER_MASTER}  Infomodel Get SW Versions  module=MSM
    Set tags for software  SW_AFTER_FALLBACK_MASTER  ${ACTIVE_SW_AFTER_MASTER}  ${PASSIVE_SW_AFTER_MASTER}
    Set test variable  ${ACTIVE_SW_AFTER_MASTER}
    Check if software match software pattern  ${ACTIVE_SW_AFTER_MASTER}  ${ACTIVE_SW_BEFORE_MASTER}
    ${faults_active}  Run keyword and return status
    ...  Wait Until Keyword Succeeds  360 sec  30 sec  Check If Critical 23 and Major 4083 faults are present on ESM
    Run keyword if  ${faults_active}
    ...  Log  Fault 4083 with severity 'Major' and fault 23 with severity 'Critical' is present  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Fault 4083 with severity 'Major' and/or fault 23 with severity 'Critical' is not present
    ...  AND
    ...  Log  Fault 4083 with severity 'Major' and/or fault 23 with severity 'Critical' is not present  console=${TRUE}

Step 7: Verify Update REQ object presence
    [Documentation]    Short description.
    Log Step Header  Step 7: Verify Update REQ object presence
    ${query_status}  Run keyword and return status
    ...  Query Infomodel  /MRBTS-1/RAT-1/URI-*/SW_UPDATE_NTF_REQ-*  timeout=1m
    Run keyword if  ${query_status}  Log  Object SW_UPDATE_NTF_REQ was created...  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Log  [restriction] Object SW_UPDATE_NTF_REQ was not found...  console=${TRUE}
    ...  AND
    ...  Set test restriction  Object SW_UPDATE_NTF_REQ was not found...

Step 8: Check if LTE and NR cells are onair with cell degraded
    [Documentation]    Short description.
    Log step header  Step 8: Check if LTE and NR cells are onair with cell degraded
    sleep    10min
    ${cells_status}=  Verify cells states  Check if LTE and NR cells degraded
    Run keyword if  ${cells_status}
    ...  Log  ${\n}All cells operationalState is 'Enabled'  console=${True}
    ...  ELSE
    ...  Fail  Not all cells operationalState is 'Enabled'. Check logs cells_status=${cells_status}

Step 9: SW update for ESM
    [Documentation]    Short description.
    Log Step Header  Step 9: SW update for ESM
    #sleep    600
    Log  Checking if SW in ${BASE_SW_DIR} is the same as active SW on MSM...  console=${TRUE}
    ${active_sw_pattern}
    ...  Get regexp matches  ${ACTIVE_SW_AFTER_MASTER}  SBTS[0-9][0-9][A-Z][0-9]?_(\\S{3}_\\d{4}_\\d{6}_\\d{6})
    ${sw_file_list}  OperatingSystem.List Files In Directory  ${BASE_SW_DIR}  *${active_sw_pattern}*
    Should not be empty  ${sw_file_list}  Required package not present in ${BASE_SW_DIR}
    FOR  ${file}  IN  @{sw_file_list}
        ${file_path}  Join path  ${BASE_SW_DIR}  ${file}
        ${sw}  Get TargetBD Node Attribute Value  buildDescriptorId  ${file_path}
        ${match_sw}  Run keyword and return status  Should be equal  ${ACTIVE_SW_AFTER_MASTER}  ${sw}
        Run keyword if  ${match_sw}  Run keywords  Set test variable  ${BASE_SW_PATH}  ${file_path}
        ...  AND  Exit For Loop
    END
    Should not be empty  ${BASE_SW_PATH}  Required package not present in ${BASE_SW_DIR}
    OperatingSystem.File should exist  ${BASE_SW_PATH}
    Log  SW build to update: ${BASE_SW_PATH}  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  sw_package=${BASE_SW_PATH}
    ...  should_activate=${TRUE}  timeout=${SW_UPDATE_TIMEOUT}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ...  ELSE  Log  SW update on ESM finished.  console=${TRUE}
    ${master_reachable}  ${slave_ping_lost}  ${slave_ping_regain}  Check if only slave will begin reset
    ...   ping lost timeout=150    ping recovery timeout=420    master ip=192.168.255.129    slave ip=192.168.255.119
    Run keyword if  ${master_reachable} and ${slave_ping_lost}
    ...  Log  Only ESM reset performed after SW update on ESM  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Set test failed  All BTS reset performed after SW update on ESM
    ...  AND
    ...  Log  All BTS reset performed after SW update on ESM  console=${TRUE}
    Log  Check if ESM is stable after SW update  console=${TRUE}
    ${ping_status}  Check If Target Is Stable
    ...  ip=192.168.255.119  min_uptime=180  max_downtime=240  timeout=900
    ...  remote_host=${tl.test_pcs[1].default_ssh_connection_details.addr}
    Run keyword if  ${ping_status}  Log  ESM is stable after SW update  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Log  ESM is not stable after SW update  console=${TRUE}
    ...  AND
    ...  Set test failed  ESM is not stable after SW update

Step 10: Check SW versions after update
    [Documentation]    Short description.
    Log Step Header  Step 10: Check SW versions after update
    ${active_sw_after_ext}  ${passive_sw_after_ext}  Infomodel Get SW Versions  module=ESM
    Log  Active SW on ESM: ${active_sw_after_ext}  console=${TRUE}
    Log  Passive SW on ESM: ${passive_sw_after_ext}  console=${TRUE}
    Check if software match software pattern  ${active_sw_after_ext}  ${ACTIVE_SW_BEFORE_EXT}

Step 11: Site reset due to fault 4001 if needed
    [Documentation]    Short description.
    Log Step Header  Step 11: Site reset due to fault 4001 if needed
    Log  Checking if GSM and/or WCDMA is deployed on ESM  console=${TRUE}
    ${GSM_esm}  Checking if GSM on ESM
    Log  GSM cells on ESM: ${GSM_esm}  console=${TRUE}
    ${WCDMA_esm}  Checking if WCDMA on ESM
    Log  WCDMA cells on ESM: ${WCDMA_esm}  console=${TRUE}
    ${is_WCDMA_or_GSM_on_ESM}  Set variable if  ${GSM_esm} or ${WCDMA_esm}  ${TRUE}  ${FALSE}
    Set test variable  ${IS_WCDMA_OR_GSM_ON_ESM}  ${is_WCDMA_or_GSM_on_ESM}
    ${autoreset_configured}  Run keyword if  ${IS_WCDMA_OR_GSM_ON_ESM}  Check if autoreset is configured
    Set test variable  ${AUTORESET_CONFIGURED}  ${autoreset_configured}
    ${reset_triggered}  Run keyword if  ${IS_WCDMA_OR_GSM_ON_ESM} and not ${AUTORESET_CONFIGURED}
    ...  Run Keyword And Return Status  Wait until keyword succeeds  ${FAULT_4001_TIMEOUT} sec  30 sec  Check fault 4001
    ...  ELSE IF  ${IS_WCDMA_OR_GSM_ON_ESM} and ${AUTORESET_CONFIGURED}
    ...  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.129  timeout=${FAULT_4001_TIMEOUT}
    Run keyword if  ${IS_WCDMA_OR_GSM_ON_ESM}  Check if BTS is stable after reset

Step 12: SW update for RMODs
    [Documentation]    Short description.
    Log Step Header  Step 12: SW update for RMODs
    ${is_fault_23_on_RMODs}  Run keyword and return status
    ...  Wait Until Keyword Succeeds  360 sec  30 sec  Check If Fault 23 is present on RMODs
    Run keyword if  ${is_fault_23_on_RMODs}  Sw update on RMODs
    ...  ELSE
    ...  Log  Fault 23 on RMODs is not present (SW update is not needed)  console=${TRUE}
    ${reset_triggered}  Run keyword if  ${IS_WCDMA_OR_GSM_ON_ESM} and not ${AUTORESET_CONFIGURED}
    ...  Run Keyword And Return Status  Wait until keyword succeeds  ${FAULT_4001_TIMEOUT} sec  30 sec  Check fault 4001
    ...  ELSE IF  ${IS_WCDMA_OR_GSM_ON_ESM} and ${AUTORESET_CONFIGURED}
    ...  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.129  timeout=${FAULT_4001_TIMEOUT}
    Run keyword if  ${IS_WCDMA_OR_GSM_ON_ESM}  Check if BTS is stable after reset

Step 13: Fault verification
    [Documentation]    Short description.
    Log Step Header  Step 13: Fault verification
    Wait Until Keyword Succeeds  15min  30sec  Check faults after fallback

Step 14: Check if BTS is onair with cell degraded
    [Documentation]    Short description.
    Log step header  Step 14: Check if BTS is onair with cell degraded
    Log  ${\n}Checking cells operationalState...  console=${True}
    sleep    360
    ${cells_status}=  Verify cells states  Check if cells degraded
    Wait until keyword succeeds  10min  30 sec    Run keyword if  ${cells_status}
    ...  Log  ${\n}All cells operationalState is 'Enabled'  console=${True}
    ...  ELSE
    ...  Fail  Not all cells operationalState is 'Enabled'. Check logs cells_status=${cells_status}

Step 15: Recover the env by upgrade different package
    [Documentation]    Short description.
    Change parameter to connect netact with BTS
    recover env to clear 4082 by upgrade differ sw
    check BTS is onair after update to tested software

Sw update on RMODs
    [Documentation]    Short description.
    Log  Start SW update on RMODs...  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software
    ...  sw_package=${BASE_SW_PATH}  should_activate=${TRUE}  timeout=${SW_UPDATE_TIMEOUT}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    Log  Wait until all rmods are available  console=${TRUE}
    Wait until keyword succeeds  10 min  30 sec  Check if all RMODs are available

Check if all RMODs are available
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Assert Every    RMOD    availabilityStatus!=regex"NotInstalled|Offline"
    ${scf_rmods}           Get Radios
    ${scf_count_rmods}     Get length  ${scf_rmods}
    ${runtime_rmods}       taf.sbts.oam.coam.admin.Get ids for all  RMOD
    ${final_status}        Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run keyword if    not ${final_status}  Fail  Not all radio modules are available

Check faults after fallback
    [Documentation]    Short description.
    ${EXPECTED_ALARM1}     Create Dictionary  faultId=4083  severity=Major
    ${EXPECTED}            Create List  ${EXPECTED_ALARM1}
    ${CRITICAL_ALARM1}     Create Dictionary  severity=Major|Critical
    ${CRITICAL}            Create List  ${CRITICAL_ALARM1}
    Admin Check Active Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}

Check if autoreset is configured
    [Documentation]    Short description.
    Log  Check if autoreset is configured  console=${TRUE}
    taf.sbts.oam.coam.admin.Collect Scf  export_type=configuration  target_file_name=${TestFiles}/SCF_after_fallback.xml  timeout=180
    Log  SCF has been saved under ${TestFiles}/SCF_after_fallback.xml  console=${TRUE}
    Log  Will check if 'actForceAutoReset' and 'actForceUnitAutoReset' are set to 'True'  console=${TRUE}
    ${actForceAutoReset}  XML.Get Element Text  ${TestFiles}/SCF_after_fallback.xml  .//p[@name="actForceAutoReset"]
    ${actForceUnitAutoReset}
    ...  XML.Get Element Text  ${TestFiles}/SCF_after_fallback.xml  .//p[@name="actForceUnitAutoReset"]
    Run keyword if  '${actForceAutoReset}'=='True' and '${actForceUnitAutoReset}'=='True'  Run keywords
    ...  Log  'actForceAutoReset' and 'actForceUnitAutoReset' are set to 'True'  console=${TRUE}
    ...  AND
    ...  Return from keyword  ${TRUE}
    ...  ELSE  Run keywords
    ...  Log  'actForceAutoReset' and/or 'actForceUnitAutoReset' are not set to 'True'  console=${TRUE}
    ...  AND
    ...  Return from keyword  ${FALSE}

Check if BTS is stable after reset
    [Documentation]    Short description.
    Log  Check if ping has been regained after BTS reset  console=${TRUE}
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=420
    Run keyword if  ${ping_regain_status}  Log  BTS is reachable after reset  console=${TRUE}
    ...  ELSE  Fail  BTS is not reachable after reset
    Log  Check if target is stable after reset  console=${TRUE}
    Check If Target Is Stable  192.168.255.129

Check If Critical 23 and Major 4083 faults are present on ESM
    [Documentation]  Return TRUE if Critical 23 and Major 4083 faults are active on BTS
    @{active_alarms} =  taf.sbts.oam.coam.admin.Get Active Alarms
    Set test variable  ${FAULT_23_PRESENT}  ${FALSE}
    Set test variable  ${FAULT_4083_PRESENT}  ${FALSE}
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=${TRUE}
        ${notifier_is_smod}  Run keyword and return status  should contain  ${alarm.notifier}  SMOD_R
        ${FAULT_23_PRESENT}  Set Variable If
        ...  '${alarm.faultId}'=='23' and '${alarm.severity}'=='Critical' and ${notifier_is_smod}  ${TRUE}  ${FAULT_23_PRESENT}
        ${FAULT_4083_PRESENT}  Set Variable If
        ...  '${alarm.faultId}'=='4083' and '${alarm.severity}'=='Major' and ${notifier_is_smod}  ${TRUE}  ${FAULT_4083_PRESENT}
        Run Keyword If  ${FAULT_23_PRESENT} and ${FAULT_4083_PRESENT}  Return From Keyword  ${TRUE}
    END
    Fail  Fault 4083 with severity 'Major' and/or fault 23 with severity 'Critical' is not present

Checking if GSM on ESM
    [Documentation]    Short description.
    ${object_parameter}  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-4/BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*
    ...  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      Run keyword if  ${status}  Return from keyword  ${TRUE}
    END
    Return from keyword  ${FALSE}

Checking if WCDMA on ESM
    [Documentation]    Short description.
    ${object_parameter}  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-4/BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*
    ...  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      Run keyword if  ${status}  Return from keyword  ${TRUE}
    END
    Return from keyword  ${FALSE}

BM available
    [Documentation]    Short description.
    ${log_2}=    Catenate    METAs and BMs releases of passive and active SW are the same${\n}TC:
    ...  SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_inconsistent_IM_sync_successful should be run instead
    Run keyword if  ${META_CHECK}==${TRUE} and ${BM_CHECK}==${TRUE}   Set test norun
    ...  ${log_2}
    ...  fail_test=${False}
    ...  ELSE IF  ${META_CHECK}==${TRUE} and ${BM_CHECK}==${FALSE}
    ...  Log  METAs of target and active SW are the same, but BM releases are different, consistent fallback is possible
    ...     console=${TRUE}
    ...  ELSE IF  ${META_CHECK}==${FALSE}
    ...  Log  METAs of target and active SW are the different, consistent fallback is possible  console=${TRUE}

BM unavailable
    [Documentation]    Short description.
    Set test restriction  Unable to get BM release (==MAIN or EMPTY) - CHECK LOGS!!
    Log Important Message  Set test restriction - Unable to get BM release (==MAIN or EMPTY) - CHECK LOGS!!
    ${log_3}=    Catenate    METAs of target and active SW are the same${\n}TC:
    ...  SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_inconsistent_IM_sync_successful should be run instead
    Run keyword if  ${META_CHECK}==${TRUE}  Set test norun
    ...  ${log_3}
    ...  fail_test=${False}
    ...  ELSE IF  ${META_CHECK}==${FALSE}
    ...  Log  METAs of target and active SW are the different, consistent fallback is possible  console=${TRUE}

Join spanned zip file
    [Documentation]    Short description.
    Log  Will join spanned meta zip file  console=${TRUE}
    Run Local Linux Command  cat ${TestFiles}/meta/meta_target/meta*.zip > ${TestFiles}/meta/meta_target/meta_target.zip

Check If Fault 23 is present on RMODs
    [Documentation]  If active alarm exists and is Critical return True otherwise return False
    @{active_alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=${TRUE}
        ${expected_notifier}  Run keyword and return status  Should contain  ${alarm.notifier}  RMOD_R
        Run Keyword If  '${alarm.faultId}'=='23' and ${expected_notifier}
        ...  Return From Keyword  ${TRUE}
    END
    Fail  Fault 23 is not present on any RMOD

Check fault 4001
    [Documentation]    Short description.
    Log  Will check if fault 4001 is visible  console=${TRUE}
    ${fault_4001}  Run Keyword And Return Status  Check SOAM Active Alarms  expected_fault=4001  ignored_fault=.*
    Run keyword if  not ${fault_4001}  Fail  Fault 4001 is not present
    Log  Resetting site from admin  console=${TRUE}
    ${reset_status}  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Reset Site
    Run keyword if  not ${reset_status}  Fail  BTS reset due to 4001 failed
    ${ping_loss_status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.129  timeout=360

Check if cm_data is present and delete
    [Documentation]    Short description.
    Log  Check if cm_data.ims2 file is present in /ffs/stb/config or in /ffs/stb/config and delete if present
    ...  console=${TRUE}
    Set Connection Parameters  192.168.255.129  user=toor4nsn  password=oZPS0POrRieRtu
    ${status}  ${cm_data_path}  Run keyword and ignore error
    ...  Run Remote Linux Command  find /ffs/run/config/cm_data.ims2
    Run keyword if  '${status}'=='PASS'  Delete cm_data  ${cm_data_path}
    ...  ELSE  Log  cm_data.ims2 not found in /ffs/run/config/  console=${TRUE}
    ${status}  ${cm_data_path}  Run keyword and ignore error
    ...  Run Remote Linux Command  find /ffs/stb/config/cm_data.ims2
    Run keyword if  '${status}'=='PASS'  Delete cm_data  ${cm_data_path}
    ...  ELSE  Log  cm_data.ims2 not found in /ffs/stb/config/  console=${TRUE}

Delete cm_data
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cm_data_path}: <description>
    [Arguments]  ${cm_data_path}
    ${run_output}  Run Remote Linux Command  uboot_env get | grep active_partition
    ${active_partition_id}  Should Match Regexp  ${run_output}  \\d
    ${passive_partition_id}  Set variable if  '${active_partition_id}'=='1'  2  1
    ${remount_status}  Run keyword and return status
    ...  Run Remote Linux Command  mount -o remount,rw /ffs/fs${passive_partition_id}
    ${delete_status}  Run keyword if  ${remount_status}
    ...  Run keyword and return status  Run Remote Linux Command  rm -f ${cm_data_path}
    Run keyword if  ${delete_status}  Log  cm_data.ims2 file successfully deleted  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Log  cm_data.ims2 file not deleted  console=${TRUE}
    ...  AND
    ...  Set test restriction  cm_data.ims2 file not deleted
    set test variable    ${passive_partition_id}

Choose Target SW build version from list for DC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_list}: <description>
    ...
    ...    Returns:
    ...        ${sw_build}: <description>
    [Arguments]    ${sw_list}
    set test variable    ${SW_list_1}    ${sw_list[-9]}
    set test variable    ${SW_list_2}    ${sw_list[-5]}
    set test variable    ${SW_list_3}    ${sw_list[-1]}
    ${SW_Status}    Run Keyword And Return Status    should contain    ${PASSIVE_SW_BEFORE_MASTER}     9999
    ${PASSIVE_SW_BEFORE_MASTER}    Run Keyword If    ${SW_Status}==True
    ...  Replace String Using Regexp    ${PASSIVE_SW_BEFORE_MASTER}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set Variable    ${PASSIVE_SW_BEFORE_MASTER}
    ${SW_Status}    Run Keyword And Return Status    should contain    ${ACTIVE_SW_BEFORE_MASTER}    9999
    ${ACTIVE_SW_BEFORE_MASTER}    Run Keyword If    ${SW_Status}==True
    ...  Replace String Using Regexp    ${ACTIVE_SW_BEFORE_MASTER}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set Variable    ${ACTIVE_SW_BEFORE_MASTER}
    ${sw_temp}    split string    ${ACTIVE_SW_BEFORE_MASTER}    _
    ${Release_Num}    Run Keyword If    ${SW_Status}==True    Set Variable    SBTS00
    ...    ELSE    Set Variable    ${sw_temp[0]}
    ${sw_build}    Run Keyword If
    ...  '${SW_list_3}'!='${PASSIVE_SW_BEFORE_MASTER}' and '${SW_list_3}'!='${ACTIVE_SW_BEFORE_MASTER}'
    ...  Set Variable    ${SW_list_3}
    ...    ELSE IF    '${SW_list_2}'!='${PASSIVE_SW_BEFORE_MASTER}' and '${SW_list_2}'!='${ACTIVE_SW_BEFORE_MASTER}'
    ...  Set Variable    ${SW_list_2}
    ...    ELSE    Set Variable    ${SW_list_1}
    Set Suite Variable    ${sw_build}
    Set Suite Variable    ${Release_Num}
    [Return]    ${sw_build}    #${sw_build_path}

recover env to clear 4082 by upgrade differ sw
    [Documentation]    Short description.
    ${active_sw_bef_rec}  ${passive_sw_bef_rec}=  Infomodel Get SW Versions  module=MSM
    ${active_sw_bef_rec}    run keyword if    '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${active_sw_bef_rec}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${active_sw_bef_rec}
    ${passive_sw_bef_rec}    run keyword if    '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${passive_sw_bef_rec}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${passive_sw_bef_rec}
    ${sw_rec_path}=    Get upgrade path    ${active_sw_bef_rec}    ${passive_sw_bef_rec}
    ...  ${release_list_1}    ${release_list_2}    ${release_list_3}
    ${sw_rec}=    Common_Find SW name    ${sw_rec_path}
    taf.sbts.oam.coam.admin.update software    ${sw_rec}    True    ${SW_UPDATE_TIMEOUT}

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}  OperatingSystem.List files in directory  ${SW_PATH}
    should not be empty  ${package name}  Required package not present in ${SW_PATH}
    ${SW_PATH_package}=  Join Path 	${SW_PATH}  ${package name[0]}
    OperatingSystem.File should exist  ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=900
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=300
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}   min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait until keyword succeeds  15 min  30 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

Check if cells degraded
    [Documentation]    Short description.
    ${cells_GSM_onair}=  Verify cells  GSM
    ...  expected_states=availabilityStatus=${_Degraded},usageState=Active  scf_check=${scf_parser_started}
    ${cells_WCDMA_onair}=  Verify cells  WCDMA
    ...  expected_states=availabilityStatus=${_Degraded}, usageState=Active  scf_check=${scf_parser_started}
    ${cells_LTE_onair}=   Verify cells  LTE
    ...  expected_states=availabilityStatus=${_Degraded}, blockingState=Unblocked  scf_check=${scf_parser_started}
    ${cells_NR_onair}=  Verify cells  NR
    ...  expected_states=availabilityStatus=${_Degraded}, blockingState=Unblocked   scf_check=${scf_parser_started}
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair}
    ...  Fail  GSM:${cells_GSM_onair} WCDMA:${cells_WCDMA_onair} LTE:${cells_LTE_onair} NR:${cells_NR_onair}

Check if LTE and NR cells degraded
    [Documentation]    Short description.
    ${cells_LTE_onair}=   Verify cells  LTE
    ...  expected_states=availabilityStatus=${_Degraded}, blockingState=Unblocked  scf_check=${scf_parser_started}
    ${cells_NR_onair}=  Verify cells  NR
    ...  expected_states=availabilityStatus=${_Degraded}, blockingState=Unblocked   scf_check=${scf_parser_started}
    Run keyword if    not ${cells_LTE_onair} and ${cells_NR_onair}
    ...  Fail  LTE:${cells_LTE_onair} NR:${cells_NR_onair}

Verify cells states
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cells_state_check}: <description>
    ...
    ...    Returns:
    ...        ${cells_state}: <description>
    [Arguments]  ${cells_state_check}
    ${cells_state}=  Run keyword and return status
    ...  Wait Until Keyword Succeeds  ${restore_timeout}  5s  ${cells_state_check}
    [Return]  ${cells_state}

TC_Custom Teardown
    [Documentation]    Short description.
    TC Teardown
    Change parameter to connect netact with BTS
