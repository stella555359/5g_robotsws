*** Settings ***
Documentation
    ...  This TC is triggering fault 246 for 3 times after setting the parameter actForceAutoReset to True.
    ...  Site reset is performed in the beginning to clear all counters. coreRestartCounter for secondary core
    ...  should be 0.
    ...
    ...  For 2 times, BTS secondary core autonomous reset as recovery action is triggered and coreRestartCounter
    ...  for secondary core should be incremented. Cells on secondary core and cells on RMODs with syncronization
    ...  cablink linked to secondary core should be Failed.
    ...  After secondary core reset, 5G RAT reset is performed without being visible the corresponding alarm for
    ...  this action.
    ...  Fault 4001: RAT autonomous reset as recovery action should appear on RNC.
    ...
    ...  For the third time, BTS site autonomous reset as recovery action is triggered.
    ...  After site autonomous reset, TC is waiting for SBTS to reach onAir state.
    ...  In the end, actForceAutoReset is set to False (default value).

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${TIME_DIFFERENCE_THRESHOLD}  10  # [integer] Value which will be compared with the difference between NMS reset and alarm appearance time in WebEM
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset
${RECOVERY_TIMEOUT}  600  # Timeout for SBTS to recover after secondary core autonomous reset
${AFFECTED_CELLS_TIMEOUT}  300  # Timeout for affected cell to reach faullty state caused by secondary core autonomous reset
${ALARM_TIMEOUT}  900  # Timeout for fault 246 to be visible in WebEM and NetAct


*** Keywords ***
TC__FM__SC_to_Site_reset_escalation_fid_246
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25411
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25411 - Initial TAT creation
    ...  05.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25670 - Improve cells check and add verification for fault 4001
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  12.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28515 - Enhancement test should check fault 4001 in Mantaray under RNC object
    ...  26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29193 - Add check for fault 4670 in WebEM and Netact under RNC object
    ...  25.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29938 - Enhancement test fails due to affected cells state and alarm check
    ...  10.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30117 - Add check for FID 10 if it appears
    ...  24.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30223 - Update check for FID 10 in WebEM and Mantaray
    ...  ******************

    Set Tags  CA-WebEM  OWNER-florin-sebastian.nedelcu@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23  CNI-81643

    Step0: TC Variables And Preconditions
    Step1: Perform Site Reset To Clear All Counters
    Step2: Trigger Fault 246 And Check SBTS Status
    Step3: Trigger Fault 246 And Check SBTS Status
    Step4: Trigger Fault 246 For The Third Time And Check SBTS Status


