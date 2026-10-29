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
...    Technical Specification version 2.0. This scenario implies the lack of presence of either cbsdFrequencyGuidance
...    or featureDataExchange paramenters.

*** Keywords ***
CBRS_LTE5703_FeVe_14_Grant_Procedure_without_cbsdFrequencyGuidance_and_featureDataExchange_present
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.296
    [Timeout]    30min

    ${alias}           Set Variable    RAT_1ST
    ${enb_id}          Set Variable    ${testlines.${testline_id}.enb_id}
    ${numberOfCells}   Get Number of Cells    ${enb_id}
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
    ...                                               delta_file_tmp=${CURDIR}/Data/feve14/Precondition_delta_tmp.json
    ...                                               delta_file_final=${CURDIR}/Data/feve14/Precondition_delta.json
    Disable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/feve14/SAS_Sim.conf
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Capturing Historical Alarms
    ${time_stop}    Get Time
    Check If Grant Request is TS2.0 Compliant    alias=${alias}
    ...                                          time_start=${time_start}
    ...                                          time_stop=${time_stop}
    ...                                          sas_log_path=${sas_logs_dir}
    ...                                          numberOfCells=${numberOfCells}
    ...                                          allowed_low_frequencies=${allowed_low_frequencies}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Run Keyword And Continue On Failure    Save And Check Historical Alarms    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes

