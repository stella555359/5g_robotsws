*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    artur.czainski@nokia.com
...    = Summary =
...    The purpose of this test is to verify whether Grant procedure fullfills requirements stated by WInnForum
...    Technical Specification version 2.0. This scenario implies the CBSD will receive the ‘106’ response code,
...    which will cause it to wait for a time specified in ‘timing interval’ field.

*** Keywords ***
CBRS_LTE5703_FeVe_15_Grant_Procedure_with_response_code_106_with_valid_timing_interval
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.296
    [Timeout]    30min

    ${alias}           Set Variable    RAT_1ST
    ${enb_id}          Set Variable    ${testlines.${testline_id}.enb_id}
    ${numberOfCells}   Get Number of Cells    ${enb_id}

    ${bts_side}   Set Variable    *

    Set Test Variable      @{allowed_low_frequencies}    @{EMPTY}
    Append To List         ${allowed_low_frequencies}
    ...                    ${3550000000}
    ...                    ${3560000000}
    ...                    ${3570000000}
    ...                    ${3580000000}

    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    Create Generic Delta And Perform Commissioning    enb_id=${enb_id}
    ...                                               delta_file_tmp=${CURDIR}/Data/feve15/Precondition_delta_tmp.json
    ...                                               delta_file_final=${CURDIR}/Data/feve15/Precondition_delta.json
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    ${expected_alarms}   Create List     SAS Grant Failure
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/feve15/SAS_Sim.conf
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Assert Fault Presence On Selected Cell    cell_id=1    fault_id=6828    alarm_name=SAS Grant Failure    bts_side=${bts_side}
    Start Capturing Historical Alarms
    ${time_intermediate}    Get Time
    Wait For All Cells To Be OnAir
    ${time_stop}   Get Time

    Check If Grant Request is TS2.0 Compliant    alias=${alias}
    ...                                          time_start=${time_start}
    ...                                          time_stop=${time_intermediate}
    ...                                          sas_log_path=${sas_logs_dir}
    ...                                          numberOfCells=${numberOfCells}
    ...                                          allowed_low_frequencies=${allowed_low_frequencies}

    Check If Grant Request is TS2.0 Compliant    alias=${alias}
    ...                                          time_start=${time_intermediate}
    ...                                          time_stop=${time_stop}
    ...                                          sas_log_path=${sas_logs_dir}
    ...                                          numberOfCells=${numberOfCells}
    ...                                          allowed_low_frequencies=${allowed_low_frequencies}

    [Teardown]    Run Keywords
    ...    Kill All SAS Processes    AND
    ...    Run Keyword And Continue On Failure    Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...    Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...    Get SAS Logs To Logs Dir    alias=default

