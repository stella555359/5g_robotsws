*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Marek Kot
...    Michal Moskala
...    Albert Sakowicz

*** Keywords ***
CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.296
    ...                Purpose: The purpose of this test is to verify whether Spectrum Inquiry procedure fullfills
    ...                requirements stated by WInnForum Technical Specification version 2.0. This scenario implies the
    ...                presence of both 'cbsdFrequencyGuidance' and groupingConfig in the spectrumInquiryResponse.
    ...                CBSD shall request only for channels presented in the latest cbsdFrequencyGuidance.

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${ims_alias}   Set Variable    RAT_1ST
    &{expected_alarm_1}   Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ...                                          reason=No available frequency.
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}

    Kill All SAS Processes
    Modify Bandwidth For All Cbsd Cells    enb_id=${enb_id}    required_chbw=10

    ${add_Icg_Ccg_plan}   Replace Variables In File
    ...                     file_path=${CURDIR}/Data/FeVe08/FeVe_08_add_Icg_Ccg_tmp.json
    ...                     file_destination=${OUTPUT DIR}/FeVe_08_add_Icg_Ccg.json
    ...                     enb_id=${enb_id}
    Wait Until Keyword Succeeds    20x    15s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${add_Icg_Ccg_plan}    connection=${ims_alias}

    Disable CBRS Feature On eNB

    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=60
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe08/SAS_Sim.conf
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait For Any Grant To Be Authorized    alias=${ims_alias}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=60

    ${grant_info}   Get Grant Details For Each CBSD Cell    alias=${ims_alias}
    ${time_stop}   Get Time

    Check If Inquiry is TS2.0 Compliant    alias=${ims_alias}
    ...                                    time_start=${time_start}
    ...                                    time_stop=${time_stop}
    ...                                    sas_log_path=${sas_logs_dir}
    ...                                    enb_id=${enb_id}

    Check If Granted Channels Follow FrequencyGuidance    time_start=${time_start}
    ...                                                   time_stop=${time_stop}
    ...                                                   sas_log_path=${sas_logs_dir}
    ...                                                   grant_list=${grant_info}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes
