*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that measurement period change from longer to shorter for TNL counters works properly

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${PMTNL_PARAMETER_INTERVAL}  ${EMPTY}  # Provide TNL measurement with target interval. For example 'ipNodeStatisticsInterval=15min'


*** Keywords ***
TC__PM__TNL_measurement_interval_change_from_longer_to_shorter
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-lukasz.targonski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Step 0: Preconditions
    Step 1: Download PM From BTS
    Step 2: Change Measurements Interval
    Step 3: Check Incomplete Previous PM
    Step 4: Download PM From BTS
    Step 5: Change Back Measurement Interval


Step 0: Preconditions
    Log  \nStep 0: Preconditions  console=true
    Should Not Be Empty  ${PMTNL_PARAMETER_INTERVAL}  msg=Parameter name from PMTNL not provided.

    ${sw}  coam.Get Sw Version
    ${sw_version}  Get Substring  ${sw}  4  6
    ${target_tnl_distname}  Set Variable If  ${sw_version}>=22  TNLSVC-1/PMTNLINT-1  TNLSVC-1/TNL-1/PMTNL-1
    Set Test Variable  ${TARGET_TNL_DISTNAME}
    ${bts_id}  Admin Get BTS ID
    Set Test Variable  ${BTS_ID}
    Change Initial Values If Needed
    Create PMTNL Dictionary
    Setup Measurement Interval Dictionaries


Step 1: Download PM From BTS
    [Documentation]
    ...  In this step PM report from full measurement period is downloaded. Measurement presence before interval change is checked.

    Log  \nStep1: Pm report is being downloaded from BTS, counter(s) presence is being checked  console=true
    ${datetime}  Get Current Date  exclude_millis=True  result_format=datetime
    ${meas_start_ability_dates_dict}  Create Dictionary
    Set Test Variable  ${MEAS_START_ABILITY_DATES_DICT}
    Set Test Variable  ${DATETIME}

    ${uptime_date}  Check BTS Uptime
    Wait For Measurements Collection  ${uptime_date}
    Check Measurements Presence Before Interval Change


Step 2: Change Measurements Interval
    [Documentation]
    ...  In this step interval values are being changed from longer to shorter. Target TNL measurements parameters
    ...  located under MRBTS-bts_id/MNL-1/MNLENT-1/PMMNL-1 or MRBTS-bts_id/TNLSVC-1/TNL-1/PMTNL-1 (for SW releases up to SBTS21B)
    ...  or MRBTS-bts_id/TNLSVC-1/PMTNLINT-1 (SBTS 22R1 onwards) manadged objects in Info Model are modified

    Log  \nStep2: Measurement interval is being changed  console=true

    ${delta_id}  Set Variable  measurement_change
    coam.Create Delta  ${delta_id}
    FOR  ${meas}  IN  @{TARGET_MEAS_INTERVAL_DICT}
        Run Keyword If  '${meas}'=='s1X2TacStatisticsInterval' or '${meas}'=='topFreqSyncStatisticsInterval'
        ...  coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
        ...  ${meas}
        ...  ${TARGET_MEAS_INTERVAL_DICT['${meas}']}min
        ...  ${delta_id}
        ...  ELSE
        ...  coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/${TARGET_TNL_DISTNAME}
        ...  ${meas}
        ...  ${TARGET_MEAS_INTERVAL_DICT['${meas}']}min
        ...  ${delta_id}
        Log  Value of parameter ${meas} will be changed from:  console=true
        Log  ${P_MEAS_INTERVAL_DICT['${meas}']}min to ${TARGET_MEAS_INTERVAL_DICT['${meas}']}min  console=true
    END

    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta_1.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_1.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}


Step 3: Check Incomplete Previous PM
    [Documentation]
    ...  In this step it is checked if measurements are correctly reported after interval change.
    ...  Interval period reported in downladed PM file should be calculated based on the old interval and new interval period set in Step 2

    Log  \nStep3: Check incomplete previous PM report  console=true
    Calculate Measurement Start And Availability Dates For Incomplete Interval
    Check Measurements Presence


Step 4: Download PM From BTS
    [Documentation]
    ...  In this step it is checked if measurements from full interval period, set in Step 2, are collected.

    Log  \nStep4: Download PM From BTS  console=true
    Calculate Measurement Start And Availability Dates For Complete Interval
    Check Measurements Presence


Step 5: Change Back Measurement Interval
    [Documentation]
    ...  In this step intervals are changed back to values before intervals change in Step 2

    Log  \nStep5: Measurement interval values are changed back to previous values  console=true
    ${delta_id}  Set Variable  measurement_back
    coam.Create Delta  ${delta_id}
    FOR  ${meas}  IN  @{P_MEAS_INTERVAL_DICT}
        Run Keyword If  '${meas}'=='s1X2TacStatisticsInterval' or '${meas}'=='topFreqSyncStatisticsInterval'
        ...  coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  ${meas}  ${P_MEAS_INTERVAL_DICT['${meas}']}min
        ...  ${delta_id}
        ...  ELSE
        ...  coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/${TARGET_TNL_DISTNAME}  ${meas}  ${P_MEAS_INTERVAL_DICT['${meas}']}min
        ...  ${delta_id}
        Log  Value of parameter ${meas} will be changed to ${P_MEAS_INTERVAL_DICT['${meas}']}min  console=true
    END
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta_2.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_2.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}


Change Initial Values If Needed
    coam.Get Current Scf File  ${BTS_FILES}  SCF.xml  with_auto_configured_parameters=${TRUE}  timeout=30
    Setup Pm  scf_path=${BTS_FILES}/SCF.xml

    ${split}  Split String  ${PMTNL_PARAMETER_INTERVAL}  separator=,
    FOR  ${item}  IN  @{split}
        ${param_val}  Split String  ${item}  separator==
        ${status}  ${scf_interval}  Run Keyword And Ignore Error
        ...  Get Scf Parameter  ${param_val[0]}
        ${scf_interval}  Set Variable If  '${status}'=='FAIL' or '${scf_interval}'=='disabled'  0min  ${scf_interval}
        Continue For Loop If  '${scf_interval}'>'${param_val}[1]'

        ${new_initial_value}  Set Variable If  '${param_val}[1]'=='15min'  30min  60min
        ${distname}  Set Variable If  '${param_val}[0]'=='s1X2TacStatisticsInterval' or '${param_val}[0]'=='topFreqSyncStatisticsInterval'
        ...  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  MRBTS-${BTS_ID}/${TARGET_TNL_DISTNAME}
        coam.Perform Parameter Recommissioning  ${distname}  ${param_val}[0]  update  ${new_initial_value}  skip_parameter_relation_errors=True
        Sleep Until New Cycle  minutes_for_cycle=${scf_interval}
        Sleep Until New Cycle  minutes_for_cycle=${new_initial_value}  additional_condition=${True}
    END

    [Teardown]  Teardown Pm


Check Measurements Presence Before Interval Change
    [Documentation]
    ...  This keyword checkes if measurements are available in PM report for full measurement period
    ...  before that period is modified to shorter value

    ${datetime}  Get Current Date  exclude_millis=True  result_format=datetime
    FOR  ${meas}  IN  @{MEAS_START_ABILITY_DATES_DICT}
        ${meas_start_availability_list}  Calculate Measurement Availability Time  ${P_MEAS_INTERVAL_DICT}  ${meas}  ${datetime}
        Set To Dictionary  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}  ${meas_start_availability_list}
        ${timediff}  Subtract Date From Date  ${datetime}  ${MEAS_START_ABILITY_DATES_DICT['${meas}'][0]}
        ${timediff}  Evaluate  int(${timediff}/60)
        Run Keyword If  ${timediff}>60
        ...  Run Keywords
        ...  Log  Measurement ${meas} start date: ${MEAS_START_ABILITY_DATES_DICT['${meas}'][0]},  console=true
        ...  AND
        ...  Log  availability date: ${MEAS_START_ABILITY_DATES_DICT['${meas}'][1]}  console=true
        ...  AND
        ...  Wait For Measurements  ${MEAS_START_ABILITY_DATES_DICT['${meas}'][1]}
        ${calculated_interval}  Calculate Measurement Interval  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}
        ${time}  Get Current Date
        Download PM  ${meas}  ${calculated_interval}  ${time}
        Check Measurement In PM Report  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}  ${calculated_interval}  ${time}
    END


