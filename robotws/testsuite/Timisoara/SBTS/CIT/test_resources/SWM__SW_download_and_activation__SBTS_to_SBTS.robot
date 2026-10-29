*** Settings ***
Documentation
    ...  TC for SW download and activation. There are optional parameters:
    ...  1. Target SW name - SW package name. If not given, TC will choose newest package in a directory
    ...  2. Target SW dir - Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
    ...  3. SW Update Timeout - Given in seconds; That is a timeout for SW download and Activation (probably without reset - will be clarified)
    ...  4. onAir Check Number - Number of checks for proceduralStatus: onAir (probably since the reset beginning); check interval = 10s
    ...
    ...  Step1: Locates the target SW package on the filesystem using the configured path and name.
    ...  Step2: Reads and logs the active and passive SW versions before the update.
    ...  Step3: Triggers SW update, waits for BTS reset (ping loss/regain) and connection stabilization.
    ...  Step4: Waits for first cell to go onAir, then verifies SMOD/RMOD states and overall BTS status.
    ...  Step5: Reads and logs the active and passive SW versions after the update.
    ...  Step6: Waits for all cells to reach the expected onAir state; optionally checks mplane connection.
    ...  Step7: Checks active alarms - fails on Major/Critical alarms, sets restriction on Minor alarms.
    ...  Step8: Check Alarm 4592 If Is Needed - Only active for SW >= SBTS24R3 (feature CB007964). Waits 120s for SSH and fault history to load.
    ...  SW update (same release): verifies fault 4592 is NOT present in alarms history.
    ...  SW upgrade (older -> newer): verifies fault 4592 IS present with correct supplAlarmInfo:
    ...  - Supported HW (ASIA/ASIB/ASIL/ASIM): "...due to power on, <DATE>T<TIME> is the last known timestamp before reset"
    ...  - Not supported HW (Flexi/ASOE/ASOF/ASIK/ASOG/ASOH/half-rack FSMF): "...due to [Ss]oftware [Rr]eset"
    ...  Result is also validated in NetAct cleared alarms if NetAct integration is active.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}  900  # Given in seconds; That is a timeout for SW download and activation (without reset)
${PING_LOSS_TIMEOUT}  240  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${PING_STABLE_TIMEOUT}  70  # Timeout for ping until target is stable
${ON_AIR_CHECK_NUMBER}  60  # Number of checks for proceduralStatus: onAir (probably since the reset beginning)
${FIRST_CELL_ON_AIR_TIMEOUT}  15  # Time to wait for first cell on Air (in minutes)
${TEST_TIMEOUT}  30  # Test timeout (in minutes)
${MAKE_ADDITIONAL_CHECKS}  ${FALSE}  # Set TRUE if additional check of BTS (cells, modules, alarms)
# should be taken at the end of TC
# Check is performed to ensure that BTS is onAir for some period of time
${ADDITIONAL_CHECKS_NUMBER}  5  # Number of checks which have to be perform to ensure that bts is onAir
${SLEEP_INTERVAL}  1 min  # Time interval between additional checks, if given in minutes,
# time unit must be added
${PASS_IF_SW_EXISTS}  ${False}  # Set True if the test must finish as PASSED when the requested SW is installed yet

${HARDWARE_CHECK_AFTER_UPDATE}  10  # [min] Time to wait for hardware to have expected states
${RESET_ADMIN_AFTER_UPDATE}  ${TRUE}  # Flag for on-demand reset of admin after update


