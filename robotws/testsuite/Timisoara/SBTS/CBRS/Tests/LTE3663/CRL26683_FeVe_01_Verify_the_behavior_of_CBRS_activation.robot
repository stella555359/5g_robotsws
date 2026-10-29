*** Settings ***
Documentation    The purpose of this test case is to check whether the CBSD/SAS communication with commercial SAS
...                is successful during CBRS activation.
...                Author: michal.kosicki@nokia.com
...                Maintainer: Pawel Rokicki


*** Keywords ***
CRL26683_FeVe_01_Verify_the_behavior_of_CBRS_activation

    ${release_version}   Get Active Release Version
    ${sas_port}   Set Variable    4433

    Disable CBRS Feature On eNB
    Log To Console    Disabling CBRS to make sure it registers again
    Sleep And Display Progress    10    s

    Get Current SCF File    ${CURDIR}    scfc_to_check_parameters.xml    export_type=runtimeObjects    connection=RAT_1ST
    ${cbsd_status}   Evaluate Xpath    ${CURDIR}/scfc_to_check_parameters.xml
    ...    string(.//managedObject[contains(@distName,"LNBTS-${testlines.${testline_id}.enb_id}/CBSD-1")]/p[@name="cbsdRegistrationState"])
    Should Be True    '${cbsd_status}' == 'Unregistered'
    Check Cell Operational State    cell_state=Disabled    cell_id=1

    ${sas_pid}    ${sas_log}   Start SAS Process    alias=default    port=${sas_port}
    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir

    Get Current SCF File    ${CURDIR}    scfc_runtime.xml    export_type=runtimeObjects    connection=RAT_1ST
    ${cbsd_status}   Evaluate Xpath    ${CURDIR}/scfc_runtime.xml
    ...    string(.//managedObject[contains(@distName,"LNBTS-${testlines.${testline_id}.enb_id}/CBSD-1")]/p[@name="cbsdRegistrationState"])
    Should Be True    '${cbsd_status}' == 'Registered'

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