Download PM
    [Arguments]  ${meas}  ${calculated_interval}  ${time}

    Read PM File
    ${output}  Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/PM_REPORT_${meas}_${calculated_interval}min_${time}.xml
    Run Keyword If  ${output}
    ...  Log  PM report is present in ram disk  console=true
    ...  ELSE
    ...  FAIL  PM Report not present in ram disk


Check Measurement In PM Report
    [Documentation]
    ...  In this keyword it is checked if measurement with correct measurement start time and interval period is reported in PM file
    ...  previously downloaded from BTS.
    [Arguments]  ${m_ability_dates}  ${meas}  ${c_i}  ${time}

    Log  Measurement interval for ${meas} in the latest PM report should be equal to ${c_i}min  console=true
    ${o_me_s}  Parse XML  ${BTS_FILES}/PM_REPORT_${meas}_${c_i}min_${time}.xml
    ${var1}  Set Variable  //PMSetup[contains(@interval,
    ${var2}  Set Variable  contains(@startTime,
    ${var3}  Set Variable  :00.")]/PMMOResult/NE-WBTS_1.0[@measurementType=
    ${result}  Evaluate Xpath  ${o_me_s}
    ...  ${var1}"${c_i}") and ${var2}"${m_ability_dates['${meas}'][0].minute}${var3}"${PMTNL_DICTIONARY['${meas}']}"]

    Run Keyword If  '${result}'=='[]'
    ...  Set Test Failed  Measurement ${meas} not found in PM report.
    ...  ELSE
    ...  Log  Measurement ${meas} with correct interval found in PM report  console=true


Wait For Measurements Collection
    [Documentation]
    ...  This keyword checkes and waits if there was not enough time to collect counters for full measurement period after BTS startup.
    [Arguments]  ${uptime_date}

    FOR  ${meas}  IN  @{P_MEAS_INTERVAL_DICT}
        ${meas_start_availability_list}  Calculate Measurement Availability Time  ${P_MEAS_INTERVAL_DICT}  ${meas}  ${DATETIME}
        ${timediff}  Subtract Date From Date  ${meas_start_availability_list[0]}  ${uptime_date}
        ${timediff}  Evaluate  int(${timediff}/60)
        ${meas_start_availability_list}  Run Keyword If  ${timediff}<0
        ...  Calculate Measurements Start Time After Startup  ${meas_start_availability_list}  ${P_MEAS_INTERVAL_DICT['${meas}']}
        ...  ELSE
        ...  Set Variable  ${meas_start_availability_list}
        Set To Dictionary  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}  ${meas_start_availability_list}
        Run Keyword If  ${timediff}<${P_MEAS_INTERVAL_DICT['${meas}']}
        ...  Wait For Measurements  ${MEAS_START_ABILITY_DATES_DICT['${meas}'][1]}
    END


Calculate Measurement Start And Availability Dates For Incomplete Interval
    [Documentation]
    ...  In this keyword measurements start and availability dates for incomplete period are calculated.
    ...  Those dates are needed to calculate interval value that should be reported in PM file.

    ${p_meas_start_ability_dates_dict}  Create Dictionary
    ${datetime}  Get Current Date  exclude_millis=True  result_format=datetime
    FOR  ${meas}  IN  @{TARGET_MEAS_INTERVAL_DICT}
        ${meas_start_availability_list}  Calculate Measurement Availability Time  ${P_MEAS_INTERVAL_DICT}  ${meas}  ${datetime}
        Set To Dictionary  ${p_meas_start_ability_dates_dict}  ${meas}  ${meas_start_availability_list}
        ${meas_start_availability_list}  Calculate Measurement Availability Time  ${TARGET_MEAS_INTERVAL_DICT}  ${meas}  ${datetime}
        Set To Dictionary  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}  ${meas_start_availability_list}
        ${meas_start_ability_dates_dict}  Calculate Meas Start Incomplete Interval Period  ${MEAS_START_ABILITY_DATES_DICT}
        ...  ${p_meas_start_ability_dates_dict}  ${meas}
        Log  Measurement ${meas} start date: ${meas_start_ability_dates_dict['${meas}'][0]},  console=true
        Log  availability date: ${meas_start_ability_dates_dict['${meas}'][1]}  console=true
    END


