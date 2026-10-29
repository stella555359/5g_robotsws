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
...    Artur Czainski

*** Keywords ***
CBRS_LTE5703_FeVe_11_SpectrumInquiry_Procedure_Modification_with_CA_service_enabled
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.375
    ...                Purpose: The purpose of this test is to verify whether Spectrum Inquiry procedure fulfils
    ...                requirements stated by WInnForum Technical Specification version 2.0.
    ...                This scenario checks channel selection algorithm with CBSDCELs configured in various ways in
    ...                terms of desiredPmax. Carrier Aggregation feature is enabled.

    ${ims_alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}

    Kill All SAS Processes
    Restore Supported Spectrum    bts_id=${enb_id}
    Wait Until BTS Is Not Busy

    ${precondition_plan}   Replace Variables In File
    ...                      file_path=${CURDIR}/Data/FeVe11/FEVE_11_Precond_delta_tmp.json
    ...                      file_destination=${OUTPUT DIR}/FEVE_11_Precond_delta.json
    ...                      enb_id=${enb_id}
    ${postcondition_plan}   Replace Variables In File
    ...                       file_path=${CURDIR}/Data/FeVe11/FEVE_11_Postcond_delta_tmp.json
    ...                       file_destination=${OUTPUT DIR}/FEVE_11_Postcond_delta.json
    ...                       enb_id=${enb_id}
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${precondition_plan}    connection=${ims_alias}

    Disable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe11/SAS_Sim.conf
    Wait Until BTS Is Not Busy
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Start Watchdog Alarm Detection
    Wait For Any Grant To Be Authorized    alias=${ims_alias}
    Wait For All Cells To be Onair

    ${grant_info}   Get Grant Details For Each CBSD Cell    alias=${ims_alias}
    ${time_stop}    Get Time

    ${available_channels_list}   Check If Inquiry is TS2.0 Compliant
    ...                            alias=${ims_alias}
    ...                            time_start=${time_start}
    ...                            time_stop=${time_stop}
    ...                            sas_log_path=${sas_logs_dir}
    ...                            enb_id=${enb_id}

    Check If CBSD Has Only Requested Available Channels    available_channels_list=${available_channels_list}
    ...                                                    grant_info=${grant_info}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Perform Delta Recommissioning    delta_file=${postcondition_plan}
    ...                               connection=${ims_alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes
