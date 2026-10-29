*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that counters collection disabling works properly for WCDMA counters

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
@{WNPMRNL_DICTIONARY}  @{EMPTY}
${WNPMRNL_PARAMETER}  ${EMPTY}


*** Keywords ***
TC__PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-lukasz.targonski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Should Not Be Equal As Strings  ${WNPMRNL_PARAMETER}  ${EMPTY}  msg=Parameter name from WNPMRNL not provided.
    Step 0: Preconditions
    Step 1: Download PM From BTS
    Step 2: Change Measurements Interval
    Step 3: Download PM From BTS


Step 0: Preconditions
    ${wnpmrnl_dictionary}  Create Dictionary  mtCellThrWBTS=Cell_Throughput_WBTS  mtFrameProtWBTS=Frame_Protocol_WBTS
    ...  mtHSPASchedMon=HSPA_Scheduler_Monitoring  mtHSPAWBTS=HSDPA_WBTS  mtHSPAWBTSExt=HSPA_WBTS_Extension  mtOperSpecStat=WBTS_Operator_Statistics
    ...  mtSIMonWBTS=WCDMA_SI_Monitoring  mtSignLoadWBTS=Signaling_Load_WBTS  mtWBTSLevelMon=WBTS_Level_Monitoring  mtWBTSR99Res=WBTS_R99_HW
    Set Test Variable  ${WNPMRNL_DICTIONARY}


Step 1: Download PM From BTS
    Log  Step1: Pm file is being downloaded from BTS, counter(s) presence is being checked  console=true
    Wait For BTS Counters
    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf.xml

    ${parameters_list}  Get Regexp Matches  ${WNPMRNL_PARAMETER}  [a-zA-Z1-9][^,]*
    ${interval_list}  Create List
    Set Test Variable  ${INTERVAL_LIST}
    FOR  ${elem}  IN  @{parameters_list}
        ${interval}  Get Scf Parameter  ${elem}
        Append To List  ${INTERVAL_LIST}  ${interval}
    END
    Set Test Variable  ${PARAMETERS_LIST}

    Set Test Variable  ${PM_REPORT_NAME}  PM_REPORT_before_parameter(s)_modification.xml
    Read PM File
    ${output}  Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/${PM_REPORT_NAME}
    Run Keyword If  ${output}
    ...  Log  PM Report is present in ram disk  console=true
    ...  ELSE
    ...  FAIL  PM Report not present in ram disk
    Teardown All Aliases
    Check BTS Counters


Step 2: Change Measurements Interval
    Log  Step2: Measurement interval is being changed  console=true
    ${bts_id}  Admin Get BTS ID

    ${wait_before_parameter_mod}  Evaluate  random.randint(180,3420)  modules=random
    Log  Going to sleep for ${wait_before_parameter_mod} seconds  console=true
    Sleep  ${wait_before_parameter_mod}

    ${int}  Set Variable  0
    FOR  ${parameter}  IN  @{PARAMETERS_LIST}
        Run Keyword If  '${INTERVAL_LIST[${int}]}'=='60min'
        ...  Run Keywords
        ...  Log  Value of parameter ${parameter} is being changed from '60min' to 'disabled'  console=true
        ...  AND
        ...  coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/WNBTS-1/WNPMRNL-1
        ...  ${parameter}
        ...  update
        ...  disabled
        ...  skip_parameter_relation_errors=True
        ...  ELSE IF  '${INTERVAL_LIST[${int}]}'=='disabled'
        ...  Run Keywords
        ...  Log  Value of parameter ${parameter} is being changed from 'disabled' to '60min'  console=true
        ...  AND
        ...  coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/WNBTS-1/WNPMRNL-1  ${parameter}  update  60min
        ...  skip_parameter_relation_errors=True
        ${int}  Evaluate  ${int}+1
    END


Step 3: Download PM From BTS
    Log  Step3: Pm file is being downloaded from BTS, counter(s) presence is being checked  console=true
    Wait For BTS Counters
    coam.Get Current Scf File  ${BTS_FILES}  scf_mod.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf_mod.xml

    ${interval_list}  Create List  @{EMPTY}
    Set Test Variable  ${INTERVAL_LIST}
    FOR  ${elem}  IN  @{PARAMETERS_LIST}
        ${interval}  Get Scf Parameter  ${elem}
        Append To List  ${INTERVAL_LIST}  ${interval}
    END

    Set Test Variable  ${PM_REPORT_NAME}  PM_REPORT_after_parameter(s)_modification.xml
    Read PM File
    ${output}  Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/${PM_REPORT_NAME}
    Teardown All Aliases
    Check BTS Counters


Wait For BTS Counters
    ${minutes_now}  Get Time  minutes
    ${minutes_now}  Convert Time  ${minutes_now}
    ${time}  Evaluate  int(60*(61-${minutes_now}))

    Log  Wait (${time} seconds) for full hour and WBTS counters to appear on ram  console=true
    Sleep  ${time}

    Log  PM report is being downloaded from BTS  console=true
    Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/${PM_REPORT_NAME}


Check BTS Counters
    ${int}  Set Variable  0
    FOR  ${parameter}  IN  @{PARAMETERS_LIST}
        Loop Over Parameters  ${parameter}  ${int}
        ${int}  Evaluate  ${int}+1
    END


Loop Over Parameters
    [Arguments]  ${parameter}  ${int}

    ${measurement_type}  Get From Dictionary  ${WNPMRNL_DICTIONARY}  ${parameter}
    Log  Value of parameter ${parameter} is set to ${INTERVAL_LIST[${int}]}  console=true
    ${measurement_type}  Get From Dictionary  ${WNPMRNL_DICTIONARY}  ${parameter}
    ${grep}  OperatingSystem.Grep File  ${BTS_FILES}/${PM_REPORT_NAME}  ${measurement_type}
    ${grep}  Run Keyword And Ignore Error
    ...  Should Not Be Empty  ${grep}
    Run Keyword If  '${INTERVAL_LIST[${int}]}'=='60min' and '${grep[0]}'=='FAIL'
    ...  FAIL  measurementType= "${measurement_type}" is not present in PM report  console=true
    Run Keyword If  '${INTERVAL_LIST[${int}]}'=='60min' and '${grep[0]}'=='PASS'
    ...  Log  measurementType= "${measurement_type}" is present in PM report  console=true
    Run Keyword If  '${INTERVAL_LIST[${int}]}'=='disabled' and '${grep[0]}'=='FAIL'
    ...  Log  measurementType= "${measurement_type}" is not present in PM report  console=true
    Run Keyword If  '${INTERVAL_LIST[${int}]}'=='disabled' and '${grep[0]}'=='PASS'
    ...  FAIL  measurementType= "${measurement_type}" is present in PM report  console=true


TC Setup
    Common Test Setup  tc_name=PM__WCDMA_counters_collection_disabling


TC Teardown
    Common Test Teardown