Check Measurements Presence
    FOR  ${meas}  IN  @{MEAS_START_ABILITY_DATES_DICT}
        Wait For Measurements  ${MEAS_START_ABILITY_DATES_DICT['${meas}'][1]}
        ${calculated_interval}  Calculate Measurement Interval  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}
        ${time}  Get Current Date
        Download PM  ${meas}  ${calculated_interval}  ${time}
        Check Measurement In PM Report  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}  ${calculated_interval}  ${time}
    END


Calculate Measurement Start And Availability Dates For Complete Interval
    [Documentation]
    ...  In this keyword measurements start and availability dates for complete period are calculated.
    ...  Those dates are needed to calculate interval value that should be reported in PM file.

    ${p_meas_start_ability_dates_dict}  Copy Dictionary  ${MEAS_START_ABILITY_DATES_DICT}
    ${datetime}  Get Current Date  exclude_millis=True  result_format=datetime
    FOR  ${meas}  IN  @{TARGET_MEAS_INTERVAL_DICT}
        ${meas_start_availability_list}  Calculate Measurement Availability Time  ${TARGET_MEAS_INTERVAL_DICT}  ${meas}  ${datetime}
        Set To Dictionary  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}  ${meas_start_availability_list}
        ${timediff}  Subtract Date From Date  ${MEAS_START_ABILITY_DATES_DICT['${meas}'][0]}  ${p_meas_start_ability_dates_dict['${meas}'][1]}
        ${timediff}  Evaluate  int(${timediff}/60)
        ${meas_start_availability_list}  Run Keyword If  '${timediff}'>='${TARGET_MEAS_INTERVAL_DICT['${meas}']}'
        ...  Calculate Measurement Availability Time  ${TARGET_MEAS_INTERVAL_DICT}  ${meas}  ${p_meas_start_ability_dates_dict['${meas}'][1]}
        ...  ELSE
        ...  Calculate Measurement Availability Time  ${TARGET_MEAS_INTERVAL_DICT}  ${meas}  ${datetime}
        Set To Dictionary  ${MEAS_START_ABILITY_DATES_DICT}  ${meas}  ${meas_start_availability_list}
        Log  Measurement ${meas} start date: ${MEAS_START_ABILITY_DATES_DICT['${meas}'][0]},  console=true
        Log  availability date: ${MEAS_START_ABILITY_DATES_DICT['${meas}'][1]}  console=true
    END


Calculate Measurement Availability Time
    [Arguments]  ${target_meas_interval_dict}  ${meas}  ${dt}

    ${meas_int}  Get From Dictionary  ${target_meas_interval_dict}  ${meas}
    ${minutes_to_measurement_end_time}  Evaluate  int((${dt.hour}*60+${dt.minute})/int(${meas_int})+1)*int(${meas_int})-${dt.hour}*60-${dt.minute}
    ${meas_ability_time}  Add Time To Date  ${dt}  ${minutes_to_measurement_end_time} minutes
    ${meas_ability_time}  Subtract Time From Date  ${meas_ability_time}  ${dt.second} seconds  exclude_millis=True  result_format=datetime
    ${measurement_start_time}  Subtract Time From Date  ${meas_ability_time}  ${meas_int} minutes  exclude_millis=True  result_format=datetime
    ${meas_start_availability_list}  Create List  ${measurement_start_time}  ${meas_ability_time}

    RETURN  ${meas_start_availability_list}


Wait For Measurements
    [Documentation]
    ...  This keyword calculate time diff between measurement availability time and current time
    ...  and wait if time diff > 0
    [Arguments]  ${meas_ability_time}

    ${current_date}  Get Current Date  exclude_millis=True  result_format=datetime
    ${minutes_to_full_hour}  Run Keyword If  '${meas_ability_time.minute}'!='0'
    ...  Evaluate  60 - ${meas_ability_time.minute}
    ...  ELSE
    ...  Set Variable  0
    ${pm_report_availability_time}  Add Time To Date  ${meas_ability_time}  ${minutes_to_full_hour} minutes  result_format=datetime
    ${timediff}  Subtract Date From Date  ${pm_report_availability_time}  ${current_date}
    ${timediff}  Evaluate  ${timediff}+120
    Run Keyword If  ${timediff}>0
    ...  Run Keywords
    ...  Log  Wait until ${pm_report_availability_time} + 2 mins for full PM report to appear on ram  console=true
    ...  AND
    ...  Sleep  ${timediff}


