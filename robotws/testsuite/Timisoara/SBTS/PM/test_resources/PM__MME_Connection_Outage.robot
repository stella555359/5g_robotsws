*** Settings ***
Documentation
...  This TC checks M8020C(0-6) counters in three 15min time intervals.
...  mtCellAvailability and reportingIntervalPm are set to 15min.
...  s1InducedCellDeactDelayTime is set to 300 (seconds).
...
...  First interval:
...    - LNMME object is locked
...    - TC waits for 180 seconds (in this time LTE cells are still enabled because s1InducedCellDeactDelayTime is not elapsed)
...    - LNMME object is unlocked
...    - TC waits for new 15min interval to check counters:
...        * M8020C5 (disabled samples) = difference between LNMME unavailable timestamp and LNMME available timestamp
...        * M8020C3 (enabled samples) = 900 - M8020C5
...
...  Second interval:
...    - LNMME object is locked until the end of current 15min interval
...    - TC waits for new 15min interval to check counters:
...        * M8020C3 (enabled samples) = LNMME unavailable timestamp - previous 15min interval start time
...        * M8020C5 (disabled samples) = 900 - M8020C3
...
...  Third interval:
...    - LNMME object is unlocked after 180 seconds
...    - TC waits for new 15min interval and this time counters are checked in particular for each LTE cell:
...        * M8020C5 (disabled samples) = LTE cell enabled timestamp - previous 15min interval start time
...        * M8020C3 (enabled samples) = 900 - M8020C5
...
...  Timestamps for LNMME and LTE cells are obtained from ims files collected for each interval.
...  Time difference between actual and expected values for counters have 1 second tolerance.

Library  ../../common_resources/python_resources/ims_parser.py
Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__MME_Connection_Outage
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28742
    ...
    ...  *******************
    ...  History of changes
    ...  - 11.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28742 - Initial TAT creation
    ...  - 07.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28742 - Exclude NB IoT cells
    ...  - 05.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29343 - Increase tolerance to 6 seconds
    ...  - 25.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29455 - Fix difference comparison with 6 seconds
    ...  - 04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29521 - Increase timeout for get_pm_counters kw
    ...  - 22.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29593 - Check PM report instead of admin api output
    ...  - 09.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30305 - Add watchdog alarms

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-LTE432

    Step0: TC Prerequisites
    Step1: Lock LNMME S1 Link
    Step2: Unlock LNMME S1 Link
    Step3: Wait Until New 15min Period And Check M8020 Counters
    Step4: Lock LNMME S1 Link
    Step5: Wait Until New 15min Period And Check M8020 Counters
    Step6: Unlock LNMME S1 Link
    Step7: Wait Until New 15min Period And Check M8020 Counters


Step0: TC Prerequisites
    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/PMRNL-1  mtCellAvailability  15min
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  15min
    Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}  s1InducedCellDeactDelayTime  300
    ${lncel_id_names_dict}  Get LTE Cells Name And Id
    ${lncel_names}  Get Dictionary Values  ${lncel_id_names_dict}
    Set Test Variable  ${LNCEL_ID_NAMES_DICT}
    Set Test Variable  ${LNCEL_NAMES}
    ${lnmme_ids}  Get Ids For All  LNMME
    Set Test Variable  ${LNMME_DN}  ${lnmme_ids}[0]

    Sleep Until New Cycle  15min
    Setup Admin  bts_host=${OAM_BTS_IP}  name=save_ims2  update_interval=1


Step1: Lock LNMME S1 Link
    Log  \n\nStep1: Lock LNMME S1 Link  console=true
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNMME-0  administrativeState  update  locked
    ...  skip_parameter_relation_errors=${True}  timeout=300
    Assert  LNMME  ${LNMME_DN}  s1LinkStatus=regex"Unavailable|unavailable"  timeout=180
    Sleep  180s  Wait 3 min to maintain LNMME locked according to TC requirements.
    Assert Every  LNCEL  operationalState=${ENABLED}


Step2: Unlock LNMME S1 Link
    Log  \n\nStep2: Unlock LNMME S1 Link  console=true
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNMME-0  administrativeState  update  unlocked
    ...  skip_parameter_relation_errors=${True}  timeout=300
    Assert Every  LNCEL  operationalState=${ENABLED}
    Assert  LNMME  ${LNMME_DN}  s1LinkStatus=regex"Available|available"  timeout=180


Step3: Wait Until New 15min Period And Check M8020 Counters
    Log  \n\nStep3: Wait Until New 15min Period And Check M8020 Counters  console=true
    Sleep Until New Cycle  15min
    Sleep  1min  TC will wait until counters are fully loaded.
    ${expected_values}  Calculate M8020 Counters When Delay Time Has Not Elapsed
    Check M8020 Counters  ${expected_values}  When_Delay_Time_Has_Not_Elapsed


Step4: Lock LNMME S1 Link
    Log  \n\nStep4: Lock LNMME S1 Link  console=true
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNMME-0  administrativeState  update  locked
    ...  skip_parameter_relation_errors=${True}  timeout=300
    Assert  LNMME  ${LNMME_DN}  s1LinkStatus=regex"Unavailable|unavailable"  timeout=180
    Assert Every  LNCEL  operationalState=${DISABLED}  timeout=300


Step5: Wait Until New 15min Period And Check M8020 Counters
    Log  \n\nStep5: Wait Until New 15min Period And Check M8020 Counters  console=true
    Sleep Until New Cycle  15min
    Sleep  1min  TC will wait until counters are fully loaded.
    ${expected_values}  Calculate M8020 Counters When Delay Time Has Elapsed
    Check M8020 Counters  ${expected_values}  When_Delay_Time_Has_Elapsed


Step6: Unlock LNMME S1 Link
    Log  \n\nStep6: Unlock LNMME S1 Link  console=true
    Sleep  120s  Time to wait according to TC requirements.
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNMME-0  administrativeState  update  unlocked
    ...  skip_parameter_relation_errors=${True}  timeout=300
    Assert  LNMME  ${LNMME_DN}  s1LinkStatus=regex"Available|available"  timeout=180
    Assert Every  LNCEL  operationalState=${ENABLED}  timeout=300


Step7: Wait Until New 15min Period And Check M8020 Counters
    Log  \n\nStep7: Wait Until New 15min Period And Check M8020 Counters  console=true
    Sleep Until New Cycle  15min
    Sleep  1min  TC will wait until counters are fully loaded.
    ${expected_values}  Calculate M8020 Counters Using Cells Status
    Check M8020 Counters  ${expected_values}  With_Different_Values_For_Cells


Get LTE Cells Name And Id
    ${lncels_params}  Get Parameters For All  LNCEL
    ${lncel_id_names}  Create Dictionary
    FOR  ${params}  IN  @{lncels_params}
        ${lncel_name}  Fetch From Right  ${params}[id]  /
        ${lncel_name}  Remove String  ${lncel_name}  _R
        Set To Dictionary  ${lncel_id_names}  ${params}[id]=${lncel_name}
    END

    RETURN  ${lncel_id_names}


Calculate M8020 Counters When Delay Time Has Not Elapsed
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/first_interval.ims2
    Collect Infomodel Log From Current Session  ${ims_path}  leave_disconnect_logs=True  connection=save_ims2
    Reset Admin  connection=save_ims2

    ${s1_link_unavailable}  Create Dictionary  s1LinkStatus=unavailable
    ${s1_link_available}  Create Dictionary  s1LinkStatus=available
    ${interval_start_time}  Get Previous 15min Interval Start Time
    ${unavailable_timestamp}  Get First Timestamp  ${ims_path}  ${LNMME_DN}  ${s1_link_unavailable}  search_after=${interval_start_time}
    ${available_timestamp}  Get First Timestamp  ${ims_path}  ${LNMME_DN}  ${s1_link_available}  search_after=${unavailable_timestamp}

    ${disabled_samples}  Subtract Date From Date  ${available_timestamp}  ${unavailable_timestamp}
    ${disabled_samples}  Evaluate  round(float(${disabled_samples}))
    ${enabled_samples}  Evaluate  900 - ${disabled_samples}

    ${expected_counters}  Create Dictionary
    ${expected_values}  Create Dictionary  M8020C0=${1}  M8020C1=${0}  M8020C2=${1}  M8020C3=${enabled_samples}  M8020C4=${0}
    ...  M8020C5=${disabled_samples}  M8020C6=${900}
    FOR  ${cell_name}  IN  @{LNCEL_NAMES}
        Set To Dictionary  ${expected_counters}  ${cell_name}=${expected_values}
    END

    RETURN  ${expected_counters}


