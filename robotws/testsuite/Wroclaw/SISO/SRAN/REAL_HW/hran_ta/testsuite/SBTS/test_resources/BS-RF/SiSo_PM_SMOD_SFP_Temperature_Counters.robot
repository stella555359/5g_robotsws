*** Settings ***
Documentation
...  The purpose of this Test Case is to automatically enter test dedicated state and execute PUSCH performance test models.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_Energy_Efficiency.robot
Library     ../../../../resources/Python/counters_helpers.py

*** Variables ***

${INTERVAL}  15  # for parameter: mtBtsEnergyMonitoring. Please enter only the number. Available intervals in minutes: 15,30,60,360,720,1440
${node}  default
*** Keywords ***
TC__SiSo_PM_SMOD_SFP_Temperature_Counters
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-48337
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the activation and deactivation for Embedded Power Meter
    ...  for Enegry Efficiency Monitoring.
    ...  Power Meter is capable of measure power consumption (DC voltage and amperage) in RF and SM.
    ...  TC includes checking the display PM Counters for SBTS Enegry Consumption and Real Time Measurements.
    ...  Additional for Real-Time Measurements is checking voltage values for all modules (RMOD(s) and SMOD(s)) in configuration.
    ...  Voltage values are collecting for 5 minutes.
    ...  For FSM-r3 should be visible "0" in voltage field because FSM-r3 do not have Power Meter units.
    ...  For RMODs which doesn't support EEM in voltage field should be visible "0"
    ...  Voltage for FSM-r4 and all supported RMODs should be between 48-56V.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-11060 - Initial creation
    ...  - 15.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13191 - Fix related with amount of unsupported RMODs and collecting snapshot
    ...  - 13.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14532 - Changed method for time to wait for Energy Efficiency Monitoring
    ...  - 04.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16468 - Independence from path in KW "Collect PM Counters"
    ...  - 12.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16793 - Added voltage checking for SMOD(s)
    ...  - 23.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16970 - Added voltage checking for RMOD(s)
    ...  - 19.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18255 - Shorten TC name
    ...  - 27.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18661 - Change in timing mechanism
    ...  - 18.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 14.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22332 - Values "Not supported" and "Not avaialable" changed to 0
    ...  - 21.03.2022 - https://jira3.int.net.nokia.com/browse/TAT-22729 - SMOD Counter value verification
    ...  - 19.07.2022 - Changes due to PR645366 - PM unsupported modules has value "-" instead of "0"
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/BS-RF__BTS_Embedded_Power_Meter_for_Energy_
    ...  Efficiency_Monitoring_feature_activation_and_deactivation_in_WebEM__RP000951__Automated_TAT-11060.png


    Set Tags    CA-BS-RF    OWNER-mateusz.kawka@nokia.com    AUTHOR-mateusz.kawka@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CIT    SW-SBTS17A    SW-SBTS18
    ...    FEATURE-RP000951    FEATURE-RP001486_2    FEATURE-RP001145_1

    step1: Preconditions
    step2: Enable SFP SMOD Counters
    step3: Disable SFP SMOD Counters

step1: Preconditions

    Log To Console  ${\n}step1: Preconditions${\n}

    Check Interval  ${INTERVAL}

    ${bts_obj}   admin.Get Parameters For All  BTS
    ${bts_id}    Convert To String  ${bts_obj[0].btsId}
    Set Test Variable  ${OBJECT_VARIABLE_MTSBTSSFPSMOD}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    ${param_list}    Create List    mtSBTSSfpSMOD
    ${reference_dict}    admin.Get Parameter By Distname    ${OBJECT_VARIABLE_MTSBTSSFPSMOD}   ${param_list}
    Run Keyword If  '${reference_dict[0]['parameters']['mtSBTSSfpSMOD']}'!='disabled'
    ...    Run Keywords
    ...    Log to console  mtSBTSSfpSMOD parameter is other than disabled, feature have to be deactivated before test start !
    ...    AND  Fail   Feature mtSBTSSfpSMOD is not disabled, please deactivate it before test start !


