*** Settings ***
Documentation
    ...  Main purpose of TC is checking fallback functionality of SBTS SW in dual core configuration:
    ...  fallback from SBTS_SOAM to SBTS_SOAM

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SW_PACKAGE_PATH}  /home/ute/btsauto/BASE_SW  # Direct path to directory where desired sw package is stored,
# should be the same as passive SW before fallback
${SW_UPDATE_TIMEOUT}  1000  # Given in seconds; That is a timeout for SW download and activation (without reset)
${BTS_IS_BUSY_TIMEOUT_FOR_SWR_SLAVE}  900  # Timeout for PR596873-SW update on ESM via loader after fallback failed with Download failed,
# BTS is busy
${PING_LOSS_TIMEOUT}  240  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${RESTORE_TIMEOUT}  240  # Timeout for cells to go OnAir after last update
${ESM_IP}  192.168.255.119  # ESM trs ip
${FAULT_4001_TIMEOUT}  15  # How long should KW wait for fault 4001 [in minutes]
${RECOVERY_TIMEOUT}  601
${SKIP_META_CHECK}  False  # If is set True the meta check will be skipped
${SKIP_BM_CHECK}  False  # If is set True the bm check will be skipped
${PING_STABLE_TIMEOUT}  401  # Timeout for ping until target is stable
${SECOND_RESET_AFTER_FALLBACK_TIMEOUT}  650  # Timeout for second reset after fallback


*** Keywords ***
TC__SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.05.2018 - TC file created, implementation started
    ...  - 10.09.2018 - TAT-12126 Set test norun changed to Set test blocked in META check
    ...  - 24.12.2018 - TAT-13071 Info about active Fault 4082 added when minor faults present on BTS
    ...  - 27.12.2018 - TAT-13802
    ...  - 19.03.2019 - TAT-14934
    ...  - 18.04.2019 - TAT-15093 COMPA - DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC failed with MSM is not stable after update on ESM.
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 15.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-15468 - Adds checking BM release for DC fallbacks SBTS
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17980 - Changes timeout for fault 4001 and adds this timeout to Variables
    ...  - 08.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18645 - Adds reset connection to admin and infomodel after fallback
    ...  - 27.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18888 - Fix problem with duplicated KW names
    ...  - 06.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-18664 - Adds support for reset due to fault 4001
    ...  - 04.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23829 - Fix problem for SBTS cells state
    ...  - 23.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24344 - Fix problems for checking meta versions
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  - 14.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-25480 - Fix arguments
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27302 - Add skip option for meta and bm check
    ...  - 12.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27419 - Accept fid 23 as Warning or Critical
    ...  - 25.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27481 - Fix for ASIL smod
    ...  - 24.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28097 - Accept fid 23 as Minor or Major
    ...  - 22.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28483 - Add FID 23 check at test end
    ...  - 23.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30404 - Fix BTS stable check for both reboots
    ...  - 11.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30507 - Fix missing global variable
    ...  - 18.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30540 - Fix pattern check for active and passive sw
    ...  - 27.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30569 - Add timeout variable for second reset after fallback
    ...  - 01.04.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30694 - Add watchdog alarms
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-9883.png

    Set Tags  PHASE-COMPA  CA-SWM  OWNER-dominik.jesariew@nokia.com  AUTHOR-wojciech.sikora@nokia.com  SW-SBTS17  MAINTAINER-iasmin.tomici@nokia.com
    ...  SW-SBTS18  SW-SBTS18SP  SW-SBTS18A  SW-SBTS19  FEATURE-RP000938  FEATURE-RP001498  FEATURE-RP001621

    Step 0: Suite Configuration
    Step 1: Check Active And Passive Sw Version
    Step 2: Software Fallback
    Step 3: Wait Till BTS Is Stable
    Step 4: Check Sw After Fallback
    Step 5: Find SW Name And Path
    Step 6: SW Update On ESM Via MSM
    Step 7: Fault 23 Verification
    Step 8: RMODs SW Update For ESM
    Step 9: Fault 4082 Verification
    Step 10: Check Alarms And States After Fallback
    Step 11: Log All Active Alarms During The Test


