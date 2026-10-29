*** Settings ***
Documentation    Scenario specific keywords for Feature <ID>
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    ../../../../ET/L2/libraries/template_functions.py    WITH NAME  template_functions
Library    Collections
Resource    ../../../../ET/L2/resources/common_keywords.robot
Resource    ../../../../ET/L2/resources/TEAL_additional_keywords.robot

*** Keywords ***

#-----------For Test Execution -----------------#
Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}

Run Feature specific keywords before attach
    RETURN


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    IF  'Test TTI' == '${TEST_NAME}'   RETURN
    Attach more UEs
    ${iterations}=  Evaluate  ${traffic_duration} / 2
    TEAL_additional_keywords.Collect Bearer Stats and save to Json and DF  ${iterations}
    ...  2s  modern


Run Feature specific keywords after traffic before detach
    RETURN

Run Feature specific keywords after detach
    RETURN

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Attach more UEs
    ${list_of_sa_ue_to_be_attached}=  template_functions.Get Attach List  scenario_name=${scenario_name}  ue_type=sa  with_auto_attach=False
    Log to Console  Register UEs to 5G
    ${ue_ids}=  Get Dictionary Keys  ${list_of_sa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_sa_ue_to_be_attached}  ${ue_id}
        ${status}=    run keyword and return status
        ...    Try to Register SA UE and save its RNTI    ${ue_id}    ${ue_parameters}
        IF    ${FALSE}==${status}    Log    Try to Register SA UE and save its RNTI on UE${ue_id} FAILED!    level=ERROR
        ${status}=    run keyword and return status
        ...    ucl.kwrun
        ...        wts_ue.Set traffic type    ue_id=${ue_id}    pdu_id=${ue_parameters["pdu"]}    trf_type=internal
        IF    ${FALSE}==${status}    Log    Set traffic type on UE${ue_id} FAILED!    level=ERROR
        ${status}=    run keyword and return status
        ...    ucl.kwrun
        ...        wts_ue.UE PDU Session Setup    ue_id=${ue_id}    pdu=${ue_parameters["pdu"]}    gw=${ue_id}  nwslice=1
        IF    ${FALSE}==${status}    Log    UE PDU Session Setup on UE${ue_id} FAILED!    level=ERROR
        log to console  UE${ue_id} is registered to 5G in SA Mode!
    END

#-----------For Suite Setup -----------------#
Make necessary changes to SCF
    RETURN

Update Basic Configuration File
    RETURN
