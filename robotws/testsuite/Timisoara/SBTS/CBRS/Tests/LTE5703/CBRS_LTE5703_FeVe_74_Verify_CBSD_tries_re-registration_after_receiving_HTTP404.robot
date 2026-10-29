*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    piotr.lukaszewicz@nokia.com
...    katarzyna.olszewska@nokia.com
...    jakub.klein@nokia.com

*** Keywords ***
CBRS_LTE5703_FeVe_74_Verify_CBSD_tries_re-registration_after_receiving_HTTP404
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.281
    ...                Purpose: The purpose of this test is to cover scenario reported previously under PR533550.
    ...                After receiving HTTP status code 404 from SAS, CBSD shall retry the registration with lower TS protocol version.
    ...                The CBSD should not change its status to Registered unless it receives successful reigstrationResponse from SAS.
    ...                When CBSD receives status code 404 from SAS, using TS protocol in the lowest version (1.0), CBSD shall retry
    ...                again with initial protocol version (i.e. 2.0)


    &{expected_alarm}   Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    ...                                        reason=Register Exception with Reason: 100.
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    ${ims_alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}

    Kill All SAS Processes
    ## Disabling CBRS to make sure it starts the new registration with TS2.0 protocol ##
    Disable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ## Starting SASSim configured in a way it keeps on sending HTTP404 for each received request ##
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_74/SAS_Sim_HTTP404.conf
    Enable CBRS Feature On eNB

    ## We expect a fault to be raised due to unsuccessful registration ##
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=30

    ## This method checks if CBSD has tried all the capable TS version for the registration ##
    Check If Registration Request Was Re-tried After Receiving HTTP404    sas_logs_dir=${sas_logs_dir}

    ## This method makes sure the CBSD does not change its state to 'Registered'
    Check If CBSD Remains In Unregistered State    enb_id=${enb_id}    ims_alias=${ims_alias}

    ## In the background a new SASSim is set-up with a default configuration (no HTTP404) ##
    Kill All SAS Processes
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_74/SAS_Sim_default.conf

    ## CBSD should successfuly register to the SASSim after configuration was changed ##
    Wait For All Cells To Be OnAir
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=30
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes

Check If Registration Request Was Re-tried After Receiving HTTP404
    [Documentation]    This method checks in SASSim.log if CBSD has tried all the capable TS version for the registration
    [Arguments]    ${sas_logs_dir}
    @{TS_registration_list}   Create List    POST /v2.0/registration    POST /v1.2/registration
    ...                                        POST /v1.1/registration    POST /v1.0/registration
    ${SAS_log}   OperatingSystem.Get File    ${sas_logs_dir}
    FOR    ${ts_version}    IN    @{TS_registration_list}
      Should Contain    ${SAS_log}    ${ts_version}    msg=CBSD has not tried to register with some lower TS version after receiving HTTP404
    END

Check If CBSD Remains In Unregistered State
    [Documentation]    This method makes sure the CBSD does not change its state to 'Registered'
    [Arguments]    ${enb_id}    ${ims_alias}
    ${is_CBSD_registered}   Run Keyword And Return Status    ute_admin_infomodel.Query InfoModel
    ...                       query=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-* is [cbsdRegistrationState!="Unregistered"]
    ...                       timeout=120
    ...                       alias=${ims_alias}
    IF  '${is_CBSD_registered}'=='True'  FAIL  msg=cbsdRegistrationState has unexpectedly changed to Registered despite receiving HTTP404