Step 0: Suite Configuration
    Log Step Header  Step 0: Suite configuration
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Set Test Variable  ${ACTIVE_SW_PATTERN}  SBTS\\d{2}
    Set Test Variable  ${PASSIVE_SW_PATTERN}  SBTS\\d{2}
    Verify SSH Connection And Enable If Necessary
    IF  ${SKIP_META_CHECK}==${TRUE}
        ${meta_check}  Set Variable  False
    ELSE
        ${meta_check}  Check If Metas Versions On Passive And Active Are The Same
    END
    IF  ${SKIP_BM_CHECK}==${TRUE}
        ${bm_check}  Set Variable  False
    ELSE
        ${bm_check}  Check BM Release
    END
    Set Test Variable  ${META_CHECK}  ${meta_check}
    Set Test Variable  ${BM_CHECK}  ${bm_check}
    IF  '${BM_CHECK}'=='release_is_empty'
        BM Unavailable
    ELSE
        BM Available
    END
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
    Check If Software Match Software Pattern  ${active_sw_before_master}  ${ACTIVE_SW_PATTERN}
    Check If Software Match Software Pattern  ${passive_sw_before_master}  ${PASSIVE_SW_PATTERN}
    Check If Software Match Software Pattern  ${active_sw_before_ext}  ${ACTIVE_SW_PATTERN}
    Check If Software Match Software Pattern  ${passive_sw_before_ext}  ${PASSIVE_SW_PATTERN}
    Set Test Variable  ${ACTIVE_SW_BEFORE_MASTER}
    Set Test Variable  ${PASSIVE_SW_BEFORE_MASTER}
    Set Test Variable  ${ACTIVE_SW_BEFORE_EXT}
    Set Test Variable  ${PASSIVE_SW_BEFORE_EXT}


Step 2: Software Fallback
    Log Step Header  Step 2: Software fallback
    Log  Checking hardware version  console=true
    ${sm_variant}  Get SM Variant
    Software Fallback  ${sm_variant[0]}


Step 3: Wait Till BTS Is Stable
    Log Step Header  Step 3: Wait till BTS is stable
    Log  Wait For Target To Be Reachable  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  ${SMOD1['TRS_IP']}
    IF  ${status}
        Log  BTS is reachable!  console=true
    ELSE
        Fail  BTS not reachable after reboot.
    END
    Log  Wait For Reset  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${SECOND_RESET_AFTER_FALLBACK_TIMEOUT}
    IF  ${status}
        Log  Software reset was performed!  console=true
    ELSE
        Set Test Restriction  Software reset was not performed.
    END
    Log  Wait For Target To Be Reachable after Reset  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  ${SMOD1['TRS_IP']}  timeout=360
    IF  ${status}
        Log  BTS is reachable after reset.  console=true
    ELSE
        Fail  BTS not reachable after reset.
    END
    Log  Check If Target Is Stable  console=true
    Sleep  ${RECOVERY_TIMEOUT}
    ${ping_status}  Run Keyword And Return Status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=360  timeout=${PING_STABLE_TIMEOUT}
    IF  ${ping_status}
        Log  BTS is stable after fallback.  console=true
    ELSE
        Fail  BTS is not stable after fallback.
    END
    ${admin_working_state}  Run Keyword And Return Status
    ...  sbts_admin.Admin And Infomodel Connections Reset  reset_req=${TRUE}
    IF  ${admin_working_state}
        Log  Admin and infomodel are ok after reset!  console=true
    ELSE
        Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=true
    END


Step 4: Check Sw After Fallback
    Log Step Header  Step 4: Check sw after fallback
    Sleep  300
    ${active_sw_after_master}  ${passive_sw_after_master}  Infomodel Get SW Versions  module=MSM
    Set Test Variable  ${ACTIVE_SW_AFTER_MASTER}
    Set Tags For Software  SW_AFTER_FALLBACK_MASTER  ${ACTIVE_SW_AFTER_MASTER}  ${passive_sw_after_master}
    Check If Software Match Software Pattern  ${ACTIVE_SW_AFTER_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}
    Check If Software Match Software Pattern  ${passive_sw_after_master}  ${ACTIVE_SW_BEFORE_MASTER}
    Log  Active SW after fallback is correct on MSM console=true
    ${incom_sw_esm}  Check If Fault 23 Present On ESM
    IF  '${incom_sw_esm}'=='${False}'
        Fail  No fault 23 on ESM or Fault severity is not 'Critical'
    ELSE
        Log  Fault 23 present on ESM. Will now install SW on ESM  console=true
    END


Step 5: Find SW Name And Path
    [Documentation]    Search for newest SBTS software package in dedicated directory

    Log Step Header  Step 5: Find SW name and path
    Log  Checking if chosen SW is the same as active SW on MSM...  console=true
    ${active_sw_pattern_from_path}  Get Regexp Matches  ${ACTIVE_SW_AFTER_MASTER}  \\S+_(\\S+_\\S+_\\S+_\\S+)  1
    ${package_name}  OperatingSystem.List Files In Directory  ${SW_PACKAGE_PATH}  *${active_sw_pattern_from_path[0]}*
    Should Not Be Empty  ${package_name}  Required package not present in ${SW_PACKAGE_PATH}
    ${sw_path}  Join Path  ${SW_PACKAGE_PATH}  ${package_name[0]}
    OperatingSystem.File Should Exist  ${sw_path}
    Set Global Variable  ${SW_PATH}
    Log  SW package found at: ${SW_PATH}  console=true


Step 6: SW Update On ESM Via MSM
    Log Step Header  Step 6: SW update on ESM via MSM
    Sleep  ${BTS_IS_BUSY_TIMEOUT_FOR_SWR_SLAVE}
    Log  Will now perform software update on ESM  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  coam.Update Software  ${SW_PATH}  True  ${SW_UPDATE_TIMEOUT}
    IF  '${sw_update_result}'=='FAIL'  Fail  Software update failed: ${sw_update_msg}
    IF  ${GSM_ESM} or ${WCDMA_ESM}
        Post Update Ping Check With 2G Or 3G Cells On ESM
    ELSE
        Post Update Ping Check Without 2G Or 3G Cells On ESM
    END
    Wait Until Keyword Succeeds  5 min  10 sec
    ...  Fail If Connection With Admin Is Not Available
    Log  ${\n}${\n}Checking if fault23 is cleared from ESM...  console=true
    Wait Until Keyword Succeeds  5 min  10 sec
    ...  Check If Fault 23 Cleared On SMOD


Step 7: Fault 23 Verification
    Log Step Header  Step 7: Fault 23 for RMOD verification
    Log  Waiting for fault 23 on RMODs...  console=true
    FOR  ${run}  IN RANGE  1  150
        ${is_fault_active_rmod}  Check If Fault 23 Present
    END
    Set Test Variable  ${IS_FAULT_ACTIVE_RMOD}
    Log  Fault 23 For RMOD active: ${IS_FAULT_ACTIVE_RMOD}  console=true


Step 8: RMODs SW Update For ESM
    Log Step Header  Step 8: RMODs SW update for ESM
    IF  ${IS_FAULT_ACTIVE_RMOD}==${FALSE}
        Log  SW update for RMODs not needed (No faults 23 detected on ESM)  console=true
    ELSE
        SW Update For RMODs
    END
    Wait Until Keyword Succeeds  5min  15sec
    ...  Check If Fault 23 Present After Update
    Log  Fault 23 on RMODs cleared  console=true
    Log  Check if BTS is resetting due to fault 4001  console=true
    ${reset_due_to_4001}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
    IF  not ${reset_due_to_4001}
        ${4001_is_active}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  10 min  15 s  Check Fault 4001 After Update
    END
    IF  ${4001_is_active}  Reset After 4001


