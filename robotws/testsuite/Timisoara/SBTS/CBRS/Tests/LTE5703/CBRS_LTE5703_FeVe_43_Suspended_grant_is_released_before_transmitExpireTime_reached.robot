*** Settings ***
Documentation
...    = Author = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Maintainer = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Reviewer = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
CBRS_LTE5703_FeVe_43_Suspended_grant_is_released_before_transmitExpireTime_reached
    [Documentation]    The purpose of this test is to verify whether eNB behaves correctly when channel suspension
    ...                is released before transmit expiry time is reached. It is realized by SAS Sim configuration.
    ...                Tested Requirement: OM_GEN_SFS_CBRS.381

    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log To Console    Setting SAS to respond 501 for 3rd heartbeat and then release suspension
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/SAS_conf_43.conf
    Enable CBRS Feature On eNB
    Log To Console    CBRS enabled, waiting to get onair
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Watchdog Alarm Detection

    Log To Console    Waiting for suspend and it's release
    Sleep And Display Progress    90    s
    Log To Console    Checking SAS log for amount of grants and suspensions
    ${amount_of_grant_request}   Run    grep 'grantRequest' ${sas_log} | wc -l
    ${amount_of_heartbeats_with_suspension}   Run    grep 'The grant is suspended' ${sas_log} | wc -l
    ${amount_of_relinquishment_requests}   Run    grep 'relinquishmentRequest' ${sas_log} | wc -l
    Log To Console    Amount of RMODs: ${SUM_OF_CBSDS}
    Log To Console    Amount of grants: ${amount_of_grant_request}
    Log To Console    Amount of suspensions: ${amount_of_heartbeats_with_suspension}
    Log To Console    Amount of relinquishments: ${amount_of_relinquishment_requests}
    Should Be Equal As Numbers    ${amount_of_grant_request}    ${SUM_OF_CBSDS}
    Should Be Equal As Numbers    ${amount_of_heartbeats_with_suspension}    ${SUM_OF_CBSDS}
    Should Be Equal As Numbers    ${amount_of_relinquishment_requests}    0

    Log To Console    Grants are ok, checking if eNB onair again
    Watchdog Check For Failures
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Log To Console    eNB is onair, checking historical alarms

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
