*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
Variables    tc_variables/sbts_sbts_sbts_sbts__state__common_startup_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot
Resource    ../../resources/rfs_pdu.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of SBTS BTS Startup operations, default value 3
${SBTS_POWER_ON_WRN_THR}  600  # If BTS reset time exceeds SBTS_POWER_ON_WRN_THR, test verdict will be failed and snapshot collected
                               # Default value: in accordance with KPI 3 specifications
${SBTS_MAX_WAIT_TIME}  900  # Maximum time to wait for LTE BTS OnAir. If this value is exceeded, test will fail

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26629
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for all SBTS common startup procedure, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - perform power OFF operation on all BTS
    ...  - perform power ON operation on all BTS
    ...  - wait for startup on all BTS
    ...  - check reset behavior on all BTS based on IMS RESET info
    ...  - get and check KPI3 info from IMS file
    ...  Pass criteria: BTS startup works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 18.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26629 - [5G][CB009182-C002270-RP003030]new NR_SBTS__STATE__Common_Startup TC
    ...  which will run SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup In case of SBTS-NR configuration
    ...  - 14.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28570 -
    ...  [5G][CB011076] Pls increase the time after BTS ping available, after which checks are made through admin
    ...  - 08.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29996 -
    ...  SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup doesn't wait for slave BTS cells to be up more than 5 min
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26629_SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.png

    Set Tags    CA-STATE    OWNER-iasmina.dragity@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check PDU definition and reachability
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Power OFF all BTS
        Step 5: Power ON all BTS
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
        Step 9: Check BTS reset behavior based on IMS info
        Step 10: Get and check KPI3 info from IMS file for iteration ${INDEX}
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        ${remaining_time}=  Run Keyword If  '${when}'=='final'
        ...  Get Elapsed Time  ${date_timestamp_start_UTC}  ${SBTS_MAX_WAIT_TIME}
        ...  ELSE  Set Variable  480
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}
        ...  timeout=${remaining_time}  alias=${alias}

        ${remaining_time}=  Run Keyword If  '${when}'=='final'
        ...  Get Elapsed Time  ${date_timestamp_start_UTC}  ${SBTS_MAX_WAIT_TIME}
        ...  ELSE  Set Variable  600
        Admin Check BTS RAT Procedural State
        ...  alias=${alias}  timeout=${remaining_time}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Keyword used to check PDU definition and reachability for BTS

    Log  Step ${index}: Check PDU definition and reachability  console=True
    FOR  ${alias}  IN  @{alias_list}
        Check PDU definition and reachability  ${alias}
    END

Step ${index}: Power ${power} all BTS
    [Documentation]
    ...  Keyword used to power OFF/ON all BTS

    Log  Step ${index}: Power ${power} all BTS  console=True

    Run Keyword If  '${power}' == 'OFF'  Run Keywords
    ...  Log  BTS RESET info search from IMS file:  console=True
    ...  AND  Get Current Date UTC info  start
    ...  AND  Log  BTS RESET UTC start timestamp: ${date_timestamp_start_UTC}  console=True
    ...  AND  Sleep  10 sec

    FOR  ${alias}  IN  @{alias_list}
        Power BTS  ${alias}  ${power}
    END

    Run Keyword If  '${power}' == 'OFF'  Run Keywords
    ...  Log  Wait 1 min after all BTS are powered OFF  console=True
    ...  AND  Sleep  1 min

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True

	${remaining_MAX_WAIT_TIME}=  Get Elapsed Time  ${date_timestamp_start_UTC}  ${SBTS_MAX_WAIT_TIME}
    RFS Test Case Final Checks  wait_timer=${remaining_MAX_WAIT_TIME}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS reset behavior is checked based on IMS info
    ...  Reset behavior as expected in following conditions:
    ...  - BTS site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get Current Date UTC info  end
    Log  BTS RESET UTC end timestamp: ${date_timestamp_end_UTC}  console=True

    FOR  ${alias}  IN  @{alias_list}
        Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}  remove_ims_file=False
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Step ${index}: Get and check KPI3 info from IMS file for iteration ${CYCLE}
    [Documentation]
    ...  Get and check KPI3 info from IMS file.

    Log  Step ${index}: Get and check KPI3 info from IMS file for iteration ${CYCLE}  console=True
    FOR  ${alias}  IN  @{alias_list}
        Get and check KPI3 info  ${alias}  ${CYCLE}
    END

Check PDU definition and reachability
    [Documentation]
    ...  Helper Keyword used to check PDU definition and reachability

    [Arguments]  ${alias}

    Log  Check PDU definition and reachability  console=True
    ${BTS_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}
    Set Test Variable  ${${alias}_SM_PDU_if_name_list}  ${BTS_SM_PDU_if_name_list}
    ${PDU_port_status}=  Check BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
    Run Keyword if  ${PDU_port_status}
    ...  Log  ${alias} SMs PDU port status as expected  console=True  console=True
    ...  ELSE  Run Keywords
    ...  Log  PDU for ${alias} SMs is either not reachable or not switched on!  level=ERROR
    ...  AND  Fail  PDU for ${alias} SMs is either not reachable or not switched on!

Power BTS
    [Documentation]
    ...  Helper Keyword used to power ON/OFF BTS

    [Arguments]  ${alias}  ${power}
    Log  Power ${power} BTS ${alias}  console=True

    Get Current Date UTC info  power_${power.lower()}
    Log  BTS ${alias} power ${power} UTC timestamp: ${date_timestamp_power_${power.lower()}_UTC}  console=True
    Set Test Variable   ${${alias}_date_timestamp_power_${power.lower()}_UTC}  ${date_timestamp_power_${power.lower()}_UTC}

    Log  Power ${power} BTS ${alias}  console=True
    ${power}=  Convert To Lower Case  ${power}
    ${PDU_port_status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  ${power}
    Run Keyword If  ${PDU_port_status}
    ...  Log  ${alias} SMs PDU port status ${power}, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set ${alias} SMs PDU port status ${power} failed!  level=ERROR
    ...  AND  Fail  Set ${alias} SMs PDU port status on failed!
    Run Keyword If  '${power}' == 'on'  Run Keywords
    ...  Get Current Time  bts_initial
    ...  AND  Log  Power ON BTS ${alias} time is: ${time_bts_initial}  console=True
    ...  AND  Set Test Variable  ${${alias}_time_bts_initial}  ${time_bts_initial}

    ${BTS_TECH_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  '${power}' == 'OFF'
    ...  Wait For Target To Be Not Reachable TAF  hostname=${BTS_TECH_IP_address}  timeout=300  remote_host=${remote_host_ip}

Get and check KPI3 info
    [Documentation]
    ...  Helper Keyword used to get and check KPI3 info

    [Arguments]  ${alias}  ${CYCLE}
    Log  Get and check KPI3 info for BTS ${alias}  console=True

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi3  kpi_thresholds=${SBTS_POWER_ON_WRN_THR}  alias=${alias}
    ...  remove_ims_file=False  start_point_timestamp_UTC=${${alias}_date_timestamp_power_on_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi3
    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}  action_1=BTS_Power_On  kpi_reported_1=KPI_3
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword And Continue On Failure  Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}
    END
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