Step 9: Fault 4082 Verification
    Log Step Header  Step 9: Fault 4082 verification
    ${expected_alarm1}  Create Dictionary  faultId=${FAULT_4082}[fault_id]  severity=${FAULT_4082}[severity]
    ${expected}  Create List  ${expected_alarm1}
    ${critical_alarm1}  Create Dictionary  severity=Major|Critical
    ${critical}  Create List  ${critical_alarm1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  critical_patterns=${critical}
    IF  '${alarms_status}'=='FAIL'
        Fail  No Fault 4082 with Major severity found or other Major|Critical occured
    ELSE IF  ${alarms_msg}
        Set Test Restriction  Fault 4082 active on BTS with severity=Major, but some minor faults found: ${alarms_msg}
    ELSE
        Log  Alarm with Fault 4082 active on BTS with severity=Major. No other active alarms.  console=true
    END


Step 10: Check Alarms And States After Fallback
    Log Step Header  Step 10: Check if active sw is commisioned
    ${active_sw_after_ext}  ${passive_sw_after_ext}  Infomodel Get SW Versions  module=ESM
    Set Tags For Software  SW_AFTER_FALLBACK_EXTENSION  ${active_sw_after_ext}  ${passive_sw_after_ext}
    Check If Software Match Software Pattern  ${active_sw_after_ext}  ${PASSIVE_SW_BEFORE_EXT}
    Check If Software Match Software Pattern  ${passive_sw_after_ext}  ${ACTIVE_SW_BEFORE_EXT}
    ${is_commissioned}  Run Keyword And Return Status
    ...  Query Infomodel  every //SCF-* is [stateInfo.proceduralState=validated]
    Set Test Variable  ${IS_COMMISSIONED}  ${is_commissioned}
    IF  ${IS_COMMISSIONED}
        Log  Active sw is commissioned  console=true
    ELSE
        Fail  Active sw is not commissioned
    END
    ${modules_status}  Check If Modules States Ok After Sw Updates
    Wait Until Keyword Succeeds  300s  15sec  Check If Fault 23 Present After SW Update At The End
    ${cells_status}  IF  ${IS_COMMISSIONED}  Verify Cells States
    IF  ${modules_status} and ${cells_status}
        Log  BTS is operational  console=true
    ELSE
        Fail  Not all modules are in the expected state. Check logs (modules_status=${modules_status}, cells_status=${cells_status})
    END


Step 11: Log All Active Alarms During The Test
    Log Step Header  Step 11: Log All Active Alarms During The Test
    IF  ${DISABLE_WATCHDOG}  RETURN
    ${alarms}  watchdog.Get Detected Alarms
    Log  Active alarms during the test are ${alarms}  console=true


Check If Modules States Ok After Sw Updates
    Log  Will now check if modules states are correct, for maximum of 60 times with 10s interval...  console=true
    FOR  ${run}  IN RANGE  1  60
        ${modules_status}  Verify Modules  RMOD  scf_check=${FALSE}
        IF  '${modules_status}' == 'True'
            Log  Modules states are correct. Check attempt: ${run}  console=true
            RETURN  ${modules_status}
        END
        Sleep  10
    END
    Set Test Failed  Modules states not correct within timeout


Verify Cells States
    ${cells_state}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  5s
    ...  Fail If Not All Cells Are On Air

    RETURN  ${cells_state}


Fail If Not All Cells Are On Air
    ${gsm_statuses}  Catenate  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, availabilityStatus=${DEGRADED},
    ...  blockingState=${UNBLOCKED}, usageState=${ACTIVE}
    ${cells_gsm_onair}  Verify Cells  GSM  ${gsm_statuses}  scf_check=${SCF_PARSER_STARTED}
    ${wcdma_statuses}  Catenate  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}, blockingState=${UNBLOCKED},  usageState=${ACTIVE}
    ${cells_wcdma_onair}  Verify Cells  WCDMA  ${wcdma_statuses}  scf_check=${SCF_PARSER_STARTED}
    ${lte_statuses}  Catenate  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, availabilityStatus=${DEGRADED},
    ...  blockingState=${UNBLOCKED}
    ${cells_lte_onair}  Verify Cells  LTE  ${lte_statuses}  scf_check=${SCF_PARSER_STARTED}
    IF  ${cells_gsm_onair} and ${cells_wcdma_onair} and ${cells_lte_onair}
        Log  GSM, WCDMA and LTE cells are onAir!  console=true
    ELSE
        Fail  GSM:${cells_gsm_onair} WCDMA:${cells_wcdma_onair} LTE:${cells_lte_onair}
    END


