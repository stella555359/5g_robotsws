*** Settings ***
Documentation
...    = Author = Karol Pa?amarz
...    _karol.palamarz@nokia.com_
...    = Maintainer =
...    _karol.palamarz@nokia.com_
...    = Reviewer =
...    _marek.kot@nokia.com_
...    _artur.czainski@nokia.com_
...    = Summary =
...    Test checks eNB initiation relinquish CBSD grant after receiving the response containing Feature Data Exchange set to
...    ?true? and responseCode 100.
...    Test Case checks messages compatibility.
...    Grant relinquish is triggered by blocking cell via WebEM.
...    = Pre - Requirements =
...    _actCBRS flag is set to false_
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_LTE5703_FeVe_49_Initiation_of_Relinquish_Grant_with_the_response_containing_FeatureDataExchange_and_response_code_100
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.352
    [Timeout]          40min
    Log    ${\n}Step 1: Test preparation, setup environment    console=true
    ${enb_root_user}            Set Variable    toor4nsn
    ${enb_root_pass}            Set Variable    oZPS0POrRieRtu
    ${enb_id}                   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}                    Set Variable    RAT_1ST
    ${sas_new_config}           Set Variable    ${CURDIR}/Data/SAS_Sim_49.conf
    ${relinquishmentRequest}    Set Variable    ${CURDIR}/Data/relinquishmentRequest.json
    ${relinquishmentResponse}   Set Variable    ${CURDIR}/Data/relinquishmentResponse_code_100.json
    ${deregistrationRequest}    Set Variable    ${CURDIR}/Data/deregistrationRequest.json
    ${deregistrationResponse}   Set Variable    ${CURDIR}/Data/deregistrationResponse.json
    ${registrationRequest}      Set Variable    ${CURDIR}/Data/registrationRequest.json
    ${registrationResponse}     Set Variable    ${CURDIR}/Data/registrationResponse.json
    ${featureDataRequest}       Set Variable    ${CURDIR}/Data/featureDataRequest.json
    ${featureDataResponse}      Set Variable    ${CURDIR}/Data/featureDataResponse.json
    ${expected_fault_list}      Create List     SAS Registration Failure    Cell blocked    SAS Spectrum Relinquishment Failure
    ...    Previously downloaded plan was overwritten    SAS Server Communication Failure
    ${bts_side}   Set Variable    *
    Synchronize Time Between VM And eNB In Case Of Difference
    Start Capturing Historical Alarms
    Add ICG And CCG Group ID
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Wait Until BTS Is Not Busy
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}
    ${time_start}   Get Time
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
    ${reliquishmentRequest_messages_infomodel}    Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${relinquishmentRequest}     ${cell_id}    ${cbsd_id}
    ${reliquishmentResponse_messages_infomodel}   Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${relinquishmentResponse}    ${cell_id}    ${cbsd_id}
    ${deregistration_requests_infomodel}          Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${deregistrationRequest}     ${cell_id}    ${cbsd_id}
    ${deregistration_responses_infomodel}         Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${deregistrationResponse}    ${cell_id}    ${cbsd_id}
    ${registration_requests_infomodel}            Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest}       ${cell_id}    ${cbsd_id}
    ${registration_responses_infomodel}           Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse}      ${cell_id}    ${cbsd_id}
    ${featureDataRequest_messages_infomodel}      Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${featureDataRequest}        ${cell_id}    ${cbsd_id}
    ${featureDataResponse_messages_infomodel}     Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${featureDataResponse}       ${cell_id}    ${cbsd_id}
    ${relinquishment_messages_infomodel}   Create List    ${reliquishmentRequest_messages_infomodel}    ${reliquishmentResponse_messages_infomodel}
    ${deregistration_messages_infomodel}   Create List    ${deregistration_requests_infomodel}          ${deregistration_responses_infomodel}
    ${registration_messages_infomodel}   Create List    ${registration_requests_infomodel}            ${registration_responses_infomodel}
    ${featureData_messages_infomodel}   Create List    ${featureDataRequest_messages_infomodel}      ${featureDataResponse_messages_infomodel}

    Log    ${\n}Step 4: Blocking cell, expecting grant relinquishment and featureDataExchange procedure    console=True
    taf.sbts.oam.coam.admin.Block Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${cell_id}   connection=RAT_1ST
    Wait Until Keyword Succeeds    10x    10s    Required Cell Block Status Should Be Reached    ${cell_id}    Blocked    ${enb_id}    ${bts_side}
    Wait Until Keyword Succeeds    10x    10s    Check Fault Presence On Selected Cell    ${cell_id}    6830    SAS Spectrum Relinquishment Failure
    ...    Relinquish Exception with Reason: 100.    ${bts_side}
    ${time_stop}   Get Time

    Log    ${\n}Step 5: Getting messages from SAS_Sim.log   console=True
    ${relinquishment_requests}        Get Messages From SAS Log    ${sas_log}    ${time_start}    ${time_stop}    relinquishmentRequest
    ${relinquishment_responses}       Get Messages From SAS Log    ${sas_log}    ${time_start}    ${time_stop}    relinquishmentResponse
    ${relinquishment_response_date}   Get Time For Specific Message From SAS_Sim.log    ${sas_log}    ${time_start}
    ...    ${time_stop}    relinquishmentResponse
    ${deregistration_requests}        Get Messages From SAS Log    ${sas_log}    ${relinquishment_response_date[0]}
    ...    ${time_stop}    deregistrationRequest
    ${deregistration_responses}       Get Messages From SAS Log    ${sas_log}    ${relinquishment_response_date[0]}
    ...    ${time_stop}    deregistrationResponse
    ${registration_requests}          Get Messages From SAS Log    ${sas_log}    ${relinquishment_response_date[0]}
    ...    ${time_stop}    registrationRequest
    ${registration_responses}         Get Messages From SAS Log    ${sas_log}    ${relinquishment_response_date[0]}
    ...    ${time_stop}    registrationResponse

    ${relinquishment_messages}        Create List    ${relinquishment_requests[0]}    ${relinquishment_responses[0]}
    ${deregistration_messages}        Create List    ${deregistration_requests[0]}    ${deregistration_responses[0]}
    ${registration_messages}          Create List    ${registration_requests[0]}      ${registration_responses[0]}

#    disabled below line due to Step 9 removal
#    ${featureData_messages}           Create List    ${featureData_requests[0]}       ${featureData_responses[0]}

    Log    ${\n}Step 6: Verifing relinquishment messages    console=True
    FOR    ${line}    IN    @{relinquishment_messages}
        Compare Messages    ${line}    ${relinquishment_messages_infomodel}
    END

    Log    ${\n}Step 7: Verifing deregistration messages after failed relinquishment procedure    console=True
    FOR    ${line}    IN    @{deregistration_messages}
        Compare Messages    ${line}    ${deregistration_messages_infomodel}
    END

    Log    ${\n}Step 8: Verifing registration messages after failed relinquishment procedure    console=True
    FOR    ${line}    IN    @{registration_messages}
        Compare Messages    ${line}    ${registration_messages_infomodel}
    END


    [Teardown]    Run Keywords
    ...    taf.sbts.oam.coam.admin.Unblock Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${cell_id}  connection=RAT_1ST    AND
    ...    Delete ICG And CCG Group ID    AND
    ...    Wait For All Cells To Be OnAir    AND
    ...    No Alarm Except Allowed Should Appear On EnB    AND
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Save And Check Historical Alarms    expected_alarms=@{expected_fault_list}
