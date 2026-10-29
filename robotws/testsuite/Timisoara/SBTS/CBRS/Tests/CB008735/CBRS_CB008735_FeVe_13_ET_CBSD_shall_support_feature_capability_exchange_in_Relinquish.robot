*** Settings ***
Documentation
...    = Author =
...    Elzbieta.Wlodarczyk@nokia.com
...    = Maintainer =
...    Elzbieta.Wlodarczyk@nokia.com
...    = Reviewer =
...    Karol.Sadowski@nokia.com
...    Piotr.Lukaszewicz@nokia.com
...    Lukasz.lechowicz@nokia.com
...    Aleksandra.Chudzik@nokia.com

*** Keywords ***
CBRS_CB008735_FeVe_13_ET_CBSD_shall_support_feature_capability_exchange_in_Relinquish
    [Documentation]  Requirement: LTE_OPR_REQ_23595
    ...              Purpose: This case verifies if CBSD supports feature capability exchange during Relinquish procedure
    ...              with featureCapabilityExchangeTrigger set to "TRUE"
    ...              Step 1: Start SAS Processes
    ...              Step 2: Checking presence of reliquishmentRequest and reliquishmentResponse
    ...              Step 3: Checking presence of featureCapabilityExchangeRequests


    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}

    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Enable CBRS Feature On eNB

    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585    3590    3595   3600
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}


    Replace Variables In File    ${CURDIR}/Data/Feve13/Feve13_precondition_delta.json
    ...                          ${OUTPUT_DIR}/Feve13_precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/Feve13/Feve13_postcondition_delta.json
    ...                          ${OUTPUT_DIR}/Feve13_postcondition_delta.json
    ...                          enb_id=${enb_id}

    Log To Console    Preconditions
    Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                         ${OUTPUT_DIR}/Feve13_precondition_delta.json
    ...                                         connection=RAT_1ST

    Log To Console    Step 1: Start SAS Processes
    ${time_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/Feve13/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection
    ${time_stop}   Get Time

    Log To Console    Step 2: Checking presence of reliquishmentRequest and reliquishmentResponse
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}

    ${relinquishmentResponse}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                          parameter=responseCode
    ...                                                          data_type=relinquishmentResponse

    Should Be Equal As Numbers    ${relinquishmentResponse[0]}    0   msg=relinquishmentRequest and relinquishmentResponse does not occur in SAS logs

    Log To Console    Step 3: Checking presence of featureCapabilityExchangeRequests
    Verify Presence of featureDataExchange After Certain Procedure    start_from=relinquishmentResponse
    ...                                                               time_start=${time_start}
    ...                                                               time_stop=${time_stop}
    ...                                                               sas_log_path=${sas_log}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/Feve13_postcondition_delta.json
    ...                                                                       connection=RAT_1ST    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}