Fail If Connection With Admin Is Not Available
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    IF  ${status}  RETURN  ${TRUE}
    ${admin_reset_status}  Run Keyword And Return Status
    ...  coam.Reset Admin
    ${infomodel_reset_status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    IF  ${status}  RETURN  ${TRUE}
    Fail  ${admin_reset_status}/${infomodel_reset_status}


Check If Fault 23 Present On ESM
    [Documentation]  If active alarm exist and is Major return True otherwise return False

    @{active_alarms}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=true
        ${notifier_is_smod}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.notifier}  SMOD_R
        ${severity_status}  Run Keyword And Return Status
        ...  Should Contain  Warning|Critical|Minor|Major  ${alarm.severity}
        IF  '${alarm.faultId}'=='${FAULT_23}[fault_id]' and ${severity_status} and ${notifier_is_smod}
            RETURN  ${TRUE}
        END
    END
    Log  Out of loop false  console=true

    RETURN  ${FALSE}


Check If Fault 23 Cleared On SMOD
    [Documentation]  If fault 23 on SMOD is not cleared return FALSE

    @{active_alarms}  coam.Get Active Alarms
    Log  ${\n}Active alarms on BTS:  console=true
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=true
        ${notifier_is_smod}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.notifier}  SMOD_R
        IF  '${alarm.faultId}'=='${FAULT_23}[fault_id]' and ${notifier_is_smod}  Fail  Alarm with fault 23 on ESM active
    END
    Log  ${\n}Fault23 cleared on ESM  console=true


Check If Fault 23 Present
    [Documentation]  If active alarm exist and is Major return True otherwise return False

    @{active_alarms}  coam.Get Active Alarms
    Sleep  2
    FOR  ${alarm}  IN  @{active_alarms}
        ${notifier_is_rmod}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.notifier}  RMOD_R
        IF  '${alarm.faultId}'=='${FAULT_23}[fault_id]' and ${notifier_is_rmod}  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Check If Fault 23 Present After SW Update At The End
    [Documentation]  If active alarm exist at the end of the test, then the test should be failed.

    @{active_alarms}  coam.Get Active Alarms
    Sleep  2s  Wait for alarms to be collected.
    FOR  ${alarm}  IN  @{active_alarms}
        IF  '${alarm}[faultId]'=='${FAULT_23_ALARM_7115}[fault_id]'
            Fail  Fault 23 with fault name: ${FAULT_23_ALARM_7115}[fault_name] is present at the end of the test. [NOK]
        END
    END


Check If Fault 23 Present After Update
    Check If Modules States Ok After Sw Updates
    ${expected_alarm1}  Create Dictionary  faultId=${FAULT_4082}[fault_id]
    ${expected}  Create List  ${expected_alarm1}
    ${critical_alarm1}  Create Dictionary  faultId=${FAULT_23}[fault_id]
    ${critical}  Create List  ${critical_alarm1}
    Admin Check Active Alarms TAF  expected_patterns=${expected}  critical_patterns=${critical}


SW Update For RMODs
    Log  Will now perform SW update on RMODs  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  coam.Update Software  ${SW_PATH}  True  ${SW_UPDATE_TIMEOUT}
    IF  '${sw_update_result}'=='FAIL'  Fail  SW update failed. Reason: ${sw_update_msg}
    Log  Wait until rmods operationalState Enabled  console=true
    Wait Until Keyword Succeeds  10 min  30 sec
    ...  coam.Assert Every  RMOD  operationalState=${ENABLED}


Check Ping On ESM After SW Update To ESM
    ${ping_loss_status_esm_after_esm_up}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${ESM_IP}  timeout=${PING_LOSS_TIMEOUT}  remote_host=${PC_IP2}
    IF  ${ping_loss_status_esm_after_esm_up}==${FALSE}  Fail  Ping has not been lost within timeout
    Log  ESM lost ping after update  console=true
    ${ping_regain_status_esm_after_esm_up}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${ESM_IP}  timeout=${PING_REGAIN_TIMEOUT}  remote_host=${PC_IP2}
    Set Test Variable  ${PING_REGAIN_STATUS_ESM_AFTER_ESM_UP}
    IF  ${PING_REGAIN_STATUS_ESM_AFTER_ESM_UP}==${FALSE}  Fail  Ping has not been regained within timeout
    Log  ESM regained ping after reset  console=true


Checking If GSM On ESM
    ${object_parameter}  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
        ${list}  Get From List  ${object_parameter}  ${index}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${list[0]}  /BTS_L-4/
        IF  '${status}'=='True'  RETURN  ${TRUE}
    END


Checking If WCDMA On ESM
    ${object_parameter}  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
        ${list}  Get From List  ${object_parameter}  ${index}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${list[0]}  /BTS_L-4/
        IF  '${status}'=='True'  RETURN  ${TRUE}
    END


Post Update Ping Check Without 2G Or 3G Cells On ESM
    Check Ping On ESM After SW Update To ESM
    ${ping_status_msm_after_esm_up}  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=240  max_downtime=0  timeout=250
    Log  ${\n}Was MSM ping stable after update on ESM: ${ping_status_msm_after_esm_up}  console=true
    IF  ${ping_status_msm_after_esm_up}
        Log  MSM is stable after update on ESM.  console=true
    ELSE
        Fail  MSM is not stable after update on ESM.
    END


Post Update Ping Check With 2G Or 3G Cells On ESM
    Check Ping On ESM After SW Update To ESM
    Log  Waiting ${FAULT_4001_TIMEOUT}min for fault 4001  console=true
    ${fault_4001_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FAULT_4001_TIMEOUT} min  5 sec
    ...  Check Fault 4001 After Update
    IF  ${fault_4001_status}
        Log Important Message  Alarm with Fault 4001 active on BTS
        Reset After 4001
    ELSE
        Log Important Message  Fault 4001 DID NOT APPEAR  level=WARN
    END


Check Fault 4001 After Update
    ${expected_alarm1}  Create Dictionary  faultId=${FAULT_4001_BTS_RST_REQ}[fault_id]
    ${expected}  Create List  ${expected_alarm1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  print_alarms=${FALSE}
    IF  '${alarms_status}'=='FAIL'  Fail  Unexpected active alarm detected


Reset After 4001
    Log  Waiting for BTS reset...  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=180
    IF  '${status}'=='False'  coam.Reset Site  600
    Log  Waiting for target to be reachable  console=true
    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=180
    Log  Waiting for target to be stable  console=true
    Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=240  max_downtime=100  timeout=400


BM Available
    ${norun_message}  Catenate  METAs and BMs releases of passive and active SW are the same${\n}TC:
    ...  SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_INCONS_RLC should be run instead
    IF  ${META_CHECK}==${TRUE} and ${BM_CHECK}==${TRUE}
        Set Test Norun  ${norun_message}  fail_test=${FALSE}
    ELSE IF  ${META_CHECK}==${TRUE} and ${BM_CHECK}==${FALSE}
        Log  METAs of passive and active SW are the same, but BM releases are different, consistent fallback is possible  console=true
    ELSE IF  ${META_CHECK}==${FALSE}
        Log  METAs of passive and active SW are the different, consistent fallback is possible  console=true
    END


BM Unavailable
    Set Test Restriction  Unable to get BM release (==MAIN or EMPTY) - CHECK LOGS!!
    Log Important Message  Set test restriction - Unable to get BM release (==MAIN or EMPTY) - CHECK LOGS!!
    IF  ${META_CHECK}==${TRUE}
        Set Test Norun  METAs of passive and active SW are the same${\n}TC: SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_INCONS_RLC should be run instead
        ...  fail_test=${FALSE}
    ELSE IF  ${META_CHECK}==${FALSE}
        Log  METAs of passive and active SW are the different, consistent fallback is possible  console=true
    END


TC Setup
    Common Test Setup  tc_name=SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC


TC Teardown
    Common Test Teardown