Calculate M8020 Counters When Delay Time Has Elapsed
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/second_interval.ims2
    Collect Infomodel Log From Current Session  ${ims_path}  leave_disconnect_logs=True  connection=save_ims2
    Reset Admin  connection=save_ims2

    ${s1_link_unavailable}  Create Dictionary  s1LinkStatus=unavailable
    ${interval_start_time}  Get Previous 15min Interval Start Time
    ${unavailable_timestamp}  Get First Timestamp  ${ims_path}  ${LNMME_DN}  ${s1_link_unavailable}  search_after=${interval_start_time}

    ${enabled_samples}  Subtract Date From Date  ${unavailable_timestamp}  ${interval_start_time}
    ${enabled_samples}  Evaluate  round(float(${enabled_samples}))
    ${disabled_samples}  Evaluate  900 - ${enabled_samples}

    ${expected_counters}  Create Dictionary
    ${expected_values}  Create Dictionary  M8020C0=${0}  M8020C1=${0}  M8020C2=${1}  M8020C3=${enabled_samples}  M8020C4=${0}
    ...  M8020C5=${disabled_samples}  M8020C6=${900}
    FOR  ${cell_name}  IN  @{LNCEL_NAMES}
        Set To Dictionary  ${expected_counters}  ${cell_name}=${expected_values}
    END

    RETURN  ${expected_counters}


Calculate M8020 Counters Using Cells Status
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/third_interval.ims2
    Collect Infomodel Log From Current Session  ${ims_path}  leave_disconnect_logs=True  connection=save_ims2

    ${expected_counters}  Create Dictionary
    ${cell_enabled}  Create Dictionary  operationalState=enabled
    ${interval_start_time}  Get Previous 15min Interval Start Time

    FOR  ${cell_dn}  IN  @{LNCEL_ID_NAMES_DICT}
        ${cell_enabled_timestamp}  Get First Timestamp  ${ims_path}  ${cell_dn}  ${cell_enabled}  search_after=${interval_start_time}

        ${disabled_samples}  Subtract Date From Date  ${cell_enabled_timestamp}  ${interval_start_time}
        ${disabled_samples}  Evaluate  round(float(${disabled_samples}))
        ${enabled_samples}  Evaluate  900 - ${disabled_samples}

        ${expected_values}  Create Dictionary  M8020C0=${1}  M8020C1=${0}  M8020C2=${0}  M8020C3=${enabled_samples}  M8020C4=${0}
        ...  M8020C5=${disabled_samples}  M8020C6=${900}
        Set To Dictionary  ${expected_counters}  ${LNCEL_ID_NAMES_DICT}[${cell_dn}]=${expected_values}
    END

    RETURN  ${expected_counters}


