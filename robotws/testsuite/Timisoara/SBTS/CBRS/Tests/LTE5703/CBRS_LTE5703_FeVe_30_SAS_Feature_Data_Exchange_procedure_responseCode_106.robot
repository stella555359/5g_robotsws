*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Katarzyna Olszewska
...    Michal Moskala
...    Jakub Klein
...    Piotr Lukaszewicz

*** Keywords ***
CBRS_LTE5703_FeVe_30_SAS_Feature_Data_Exchange_procedure_responseCode_106
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.374
    ...              Purpose: This scenario verifies if CBSD and SAS successfully exchange supported feature lists.
    ...              If CBSD receives the parameter responseCode = 106 as a response to a featureDataExchangeRequest
    ...              then CBSD waits waitingInterval or default waitingInterval (depending on SW build) and sends featureDataRequest again.

    ${ims_alias}         Set Variable    RAT_1ST
    ${enb_id}            Set Variable    ${testlines.${testline_id}.enb_id}

    Wait Until BTS Is Not Busy
    Kill All SAS Processes

    #SupportedSpectrum is narrowed to certain channels
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB

    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe30/SAS_Sim.conf

    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Required CBSD Status Should Be Reached    expected_status=Registered
    ...                                       enb_id=${enb_id}

    #To make sure CBSD operates on TS2.0 (otherwise featureDataExchange is not supported)
    Check If CBSD Is Registered As TS2.0 Compliant    alias=${ims_alias}
    Start Capturing Historical Alarms
    Wait For Any Grant To Be Authorized       alias=${ims_alias}

    #Waiting for the featureDataRequest to be re-sent after 20seconds upon receiving first successful HeartbeatResponse
    Sleep And Display Progress    waiting_time=90
    ${time_stop}    Get Time

    #The first featureDataResponse brings responseCode106 and the second is successful
    Verify If featureDataRequest Was Resent    sas_logs_dir=${sas_logs_dir}
    ...                                        time_start=${time_start}
    ...                                        time_stop=${time_stop}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Save And Check Historical Alarms    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes


Verify If featureDataRequest Was Resent
    [Arguments]    ${sas_logs_dir}    ${time_start}    ${time_stop}
    [Documentation]    It checks if the first featureDataRequest is responded by SAS with code 106, and then if CBSD has resent the request again
    ${parsed_log_file}           Parse Sas Log File
    ...                            log_file_name=${sas_logs_dir}
    ...                            date_start=${time_start}
    ...                            date_stop=${time_stop}

    ${featureDataRequest}        Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            parameter=cbsdFeatureInfo
    ...                            data_type=featureDataRequest

    ${featureDataResponse}       Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            parameter=responseCode
    ...                            data_type=featureDataResponse

    ${requests_count}   Get Length    ${featureDataRequest}
    Should Be Equal As Numbers   ${requests_count}    ${2}
    Should Contain    ${featureDataResponse}    ${106}
    Should Contain    ${featureDataResponse}    ${0}

