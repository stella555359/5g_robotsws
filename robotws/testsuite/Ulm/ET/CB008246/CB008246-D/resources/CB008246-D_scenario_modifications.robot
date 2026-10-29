*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008246-D

Library     Collections
Library     ../../../L2/libraries/template_functions.py    WITH NAME    template
Resource    ../../../../resources/Common/wts_ue.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***

${target_bler}           100,100,100,95,90,50,10,1,0.5,0.1,0,0,0,0,0



*** Keywords ***

#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}
    log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    [Documentation]   Set UE_Cqi report and config target_mcs before attach
    Set UE IDs String List
    wts_ue.Update UE Channel State Information  profile_id=1  cqi=4  cqi_mode=fixed  ri=0  ri_mode=fixed
    De-Activate Testmode For UE    testmode=csi_override    action=activate
    wts_ue.Configure NR Advanced BLER testmode  profile_id=1  target_bler_profile_id=1  target_bler=${target_bler}  target_mcs=2
    ...    rank=0  mcs_table=all  p_target_bler_profile_id=1


Run Feature specific keywords after attach before traffic is started
    RETURN

Run Feature specific keywords during traffic before detach
    [Documentation]
    ...    Keep amount of time to check the data transmision in HRDRB
    ...    Update UE_Cqi to lower value to prepare the bad radio condition
    ...    Active the target_mcs blet test mode to make HR switch to BR
    ...    after amount of time, deactive the adv_bler_testmode to see if BR can switch back to HR

    [Arguments]  @{varargs}

    Sleep    2s
    Display Traffic Data Rate
    Sleep    3s
    wts_ue.Update UE Channel State Information  profile_id=1  cqi=1  cqi_mode=fixed  ri=0  ri_mode=fixed
    De-Activate Testmode For UE    testmode=csi_override    action=activate
    De-Activate Testmode For UE    testmode=adv_bler    action=activate
    Sleep    2s
    Display Traffic Data Rate
    Sleep    3s
    wts_ue.Update UE Channel State Information  profile_id=1  cqi=8  cqi_mode=fixed  ri=1  ri_mode=fixed
    De-Activate Testmode For UE    testmode=csi_override    action=activate
    De-Activate Testmode For UE    testmode=adv_bler    action=deactivate
    Sleep    2s
    Display Traffic Data Rate


Run Feature specific keywords after traffic before detach
    De-Activate Testmode For UE    testmode=csi_override    action=deactivate


Run Feature specific keywords after detach
    RETURN


#----------- Specific KW  -----------------------------------------------------------------------------------------------------------[150 characters]
Display Traffic Data Rate
    ${_}  ${bearer_stats_attribs_sa}=  template.get_bearer_stat_params  scenario_name=${scenario_name}
    ${tp}=  Run Keyword And Warn On Failure    wts_ue.Get Bearer Stats From Egate
    ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  pdu=${bearer_stats_attribs_sa["pdus"]}
    ...  qfi=${bearer_stats_attribs_sa["qfis"]}  dir=bi
    Log to console    Current DL throughput for UE${bearer_stats_attribs_sa["ues"]} is ${tp} bps


Set UE IDs String List
    ${attached_ue_list}=    template.Get_Ue_Ids_Configured_For_Scenario    scenario_name=${scenario_name}
    Collections.Sort List  ${attached_ue_list}
    ${STRING_ATTACHED_UE_LIST}=    Catenate    SEPARATOR=,    @{attached_ue_list}
    Set Test Variable    ${STRING_ATTACHED_UE_LIST}


De-Activate Testmode For UE
    [Arguments]    ${testmode}   ${action}
        wts_ue.Associate UEs To Testmode  ue_id=${STRING_ATTACHED_UE_LIST}  profile_id=1  scell=primary  testmode=${testmode}  action=${action}