step2: Enable SFP SMOD Counters

    Log To Console  ${\n}step2: Enable SFP SMOD Counters${\n}

    Log to console  mtSBTSSfpSMOD is setting to ${INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_MTSBTSSFPSMOD}  mtSBTSSfpSMOD
    ...  update  ${INTERVAL}min
    Log To Console  mtSBTSSfpSMOD recommissioned to ${INTERVAL}min !\nNow check if cells are onAir...\n

    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'
    ...  Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}
#
    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Log To Console  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    ${pm_length_enabled}  ${last_timestamp_enabled}  Verify SFP SMOD Counter And Return Length
    Set Test Variable  ${PM_LENGTH_ENABLED}
    Set Test Variable  ${LAST_TIMESTAMP_ENABLED}

step3: Disable SFP SMOD Counters

    Log To Console  ${\n}step3: Disable SFP SMOD Counters${\n}
    Log to console  mtSBTSSfpSMOD is setting to ${INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_MTSBTSSFPSMOD}  mtSBTSSfpSMOD
    ...  update  disabled
    Log To Console  mtSBTSSfpSMOD recommissioned to disabled !\nNow check if cells are onAir...\n

    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'
    ...  Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Log To Console  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    ${pm_length_disabled}  ${last_timestamp_disabled}  Verify SFP SMOD Counter And Return Length

    ${pm_length_compare}=  Run Keyword And Return Status  Should Be Equal  ${PM_LENGTH_ENABLED}  ${pm_length_disabled}
    Run Keyword If  ${pm_length_compare}
    ...  Log To Console  Feature deactivation was successfull, no more counters collected !\n
    ...  ELSE
    ...  Run Keyword And Continue On Failure
    ...  Fail  Feature deactivation wasn't successfull, new counters collected !\n

    ${timestamp_compare}=  Run Keyword And Return Status  Should Be Equal  ${LAST_TIMESTAMP_ENABLED}  ${last_timestamp_disabled}
    Run Keyword If  ${timestamp_compare}
    ...  Log To Console  Feature deactivation was successfull, no new timestamp in counters table after feature deactivation !\n
    ...  ELSE
    ...  Run Keyword And Continue On Failure
    ...  Fail  Feature deactivation wasn't successfull, new timestamp exists in counters table !\n

Verify SFP SMOD Counter And Return Length

    Log To Console  Getting PM Counter M40006C2 and checking values ...\n
    ${pm_counter}  admin.Get Pm Counters  M40006C2  alias=${node}
    ${counters_values_list}  Find Key In Nested Dictionary  ${pm_counter}  M40006C2
    ${counters_values_len}  Get Length  ${counters_values_list}
    Log To Console  Found ${counters_values_len} occurrences of M40006C2 counter !\nNow every counter values will be checked ...\n
    ${last_timestamps_list}  Create List
    FOR  ${dict}  IN  @{counters_values_list}
        ${range_status}  Check Dictionary Values In Range  ${dict}  0  100
        ${last_timestamp}  Get Last Timestamp From Counters Dictionary  ${dict}
        Append To List  ${last_timestamps_list}  ${last_timestamp}
        ${time_status}  Validate Epoch Timestamp  ${last_timestamp}
        Run Keyword If  ${time_status}
        ...  Log To Console  Timestamp is valid !
        ...  ELSE
        ...  Run Keyword And Continue On Failure  Fail  Timestamp is not valid !\n
        Run Keyword If  ${range_status}
        ...  Log To Console  All counters are in range 0-100 !
        ...  ELSE
        ...  Run Keyword And Continue On Failure  Fail  Some counters are out of range 0-100 !\n
    END

    ${all_timetamps_equal_status}  Check If All Elements In List Equal  ${last_timestamps_list}

    Run Keyword If  ${all_timetamps_equal_status}
    ...  Log To Console  All timestamps are the same !
    ...  ELSE
    ...  Run Keyword And Continue On Failure  Fail  Not all timestamps are the same !\n

    ${pm_length}  Evaluate  sum(len(d) for d in ${counters_values_list})

    [Return]  ${pm_length}  ${last_timestamp}

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown

#***Test Cases ***
#test
#    admin.Setup Admin  bts_host=10.44.46.152
#    TC__SiSo_PM_SMOD_SFP_Temperature_Counters
#    admin.Teardown Admin
