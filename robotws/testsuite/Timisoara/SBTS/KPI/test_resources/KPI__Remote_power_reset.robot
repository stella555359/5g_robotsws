*** Settings ***
Documentation
    ...  Thic TC is performing sbts power reset with or without snapshot collection depending on RESET_WITH_SNAPSHOT
    ...  value.
    ...  TC is waiting for all cells to be onAir and kpi11a and kpi11b are calculated.
    ...  If cells are not operational after RESTORE_TIMEOUT or unexpected alarms are active, TC will fail and snapshot
    ...  will be collected.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  20  # Time needed to restore BTS after power reset, default value 20 min.
${RESET_WITH_SNAPSHOT}  ${False}
${WAIT_FOR_RECONNECTION}  ${True}
${POWER_RESET_TIMEOUT}  1800
${LSS_USERNAME}  coam
${LSS_PASSWORD}  zO&n1W*ktp7
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}
${CALCULATE_RESET_DURATION}  ${False}


*** Keywords ***
TC__KPI__Remote_power_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.int.net.nokia.com/browse/TAT-23632
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  02.09.2022 - https://jiradc.int.net.nokia.com/browse/TAT-23632 - Initial creation
    ...  20.12.2022 - https://jiradc.int.net.nokia.com/browse/TAT-24332 - Wrong keyword for check SBTS state
    ...  04.01.2023 - https://jiradc.int.net.nokia.com/browse/TAT-24385 - Add check if snapshot is collected in netact
    ...  10.01.2023 - https://jiradc.int.net.nokia.com/browse/TAT-24445 - Add check if snapshot is collected on lss server
    ...  06.02.2023 - https://jiradc.int.net.nokia.com/browse/TAT-24670 - Add Wait for reconnection parameter
    ...  13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25540 - Add option for activating graceful cell shutdown before reset
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26611 - Add calculation for reset duration
    ...  18.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28095 - Update keywords handling netact data
    ...  13.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30070 - Add kpi11b
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007040

    Step 1: SBTS Power Reset
    Step 2: SBTS Is Restored


Step 1: SBTS Power Reset
    Log  \nStep 1: SBTS Power reset  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  update_interval=500  name=collect_infomodel_log
    Sleep  10s
    ${current_time}  Get Current Date  result_format=%Y%m%d-%H%M
    ${initial_timestamp}  Convert To String  ${current_time}
    Set Test Variable  ${INITIAL_TIMESTAMP}
    IF  ${RESET_WITH_SNAPSHOT}  Set Length For Initial Snapshot List
    Log  Power reset is performing.  console=true
    coam.Power Reset  reset_with_snapshot=${RESET_WITH_SNAPSHOT}  wait_for_reconnection=${WAIT_FOR_RECONNECTION}  timeout=${POWER_RESET_TIMEOUT}
    ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  connection=collect_infomodel_log


Step 2: SBTS Is Restored
    Log  \nStep 2: SBTS is restored\nCheck BTS and Cells states after reset\nWait ${RESTORE_TIMEOUT} mins for the states to be as expected
    ...  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  60s
    ...  Admin Check All Required State
    ${list_of_active_alarms}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    ${length}  Get Length  ${list_of_active_alarms}
    IF  ${length}>0  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}
    IF  ${RESET_WITH_SNAPSHOT}  Check If Snapshot Is Saved


Set Length For Initial Snapshot List
    ${parameter_object}  coam.Get Managed Objects  TRBLCADM_A
    Set Test Variable  ${TRBLCADM_OBJECT}  ${parameter_object}[0][parameters]
    IF  '${TRBLCADM_OBJECT}[diagSnapDestination]'=='nms'
        ${snapshot_lines}  Get Snapshots Saved In Netact
    ELSE
        ${snapshot_lines}  Get Snapshots Saved In Lss
    END
    ${initial_length}  Get Length  ${snapshot_lines}
    Set Test Variable  ${INITIAL_LENGTH}


Get Snapshots Saved In Netact
    ${netact_info}  coam.Get Nms State
    ${manager_id}  Get Manager Id For NetAct  ${netact_info}
    ${web_url}  ${netact_name}  Get Web Url And Netact Name  ${manager_id}
    Open Ssh Connection To NetAct  ${web_url}
    ${snapshot_files}  SSHLibrary.Execute Command  ls -l /d/oss/global/diagsnap/ne3sws/ | grep ${BTS_ID}
    SSHLibrary.Close Connection
    ${snapshot_lines}  Split To Lines  ${snapshot_files}

    RETURN  ${snapshot_lines}


Get Snapshots Saved In Lss
    SSHLibrary.Open Connection  ${TRBLCADM_OBJECT}[lssConfig][lssIPaddress]
    ${status}  Run Keyword And Return Status
    ...  SSHLibrary.Login  ${LSS_USERNAME}  ${LSS_PASSWORD}
    IF  ${status}==${FALSE}  Fail  TC couldn't connect to lss server: ${TRBLCADM_OBJECT}[lssConfig][lssIPaddress].
    ${snapshot_files}  SSHLibrary.Execute Command  ls -l /home/coam | grep ${BTS_ID}
    SSHLibrary.Close Connection
    ${snapshot_lines}  Split To Lines  ${snapshot_files}

    RETURN  ${snapshot_lines}



Check If Snapshot Is Saved
    Log  Check if snapshot is saved on ${TRBLCADM_OBJECT}[diagSnapDestination] server.  console=true
    IF  '${TRBLCADM_OBJECT}[diagSnapDestination]'=='nms'
        ${snapshot_lines}  Get Snapshots Saved In Netact
    ELSE
        ${snapshot_lines}  Get Snapshots Saved In Lss
    END
    ${snapshot_list_length}  Get Length  ${snapshot_lines}
    ${timestamp_list}  Create List
    FOR  ${line}  IN  @{snapshot_lines}
        ${snapshot_name}  Fetch From Right  ${line}  ${SPACE}
        ${timestamp}  Fetch From Right  ${snapshot_name}  _
        ${timestamp}  Remove String  ${timestamp}  .zip
        Append To List  ${timestamp_list}  ${timestamp}
    END
    Sort List  ${timestamp_list}
    IF  ${snapshot_list_length}>${INITIAL_LENGTH} and '${timestamp_list}[-1]'>='${INITIAL_TIMESTAMP}'
        Log  Snapshot is collected: ${snapshot_name}.  console=true
    ELSE
        Fail  Snapshot was not collected!
    END


Calculate SBTS Remote Power Reset Duration
    ${kpiremotepowerreset}  Calculate Kpiremotepowerreset  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    Log Delta In Seconds  ${kpiremotepowerreset}[kpiremotepowerreset][-1][delta]  kpiremotepowerreset
    Save Delta Results  kpiremotepowerreset


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__Remote_power_reset


TC Teardown
    Collect Infomodel Log From Current Session  target_file_name=${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    ...  connection=collect_infomodel_log
    Teardown Admin  connection=collect_infomodel_log
    Common Test Teardown
    ${kpis_to_be_calculated}  Create List  kpi11a  kpi11b
    ${kpi11}  Calculate Kpis  ${kpis_to_be_calculated}  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi11}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END
    IF  ${CALCULATE_RESET_DURATION}  Calculate SBTS Remote Power Reset Duration
    Set Log Level  TRACE
