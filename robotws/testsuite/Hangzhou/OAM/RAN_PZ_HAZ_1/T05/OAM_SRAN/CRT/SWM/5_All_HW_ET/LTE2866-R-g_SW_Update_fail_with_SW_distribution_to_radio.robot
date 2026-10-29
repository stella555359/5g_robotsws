*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library    taf.sbts.oam.coam.admin
Library    DateTime
Library    OperatingSystem
Library     taf.hw.pdu
#Library    hran_ims


*** Variables ***
${Target SW name}                  ${None}                        # SW package name
${Target SW dir}                   /home/ute/btsauto/TARGET_SW    # Directory in which TC should look for sw package
${SW Update Timeout}               3000                            # Given in seconds
${Ping loss timeout}               240                            # Timeout for ping loss during reset
${Ping regain timeout}             600                            # Timeout for ping regain during reset
${onAir Check Number}              60                             # Number of checks for proceduralStatus
${First Cell On Air Timeout}       15                             # Time to wait for first cell on Air (in minutes)
${Test Timeout}                    30                             # Test timeout (in minutes)
${Make Additional Checks}          ${FALSE}                       # Set TRUE if additional check of BTS
${Additional Checks Number}        5
${Sleep interval}                  1 min                          # Time interval between additional checks
${Pass If SW exists}               ${False}
${Log KPIs}                        ${TRUE}                        # Parameter created to turn off KPIs logging on demand
${EXPECTED_BTS_STATUS}             OnAir                          # Expected BTS state before TC starts
${EXPECTED_BTS_STATUS_AFTER_SWDL}  OnAir                          # Expected BTS state after SW download and activation,
                                                                  # can be list of values separeted by commas (no spaces)
${HARDWARE_CHECK_AFTER_UPDATE}     10                             # [min] Time to wait for hardware to have expected states
${FAULT_30_CHECK_TIMEOUT}          300                            # Filtering time to trigger fault 30


*** Keywords ***
TC__LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-4072
    ...
    ...  ***********************************************************
    ...  2. Description in reStructuredText format on what is tested
    ...  ***********************************************************
    ...
    ...  TC for SW download and activation. There are optional parameters:
    ...
    ...  1. Target SW name
    ...  2. Target SW dir
    ...  3. SW Update Timeout - Given in seconds;
    ...  4. onAir Check Number - Number of checks for proceduralStatus

    #[Timeout]    ${Test Timeout} minutes
    Set Tags    CA-SWM    PHASE-CIT    OWNER-dominik.tredota@nokia.com    AUTHOR-sebastian.burniak@nokia.com
    ...    MAINTAINER-wojciech.sikora@nokia.com
    ...    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923
    ...    FEATURE-RP001307_RP000923    FEATURE-RP0001145_RP000923
    variable_update_define
    step1: Find path to SW package
    step2: Check active and passive sw version
    step3: Download T1
    step4: SW update T1
    step5: Check active and passive sw version
    step6: Fault 30 raised
    step7: Turn ON RU first time
    step8: SW update T1
    step9: Check active and passive sw version
    step10: Check If Fault 30 cleared on SMOD
    step11: Check BTS state
    step12: Check if all cells onAir
    step13: Check active alarms
    step14: SW rollback on MSM
    step15: Check if all cells onAir
    ${SCF_ID}=    Run keyword and ignore error    Request SCFID    ${TESTLINE_NAME}

variable_update_define
    [Documentation]    Short description.
    ${cells_NR_expected_states_after_update}       set variable
    ...    administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked
    ${cells_LTE_expected_states_after_update}       set variable
    ...    administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked
    ${cells_WCDMA_expected_states_after_update}     set variable
    ...    operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active
    ${cells_GSM_expected_states_after_update}       set variable
    ...    administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active
    set test variable    ${cells_NR_expected_states_after_update}
    set test variable    ${cells_LTE_expected_states_after_update}
    set test variable    ${cells_WCDMA_expected_states_after_update}
    set test variable    ${cells_GSM_expected_states_after_update}

step1: Find path to SW package
    [Documentation]    Short description.
    Log Step Header  step1: Find path to SW package
    Find path to SW package
    Run Keyword If  '${Target SW path}'== ${None}   Fail

step2: Check active and passive sw version
    [Documentation]    Short description.
    Log step header    Step 2: Check active and passive sw version
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM

step3: Download T1
    [Documentation]    Short description.
    Log Step Header  step3: Download T1
    Download SW T1

step4: SW update T1
    [Documentation]    Short description.
    Log Step Header  step4: SW update T1
    Log  Will now perform software update  console=${TRUE}
    ${target_sw_path_T1}    Get sw package from directory    ${SW_path_Download_T1}    ${TARGET_SW_NAME}
    Set test variable    ${TARGET_SW_PATH_T1}    ${target_sw_path_T1}
    Setup Second Admin Thread
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Run keyword in background
    ...    Update Software  sw_package=${TARGET_SW_PATH_T1}  timeout=3000
    sleep    300s
    taf.hw.pdu.setup_pdu   ${RRU1_INFO.POWERBREAK_TYPE}      ${RRU1_INFO.POWERBREAK_IP}
    taf.hw.pdu.power_off   ${RRU1_INFO.POWERBREAK_PORT}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    #Teardown Second Admin Thread
    sleep    30s

step5: Check active and passive sw version
    [Documentation]    Short description.
    Log step header    Step 5: Check active and passive sw version
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM

step6: Fault 30 raised
    [Documentation]    Wait ${FAULT_30_CHECK_TIMEOUT} filtering time, check alarms and expect fault 30
    Log Step Header  step6: Fault 30 raised
    Log     Wait ${FAULT_30_CHECK_TIMEOUT} s to let the alarm 30 trigger    console=${TRUE}
    sleep    300s
    Wait until keyword succeeds  ${FAULT_30_CHECK_TIMEOUT}  20 sec  Fault 30 check
    Log Important Message  Fault 30 present

step7: Turn ON RU first time
    [Documentation]    Short description.
    Log Step Header  Step7: Turn ON RU first time
    taf.hw.pdu.setup_pdu    ${RRU1_INFO.POWERBREAK_TYPE}     ${RRU1_INFO.POWERBREAK_IP}      timeout=10
    taf.hw.pdu.power_on   ${RRU1_INFO.POWERBREAK_PORT}
    sleep    480s

step8: SW update T1
    [Documentation]    Short description.
    Log Step Header  step8: SW update T1
    Log  Will now perform software update  console=${TRUE}
    ${target_sw_path_T1}    Get sw package from directory    ${SW_path_Download_T1}    ${TARGET_SW_NAME}
    Set test variable    ${TARGET_SW_PATH_T1}    ${target_sw_path_T1}
    ${software_update_start}=  Get current date
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_PATH_T1}  True  3000
    ${software_update_end}=  Get current date
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status
    ...    Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}   Log
    ...    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...       ELSE                                  Log
    ...    BTS is resetting after successful sw update          console=${TRUE}
    ${ping_loss}=  Get current date
    ${ping regain status}  Run keyword and return status
    ...    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping_regain}=  Get current date
    ${ping stable status}  Run keyword and return status
    ...    Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=60  max_downtime=0  timeout=61
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 60 seconds
    Set test variable  ${software_update_start}
    Set test variable  ${software_update_end}
    Set test variable  ${ping_loss}
    Set test variable  ${ping_regain}
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available
    sleep    300s

step9: Check active and passive sw version
    [Documentation]    Short description.
    Log step header    Step 9: Check active and passive sw version
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM

step10: Check If Fault 30 cleared on SMOD
    [Documentation]    Short description.
    Check If Fault 30 cleared on SMOD