Step0: TC Variables And Preconditions
    ${secondary_core_object}  Get Secondary Core Parameters
    Set Test Variable  ${SC_R_DN}  ${secondary_core_object}[id][internal]
    ${sc_ref}  Query Infomodel  get object ${SC_R_DN}/REF-*
    ${msg_ids}  Create List  0x2062  0x206B
    Set Test Variable  ${SC_L_DN}  ${sc_ref.distName}
    Set Test Variable  ${MSG_IDS}
    Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${rnc_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*
    ${wbts_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*/WBTS-*
    ${rnc_id}  Fetch From Right  ${rnc_infomodel}[dist_name]  RNC-
    ${wbts_id}  Fetch From Right  ${wbts_infomodel}[dist_name]  WBTS-
    Set Test Variable  ${RNC_ID}
    Set Test Variable  ${WBTS_ID}


Step1: Perform Site Reset To Clear All Counters
    Log  \nStep1: Perform site reset to clear all counters.  console=true

    Perform Site Reset
    ${actual_value}  Get Core Restart Counter Value  ${SC_L_DN}
    Should Be Equal As Integers  ${actual_value}  0  msg=Secondary core restart counter did not reset.
    Log  Secondary core restart counter is 0 after site reset.  console=true


Step${index}: Trigger Fault 246 And Check SBTS Status
    Log  \nStep${index}: Trigger fault 246 and check SBTS status.  console=true

    Set Affected Unaffected and 5G Cells On Primary Core
    ${count_affected_iot}  Get Length  ${AFFECTED_CELLS_WITH_IOT}
    ${count_5g_cells_on_pc}  Get Length  ${5_G_CELLS_ON_PRIMARY_CORE}
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger Fault 246  ${SC_L_DN}  ${MSG_IDS}[0]
    Log  Fault 246 sent to secondary core.  console=true
    Wait Until Keyword Succeeds  ${AFFECTED_CELLS_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS_WITHOUT_IOT}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Log  Affected cells reached state operationalState=${DISABLED}, availabilityStatus=${FAILED} :\n${AFFECTED_CELLS_WITHOUT_IOT}  console=true
    IF  ${count_affected_iot}
        Wait Until Keyword Succeeds  ${AFFECTED_CELLS_TIMEOUT}  10
        ...  Check Parameters Status For Cells  ${AFFECTED_CELLS_WITH_IOT}  operationalState=${DISABLED}, availabilityStatus=${OFFLINE}
        Log  Affected cells reached state operationalState=${DISABLED}, availabilityStatus=${OFFLINE} :\n${AFFECTED_CELLS_WITH_IOT}  console=true
    END
    Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}

    ${fid_246_2nd_core_params}  Get String With Alarm Parameters  ${FAULT_246_2_ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${fid_246_2nd_core_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault active in WebEM : ${FAULT_246_2_ND_CORE_AUTO_RST}.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_246_2_ND_CORE_AUTO_RST}
    ...                                                                               time_from=${start_time}
    ...                                                                               additional_fault_id=${FAULT_246_2_ND_CORE_AUTO_RST}[fault_id]
    Log  Fault reported and cleared in Mantaray : ${FAULT_246_2_ND_CORE_AUTO_RST}.  console=true
    IF  ${count_5g_cells_on_pc}
        Wait Until Keyword Succeeds  ${AFFECTED_CELLS_TIMEOUT}  10
        ...  Check Parameters Status For Cells  ${5_G_CELLS_ON_PRIMARY_CORE}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
        Log  Affected cells reached state operationalState=${DISABLED}, availabilityStatus=${FAILED} :\n${5_G_CELLS_ON_PRIMARY_CORE}  console=true
    END
    Assert  SMOD  ${SC_R_DN}  operationalState=${ENABLED}  timeout=300
    ${expected_value}  Evaluate  ${index}-1
    ${actual_value}  Get Core Restart Counter Value  ${SC_L_DN}
    Should Be Equal As Integers  ${actual_value}  ${expected_value}  msg=Secondary core restart counter did not increase to ${expected_value}.
    Log  Secondary core restart counter increased to ${expected_value}.  console=true

    ${suppl_alarm_info}  Catenate  SEPARATOR=${SPACE}
    ...  BTS secondary core is enabled, or, un-commissioned BBMOD detected at BTS start-up is commissioned at runtime or BBMOD is reset at runtime.
    ...  To use the affected resources and setup disabled WCDMA cell.*, the WCDMA RAT Reset is needed.
    ${fid_4001_rat_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4001_RAT_AUTO_RST}
    ${alarm_4001_parameters}  Catenate  SEPARATOR=,${SPACE}  ${fid_4001_rat_auto_rst_params}  supplAlarmInfo=regex"${suppl_alarm_info}"
    ${fid_4670_params}  Get String With Alarm Parameters  ${FAULT_4670}
    ${alarm_4670_parameters}  Catenate  SEPARATOR=,${SPACE}  ${fid_4670_params}  supplAlarmInfo=regex"${suppl_alarm_info}"

    IF  ${SCF_COUNT_WCDMA}
        IF  '${ENB_BRANCH}' >= 'SBTS25R3'
            Assert Alarm Active  parameters=${alarm_4670_parameters}  timeout=${ALARM_TIMEOUT}
            Log  Fault active in WebEM ${FAULT_4670}.  console=true
        ELSE
            Assert Alarm Active  parameters=${alarm_4001_parameters}  timeout=${ALARM_TIMEOUT}
            Log  Fault active in WebEM ${FAULT_4001_RAT_AUTO_RST}.  console=true
        END
        Assert Every  WNCEL  availabilityStatus=${FAILED}, operationalState=${DISABLED}  timeout=300
        IF  '${ENB_BRANCH}' >= 'SBTS25R3'
            Assert Alarm Inactive  parameters=${alarm_4670_parameters}  timeout=300
            Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
            ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4670}
            ...                                                                               time_from=${start_time}
            ...                                                                               dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
            ...                                                                               suppl_info=${suppl_alarm_info}
            Log  Fault ${FAULT_4670} reported and cleared from WebEM and Mantaray.  console=true
        ELSE
            Assert Alarm Inactive  parameters=${alarm_4001_parameters}  timeout=300
            Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
            ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4001_RAT_AUTO_RST}
            ...                                                                               time_from=${start_time}
            ...                                                                               additional_fault_id=${FAULT_4001_RAT_AUTO_RST}[fault_id]
            ...                                                                               dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
            ...                                                                               suppl_info=${suppl_alarm_info}
            Log  Fault ${FAULT_4001_RAT_AUTO_RST} reported and cleared from WebEM and Mantaray.  console=true
        END

    END
    Log  TC will check active alarms for 2 minutes.  console=true
    FOR  ${time}  IN RANGE  0  6
        Admin Check Active Alarms TAF
        Sleep  20s
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS_WITHOUT_IOT}  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS_WITH_IOT}  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${5_G_CELLS_ON_PRIMARY_CORE}  operationalState=${ENABLED}


