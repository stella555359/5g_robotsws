*** Settings ***
Documentation
...    = Author = Karol Palamarz
...    _karol.palamarz@nokia.com_
...    = Maintainer =
...    _karol.palamarz@nokia.com_
...    = Reviewer =
...    _marek.kot@nokia.com_
...    _artur.czainski@nokia.com_
...    = Summary =
...    Test checks eNB initiation relinquish CBSD grant after receiving the response containing Feature Data Exchange set to 'true',
...    responseCode 106 and valid responseData.
...    Grant relinquish is triggered by blocking cell via WebEM.
...    = Pre - Requirements =
...    _actCBRS flag is set to false_
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_LTE5703_FeVe_50_Initiation_of_Relinquish_Grant_with_the_response_containing_FeatureDataExchange_and_response_code_106_and_valid_responseData
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.352, OM_GEN_SFS_CBRS.371
    [Timeout]          40min
    Log    ${\n}Step 1: Test preparation, setup environment    console=true
    ${enb_root_user}            Set Variable    toor4nsn
    ${enb_root_pass}            Set Variable    oZPS0POrRieRtu
    ${enb_id}                   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}                    Set Variable    RAT_1ST
    ${sas_new_config}           Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/SAS_Sim_50.conf
    ${relinquishmentRequest}    Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/relinquishmentRequest.json
    ${relinquishmentResponse_code_106}   Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/relinquishmentResponse_code_106_responseData_60.json
    ${relinquishmentResponse_code_0}   Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/relinquishmentResponse.json
    ${featureDataRequest}       Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/featureDataRequest.json
    ${featureDataResponse}      Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/featureDataResponse.json
    ${expected_fault_list}      Create List     SAS Registration Failure    Cell blocked    SAS Spectrum Relinquishment Failure
    ...                                           Previously downloaded plan was overwritten    SAS Server Communication Failure
    ${bts_side}   Set Variable    *
    Synchronize Time Between VM And eNB In Case Of Difference
    Start Capturing Historical Alarms
    Disable CBRS Feature On eNB
    Wait Until BTS Is Not Busy
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}
    ${log_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${sas_new_config}

    Log    ${\n}Step 2: Enable CBRS feature flag, expecting CBSD registration    console=True
    Enable CBRS Feature On eNB
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    No Alarm Except Allowed Should Appear On EnB

    Log    ${\n}Step 3: Preparing all messages from Infomodel data   console=True
    ${cbsd_object}   Get Random Cbsd Object
    ${cbsd_id}   Get Cbsd Id From Cbsd Object    ${cbsd_object}
    ${cell_id}   Get Random Cell From Cbsd Object    ${cbsd_object}
    ${reliquishmentRequest_messages_infomodel}             Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${relinquishmentRequest}     ${cell_id}    ${cbsd_id}
    ${reliquishmentResponse_messages_code_106_infomodel}   Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${relinquishmentResponse_code_106}    ${cell_id}    ${cbsd_id}
    ${reliquishmentResponse_messages_code_0_infomodel}     Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${relinquishmentResponse_code_0}    ${cell_id}    ${cbsd_id}
    ${featureDataRequest_messages_infomodel}   Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${featureDataRequest}        ${cell_id}    ${cbsd_id}
    ${featureDataResponse_messages_infomodel}   Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${featureDataResponse}       ${cell_id}    ${cbsd_id}
    ${unsuccessful_relinquishment_messages_infomodel}   Create List
    ...    ${reliquishmentRequest_messages_infomodel}    ${reliquishmentResponse_messages_code_106_infomodel}
    ${successful_relinquishment_messages_infomodel}   Create List
    ...    ${reliquishmentRequest_messages_infomodel}    ${reliquishmentResponse_messages_code_0_infomodel}
    ${featureData_messages_infomodel}   Create List    ${featureDataRequest_messages_infomodel}      ${featureDataResponse_messages_infomodel}

    Log To Console    Step 4: Blocking cell, expecting grant relinquishment and featureDataExchange procedure
    taf.sbts.oam.coam.admin.Block Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${cell_id}   connection=RAT_1ST
    Wait Until Keyword Succeeds    10x    10s    Required Cell Block Status Should Be Reached    ${cell_id}    Blocked    ${enb_id}    ${bts_side}
    Wait Until Keyword Succeeds    10x    10s    Check Fault Presence On Selected Cell    ${cell_id}    6830    SAS Spectrum Relinquishment Failure
    ...    Relinquish Exception with Reason: 106. ResponseMessage: Do not contact SAS for the time being. ResponseData: 60.    ${bts_side}

    og To Console    Step 5: Wait for CBSD second relinquishmentRequest / Response and featureDataExchange procedure for cell ${cell_id}
    Sleep    60s    #sleep is needed because CBSD does not contact SAS for the time provided in responseData, no way to check status using infomodel
    ${log_stop}   Get Time

    Log    ${\n}Step 6: Checking if second request was sent after specified 60s period    console=True
    ${relinquishmentRequest_dates}   Get Time For Specific Message From SAS_Sim.log
    ...    ${sas_log}    ${log_start}    ${log_stop}    relinquishmentRequest
    ${time_difference}   Subtract Date From Date    ${relinquishmentRequest_dates[1]}    ${relinquishmentRequest_dates[0]}
    ${time_difference_string}   Convert To String    ${time_difference}
    Should Be Equal    ${time_difference_string}    60.0

    Log    ${\n}Step 7: Getting messages from SAS_Sim.log   console=True
    ${relinquishmentResponse_dates}   Get Time For Specific Message From SAS_Sim.log
    ...    ${sas_log}    ${log_start}    ${log_stop}    relinquishmentResponse
    ${relinquishment_requests}    Get Messages From SAS Log    ${sas_log}    ${log_start}    ${log_stop}    relinquishmentRequest
    ${relinquishment_responses}   Get Messages From SAS Log    ${sas_log}    ${log_start}    ${log_stop}    relinquishmentResponse
    ${featureData_requests}       Get Messages From SAS Log
    ...    ${sas_log}    ${relinquishmentResponse_dates[1]}    ${log_stop}    featureDataRequest
    ${featureData_responses}      Get Messages From SAS Log
    ...    ${sas_log}    ${relinquishmentResponse_dates[1]}    ${log_stop}    featureDataResponse
    ${unsuccessful_relinquishment_messages}   Create List    ${relinquishment_requests[0]}    ${relinquishment_responses[0]}
    ${successful_relinquishment_messages}     Create List    ${relinquishment_requests[1]}    ${relinquishment_responses[1]}
    ${featureData_messages}                   Create List    ${featureData_requests[0]}       ${featureData_responses[0]}

    Log    ${\n}Step 8: Verifing unsuccessful relinquishment messages    console=True
    FOR    ${line}    IN    @{unsuccessful_relinquishment_messages}
        Compare Messages    ${line}    ${unsuccessful_relinquishment_messages_infomodel}
    END

    Log    ${\n}Step 9: Verifing successful relinquishment messages    console=True
    FOR    ${line}    IN    @{successful_relinquishment_messages}
        Compare Messages    ${line}    ${successful_relinquishment_messages_infomodel}
    END

    Log    ${\n}Step 10: Verifing featureData messages after relinquishment procedure    console=True
    FOR    ${line}    IN    @{featureData_messages}
        Compare Messages    ${line}    ${featureData_messages_infomodel}
    END

    [Teardown]    Run Keywords
    ...    taf.sbts.oam.coam.admin.Unblock Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${cell_id}  connection=RAT_1ST    AND
    ...    Wait For All Cells To Be OnAir    AND
    ...    No Alarm Except Allowed Should Appear On EnB    AND
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Save And Check Historical Alarms    expected_alarms=@{expected_fault_list}
