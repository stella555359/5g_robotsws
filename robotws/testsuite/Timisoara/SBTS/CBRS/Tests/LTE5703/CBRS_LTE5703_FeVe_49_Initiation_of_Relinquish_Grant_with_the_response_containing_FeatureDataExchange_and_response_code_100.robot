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
...    Test checks eNB initiation relinquish CBSD grant after receiving the response containing
...    Feature Data Exchange set to 'true' and responseCode 100.
...    Test Case checks messages compatibility.
...    Grant relinquish is triggered by blocking cell via WebEM.
...    = Pre - Requirements =
...    _actCBRS flag is set to false_
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_LTE5703_FeVe_49_Initiation_of_Relinquish_Grant_with_the_response_containing_FeatureDataExchange_and_response_code_100
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.352, OM_GEN_SFS_CBRS.371
    [Timeout]          40min
    Log    ${\n}Step 1: Test preparation, setup environment    console=true
    ${enb_root_user}            Set Variable    toor4nsn
    ${enb_root_pass}            Set Variable    oZPS0POrRieRtu
    ${enb_id}                   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}                    Set Variable    RAT_1ST
    ${sas_new_config}           Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/SAS_Sim_49.conf
    ${relinquishmentRequest}    Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/relinquishmentRequest.json
    ${relinquishmentResponse}   Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/relinquishmentResponse_code_100.json
    ${deregistrationRequest}    Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/deregistrationRequest.json
    ${deregistrationResponse}   Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/deregistrationResponse.json
    ${registrationRequest}      Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/registrationRequest.json
    ${registrationResponse}     Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/registrationResponse.json
    ${featureDataRequest}       Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/featureDataRequest.json
    ${featureDataResponse}      Set Variable    ${CURDIR}/Data/FeVe49-51_and_73/featureDataResponse.json
    ${expected_fault_list}      Create List     SAS Registration Failure    Cell blocked    SAS Spectrum Relinquishment Failure
    ...                                           Previously downloaded plan was overwritten    SAS Server Communication Failure
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
    ${deregistration_requests_infomodel}          Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${deregistrationRequest}     ${cell_id}    ${cbsd_id}
    ${registration_requests_infomodel}            Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest}       ${cell_id}    ${cbsd_id}
    ${featureDataRequest_messages_infomodel}      Create Message With Provided CBSD Cell
    ...    ${bts_side}    ${enb_id}    ${alias}    ${featureDataRequest}        ${cell_id}    ${cbsd_id}


    Log    ${\n}Step 4: Blocking cell, expecting grant relinquishment and featureDataExchange procedure    console=True
    taf.sbts.oam.coam.admin.Block Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${cell_id}   connection=RAT_1ST
    Wait Until Keyword Succeeds    10x    10s    Required Cell Block Status Should Be Reached    ${cell_id}    Blocked    ${enb_id}    ${bts_side}
    Wait Until Keyword Succeeds    10x    10s    Check Fault Presence On Selected Cell    ${cell_id}    6830    SAS Spectrum Relinquishment Failure
    ...    Relinquish Exception with Reason: 100.    ${bts_side}
    ${time_stop}   Get Time

    Log    ${\n}Step 5: Getting messages from SAS_Sim.log   console=True
    ${relinquishment_requests}   Get Messages From SAS Log    ${sas_log}    ${time_start}    ${time_stop}    relinquishmentRequest
    ${relinquishment_response_date}   Get Time For Specific Message From SAS_Sim.log
    ...    ${sas_log}    ${time_start}    ${time_stop}    relinquishmentResponse
    ${deregistration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${relinquishment_response_date[0]}    ${time_stop}    deregistrationRequest
    ${registration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${relinquishment_response_date[0]}    ${time_stop}    registrationRequest


    Log    ${\n}Step 6: Verifing relinquishment messages    console=True
    FOR    ${line}    IN    @{relinquishment_requests[0]}
        Compare Messages    ${line}    ${reliquishmentRequest_messages_infomodel}
    END

    Log    ${\n}Step 7: Verifing deregistration messages after failed relinquishment procedure    console=True
    FOR    ${line}    IN    @{deregistration_requests[0]}
        Compare Messages    ${line}    ${deregistration_requests_infomodel}
    END

    Log    ${\n}Step 8: Verifing registration messages after failed relinquishment procedure    console=True
    FOR    ${line}    IN    @{registration_requests[0]}
        Compare Messages    ${line}    ${registration_requests_infomodel}
    END

    [Teardown]    Run Keywords
    ...    taf.sbts.oam.coam.admin.Unblock Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${cell_id}  connection=RAT_1ST    AND
    ...    Delete ICG And CCG Group ID    AND
    ...    Wait For All Cells To Be OnAir    AND
    ...    No Alarm Except Allowed Should Appear On EnB    AND
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Save And Check Historical Alarms    expected_alarms=@{expected_fault_list}