step11: Check BTS state
    [Documentation]    Short description.
    Log Step Header  step11: Check BTS state
    Log   Will now wait for first cell onAir  console=${TRUE}
    Set test variable  ${cells_LTE_expected_states}  ${cells_LTE_expected_states_after_update}
    Set test variable  ${cells_WCDMA_expected_states}  ${cells_WCDMA_expected_states_after_update}
    Set test variable  ${cells_GSM_expected_states}  ${cells_GSM_expected_states_after_update}
    Wait Until Keyword Succeeds  ${First Cell On Air Timeout} min  1 sec  Check if any cell is onAir
    ${first_cell_onair}=  Get current date
    Set test variable  ${first_cell_onair}
    Log to console   Will now check if SMODs and RMODs are in expected
    ...    states:${\n}SMODs:${SMOD_expected_states}${\n}RMODs:${RMOD_expected_states}
    Wait until keyword succeeds  ${HARDWARE_CHECK_AFTER_UPDATE} min  30 sec
    ...    Check System Modules and Radio Modules after update
    ${EXPECTED_BTS_STATUS_AFTER_SWDL}  Split String  ${EXPECTED_BTS_STATUS_AFTER_SWDL}  separator=,  max_split=-1
    Log to console  Will now check if BTS state is in list of EXPECTED STATES:${EXPECTED_BTS_STATUS_AFTER_SWDL}
    ...    up to ${onAir Check Number} times with 10s interval.
    FOR  ${run}  IN RANGE  1  ${onAir Check Number}
        ${BTS check status}  ${BTS_status_after_SWDL}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Get Mrbts State
        Run keyword if  '${BTS_status_after_SWDL}' in ${EXPECTED_BTS_STATUS_AFTER_SWDL}  Run Keywords
        ...  Log to console  BTS state is ${BTS_status_after_SWDL}! Check attempt: ${run}   AND
        ...  Log to console  BTS state:${BTS_status_after_SWDL} in LIST of
        ...  EXPECTED STATES:${EXPECTED_BTS_STATUS_AFTER_SWDL} - YES     AND
        ...  Return from keyword
        Sleep  10
    END
    Set test failed  BTS state:${BTS_status_after_SWDL} NOT in LIST of EXPECTED STATES:${EXPECTED_BTS_STATUS_AFTER_SWDL}
    ...    within timeout or the status could not have been obtained

step12: Check if all cells onAir
    [Documentation]    Short description.
    Log Step Header  step12: Check if all cells onAir
    Log to console  Will now wait for all cells to be online. Will check every 10 seconds.
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword if  ${all_cell_status} == ${True}  Run Keywords
        ...  Log to console   All cells online! Check attempt: ${run}
        ...  AND  Exit For Loop
        Sleep  10
    END
    ${all_cells_onair}=  Get current date
    Run keyword if    ${Make Additional Checks}    Ensure that BTS remains OnAir
    Set test variable  ${all_cells_onair}
    #Log table  ${cell_state_table}
    ${MPLANE_IP}=  Admin Get MPLANE IP
    ${status}=  Run keyword and return status  Admin Check mplane connection  ${MPLANE_IP}
    Run keyword if    not ${status}  Set Test Restriction  Check mplane connection to admin failed!

step13: Check active alarms
    [Documentation]    Short description.
    Log Step Header  step13: Check active alarms
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if   '${alarms_status}'=='FAIL'  Fail                  Major/Critical alarm found.
    Run keyword if    ${alarms_return}           Set Test Restriction  Minor alarm found.

step14: SW rollback on MSM
    [Documentation]    Short description.
    Log step header  Step 14: SW rollback on MSM
    ${rollback_status}=  Run keyword and return status  taf.sbts.oam.coam.admin.Rollback software
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.
    Log  Software rollback triggered successfully.  console=${TRUE}
    Log  Wait till BTS is stable and ensure admin connectivity  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=1200
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after rollback.
    Log  BTS is stable after rollback.  console=${TRUE}
    ${admin_working_state}  Reset admin and infomodel connection if broken
    Run keyword if    not ${admin_working_state}  Fail
    ...    Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
    sleep    300s

step15: Check if all cells onAir
    [Documentation]    Short description.
    Log Step Header  step15: Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds.  level=INFO  console=${TRUE}
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword if  ${all_cell_status} == ${True}  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
        Sleep  10
    END
    ${all_cells_onair}=  Get current date
    Run keyword if    ${Make Additional Checks}    Ensure that BTS remains OnAir
    Set test variable  ${all_cells_onair}
    #Log table  ${cell_state_table}
    ${MPLANE_IP}=  Admin Get MPLANE IP
    ${status}=  Run keyword and return status  Admin Check mplane connection  ${MPLANE_IP}
    Run keyword if    not ${status}  Set Test Restriction  Check mplane connection to admin failed!

Check if any cell is onAir
    [Documentation]    Short description.
    ${lte}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  LNCEL  ${cells_LTE_expected_states}
    Run keyword if  ${lte}  Return from keyword
    ${wcdma}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  WNCEL  ${cells_WCDMA_expected_states}
    Run keyword if  ${wcdma}  Return from keyword
    ${gsm}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  GNCEL  ${cells_GSM_expected_states}
    Run keyword if  ${gsm}  Return from keyword
    Fail  Any cell is onAir

Check If Fault 30 cleared on SMOD
    [Documentation]    If fault 30 on SMOD is not cleared return FALSE
    @{active_alarms} =    taf.sbts.oam.coam.admin.Get Active Alarms
    Log    ${\n}Active alarms on BTS:    console=${TRUE}
    FOR    ${alarm}    IN    @{active_alarms}
    Log    FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}    console=yes
    ${notifier_is_smod}    run keyword and return status    should contain    ${alarm.notifier}    SMOD_R
    Run Keyword If    '${alarm.faultId}'=='30' and ${notifier_is_smod}    Fail    Alarm with fault 30 on ESM active
    END
    Log    ${\n}Fault30 cleared on ESM    console=yes

Fault 30 check
    [Documentation]    Short description.
    ${EXPECTED_ALARM}=    Create Dictionary    faultId=30
    ${EXPECTED}=    Create List    ${EXPECTED_ALARM}
    Admin Check Active Alarms    expected_patterns=${EXPECTED}

Log NIDD change and collect SCF
    [Documentation]    Short description.
    Log  Log NIDD change, collect and validate SCF before download and activation  console=${TRUE}
    ${active_package_name}  Get TargetBD Attribute Value From Active Partition  swReleaseVersionPackageName
    ${target_package_name}  Get TargetBD Node Attribute Value  swReleaseVersionPackageName  ${Target SW path}
    Log to console   active swReleaseVersionPackageName: ${active_package_name}\ntarget swReleaseVersionPackageName:
    ...    ${target_package_name}
    ${active_sw}  Should match regexp  ${active_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    ${target_sw}  Should match regexp  ${target_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    taf.sbts.oam.coam.admin.Collect SCF  ${BTS Files}/SCF_${active_sw}_before_SW_Download.xml
    ${scf_valid}  ${msg}  Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Validate Scf
    ...    scf_file=${BTS Files}/SCF_${active_sw}_before_SW_Download.xml  timeout=240
    Run Keyword If  '${scf_valid}'=='FAIL'  Set Test Restriction  SCF Validation on BASE SW:${active_sw} failed:\n${msg}
    Log to console   SCF has been saved under ${BTS Files}/SCF_${active_sw}_before_SW_Download.xml
    ${NIDD_CHANGE}=  wft.Check Nidd Change  ${active_sw}  ${target_sw}
    Log to console   Between ${active_sw} and ${target_sw} NIDD_RADIO, SBTS_NIDD change: ${NIDD_CHANGE}

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

Fail if connection to infomodel is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    ${infomodel_reset_status}  Run keyword and return status
    ...    ute_admin_infomodel.Reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    Fail  ${infomodel_reset_status}

Ensure that BTS remains OnAir
    [Documentation]    Short description.
    Log   BTS will be checked ${Additional Checks Number} times with interval ${Sleep interval} if it remains onAir
    ...   console=${TRUE}
    FOR  ${i}  IN RANGE  ${Additional Checks Number}
        ${is_onAir}=    Verify states
        Log    BTS is onAir    console=${TRUE}
        Sleep   ${Sleep interval}
    END

Verify states
    [Documentation]    Short description.
    ${status}  ${system_modules_working}=   Run Keyword And Ignore Error    Verify system modules states
    ${status}  ${radio_modules_working}=    Run Keyword And Ignore Error    Verify radio modules states
    Run keyword if    not ${system_modules_working} and ${radio_modules_working}    Fail
    ...    msg=At least one module has state other than expected

    ${status}  ${cells_GSM_onair}=          Run Keyword And Ignore Error    Verify GSM cells states
    ${status}  ${cells_WCDMA_onair}=        Run Keyword And Ignore Error    Verify WCDMA cells states
    ${status}  ${cells_LTE_onair}=          Run Keyword And Ignore Error    Verify LTE cells states
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair}    Fail
    ...    msg=At least one cell has state other than expected

    ${IGNORED_ALARMS}=      Create Dictionary  severity=Minor
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${IGNORED_PATTERNS}=    Create List  ${IGNORED_ALARMS}
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_msg}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  ignored_patterns=${IGNORED_PATTERNS}  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if    not '${alarms_status}'=='PASS'    Fail    msg=Major alarm found.

Log kpi and teardown hran ims
    [Documentation]    Short description.
    Run keyword if  ${Log KPIs}  Run keywords
    ...  Run Keyword And Ignore Error    Log robot kpi    AND
    ...  Log KPI
    ...  ELSE
    ...  Log  ==========${\n}Logging KPIs was turned off${\n}==========  console=${TRUE}