Step4: Trigger Fault 246 For The Third Time And Check SBTS Status
    Log  \nStep4: Trigger fault 246 for the third time and check SBTS status.  console=true
    ${count_affected_iot}  Get Length  ${AFFECTED_CELLS_WITH_IOT}
    Set Affected Unaffected and 5G Cells On Primary Core
    ${last_start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${LAST_START_TIME}
    ${bbmods_on_secondary}  Get BBMODs On Secondary Core  ${SC_R_DN}
    ${rmods_with_syncro_on_sc}  Get RMODs With Syncro Cablink On Secondary Core  ${bbmods_on_secondary}
    Set Test Variable  ${RMODS_WITH_SYNCRO_ON_SC}
    ${rmods_count}  Get Length  ${rmods_with_syncro_on_sc}
    Log  Found ${rmods_count} RMODs with syncro cablink on secondary core: ${rmods_with_syncro_on_sc}  console=true
    Trigger Fault 246  ${SC_L_DN}  ${MSG_IDS}[1]
    Wait Until Keyword Succeeds  ${AFFECTED_CELLS_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS_WITHOUT_IOT}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Log  Affected cells reached state operationalState=${DISABLED}, availabilityStatus=${FAILED} :\n${AFFECTED_CELLS_WITHOUT_IOT}  console=true
    IF  ${count_affected_iot}
        Wait Until Keyword Succeeds  ${AFFECTED_CELLS_TIMEOUT}  10
        ...  Check Parameters Status For Cells  ${AFFECTED_CELLS_WITH_IOT}  operationalState=${DISABLED}, availabilityStatus=${OFFLINE}
        Log  Affected cells reached state operationalState=${DISABLED}, availabilityStatus=${OFFLINE} :\n${AFFECTED_CELLS_WITH_IOT}  console=true
    END
    ${fid_246_site_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_246_SITE_AUTO_RST}
    Assert Alarm Active  parameters=${fid_246_site_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ${timestamp_after_fid_246}  Get Current Date  time_zone=local  result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable  ${TIMESTAMP_AFTER_FID_246}
    Log  Fault active in WebEM : ${FAULT_246_SITE_AUTO_RST}.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Admin Check All Required State
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_246_SITE_AUTO_RST}
    ...                                                                               time_from=${last_start_time}
    ...                                                                               additional_fault_id=${FAULT_246_SITE_AUTO_RST}[fault_id]
    Log  Fault reported and cleared in Mantaray : ${FAULT_246_SITE_AUTO_RST}.  console=true

    ${ims_path}  Set Variable  ${BTS_FILES}/fid10_alarms.ims2
    Collect Infomodel Log From Current Session  target_file_name=${ims_path}  timeout=300
    ${fid_10_alarms}  ims_parser.Get Fault Occurrences  ${ims_path}  ${FAULT_10_Critical}[fault_id]  begin=${timestamp_after_fid_246}
    Set Test Variable  ${FID_10_ALARMS}


Set Affected Unaffected and 5G Cells On Primary Core
    ${cells_on_secondary_core}  Get Cell Mapping By Module Id  ${SC_R_DN}
    ${affected_cells}  Get Cells On RMODs With Syncronization Cablink On Secondary Core  ${SC_R_DN}
    Append To List  ${affected_cells}  @{cells_on_secondary_core}
    ${affected_cells}  Remove Duplicates  ${affected_cells}
    ${all_cells}  Get All Cells On Bts
    Remove Values From List  ${all_cells}  @{affected_cells}
    ${affected_cells_without_iot}  ${affected_cells_with_iot}  Check If Affected Cells Are IoT  ${affected_cells}
    ${5_g_cells_on_primary_core}  Get Cells Mapped On PC If RAT Is Mapped On Both PC And SC  NRCELL
    Set Test Variable  ${AFFECTED_CELLS_WITH_IOT}
    Set Test Variable  ${AFFECTED_CELLS_WITHOUT_IOT}
    Set Test Variable  ${UNAFFECTED_CELLS}  ${all_cells}
    Set Test Variable  ${5_G_CELLS_ON_PRIMARY_CORE}


Check If Affected Cells Are IoT
    [Arguments]  ${affected_cells_list}

     ${affected_cells_with_iot}  Create List
     ${affected_cells_without_iot}  Create List
     FOR  ${cell}  IN  @{affected_cells_list}
         IF  'LNCEL' in '${cell}'
             ${ref_cell}  coam.Get Parameters  ${cell}/REF-1
             ${cell_l}  coam.Get Parameters  ${ref_cell}[distName]
             IF  '${cell_l}[technology]' == 'nbIotFdd'
                 Append To List  ${affected_cells_with_iot}  ${cell}
             ELSE
                 Append To List  ${affected_cells_without_iot}  ${cell}
             END
         ELSE
             Append To List  ${affected_cells_without_iot}  ${cell}
         END
     END

     RETURN  ${affected_cells_without_iot}  ${affected_cells_with_iot}


Check FID 10 In WebEM And Mantaray With The Help Of IMS and Syslog Files
    [Arguments]  ${timestamp}  ${rmods_with_syncro_on_sc}  ${fid_10_alarms}  ${start_time}

    IF  '${ENB_BRANCH}'>='25R3'
        Unarchive Syslogs From UDPLogs Directory
        ${files}  OperatingSystem.List Files In Directory  ${UDP_LOGS}/Unarchived
        FOR  ${file}  IN  @{files}
            IF  '${file}' in ['SYSLOG_PC_UDP', 'SYSLOG_BTS_UDP']
                ${nms_reset_lines}  Parse Syslog From Archive  ${UDP_LOGS}/Unarchived/${file}
                ...                                            TcpConnForNe3SAdapt.* The connection have been destroy
                BREAK
            END
        END
        Should Not Be Empty  ${nms_reset_lines}  No NMS reset lines found in syslog files: ${files}.
        ${nms_reset_timestamp}  Find First Timestamp After Given Time  ${nms_reset_lines}  ${timestamp}
        Process FID 10 Alarms With Time Difference Check  ${fid_10_alarms}  ${rmods_with_syncro_on_sc}  ${nms_reset_timestamp}  ${start_time}
    ELSE
        Log  No need to verify FID 10 appearance in WebEM And Mantaray. Software version is less than 25R3.  console=true
    END


Process FID 10 Alarms With Time Difference Check
    [Arguments]  ${alarms_list}  ${rmods_list}  ${nms_reset_time}  ${start_time}

    ${current_date}  Fetch From Left  ${nms_reset_time}  ${SPACE}
    ${current_date}  Remove String Using Regexp  ${current_date}  -
    ${nms_reset_time_only}  Fetch From Right  ${nms_reset_time}  ${SPACE}

    FOR  ${alarm}  IN  @{alarms_list}
        ${rmod_status}  Run Keyword And Return Status  List Should Contain Value  ${rmods_list}  ${alarm}[alarmingResourceDN]
        IF  ${rmod_status}
            ${observation_time_processed}  Remove String Using Regexp  ${alarm}[observationTime]  ${current_date}
            ${observation_time_processed}  Fetch From Left  ${observation_time_processed}  .
            ${characters}  Split String To Characters  ${observation_time_processed}
            ${observation_time_formatted}  Catenate  SEPARATOR=:  ${characters[0]}${characters[1]}
            ...                                                   ${characters[2]}${characters[3]}
            ...                                                   ${characters[4]}${characters[5]}
            ${message}  Catenate  Fault ${FAULT_10_Critical} was active in WebEM before escalation to Site Reset,
            ...                   with correct supplementary alarm information, on RMOD: ${alarm}[alarmingResourceDN]
            ...                   at ${observation_time_formatted}
            Log  ${message}  console=true
            ${difference}  Subtract Time From Time  ${nms_reset_time_only}  ${observation_time_formatted}
            ${difference}  Convert To Integer  ${difference}
            IF  ${difference}>${TIME_DIFFERENCE_THRESHOLD}
                ${nms_rmod_dn}  Get Regexp Matches  ${alarm}[alarmingResourceDN]  /EQM_R.*
                ${nms_rmod_dn}  Catenate  SEPARATOR=  PLMN-PLMN/  MRBTS-${BTS_ID}  ${nms_rmod_dn}[0]
                Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
                ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_10_Critical}
                ...                                                                               suppl_info=RU connection was lost in runtime
                ...                                                                               object_id=${nms_rmod_dn}
                ...                                                                               time_from=${start_time}
            ELSE
                ${message}  Catenate  No need to verify FID 10 appearance in Mantaray.
                ...                   Time difference between NMS reset and alarm appearance
                ...                   time in WebEM is less than 12 seconds.  console=true
                Log  ${message}  console=true
            END
        END
    END


TC Setup
    Common Test Setup  tc_name=FM__SC_to_Site_reset_escalation_fid_246
    Setup Netact


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    Teardown Netact
    Common Test Teardown
    ${fid10_alarms_status}  Run Keyword And Return Status  Should Not Be Empty  ${FID_10_ALARMS}
    IF  ${fid10_alarms_status}
        Check FID 10 In WebEM And Mantaray With The Help Of IMS and Syslog Files  ${TIMESTAMP_AFTER_FID_246}
        ...                                                                       ${RMODS_WITH_SYNCRO_ON_SC}
        ...                                                                       ${FID_10_ALARMS}
        ...                                                                       ${LAST_START_TIME}
    ELSE
        Log  FID 10 did not occure at all during escalation to Site Reset  console=true
    END
