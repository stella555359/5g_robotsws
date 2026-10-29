*** Settings ***
Documentation
    ...  Author: Lukasz Targonski

Library  OperatingSystem
Library  random
Library  taf.sbts.oam.coam.admin  WITH NAME  coam
Library  hran_pm
Resource  ../../../resources/verdicts.robot
Resource  ../../../resources/pm.robot
Resource  ../../../resources/pm_logs_frame.robot
Resource  ../../../resources/pm_logs_general.robot
Resource  ../../../resources/dcap.robot
# Resource  /taf/rfrl/common_resources/common_step/interface.robot
Resource  ../../../common_resources/ca_PM_general.robot


*** Variables ***
@{WNPMRNL_DICTIONARY}  @{EMPTY}
${WNPMRNL_PARAMETER}  ${EMPTY}


*** Keywords ***
TC__PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8144
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2018-03-06 - TC created. version 1.0
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-05-12 - TAT-23087 - Link to flowchart corrected
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...           checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-06-07 - TAT-25492 - Adding DCAP Keywords to TC Setup and TC Teardown for log collection
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is to verify that counters collection disabling works properly for WCDMA counters
    ...  *******************
    ...  Test case flowchart:
    ...  https://gitlabe1.ext.net.nokia.com/
    ...  panda-docs/hran_doc/-/raw/master/testsuite/SBTS/PM__WCDMA_measurement_interval_change-counters_collection_disabling.png
    ...  *******************

    Set Tags  CA-PM  OWNER-iuliia.taupeka@nokia.com  AUTHOR-lukasz.targonski@nokia.com  MAINTAINER-iuliia.taupeka@nokia.com  PHASE-CR1  SW-SBTS17

    Should Not Be Equal As Strings  ${WNPMRNL_PARAMETER}  ${EMPTY}  msg=Parameter name from WNPMRNL not provided.
    Step 0: Preconditions
    Step 1: Download PM From BTS
    Step 2: Change Measurements Interval
    Step 3: Download PM From BTS


Step 0: Preconditions
    Create WNPMRNL Dictionary
    Verify WCDMA Cells States

    ${critical_alarm}  Create Dictionary  faultId=26
    ${critical}  Create List  ${critical_alarm}
    bts_states.Check Active Alarms  critical_patterns=${critical}


Step 1: Download PM From BTS
    Log  Step1: Pm file is being downloaded from BTS, counter(s) presence is being checked  console=true
    Wait For BTS Counters
    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  export_type=configuration
    Setup Pm  scf_path=${BTS_FILES}/scf.xml

    ${parameters_list}  Get Regexp Matches  ${WNPMRNL_PARAMETER}  [a-zA-Z1-9][^,]*
    ${interval_list}  Create List
    FOR  ${elem}  IN  @{parameters_list}
        ${interval}  Get Scf Parameter  ${elem}
        Append To List  ${interval_list}  ${interval}
    END

    Set Test Variable  ${PARAMETERS_LIST}
    Set Test Variable  ${INTERVAL_LIST}
    ${pm_report_name}  Set Variable  PM_REPORT_before_parameter(s)_modification.xml
    Set Test Variable  ${PM_REPORT_NAME}
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
    ${bts_id}  bts_states.Get BTS ID

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
        ...  skip_parameter_relation_errors=${TRUE}
        ...  ELSE IF  '${INTERVAL_LIST[${int}]}'=='disabled'
        ...  Run Keywords
        ...  Log  Value of parameter ${parameter} is being changed from 'disabled' to '60min'  console=true
        ...  AND
        ...  coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/WNBTS-1/WNPMRNL-1
        ...  ${parameter}
        ...  update
        ...  60min
        ...  skip_parameter_relation_errors=${TRUE}
        ${int}  Evaluate  ${int}+1
    END


Step 3: Download PM From BTS
    Log  Step3: Pm file is being downloaded from BTS, counter(s) presence is being checked  console=true
    Wait For BTS Counters
    coam.Get Current Scf File  ${BTS_FILES}  scf_mod.xml  export_type=configuration
    Setup Pm  scf_path=${BTS_FILES}/scf_mod.xml

    ${interval_list}  Create List  @{EMPTY}
    FOR  ${elem}  IN  @{PARAMETERS_LIST}
        ${interval}  Get Scf Parameter  ${elem}
        Append To List  ${interval_list}  ${interval}
    END

    Set Test Variable  ${INTERVAL_LIST}
    ${pm_report_name}  Set Variable  PM_REPORT_after_parameter(s)_modification.xml
    Set Test Variable  ${PM_REPORT_NAME}
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


Create WNPMRNL Dictionary
    ${wnpmrnl_dictionary}  Create Dictionary  mtCellThrWBTS=Cell_Throughput_WBTS  mtFrameProtWBTS=Frame_Protocol_WBTS
    ...  mtHSPASchedMon=HSPA_Scheduler_Monitoring  mtHSPAWBTS=HSDPA_WBTS  mtHSPAWBTSExt=HSPA_WBTS_Extension  mtOperSpecStat=WBTS_Operator_Statistics
    ...  mtSIMonWBTS=WCDMA_SI_Monitoring  mtSignLoadWBTS=Signaling_Load_WBTS  mtWBTSLevelMon=WBTS_Level_Monitoring  mtWBTSR99Res=WBTS_R99_HW
    Set Test Variable  ${WNPMRNL_DICTIONARY}


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
    Run Keywords
    ...  Common Test Setup


TC Teardown
    Run Keywords
    ...  interface.Common Step Trigger
    ...  AND
    ...  Common Test Teardown
