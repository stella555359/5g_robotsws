*** Settings ***
Documentation
...    = Author =
...    katarzyna.olszewska@nokia.com
...    = Maintainer =
...    katarzyna.olszewska@nokia.com
...    = Reviewer =
...    Lukasz Lechowicz
...    Jakub Klein
...    Piotr Lukaszewicz
...    Aleksandra Chudzik
...    Justyna Durak

*** Keywords ***
CBRS_LTE5703_FeVe_29_SAS_Feature_Data_Exchange_procedure_responseCode_100
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.374
    ...              Purpose: This scenario verifies if CBSD and SAS successfully exchange supported feature lists.
    ...              If CBSD receives the parameter responseCode = 100 as a response to a featureDataExchangeRequest
    ...              then eNB should start deregistration procedure and later attempt to reregister again.

    ${ims_alias}         Set Variable    RAT_1ST
    ${enb_id}            Set Variable    ${testlines.${testline_id}.enb_id}

    Wait Until BTS Is Not Busy
    Kill All SAS Processes

    #SupportedSpectrum is narrowed to certain channels
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB

    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe29/SAS_Sim.conf

    ${test_time_start}   Get Time
    Enable CBRS Feature On eNB
    Required CBSD Status Should Be Reached    expected_status=Registered
    ...                                       enb_id=${enb_id}

    #To make sure CBSD operates on TS2.0 (otherwise featureDataExchange is not supported)
    Check If CBSD Is Registered As TS2.0 Compliant    alias=${ims_alias}
    Start Capturing Historical Alarms
    Wait For Any Grant To Be Authorized       alias=${ims_alias}

    #Waiting for the featureDataRequest to be re-sent after 20seconds upon receiving first successful HeartbeatResponse
    Sleep And Display Progress    waiting_time=90
    ${test_time_stop}    Get Time

    # featureDataResponse brings responseCode100 and deregistration will start
    Verify If featureDataRequest Was sent once and check if deregistration occured    sas_logs_dir=${sas_logs_dir}
    ...                                        test_time_start=${test_time_start}
    ...                                        test_time_stop=${test_time_stop}

    Wait For All Cells To Be OnAir

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Save And Check Historical Alarms    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes

Verify If featureDataRequest Was sent once and check if deregistration occured
    [Arguments]    ${sas_logs_dir}    ${test_time_start}    ${test_time_stop}
    [Documentation]    It checks if the first featureDataRequest is responded by SAS with code 100, and then if CBSD has resent the request again
    ${parsed_log_file}           Parse Sas Log File
    ...                            log_file_name=${sas_logs_dir}
    ...                            date_start=${test_time_start}
    ...                            date_stop=${test_time_stop}

    ${featureDataRequest}        Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            parameter=cbsdFeatureInfo
    ...                            data_type=featureDataRequest

    ${featureDataResponse}       Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            parameter=responseCode
    ...                            data_type=featureDataResponse

    ${featureId}                 Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            parameter=featureId
    ...                            data_type=featureDataRequest

    ${deregistrationRequest}     Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            parameter=cbsdId
    ...                            data_type=deregistrationRequest

    ${deregistrationResponse}    Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            parameter=responseCode
    ...                            data_type=deregistrationResponse

    ${requests_count}   Get Length    ${featureDataRequest}
    Should Be Equal As Numbers   ${requests_count}    ${1}
    Should Contain    ${featureDataResponse}    ${100}
    Should Contain    ${featureId}    WF_ENHANCED_GROUP_HANDLING

    ${deregistration_count}   Get Length    ${deregistrationRequest}
    Should Be Equal As Numbers   ${deregistration_count}    ${1}
    Should Contain    ${deregistrationResponse}    ${0}