*** Keywords ***
TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Documentation]
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 14.10.2016 - initial creation
    ...  - 23.06.2017 - TAT-6806 waiting for reset added after sw update
    ...  - 05.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7840 - Change dist_name when SMOD_R-1 horizontal position 2 ? right
    ...  - 28.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-10410 - Situation Active software package is: ? not handled properly
    ...  - 17.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12541 - Add KW Admin Check mplane connection
    ...  - 10.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-12132 - Added lines previously deleted
    ...  - 13.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14218 - Changed handlig issues in case of exceeded ping loss timeout
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15171 - Replaced KW 'check_if_target_is_available' to 'check_if_target_is_stable'
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 05.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-13624 - Added validation of SCF before update
    ...  - 23.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16732 - Added variable 'Log KPIs' to turn off logging KPIs in Teardown
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 11.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17844 - (active/passive)SoftwareVersion changed to
    ...                                                              (active/passive)BuildDescriptorId in KW: Check SW version (hran_infomodel)
    ...  - 21.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17911 - Adds 'EXPECTED_BTS_STATUS' to variables; QT request
    ...  - 25.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-18014 - Adds 'EXPECTED_BTS_STATUS_AFTER_SWDL' to variables; QT request
    ...  - 28.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-16546 - Adds SMODs&RMODs states check in Step4 using 'RMOD_expected_states' and
    ...                                                              'SMOD_expected_states' from hran_frame_sbts
    ...  - 19.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18592 - Increase timeout $HARDWARE_CHECK_AFTER_UPDATE
    ...  - 21.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19344 - Adds variables with expected cells state after upgrade
    ...  - 13.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23045 - Add possibility to reset both admin and infomodel after update
    ...  - 27.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23668 - Add verification for 5G cells
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 23.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25009 - Increase timeout for reaching ping
    ...  - 16.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25554 - Fix recovery ping
    ...  - 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28168 - Include a check for fault 4592
    ...  - 20.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28460 - Adding software filtering
    ...  - 11.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30289 - Add timeout for establishing ssh conection
    ...  - 19.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30627 - Change verification for fid 4592 in case of sw update or sw upgrade
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4072.png#
    [Timeout]  ${TEST_TIMEOUT} minutes

    Set Tags  CA-SWM  PHASE-CIT  OWNER-dominik.tredota@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step1: Find Path To SW Package
    Step2: Check SW Versions
    Step3: SW Update
    Step4: Check BTS State
    Step5: Check SW Versions
    Step6: Check If All Cells OnAir
    Step7: Check Active Alarms
    Step8: Check Alarm 4592 If Is Needed


Preconditions
    Set Test Variable  ${EXPECTED_BTS_STATUS}  OnAir,onAir
    Set Test Variable  ${EXPECTED_BTS_STATUS_AFTER_SWDL}  OnAir,onAir


Step${number_step}: Check SW Versions
    Log Step Header  step${number_step}: Check SW versions
    Run Keyword If  '${number_step}'!='2'
    ...  Wait Until Keyword Succeeds  5 min  10 sec
    ...  Fail If Connection To Infomodel Is Not Available
    Check SW Version  ${number_step}  ${PASS_IF_SW_EXISTS}
    Run Keyword If  '${number_step}'=='2'
    ...  Run Keyword And Ignore Error
    ...  Log NIDD Change And Collect SCF


Step1: Find Path To SW Package
    Log Step Header  step1: Find path to SW package
    Find Path To SW Package
    Run Keyword If  '${TARGET_SW_PATH}'== ${None}
    ...  Fail


Step3: SW Update
    Log Step Header  step3: SW update
    Log  Will now perform software update  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}
    ${software_update_start}  Get Current Date
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  True  timeout=${SW_UPDATE_TIMEOUT}
    ${software_update_end}  Get Current Date
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_LOSS_TIMEOUT}
    Run Keyword If  ${ping_loss_status}==${FALSE}
    ...  Log  BTS RESET after successful sw update DID NOT OCCUR  console=true
    ...  ELSE
    ...  Log  BTS is resetting after successful sw update  console=true
    ${ping_loss}  Get Current Date
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout
    ${ping_regain}  Get Current Date
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  20
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    Run Keyword If  ${ping_stable_status}==${False}
    ...  Set Test Failed  Ping has not been available for ${PING_STABLE_TIMEOUT} seconds
    Set Test Variable  ${SOFTWARE_UPDATE_START}
    Set Test Variable  ${SOFTWARE_UPDATE_END}
    Set Test Variable  ${PING_LOSS}
    Set Test Variable  ${PING_REGAIN}

    Wait Until Keyword Succeeds  5m  10s
    ...  sbts_admin.Admin And Infomodel Connections Reset  ${RESET_ADMIN_AFTER_UPDATE}


Step4: Check BTS State
    Log Step Header  step4: Check BTS state
    Log  Will now wait for first cell onAir  console=true
    Wait Until Keyword Succeeds  ${FIRST_CELL_ON_AIR_TIMEOUT} min  1 sec
    ...  Check If Any Cell Is OnAir
    ${first_cell_onair}  Get Current Date
    Set Test Variable  ${FIRST_CELL_ONAIR}
    Log  Will now check if SMODs and RMODs are in expected states:${\n}SMODs:${SMOD_EXPECTED_STATES}${\n}RMODs:${RMOD_EXPECTED_STATES}
    ...  console=true
    Wait Until Keyword Succeeds  ${HARDWARE_CHECK_AFTER_UPDATE} min  30 sec
    ...  Check System Modules And Radio Modules After Update
    ${expected_bts_status_after_swdl}  Split String  ${EXPECTED_BTS_STATUS_AFTER_SWDL}  separator=,  max_split=-1
    Log  Will now check if BTS state is in list of EXPECTED STATES:${expected_bts_status_after_swdl}  console=true
    Log  up to ${ON_AIR_CHECK_NUMBER} times with 10s interval.  console=true
    FOR  ${run}  IN RANGE  1  ${ON_AIR_CHECK_NUMBER}
        ${bts_check_status}  ${bts_status_after_swdl}  Run Keyword And Ignore Error
        ...  Get Mrbts State
        Run Keyword If  '${bts_status_after_swdl}' in ${expected_bts_status_after_swdl}
        ...  Run Keywords
        ...  Log  BTS state is ${bts_status_after_swdl}! Check attempt: ${run}  console=true
        ...  AND
        ...  Log  BTS state:${bts_status_after_swdl} in LIST of EXPECTED STATES:${expected_bts_status_after_swdl} - YES  console=true
        ...  AND
        ...  Return From Keyword
        Sleep  10
    END
    Set Test Failed
    ...  BTS state:${bts_status_after_swdl} NOT in LIST of EXPECTED STATES:${expected_bts_status_after_swdl} within timeout or status wasn't obtained


Step6: Check If All Cells OnAir
    Log Step Header  step6: Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds.  level=INFO  console=true
    FOR  ${run}  IN RANGE  1  420
        ${all_cells_status}  Run Keyword And Return Status
        ...  Assert All Cells Are In Expected State
        Run Keyword If  '${all_cells_status}' == '${TRUE}'
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
    Run Keyword If  ${status}==${FALSE}
    ...  Set Test Restriction  Check mplane connection to admin failed!


Step7: Check Active Alarms
    Log Step Header  step7: Check active alarms
    ${critical_alarms1}  Create Dictionary  severity=Major
    ${critical_alarms2}  Create Dictionary  severity=Critical
    ${critical_patterns}  Create List  ${critical_alarms1}  ${critical_alarms2}
    ${alarms_status}  ${alarms_return}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  Major/Critical alarm found.
    Run Keyword If  ${alarms_return}
    ...  Set Test Restriction  Minor alarm found.


Step8: Check Alarm 4592 If Is Needed
    Log  Step8: Check Alarm 4592 If Is Needed  console=true
    ${active_sw_after_swr}  Get Sw Version
    ${sw_version_after_swr}  Fetch From Left  ${active_sw_after_swr}  _
    Sleep  120  TC waits 120s for SSH connection to establish and faults to be loaded in history.
    ${historical_alarms}  Get Historic Alarms  60  load_history=True  severity=warning
    IF  '${ENB_BRANCH}' == '${sw_version_after_swr}' and '${sw_version_after_swr}' >= 'SBTS24R3'
        Log  Action performed was sw update because initial sw release was ${ENB_BRANCH} which is the same with target release.
        ...  console=true
        Check If Fault 4592 Is Not Visible In WebEM  ${historical_alarms}
    ELSE IF  '${ENB_BRANCH}' < '${sw_version_after_swr}' and '${sw_version_after_swr}' >= 'SBTS24R3'
        Log  Action performed was sw upgrade because initial sw release was ${ENB_BRANCH} which is older than target release.
        ...  console=true
        Log  FID 4592 might occur after sw upgrade, check will be perform!  console=true
        Initiating Alarm 4592 Verification
    ELSE
        Log  Active software is ${active_sw_after_swr}. The check of alarm 4592 will not start.  console=true
    END


Initiating Alarm 4592 Verification
    [Documentation]
    ...  Entry point for the alarm 4592 verification flow, triggered only when the active SW release
    ...  is newer than the initial one and both are >= SBTS24R3 (feature CB007964 is applicable).
    ...  Retrieves the current BTS date/time in UTC, fetches the last 60 minutes of historical warning
    ...  alarms and identifies the hardware type of each SMOD module. Based on the hardware:
    ...  - Supported HW (ASIA, ASIB, ASIL, ASIM): delegates to
    ...  "Check The Appearance Of 4592 And Supplementary Alarm Info For Supported HW"
    ...  - Not supported HW (Flexi, ASOE, ASOF, ASIK, ASOG, ASOH or half-rack FSMF): delegates to
    ...  "Check The Appearance Of 4592 And Supplementary Alarm Info For Not Supported HW"

    Log  Active software is greater than 24R3. Feature CB007964 is applied. The check of alarm 4592 will start.  console=true
    ${DATE_HOUR}  Get BTS Time In UTC Format  %Y-%m-%d %H
    ${DATE}  Get BTS Time In UTC Format  %Y-%m-%d
    Set Test Variable  ${DATE_HOUR}
    Set Test Variable  ${DATE}
    ${historical_alarms}  Get Historic Alarms  60  load_history=True  severity=warning

    ${smods_objects}  coam.Get Parameters For All  class_name=SMOD
    ${check_master}  Run Keyword And Return Status  Should Contain  ${smods_objects}[0][productName]  FSMF
    ${check_slave}  Run Keyword And Return Status  Should Contain  ${smods_objects}[1][productName]  FSMF

    ${check_full_rack_fsmf}  Set Variable If  '${check_master}'=='${TRUE}' and '${check_slave}'=='${TRUE}'  ${TRUE}  ${FALSE}
    ${check_half_rack_fsmf}  Set Variable If  '${check_master}'=='${TRUE}' or '${check_slave}'=='${TRUE}'  ${TRUE}  ${FALSE}

    ${list_feature_supported_hw}  Create List  ASIA  ASIB  ASIL  ASIM
    ${list_feature_not_supported_hw}  Create List  Flexi  ASOE  ASOF  ASIK  ASOG  ASOH

    ${smods}  Get FSM Info
    FOR  ${smod}  IN  @{smods}
        ${length_product_name}  Get Length  ${smod}[productName]
        IF  ${length_product_name} > 4
            ${product_name}  Fetch From Left  ${smod}[productName]  ${SPACE}
        END
        IF  '${product_name}' in @{list_feature_supported_hw}
            Set Test Variable  ${CHECK_SUPPORTED}  ${TRUE}
            Set Test Variable  ${CHECK_NOT_SUPPORTED}  ${FALSE}
        ELSE IF  ( '${product_name}' in @{list_feature_not_supported_hw} ) or ${check_half_rack_fsmf}
            Set Test Variable  ${CHECK_NOT_SUPPORTED}  ${TRUE}
            Set Test Variable  ${CHECK_SUPPORTED}  ${FALSE}
        END
    END

    IF  ${CHECK_NOT_SUPPORTED}
        Check The Appearance Of 4592 And Supplementary Alarm Info For Not Supported HW  ${historical_alarms}
    ELSE IF  ${CHECK_SUPPORTED}
        Check The Appearance Of 4592 And Supplementary Alarm Info For Supported HW  ${historical_alarms}
    END


Check If Fault 4592 Is Not Visible In WebEM
    [Arguments]  ${historical_alarms}
    [Documentation]
    ...  Verifies that fault 4592 (alarm 7115) does NOT appear in the historical alarms list in WebEM.
    ...  This check is used after an SW update (same release), where fault 4592 is not expected to be raised.
    ...  Iterates through all historical alarms; if any alarm with faultId matching fault 4592 is found,
    ...  the keyword fails immediately. If no matching alarm is found, the check passes.

    Log  Check for fault 4592 to not be visible in WebEM!  console=true
    ${status_list}  Run Keyword And Return Status  Should Not Be Empty  ${historical_alarms}
    IF  ${status_list}
        FOR  ${alarm}  IN  @{historical_alarms}
            ${status_alarm}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4592}[fault_id]
            IF  ${status_alarm}  Fail  Alarm 7115 "${FAULT_4592}[fault_name]" has appeared in historical alarms in WebEM.[NOK]
        END
    ELSE
        Log  Alarm "${FAULT_4592}[fault_name]" was not found in history alarms. [OK]  console=true
    END


Check The Appearance Of 4592 And Supplementary Alarm Info For Not Supported HW
    [Arguments]  ${historical_alarms}
    [Documentation]
    ...  Verifies that fault 4592 (alarm 7115) is present in historical alarms and contains the correct
    ...  supplementary info for hardware that does NOT support feature CB007964 (e.g. Flexi, ASOE, ASOF,
    ...  ASIK, ASOG, ASOH or half-rack FSMF configurations).
    ...  The expected supplAlarmInfo must match the pattern:
    ...  "BTS booted at <DATE_HOUR>:MM:SS GMT+<offset> due to software reset"
    ...  where "software reset" is accepted in both lowercase and capitalized form ([Ss]oftware [Rr]eset).
    ...  If the alarm is found with correct supplementary info, the result is also validated in NetAct
    ...  (if NetAct integration is active). Fails if the alarm is present but with incorrect supplementary info.

    ${status_list}  Run Keyword And Return Status  Should Not Be Empty  ${historical_alarms}
    IF  ${status_list}
        FOR  ${alarm}  IN  @{historical_alarms}
            ${status_alarm}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4592}[fault_id]
            ${gmt_string}  Remove String  ${alarm}[btsObservationTimezone]  :
            ${gmt_time}  Fetch From Right  ${gmt_string}  +
            ${status_suppl_info}  Run Keyword And Return Status
            ...  Should Match Regexp  ${alarm}[alarmText][alarmAdditionalInfo][supplAlarmInfo]
            ...  BTS booted at ${DATE_HOUR}:\\d{2}:\\d{2} GMT\\+${gmt_time} due to [Ss]oftware [Rr]eset
            IF  ${status_alarm} and ${status_suppl_info}
                Log  Alarm 7115 "${FAULT_4592}[alarm_name]" has the correct supplementary info in historical alarms in WebEM. [OK]  console=true
                ${suppl_info}  Set Variable  BTS booted at ${DATE_HOUR}:\\d{2}:\\d{2} GMT\\+${gmt_time} due to [Ss]oftware [Rr]eset
                IF  ${STATUS_NETACT}
                    Checking Netact Integration State And Alarm in Cleared Alarms In Netact  &{FAULT_4592}  time_from=${START_TIME}
                    ...  suppl_info=.*${suppl_info}.*
                END
                BREAK
            ELSE IF  ${status_alarm} and ${status_suppl_info}==${FALSE}
                Fail  Alarm "${FAULT_4592}[fault_name]" is not visible correctly in WebEM.[NOK]
            END
        END
    ELSE
        Log  Alarm "${FAULT_4592}[fault_name]" was not found in historical alarms. [OK]  console=true
    END


Check The Appearance Of 4592 And Supplementary Alarm Info For Supported HW
    [Arguments]  ${historical_alarms}
    [Documentation]
    ...  Verifies that fault 4592 (alarm 7115) is present in historical alarms and contains the correct
    ...  supplementary info for hardware that supports feature CB007964 (ASIA, ASIB, ASIL, ASIM).
    ...  The expected supplAlarmInfo must match the pattern:
    ...  "BTS booted at <DATE_HOUR>:MM:SS GMT+<offset> due to power on, <DATE>THH:MM:SS is the last known timestamp before reset"
    ...  If the alarm is found with correct supplementary info, the result is also validated in NetAct
    ...  (if NetAct integration is active). Fails if the alarm is present but with incorrect supplementary info.

    ${status_list}  Run Keyword And Return Status  Should Not Be Empty  ${historical_alarms}
    IF  ${status_list}
        FOR  ${alarm}  IN  @{historical_alarms}
            ${status_alarm}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4592}[fault_id]
            ${gmt_string}  Remove String  ${alarm}[btsObservationTimezone]  :
            ${gmt_time}  Fetch From Right  ${gmt_string}  +
            ${suppl_info_text}  Catenate  SEPARATOR=  BTS booted at ${DATE_HOUR}:\\d{2}:\\d{2} GMT\\+${gmt_time} due to power on, ${DATE}T\\d{2}:
            ...  \\d{2}:\\d{2} is the last known timestamp before reset
            ${status_suppl_info}  Run Keyword And Return Status
            ...  Should Match Regexp  ${alarm}[alarmText][alarmAdditionalInfo][supplAlarmInfo]
            ...  ${suppl_info_text}
            IF  ${status_alarm} and ${status_suppl_info}
                Log  Alarm 7115 "${FAULT_4592}[alarm_name]" has the correct supplementary info in historical alarms in WebEM. [OK]  console=true
                IF  ${STATUS_NETACT}
                    Checking Netact Integration State And Alarm in Cleared Alarms In Netact  &{FAULT_4592}  time_from=${START_TIME}
                    ...  suppl_info=.*${suppl_info_text}.*
                END
                BREAK
            ELSE IF  ${status_alarm} and ${status_suppl_info}==${FALSE}
                Fail  Alarm "${FAULT_4592}[fault_name]" is not visible correctly in WebEM.[NOK]
            END
        END
    ELSE
        Log  Alarm "${FAULT_4592}[fault_name]" was not found in historical alarms. [OK]  console=true
    END


