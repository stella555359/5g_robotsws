*** Settings ***
Documentation
...  This TC can run on NR, LTE and TNL.
...  For every cases, parameters under PMRNL, NRPMRNL and PMTNLINT if corresponding technology exists on SBTS will be set on 30 min and 15 min for
...  branches older than 25R3. For branches starting from 25R3, parameters will be set on 15 min and 5 min.
...  Then TC waits until two higher value min time intervals and then for lower value min intervals to save the number of all counters and the one
...  of counters set on 0.
...  These values are obtained by extracting counter objects from xml PM files.
...  In the end TC compares the number for both time intervals for each existing technology.
...  The number of all counters should be the same and the number of counters set on 0 can be different.
...  There can be cases when some parameters cannot be set on 5 min and the corresponding counters should be added as exceptions when comparing all
...  counters.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
# COUNTERS_MATCH variables can be string or list of strings delimited by commas. They are counters prefix, e.g: M80 or M800,M801.
${NR_COUNTERS_MATCH}  M55
${LTE_COUNTERS_MATCH}  M80
${TNL_COUNTERS_MATCH}  M51


*** Keywords ***
TC__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28694
    ...
    ...  *******************
    ...  History of changes
    ...  - 03.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28694 - Initial TC creation
    ...  - 26.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28833 - TC adaptation for NR, LTE and TNL
    ...  - 11.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28906 - Set parameters to 15min if test failed
    ...  - 14.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28934 - Refactor parameters update
    ...  - 17.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29415 - Exclude some parameters from being set on 5 min
    ...  - 18.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29417 - Adapt TC to work on multiple branches
    ...  - 23.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29445 - Add PMMNL parameters
    ...  - 07.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29530 - Add LNBTS PMRNL counters exception
    ...  - 27.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29784 - Ignore mtBtsRestApiStatistics parameter
    ...  - 08.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30002 - Fix excluding disabled parameters
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf

    Step0: TC Variables
    Step1: Set Meas And Reporting Interval To ${HIGHER_VALUE}
    Step2: Wait Two ${HIGHER_VALUE} Intervals And Set Counters Number From Last PM Report
    Step3: Set Meas And Reporting Interval To ${LOWER_VALUE}
    Step4: Wait Two ${LOWER_VALUE} Intervals And Set Counters Number From Last PM Report
    Step5: Compare Counters Numbers


Step0: TC Variables
    ${higher_value}  Set Variable If  '${ENB_BRANCH}' <= 'SBTS25R2'  30min  15min
    ${lower_value}  Set Variable If  '${ENB_BRANCH}' <= 'SBTS25R2'  15min  5min
    Set Test Variable  ${HIGHER_VALUE}
    Set Test Variable  ${LOWER_VALUE}

    ${PARAMETERS_TO_UPDATE}  Create Dictionary
    Set Test Variable  ${PARAMETERS_TO_UPDATE}
    ${rat_list}  Create List  TNL
    IF  ${SCF_COUNT_NR}  Run Keywords  Set NRPMRNL Parameters  AND  Append To List  ${rat_list}  NR
    IF  ${SCF_COUNT_LTE}  Run Keywords  Set PMRNL Parameters  AND  Append To List  ${rat_list}  LTE
    Set PMTNLINT And PMMNL Parameters
    Set Test Variable  ${RAT_LIST}


Step${index}: Set Meas And Reporting Interval To ${new_value}
    Log  \nStep${index}: Set Meas And Reporting Interval To ${new_value}  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}

    IF  '${new_value}' == '5min'
        Remove Values From List  ${PARAMETERS_TO_UPDATE}[MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1]  pdhInterfaceStatisticsInterval
        ...  pppLinkStatisticsInterval  pppMultiLinkStatisticsInterval  pppSingleLinkStatisticsInterval
        Remove Values From List  ${PARAMETERS_TO_UPDATE}[MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1]  cteStatisticsInterval  dteStatisticsInterval
        ...  loosePhaseAndTimeStatisticsInterval  mtSBTSAntennaLine
    END

    FOR  ${path}  IN  @{PARAMETERS_TO_UPDATE}
        Add Parameters To Delta  ${path}  ${PARAMETERS_TO_UPDATE}[${path}]  ${new_value}  ${delta_id}
    END
    ${param_list}  Create List  reportingIntervalPm
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    IF  '${parameter}[0][parameters][reportingIntervalPm]'!='${new_value}'  Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ...  reportingIntervalPm  ${new_value}  ${delta_id}

    ${delta}  Get Delta  ${delta_id}
    ${delta_is_empty}  Run Keyword And Return Status  Should Be Equal As Strings  ${delta}  []
    IF  ${delta_is_empty}  RETURN

    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=True

    [Teardown]  Run Keywords  Remove Delta  ${delta_id}  AND  Run keyword And Ignore Error  Remove File  ${BTS_Files}/delta.json


Step${index}: Wait Two ${interval_to_wait} Intervals And Set Counters Number From Last PM Report
    Log  \nStep${index}: Wait Two ${interval_to_wait} Intervals And Set Counters Number From Last PM Report  console=true
    Repeat Keyword  2 times  Sleep Until New Cycle  minutes_for_cycle=${interval_to_wait}
    Sleep  1min  TC waits until counters are fully loaded.

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]

    ${last_xml_file}  ${counters_dict}  Get PM File And Counters Number For TNL And List Of RATs  ${RAT_LIST}
    Log  \nNumber of counters with meas set on ${interval_to_wait}: \n${counters_dict}  console=true
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/${last_xml_file}  ${BTS_FILES}/PM_Report_WITH_MEAS_SET_ON_${interval_to_wait}.xml

    Set Test Variable  ${COUNTERS_DICT_WITH_${interval_to_wait}_INTERVAL}  ${counters_dict}

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/test_${last_xml_file}  AND  SSHLibrary.Close Connection


Step5: Compare Counters Numbers
    Log  \nStep5: Compare Counters Numbers  console=true

    FOR  ${tech}  IN  @{COUNTERS_DICT_WITH_${HIGHER_VALUE}_INTERVAL}

        ${counters_on_0_higher}  Set Variable  ${COUNTERS_DICT_WITH_${HIGHER_VALUE}_INTERVAL}[${tech}][counters_set_on_0]
        ${counters_on_0_lower}  Set Variable  ${COUNTERS_DICT_WITH_${LOWER_VALUE}_INTERVAL}[${tech}][counters_set_on_0]
        ${counters_on_0_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${counters_on_0_higher}  ${counters_on_0_lower}
        IF  not ${counters_on_0_status}
            ${counters_diff}  Get Counters Differences Between 2 XML Files  ${BTS_FILES}/PM_Report_WITH_MEAS_SET_ON_${HIGHER_VALUE}.xml
            ...  ${BTS_FILES}/PM_Report_WITH_MEAS_SET_ON_${LOWER_VALUE}.xml  ${${tech}_COUNTERS_MATCH}  counters_type=set_on_0
            ${log_message}  Catenate  ${tech} counters set on 0 differ for ${HIGHER_VALUE} and ${LOWER_VALUE} intervals.
            ...  \nFollowing ${tech} counters are different:\n${counters_diff}.
            Log  ${log_message}  level=WARN
        END

        ${all_counters_higher}  Set Variable  ${COUNTERS_DICT_WITH_${HIGHER_VALUE}_INTERVAL}[${tech}][counters_number]
        ${all_counters_lower}  Set Variable  ${COUNTERS_DICT_WITH_${LOWER_VALUE}_INTERVAL}[${tech}][counters_number]
        ${all_counters_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${all_counters_higher}  ${all_counters_lower}
        IF  not ${all_counters_status}
            ${counters_diff}  Get Counters Differences Between 2 XML Files  ${BTS_FILES}/PM_Report_WITH_MEAS_SET_ON_${HIGHER_VALUE}.xml
            ...  ${BTS_FILES}/PM_Report_WITH_MEAS_SET_ON_${LOWER_VALUE}.xml  ${${tech}_COUNTERS_MATCH}  counters_type=all
            ${var_exists}  Run Keyword And Return Status  Variable Should Exist  ${${tech}_EXCEPTIONS}
            IF  ${var_exists}
                Remove Values From List  ${counters_diff}  @{${tech}_EXCEPTIONS}
                ${no_of_counters_diff}  Get Length  ${counters_diff}
                IF  ${no_of_counters_diff}==0  CONTINUE
            END
            Log  Number of all ${tech} counters differ. \nFollowing ${tech} counters are different:\n${counters_diff}.  level=ERROR
            Set Test Failed  Number of all ${tech} counters differ. \nFollowing ${tech} counters are different:\n${counters_diff}.
        END
    END


Set NRPMRNL Parameters
    ${nrbts_id}  Admin Get NRBTS ID
    ${nrpmrnl_path}  Set Variable  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRPMRNL-1
    ${nrpmrnl_parameters}  Get Parameter By Distname  ${nrpmrnl_path}
    ${nrpmrnl_parameters}  Set Variable  ${nrpmrnl_parameters}[0][parameters]
    Remove From Dictionary  ${nrpmrnl_parameters}  nrPmRnlId
    Remove From Dictionary  ${nrpmrnl_parameters}  ulUeThptMethod
    Remove From Dictionary  ${nrpmrnl_parameters}  nrRTPMMeasurementsList

    ${additional_nr_parameters}  Create Dictionary
    ${meas_list}  Create List  miNrRipSamples  miNrStrMeasure
    FOR  ${meas}  IN  @{meas_list}
        IF  '${meas}' in @{nrpmrnl_parameters.keys()}
            Set To Dictionary  ${additional_nr_parameters}  ${meas}=${nrpmrnl_parameters}[${meas}]
            Remove From Dictionary  ${nrpmrnl_parameters}  ${meas}
        END
    END

    ${meas_list}  Create List  miNrCABMCCP  miNrNgcFlexInterface  miNrRelReportCu  miNrEcpriUpFCp
    FOR  ${meas}  IN  @{meas_list}
        IF  '${meas}' in @{nrpmrnl_parameters.keys()}
            IF  '${nrpmrnl_parameters}[${meas}]'=='disabled'  Remove From Dictionary  ${nrpmrnl_parameters}  ${meas}
        END
    END

    FOR  ${key}  ${value}  IN  &{nrpmrnl_parameters}
         IF  '${value}' == 'disabled'  Remove From Dictionary  ${nrpmrnl_parameters}  ${key}
    END

    ${additional_nr_parameters}  Get Dictionary Keys  ${additional_nr_parameters}
    ${existing_meas}  Get Dictionary Keys  ${nrpmrnl_parameters}
    Set Test Variable  ${ADDITIONAL_NR_PARAMETERS}
    Set To Dictionary  ${PARAMETERS_TO_UPDATE}  ${nrpmrnl_path}=${existing_meas}


Set PMRNL Parameters
    ${lnbts_id}  Admin Get LNBTS ID
    ${pmrnl_path}  Set Variable  MRBTS-${BTS_ID}/LNBTS-${lnbts_id}/PMRNL-1
    ${pmrnl_parameters}  Get Parameter By Distname  ${pmrnl_path}
    ${pmrnl_parameters}  Set Variable  ${pmrnl_parameters}[0][parameters]
    Remove From Dictionary  ${pmrnl_parameters}  pmRnlId
    Remove From Dictionary  ${pmrnl_parameters}  mtSIMonitoring
    FOR  ${key}  ${value}  IN  &{pmrnl_parameters}
         IF  '${value}' == 'disabled'  Remove From Dictionary  ${pmrnl_parameters}  ${key}
    END
    ${pmrnl_keys}  Get Dictionary Keys  ${pmrnl_parameters}
    Set To Dictionary  ${PARAMETERS_TO_UPDATE}  ${pmrnl_path}=${pmrnl_keys}

    ${LTE_EXCEPTIONS}  Create List  <M8049C0>  <M8049C1>  <M8049C2>  <M8049C3>
    Set Test Variable  ${LTE_EXCEPTIONS}


Set PMTNLINT And PMMNL Parameters
    ${tnlint_path}  Set Variable  MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    ${tnlint_parameters}  Get Parameter By Distname  ${tnlint_path}
    ${tnlint_parameters}  Set Variable  ${tnlint_parameters}[0][parameters]
    Remove From Dictionary  ${tnlint_parameters}  pmTnlIntId
    Remove From Dictionary  ${tnlint_parameters}  ipDataTrafficVolumeInterval
    FOR  ${key}  ${value}  IN  &{tnlint_parameters}
         IF  '${value}' == 'disabled'  Remove From Dictionary  ${tnlint_parameters}  ${key}
    END
    ${tnlint_keys}  Get Dictionary Keys  ${tnlint_parameters}
    Set To Dictionary  ${PARAMETERS_TO_UPDATE}  ${tnlint_path}=${tnlint_keys}

    ${pmmnl_path}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${pmmnl_parameters}  Get Parameter By Distname  ${pmmnl_path}
    ${pmmnl_parameters}  Set Variable  ${pmmnl_parameters}[0][parameters]
    Remove From Dictionary  ${pmmnl_parameters}  pmMnlId
    Remove From Dictionary  ${pmmnl_parameters}  actZeroCounterSuppression
    Remove From Dictionary  ${pmmnl_parameters}  mtBtsRestApiStatistics
    FOR  ${key}  ${value}  IN  &{pmmnl_parameters}
         IF  '${value}' == 'disabled'  Remove From Dictionary  ${pmmnl_parameters}  ${key}
    END
    ${pmmnl_keys}  Get Dictionary Keys  ${pmmnl_parameters}
    Set To Dictionary  ${PARAMETERS_TO_UPDATE}  ${pmmnl_path}=${pmmnl_keys}

    IF  '${LOWER_VALUE}'=='5min'
        ${TNL_EXCEPTIONS}  Create List  <M51323C0>  <M51323C1>  <M51323C2>  <M51323C3>  <M51323C4>  <M51323C5>
        Set Test Variable  ${TNL_EXCEPTIONS}
    END


Add Parameters To Delta
    [Arguments]  ${path}  ${meas_list}  ${new_value}  ${delta_id}
    FOR  ${meas}  IN  @{meas_list}
        ${param_list}  Create List  ${meas}
        ${meas_dict}  Get Parameter By Distname  ${path}  ${param_list}
        ${meas_current_value}  Set Variable  ${meas_dict}[0][parameters][${meas}]
        IF  '${meas_current_value}'!='${new_value}'  Append Parameter Update To Delta  ${path}  ${meas}  ${new_value}  ${delta_id}
    END
    IF  'NRBTS' in '${path}'  Change additional parameters for NR  ${path}  ${new_value}  ${delta_id}


Change additional parameters for NR
    [Arguments]  ${path}  ${new_value}  ${delta_id}

    ${new_value}  Remove String  ${new_value}  min
    FOR  ${meas}  IN  @{ADDITIONAL_NR_PARAMETERS}
        ${param_list}  Create List  ${meas}
        ${meas_dict}  Get Parameter By Distname  ${path}  ${param_list}
        ${meas_current_value}  Set Variable  ${meas_dict}[0][parameters][${meas}]
        IF  '${meas_current_value}'!='${new_value} minutes'  Append Parameter Update To Delta  ${path}  ${meas}
        ...  ${new_value} minutes  ${delta_id}
    END


TC Setup
    Common Test Setup  tc_name=PM__Measurements_Interval_Change_From_Longer_To_Shorter


TC Teardown
    Run Keyword If Test Failed  Step_in_teardown: Set Meas And Reporting Interval To ${LOWER_VALUE}
    Common Test Teardown