Check M8020 Counters
    [Arguments]  ${counters_expected_value}  ${pm_report_type}

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=get_pm_report
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${last_xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    ${last_xml_file}  Remove String  ${last_xml_file}  test_
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/test_${last_xml_file}  ${BTS_FILES}/PM_Report_${pm_report_type}.xml

    ${required_counters}  Create List  M8020C0  M8020C1  M8020C2  M8020C3  M8020C4  M8020C5  M8020C6
    ${counters_new_value}  Get Counters From PM Report  pm_report_path=${BTS_FILES}/PM_Report_${pm_report_type}.xml
    ...  interval=15  measurement_name=LTE_Cell_Avail  counters=${required_counters}
    ${cells}  Get Dictionary Keys  ${counters_new_value}
    ${cells_diff}  Evaluate  list(set($cells) ^ set($LNCEL_NAMES))
    Should Be Empty  ${cells_diff}  Counters are not generated for the following LTE cells: ${cells_diff}.

    FOR  ${cell_name}  IN  @{counters_new_value}
        Log  \nNew values for ${cell_name} M8020 counters: ${counters_new_value}[${cell_name}].  console=true
        Log  Expected values for ${cell_name} M8020 counters: ${counters_expected_value}[${cell_name}].  console=true
        ${counters_are_as_expected}  Run Keyword And Return Status  Compare Dictionaries  ${counters_new_value}[${cell_name}]
        ...  ${counters_expected_value}[${cell_name}]
        IF  not ${counters_are_as_expected}  Set Test Failed  ${cell_name} counters don't have expected values.
    END

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/test_${last_xml_file}  AND  SSHLibrary.Close Connection


Get Counters From PM Report
    [Arguments]  ${pm_report_path}  ${interval}  ${measurement_name}  ${counters}

    ${o_me_s}  Parse XML  ${pm_report_path}
    ${required_xpath}  Set Variable  //PMSetup[@interval="${interval}"][last()]//NE-WBTS_1.0[@measurementType="${measurement_name}"]
    ${required_ne_wbts_elements}  Evaluate Xpath  ${o_me_s}  ${required_xpath}
    ${counters_for_each_distname}  Create Dictionary
    FOR  ${ne_wbts_element}  IN  @{required_ne_wbts_elements}
        ${dn_element}  Get Element  ${ne_wbts_element}  preceding-sibling::MO[@dimension="network_element"]
        ${distname}  Get Element Text  ${dn_element}
        ${distname}  Fetch From Right  ${distname}  /
        ${distname}  Remove String  ${distname}  \n

        ${counters_values}  Create Dictionary
        FOR  ${counter}  IN  @{counters}
            ${value}  Get Element Text  ${ne_wbts_element}  child::${counter}
            Set To Dictionary  ${counters_values}  ${counter}=${value}
        END
        Set To Dictionary  ${counters_for_each_distname}  ${distname}=${counters_values}
    END

    RETURN  ${counters_for_each_distname}


Compare Dictionaries
    [Arguments]  ${actual_values}  ${expected_values}
    FOR  ${counter}  IN  @{expected_values}
        IF  '${counter}' in ['M8020C3', 'M8020C5']
            ${diff}  Evaluate  int(${actual_values}[${counter}])-int(${expected_values}[${counter}])
            Should Be True  ${diff} >= -6 and ${diff} <= 6
        ELSE
            Should Be Equal As Integers  ${actual_values}[${counter}]  ${expected_values}[${counter}]
        END
    END


Get Previous 15min Interval Start Time
    ${current_date}  Get Current Date  result_format=datetime  time_zone=UTC  exclude_millis=True
    ${minutes}  Convert To Integer  ${current_date.minute}

    WHILE  ${minutes} > 15
        ${minutes}  Evaluate  ${minutes} - 15
    END
    ${minutes}  Evaluate  ${minutes} + 15
    ${previous_interval_start_time}  Subtract Time From Date  ${current_date}  00:${minutes}:${current_date.second}  exclude_millis=True
    ${previous_interval_start_time}  Convert Date  ${previous_interval_start_time}  datetime

    RETURN  ${previous_interval_start_time}


Unlock LNBTS If Needed
    ${s1_link_is_locked}  Run Keyword And Return Status  Assert  LNMME  ${LNMME_DN}  s1LinkStatus=regex"Unavailable|unavailable"
    IF  ${s1_link_is_locked}
        Log  \nRecovery action: Unlock LNMME S1 link.  console=true
        Perform Parameter Recommissioning  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNMME-0  administrativeState  update  unlocked
        ...  skip_parameter_relation_errors=${True}  timeout=300
        Assert Every  LNCEL  operationalState=${ENABLED}  timeout=300
    END


TC Setup
    Common Test Setup  tc_name=PM__MME_Connection_Outage


TC Teardown
    Run Keyword If Test Failed  Unlock LNBTS If Needed
    Remove Files  ${BTS_FILES}/IM/*_interval.ims2
    Common Test Teardown