Log KPI
    [Documentation]    Short description.
    Log  Measuring KPI  console=${TRUE}
    Add event  sw_update_ind    create /MRBTS-1/RAT-1/URI-*/SESSION-*/SW_UPDATE_IND-*  actionType=Download
    Add cell   first_cell_down  cell_down=True  first_cell=True
    Add cell   last_cell_down   cell_down=True  last_cell=True
    Add cell   first_cell_up    cell_up=True    first_cell=True
    Add cell   last_cell_up     cell_up=True    last_cell=True
    Setup_ims_file  ${BTS Files}/IM/InfoModel_untilReset.ims2  ${BTS Files}/IM/InfoModel_log.ims2
    Register cells list  ${ALL_AVAILABLE_CELLS}
    ims.Create delta  sw_update_ind__to__first_cell_up           sw_update_ind           first_cell_up
    ims.Create delta  first_cell_down__to__last_cell_up          first_cell_down         last_cell_up
    Log delta

    ${variables_are_set}  ${tl_configuration}  ${tl_sync}  ${tl_platform}=  Get KPI related test line variables
    Run keyword if    not ${variables_are_set}  Return from keyword

    Log  Send KPI's to database  console=${TRUE}
    Register KPI  sw_update_ind__to__first_cell_up     KPI#4
    ...  KPI#4: BTS SW download followed by SW activation - SW Download begins / first cell up
    ...  ${TESTLINE_NAME}  ${tl_configuration}  ${tl_sync}  ${tl_platform}  ${TEST VERDICT}
    ...  base_build=${active SW version}  target_build=${TARGET_SW}

    Register KPI  first_cell_down__to__last_cell_up    KPI#2
    ...  KPI#2: BTS SW activation service downtime - first cell down / last cell up
    ...  ${TESTLINE_NAME}  ${tl_configuration}  ${tl_sync}  ${tl_platform}  ${TEST VERDICT}
    ...  base_build=${active SW version}  target_build=${TARGET_SW}

Log robot kpi
    [Documentation]    Short description.
    #Create Table  SOAM_TO_SOAM  Description  Time
    #add row  SOAM_TO_SOAM  Update Start      ${software_update_start}
    #add row  SOAM_TO_SOAM  Update End        ${software_update_end}
    #add row  SOAM_TO_SOAM  Ping loss         ${ping_loss}
    #add row  SOAM_TO_SOAM  Ping regain       ${ping_regain}
    #add row  SOAM_TO_SOAM  First Cell onAir  ${first_cell_onair}
    #add row  SOAM_TO_SOAM  All Cells onAir   ${all_cells_onair}
    #Log table  SOAM_TO_SOAM

    #Create Table  SOAM_TO_SOAM_delta  Description  Delta [s]
    ${timedelta}=  Subtract date From date  ${software_update_end}  ${software_update_start}  result_format=timer
    #add row  SOAM_TO_SOAM_delta  Download  ${timedelta}
    ${timedelta}=  Subtract date From date  ${first_cell_onair}  ${software_update_end}  result_format=timer
    #add row  SOAM_TO_SOAM_delta  Activation  ${timedelta}
    ${timedelta}=  Subtract date From date  ${ping_regain}  ${ping_loss}  result_format=timer
    #add row  SOAM_TO_SOAM_delta  Reset  ${timedelta}
    ${timedelta}=  Subtract date From date  ${all_cells_onair}  ${software_update_start}  result_format=timer
    #add row  SOAM_TO_SOAM_delta  Operation Time  ${timedelta}
    #Log table  SOAM_TO_SOAM_delta

Check System Modules and Radio Modules after update
    [Documentation]    Short description.
    Log  ${\n}${\n}SMODs/RMODs states check:  console=${TRUE}
    ${are_all_smods_on}  Verify modules  SMOD   expected_states=${SMOD_expected_states}  scf_check=${FALSE}
    ${are_all_rmods_on}  Verify modules  RMOD   expected_states=${RMOD_expected_states}  scf_check=${FALSE}
    Should be true  ${are_all_smods_on} and ${are_all_rmods_on}

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup    expected_BTS_status=${EXPECTED_BTS_STATUS}

TC_Custom Teardown
    [Documentation]    Short description.
    Run keywords    Common Test Teardown

#    AND    Log kpi and teardown hran ims

Request SCFID
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scout_testline_name}: <description>
    [Arguments]   ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