Calculate Measurement Interval
    [Arguments]  ${meas_start_ability_dates_dict}  ${meas}

    ${meas_start_ability_dates}  Get From Dictionary  ${meas_start_ability_dates_dict}  ${meas}
    ${calculated_interval}  Subtract Date From Date  ${meas_start_ability_dates}[1]  ${meas_start_ability_dates}[0]
    ${calculated_interval}  Evaluate  int(${calculated_interval}/60)

    RETURN  ${calculated_interval}


Calculate Meas Start Incomplete Interval Period
    [Arguments]  ${meas_start_ability_dates_dict}  ${p_meas_start_ability_dates_dict}  ${meas}

    ${meas_start_ability}  Get From Dictionary  ${meas_start_ability_dates_dict}  ${meas}
    ${p_meas_start_ability}  Get From Dictionary  ${p_meas_start_ability_dates_dict}  ${meas}
    Set List Value  ${meas_start_ability}  0  ${p_meas_start_ability}[0]

    RETURN  ${meas_start_ability_dates_dict}


Calculate Measurements Start Time After Startup
    [Arguments]  ${meas_start_availability_list}  ${interval}

    ${measurement_start_time}  Add Time To Date  ${meas_start_availability_list[0]}  ${interval} minutes  result_format=datetime
    ${meas_ability_time}  Add Time To Date  ${meas_start_availability_list[1]}  ${interval} minutes  result_format=datetime
    Set List Value  ${meas_start_availability_list}  0  ${measurement_start_time}
    Set List Value  ${meas_start_availability_list}  1  ${meas_ability_time}

    RETURN  ${meas_start_availability_list}


Setup Measurement Interval Dictionaries
    [Documentation]
    ...  This keyword is used to setup two dictionaries, used in other keywords, that contain measurements names with target interval values
    ...  and interval values before modifiation.

    ${target_meas_interval_dict}  Create Dictionary
    ${p_meas_interval_dict}  Create Dictionary
    Set Test Variable  ${TARGET_MEAS_INTERVAL_DICT}
    Set Test Variable  ${P_MEAS_INTERVAL_DICT}
    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}  timeout=30
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${split}  Split String  ${PMTNL_PARAMETER_INTERVAL}  separator=,
    FOR  ${item}  IN  @{split}
        ${param_val}  Split String  ${item}  separator==
        ${target_interval}  Fetch From Left  ${param_val[1]}  min
        Set To Dictionary  ${TARGET_MEAS_INTERVAL_DICT}  ${param_val[0]}=${target_interval}
        ${scf_interval}  Get Scf Parameter  ${param_val[0]}
        ${scf_interval}  Fetch From Left  ${scf_interval}  min
        Set To Dictionary  ${P_MEAS_INTERVAL_DICT}  ${param_val[0]}=${scf_interval}
        Run Keyword If  '${TARGET_MEAS_INTERVAL_DICT['${param_val[0]}']}'>='${P_MEAS_INTERVAL_DICT['${param_val[0]}']}'
        ...  FAIL  Target interval for '${param_val[0]}' is`t shorter than current interval: ${P_MEAS_INTERVAL_DICT['${param_val[0]}']}
    END


Create PMTNL Dictionary
    [Documentation]
    ...  Keyword to create dictionary that contain measurements abbreviation from SCF
    ...  corresponding to measurements names in PM file downloaded from BTS

    ${pmtnl_dictionary}  Create Dictionary  ethernetInterfaceStatisticsInterval=ETHIF_stats  ethernetLinkInterval=ETHLK_stats
    ...  vlanStatisticsInterval=VLAN_stats  ipInterfaceStatisticsInterval=IPIF_stats  ipV4AddressStatisticsInterval=IPv4_addr_stats
    ...  ipNodeStatisticsInterval=IPNO_stats  tcpUdpStatisticsInterval=TCP_UDP_stats  sctpStatisticsInterval=SCTP_stats
    ...  ipFilteringInterval=IP_filtering_Stats  secondLevelSchedulerStatisticsInterval=SCDSCH_stats  ipPerHopBehaviourStatisticsInterval=PHB_stats
    ...  bridgePortStatisticsInterval=Bridge_Port_Stats  s1X2TacStatisticsInterval=S1_X2_TAC_Stats  topFreqSyncStatisticsInterval=TOP_FreqSync_stats
    Set Test Variable  ${PMTNL_DICTIONARY}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
