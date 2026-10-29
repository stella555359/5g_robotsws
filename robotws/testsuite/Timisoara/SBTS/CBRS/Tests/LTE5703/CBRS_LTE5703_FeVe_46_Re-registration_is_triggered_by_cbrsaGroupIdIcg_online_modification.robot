*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Marek Kot
...    Michal Moskala
...    Artur Czainski

*** Keywords ***
CBRS_LTE5703_FeVe_46_Re-registration_is_triggered_by_cbrsaGroupIdIcg_online_modification
    [Documentation]  In this scenario CBSD shall trigger de-registration procedure after operator
    ...              modifies the CBRSA Group Identifer of Interference Coordination Group. CBSD is then
    ...              expected to raise a new registrationRequest with updated values of ICG.
    ...              Tested Requirement: OM_GEN_SFS_CBRS.347

    ${expected_alarms}   Create List     SAS Spectrum Inquiry Failure
    ${ims_alias}         Set Variable    RAT_1ST
    ${enb_id}            Set Variable    ${testlines.${testline_id}.enb_id}

    Kill All SAS Processes

    Wait Until BTS Is Not Busy

    ${precondition_plan}   Replace Variables In File
    ...                      file_path=${CURDIR}/Data/FeVe46/FEVE_46_Precond_delta_tmp.json
    ...                      file_destination=${OUTPUT DIR}/FEVE_46_Precond_delta.json
    ...                      enb_id=${enb_id}

    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
    ...                                         delta_file=${precondition_plan}
    ...                                         connection=${ims_alias}

    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe46/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    Required CBSD Status Should Be Reached    expected_status=Registered
    ...                                       enb_id=${enb_id}
    ${assigned_cbsdId}   Fetch CBSD ID    enb_id=${enb_id}

    Wait Until BTS Is Not Busy
    Start Capturing Historical Alarms

    ${time_start_ICG_changed}   Get Time

    Wait Until Keyword Succeeds    5x    30s    Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBSD-1
    ...    parameter=cbrsaGroupIdIcg
    ...    operation=update
    ...    value=modified_ICG
    ...    connection=${ims_alias}

    Wait For All Cells To Be OnAir
    ${time_stop_ICG_changed}    Get Time

    Required CBSD Status Should Be Reached    expected_status=Registered
    ...                                       enb_id=${enb_id}

    Check For Re-registration Event    time_start=${time_start_ICG_changed}
    ...                                time_stop=${time_stop_ICG_changed}
    ...                                sas_log_path=${sas_logs_dir}
    ...                                cbsd_id=${assigned_cbsdId}

    Verify ICG And CCG In Procedure    time_start=${time_start_ICG_changed}
    ...                                time_stop=${time_stop_ICG_changed}
    ...                                sas_log_path=${sas_logs_dir}
    ...                                procedure=registrationRequest
    ...                                enb_id=${enb_id}

    Verify ICG And CCG In Procedure    time_start=${time_start_ICG_changed}
    ...                                time_stop=${time_stop_ICG_changed}
    ...                                sas_log_path=${sas_logs_dir}
    ...                                procedure=spectrumInquiryRequest
    ...                                enb_id=${enb_id}

    Verify ICG And CCG In Procedure    time_start=${time_start_ICG_changed}
    ...                                time_stop=${time_stop_ICG_changed}
    ...                                sas_log_path=${sas_logs_dir}
    ...                                procedure=grantRequest
    ...                                enb_id=${enb_id}

    ${grant_info}   Get Grant Details For Each CBSD Cell    alias=${ims_alias}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...                           Kill All SAS Processes