Check If Any Cell Is OnAir
    ${lte}  Run Keyword And Return Status
    ...  Assert Parameters For Any  LNCEL  ${CELLS_LTE_EXPECTED_STATES}
    Run Keyword If  ${lte}
    ...  Return From Keyword
    ${wcdma}  Run Keyword And Return Status
    ...  Assert Parameters For Any  WNCEL  ${CELLS_WCDMA_EXPECTED_STATES}
    Run Keyword If  ${wcdma}
    ...  Return From Keyword
    ${gsm}  Run Keyword And Return Status
    ...  Assert Parameters For Any  GNCEL  ${CELLS_GSM_EXPECTED_STATES}
    Run Keyword If  ${gsm}
    ...  Return From Keyword
    ${nr}  Run Keyword And Return Status
    ...  Assert Parameters For Any  NRCEL  ${CELLS_NR_EXPECTED_STATES}
    Run Keyword If  ${nr}
    ...  Return From Keyword
    Fail  Any cell is onAir


Log NIDD Change And Collect SCF
    Log  Log NIDD change, collect and validate SCF before download and activation  console=true
    ${active_package_name}  Get TargetBD Attribute Value From Active Partition  swReleaseVersionPackageName
    ${target_package_name}  hran_file_operations.Get TargetBD Node Attribute Value  swReleaseVersionPackageName  ${TARGET_SW_PATH}
    Log  active swReleaseVersionPackageName: ${active_package_name}\ntarget swReleaseVersionPackageName: ${target_package_name}  console=true
    ${active_sw}  Should Match Regexp  ${active_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    ${target_sw}  Should Match Regexp  ${target_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    Get Current Scf File  ${BTS_FILES}  SCF_${active_sw}_before_SW_Download.xml
    ${scf_valid}  ${msg}  Run Keyword And Ignore Error
    ...  Validate Scf  scf_file=${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml  timeout=240
    Run Keyword If  '${scf_valid}'=='FAIL'
    ...  Set Test Restriction  SCF Validation on BASE SW:${active_sw} failed:\n${msg}
    Log  SCF has been saved under ${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml  console=true


Fail If Connection To Infomodel Is Not Available
    ${status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Check Infomodel Object  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run Keyword If  ${status}
    ...  Return From Keyword
    ${infomodel_reset_status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    ${status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Check Infomodel Object  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run Keyword If  ${status}
    ...  Return From Keyword
    Fail  ${infomodel_reset_status}


Ensure That BTS Remains OnAir
    Log  BTS will be checked ${ADDITIONAL_CHECKS_NUMBER} times with interval ${SLEEP_INTERVAL} if it remains onAir  console=true
    FOR  ${i}  IN RANGE  ${ADDITIONAL_CHECKS_NUMBER}
        ${is_on_air}  Verify States
        Log  BTS is onAir  console=true
        Sleep  ${SLEEP_INTERVAL}
    END


Verify States
    Verify BTS States


Check System Modules And Radio Modules After Update
    Log  ${\n}${\n}SMODs/RMODs states check:  console=true
    ${are_all_smods_on}  Verify Modules TAF  SMOD  expected_states=${SMOD_EXPECTED_STATES}  scf_check=${FALSE}
    ${are_all_rmods_on}  Verify Modules TAF  RMOD  expected_states=${RMOD_EXPECTED_STATES}  scf_check=${FALSE}
    Should Be True  ${are_all_smods_on} and ${are_all_rmods_on}


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Preconditions
    Common Test Setup  tc_name=SWM__SW_download_and_activation__SBTS_to_SBTS
    ${status_netact}  Run Keyword And Return Status  Setup Netact
    Set Test Variable  ${STATUS_NETACT}  ${status_netact}
    Run Keyword If  ${status_netact}
    ...  Log  SBTS is integrated into Netact. Alarm check will follow.  console=true
    ...  ELSE
    ...  Log  SBTS is not integrated into Netact. Alarm check will be skipped.  console=true

TC Teardown
    Run Keyword If  ${STATUS_NETACT}
    ...  Teardown NetAct
    Common Test Teardown
    Set Test Variable  ${DISABLE_WATCHDOG}  ${FALSE}
