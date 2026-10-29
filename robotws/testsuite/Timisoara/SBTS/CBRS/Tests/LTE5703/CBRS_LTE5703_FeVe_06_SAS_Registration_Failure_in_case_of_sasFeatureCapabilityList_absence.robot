*** Settings ***
Documentation
...    = Author = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    _artur.czainski@nokia.com_
...    _karol.palamarz@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Summary =
...    The purpose of this test is to verify whether whether eNB is able to react properly
...    when recives DeregistrationResponse with Response Code: 106 and at the same time responseData is valid.

*** Keywords ***
CBRS_LTE5703_FeVe_06_SAS_Registration_Failure_in_case_of_sasFeatureCapabilityList_absence
    [Documentation]   This Test Case checks if CBSD Registration Procedure to SAS v2 fails after receiving registration
    ...   response message from SAS without sasFeatureCapabilityList
    ...   Purpose: Verify if the registration  procedure is modified and TS2.0 compliant
    ...   LTE5703 CFAM, requirement OM_GEN_SFS_CBRS.281
    [Timeout]    20min
    Log    Setting preconditions and variables...    console=true
    Disable CBRS Feature On eNB
    @{allowed_alarms}   Set Variable    ${enb_allowed_alarms}
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    @{mandatory_alarms}  Create List   {'faultId': '6826', 'faultName': 'SAS Registration Failure', 'severity': 'Critical'}
    @{expected_alarms}   Create List     SAS Server Communication Failure    SAS Registration Failure
    ${registrationRequest_1}    Set Variable    ${CURDIR}/Data/FeVe_06/registrationRequest_1.json
    ${registrationResponse_1}   Set Variable    ${CURDIR}/Data/FeVe_06/registrationResponse_1.json
    ${registrationRequest_2}    Set Variable    ${CURDIR}/Data/FeVe_06/registrationRequest_2.json
    ${bts_side}   Set Variable    *
    Wait Until BTS Is Not Busy
    Add ICG And CCG Group ID

    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}
    ${first_registration_log_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_06/SAS_Sim.conf

    Log    Step 1: Enable the feature flag    console=true
    Wait Until BTS Is Not Busy
    Start Capturing Historical Alarms
    Enable CBRS Feature On eNB

    Log    Step 2: Check eNB alarms and prepare template registration messages    console=true
    Wait Until Keyword Succeeds    10x    10s    Admin Alarms Get And Check
    ...                                          mandatory=@{mandatory_alarms}
    ...                                          allowed=${allowed_alarms}
    ...                                          alias=RAT_1ST
    ${request_message_reg}  IF  ${SUM_OF_CBSDS}==3   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    RAT_1ST    ${registrationRequest_1}    Registered
    ${request_message_unreg}   Create Registration Request Messages According to CBSD State
    ...   ${bts_side}    ${enb_id}    RAT_1ST    ${registrationRequest_1}    Unregistered
    IF  ${SUM_OF_CBSDS}==3
         ${request_message}  Create List    ${request_message_reg}    ${request_message_unreg}
    ELSE
         ${request_message}  Create List    ${request_message_unreg}
    END
    ${response_message_0_unreg}   Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    RAT_1ST    ${registrationResponse_1}    Unregistered
    ${response_message_0_reg}   IF  ${SUM_OF_CBSDS}==3     Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    RAT_1ST    ${registrationResponse_1}    Registered
    IF  ${SUM_OF_CBSDS}==3
        ${response_message}  Create List    ${response_message_0_unreg}    ${response_message_0_reg}
    ELSE
        ${response_message}  Create List    ${response_message_0_unreg}
    END

    ${second_registration_log_start}   Get Time
    ${request_message_reg_2}     Create Registration Request Messages According to CBSD State
    ...   ${bts_side}    ${enb_id}    RAT_1ST    ${registrationRequest_2}    Unregistered
    Wait Until Keyword Succeeds    10x    10s    Admin Alarms Get And Check
    ...                                          mandatory=${EMPTY}
    ...                                          allowed=${allowed_alarms}
    ...                                          alias=RAT_1ST
    ${first_registration_log_stop}   Get Time

    Log    Step 3: Compare parameters in CBSD Registration Request and Response messages with templates  console=true
    ${request_message_reg}   Create Registration Request Messages According to CBSD State
    ...   ${bts_side}    ${enb_id}    RAT_1ST    ${registrationRequest_1}    Registered
    ${first_registration_requests}   Get Messages From SAS Log    ${sas_log}    ${first_registration_log_start}
    ...    ${first_registration_log_stop}    registrationRequest
    FOR    ${line}    IN    @{request_message[0]}
        Compare Messages    ${line}    ${first_registration_requests}
    END

    Log    Step 4: Check second Registrationrequest for radio that got empty sasFeatureCapabilityList in first request    console=true
    ${second_registration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${second_registration_log_start}    ${first_registration_log_stop}    registrationRequest
    FOR    ${line}    IN    @{request_message_reg_2}
       Compare Messages    ${line}    ${second_registration_requests}
    END

    ute_admin_infomodel.Query Infomodel
    ...                    query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...                    timeout=360
    ...                    alias=RAT_1ST


    Log    Scenaro passed!    console=true
    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Delete ICG And CCG Group ID    AND
    ...    Save And Check Historical Alarms    expected_alarms=@{expected_alarms}
