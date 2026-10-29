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
CBRS_LTE5703_FeVe_12_SpectrumInquiry_Procedure_Modification_with_non_success_and_RC_106_and_100
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.375
    ...                Purpose: The purpose of this test is to verify whether Spectrum Inquiry procedure fulfils
    ...                requirements stated by WInnForum Technical Specification version 2.0. In this scenario SAS
    ...                is expected to include responseCode 106 in the first spectrumInquiryResponse and responseCode 100
    ...                in the second one. In the first case CBSD shall re-send the spectrumInquiryRequest after expiration
    ...                of waiting time that may be specified in the responseData array (default waiting interval is 30s).

    ${ims_alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=6827    fault_name=SAS Spectrum Inquiry Failure    severity=Critical
    ...    reason=Inquiry Exception with Reason: 106. ResponseMessage: Do not contact SAS for the time being. ResponseData: 45.
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}

    Kill All SAS Processes

    Wait Until BTS Is Not Busy
    ${precondition_plan}   Replace Variables In File
    ...                      file_path=${CURDIR}/Data/FeVe12/FEVE_12_Precond_delta_tmp.json
    ...                      file_destination=${OUTPUT DIR}/FEVE_12_Precond_delta.json
    ...                      enb_id=${enb_id}
    Perform Delta Recommissioning    delta_file=${precondition_plan}
    ...                              connection=${ims_alias}

    Restore Supported Spectrum    bts_id=${enb_id}

    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB

    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe12/SAS_Sim.conf

    Wait Until BTS Is Not Busy
    ${time_start_first_inquiry}   Get Time
    Enable CBRS Feature On eNB
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    ${assigned_cbsdId}   Fetch CBSD ID    enb_id=${enb_id}
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Wait Until All Cells Reach State    enb_id=${enb_id}   state=operationalState    state_value=Disabled
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=60
    ${time_stop_first_inquiry}   Get Time

    ${response_code_first_inquiry}   Check The Return Code Of SAS Response    time_start=${time_start_first_inquiry}
    ...                                                                         time_stop=${time_stop_first_inquiry}
    ...                                                                         sas_log_path=${sas_logs_dir}
    ...                                                                         procedure=spectrumInquiryResponse
    Should Be Equal    ${response_code_first_inquiry}    ${106}

    ${time_start_second_inquiry}   Get Time
    Wait For Any Grant To Be Authorized    alias=${ims_alias}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    ${time_stop_second_inquiry}   Get Time
    ${response_code_second_inquiry}   Check The Return Code Of SAS Response    time_start=${time_start_second_inquiry}
    ...                                                                          time_stop=${time_stop_second_inquiry}
    ...                                                                          sas_log_path=${sas_logs_dir}
    ...                                                                          procedure=spectrumInquiryResponse
    Should Be Equal    ${response_code_second_inquiry}    ${100}
    Check For Re-registration Event    time_start=${time_start_second_inquiry}
    ...                                time_stop=${time_stop_second_inquiry}
    ...                                sas_log_path=${sas_logs_dir}
    ...                                cbsd_id=${assigned_cbsdId}
    Required CBSD Status Should Be Reached    expected_status=Registered
    ...                                       enb_id=${enb_id}

    ${grant_info}   Get Grant Details For Each CBSD Cell    alias=${ims_alias}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes
